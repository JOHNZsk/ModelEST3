unit LogikaStavadlo;

interface

uses
  System.SysUtils, System.Classes, StavadloObjekty, Generics.Collections,
  Graphics, ExtCtrls, Types, Cesta, GR32_Image, GR32;

type
  THitBox=record
    Poloha: TRect;
    Objekt: TStavadloObjekt;
  end;

  function HitBox(p_rect: TRect; p_objekt: TStavadloObjekt): THitBox;

//****************************************************************************//

type TPorucha=record
  Cas: TDateTime;
  Dopravna: TDopravna;
  Text: string;
end;

function Porucha(p_cas: TDateTime; p_dopravna: TDopravna; p_text: string): TPorucha;

//****************************************************************************//

type TNudzovyPovelTyp=(NPT_STAV,NPT_RESETNAV,NPT_RESETVYH,NPT_RESETNAVGLOBAL,NPT_RESETVYHGLOBAL,NPT_PRIVOLAVACKA,NPT_ZAV2,NPT_DOH1,NPT_DOH2,NPT_APN1,NPT_APN2,NPT_ZRUSVYLUKU,NPT_ZRUSSTITOK,NPT_KPV,NPT_KSV,NPT_RESETNAVDOP,NPT_RESETVYHDOP);

function NudzovyPovelTypText(p_hodnota: TNudzovyPovelTyp): string;

//****************************************************************************//

type TNudzovyPovelPotvrdTyp=(NPP_ENTER,NPP_ASDF);

//****************************************************************************//

type TMenuPolozka=(MK_STAV,MK_STOJ,MK_DN,MK_PN,MK_ZAM1,MK_ZAM2,MK_P1,MK_P2,MK_ZAV1,MK_ZAV2,MK_DOH1,MK_DOH2,MK_APN1,MK_APN2,MK_STIT,MK_VYL,MK_RESET,MK_KPV,MK_KSV,MK_RNAV,MK_RVYH);

type TCasTyp=(TCA_REALNY,TCA_ZRYCHLENY,TCA_LOCONET);

type TCasZlozka=(ZCA_DEN,ZCA_HODINA,ZCA_MINUTA,ZCA_SEKUNDA);

type
  TLogikaES = class(TDataModule)
    Timer1: TTimer;
    VolbaTimer: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure VolbaTimerTimer(Sender: TObject);
  private
    { Private declarations }
    t_dopravne: TList<TDopravna>;
    t_plan: TList<TStavadloObjekt>;
    t_hitboxy: TList<THitBox>;
    t_zaverovka: TList<TCesta>;
    t_zlozene: TList<TZlozenaCesta>;

    t_dohlady: TDictionary<Integer,TVyhybkaDohlad>;

    t_nazvy_dopravni: Boolean;
    t_plan_vyska,t_plan_sirka: Integer;
    t_plan_nazov: string;

    t_volby_cesty: TList<TPair<TStavadloObjekt,Boolean>>;

    t_stavana_cesta: TCesta;
    t_stavana_vyhybka: TVyhybka;
    t_postavene_cesty: TDictionary<TStavadloObjekt,TCesta>;

    t_hint: TStavadloObjekt;
    t_poruchy: TList<TPorucha>;
    t_nevybavene_stitky: TList<TPair<TStavadloObjekt,Boolean>>;

    t_volat_dratotah: Boolean;
    t_menu_objekt: TStavadloObjekt;

    t_je_nudzovy_povel: Boolean;
    t_nudzovy_povel_dopravna: TDopravna;
    t_nudzovy_povel_typ: TNudzovyPovelTyp;
    t_nudzovy_povel_prvok: TStavadloObjekt;
    t_nudzovy_povel_potvrd_typ: TNudzovyPovelPotvrdTyp;
    t_nudzovy_povel_sekvencia: string;

    t_je_stitok,t_je_vyluka: Boolean;
    t_sv_citanie: Boolean;
    t_sv_objekt: TStavadloObjekt;
    t_sv_subor: string;

    t_cas_typ: TCasTyp;
    t_cas_hodnota: TDateTime;
    t_cas_rychlost: Integer;
    t_cas_posledny: TDateTime;
    t_cas_stoji: Boolean;
    t_cas_okno: Boolean;

    function SkontrolujConfig: Boolean;

    procedure AktualizujPanely;
    procedure ResetujDohlad(p_vyhybka: TVyhybkaDohlad);

    function JeZaciatokCesty(p_objekt: TStavadloObjekt; p_posun: Boolean): Boolean;

    procedure ZhodNudzovyPovel;
    procedure VykonajNudzovyPovel;

    function JeDalsiaPN(p_navestidlo: TNavestidloHlavne): Boolean;

  public
    { Public declarations }
    property SirkaPlanu: Integer read t_plan_sirka;
    property VyskaPlanu: Integer read t_plan_vyska;
    property NazovPlanu: string read t_plan_nazov;
    property NazvyDopravni: Boolean read t_nazvy_dopravni;

    property NudzovyPovel: Boolean read t_je_nudzovy_povel;
    property NudzovyPovelDopravna: TDopravna read t_nudzovy_povel_dopravna;
    property NudzovyPovelTyp: TNudzovyPovelTyp read t_nudzovy_povel_typ;
    property NudzovyPovelPrvok: TStavadloObjekt read t_nudzovy_povel_prvok;
    property NudzovyPovelPotvrdTyp: TNudzovyPovelPotvrdTyp read t_nudzovy_povel_potvrd_typ;
    property NudzovyPovelSekvencia: string read t_nudzovy_povel_sekvencia;

    property CasHodnota: TDateTime read t_cas_hodnota;
    property CasZrychlenie: Integer read t_cas_rychlost;
    property CasTyp: TCasTyp read t_cas_typ;
    property CasStoji: Boolean read t_cas_stoji;

    procedure VyberJednotku(p_x,p_y: Integer; p_shift: TShiftState; p_stredne: Boolean);
    procedure VyberZrusenie(p_x,p_y: Integer; p_shift: TShiftState);

    procedure SpracujSpravuB0(p_adresa: Integer; p_smer: Boolean);
    procedure SpracujSpravuB2(p_adresa: Integer; p_stav: Boolean);
    procedure SpracujSpravuBCB4(p_adresa: Integer; p_smer: Boolean);

    procedure OtestujVyhybky;
    procedure OtestujNavestidla;
    procedure ResetujVyhybky(p_stanoviste: TStanObsluhy; p_potvrd: Boolean);
    procedure ResetujNavestidla(p_stanoviste: TStanObsluhy; p_potvrd: Boolean);
    procedure ResetujDohlady(p_stanoviste: TStanObsluhy);

    procedure ResetujVyhybku(p_vyhybka: TVyhybka; p_potvrd: Boolean);
    procedure ResetujNavestidlo(p_navestidlo: TNavestidlo; p_potvrd: Boolean);
    procedure Privolavacka(p_navestidlo: TNavestidloHlavne; p_potvrd: Boolean);

    procedure AktualizujVolnoznak(p_navestidlo: TNavestidlo);

    function DajObjekt(p_kod_jednotky: TKodJednotky; p_c_jednotky: Integer): TStavadloObjekt;
    function DajCestu(p_cislo: Integer): TCesta;

    procedure DajVyhybky(p_pole: TList<TVyhybka>);
    procedure DajNavestidla(p_pole: TList<TNavestidlo>);

    procedure PridajDopravnu(p_dopravna: TDopravna);
    procedure PridajObjekt(p_objekt: TStavadloObjekt);
    procedure PridajHitBox(p_hitbox: THitBox);
    procedure PridajCestu(p_cesta: TCesta);
    procedure PridajZlozenu(p_cesta: TZlozenaCesta);

    procedure NastavParametre(p_vyska,p_sirka: Integer; p_nazov: string; p_nazvy_dopravni: Boolean);

    procedure PovolDratotah;
    procedure ZakazDratotah;

    procedure VytvorPoruchu(p_cas: TDateTime; p_dopravna: TDopravna; p_text: string);
    function DajPoruchu(p_index: Integer): TPorucha;
    function PocetPoruch: Integer;

    function DajObjekty: TList<TStavadloObjekt>;
    function DajVolby: TList<TPair<TStavadloObjekt,Boolean>>;
    function DajHitBox(p_objekt: TStavadloObjekt): THitBox;

    procedure SpracujKlavesu(p_klavesa: Word; p_shift: TShiftState);
    procedure ZobrazMenu(p_x,p_y: Integer; p_objekt: TStavadloObjekt);
    procedure SpracujMenu(p_menu: TMenuPolozka);

    procedure NastavNudzovyPovel(p_dopravna: TDopravna; p_typ: TNudzovyPovelTyp; p_prvok: TStavadloObjekt; p_potvrd_typ: TNudzovyPovelPotvrdTyp);

    procedure VypisNudzovyPovelKPV(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean ; out p_cervena_d: Boolean ; out p_cervena_e: Boolean);
    procedure VypisNudzovyPovelKSV(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean);
    procedure VypisNudzovyPovelNavestidla(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean);
    procedure VypisNudzovyPovelVyhybky(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean);

    procedure VyberHint(p_x,p_y: Integer);
    procedure ZrusHint;

    procedure NastavStitok(p_objekt: TPair<TStavadloObjekt,Boolean>);
    procedure PridajVolbaStitok(p_objekt: TStavadloObjekt);
    procedure ZadajStitok(p_objekt: TStavadloObjekt);
    procedure ZadajVyluku(p_objekt: TStavadloObjekt);
    procedure PotvrdStitokVyluku;
    procedure ZrusStitokVyluku;

    procedure PotvrdPoruchu;

    procedure UlozStitkyVyluky;

    procedure Spusti(p_subor_plan,p_subor_sv: string);
    procedure Reset(p_navestidla,p_vyhybky: Boolean);

    procedure NastavCas(p_typ: TCasTyp; p_hodnota: TDateTime; p_zrychlenie: Integer);
    procedure PridajCasZlozka(p_zlozka: TCasZlozka);
    procedure UberCasZlozka(p_zlozka: TCasZlozka);
    procedure ZastavCas;
    procedure SpustiCas;
    procedure ZapniCasOkno;
    procedure VypniCasOkno;
  end;

var
  LogikaES: TLogikaES;

