unit CPortThread;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Generics.Collections,
  synaser;

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
      Adresa: Word;
      Smer: Boolean;

      constructor Create(p_adresa: Word; p_smer: Boolean);
  end;

  //**************************************************************************//

  TCPortZpravaB2=class(TCPortZprava)
    public
      Adresa: Word;
      Stav: Boolean;

      constructor Create(p_adresa: Word; p_stav: Boolean);
  end;

  //**************************************************************************//

  TCPortZpravaBCB4=class(TCPortZprava)
    public
      Adresa: Word;
      Ack: Boolean;

      constructor Create(p_adresa: Word; p_ack: Boolean);
  end;

  //**************************************************************************//

  TCPortZpravaBFB4=class(TCPortZprava)
    public
      Adresa: Word;
      Stav: Boolean;

      constructor Create(p_adresa: Word; p_stav: Boolean);
  end;

  //**************************************************************************//

  TCPortZpravaBAB4=class(TCPortZprava)
    public
      Slot: Byte;

      constructor Create(p_slot: Byte);
  end;

  //**************************************************************************//

  TCPortZpravaEFB4Odpoved=(EFB4_NOT_IMPLEMENTED,EFB4_BUSY,EFB4_ACCEPTED,EFB4_ACCEPTED_NO_REPLY);

  TCPortZpravaEFB4=class(TCPortZprava)
    public
      Slot: Byte;
      Odpoved: TCPortZpravaEFB4Odpoved;

      constructor Create(p_slot: Byte; p_odpoved: TCPortZpravaEFB4Odpoved);
  end;

  //**************************************************************************//

  TCPortZpravaE7Slot=class(TCPortZprava)
    public
      Slot: Byte;
      Adresa: Word;

      Stat: Byte;
      Rychlost: Byte;
      Dirf: Byte;
      Trk: Byte;
      SS2: Byte;
      Snd: Byte;
      ID: Word;

      constructor Create(p_slot: Byte; p_adresa: Word; p_stat: Byte; p_rychlost: Byte; p_dirf: Byte; p_trk: Byte; p_ss2: Byte; p_snd: Byte; p_id: Word);
  end;

  const E7SL_RYCHLOST_STOP=$00;
  const E7SL_RYCHLOST_NUDZ_STOP=$01;
  const E7SL_SLOT_DISPATCH = $00;
  const E7SL_SLOT_PROGRAM = $7C;
  const E7SL_SLOT_CLOCK = $7B;
  const E7SL_SLOT_NEPOUZITY = $80;


  //**************************************************************************//

  type TCPortZpravaE7Program=class(TCPortZprava)
    public
      PCMD: Byte;
      PStat: Byte;
      POMAdresa: Word;
      TRK: Byte;
      CV: Word;
      Data: Byte;

      constructor Create(p_cmd: Byte; p_stat: Byte; p_pom_adresa: Word; p_trk: Byte; p_cv: Word; p_data: Byte);
  end;

  //**************************************************************************//

  type TCPortZpravaEFCas=class(TCPortZprava)
      public
        Rate: Byte;
        FRAC: Word;
        Mins: Byte;
        TRK: Byte;
        Hours: Byte;
        Days: Byte;
        Valid: Boolean;
        ID:Word;

        constructor Create(p_rate: Byte; p_frac: Word; p_mins: Byte; p_trk: Byte; p_hours: Byte; p_days: Byte; p_valid: Boolean; p_id: Word);
  end;

  //**************************************************************************//

  TCPortDohladVyhybky=record
    DohladPlus: Integer;
    DohladMinus: Integer;
  end;

  //**************************************************************************//

  TCPortThread = class(TThread)
  private
    t_opkod: Byte;
    t_pocbajtov: Byte;
    t_sprava: TBytes;
    t_akt_bajt: Integer;

    t_posl_ziadost_adresa: Word;
    t_posl_loko_adresa: Word;
    t_posl_presuvany_slot_zdroj: Byte;
    t_posl_presuvany_slot_ciel: Byte;
    t_posl_citany_slot: Byte;
    t_posl_zapisovy_slot: Byte;

    t_portcislo: string;
    t_rychlost: Cardinal;
    t_hwflow: Boolean;
    t_simulacia: Boolean;

    t_port: TBlockSerial;

    t_simbuffer: TBytes;

    t_povely: TQueue<TByteDynPoleW>;
    //t_simulacia_dohladov: TDictionary<Integer,TCPortDohladVyhybky>;

    t_vlakno_vstup: TCriticalSection;
    t_vlakno_vystup: TCriticalSection;
    t_vlakno_system: TCriticalSection;

    t_vystup: TList<TCPortZprava>;
    t_vystup_debug: TList<string>;

    procedure Pripoj;

    procedure SpracujSpravuB0;
    procedure SpracujSpravuB2;
    procedure SpracujSpravuB4;
    procedure SpracujSpravuBC;

    procedure SpracujSpravuBF;
    procedure SpracujSpravuBB;
    procedure SpracujSpravuBA;
    procedure SpracujSpravuE7;
    procedure SpracujSpravuEF;

    procedure SpracujSpravu;
    procedure PreverOdpoved;
    procedure DiscardniSpravu(p_vypis: Boolean);

    procedure PridajBajt(p_bajt: Byte);

    procedure NasimulujB4(p_povel: TByteDynPoleW);
    procedure NasimulujB2(p_povel: TByteDynPoleW);
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

    function DajVystup(p_list: TList<TCPortZprava>; p_vystup_debug: TList<string>): Boolean;

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

