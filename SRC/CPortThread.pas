unit CPortThread;

interface

uses
  System.Classes, SyncObjs, Generics.Collections, System.SysUtils, synaser;

type
  TByteDynPoleW=class(TObject)
    public
      Pole: TBytes;
      constructor Create(p_pole: TBytes);
  end;

  //**************************************************************************//

  TCPortZprava=class(TObject)

  end;

  //**************************************************************************//

  TCPortZpravaB0=class(TCPortZprava)
    public
      Adresa: Integer;
      Smer: Boolean;

      constructor Create(p_adresa: Integer; p_smer: Boolean);
  end;

  //**************************************************************************//

  TCPortZpravaBCB4=class(TCPortZprava)
    public
      Adresa: Integer;
      Ack: Boolean;

      constructor Create(p_adresa: Integer; p_ack: Boolean);
  end;

  //**************************************************************************//

  TCPortThread = class(TThread)
  private
    t_opkod: Byte;
    t_pocbajtov: Byte;
    t_sprava: TBytes;
    t_akt_bajt: Integer;
    t_posl_ziadost_adresa: Integer;

    t_portcislo: string;
    t_rychlost: Cardinal;
    t_hwflow: Boolean;
    t_simulacia: Boolean;

    t_port: TBlockSerial;

    t_simbuffer: TBytes;

    t_povely: TQueue<TByteDynPoleW>;

    t_vlakno_vstup: TCriticalSection;
    t_vlakno_vystup: TCriticalSection;
    t_vlakno_system: TCriticalSection;

    t_vystup: TList<TCPortZprava>;

    procedure Pripoj;

    procedure SpracujSpravuB0;
    procedure SpracujSpravuB4;
    procedure SpracujSpravuBC;

    procedure SpracujSpravu;
    procedure PreverOdpoved;
    procedure DiscardniSpravu(p_vypis: Boolean);

    procedure PridajBajt(p_bajt: Byte);

    procedure NasimulujB4(p_povel: TByteDynPoleW);
    procedure ZapisPovel(p_povel: TByteDynPoleW);
  protected
    procedure Execute; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Nastav(p_port: string; p_rychlost: Cardinal; p_hwflow, p_simulacia: Boolean);
    procedure NastavPort(p_port: Integer);

    function DajPocetPovelov: Integer;
    procedure PridajPovel(p_povel: TBytes);

    function DajVystup(p_list: TList<TCPortZprava>): Boolean;

    procedure CakajNaPripojenie;
  end;

implementation

constructor TByteDynPoleW.Create(p_pole: TBytes);
var
  i: Integer;
begin
  SetLength(Pole,Length(p_pole));
  for i := Low(p_pole) to High(p_pole) do pole[i]:=p_pole[i];
end;

//****************************************************************************//

constructor TCPortZpravaB0.Create(p_adresa: Integer; p_smer: Boolean);
begin
  Adresa:=p_adresa;
  Smer:=p_smer;
end;

//****************************************************************************//

constructor TCPortZpravaBCB4.Create(p_adresa: Integer; p_ack: Boolean);
begin
  Adresa:=p_adresa;
  Ack:=p_ack;
end;

//****************************************************************************//

{ TCPortThread }

constructor TCPortThread.Create;
begin
  inherited Create(True);

  t_vlakno_vstup:=TCriticalSection.Create;
  t_vlakno_vystup:=TCriticalSection.Create;
  t_vlakno_system:=TCriticalSection.Create;

  t_opkod:=0;
  SetLength(t_sprava,0);
  t_akt_bajt:=0;
  t_posl_ziadost_adresa:=0;

  t_portcislo:='COM5';
  t_rychlost:=115200;
  t_hwflow:=False;
  t_simulacia:=False;

  t_povely:=TQueue<TByteDynPoleW>.Create;
  t_port:=TBlockSerial.Create;
  t_vystup:=TList<TCPortZprava>.Create;

  SetLength(t_simbuffer,0);
end;

////////////////////////////////////////////////////////////////////////////////