implementation
  uses GUI1, DiagDialog, ComPort, IniFiles, Forms, LoadConfig, DratotahDialog,
  DateUtils, Winapi.Windows, ipwxml, CasDialog;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function HitBox(p_rect: TRect; p_objekt: TStavadloObjekt): THitBox;
begin
  Result.Poloha:=p_rect;
  Result.Objekt:=p_objekt;
end;

//****************************************************************************//

function Porucha(p_cas: TDateTime; p_dopravna: TDopravna; p_text: string): TPorucha;
begin
  Result.Cas:=p_cas;
  Result.Dopravna:=p_dopravna;
  Result.Text:=p_text;
end;

//****************************************************************************//

function NudzovyPovelTypText(p_hodnota: TNudzovyPovelTyp): string;
begin
  case p_hodnota of
    NPT_STAV: Result:='Stav prvku';
    NPT_RESETNAV: Result:='Reset n·vestidla';
    NPT_RESETVYH: Result:='Reset v˝hybky';
    NPT_RESETNAVGLOBAL,NPT_RESETNAVDOP: Result:='Reset vöetk˝ch n·vestidiel';
    NPT_RESETVYHGLOBAL,NPT_RESETVYHDOP: Result:='Reset vöetk˝ch v˝hybiek';
    NPT_PRIVOLAVACKA: Result:='Rozsvietenie priv. n·vesti';
    NPT_ZAV2: Result:='Zruöenie ruË. z·veru';
    NPT_DOH1: Result:='Vyradenie dohæadov˝ch obvodov v˝hybky';
    NPT_DOH2: Result:='Zruöenie vyradenia dohæadu v˝hybky';
    NPT_APN1: Result:='Vyn˙tenie automatickej priv. n·vesti';
    NPT_APN2: Result:='Zruöenie vyn˙tenia aut. priv. n·vesti';
    NPT_ZRUSVYLUKU: Result:='Zruöenie v˝luky';
    NPT_ZRUSSTITOK: Result:='Zruöenie ötÌtka';
    NPT_KPV: Result:='Kontrola polohy v˝hybiek';
    NPT_KSV: Result:='Kontrola ötÌtkov a v˝luk';
    else Result:='N˙dzov˝ povel';
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.DataModuleCreate(Sender: TObject);
begin
  t_dopravne:=TList<TDopravna>.Create;
  t_plan:=TList<TStavadloObjekt>.Create;
  t_hitboxy:=TList<THitBox>.Create;
  t_zaverovka:=TList<TCesta>.Create;
  t_zlozene:=TList<TZlozenaCesta>.Create;

  t_dohlady:=TDictionary<Integer,TVyhybkaDohlad>.Create;

  t_volby_cesty:=TList<TPair<TStavadloObjekt,Boolean>>.Create;
  t_hint:=nil;

  t_nevybavene_stitky:=TList<TPair<TStavadloObjekt,Boolean>>.Create;

  t_je_stitok:=False;
  t_je_vyluka:=False;
  t_sv_objekt:=nil;
  t_sv_citanie:=False;

  t_poruchy:=TList<TPorucha>.Create;

  t_stavana_cesta:=nil;
  t_stavana_vyhybka:=nil;
  t_postavene_cesty:=TDictionary<TStavadloObjekt,TCesta>.Create;

  t_volat_dratotah:=False;
  t_menu_objekt:=nil;

  t_sv_subor:='';

  t_cas_typ:=TCA_REALNY;
  t_cas_hodnota:=Now;
  t_cas_rychlost:=1;
  t_cas_posledny:=Now;
  t_cas_stoji:=True;
  t_cas_okno:=False;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.Spusti(p_subor_plan,p_subor_sv: string);
var
  config: TConfigLoader;
begin
  t_sv_subor:=p_subor_sv;

  config:=TConfigLoader.Create(p_subor_plan,p_subor_sv);
  try
    if config.NacitajKonfiguraciu(self) then
    begin
      SkontrolujConfig;
    end;

    config.NacitajStitkyVyluky(self);
  finally
    config.Free;
  end;

  Timer1.Enabled:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.Reset(p_navestidla,p_vyhybky: Boolean);
begin
  if p_vyhybky then LogikaES.ResetujVyhybky(nil,True)
  else LogikaES.OtestujVyhybky;

  if p_navestidla then LogikaES.ResetujNavestidla(nil,True);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.NastavParametre(p_vyska,p_sirka: Integer; p_nazov: string; p_nazvy_dopravni: Boolean);
begin
  t_plan_vyska:=p_vyska;
  t_plan_sirka:=p_sirka;
  t_plan_nazov:=p_nazov;
  t_nazvy_dopravni:=p_nazvy_dopravni;

  Form1.Caption:=p_nazov+' [modelK]';
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PovolDratotah;
begin
  t_volat_dratotah:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZakazDratotah;
begin
  t_volat_dratotah:=False;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.DajVyhybky(p_pole: TList<TVyhybka>);
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if objekt is TVyhybka then p_pole.Add(objekt as TVyhybka);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.DajNavestidla(p_pole: TList<TNavestidlo>);
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if objekt is TNavestidlo then p_pole.Add(objekt as TNavestidlo);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajObjekt(p_kod_jednotky: TKodJednotky; p_c_jednotky: Integer): TStavadloObjekt;
var
  objekt: TStavadloObjekt;
begin
  Result:=nil;

  for objekt in t_plan do
  begin
    if (objekt.KodJednotky=p_kod_jednotky) and (objekt.CisloJednotky=p_c_jednotky) then
    begin
      Result:=objekt;
      break;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajCestu(p_cislo: Integer): TCesta;
var
  objekt: TCesta;
begin
  Result:=nil;

  for objekt in t_zaverovka do
  begin
    if (objekt.Cislo=p_cislo) then
    begin
      Result:=objekt;
      break;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajDopravnu(p_dopravna: TDopravna);
begin
  t_dopravne.Add(p_dopravna);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajObjekt(p_objekt: TStavadloObjekt);
begin
  t_plan.Add(p_objekt);

  if p_objekt is TVyhybkaDohlad then
  begin
    t_dohlady.AddOrSetValue((p_objekt as TVyhybkaDohlad).DohladRovno,p_objekt as TVyhybkaDohlad);
    t_dohlady.AddOrSetValue((p_objekt as TVyhybkaDohlad).DohladOdbocka,p_objekt as TVyhybkaDohlad);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajHitBox(p_hitbox: THitBox);
begin
  t_hitboxy.Add(p_hitbox);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajCestu(p_cesta: TCesta);
begin
  t_zaverovka.Add(p_cesta);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajZlozenu(p_cesta: TZlozenaCesta);
begin
  t_zlozene.Add(p_cesta);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.DataModuleDestroy(Sender: TObject);
var
  i: TObject;
begin
  for i in t_plan do i.Free;
  t_plan.Free;
  for i in t_dopravne do i.Free;
  t_dopravne.Free;
  t_volby_cesty.Free;
  t_hitboxy.Free;
  t_postavene_cesty.Free;
  t_poruchy.Free;

  for i in t_zaverovka do i.Free;
  t_zaverovka.Free;

  for i in t_zlozene do i.Free;
  t_zlozene.Free;

  t_nevybavene_stitky.Free;
  t_dohlady.Free;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.AktualizujVolnoznak(p_navestidlo: TNavestidlo);
var
  cesta: TPair<TStavadloObjekt,TCesta>;
begin
  for cesta in t_postavene_cesty do
  begin
    if (cesta.Value.Dalsie=p_navestidlo) then cesta.Value.AktualizujVolnoznak(False);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.Timer1Timer(Sender: TObject);
begin
  Form1.PaintBox1.Invalidate;
  Form1.PaintBoxPoruchy.Invalidate;

  if t_cas_typ=TCA_REALNY then
  begin
    var cas:=Now;
    Form1.Cas.Caption:=FormatDateTime('dd.mm.yyyy hh:nn:ss',cas);
    if t_cas_okno then CasDlg.AktualizujCas(t_cas_typ,cas,1,False);
  end
  else
  begin
    if not t_cas_stoji then
    begin
      var cas_novy:=Now;
      t_cas_hodnota:=IncMilliSecond(t_cas_hodnota,MilliSecondsBetween(cas_novy,t_cas_posledny)*t_cas_rychlost);
      t_cas_posledny:=cas_novy;
    end;

    var text:='';
    var den:=DaysBetween(t_cas_hodnota,EncodeDate(2000,1,1));

    if den>0 then text:=text+IntToStr(den)+' - ';

    if t_cas_rychlost<=2 then text:=text+FormatDateTime('hh:nn:ss',t_cas_hodnota)
    else text:=text+FormatDateTime('hh:nn',t_cas_hodnota);

    if t_cas_stoji then text:=text+' (stojÌ)'
    else text:=text+' ('+IntToStr(t_cas_rychlost)+'x)';
    Form1.Cas.Caption:=text;

    if t_cas_okno then CasDlg.AktualizujCas(t_cas_typ,t_cas_hodnota,t_cas_rychlost,t_cas_stoji);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.SkontrolujConfig: Boolean;
var
  jednotky: TList<TJednotka>;
  objekt: TStavadloObjekt;

  cesty: TDictionary<Integer,TCesta>;
  cesta: TCesta;
begin
  Result:=True;

  jednotky:=TList<TJednotka>.Create;
  try
    for objekt in t_plan do
    begin
      if not jednotky.Contains(objekt.DajJednotku) then jednotky.Add(objekt.DajJednotku)
      else
      begin
        DiagDlg.Memo1.Lines.Insert(0,'DuplicitnÌ jednotka: '+IntToStr(Ord(objekt.KodJednotky))+'/'+IntToStr(objekt.CisloJednotky));
        Result:=False;
      end;
    end;
  finally
    jednotky.Free;
  end;

  if Result then
  begin
    cesty:=TDictionary<Integer,TCesta>.Create;
    try
      for cesta in t_zaverovka do
      begin
        if not cesty.ContainsKey(cesta.Cislo) then cesty.Add(cesta.Cislo,cesta)
        else
        begin
          DiagDlg.Memo1.Lines.Insert(0,'DuplicitnÌ cesta: '+IntToStr(cesta.Cislo));
          Result:=False;
        end;
      end;
    finally
      cesty.Free;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VolbaTimerTimer(Sender: TObject);
