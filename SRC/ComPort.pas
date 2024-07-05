unit ComPort;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.ExtCtrls,
  System.SyncObjs,
  CPortThread;

type
  TCPort = class(TDataModule)
    Timer1: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    t_portcislo: string;
    t_rychlost: Cardinal;
    t_hwflow: Boolean;
    t_simulacia: Boolean;

    t_vlakno: TCPortThread;

    procedure VydajPovel(p_povel: TBytes);
  public
    { Public declarations }
    property PortCislo: string read t_portcislo;
    property JeSimulacia: Boolean read t_simulacia;

    procedure Nastav(p_port: string; p_rychlost: Integer; p_hwflow: Boolean; p_simulacia: Boolean);

    function DajPocetPovelov: Integer;
    procedure VydajPovel82;
    procedure VydajPovel83;
    procedure VydajPovelB0(p_adresa: Word; p_nahodeny: Boolean);
    procedure VydajPovelBC(p_adresa: Word);

    procedure VydajPovelBF(p_adresa: Word);
    procedure VydajPovelBB(p_slot: Byte);
    procedure VydajPovelBA(p_slot_zdroj,p_slot_ciel: Byte);

    //programovanie podla Uhlenbrocku (TRK a POM ma rozdielnu strukturu!)
    procedure VydajPovelEDProgramTRK(p_read: Boolean; p_cv: Word; p_data: Byte);
    procedure VydajPovelEDProgramPOM(p_read: Boolean; p_pom_adresa: Word; p_cv: Word; p_data: Byte);

    procedure VydajPovelEFHodiny(p_rate: Byte; p_mins: Byte; p_hours: Byte; p_days: Byte; p_id: Word);

    //programovanie podla Digitraxu
    procedure VydajPovelEFProgram(p_cmd: Byte; p_pom_adresa: Word; p_trk: Byte; p_cv: Word; p_data: Byte);


    procedure NastavPort(p_port: INteger);



    procedure Pripoj;
  end;

var
  CPort: TCPort;

implementation
  uses
    Winapi.MMSystem,
    System.Types,
    Vcl.Forms,
    Generics.Collections,
    DiagDialog,
    LogikaStavadlo,
    ProgDialog;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TCPort.DajPocetPovelov: Integer;
begin
  if t_vlakno<>nil then Result:=t_vlakno.DajPocetPovelov
  else Result:=0;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.DataModuleCreate(Sender: TObject);
begin
  t_portcislo:='COM5';
  t_rychlost:=115200;
  t_hwflow:=False;
  t_simulacia:=False;

  t_vlakno:=nil;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.Nastav(p_port: string; p_rychlost: Integer; p_hwflow: Boolean; p_simulacia: Boolean);
begin
  t_portcislo:=p_port;
  t_rychlost:=p_rychlost;
  t_hwflow:=p_hwflow;
  t_simulacia:=p_simulacia;

  if t_vlakno<>nil then t_vlakno.Nastav(p_port,p_rychlost,p_hwflow,p_simulacia);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.DataModuleDestroy(Sender: TObject);
begin
  if t_vlakno<>nil then FreeAndNil(t_vlakno);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.NastavPort(p_port: INteger);
begin
  t_portcislo:='COM'+IntToStr(p_port);

  if t_vlakno<>nil then t_vlakno.NastavPort(p_port);

  DiagDlg.Label5.Caption:=t_portcislo;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.Pripoj;
begin
  t_vlakno:=TCPortThread.Create;
  t_vlakno.Nastav(t_portcislo,t_rychlost,t_hwflow,t_simulacia);
  t_vlakno.Start;

  t_vlakno.CakajNaPripojenie;

  Timer1.Enabled:=True;

  VydajPovel83;
  LogikaES.ResetujDohlady(nil);


  DiagDlg.Button1.Enabled:=False;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.Timer1Timer(Sender: TObject);
var
  vstup: TList<TCPortZprava>;
  vstup_debug: TList<string>;