constructor TCPortZpravaB0.Create(p_adresa: Word; p_smer: Boolean);
begin
  Adresa:=p_adresa;
  Smer:=p_smer;
end;

//****************************************************************************//

constructor TCPortZpravaB2.Create(p_adresa: Word; p_stav: Boolean);
begin
  Adresa:=p_adresa;
  Stav:=p_stav;
end;

//****************************************************************************//

constructor TCPortZpravaBCB4.Create(p_adresa: Word; p_ack: Boolean);
begin
  Adresa:=p_adresa;
  Ack:=p_ack;
end;

//****************************************************************************//

constructor TCPortZpravaBFB4.Create(p_adresa: Word; p_stav: Boolean);
begin
  Adresa:=p_adresa;
  Stav:=p_stav;
end;

//****************************************************************************//

constructor TCPortZpravaBAB4.Create(p_slot: Byte);
begin
  Slot:=p_slot;
end;

//****************************************************************************//

constructor TCPortZpravaEFB4.Create(p_slot: Byte; p_odpoved: TCPortZpravaEFB4Odpoved);
begin
  Slot:=p_slot;
  Odpoved:=p_odpoved;
end;

//****************************************************************************//

constructor TCPortZpravaE7Slot.Create(p_slot: Byte; p_adresa: Word; p_stat: Byte; p_rychlost: Byte; p_dirf: Byte; p_trk: Byte; p_ss2: Byte; p_snd: Byte; p_id: Word);
begin
  Slot:=p_slot;
  Adresa:=p_adresa;
  Stat:=p_stat;
  Rychlost:=p_rychlost;
  Dirf:=p_dirf;
  Trk:=p_trk;
  SS2:=p_ss2;
  Snd:=p_snd;
  ID:=p_id;
end;

//****************************************************************************//

constructor TCPortZpravaE7Program.Create(p_cmd: Byte; p_stat: Byte; p_pom_adresa: Word; p_trk: Byte; p_cv: Word; p_data: Byte);
begin
  PCMD:=p_cmd;
  PStat:=p_stat;
  POMAdresa:=p_pom_adresa;
  TRK:=p_trk;
  CV:=p_cv;
  Data:=p_data;
end;

//****************************************************************************//