var
  cesta: TCesta;
  zcesta: TZlozenaCesta;
  najdena: Boolean;
  zdroj,ciel: TStavadloObjekt;
  posun: Boolean;
  vc: TPair<TStavadloObjekt,TCesta>;
begin
  if(t_stavana_vyhybka<>nil) then
  begin
    if t_nevybavene_stitky.Count=0 then
    begin
      if t_stavana_vyhybka.JeVolna(True) then
      begin
        if t_stavana_vyhybka.PolohaLog in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then CPort.VydajPovelB0(t_stavana_vyhybka.Adresa,not t_stavana_vyhybka.OtocitPolaritu)
        else if t_stavana_vyhybka.PolohaLog in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then  CPort.VydajPovelB0(t_stavana_vyhybka.Adresa,t_stavana_vyhybka.OtocitPolaritu);

        t_stavana_vyhybka:=nil;
      end
      else
      begin
        VytvorPoruchu(Now,t_stavana_vyhybka.Dopravna,'Nie s˙ splnenÈ podmienky pre prestavenie');

        t_stavana_vyhybka:=nil;
      end;

      if (t_stavana_cesta=nil) and (t_stavana_vyhybka=nil) and (t_volby_cesty.Count<2) then VolbaTimer.Enabled:=False;
    end;
  end
  else if(t_stavana_cesta<>nil) then
  begin
    if t_stavana_cesta.VolnoZnak(False) then t_stavana_cesta:=nil
    else if (not t_stavana_cesta.Zavreta) and t_stavana_cesta.Postavena then
    begin
      t_stavana_cesta.Zapevni;
      t_stavana_cesta:=nil;
    end
    else if t_nevybavene_stitky.Count=0 then
    begin
      for vc in t_postavene_cesty do
      begin
        if vc.Value=t_stavana_cesta then
        begin
          if t_stavana_cesta.Zavreta then t_stavana_cesta.Postav;
          break;
        end;
      end;
    end;
  end
  else
  begin
    if t_volby_cesty.Count>=2 then
    begin
      zdroj:=t_volby_cesty[0].Key;
      ciel:=t_volby_cesty[1].Key;
      posun:=t_volby_cesty[0].Value;

      najdena:=False;

      //overenie zlozenych ciest
      for zcesta in t_zlozene do
      begin
        najdena:=zcesta.OverVolbu(posun,zdroj,ciel);

        if najdena then
        begin
          t_volby_cesty.Delete(0);
          t_volby_cesty.Delete(0);

          zcesta.PridajVolbu(posun,t_volby_cesty);

          break;
        end;
      end;

      if(najdena) then
      begin
        najdena:=False;

        zdroj:=t_volby_cesty[0].Key;
        ciel:=t_volby_cesty[1].Key;
        posun:=t_volby_cesty[0].Value;
      end;

      //overenie jednoduchych ciest - vyber volby na postavenie
      for cesta in t_zaverovka do
      begin
        najdena:=cesta.OverVolbu(posun,zdroj,ciel);

        if najdena then
        begin
          if cesta.Zavri(posun,zdroj) then
          begin
            t_stavana_cesta:=cesta;
            t_postavene_cesty.Add(zdroj,t_stavana_cesta);
            zdroj.NastavJeZdroj(posun);

            if t_nevybavene_stitky.Count>0 then NastavStitok(t_nevybavene_stitky.First)
            else cesta.Postav;
          end
          else VytvorPoruchu(Now,zdroj.Dopravna,'Cestu nejde navoliù');

          break;
        end;
      end;

      if not najdena then VytvorPoruchu(Now,zdroj.Dopravna,'Cesta neexistuje');

      //zmazanie volieb
      t_volby_cesty.Delete(0);
      t_volby_cesty.Delete(0);
    end;

    if (t_stavana_cesta=nil) and (t_stavana_vyhybka=nil) and (t_volby_cesty.Count<2) then VolbaTimer.Enabled:=False;
  end;

  AktualizujPanely;
  Form1.PaintBox1.Invalidate;
  if t_volat_dratotah then DratotahDlg.Obnov;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VyberJednotku(p_x,p_y: Integer; p_shift: TShiftState; p_stredne: Boolean);
var
  perc_x,perc_y: Integer;
  hitbox: THitBox;
  vysledok: TStavadloObjekt;
  povely: TList<TPair<Integer,Boolean>>;
  povel: TPair<Integer,Boolean>;
  volba: TPair<TStavadloObjekt,Boolean>;
  posun: Boolean;
  cesta: TCesta;
begin
  perc_x:=((p_x*SirkaPlanu) div Form1.PaintBox1.Width);
  perc_y:=((p_y*VyskaPlanu) div Form1.PaintBox1.Height);

  vysledok:=nil;

  for hitbox in t_hitboxy do
  begin
    if (perc_x>=hitbox.Poloha.Left) and (perc_x<hitbox.Poloha.Right) and (perc_y>=hitbox.Poloha.Top) and (perc_y<hitbox.Poloha.Bottom) then
    begin
       vysledok:=hitbox.Objekt;
       break;
    end;
  end;

  if vysledok<>nil then
  begin
    if(vysledok is TNavestidloHlavne) and (ssAlt in p_shift) and (ssShift in p_shift) then
    begin
      if(not (vysledok as TNavestidloHlavne).RucnyZaver) then
      begin
        if (vysledok as TNavestidloHlavne).Navest[False]=CN_PRIVOLAVACKA then
        begin
          povely:=TList<TPair<Integer,Boolean>>.Create;
          try
            (vysledok as TNavestidloHlavne).RozsvietNavest(CN_STOJ,povely);
            for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
          finally
            povely.Free;
          end;
        end
        else if (vysledok as TNavestidloHlavne).Navest[False] in [CN_STOJ,CN_NEZNAMA] then Privolavacka(vysledok as TNavestidloHlavne,False);
      end;
    end
    else if(vysledok is TNavestidlo) and (t_postavene_cesty.TryGetValue(vysledok,cesta)) then
    begin
      if ((vysledok is TNavestidloHlavne) and ((vysledok as TNavestidloHlavne).Navest[False]<>CN_STOJ)) or ((vysledok is TNavestidloZriadovacie) and ((vysledok as TNavestidloZriadovacie).Navest[False]<>CN_STOJ)) then cesta.ZrusVolnoznak
      else cesta.AktualizujVolnoznak(True);
    end
    else  if(not (vysledok is TVyhybka)) and ((not (ssAlt in p_shift)) or (not (ssShift in p_shift))) then
    begin
      if(t_stavana_vyhybka=nil) then
      begin
        if (t_volby_cesty.Count mod 2=0) then
        begin
          posun:=(ssCtrl in p_shift) or (p_stredne) or (vysledok is TNavestidloZriadovacie) or (vysledok is TKolajCiara);

          if JeZaciatokCesty(vysledok,posun) then
          begin
            volba.Key:=vysledok;
            volba.Value:=posun;
            t_volby_cesty.Add(volba);
          end;
        end
        else if (t_volby_cesty.Count mod 2=1) then
        begin
          volba.Key:=vysledok;
          volba.Value:=t_volby_cesty.Last.Value;
          t_volby_cesty.Add(volba);

          posun:=(ssCtrl in p_shift) or (p_stredne) or (vysledok is TNavestidloZriadovacie) or (vysledok is TKolajCiara);

          if (vysledok is TNavestidlo) and JeZaciatokCesty(vysledok,posun) then
          begin
            volba.Value:=posun;
            t_volby_cesty.Add(volba);
          end;

          if not VolbaTimer.Enabled then VolbaTimer.Enabled:=True;
        end;
      end;
    end
    else if(vysledok is TVyhybka) then
    begin
      if (vysledok as TVyhybka).JeVolna(True) then
      begin
        if ((vysledok as TVyhybka).Stitok='') and ((vysledok as TVyhybka).Vyluka='') then
        begin
          if (vysledok as TVyhybka).PolohaLog in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then CPort.VydajPovelB0((vysledok as TVyhybka).Adresa,not (vysledok as TVyhybka).OtocitPolaritu)
          else if (vysledok as TVyhybka).PolohaLog in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then  CPort.VydajPovelB0((vysledok as TVyhybka).Adresa,(vysledok as TVyhybka).OtocitPolaritu);
        end
        else
        begin
          if(t_stavana_cesta=nil) then
          begin
            t_nevybavene_stitky.Clear;
            t_stavana_vyhybka:=vysledok as TVyhybka;
            if ((vysledok as TVyhybka).Vyluka<>'') then t_nevybavene_stitky.Add(TPair<TStavadloObjekt,Boolean>.Create(vysledok,True));
            if ((vysledok as TVyhybka).Stitok<>'') then t_nevybavene_stitky.Add(TPair<TStavadloObjekt,Boolean>.Create(vysledok,False));

            if t_nevybavene_stitky.Count>0 then NastavStitok(t_nevybavene_stitky.First);

            if not VolbaTimer.Enabled then VolbaTimer.Enabled:=True;
          end;
        end;
      end;
    end;
  end;

  Form1.PaintBox1.Invalidate;
  AktualizujPanely;
  if t_volat_dratotah then DratotahDlg.Obnov;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VyberZrusenie(p_x,p_y: Integer; p_shift: TShiftState);
var
  perc_x,perc_y: Integer;
  hitbox: THitBox;
  vysledok: TStavadloObjekt;
  povel: TPair<Integer,Boolean>;
  povely: TList<TPair<Integer,Boolean>>;
  cesta: TCesta;
