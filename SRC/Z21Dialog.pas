unit Z21Dialog;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, ipwcore, ipwudpport,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdGlobal,
  Generics.Collections;

type
  TPrudVystupnyHodnota=record
    Prud: Double;
    Cas: TDateTime;
  end;

type
  TZ21Dlg = class(TForm)
    Memo1: TMemo;
    IdUDPClient1: TIdUDPClient;
    PripojBtn: TButton;
    Timer1: TTimer;
    Button2: TButton;
    FWVBtn: TButton;
    Button4: TButton;
    StopBtn: TButton;
    Panel1: TPanel;
    OdpojBtn: TButton;
    Button3: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FWVBtnClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure PripojBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure OdpojBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    t_cas_komunikacie: Integer;
    t_vyrobne_cislo: Cardinal;
    t_verzia: string;

    t_stav: string;
    t_prud_vstupny: string;
    t_prud_spatny: string;
    t_prud_prog_kolaj: string;
    t_napatie_vstupne: string;
    t_napatie_vnutorne: string;
    t_teplota_vnutorna: string;
    t_vystraha: string;

    function VypisData(const p_data: TIdBytes): string;

    procedure SpracujSpravu0040F3(p_data: TIdBytes);
    procedure SpracujSpravu004061(p_data: TIdBytes);
    procedure SpracujSpravu004081(p_data: TIdBytes);

    procedure SpracujSpravu0010(p_data: TIdBytes);
    procedure SpracujSpravu0040(p_data: TIdBytes);
    procedure SpracujSpravu0084(p_data: TIdBytes);

    procedure SpracujSpravu(const p_opkod: Word; const p_data: TIdBytes);
    procedure SpracujDatagram(const p_dlzka: Word; const p_data: TIdBytes);
    procedure SpracujData(const p_data: TIdBytes);
  public
    { Public declarations }
    property Verzia: string read t_verzia;
    property VyrobneCislo: Cardinal read t_vyrobne_cislo;

    procedure Pripoj;
    procedure Odpoj(p_destrukcia: Boolean);
    function JePripojene: Boolean;
    procedure Posli(const p_header: Word); overload;
    procedure Posli(const p_header: Word; const p_data: TIdBytes); overload;
    procedure PosliX(const p_header: Word; const p_data: TIdBytes);

    procedure GetSN;
    procedure GetFWV;
    procedure SetBFlags;
    procedure SetLogout;
    procedure ZrusSkrat;
    procedure Stop;

    procedure AppIdle;
  end;

var
  Z21Dlg: TZ21Dlg;

implementation

{$R *.dfm}

uses GUI1, ComPort;

procedure TZ21Dlg.Pripoj;
begin
  if JePripojene then Odpoj(False);
  
  IdUDPClient1.Connect;

  Timer1.Enabled:=True;
  GetSN;
  sleep(100);
  GetFWV;
  sleep(100);
  SetBFlags;

  PripojBtn.Enabled:=False;
  OdpojBtn.Enabled:=True;

  Form1.Z21Panel.Visible:=True;
  Form1.Z21M.Enabled:=True;
  Form1.Z21M.Checked:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Odpoj(p_destrukcia: Boolean);
begin
  Timer1.Enabled:=False;

  if JePripojene then
  begin
    SetLogout;
    IdUDPClient1.Disconnect;
  end;

  if(not p_destrukcia) then
  begin
    PripojBtn.Enabled:=True;
    OdpojBtn.Enabled:=False;

    Form1.Z21Panel.Visible:=False;
    Form1.Z21M.Enabled:=False;
    Form1.Z21M.Checked:=False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TZ21Dlg.JePripojene: Boolean;
begin
  Result:=IdUDPClient1.Connected;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.PosliX(const p_header: Word; const p_data: TIdBytes);
var
  outbuf: TIdBytes;
  v_xor: Byte;
  i: Integer;
begin
  if Length(p_data)=0 then Posli(p_header,p_data)
  else
  begin
    SetLength(outbuf,Length(p_data)+1);

    outbuf[0]:=p_data[0];
    v_xor:=p_data[0];

    for i := 1 to Length(p_data)-1 do
    begin
      outbuf[i]:=p_data[i];
      v_xor:=v_xor xor p_data[i];
    end;

    outbuf[High(outbuf)]:=v_xor;
    Posli(p_header,outbuf);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Posli(const p_header: Word);
