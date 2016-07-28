unit ComPort;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, Synaser,
  Vcl.ExtCtrls, IniFiles;

type
  TByteDynPoleW=class(TObject)
    public
      Pole: TBytes;
      constructor Create(p_pole: TBytes);
  end;

type
  TCPort = class(TDataModule)
    Timer1: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    t_opkod: Byte;
    t_pocbajtov: Byte;
    t_sprava: TBytes;
    t_akt_bajt: Integer;
    t_port: TBlockSerial;

    t_portcislo: string;
    t_rychlost: Cardinal;
    t_hwflow: Boolean;
    t_simulacia: Boolean;

    t_simbuffer: TBytes;

    t_posl_ziadost_adresa: Integer;

    t_povely: TQueue<TByteDynPoleW>;

    procedure SpracujSpravuB0;
    procedure SpracujSpravuB4;
    procedure SpracujSpravuBC;

    procedure SpracujSpravu;
    procedure PreverOdpoved;
    procedure DiscardniSpravu(p_vypis: Boolean);

    procedure PridajBajt(p_bajt: Byte);
    procedure VydajPovel(p_povel: TBytes);
    procedure ZapisPovel(p_povel: TByteDynPoleW);
  public
    { Public declarations }
    property PortCislo: string read t_portcislo;
    property JeSimulacia: Boolean read t_simulacia;

    function DajPocetPovelov: Integer;
    procedure VydajPovel82;
    procedure VydajPovel83;
    procedure VydajPovelB0(p_adresa: Integer; p_nahodeny: Boolean);
    procedure VydajPovelBC(p_adresa: Integer);
    procedure NastavPort(p_port: INteger);

    procedure Pripoj;
  end;

var
  CPort: TCPort;

implementation
  uses DiagDialog, Types, MMSystem, LogikaNemsova, Forms;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TByteDynPoleW.Create(p_pole: TBytes);
var
  i: Integer;
begin
  SetLength(Pole,Length(p_pole));
  for i := Low(p_pole) to High(p_pole) do pole[i]:=p_pole[i];
end;

////////////////////////////////////////////////////////////////////////////////

function TCPort.DajPocetPovelov: Integer;
begin
  Result:=t_povely.Count;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.DataModuleCreate(Sender: TObject);
var
  subor: TIniFile;
begin
  t_opkod:=0;
  SetLength(t_sprava,0);
  t_akt_bajt:=0;
  t_povely:=TQueue<TByteDynPoleW>.Create;
  t_port:=TBlockSerial.Create;

  t_portcislo:='COM2';
  t_rychlost:=115200;
  t_hwflow:=False;
  t_simulacia:=False;
  SetLength(t_simbuffer,0);

  subor:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\conf.ini');
  try
    t_portcislo:=subor.ReadString('Main','COMPort','COM1');
    t_rychlost:=subor.ReadInteger('Main','Rychlost',115200);
    t_hwflow:=subor.ReadBool('Main','HWFlow',False);
    t_simulacia:=subor.ReadBool('Main','Simulacia',False);
  finally
    subor.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.DataModuleDestroy(Sender: TObject);
begin
  t_povely.Free;
  t_port.Free;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.NastavPort(p_port: INteger);
begin
  t_portcislo:='COM'+IntToStr(p_port);
  DiagDlg.Label5.Caption:=t_portcislo;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.Pripoj;
begin
  if not t_simulacia then
  begin
    t_port.Connect(t_portcislo);
    sleep(1000);
    t_port.Config(t_rychlost, 8, 'N', SB1, False, t_hwflow);
    sleep(500);
  end;

  Timer1.Enabled:=True;

  VydajPovel83;

  DiagDlg.Button1.Enabled:=False;

  DataModule1.OtestujVyhybky;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.DiscardniSpravu(p_vypis: Boolean);
var
  text: string;
begin
  if p_vypis then
  begin
    text:='Zmazaná neúplná správa OC: '+IntToHex(t_opkod,2);
    DiagDlg.Memo1.Lines.Insert(0,text);
  end;

  t_opkod:=0;
  SetLength(t_sprava,0);
  t_pocbajtov:=0;
  t_akt_bajt:=0;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.SpracujSpravuB0;