begin
  if t_volby_cesty.Count>0 then t_volby_cesty.Remove(t_volby_cesty.Last)
  else
  begin
    perc_x:=((p_x*SirkaPlanu) div Form1.PaintBox1.Width);
    perc_y:=((p_y*VyskaPlanu) div Form1.PaintBox1.Height);

    vysledok:=nil;

    for hitbox in t_hitboxy do
    begin
      if (perc_x>=hitbox.Poloha.Left) and (perc_x<hitbox.Poloha.Right) and (perc_y>=hitbox.Poloha.Top) and (perc_y<hitbox.Poloha.Bottom) then
      begin
         vysledok:=hitbox.Objekt;
         break;
      end;
    end;

    if(vysledok<>nil) and (ssCtrl in p_shift) and ((vysledok is TNavestidlo) or (vysledok is TKolajCiara) or (vysledok is TVyhybka) or (vysledok is TStanObsluhy)) then ZobrazMenu(p_x,p_y,vysledok)
    else if(vysledok<>nil) and (vysledok is TNavestidloHlavne) and ((vysledok as TNavestidloHlavne).Navest[False]=CN_PRIVOLAVACKA) and ((not (vysledok as TNavestidloHlavne).APN) or (not t_postavene_cesty.TryGetValue(vysledok,cesta))) then
    begin
      povely:=TList<TPair<Integer,Boolean>>.Create;
      try
        (vysledok as TNavestidloHlavne).RozsvietNavest(CN_STOJ,povely);
        for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
      finally
        povely.Free;
      end;
    end
    else if (vysledok<>nil) and (t_postavene_cesty.TryGetValue(vysledok,cesta)) then
    begin
      cesta.Zrus;
      t_postavene_cesty.Remove(vysledok);
      vysledok.ZrusJeZdroj;
      if t_stavana_cesta=cesta then t_stavana_cesta:=nil;
    end
    else if(vysledok<>nil) and (vysledok<>t_menu_objekt) and ((vysledok is TNavestidlo) or (vysledok is TKolajCiara) or (vysledok is TVyhybka) or (vysledok is TStanObsluhy)) then ZobrazMenu(p_x,p_y,vysledok)
    else if(vysledok=nil) or (vysledok=t_menu_objekt) then t_menu_objekt:=nil;
  end;

  Form1.PaintBox1.Invalidate;
  AktualizujPanely;
  if t_volat_dratotah then DratotahDlg.Obnov;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.AktualizujPanely;
var
  text: string;
begin
  if t_volby_cesty.Count>0 then
  begin
    text:=t_volby_cesty[0].Key.Nazov[True,True];

    if(t_volby_cesty.Count>1) then
    begin
      text:=text+' -> ';
      text:=text+t_volby_cesty[1].Key.Nazov[True,True];
    end;

    Form1.VJednotka.Color:=clBlack;
  end
  else if t_hint<>nil then
  begin
    text:=t_hint.Nazov[True,True];
    Form1.VJednotka.Color:=clDkGray;
  end
  else
  begin
    text:='';
    Form1.VJednotka.Color:=clBlack;
  end;

  Form1.VJednotka.Caption:=text;
  Form1.PaintBoxPoruchy.Invalidate;
  Form1.PaintBoxRizika.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujSpravuB0(p_adresa: Integer; p_smer: Boolean);
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if (objekt is TVyhybka) and ((objekt as TVyhybka).Adresa=p_adresa) then (objekt as TVyhybka).NastavPolohuCentrala(p_smer,True);
    if (objekt is TNavestidlo) and ((objekt as TNavestidlo).ObsahujeAdresu(p_adresa)) then (objekt as TNavestidlo).NastavPolohu(p_adresa,p_smer);
  end;

  Form1.PaintBox1.Invalidate;
  if t_volat_dratotah then DratotahDlg.Obnov;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujSpravuB2(p_adresa: Integer; p_stav: Boolean);
var
  objekt: TVyhybkaDohlad;
begin
  DiagDlg.Memo1.Lines.Add('Spr·va B2 adr: '+IntToStr(p_adresa)+' stav: '+BoolToStr(p_stav,True));

  if t_dohlady.TryGetValue(p_adresa,objekt) then (objekt as TVyhybkaDohlad).NastavDohlad(p_adresa,p_stav);

  Form1.PaintBox1.Invalidate;
  if t_volat_dratotah then DratotahDlg.Obnov;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujSpravuBCB4(p_adresa: Integer; p_smer: Boolean);
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if (objekt is TVyhybka) and ((objekt as TVyhybka).Adresa=p_adresa) then (objekt as TVyhybka).NastavPolohuCentrala(p_smer,False);
    if (objekt is TNavestidlo) and ((objekt as TNavestidlo).ObsahujeAdresu(p_adresa)) then (objekt as TNavestidlo).NastavPolohu(p_adresa,p_smer);
  end;

  Form1.PaintBox1.Invalidate;
  if t_volat_dratotah then DratotahDlg.Obnov;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.OtestujVyhybky;
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if (objekt is TVyhybka) then CPort.VydajPovelBC((objekt as TVyhybka).Adresa);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.OtestujNavestidla;
var
  objekt: TStavadloObjekt;
  adresy: TList<Integer>;
  adresa: Integer;
begin
  for objekt in t_plan do
  begin
    if (objekt is TNavestidlo) then
    begin
      adresy:=TList<Integer>.Create;
      try
        (objekt as TNavestidlo).DajAdresy(adresy);
        for adresa in adresy do CPort.VydajPovelBC(adresa);
      finally
        adresy.Free;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujVyhybky(p_stanoviste: TStanObsluhy; p_potvrd: Boolean);
var
  objekt: TStavadloObjekt;
begin
  if p_potvrd then
  begin
    for objekt in t_plan do
    begin
      if (objekt is TVyhybka) and ((p_stanoviste=nil) or (p_stanoviste.Dopravna=objekt.Dopravna)) then ResetujVyhybku((objekt as TVyhybka),p_potvrd);
    end;

    ResetujDohlady(p_stanoviste);

    if t_volat_dratotah then DratotahDlg.Obnov;
  end
  else if p_stanoviste<>nil then NastavNudzovyPovel(p_stanoviste.Dopravna,NPT_RESETVYHDOP,p_stanoviste,NPP_ASDF)
  else NastavNudzovyPovel(nil,NPT_RESETVYHGLOBAL,nil,NPP_ASDF);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujDohlady(p_stanoviste: TStanObsluhy);
var
  vybavene_resety: TList<Integer>;
  objekt: TStavadloObjekt;
begin
  vybavene_resety:=TList<Integer>.Create;
  try
    for objekt in t_plan do
    begin
      if (objekt is TVyhybkaDohlad) and ((p_stanoviste=nil) or (p_stanoviste.Dopravna=objekt.Dopravna)) then
      begin
        if not vybavene_resety.Contains((objekt as TVyhybkaDohlad).DohladReset) then
        begin
          ResetujDohlad(objekt as TVyhybkaDohlad);
          vybavene_resety.Add((objekt as TVyhybkaDohlad).DohladReset);
        end;
      end;
    end;
  finally
    vybavene_resety.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujNavestidla(p_stanoviste: TStanObsluhy; p_potvrd: Boolean);
var
  objekt: TStavadloObjekt;
begin
  if p_potvrd then
  begin
    for objekt in t_plan do
    begin
      if (objekt is TNavestidlo) and ((p_stanoviste=nil) or (p_stanoviste.Dopravna=objekt.Dopravna)) then ResetujNavestidlo(objekt as TNavestidlo,p_potvrd);
    end;

    if t_volat_dratotah then DratotahDlg.Obnov;
  end
  else if p_stanoviste<>nil then NastavNudzovyPovel(p_stanoviste.Dopravna,NPT_RESETNAVDOP,p_stanoviste,NPP_ASDF)
  else NastavNudzovyPovel(nil,NPT_RESETNAVGLOBAL,nil,NPP_ASDF);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujVyhybku(p_vyhybka: TVyhybka; p_potvrd: Boolean);
begin
  if p_potvrd then
  begin
    if p_vyhybka.PolohaLog in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then CPort.VydajPovelB0((p_vyhybka as TVyhybka).Adresa,(p_vyhybka as TVyhybka).OtocitPolaritu)
    else if p_vyhybka.PolohaLog in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then  CPort.VydajPovelB0((p_vyhybka as TVyhybka).Adresa,not (p_vyhybka as TVyhybka).OtocitPolaritu);
  end
  else NastavNudzovyPovel(p_vyhybka.Dopravna,NPT_RESETVYH,p_vyhybka,NPP_ASDF);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujDohlad(p_vyhybka: TVyhybkaDohlad);
begin
  CPort.VydajPovelB0((p_vyhybka as TVyhybkaDohlad).DohladReset,False)
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujNavestidlo(p_navestidlo: TNavestidlo; p_potvrd: Boolean);
var
  povely: TList<TPair<Integer,Boolean>>;
  povel: TPair<Integer,Boolean>;
begin
  if p_potvrd then
  begin
    povely:=TList<TPair<Integer,Boolean>>.Create;
    try
      (p_navestidlo as TNavestidlo).Reset(povely);
      for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
    finally
      povely.Free;
    end;
  end
  else NastavNudzovyPovel(p_navestidlo.Dopravna,NPT_RESETNAV,p_navestidlo,NPP_ASDF);
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.JeDalsiaPN(p_navestidlo: TNavestidloHlavne): Boolean;
begin
  Result:=False;

  for var v_objekt in t_plan do
  begin
    if v_objekt is TNavestidloHlavne then
    begin
      if ((v_objekt as TNavestidloHlavne).SkupinaPN=p_navestidlo.SkupinaPN) and ((v_objekt as TNavestidloHlavne).Navest[False]=CN_PRIVOLAVACKA) then
      begin
        Result:=True;
        break;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.Privolavacka(p_navestidlo: TNavestidloHlavne; p_potvrd: Boolean);
begin
  if not JeDalsiaPN(p_navestidlo) then
  begin
    if p_potvrd then
    begin
      if(not p_navestidlo.RucnyZaver) then
      begin
        var povely:=TList<TPair<Integer,Boolean>>.Create;
        try
          if p_navestidlo.Navest[False] in [CN_STOJ,CN_NEZNAMA] then p_navestidlo.RozsvietNavest(CN_PRIVOLAVACKA,povely);
          for var povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
        finally
          povely.Free;
        end;
      end;
    end
    else NastavNudzovyPovel(p_navestidlo.Dopravna,NPT_PRIVOLAVACKA,p_navestidlo,NPP_ASDF);
  end
  else VytvorPoruchu(Now,p_navestidlo.Dopravna,'Nejde rozsvietiù Ôalöiu PN na zhlavÌ');
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.JeZaciatokCesty(p_objekt: TStavadloObjekt; p_posun: Boolean): Boolean;
var
  cesta: TCesta;
begin
  Result:=False;

  for cesta in t_zaverovka do
  begin
    if cesta.OverZdroj(p_objekt,p_posun) then
    begin
      Result:=True;
      break;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajPoruchu(p_index: Integer): TPorucha;
