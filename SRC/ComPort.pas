unit ComPort;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.ExtCtrls, SyncObjs, CPortThread;

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
    procedure VydajPovelB0(p_adresa: Integer; p_nahodeny: Boolean);
    procedure VydajPovelBC(p_adresa: Integer);
    procedure NastavPort(p_port: INteger);

    procedure Pripoj;
  end;

var
  CPort: TCPort;

implementation
  uses DiagDialog, Types, MMSystem, LogikaStavadlo, Forms, Generics.Collections;

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
              else if vsprava is TCPortZpravaBCB4 then LogikaES.SpracujSpravuBCB4((vsprava as TCPortZpravaBCB4).Adresa,(vsprava as TCPortZpravaBCB4).Ack);
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
begin
  if t_vlakno<>nil then t_vlakno.PridajPovel(p_povel);
end;

end.