begin
  Timer1.Enabled:=False;
  try
    if t_vlakno<>nil then
    begin
      vstup:=TList<TCPortZprava>.Create;
      try
        vstup_debug:=TList<string>.Create;
        try
           if t_vlakno.DajVystup(vstup,vstup_debug) then
          begin
            for var vsprava in vstup do
            begin
              if vsprava is TCPortZpravaB0 then LogikaES.SpracujSpravuB0((vsprava as TCPortZpravaB0).Adresa,(vsprava as TCPortZpravaB0).Smer)
              else if vsprava is TCPortZpravaB2 then LogikaES.SpracujSpravuB2((vsprava as TCPortZpravaB2).Adresa,(vsprava as TCPortZpravaB2).Stav)
              else if vsprava is TCPortZpravaBCB4 then LogikaES.SpracujSpravuBCB4((vsprava as TCPortZpravaBCB4).Adresa,(vsprava as TCPortZpravaBCB4).Ack)
              else if vsprava is TCPortZpravaBFB4 then ProgDlg.SpracujSpravuBFB4((vsprava as TCPortZpravaBFB4).Adresa,(vsprava as TCPortZpravaBFB4).Stav)
              else if vsprava is TCPortZpravaBAB4 then ProgDlg.SpracujSpravuBAB4((vsprava as TCPortZpravaBAB4).Slot)
              else if vsprava is TCPortZpravaEFB4 then ProgDlg.SpracujSpravuEFB4((vsprava as TCPortZpravaEFB4).Slot,(vsprava as TCPortZpravaEFB4).Odpoved)
              else if vsprava is TCPortZpravaE7Slot then ProgDlg.SpracujSpravuE7Slot((vsprava as TCPortZpravaE7Slot).Slot,(vsprava as TCPortZpravaE7Slot).Adresa,(vsprava as TCPortZpravaE7Slot).Stat,(vsprava as TCPortZpravaE7Slot).Rychlost,(vsprava as TCPortZpravaE7Slot).Dirf,(vsprava as TCPortZpravaE7Slot).Trk,(vsprava as TCPortZpravaE7Slot).SS2,(vsprava as TCPortZpravaE7Slot).Snd,(vsprava as TCPortZpravaE7Slot).ID)
              else if vsprava is TCPortZpravaE7Program then ProgDlg.SpracujSpravuE7Program((vsprava as TCPortZpravaE7Program).PCMD,(vsprava as TCPortZpravaE7Program).PStat,(vsprava as TCPortZpravaE7Program).POMAdresa,(vsprava as TCPortZpravaE7Program).TRK,(vsprava as TCPortZpravaE7Program).CV,(vsprava as TCPortZpravaE7Program).Data)
              //else if vsprava is TCPortZpravaEFCas then CasDlg.SpracujSpravuEFCas((vsprava as TCPortZpravaEFB4).Slot,(vsprava as TCPortZpravaEFB4).Odpoved)
            end;

            for var v_debug in vstup_debug do
            begin
              if DiagDlg.VypisCele.Checked then DiagDlg.Memo1.Lines.Add(v_debug);
            end;
          end;
        finally
          vstup_debug.Free;
        end;
      finally
        vstup.Free;
      end;
    end;
  finally
    Timer1.Enabled:=True;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelB0(p_adresa: Word; p_nahodeny: Boolean);
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

procedure TCPort.VydajPovelBC(p_adresa: Word);
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

procedure TCPort.VydajPovelBF(p_adresa: Word);
var
  buf: TBytes;
begin
  if(p_adresa>0) then
  begin
    SetLength(buf,4);

    buf[0]:=$BF;
    buf[1]:=((p_adresa shr 7) and $7F);
    buf[2]:=(p_adresa) and $7F;
    buf[3]:=$FF xor buf[0] xor buf[1] xor buf[2];

    VydajPovel(buf);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelBB(p_slot: Byte);
var
  buf: TBytes;
begin
  SetLength(buf,4);

  buf[0]:=$BB;
  buf[1]:=p_slot and $7F;
  buf[2]:=0;
  buf[3]:=$FF xor buf[0] xor buf[1] xor buf[2];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelBA(p_slot_zdroj,p_slot_ciel: Byte);
var
  buf: TBytes;
begin
  SetLength(buf,4);

  buf[0]:=$BA;
  buf[1]:=p_slot_zdroj and $7F;
  buf[2]:=p_slot_ciel and $7F;
  buf[3]:=$FF xor buf[0] xor buf[1] xor buf[2];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

function VytvorCVH(p_cv: Word; p_data: Byte): Byte;
begin
  Result:=0;

  if (p_cv and $200)<>0 then Result:=Result or $20;
  if (p_cv and $100)<>0 then Result:=Result or $10;
  if (p_data and $80)<>0 then Result:=Result or $02;
  if (p_cv and $80)<>0 then Result:=Result or $01;
end;

////////////////////////////////////////////////////////////////////////////////

//Podla uhlenbrocku, opisane zo zdrojakov JMRI
procedure TCPort.VydajPovelEDProgramTRK(p_read: Boolean; p_cv: Word; p_data: Byte);
var
  buf: TBytes;
  v_rezim: Byte;