var
  data: TIdBytes;
begin
  SetLength(data,0);
  Posli(p_header,data);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Posli(const p_header: Word; const p_data: TIdBytes);
var
  outbuf: TIdBytes;
  dlzka: Word;
  i: Integer;
begin
  SetLength(outbuf,Length(p_data)+4);
  dlzka:=Length(p_data)+4;

  outbuf[0]:=dlzka mod 256;
  outbuf[1]:=dlzka div 256;
  outbuf[2]:=p_header mod 256;
  outbuf[3]:=p_header div 256;

  for i := 0 to Length(p_data)-1 do
  begin
    outbuf[i+4]:=p_data[i];
  end;

  if IdUDPClient1.Connected then
  begin
    IdUDPClient1.SendBuffer(outbuf);
    t_cas_komunikacie:=0;
  end
  else Memo1.Lines.Add('Nepripojene');
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.GetSN;
begin
  Posli($0010);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.GetFWV;
var
  data: TIdBytes;
begin
  SetLength(data,2);
  data[0]:=$F1;
  data[1]:=$0A;

  PosliX($0040,data);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SetBFlags;
var
  data: TIdBytes;
begin
  SetLength(data,4);
  data[0]:=$01;
  data[1]:=$01;
  data[2]:=$00;
  data[3]:=$00;

  Posli($0050,data);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SetLogout;
begin
  Posli($0030);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.ZrusSkrat;
var
  data: TIdBytes;
begin
  SetLength(data,2);
  data[0]:=$21;
  data[1]:=$81;

  PosliX($0040,data);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Stop;
var
  data: TidBytes;
begin
  SetLength(data,1);
  data[0]:=$80;

  PosliX($0040,data);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Timer1Timer(Sender: TObject);
var
  data: TIdBytes;
  pocet: Integer;
begin
  Timer1.Enabled:=False;
  try
    if IdUDPClient1.Connected then
    begin
      SetLength(data,1024);

      try
        pocet:=IdUDPClient1.ReceiveBuffer(data,100);
        SetLength(data,pocet);
      except

      end;

      if Length(data)>0 then SpracujData(data);
    end
    else Memo1.Lines.Add('Nepripojené');

    Inc(t_cas_komunikacie);

    if t_cas_komunikacie>300 then
    begin
      GetSN;
      t_cas_komunikacie:=0;
    end;
  finally
    Timer1.Enabled:=True;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.PripojBtnClick(Sender: TObject);
begin
  Pripoj;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.OdpojBtnClick(Sender: TObject);