var
  adresa: Cardinal;
  smer,stav: Boolean;
  smertext,stavtext: string;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  adresa:=t_sprava[0]+((t_sprava[1] and $0F) shl 7)+1;
  smer:=(t_sprava[1] and $20)<>0;
  stav:=(t_sprava[1] and $10)<>0;

  if smer then smertext:='Nahodené' else smertext:='Zhodené';
  if stav then stavtext:='ZAP' else stavtext:='VYP';

  DataModule1.SpracujSpravuB0(adresa,smer);

  DiagDlg.Memo1.Lines.Insert(0,'Spracovaná správa B0, adr: '+IntToStr(adresa)+', smer: '+smertext+', stav: '+stavtext);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.SpracujSpravuBC;
var
  adresa: Cardinal;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  adresa:=t_sprava[0]+((t_sprava[1] and $0F) shl 7)+1;

  t_posl_ziadost_adresa:=adresa;

  DiagDlg.Memo1.Lines.Insert(0,'Spracovaná správa BC, adr: '+IntToStr(adresa));
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.SpracujSpravuB4;
var
  ack_opkod: Byte;
  ack: Byte;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  ack_opkod:=t_sprava[0] or $80;
  ack:=t_sprava[1];

  DiagDlg.Memo1.Lines.Insert(0,'Spracovaná správa B4, opkod: '+IntToHex(ack_opkod,2)+', stav: '+IntToHex(ack,2));

  if (ack_opkod=$BC) and (t_posl_ziadost_adresa>0) then
  begin
    DataModule1.SpracujSpravuBCB4(t_posl_ziadost_adresa,ack<>$50);
    t_posl_ziadost_adresa:=0;
  end;
end;

////////////////////////////////////////////////////////////////////////////////


procedure TCPort.Timer1Timer(Sender: TObject);
var
  buf: array[0..15] of Byte;
  output: Integer;
  i: Integer;
  text: string;
  prvy: Boolean;
  tmp: Byte;
begin
  Timer1.Enabled:=False;

  try
    if not t_simulacia then output:=t_port.RecvBufferEx(@buf,15,50)
    else
    begin
      for i:=Low(t_simbuffer) to High(t_simbuffer) do
      begin
        tmp:=t_simbuffer[i];
        buf[i]:=tmp;
      end;

      output:=Length(t_simbuffer);
      SetLength(t_simbuffer,0);
    end;

    for i := 0 to output-1 do PridajBajt(buf[i]);

    if DiagDlg.VypisCele.Checked and (output>0) then
    begin
      text:='Prijaté bajty: ';

      prvy:=True;
      for i := 0 to output-1 do
      begin
        if prvy then prvy:=false else text:=text+',';
        text:=text+IntToHex(buf[i],2);
      end;

      DiagDlg.Memo1.Lines.Insert(0,text);
    end;
  except
    on e: Exception do DiscardniSpravu(True);
  end;

  Timer1.Enabled:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.SpracujSpravu;