begin
  if (p_index>=0) and (p_index<t_poruchy.Count) then Result:=t_poruchy[p_index];
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.PocetPoruch: Integer;
begin
  Result:=t_poruchy.Count;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VytvorPoruchu(p_cas: TDateTime; p_dopravna: TDopravna; p_text: string);
begin
  t_poruchy.Add(Porucha(p_cas,p_dopravna,p_text));
  Form1.PaintBoxPoruchy.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajObjekty: TList<TStavadloObjekt>;
begin
  Result:=t_plan;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajVolby: TList<TPair<TStavadloObjekt,Boolean>>;
begin
  Result:=t_volby_cesty;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajHitBox(p_objekt: TStavadloObjekt): THitBox;
var
  hitbox: THitBox;
begin
  Result.Objekt:=nil;
  Result.Poloha:=Rect(0,0,0,0);

  for hitbox in t_hitboxy do
  begin
    if hitbox.Objekt=p_objekt then
    begin
      Result:=hitbox;
      break;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZhodNudzovyPovel;
begin
  t_je_nudzovy_povel:=False;
  VytvorPoruchu(Now,t_nudzovy_povel_dopravna,'Nespr·vne heslo');
  Form1.PaintBoxRizika.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VykonajNudzovyPovel;
begin
  case t_nudzovy_povel_typ of
    NPT_RESETNAV: ResetujNavestidlo(t_nudzovy_povel_prvok as TNavestidlo,True);
    NPT_RESETVYH: ResetujVyhybku(t_nudzovy_povel_prvok as TVyhybka,True);
    NPT_RESETNAVDOP: ResetujNavestidla(t_nudzovy_povel_prvok as TStanObsluhy,True);
    NPT_RESETVYHDOP: ResetujVyhybky(t_nudzovy_povel_prvok as TStanObsluhy,True);
    NPT_RESETNAVGLOBAL: ResetujNavestidla(nil,True);
    NPT_RESETVYHGLOBAL: ResetujVyhybky(nil,True);
    NPT_PRIVOLAVACKA: Privolavacka((t_nudzovy_povel_prvok as TNavestidloHlavne),True);
    NPT_ZAV2: (t_nudzovy_povel_prvok as TVyhybka).NastavRucnyZaver(False,True);
    NPT_DOH1:
    begin
      (t_nudzovy_povel_prvok as TVyhybkaDohlad).NastavDohladVypnuty(True);
      UlozStitkyVyluky;
    end;
    NPT_DOH2:
    begin
      (t_nudzovy_povel_prvok as TVyhybkaDohlad).NastavDohladVypnuty(False);
      UlozStitkyVyluky;
    end;
    NPT_APN1:
    begin
      (t_nudzovy_povel_prvok as TNavestidloHlavne).NastavAPN(True);
      UlozStitkyVyluky;
    end;
    NPT_APN2:
    begin
      (t_nudzovy_povel_prvok as TNavestidloHlavne).NastavAPN(False);
      UlozStitkyVyluky;
    end;
    NPT_ZRUSVYLUKU:
    begin
      if t_nudzovy_povel_prvok is TVyhybka then (t_nudzovy_povel_prvok as TVyhybka).NastavVyluku('')
      else (t_nudzovy_povel_prvok as TKolajCiara).NastavVyluku('');
      UlozStitkyVyluky;
    end;
    NPT_ZRUSSTITOK:
    begin
      if t_nudzovy_povel_prvok is TVyhybka then (t_nudzovy_povel_prvok as TVyhybka).NastavStitok('')
      else if t_nudzovy_povel_prvok is TNavestidlo then (t_nudzovy_povel_prvok as TNavestidlo).NastavStitok('')
      else (t_nudzovy_povel_prvok as TKolajCiara).NastavStitok('');
      UlozStitkyVyluky;
    end;
  end;

  t_je_nudzovy_povel:=False;
  Form1.PaintBoxRizika.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PotvrdPoruchu;
begin
  if t_poruchy.Count>0 then
  begin
    t_poruchy.Delete(0);
    Form1.PaintBoxPoruchy.Invalidate;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujKlavesu(p_klavesa: Word; p_shift: TShiftState);
begin
  case p_klavesa of
    VK_RETURN:
    begin
      if t_je_nudzovy_povel then
      begin
        if t_nudzovy_povel_potvrd_typ=NPP_ENTER then VykonajNudzovyPovel
        else
        begin
          if t_nudzovy_povel_sekvencia='ASDF' then VykonajNudzovyPovel
          else ZhodNudzovyPovel;
        end;
      end
      else if t_je_stitok or t_je_vyluka then PotvrdStitokVyluku
      else PotvrdPoruchu;
    end;
    Ord('A'):
    begin
      if t_je_nudzovy_povel and (t_nudzovy_povel_potvrd_typ=NPP_ASDF) then
      begin
        if t_nudzovy_povel_sekvencia='' then
        begin
          t_nudzovy_povel_sekvencia:='A';
          Form1.PaintBoxRizika.Invalidate;
        end
        else ZhodNudzovyPovel;
      end;
    end;
    Ord('S'):
    begin
      if t_je_nudzovy_povel and (t_nudzovy_povel_potvrd_typ=NPP_ASDF) then
      begin
        if t_nudzovy_povel_sekvencia='A' then
        begin
          t_nudzovy_povel_sekvencia:='AS';
          Form1.PaintBoxRizika.Invalidate;
        end
        else ZhodNudzovyPovel;
      end;
    end;
    Ord('D'):
    begin
      if t_je_nudzovy_povel and (t_nudzovy_povel_potvrd_typ=NPP_ASDF) then
      begin
        if t_nudzovy_povel_sekvencia='AS' then
        begin
          t_nudzovy_povel_sekvencia:='ASD';
          Form1.PaintBoxRizika.Invalidate;
        end
        else ZhodNudzovyPovel;
      end;
    end;
    Ord('F'):
    begin
      if t_je_nudzovy_povel and (t_nudzovy_povel_potvrd_typ=NPP_ASDF) then
      begin
        if t_nudzovy_povel_sekvencia='ASD' then
        begin
          t_nudzovy_povel_sekvencia:='ASDF';
          Form1.PaintBoxRizika.Invalidate;
        end
        else ZhodNudzovyPovel;
      end;
    end;
    VK_ESCAPE:
    begin
      if t_je_nudzovy_povel then
      begin
        t_je_nudzovy_povel:=False;
        Form1.PaintBoxRizika.Invalidate;
      end
      else if t_je_stitok or t_je_vyluka then ZrusStitokVyluku;
    end;
    VK_F8,VK_F9,VK_F11:; //zabezpecenie ignorovania skratiek y menu
    else
    begin
      if (p_klavesa<>VK_SHIFT) and (p_klavesa<>VK_MENU) and (p_klavesa<>VK_LSHIFT) and (p_klavesa<>VK_RSHIFT) and t_je_nudzovy_povel and (t_nudzovy_povel_potvrd_typ=NPP_ASDF) then ZhodNudzovyPovel;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZobrazMenu(p_x,p_y: Integer; p_objekt: TStavadloObjekt);