constructor TCPortZpravaEFCas.Create(p_rate: Byte; p_frac: Word; p_mins: Byte; p_trk: Byte; p_hours: Byte; p_days: Byte; p_valid: Boolean; p_id: Word);
begin
  Rate:=p_rate;
  FRAC:=p_frac;
  Mins:=p_mins;
  Hours:=p_hours;
  TRK:=p_trk;
  Days:=p_days;
  Valid:=p_valid;
  ID:=p_id;
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
  t_posl_loko_adresa:=0;
  t_posl_presuvany_slot_zdroj:=E7SL_SLOT_NEPOUZITY;
  t_posl_presuvany_slot_ciel:=E7SL_SLOT_NEPOUZITY;
  t_posl_citany_slot:=E7SL_SLOT_NEPOUZITY;
  t_posl_zapisovy_slot:=E7SL_SLOT_NEPOUZITY;

  t_portcislo:='COM5';
  t_rychlost:=115200;
  t_hwflow:=False;
  t_simulacia:=False;

  t_povely:=TQueue<TByteDynPoleW>.Create;
  t_port:=TBlockSerial.Create;
  t_vystup:=TList<TCPortZprava>.Create;
  t_vystup_debug:=TList<string>.Create;

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
  t_vystup_debug.Free;

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

//nerobi ziadny Sync, musi volajuca funkcia
procedure TCPortThread.NasimulujB2(p_povel: TByteDynPoleW);
var
  v_pole: array[0..3] of Byte;
begin
  v_pole[0]:=$B2;
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

    if p_povel.Pole[0]=$BC then NasimulujB4(p_povel)
    else if p_povel.Pole[0]=$B0 then NasimulujB2(p_povel);
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

function TCPortThread.DajVystup(p_list: TList<TCPortZprava>; p_vystup_debug: TList<string>): Boolean;
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

    if t_vystup_debug.Count>0 then
    begin
      if(t_opkod=0) then
      begin
        p_vystup_debug.AddRange(t_vystup_debug);
        t_vystup_debug.Clear;
      end
      else
      begin
        while(t_vystup_debug.Count>1) do
        begin
          p_vystup_debug.Add(t_vystup_debug.First);
          t_vystup_debug.Delete(0);
        end;
      end;

      Result:=True;
    end;
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

////////////////////////////////////////////////////////////////////////////////

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

procedure TCPortThread.SpracujSpravuB2;
var
  adresa: Cardinal;
  smer: Boolean;
  test,stav: Boolean;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  adresa:=t_sprava[0]+((t_sprava[1] and $0F) shl 7);
  smer:=(t_sprava[1] and $20)<>0;
  stav:=(t_sprava[1] and $10)<>0;
  //test:=(t_sprava[1] and $30)<>0;

  //konverzia z formatu loconet na format digitrax
  adresa:=(adresa shl 1);
  if smer then adresa:=adresa+1;
  adresa:=adresa+1;

  t_vlakno_vstup.Acquire;
  try
    t_vystup.Add(TCPortZpravaB2.Create(adresa,stav));
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
      t_vystup.Add(TCPortZpravaBCB4.Create(t_posl_ziadost_adresa,ack<>$50));
    finally
      t_vlakno_vstup.Release;
    end;

    t_posl_ziadost_adresa:=0;
  end
  else if(ack_opkod=$BF) and (t_posl_loko_adresa>0) then
  begin
    t_vlakno_vstup.Acquire;
    try
      t_vystup.Add(TCPortZpravaBFB4.Create(t_posl_loko_adresa,ack<>$00));
    finally
      t_vlakno_vstup.Release;
    end;

    t_posl_loko_adresa:=0;
  end
  else if(ack_opkod=$BA) and (t_posl_presuvany_slot_zdroj>0) then
  begin
    t_vlakno_vstup.Acquire;
    try
      t_vystup.Add(TCPortZpravaBAB4.Create(t_posl_presuvany_slot_zdroj));
    finally
      t_vlakno_vstup.Release;
    end;

    t_posl_presuvany_slot_zdroj:=E7SL_SLOT_NEPOUZITY;
    t_posl_presuvany_slot_ciel:=E7SL_SLOT_NEPOUZITY;
  end
  else if(ack_opkod=$EF) and (t_posl_zapisovy_slot=E7SL_SLOT_PROGRAM) then
  begin
    var v_odpoved: TCPortZpravaEFB4Odpoved;
    if ack=$7F then v_odpoved:=EFB4_NOT_IMPLEMENTED
    else if ack=$01 then v_odpoved:=EFB4_ACCEPTED
    else if ack=$40 then v_odpoved:=EFB4_ACCEPTED_NO_REPLY
    else v_odpoved:=EFB4_BUSY;

    t_vlakno_vstup.Acquire;
    try
      t_vystup.Add(TCPortZpravaEFB4.Create(t_posl_zapisovy_slot,v_odpoved));
    finally
      t_vlakno_vstup.Release;
    end;

    t_posl_zapisovy_slot:=E7SL_SLOT_NEPOUZITY;
  end
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuBF;
var
  adresa: Cardinal;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  adresa:=(t_sprava[0] shl 7)+t_sprava[1];

  t_posl_loko_adresa:=adresa;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuBB;