destructor TCPortThread.Destroy;
begin
  Terminate;
  WaitFor;

  t_povely.Free;
  t_port.Free;
  t_vystup.Free;

  t_vlakno_vstup.Free;
  t_vlakno_vystup.Free;
  t_vlakno_system.Free;

  inherited;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.Nastav(p_port: string; p_rychlost: Cardinal; p_hwflow: Boolean; p_simulacia: Boolean);
begin
  t_vlakno_system.Acquire;
  try
    t_portcislo:=p_port;
    t_rychlost:=p_rychlost;
    t_hwflow:=p_hwflow;
    t_simulacia:=p_simulacia;
  finally
    t_vlakno_system.Release;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.NastavPort(p_port: INteger);
begin
  t_vlakno_system.Acquire;
  try
    t_portcislo:='COM'+IntToStr(p_port);
  finally
    t_vlakno_system.Release;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.Pripoj;
begin
  if not t_simulacia then
  begin
    t_vlakno_system.Acquire;
    try
      t_vlakno_vystup.Acquire;
      try
        t_port.Connect(t_portcislo);
        sleep(1000);
        t_port.Config(t_rychlost, 8, 'N', SB1, False, t_hwflow);
        sleep(500);
      finally
        t_vlakno_vystup.Release;
      end;
    finally
      t_vlakno_system.Release;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TCPortThread.DajPocetPovelov: Integer;
begin
  if not Terminated then
  begin
    t_vlakno_vystup.Acquire;
    try
      Result:=t_povely.Count;
    finally
      t_vlakno_vystup.Release;
    end;
  end
  else Result:=-1;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.PridajPovel(p_povel: TBytes);
var
  povel: TBytes;
  i: Integer;
begin
  if not Terminated then
  begin
    t_vlakno_vystup.Acquire;
    try
      SetLength(povel,Length(p_povel));
      for i := Low(p_povel) to High(p_povel) do povel[i]:=p_povel[i];

      t_povely.Enqueue(TByteDynpoleW.Create(povel));

      if t_povely.Count=1 then ZapisPovel(t_povely.Peek);
    finally
      t_vlakno_vystup.Release;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

//nerobi ziadny Sync, musi volajuca funkcia
procedure TCPortThread.NasimulujB4(p_povel: TByteDynPoleW);
var
  v_pole: array[0..3] of Byte;
begin
  v_pole[0]:=$B4;
  v_pole[1]:=p_povel.Pole[0] and $7F;
  v_pole[2]:=0;
  v_pole[3]:=$FF xor v_pole[0] xor v_pole[1] xor v_pole[2];

  SetLength(t_simbuffer,Length(t_simbuffer)+4);
  t_simbuffer[Length(t_simbuffer)-4]:=v_pole[0];
  t_simbuffer[Length(t_simbuffer)-3]:=v_pole[1];
  t_simbuffer[Length(t_simbuffer)-2]:=v_pole[2];
  t_simbuffer[Length(t_simbuffer)-1]:=v_pole[3];
end;

////////////////////////////////////////////////////////////////////////////////

//nerobi Sync na VlaknoVystup, musi urobit volajuca funkcia
procedure TCPortThread.ZapisPovel(p_povel: TByteDynPoleW);
var
  v_out: Integer;
begin
  if not t_simulacia then
  begin
    while not t_port.CanWrite(50) do;
    v_out:=0;

    while v_out<Length(p_povel.Pole) do
    begin
      v_out:=v_out+t_port.SendBuffer(@(p_povel.Pole[v_out]),Length(p_povel.Pole)-v_out);
      sleep(50);
    end;
  end
  else
  begin
    SetLength(t_simbuffer,Length(p_povel.Pole));
    t_simbuffer:=Copy(p_povel.Pole,0,Length(p_povel.Pole));

    if(p_povel.Pole[0]=$BC) then NasimulujB4(p_povel);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.Execute;
var
  buf: array[0..64] of Byte;
  output: Integer;
  i: Integer;
  tmp: Byte;