begin
  Form1.NAZOV1.Caption:=p_objekt.Nazov[True,True];

  if p_objekt is TVyhybka then
  begin
    t_menu_objekt:=p_objekt;
    Form1.STAV1.Visible:=True;
    Form1.SSTAV.Visible:=True;
    Form1.STOJ1.Visible:=False;
    Form1.DN1.Visible:=False;
    Form1.PN1.Visible:=False;
    Form1.SNAV.Visible:=False;
    Form1.ZAM1.Visible:=False;
    Form1.ZAM2.Visible:=False;
    Form1.SZAM.Visible:=False;
    Form1.P1.Visible:=(t_menu_objekt as TVyhybka).JeVolna(True) and ((t_menu_objekt as TVyhybka).PolohaLog in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK]);
    Form1.P2.Visible:=(t_menu_objekt as TVyhybka).JeVolna(True) and ((t_menu_objekt as TVyhybka).PolohaLog in [VPO_NEZNAMA,VPO_ROVNO,VPO_ROVNO_OTAZNIK]);
    Form1.SVYH.Visible:=True;
    Form1.ZAV1.Visible:=(not (t_menu_objekt as TVyhybka).RucnyZaver) and ((t_menu_objekt as TVyhybka).PolohaLog<>VPO_NEZNAMA);
    Form1.ZAV2.Visible:=(t_menu_objekt as TVyhybka).RucnyZaver;
    Form1.DOH1.Visible:=(t_menu_objekt is TVyhybkaDohlad) and (not (t_menu_objekt as TVyhybkaDohlad).DohladVypnuty);
    Form1.DOH2.Visible:=(t_menu_objekt is TVyhybkaDohlad) and ((t_menu_objekt as TVyhybkaDohlad).DohladVypnuty);
    Form1.APN1.Visible:=False;
    Form1.APN2.Visible:=False;
    Form1.SZAV.Visible:=True;
    Form1.STIT1.Visible:=True;
    Form1.VYL1.Visible:=True;
    Form1.SVYL.Visible:=True;
    Form1.RESET1.Visible:=True;
    Form1.KPV1.Visible:=False;
    Form1.KSV1.Visible:=False;
    Form1.RNAV1.Visible:=False;
    Form1.RVYH1.Visible:=False;
  end
  else if p_objekt is TNavestidlo then
  begin
    t_menu_objekt:=p_objekt;
    Form1.STAV1.Visible:=True;
    Form1.SSTAV.Visible:=True;
    Form1.STOJ1.Visible:=(t_menu_objekt as TNavestidlo).Navest[False]<>CN_STOJ;
    Form1.DN1.Visible:=((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ) and ((t_menu_objekt as TNavestidlo).JeZdroj);
    Form1.PN1.Visible:=(t_menu_objekt is TNavestidloHlavne) and ((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ) and (not JeDalsiaPN(t_menu_objekt as TNavestidloHlavne));
    Form1.SNAV.Visible:=True;
    Form1.ZAM1.Visible:=(not (t_menu_objekt as TNavestidlo).RucnyZaver) and ((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ);
    Form1.ZAM2.Visible:=(t_menu_objekt as TNavestidlo).RucnyZaver;
    Form1.SZAM.Visible:=True;
    Form1.P1.Visible:=False;
    Form1.P2.Visible:=False;
    Form1.SVYH.Visible:=False;
    Form1.ZAV1.Visible:=False;
    Form1.ZAV2.Visible:=False;
    Form1.DOH1.Visible:=False;
    Form1.DOH2.Visible:=False;
    Form1.APN1.Visible:=(t_menu_objekt is TNavestidloHlavne) and ((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ) and (not (t_menu_objekt as TNavestidloHlavne).APN);
    Form1.APN2.Visible:=(t_menu_objekt is TNavestidloHlavne) and ((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ) and (t_menu_objekt as TNavestidloHlavne).APN;
    Form1.SZAV.Visible:=False;
    Form1.STIT1.Visible:=True;
    Form1.VYL1.Visible:=False;
    FOrm1.SVYL.Visible:=True;
    Form1.RESET1.Visible:=True;
    Form1.KPV1.Visible:=False;
    Form1.KSV1.Visible:=False;
    Form1.RNAV1.Visible:=False;
    Form1.RVYH1.Visible:=False;
  end
  else if p_objekt is TKolajCiara then
  begin
    t_menu_objekt:=p_objekt;
    Form1.STAV1.Visible:=True;
    Form1.SSTAV.Visible:=True;
    Form1.STOJ1.Visible:=False;
    Form1.DN1.Visible:=False;
    Form1.PN1.Visible:=False;
    Form1.SNAV.Visible:=False;
    Form1.ZAM1.Visible:=False;
    Form1.ZAM2.Visible:=False;
    Form1.SZAM.Visible:=False;
    Form1.P1.Visible:=False;
    Form1.P2.Visible:=False;
    Form1.SVYH.Visible:=False;
    Form1.ZAV1.Visible:=False;
    Form1.ZAV2.Visible:=False;
    Form1.DOH1.Visible:=False;
    Form1.DOH2.Visible:=False;
    Form1.APN1.Visible:=False;
    Form1.APN2.Visible:=False;
    Form1.SZAV.Visible:=False;
    Form1.STIT1.Visible:=True;
    Form1.VYL1.Visible:=True;
    FOrm1.SVYL.Visible:=True;
    Form1.RESET1.Visible:=False;
    Form1.KPV1.Visible:=False;
    Form1.KSV1.Visible:=False;
    Form1.RNAV1.Visible:=False;
    Form1.RVYH1.Visible:=False;
  end
  else if p_objekt is TStanObsluhy then
  begin
    t_menu_objekt:=p_objekt;
    Form1.STAV1.Visible:=False;
    Form1.SSTAV.Visible:=False;
    Form1.STOJ1.Visible:=False;
    Form1.DN1.Visible:=False;
    Form1.PN1.Visible:=False;
    Form1.SNAV.Visible:=False;
    Form1.ZAM1.Visible:=False;
    Form1.ZAM2.Visible:=False;
    Form1.SZAM.Visible:=False;
    Form1.P1.Visible:=False;
    Form1.P2.Visible:=False;
    Form1.SVYH.Visible:=False;
    Form1.ZAV1.Visible:=False;
    Form1.ZAV2.Visible:=False;
    Form1.DOH1.Visible:=False;
    Form1.DOH2.Visible:=False;
    Form1.APN1.Visible:=False;
    Form1.APN2.Visible:=False;
    Form1.SZAV.Visible:=False;
    Form1.STIT1.Visible:=False;
    Form1.VYL1.Visible:=False;
    FOrm1.SVYL.Visible:=False;
    Form1.RESET1.Visible:=False;
    Form1.KPV1.Visible:=True;
    Form1.KSV1.Visible:=True;
    Form1.RNAV1.Visible:=True;
    Form1.RVYH1.Visible:=True;
  end;

  Form1.PopupMenu1.Popup(p_x,p_y);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujMenu(p_menu: TMenuPolozka);
var
  cesta: TCesta;
  povely: TList<TPair<Integer,Boolean>>;
  povel: TPair<Integer,Boolean>;
begin
  case p_menu of
    MK_STAV: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_STAV,t_menu_objekt,NPP_ENTER);
    MK_STOJ:
    begin
      if ((t_menu_objekt as TNavestidlo).Navest[False]<>CN_STOJ) then
      begin
        if t_postavene_cesty.TryGetValue(t_menu_objekt,cesta) then cesta.ZrusVolnoznak
        else
        begin
          povely:=TList<TPair<Integer,Boolean>>.Create;
          try
            (t_menu_objekt as TNavestidlo).RozsvietNavest(CN_STOJ,povely);
            for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
          finally
            povely.Free;
          end;
        end;
      end
    end;
    MK_DN: if t_postavene_cesty.TryGetValue(t_menu_objekt,cesta) then cesta.AktualizujVolnoznak(False);
    MK_PN: Privolavacka(t_menu_objekt as TNavestidloHlavne,False);
    MK_ZAM1: if (t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ then (t_menu_objekt as TNavestidlo).NastavRucnyZaver(True);
    MK_ZAM2: (t_menu_objekt as TNavestidlo).NastavRucnyZaver(False);
    MK_P1: if (t_menu_objekt as TVyhybka).JeVolna(True) then CPort.VydajPovelB0((t_menu_objekt as TVyhybka).Adresa,not (t_menu_objekt as TVyhybka).OtocitPolaritu);
    MK_P2: if (t_menu_objekt as TVyhybka).JeVolna(True) then CPort.VydajPovelB0((t_menu_objekt as TVyhybka).Adresa,(t_menu_objekt as TVyhybka).OtocitPolaritu);
    MK_ZAV1: (t_menu_objekt as TVyhybka).NastavRucnyZaver(True,False);
    MK_ZAV2: (t_menu_objekt as TVyhybka).NastavRucnyZaver(False,False);
    MK_DOH1: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_DOH1,t_menu_objekt,NPP_ASDF);
    MK_DOH2: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_DOH2,t_menu_objekt,NPP_ENTER);
    MK_APN1: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_APN1,t_menu_objekt,NPP_ASDF);
    MK_APN2: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_APN2,t_menu_objekt,NPP_ASDF);
    MK_STIT: ZadajStitok(t_menu_objekt);
    MK_VYL: ZadajVyluku(t_menu_objekt);
    MK_RESET:
    begin
      if (t_menu_objekt is TNavestidlo) then ResetujNavestidlo(t_menu_objekt as TNavestidlo,False)
      else ResetujVyhybku(t_menu_objekt as TVyhybka,False);
    end;
    MK_KPV: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_KPV,t_menu_objekt,NPP_ENTER);
    MK_KSV: NastavNudzovyPovel(t_menu_objekt.Dopravna,NPT_KSV,t_menu_objekt,NPP_ENTER);
    MK_RNAV: ResetujNavestidla(t_menu_objekt as TStanObsluhy,False);
    MK_RVYH: ResetujVyhybky(t_menu_objekt as TStanObsluhy,False);
  end;

  AktualizujPanely;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.NastavNudzovyPovel(p_dopravna: TDopravna; p_typ: TNudzovyPovelTyp; p_prvok: TStavadloObjekt; p_potvrd_typ: TNudzovyPovelPotvrdTyp);
begin
  t_je_nudzovy_povel:=True;
  t_nudzovy_povel_dopravna:=p_dopravna;
  t_nudzovy_povel_typ:=p_typ;
  t_nudzovy_povel_prvok:=p_prvok;
  t_nudzovy_povel_potvrd_typ:=p_potvrd_typ;
  t_nudzovy_povel_sekvencia:='';

  Form1.PaintBoxRizika.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VypisNudzovyPovelKPV(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean ; out p_cervena_d: Boolean ; out p_cervena_e: Boolean);
var
  prvok: TStavadloObjekt;
begin
  p_popis_a:='(A) Z·kladn·';
  p_popis_b:='(B) OpaËn·';
  p_popis_c:='(C) Z·kladn· nepotvrden·';
  p_popis_d:='(D) OpaËn· nepotvrden·';
  p_popis_e:='(E) Nezn·ma/bez dohæadu';
  p_text_a:='';
  p_text_b:='';
  p_text_c:='';
  p_text_d:='';
  p_text_e:='';
  p_cervena_a:=False;
  p_cervena_b:=False;
  p_cervena_c:=False;
  p_cervena_d:=False;
  p_cervena_e:=False;

  for prvok in t_plan do
  begin
    if prvok is TVyhybka then
    begin
      case (prvok as TVyhybka).PolohaLog of
        VPO_ROVNO:
        begin
          if (Pos(';'+prvok.Nazov[False,False]+';',';'+p_text_a+';')=0) then
          begin
            if p_text_a<>'' then p_text_a:=p_text_a+';';
            p_text_a:=p_text_a+prvok.Nazov[False,False];
          end;
        end;
        VPO_ODBOCKA:
        begin
          if (Pos(';'+prvok.Nazov[False,False]+';',';'+p_text_b+';')=0) then
          begin
            if p_text_b<>'' then p_text_b:=p_text_b+';';
            p_text_b:=p_text_b+prvok.Nazov[False,False];
          end;
        end;
        VPO_ROVNO_OTAZNIK:
        begin
          if (Pos(';'+prvok.Nazov[False,False]+';',';'+p_text_c+';')=0) then
          begin
            if p_text_c<>'' then p_text_c:=p_text_c+';';
            p_text_c:=p_text_c+prvok.Nazov[False,False];
            p_cervena_c:=True;
          end;
        end;
        VPO_ODBOCKA_OTAZNIK:
        begin
          if (Pos(';'+prvok.Nazov[False,False]+';',';'+p_text_d+';')=0) then
          begin
            if p_text_d<>'' then p_text_d:=p_text_d+';';
            p_text_d:=p_text_d+prvok.Nazov[False,False];
            p_cervena_d:=True;
          end;
        end;
        else
        begin
          if (Pos(';'+prvok.Nazov[False,False]+';',';'+p_text_e+';')=0) then
          begin
            if p_text_e<>'' then p_text_e:=p_text_e+';';
            p_text_e:=p_text_e+prvok.Nazov[False,False];
            p_cervena_e:=True;
          end;
        end;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VypisNudzovyPovelKSV(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean);
var
  prvok: TStavadloObjekt;