begin
  try
    case t_opkod of
      $B0: SpracujSpravuB0;
      $B4: SpracujSpravuB4;
      $BC: SpracujSpravuBC;
      else DiagDlg.Memo1.Lines.Insert(0,'Neplatny opkod '+IntToHex(t_opkod,2));
    end;
  except
    on e: Exception do DiagDlg.Memo1.Lines.Insert(0,'Chyba pri spracovani spravy '+e.Message);
  end;

  PreverOdpoved;
  DiscardniSpravu(False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.PridajBajt(p_bajt: Byte);
begin
  if(p_bajt and $80)<>0 then //najdeny opkod
  begin
    if(t_opkod<>0) then DiscardniSpravu(True)
    else
    begin
      assert(Length(t_sprava)=0);
      assert(t_akt_bajt=0);
    end;

    t_opkod:=p_bajt;

    //nastavenie poctu bajtov spravy
    case((t_opkod shr 5) and $03) of
      0:
      begin
        t_pocbajtov:=1;
        SetLength(t_sprava,t_pocbajtov);
      end;
      1:
      begin
        t_pocbajtov:=3;
        SetLength(t_sprava,t_pocbajtov);
      end;
      2:
      begin
        t_pocbajtov:=5;
        SetLength(t_sprava,t_pocbajtov);
      end;
      3:
      begin
        assert(t_pocbajtov=0);
        assert(Length(t_sprava)=0);
      end
      else assert(False,'Neplatna dlzka spravy v opcode');
    end;

    assert(t_akt_bajt=0);
  end
  else
  begin
    if(t_opkod<>0) then
    begin
      if (t_pocbajtov=0) and (p_bajt>0) then //nacitanie poctu bajtov
      begin
        t_pocbajtov:=p_bajt-1;
        SetLength(t_sprava,t_pocbajtov);
        assert(t_akt_bajt=0);
      end
      else //nacitanie bajtu spravy
      begin
        if t_akt_bajt<Length(t_sprava) then
        begin
          t_sprava[t_akt_bajt]:=p_bajt;
          Inc(t_akt_bajt);

          if(t_akt_bajt=t_pocbajtov) then SpracujSpravu;
        end
        else DiscardniSpravu(False);
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelB0(p_adresa: Integer; p_nahodeny: Boolean);
var
  buf: TBytes;
  nahodeny: Byte;
begin
  if(p_adresa>0) then
  begin
    SetLength(buf,4);

    if p_nahodeny then nahodeny:=$01 else nahodeny:=$00;

    buf[0]:=$B0;
    buf[1]:=(p_adresa-1) and $7F;
    buf[2]:=((p_adresa shr 7) and $0F) or ((nahodeny and $01) shl 5) or $10;
    buf[3]:=$FF xor buf[0] xor buf[1] xor buf[2];

    VydajPovel(buf);

    buf[2]:=((p_adresa shr 7) and $0F) or ((nahodeny and $01) shl 5) or $00;
    buf[3]:=$FF xor buf[0] xor buf[1] xor buf[2];

    VydajPovel(buf);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelBC(p_adresa: Integer);
var
  buf: TBytes;
begin
  if(p_adresa>0) then
  begin
    SetLength(buf,4);

    buf[0]:=$BC;
    buf[1]:=(p_adresa-1) and $7F;
    buf[2]:=((p_adresa shr 7) and $0F);
    buf[3]:=$FF xor buf[0] xor buf[1] xor buf[2];

    VydajPovel(buf);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovel82;
var
  buf: TBytes;
begin
  SetLength(buf,2);

  buf[0]:=$82;
  buf[1]:=$FF xor buf[0];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovel83;
var
  buf: TBytes;
begin
  SetLength(buf,2);

  buf[0]:=$83;
  buf[1]:=$FF xor buf[0];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovel(p_povel: TBytes);
var
  povel: TBytes;
  i: Integer;
begin
  if t_simulacia or t_port.InstanceActive then
  begin
    SetLength(povel,Length(p_povel));
    for i := Low(p_povel) to High(p_povel) do povel[i]:=p_povel[i];

    t_povely.Enqueue(TByteDynpoleW.Create(povel));
    if t_povely.Count=1 then ZapisPovel(t_povely.Peek);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.PreverOdpoved;
var
  buf: TBytes;
  i: Integer;
begin
  if t_povely.Count>0 then
  begin
    SetLength(buf,Length(t_sprava)+1);

    buf[0]:=t_opkod;
    for i := 0 to Length(t_sprava)-1 do buf[i+1]:=t_sprava[i];

    if (Length(buf)=Length(t_povely.Peek.Pole)) and CompareMem(buf,t_povely.Peek.Pole,Length(buf)) then
    begin
      t_povely.Peek.Free;
      t_povely.Dequeue;

      if t_povely.Count>0 then ZapisPovel(t_povely.Peek);
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.ZapisPovel(p_povel: TByteDynPoleW);
var
  text: string;
  i: Integer;
  prvy: Boolean;
  v_out: Integer;
begin

  if not t_simulacia then
  begin
    while not t_port.CanWrite(50) do;
    v_out:=0;

    while v_out<Length(p_povel.Pole) do
    begin
      v_out:=v_out+t_port.SendBuffer(@(p_povel.Pole[v_out]),Length(p_povel.Pole)-v_out);
      DiagDlg.Memo1.Lines.Insert(0,'Zapísané bajtov:'+IntToStr(v_out));
      sleep(50);
    end;
  end
  else
  begin
    SetLength(t_simbuffer,Length(p_povel.Pole));
    t_simbuffer:=Copy(p_povel.Pole,0,Length(p_povel.Pole));
  end;

  prvy:=True;
  for i := Low(p_povel.Pole) to High(p_povel.Pole) do
  begin
    if prvy then prvy:=False else text:=text+',';
    text:=text+IntToHex(p_povel.Pole[i],2);
  end;

  DiagDlg.Memo1.Lines.Insert(0,'Zapísaná správa:'+text);
end;


end.