var
  slot: Byte;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  slot:=t_sprava[0];

  t_posl_citany_slot:=slot;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuBA;
var
  slot_zdroj,slot_ciel: Cardinal;
begin
  assert(Length(t_sprava)=3,'Prijata sprava s nespravnou dlzkou');
  assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2])=$FF,'Prijata sprava s nespravnym CRC');
  slot_zdroj:=t_sprava[0];
  slot_ciel:=t_sprava[1];

  t_posl_presuvany_slot_zdroj:=slot_zdroj;
  t_posl_presuvany_slot_ciel:=slot_ciel;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuE7;
var
  slot: Byte;
begin
  if(Length(t_sprava)=13) and (t_sprava[0]=14) then
  begin
    assert(Length(t_sprava)=13,'Prijata sprava s nespravnou dlzkou');
    assert(t_sprava[0]=14,'Nespravne oznacenie dlzky spravy E7');
    assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2] xor t_sprava[3] xor t_sprava[4] xor t_sprava[5] xor t_sprava[6] xor t_sprava[7] xor t_sprava[8] xor t_sprava[9] xor t_sprava[10] xor t_sprava[11] xor t_sprava[12])=$FF,'Prijata sprava s nespravnym CRC');

    slot:=t_sprava[1];

    if(slot=E7SL_SLOT_PROGRAM) then
    begin
      var v_cmd: Byte:=t_sprava[2];
      var v_stat: Byte:=t_sprava[3];
      var v_pom_adresa: Word:=(t_sprava[4] shl 7)+t_sprava[5];
      var v_trk: Byte:=t_sprava[6];
      var v_cv: Word:=(((t_sprava[7] shr 4) and $03) shl 7)+((t_sprava[7] and $01) shl 7)+t_sprava[8];
      var v_data: Byte:=(((t_sprava[7] shr 1) and $01) shl 7)+t_sprava[9];
      
    
      t_vlakno_vstup.Acquire;
      try
        t_vystup.Add(TCPortZpravaE7Program.Create(v_cmd,v_stat,v_pom_adresa,v_trk,v_cv,v_data));
      finally
        t_vlakno_vstup.Release;
      end;    

      if t_posl_citany_slot=E7SL_SLOT_PROGRAM then t_posl_citany_slot:=E7SL_SLOT_NEPOUZITY;
      if t_posl_zapisovy_slot=E7SL_SLOT_PROGRAM then t_posl_zapisovy_slot:=E7SL_SLOT_NEPOUZITY;
    end
    else
    begin
      var v_adresa:=(t_sprava[8] shl 7)+t_sprava[3];
      var v_stat: Byte:=t_sprava[2];
      var v_rychlost: Byte:=t_sprava[4];
      var v_dirf: Byte:=t_sprava[5];
      var v_trk: Byte:=t_sprava[6];
      var v_ss2: Byte:=t_sprava[7];
      var v_snd: Byte:=t_sprava[9];
      var v_id: Word:=(t_sprava[10] shl 7)+t_sprava[11];
      
    
      t_vlakno_vstup.Acquire;
      try
        t_vystup.Add(TCPortZpravaE7Slot.Create(slot,v_adresa,v_stat,v_rychlost,v_dirf,v_trk,v_ss2,v_snd,v_id));
      finally
        t_vlakno_vstup.Release;
      end;    
    
      if t_posl_loko_adresa=v_adresa then t_posl_loko_adresa:=0;
    
      if t_posl_presuvany_slot_ciel=slot then
      begin
        t_posl_presuvany_slot_zdroj:=E7SL_SLOT_NEPOUZITY;
        t_posl_presuvany_slot_ciel:=E7SL_SLOT_NEPOUZITY;
      end;

      if t_posl_citany_slot=slot then t_posl_citany_slot:=E7SL_SLOT_NEPOUZITY;      
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravuEF;
var
  slot: Byte;