begin
  p_popis_a:='(A) ätÌtok';
  p_popis_b:='(B) V˝luka';
  p_popis_c:='(C) Bez ötÌtku/v˝luky';
  p_text_a:='';
  p_text_b:='';
  p_text_c:='';
  p_cervena_a:=False;
  p_cervena_b:=False;
  p_cervena_c:=False;

  for prvok in t_plan do
  begin
    if (p_dopravna=nil) or (prvok.Dopravna=p_dopravna) then
    begin
      if prvok is TKolajCiara then
      begin
        if (prvok.Nazov[False,False]<>'') then
        begin
          if ((prvok as TKolajCiara).Stitok<>'') or ((prvok as TKolajCiara).Vyluka<>'') then
          begin
            if ((prvok as TKolajCiara).Stitok<>'') then
            begin
              if p_text_a<>'' then p_text_a:=p_text_a+';';
              p_text_a:=p_text_a+prvok.Nazov[False,False];
              p_cervena_a:=True;
            end;

            if ((prvok as TKolajCiara).Vyluka<>'') then
            begin
              if p_text_b<>'' then p_text_b:=p_text_b+';';
              p_text_b:=p_text_b+prvok.Nazov[False,False];
              p_cervena_b:=True;
            end;
          end
          else
          begin
            if p_text_c<>'' then p_text_c:=p_text_c+';';
            p_text_c:=p_text_c+prvok.Nazov[False,False];
          end
        end;
      end
      else if prvok is TVyhybka then
      begin
        if ((prvok as TVyhybka).Stitok<>'') or ((prvok as TVyhybka).Vyluka<>'') then
        begin
          if ((prvok as TVyhybka).Stitok<>'') then
          begin
            if p_text_a<>'' then p_text_a:=p_text_a+';';
            p_text_a:=p_text_a+prvok.Nazov[False,False];
            p_cervena_a:=True;
          end;

          if ((prvok as TVyhybka).Vyluka<>'') then
          begin
            if p_text_b<>'' then p_text_b:=p_text_b+';';
            p_text_b:=p_text_b+prvok.Nazov[False,False];
            p_cervena_b:=True;
          end;
        end
        else
        begin
          if p_text_c<>'' then p_text_c:=p_text_c+';';
          p_text_c:=p_text_c+prvok.Nazov[False,False];
        end
      end
      else if prvok is TNavestidlo then
      begin
        if (prvok as TNavestidlo).Stitok<>'' then
        begin
          if p_text_a<>'' then p_text_a:=p_text_a+';';
          p_text_a:=p_text_a+prvok.Nazov[False,False];
          p_cervena_a:=True;
        end
        else
        begin
          if p_text_c<>'' then p_text_c:=p_text_c+';';
          p_text_c:=p_text_c+prvok.Nazov[False,False];
        end
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VypisNudzovyPovelNavestidla(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean);
var
  prvok: TStavadloObjekt;
begin
  p_popis_a:='(A) Stoj';
  p_popis_b:='(B) Voænoznak';
  p_popis_c:='(C) RuËn˝ z·ver';
  p_text_a:='';
  p_text_b:='';
  p_text_c:='';
  p_cervena_a:=False;
  p_cervena_b:=False;
  p_cervena_c:=False;

  for prvok in t_plan do
  begin
    if (prvok is TNavestidlo) and ((p_dopravna=nil) or (prvok.Dopravna=p_dopravna)) then
    begin
      if (prvok as TNavestidlo).RucnyZaver then
      begin
        if p_text_c<>'' then p_text_c:=p_text_c+';';
        p_text_c:=p_text_c+prvok.Nazov[False,False];
        p_cervena_c:=True;
      end
      else if not ((prvok as TNavestidlo).Navest[False] in [CN_STOJ,CN_NEZNAMA]) then
      begin
        if p_text_b<>'' then p_text_b:=p_text_b+';';
        p_text_b:=p_text_b+prvok.Nazov[False,False];
        p_cervena_b:=True;
      end
      else
      begin
        if p_text_a<>'' then p_text_a:=p_text_a+';';
        p_text_a:=p_text_a+prvok.Nazov[False,False];
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VypisNudzovyPovelVyhybky(p_dopravna: TDopravna; out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean);
var
  prvok: TStavadloObjekt;
begin
  p_popis_a:='(A) Bez z·veru';
  p_popis_b:='(B) RuËn˝ z·ver';
  p_popis_c:='(C) Z·ver VC';
  p_text_a:='';
  p_text_b:='';
  p_text_c:='';
  p_cervena_a:=False;
  p_cervena_b:=False;
  p_cervena_c:=False;

  for prvok in t_plan do
  begin
    if (prvok is TVyhybka) and ((p_dopravna=nil) or (prvok.Dopravna=p_dopravna)) then
    begin
      if (not (prvok as TVyhybka).JeVolna(True)) and (not (prvok as TVyhybka).RucnyZaver) then
      begin
        if p_text_c<>'' then p_text_c:=p_text_c+';';
        p_text_c:=p_text_c+prvok.Nazov[False,False];
        p_cervena_c:=True;
      end
      else if (prvok as TVyhybka).RucnyZaver then
      begin
        if p_text_b<>'' then p_text_b:=p_text_b+';';
        p_text_b:=p_text_b+prvok.Nazov[False,False];
        p_cervena_b:=True;
      end
      else
      begin
        if p_text_a<>'' then p_text_a:=p_text_a+';';
        p_text_a:=p_text_a+prvok.Nazov[False,False];
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VyberHint(p_x,p_y: Integer);
var
  perc_x,perc_y: Integer;
  vysledok: TStavadloObjekt;
  hitbox: THitBox;
begin
  perc_x:=((p_x*SirkaPlanu) div Form1.PaintBox1.Width);
  perc_y:=((p_y*VyskaPlanu) div Form1.PaintBox1.Height);

  vysledok:=nil;

  for hitbox in t_hitboxy do
  begin
    if (perc_x>=hitbox.Poloha.Left) and (perc_x<hitbox.Poloha.Right) and (perc_y>=hitbox.Poloha.Top) and (perc_y<hitbox.Poloha.Bottom) then
    begin
       vysledok:=hitbox.Objekt;
       break;
    end;
  end;

  if(t_hint<>vysledok) then
  begin
    t_hint:=vysledok;
    AktualizujPanely;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZrusHint;
begin
  if(t_hint<>nil) then
  begin
    t_hint:=nil;
    AktualizujPanely;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajVolbaStitok(p_objekt: TStavadloObjekt);
begin
  if ((p_objekt is TVyhybka) and ((p_objekt as TVyhybka).Vyluka<>'')) or ((p_objekt is TKolajCiara) and ((p_objekt as TKolajCiara).Vyluka<>'')) then t_nevybavene_stitky.Add(TPair<TStavadloObjekt,Boolean>.Create(p_objekt,True));
  if ((p_objekt is TVyhybka) and ((p_objekt as TVyhybka).Stitok<>'')) or ((p_objekt is TNavestidlo) and ((p_objekt as TNavestidlo).Stitok<>'')) or ((p_objekt is TKolajCiara) and ((p_objekt as TKolajCiara).Stitok<>'')) then t_nevybavene_stitky.Add(TPair<TStavadloObjekt,Boolean>.Create(p_objekt,False));
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.NastavStitok(p_objekt: TPair<TStavadloObjekt,Boolean>);
begin
  if p_objekt.Value then
  begin
    t_je_vyluka:=True;
    t_je_stitok:=False;

    if(p_objekt.Key is TKolajCiara) then Form1.StitokVyluka.Text:=(p_objekt.Key as TKolajCiara).Vyluka
    else Form1.StitokVyluka.Text:=(p_objekt.Key as TVyhybka).Vyluka;

    Form1.PanelSV.Color:=clMaroon;
  end
  else
  begin
    t_je_stitok:=True;
    t_je_vyluka:=False;

    if(p_objekt.Key is TKolajCiara) then Form1.StitokVyluka.Text:=(p_objekt.Key as TKolajCiara).Stitok
    else if(p_objekt.Key is TNavestidlo) then Form1.StitokVyluka.Text:=(p_objekt.Key as TNavestidlo).Stitok
    else Form1.StitokVyluka.Text:=(p_objekt.Key as TVyhybka).Stitok;

    Form1.PanelSV.Color:=clTeal;
  end;

  t_sv_objekt:=p_objekt.Key;
  t_sv_citanie:=True;

  Form1.Label1.Caption:=p_objekt.Key.Nazov[True,False];
  Form1.PanelSV.Visible:=True;
  Form1.StitokVyluka.ReadOnly:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZadajStitok(p_objekt: TStavadloObjekt);
begin
  if(p_objekt is TKolajCiara) or (p_objekt is TNavestidlo) or (p_objekt is TVyhybka) then
  begin
    t_je_stitok:=True;
    t_je_vyluka:=False;
    t_sv_objekt:=p_objekt;
    t_sv_citanie:=False;

    if(p_objekt is TKolajCiara) then Form1.StitokVyluka.Text:=(p_objekt as TKolajCiara).Stitok
    else if(p_objekt is TNavestidlo) then Form1.StitokVyluka.Text:=(p_objekt as TNavestidlo).Stitok
    else Form1.StitokVyluka.Text:=(p_objekt as TVyhybka).Stitok;

    Form1.Label1.Caption:=p_objekt.Nazov[True,False];
    Form1.PanelSV.Color:=clTeal;
    Form1.PanelSV.Visible:=True;
    Form1.StitokVyluka.ReadOnly:=False;
    Form1.StitokVyluka.SetFocus;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZadajVyluku(p_objekt: TStavadloObjekt);
begin
  if(p_objekt is TKolajCiara) or (p_objekt is TNavestidlo) or (p_objekt is TVyhybka) then
  begin
    t_je_vyluka:=True;
    t_je_stitok:=False;
    t_sv_objekt:=p_objekt;
    t_sv_citanie:=False;

    if(p_objekt is TKolajCiara) then Form1.StitokVyluka.Text:=(p_objekt as TKolajCiara).Vyluka
    else Form1.StitokVyluka.Text:=(p_objekt as TVyhybka).Vyluka;

    Form1.Label1.Caption:=p_objekt.Nazov[True,False];
    Form1.PanelSV.Color:=clMaroon;
    Form1.PanelSV.Visible:=True;
    Form1.StitokVyluka.ReadOnly:=False;
    Form1.StitokVyluka.SetFocus;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PotvrdStitokVyluku;