begin
  Odpoj(False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Button2Click(Sender: TObject);
begin
  Posli($0051);
end;

procedure TZ21Dlg.Button3Click(Sender: TObject);
begin
  ZrusSkrat;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.FWVBtnClick(Sender: TObject);
begin
  GetFWV;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.Button4Click(Sender: TObject);
begin
  GetSN;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.StopBtnClick(Sender: TObject);
begin
  Stop;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.FormCreate(Sender: TObject);
begin
  t_cas_komunikacie:=0;
  t_vyrobne_cislo:=0;
  t_verzia:='';

  t_stav:='';
  t_prud_vstupny:='';
  t_prud_spatny:='';
  t_prud_prog_kolaj:='';
  t_napatie_vstupne:='';
  t_napatie_vnutorne:='';
  t_teplota_vnutorna:='';
  t_vystraha:='';

end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.FormDestroy(Sender: TObject);
begin
  Odpoj(True);
end;

////////////////////////////////////////////////////////////////////////////////

function TZ21Dlg.VypisData(const p_data: TIdBytes): string;
var
  i: Integer;
begin
  Result:='';

  for i := 0 to Length(p_data)-1 do
  begin
    if i<>0 then Result:=Result+',';
    Result:=Result+IntToHex(p_data[i]);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu0010(p_data: TIdBytes);
begin
  t_vyrobne_cislo:=(p_data[3] shl 24)+(p_data[2] shl 16)+(p_data[1] shl 8)+(p_data[0]);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu0040F3(p_data: TIdBytes);
begin
  if(p_data[0]=$0A) and (Length(p_data)>=3) then  t_verzia:=IntToHex(p_data[1])+'.'+IntToHex(p_data[2]);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu004061(p_data: TIdBytes);
begin
  if(p_data[0]=$00) then t_stav:='Odpojené napájanie'
  else if(p_data[1]=$01) then t_stav:='V prevádzke'
  else if(p_data[1]=$02) then t_stav:='Programovanie'
  else if(p_data[1]=$08) then t_stav:='!!! SKRAT !!!'
  else if(p_data[1]=$82) then Memo1.Lines.Add('X správa - zlý príkaz');

  AppIdle;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu004081(p_data: TIdBytes);
begin
  if(p_data[0]=$00) then t_stav:='!!! NÚDZOVÝ STOP !!!';

  AppIdle;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu0040(p_data: TIdBytes);
var
  v_xor: Byte;
  i: Integer;
  xdata: TIdBytes;
begin
  if(Length(p_data)>=2) then
  begin
    v_xor:=p_data[0];
    for i := 1 to Length(p_data)-2 do v_xor:=v_xor xor p_data[i];

    SetLength(xdata,Length(p_data)-2);
    for i := 1 to Length(p_data)-2 do xdata[i-1]:=p_data[i];

    if(v_xor=p_data[High(p_data)]) then
    begin
      case p_data[0] of
        $F3: SpracujSpravu0040F3(xdata);
        $61: SpracujSpravu004061(xdata);
        $81: SpracujSpravu004081(xdata);
        else Memo1.Lines.Add('opkod: 0040 Xkod: '+IntToStr(p_data[0])+' data: '+VypisData(p_data));
      end;
    end
    else Memo1.Lines.Add('X sprava so zlym XOR: '+VypisData(p_data));
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu0084(p_data: TIdBytes);
begin
  t_prud_vstupny:=FloatToStrF((p_data[1]*256+p_data[0])/1000,ffGeneral,3,5)+' A';
  t_prud_prog_kolaj:=FloatToStrF((p_data[3]*256+p_data[2])/1000,ffGeneral,3,5)+' A';
  t_prud_spatny:=FloatToStrF((p_data[5]*256+p_data[4])/1000,ffGeneral,3,5)+' A';
  t_teplota_vnutorna:=IntToStr(p_data[7]*256+p_data[6])+' °C';
  t_napatie_vstupne:=FloatToStrF((p_data[9]*256+p_data[8])/1000,ffGeneral,3,5)+' V';
  t_napatie_vnutorne:=FloatToStrF((p_data[11]*256+p_data[10])/1000,ffGeneral,3,5)+' V';

  if(p_data[12] and $04)>0 then      t_stav:='!!! SKRAT !!!'
  else if(p_data[12] and $01)>0 then t_stav:='!!! NÚDZOVÝ STOP !!!'
  else if(p_data[12] and $02)>0 then t_stav:='Odpojené napájanie'
  else if(p_data[12] and $20)>0 then t_stav:='Programovanie'
  else t_stav:='V prevádzke';

  if(p_data[13] and $08)>0 then      t_vystraha:='Zistený skrat v Z21'
  else if(p_data[13] and $04)>0 then t_vystraha:='Zistený skrat v boosteri'
  else if(p_data[13] and $02)>0 then t_vystraha:='Malé vstupné napätie'
  else if(p_data[13] and $01)>0 then t_vystraha:='Centrála sa prehrieva'
  else t_vystraha:='';
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujSpravu(const p_opkod: Word; const p_data: TIdBytes);
begin
  case p_opkod of
    $0010: SpracujSpravu0010(p_data);
    $0040: SpracujSpravu0040(p_data);
    $0084: SpracujSpravu0084(p_data);
    else Memo1.Lines.Add('opkod: '+IntToHex(p_opkod)+' data: '+VypisData(p_data));
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujDatagram(const p_dlzka: Word; const p_data: TIdBytes);
var
  i: Integer;
  opcode: Word;
  r_dlzka: Integer;
  inbuf: TIdBytes;
begin
  r_dlzka:=Length(p_data);

  if(r_dlzka>=2) then
  begin
    if(Length(p_data)=p_dlzka) then
    begin
      opcode:=p_data[1]*256+p_data[0];

      SetLength(inbuf,Length(p_data)-2);

      for i := 2 to Length(p_data)-1 do inbuf[i-2]:=p_data[i];

      SpracujSpravu(opcode,inbuf);
    end
    else Memo1.Lines.Add('Sprava s nespravnou dlzkou: '+VypisData(p_data));
  end
  else Memo1.Lines.Add('Sprava kratsia nez 4B'+VypisData(p_data));
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.SpracujData(const p_data: TIdBytes);
var
  i,j: Integer;
  r_dlzka,d_dlzka: Integer;
  inbuf: TIdBytes;
  je_datagram: Boolean;
begin
  r_dlzka:=Length(p_data);
  d_dlzka:=0;

  if(r_dlzka>=2) then
  begin
    je_datagram:=False;
    i:=0;

    while(i<r_dlzka) do
    begin
      if not je_datagram then
      begin
        d_dlzka:=p_data[i+1]*256+p_data[i];
        je_datagram:=true;
        i:=i+2;
      end
      else
      begin
        SetLength(inbuf,d_dlzka-2);

        if(i+d_dlzka-2)<=r_dlzka then
        begin
          for j := 0 to d_dlzka-3 do inbuf[j]:=p_data[i+j];
          SpracujDatagram(d_dlzka-2,inbuf);
          je_datagram:=False;
          i:=i+d_dlzka-2;
        end
        else
        begin
          Memo1.Lines.Add('Sprava s nespravnou dlzkou: '+VypisData(p_data));
          je_datagram:=False;
          break;
        end;
      end;
    end;

    if je_datagram then Memo1.Lines.Add('Sprava s nespravnou dlzkou: '+VypisData(p_data));
  end
  else Memo1.Lines.Add('Sprava kratsia nez 2B'+VypisData(p_data));
end;

////////////////////////////////////////////////////////////////////////////////

procedure TZ21Dlg.AppIdle;
var
  text: string;
begin

  text:='Centrála Z21 ';
  if t_vyrobne_cislo>0 then text:=text+IntToStr(t_vyrobne_cislo)+' ';
  if t_verzia<>'' then text:=text+'(v. '+t_verzia+') ';


  if not IdUDPClient1.Connected then text:=text+'odpojená' else text:=text+'pripojená';
  // text:=text+', povelov vo fronte: '+IntToStr(Cport.DajPocetPovelov);

  if IdUDPClient1.Connected then
  begin
    Form1.VZ21.Caption:=text;

    Form1.Z21Stav.Caption:=t_stav;
    FOrm1.Z21Vystraha.Caption:=t_vystraha;
    Form1.Z21ProudVstup.Caption:='Vstupný prúd: '+t_prud_vstupny;
    Form1.Z21ProgramKolejProud.Caption:='Programovacia koľaj: '+t_prud_prog_kolaj;
    Form1.Z21ProudZpetny.Caption:='Spätný prúd: '+t_prud_spatny;
    Form1.Z21TeplotaVnitrni.Caption:='Vnútorná teplota: '+t_teplota_vnutorna;
    Form1.Z21NapetiVnejsi.Caption:='Napájacie napätie: '+t_napatie_vstupne;
    Form1.Z21NapetiVnitrni.Caption:='Napätie v koľajniciach: '+t_napatie_vnutorne;

    if (t_stav='!!! SKRAT !!!') or (t_stav='!!! NÚDZOVÝ STOP !!!') or (t_stav='Odpojené napájanie') then
    begin
      if not Form1.ZrusStopBtn.Visible then Form1.ZrusStopBtn.Visible:=True;
      if Form1.StopBtn.Visible then Form1.StopBtn.Visible:=False;
    end
    else
    begin
      if Form1.ZrusStopBtn.Visible then Form1.ZrusStopBtn.Visible:=False;

      if (t_stav='V prevádzke') then
      begin
        if not Form1.StopBtn.Visible then Form1.StopBtn.Visible:=True;
      end
      else
      begin
        if Form1.StopBtn.Visible then Form1.StopBtn.Visible:=False;
      end;
    end;
  end;
end;


end.