begin
    if(Length(t_sprava)=13) and (t_sprava[0]=14) then
  begin
    assert(Length(t_sprava)=13,'Prijata sprava s nespravnou dlzkou');
    assert(t_sprava[0]=14,'Nespravne oznacenie dlzky spravy EF');
    assert((t_opkod xor t_sprava[0] xor t_sprava[1] xor t_sprava[2] xor t_sprava[3] xor t_sprava[4] xor t_sprava[5] xor t_sprava[6] xor t_sprava[7] xor t_sprava[8] xor t_sprava[9] xor t_sprava[10] xor t_sprava[11] xor t_sprava[12])=$FF,'Prijata sprava s nespravnym CRC');

    slot:=t_sprava[1];

    if(slot=E7SL_SLOT_PROGRAM) then
    begin
      t_posl_zapisovy_slot:=E7SL_SLOT_PROGRAM;
    end
    else if (slot=E7SL_SLOT_CLOCK) then
    begin
      var v_rate: Byte:=t_sprava[2];
      var v_frac:=t_sprava[3]+(t_sprava[4] shl 7);
      var v_mins:=(256-t_sprava[5]) mod 60;
      var v_trk:=t_sprava[6];
      var v_hours:=(256-t_sprava[7]) mod 24;
      var v_days:=t_sprava[8];
      var v_valid: Boolean:=t_sprava[9]<>0;
      var v_id:=(t_sprava[10] shl 7)+t_sprava[11];
    
      t_vlakno_vstup.Acquire;
      try
        t_vystup.Add(TCPortZpravaEFCas.Create(v_rate,v_frac,v_mins,v_trk,v_hours,v_days,v_valid,v_id));
      finally
        t_vlakno_vstup.Release;
      end;    
    end         
    else
    begin      
      t_posl_zapisovy_slot:=slot;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCPortThread.SpracujSpravu;
begin
  try
    case t_opkod of
      $B0: SpracujSpravuB0;
      $B2: SpracujSpravuB2;
      $B4: SpracujSpravuB4;
      $BC: SpracujSpravuBC;
      $BF: SpracujSpravuBF;
      $BB: SpracujSpravuBB;
      $BA: SpracujSpravuBA;
      $E7: SpracujSpravuE7;
      $EF: SpracujSpravuEF;

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

    t_vlakno_vstup.Acquire;
    try
      t_vystup_debug.Add(IntToHex(p_bajt));
    finally
      t_vlakno_vstup.Release;
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
      t_vlakno_vstup.Acquire;
      try
        t_vystup_debug[t_vystup_debug.Count-1]:=t_vystup_debug.Last+','+IntToHex(p_bajt);
      finally
        t_vlakno_vstup.Release;
      end;


      if (t_pocbajtov=0) and (p_bajt>0) then //nacitanie poctu bajtov
      begin
        t_pocbajtov:=p_bajt-1;
        SetLength(t_sprava,t_pocbajtov);
        assert(t_akt_bajt=0);
        t_sprava[t_akt_bajt]:=p_bajt;
        Inc(t_akt_bajt);
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