begin
  if p_read then v_rezim:=$72 else v_rezim:=$71;

  SetLength(buf,31);
  buf[0]:=$ED;
  buf[1]:=$1F;
  buf[2]:=$01;
  buf[3]:=$49;
  buf[4]:=$42;
  buf[5]:=$71 or ((p_data and $80) shr 4) or ((p_cv and $80) shr 6);
  buf[6]:=v_rezim;
  buf[7]:=p_cv and $7F;
  buf[8]:=(p_cv shr 8) and $7F;
  buf[9]:=p_data and $7F;
  buf[10]:=$70;
  buf[11]:=$00;
  buf[12]:=$00;
  buf[13]:=$00;
  buf[14]:=$00;
  buf[15]:=$10;
  buf[16]:=$00;
  buf[17]:=$00;
  buf[18]:=$00;
  buf[19]:=$00;
  buf[20]:=$00;
  buf[21]:=$00;
  buf[22]:=$00;
  buf[23]:=$00;
  buf[24]:=$00;
  buf[25]:=$00;
  buf[26]:=$00;
  buf[27]:=$00;
  buf[28]:=$00;
  buf[29]:=$00;

  buf[30]:=$FF xor buf[0] xor buf[1] xor buf[2] xor buf[3] xor buf[4] xor buf[5] xor buf[6] xor buf[7] xor buf[8] xor buf[9] xor buf[10] xor buf[11] xor buf[12] xor buf[13] xor buf[14] xor buf[15] xor buf[16] xor buf[17] xor buf[18] xor buf[19] xor buf[20] xor buf[21] xor buf[22] xor buf[23] xor buf[24] xor buf[25] xor buf[26] xor buf[27] xor buf[28] xor buf[29];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelEDProgramPOM(p_read: Boolean; p_pom_adresa: Word; p_cv: Word; p_data: Byte);
var
  buf: TBytes;
  v_rezim: Byte;
begin
  if p_read then v_rezim:=$5C else v_rezim:=$5E;

  SetLength(buf,31);
  buf[0]:=$ED;
  buf[1]:=$1F;
  buf[2]:=$01;
  buf[3]:=$49;
  buf[4]:=$42;
  buf[5]:=$71 or ((p_pom_adresa and $80) shr 7) or ((p_cv and $80) shr 4);
  buf[6]:=v_rezim;
  buf[7]:=p_pom_adresa and $7F;
  buf[8]:=(p_pom_adresa shr 8) and $7F;
  buf[9]:=p_cv and $7F;
  buf[10]:=$70 or ((p_data and $80) shr 6);
  buf[11]:=(p_cv shr 8) and $7F;
  buf[12]:=p_data and $7F;
  buf[13]:=$00;
  buf[14]:=$00;
  buf[15]:=$10;
  buf[16]:=$00;
  buf[17]:=$00;
  buf[18]:=$00;
  buf[19]:=$00;
  buf[20]:=$00;
  buf[21]:=$00;
  buf[22]:=$00;
  buf[23]:=$00;
  buf[24]:=$00;
  buf[25]:=$00;
  buf[26]:=$00;
  buf[27]:=$00;
  buf[28]:=$00;
  buf[29]:=$00;

  buf[30]:=$FF xor buf[0] xor buf[1] xor buf[2] xor buf[3] xor buf[4] xor buf[5] xor buf[6] xor buf[7] xor buf[8] xor buf[9] xor buf[10] xor buf[11] xor buf[12] xor buf[13] xor buf[14] xor buf[15] xor buf[16] xor buf[17] xor buf[18] xor buf[19] xor buf[20] xor buf[21] xor buf[22] xor buf[23] xor buf[24] xor buf[25] xor buf[26] xor buf[27] xor buf[28] xor buf[29];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

//Podla digitraxu, opisane z Loconet-Personal edition
procedure TCPort.VydajPovelEFProgram(p_cmd: Byte; p_pom_adresa: Word; p_trk: Byte; p_cv: Word; p_data: Byte);
var
  buf: TBytes;
begin
  SetLength(buf,14);
  buf[0]:=$EF;
  buf[1]:=$0E;
  buf[2]:=$7C;
  buf[3]:=p_cmd and $7F;
  buf[4]:=$0;
  buf[5]:=(p_pom_adresa shr 7) and $7F;
  buf[6]:=p_pom_adresa and $7F;
  buf[7]:=p_trk;
  buf[8]:=VytvorCVH(p_cv,p_data);
  buf[9]:=p_cv and $7F;
  buf[10]:=p_data and $7F;
  buf[11]:=$0;
  buf[12]:=$0;
  buf[13]:=$FF xor buf[0] xor buf[1] xor buf[2] xor buf[3] xor buf[4] xor buf[5] xor buf[6] xor buf[7] xor buf[8] xor buf[9] xor buf[10] xor buf[11] xor buf[12];

  VydajPovel(buf);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovelEFHodiny(p_rate: Byte; p_mins: Byte; p_hours: Byte; p_days: Byte; p_id: Word);
begin

end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPort.VydajPovel(p_povel: TBytes);
begin
  if t_vlakno<>nil then t_vlakno.PridajPovel(p_povel);
end;

end.