begin
  NameThreadForDebugging('ComPortThread');
  { Place thread code here }
  Pripoj;

  while not Terminated do
  begin
    t_vlakno_system.Acquire;
    try
      try
        if not t_simulacia then
        begin
          t_vlakno_vystup.Acquire;
          try
            output:=t_port.RecvBufferEx(@buf,64,10)
          finally
            t_vlakno_vystup.Release;
          end;
        end
        else
        begin
          t_vlakno_vystup.Acquire;
          try
            for i:=Low(t_simbuffer) to High(t_simbuffer) do
            begin
              tmp:=t_simbuffer[i];
              buf[i]:=tmp;
            end;

            output:=Length(t_simbuffer);
            SetLength(t_simbuffer,0);
          finally
            t_vlakno_vystup.Release;
          end;
        end;

        for i := 0 to output-1 do PridajBajt(buf[i]);
      except
        on e: Exception do DiscardniSpravu(True);
      end;
    finally
      t_vlakno_system.Release;
    end;

    sleep(10);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TCPortThread.DajVystup(p_list: TList<TCPortZprava>): Boolean;
var
  i: Integer;
begin
  t_vlakno_vstup.Acquire;
  try
    if t_vystup.Count>0 then
    begin
      for i := 0 to t_vystup.Count-1 do p_list.Add(t_vystup[i]);
      t_vystup.Clear;
      Result:=True;
    end
    else Result:=False;
  finally
    t_vlakno_vstup.Release;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.PreverOdpoved;
var
  buf: TBytes;
  i: Integer;
begin
  t_vlakno_vystup.Acquire;
  try
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
  finally
    t_vlakno_vystup.Release;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.DiscardniSpravu(p_vypis: Boolean);
begin
  t_opkod:=0;
  SetLength(t_sprava,0);
  t_pocbajtov:=0;
  t_akt_bajt:=0;
end;

procedure TCPortThread.CakajNaPripojenie;
var
  stav: Boolean;
begin
  stav:=False;

  if not t_simulacia then
  begin
    while not stav do
    begin
      t_vlakno_vystup.Acquire;
      try
        stav:=t_port.InstanceActive
      finally
        t_vlakno_vystup.Release;
      end;
    end;
  end;
end;


////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuB0;
var
  adresa: Cardinal;
  smer{,stav}: Boolean;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  adresa:=t_sprava[0]+((t_sprava[1] and $0F) shl 7)+1;
  smer:=(t_sprava[1] and $20)<>0;
  //stav:=(t_sprava[1] and $10)<>0;

  t_vlakno_vstup.Acquire;
  try
    //LogikaES.SpracujSpravuB0(adresa,smer);
    t_vystup.Add(TCPortZpravaB0.Create(adresa,smer));
  finally
    t_vlakno_vstup.Release;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuBC;
var
  adresa: Cardinal;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  adresa:=t_sprava[0]+((t_sprava[1] and $0F) shl 7)+1;

  t_posl_ziadost_adresa:=adresa;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuB4;
var
  ack_opkod: Byte;
  ack: Byte;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  ack_opkod:=t_sprava[0] or $80;
  ack:=t_sprava[1];

  if (ack_opkod=$BC) and (t_posl_ziadost_adresa>0) then
  begin
    t_vlakno_vstup.Acquire;
    try
      //LogikaES.SpracujSpravuBCB4(t_posl_ziadost_adresa,ack<>$50);
      t_vystup.Add(TCPortZpravaBCB4.Create(t_posl_ziadost_adresa,ack<>$50));
    finally
      t_vlakno_vstup.Release;
    end;

    t_posl_ziadost_adresa:=0;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravu;
begin
  try
    case t_opkod of
      $B0: SpracujSpravuB0;
      $B4: SpracujSpravuB4;
      $BC: SpracujSpravuBC;
    end;
  except
    on e: Exception do;
  end;

  PreverOdpoved;
  DiscardniSpravu(False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.PridajBajt(p_bajt: Byte);
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

end.