var
  pov_text: string;
begin
  if(t_je_vyluka) then
  begin
    if t_sv_citanie then t_nevybavene_stitky.Delete(0)
    else
    begin
      if(t_sv_objekt is TVyhybka) then pov_text:=(t_sv_objekt as TVyhybka).Vyluka
      else pov_text:=(t_sv_objekt as TKolajCiara).Vyluka;

      if(Form1.StitokVyluka.Text='') and (pov_text<>'') then
      begin
        NastavNudzovyPovel(t_sv_objekt.Dopravna,NPT_ZRUSVYLUKU,t_sv_objekt,NPP_ASDF);
      end
      else
      begin
        if(t_sv_objekt is TVyhybka) then (t_sv_objekt as TVyhybka).NastavVyluku(Form1.StitokVyluka.Text)
        else (t_sv_objekt as TKolajCiara).NastavVyluku(Form1.StitokVyluka.Text);
      end;
    end;
  end
  else if(t_je_stitok) then
  begin
    if t_sv_citanie then t_nevybavene_stitky.Delete(0)
    else
    begin
      if(t_sv_objekt is TVyhybka) then pov_text:=(t_sv_objekt as TVyhybka).Stitok
      else if(t_sv_objekt is TNavestidlo) then pov_text:=(t_sv_objekt as TNavestidlo).Stitok
      else pov_text:=(t_sv_objekt as TKolajCiara).Stitok;

      if(Form1.StitokVyluka.Text='') and (pov_text<>'') then
      begin
        NastavNudzovyPovel(t_sv_objekt.Dopravna,NPT_ZRUSSTITOK,t_sv_objekt,NPP_ENTER);
      end
      else
      begin
        if(t_sv_objekt is TVyhybka) then (t_sv_objekt as TVyhybka).NastavStitok(Form1.StitokVyluka.Text)
        else if(t_sv_objekt is TNavestidlo) then (t_sv_objekt as TNavestidlo).NastavStitok(Form1.StitokVyluka.Text)
        else (t_sv_objekt as TKolajCiara).NastavStitok(Form1.StitokVyluka.Text);
      end;
    end;
  end;

  if t_nevybavene_stitky.Count=0 then
  begin
    t_je_vyluka:=False;
    t_je_stitok:=False;
    Form1.PanelSV.Visible:=False;
  end
  else NastavStitok(t_nevybavene_stitky.First);

  UlozStitkyVyluky;
  AktualizujPanely;
end;


////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.UlozStitkyVyluky;
var
  ciel: TipwXML;
  prvok: TStavadloObjekt;
begin
  ciel:=TipwXML.Create(nil);
  try
    ciel.OutputFile:=t_sv_subor;
    ciel.Overwrite:=True;
    //ciel.WriteXMLDeclaration('1.0',True,False);
    ciel.StartElement('StitkyVyluky','');
    try
      ciel.StartElement('Stitky','');
      try
        for prvok in t_plan do
        begin
          if((prvok is TVyhybka) and ((prvok as TVyhybka).Stitok<>'')) or ((prvok is TNavestidlo) and ((prvok as TNavestidlo).Stitok<>'')) or ((prvok is TKolajCiara) and ((prvok as TKolajCiara).Stitok<>'')) then
          begin
            ciel.StartElement('Stitok','');
            try
              ciel.PutAttr('kodjednotky','',KodJednotkyNaXML(prvok.KodJednotky));
              ciel.PutAttr('cjednotky','',IntToStr(prvok.CisloJednotky));
              if (prvok is TVyhybka) then ciel.PutString((prvok as TVyhybka).Stitok)
              else if (prvok is TNavestidlo) then ciel.PutString((prvok as TNavestidlo).Stitok)
              else ciel.PutString((prvok as TKolajCiara).Stitok);
            finally
              ciel.EndElement;
            end;
          end;
        end;
      finally
        ciel.EndElement;
      end;

      ciel.StartElement('Vyluky','');
      try
        for prvok in t_plan do
        begin
          if((prvok is TVyhybka) and ((prvok as TVyhybka).Vyluka<>'')) or ((prvok is TKolajCiara) and ((prvok as TKolajCiara).Vyluka<>'')) then
          begin
            ciel.StartElement('Vyluka','');
            try
              ciel.PutAttr('kodjednotky','',KodJednotkyNaXML(prvok.KodJednotky));
              ciel.PutAttr('cjednotky','',IntToStr(prvok.CisloJednotky));
              if (prvok is TVyhybka) then ciel.PutString((prvok as TVyhybka).Vyluka)
              else ciel.PutString((prvok as TKolajCiara).Vyluka);
            finally
              ciel.EndElement;
            end;
          end;
        end;
      finally
        ciel.EndElement;
      end;

      ciel.StartElement('Texty','');
      try
        for prvok in t_plan do
        begin
          if (prvok is TText) and ((prvok as TText).DajPredefText<>'') then
          begin
            ciel.StartElement('Text','');
            try
              ciel.PutAttr('kodjednotky','',KodJednotkyNaXML(prvok.KodJednotky));
              ciel.PutAttr('cjednotky','',IntToStr(prvok.CisloJednotky));
              ciel.PutString((prvok as TText).DajPredefText);
            finally
              ciel.EndElement;
            end;
          end;
        end;
      finally
        ciel.EndElement;
      end;

      ciel.StartElement('Dohlady','');
      try
        for prvok in t_plan do
        begin
          if (prvok is TVyhybkaDohlad) and ((prvok as TVyhybkaDohlad).DohladVypnuty) then
          begin
            ciel.StartElement('Dohlad','');
            try
              ciel.PutAttr('kodjednotky','',KodJednotkyNaXML(prvok.KodJednotky));
              ciel.PutAttr('cjednotky','',IntToStr(prvok.CisloJednotky));
            finally
              ciel.EndElement;
            end;
          end;
        end;
      finally
        ciel.EndElement;
      end;

      ciel.StartElement('APNky','');
      try
        for prvok in t_plan do
        begin
          if (prvok is TNavestidloHlavne) and ((prvok as TNavestidloHlavne).APN) then
          begin
            ciel.StartElement('APN','');
            try
              ciel.PutAttr('kodjednotky','',KodJednotkyNaXML(prvok.KodJednotky));
              ciel.PutAttr('cjednotky','',IntToStr(prvok.CisloJednotky));
            finally
              ciel.EndElement;
            end;
          end;
        end;
      finally
        ciel.EndElement;
      end;
    finally
      ciel.EndElement;
    end;
    ciel.Save;
  finally
    ciel.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZrusStitokVyluku;
var
  cesta: TPair<TStavadloObjekt,TCesta>;
begin
  if t_sv_citanie and (t_nevybavene_stitky.Count>0) then
  begin
    if t_stavana_cesta<>nil then
    begin
      for cesta in t_postavene_cesty do
      begin
        if cesta.Value=t_stavana_cesta then
        begin
          if t_je_stitok then VytvorPoruchu(Now,cesta.Key.Dopravna,'Cestu nejde navoliù - ötÌtok');
          if t_je_vyluka then VytvorPoruchu(Now,cesta.Key.Dopravna,'Cestu nejde navoliù - v˝luka');

          t_stavana_cesta.Zrus;
          cesta.Key.ZrusJeZdroj;
          t_postavene_cesty.Remove(cesta.Key);
          break;
        end;
      end;

      t_stavana_cesta:=nil;
    end;

    t_nevybavene_stitky.Clear;
  end;

  t_je_stitok:=False;
  t_je_vyluka:=False;
  t_sv_citanie:=False;
  t_sv_objekt:=nil;

  Form1.PanelSV.Visible:=False;
  UlozStitkyVyluky;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.NastavCas(p_typ: TCasTyp; p_hodnota: TDateTime; p_zrychlenie: Integer);
begin
  t_cas_typ:=p_typ;
  t_cas_hodnota:=p_hodnota;
  t_cas_rychlost:=p_zrychlenie;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.PridajCasZlozka(p_zlozka: TCasZlozka);
begin
  case p_zlozka of
    ZCA_DEN: t_cas_hodnota:=IncDay(t_cas_hodnota,1);
    ZCA_HODINA: t_cas_hodnota:=RecodeHour(t_cas_hodnota,(HourOf(t_cas_hodnota)+1) mod 24);
    ZCA_MINUTA: t_cas_hodnota:=RecodeMinute(t_cas_hodnota,(MinuteOf(t_cas_hodnota)+1) mod 60);
    ZCA_SEKUNDA: t_cas_hodnota:=RecodeSecond(t_cas_hodnota,30);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.UberCasZlozka(p_zlozka: TCasZlozka);
begin
  case p_zlozka of
    ZCA_DEN: t_cas_hodnota:=IncDay(t_cas_hodnota,-1);
    ZCA_HODINA: 
    begin
      if HourOf(t_cas_hodnota)=0 then t_cas_hodnota:=RecodeHour(t_cas_hodnota,23)
      else t_cas_hodnota:=RecodeHour(t_cas_hodnota,(HourOf(t_cas_hodnota)-1) mod 24);

    end;
    ZCA_MINUTA: 
    begin
      if MinuteOf(t_cas_hodnota)=0 then  t_cas_hodnota:=RecodeMinute(t_cas_hodnota,59)
      else t_cas_hodnota:=RecodeMinute(t_cas_hodnota,(MinuteOf(t_cas_hodnota)-1) mod 60);
    end;
    ZCA_SEKUNDA: t_cas_hodnota:=RecodeSecond(t_cas_hodnota,0);
  end;

  if t_cas_hodnota<EncodeDate(2000,1,1) then t_cas_hodnota:=EncodeDate(2000,1,1);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZastavCas;
begin
  t_cas_stoji:=True;
  Timer1Timer(Timer1);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpustiCas;
begin
  t_cas_posledny:=Now;
  t_cas_stoji:=False;
  Timer1Timer(Timer1);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZapniCasOkno;
begin
  t_cas_okno:=True;
  if t_cas_typ=TCA_REALNY then CasDlg.AktualizujCas(t_cas_typ,Now,1,False)
  else CasDlg.AktualizujCas(t_cas_typ,t_cas_hodnota,t_cas_rychlost,t_cas_stoji);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VypniCasOkno;
begin
  t_cas_okno:=False;
end;

////////////////////////////////////////////////////////////////////////////////

end.
