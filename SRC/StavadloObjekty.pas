unit StavadloObjekty;

interface
  uses Graphics, GR32, Generics.Collections;

  type TZaver=(ZVR_NENI,ZVR_RUCNY,ZVR_PREDBEZNY,ZVR_PRESAH,ZVR_POSUNOVA,ZVR_VLAKOVA);
  type TKodJednotky=(KJ_KOLAJCIARA,KJ_NAVESTIDLOZRIADOVACIE,KJ_NAVESTIDLOVCHODOVE,KJ_NAVESTIDLOODCHODOVE,KJ_VYHYBKA,KJ_TEXT,KJ_SULIBRK);

  function KodJednotkyXML(p_text: string): TKodJednotky;
  function KodJednotkyNaSkratku(p_hodnota: TKodJednotky): string;

  //**************************************************************************//

  type TJednotka=record
    KodJednotky: TKodJednotky;
    CisloJednotky: Integer;
  end;

  function Jednotka(p_kodjednotky: TKodJednotky; p_cjednotky: Integer): TJednotka;

  //**************************************************************************//

  type TVyhybkaPozicia=(VPO_NEZNAMA,VPO_ROVNO,VPO_ODBOCKA,VPO_ROVNO_OTAZNIK,VPO_ODBOCKA_OTAZNIK);

  function VyhybkaPoziciaXML(p_text: string): TVyhybkaPozicia;
  function VyhybkaPoziciaNaText(p_text: TVyhybkaPozicia): string;

  //**************************************************************************//

  type TSvetloPozicia=(SPO_NEZNAMA,SPO_ZHASNUTE,SPO_ZHASINA,SPO_ROZSVECUJE,SPO_ROZSVIETENE);

  const SPOS_SVIETI=[SPO_ROZSVECUJE,SPO_ROZSVIETENE];
  const SPOS_NESVIETI=[SPO_ZHASNUTE,SPO_ZHASINA];

  function SvetloPoziciaNaText(p_hodnota: TSvetloPozicia): string;
  function SvetloPoziciaNaSkratku(p_hodnota: TSvetloPozicia): string;

  //**************************************************************************//

  type TNavest=(CN_NEZNAMA,CN_STOJ,CN_POSUN_DOVOLENY,CN_VYSTRAHA,CN_VOLNO,CN_OCAK40,CN_40AVYSTRAHA,CN_40A40,CN_40AVOLNO,CN_PRIVOLAVACKA);

  function NavestNaText(p_hodnota: TNavest): string;

  type TDopravna=class(TObject)
    private
      t_lcislo: Integer;
      t_nazov: string;
      t_skratka: string;
    public
      property Nazov: string read t_nazov;
      property Skratka: string read t_skratka;
      property LCislo: Integer read t_lcislo;

      constructor Create(p_nazov,p_skratka: string; p_lcislo: Integer);
  end;

  //**************************************************************************//
  
  type TStavadloObjekt=class(TObject)
    private
      t_cjednotky: Integer;
      t_je_zdroj: Boolean;
      t_je_zdroj_posun: Boolean;
      t_dopravna: TDopravna;

    protected
      function DajKodJednotky: TKodJednotky; virtual; abstract;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; virtual; abstract;

      function PercentaNaPixely(p_percenta,p_plan_zac,p_plan_kon: Integer): Integer;

    public
      property KodJednotky: TKodJednotky read DajKodJednotky;
      property CisloJednotky: Integer read t_cjednotky;
      property Nazov[KodJednotky: Boolean; Dopravna: Boolean]: string read DajNazov;
      property JeZdroj: Boolean read t_je_zdroj;
      property JeZdrojPosun: Boolean read t_je_zdroj_posun;
      property Dopravna: TDopravna read t_dopravna;

      constructor Create(p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); virtual; abstract;
      function DajJednotku: TJednotka;

      function DajStav: string; virtual;

      procedure NastavJeZdroj(p_posun: Boolean);
      procedure ZrusJeZdroj;
  end;

  //**************************************************************************//

  type TText=class(TStavadloObjekt)
    private
      t_x_zac,t_y_zac: Integer;
      t_text: string;
      t_nastred: Boolean;
      t_velkost: Integer;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_y_zac: Integer; p_text: string; p_velkost: Integer; p_nastred: Boolean; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TSulibrk=class(TStavadloObjekt)
    private
      t_x_zac,t_y_zac: Integer;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_y_zac: Integer; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TKolajCiara=class(TStavadloObjekt)
    private
      t_x_zac,t_x_kon,t_y_zac,t_y_kon: Integer;
      t_cislo: string;
      t_zaver: TZaver;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      property Zaver: TZaver read t_zaver write t_zaver;

      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
      function JeVolna: Boolean;
  end;

  //**************************************************************************//

  type TNavestidlo=class(TStavadloObjekt)
    protected
      t_x_zac,t_x_kon,t_y_zac,t_y_kon: Integer;
      t_cislo: string;

      function DajNavest(p_fyzicky: Boolean): TNavest; virtual; abstract;

    public
      property Navest[Fyzicka: Boolean]: TNavest read DajNavest;

      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer; p_dopravna: TDopravna);

      function RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean; virtual; abstract;

      function ObsahujeAdresu(p_adresa: Integer): Boolean; virtual; abstract;
      procedure NastavPolohu(p_adresa: Integer; p_smer: Boolean); virtual; abstract;

      procedure DajAdresy(p_adresy: TList<Integer>); virtual; abstract;
      procedure Reset(p_povely: TList<TPair<Integer,Boolean>>); virtual; abstract;
  end;

  //**************************************************************************//

  type TNavestidloHlavne=class(TNavestidlo)
    public
      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TVyhybka=class(TStavadloObjekt)
    private
      t_x_hrot,t_y_hrot,t_x_rovno,t_y_rovno,t_x_odboc,t_y_odboc: Integer;
      t_cislo: string;
      t_poloha: TVyhybkaPozicia;
      t_adresa: Integer;
      t_otocit_polaritu: Boolean;
      t_rucny_zaver: Boolean;

      t_kolaj_hrot,t_kolaj_rovno,t_kolaj_odboc: TKolajCiara;

    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      property Adresa: Integer read t_adresa;
      property Pozicia: TVyhybkaPozicia read t_poloha;
      property OtocitPolaritu: Boolean read t_otocit_polaritu;
      property RucnyZaver: Boolean read t_rucny_zaver;

      constructor Create(p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
      procedure NastavPolohuCentrala(p_poloha,p_istota: Boolean);

      function JeVolna: Boolean;

      function DajStav: string; override;

      function NastavRucnyZaver(p_zaver: Boolean; p_potvrd: Boolean): Boolean;
  end;

  //**************************************************************************//

  type TNavestidloVchodoveFarba=(NVF_C,NVF_HZ,NVF_HZ_KMIT,NVF_Z,NVF_B_KMIT,NVF_DZ,NVF_PREDV_HZ,NVF_PREDV_HZ_KMIT,NVF_PREDV_Z);
  const NVFS_VSETKY=[NVF_C,NVF_HZ,NVF_HZ_KMIT,NVF_Z,NVF_B_KMIT,NVF_DZ,NVF_PREDV_HZ,NVF_PREDV_HZ_KMIT,NVF_PREDV_Z];

  function NavestidloVchodoveFarbaNaText(p_hodnota: TNavestidloVchodoveFarba): string;

  type TNavestidloVchodoveAdresy=array[TNavestidloVchodoveFarba] of Integer;

  type TNavestidloVchodove=class(TNavestidloHlavne)
    private
      t_adresy: TNavestidloVchodoveAdresy;
      t_stavy: array[TNavestidloVchodoveFarba] of TSvetloPozicia;

    protected
      function DajNavest(p_fyzicky: Boolean): TNavest; override;
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adresy: TNavestidloVchodoveAdresy; p_cjednotky: Integer; p_dopravna: TDopravna);

      function RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean; override;

      function ObsahujeAdresu(p_adresa: Integer): Boolean; override;
      procedure NastavPolohu(p_adresa: Integer; p_smer: Boolean); override;

      procedure DajAdresy(p_adresy: TList<Integer>); override;
      procedure Reset(p_povely: TList<TPair<Integer,Boolean>>); override;

      function DajStav: string; override;
  end;

  //**************************************************************************//

  type TNavestidloOdchodoveFarba=(NOF_C,NOF_Z,NOF_B,NOF_B_KMIT,NOF_DZ);
  const NOFS_VSETKY=[NOF_C,NOF_Z,NOF_B,NOF_B_KMIT,NOF_DZ];

  function NavestidloOdchodoveFarbaNaText(p_hodnota: TNavestidloOdchodoveFarba): string;

  type TNavestidloOdchodoveAdresy=array[TNavestidloOdchodoveFarba] of Integer;

  type TNavestidloOdchodove=class(TNavestidloHlavne)
    private
      t_spojit_zelenu,t_bez_zltej: Boolean;
      t_adresy: TNavestidloOdchodoveAdresy;
      t_stavy: array[TNavestidloOdchodoveFarba] of TSvetloPozicia;


    protected
      function DajNavest(p_fyzicky: Boolean): TNavest; override;
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_spojit_zelenu,p_bez_zltej: Boolean; p_adresy: TNavestidloOdchodoveAdresy; p_cjednotky: Integer; p_dopravna: TDopravna);

      function RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean; override;

      function ObsahujeAdresu(p_adresa: Integer): Boolean; override;
      procedure NastavPolohu(p_adresa: Integer; p_smer: Boolean); override;

      procedure DajAdresy(p_adresy: TList<Integer>); override;
      procedure Reset(p_povely: TList<TPair<Integer,Boolean>>); override;

      function DajStav: string; override;
  end;

  //**************************************************************************//

  type TNavestidloZriadovacieFarba=(NZF_B,NZF_M);
  const NZFS_VSETKY=[NZF_B,NZF_M];

  function NavestidloZriadovacieFarbaNaText(p_hodnota: TNavestidloZriadovacieFarba): string;

  type TNavestidloZriadovacieAdresy=array[TNavestidloZriadovacieFarba] of Integer;

  type TNavestidloZriadovacie=class(TNavestidlo)
    private
      t_adresy: TNavestidloZriadovacieAdresy;
      t_stavy: array[TNavestidloZriadovacieFarba] of TSvetloPozicia;

    protected
      function DajNavest(p_fyzicky: Boolean): TNavest; override;
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adresy: TNavestidloZriadovacieAdresy; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;

      function RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean; override;

      function ObsahujeAdresu(p_adresa: Integer): Boolean; override;
      procedure NastavPolohu(p_adresa: Integer; p_smer: Boolean); override;

      procedure DajAdresy(p_adresy: TList<Integer>); override;
      procedure Reset(p_povely: TList<TPair<Integer,Boolean>>); override;

      function DajStav: string; override;
  end;

implementation
  uses DateUtils, SysUtils, Types, GR32_Polygons, GR32_Backends;

  function KodJednotkyXML(p_text: string): TKodJednotky;
  begin
    if(p_text='KJ_KOLAJCIARA') then Result:=KJ_KOLAJCIARA
    else if(p_text='KJ_NAVESTIDLOZRIADOVACIE') then Result:=KJ_NAVESTIDLOZRIADOVACIE
    else if(p_text='KJ_NAVESTIDLOVCHODOVE') then Result:=KJ_NAVESTIDLOVCHODOVE
    else if(p_text='KJ_NAVESTIDLOODCHODOVE') then Result:=KJ_NAVESTIDLOODCHODOVE
    else if(p_text='KJ_VYHYBKA') then Result:=KJ_VYHYBKA
    else if(p_text='KJ_TEXT') then Result:=KJ_TEXT
    else if(p_text='KJ_SULIBRK') then Result:=KJ_SULIBRK
    else Result:=KJ_KOLAJCIARA
  end;

  //////////////////////////////////////////////////////////////////////////////

  function KodJednotkyNaSkratku(p_hodnota: TKodJednotky): string;
  begin
    case p_hodnota of
      KJ_KOLAJCIARA: Result:='KOL';
      KJ_NAVESTIDLOZRIADOVACIE: Result:='NZR';
      KJ_NAVESTIDLOVCHODOVE: Result:='NVC';
      KJ_NAVESTIDLOODCHODOVE: Result:='NOD';
      KJ_VYHYBKA: Result:='VYH';
      KJ_TEXT: Result:='TXT';
      KJ_SULIBRK: Result:='SUL';
    end;
  end;

  //**************************************************************************//

  function VyhybkaPoziciaXML(p_text: string): TVyhybkaPozicia;
  begin
    if p_text='VPO_ROVNO' then Result:=VPO_ROVNO
    else if p_text='VPO_ODBOCKA' then Result:=VPO_ODBOCKA
    else if p_text='VPO_ROVNO_OTAZNIK' then Result:=VPO_ROVNO_OTAZNIK
    else if p_text='VPO_ODBOCKA_OTAZNIK' then Result:=VPO_ODBOCKA_OTAZNIK
    else Result:=VPO_NEZNAMA
  end;

  //////////////////////////////////////////////////////////////////////////////

  function VyhybkaPoziciaNaText(p_text: TVyhybkaPozicia): string;
  begin
    case p_text of
      VPO_NEZNAMA: Result:='Neznáma/medzipoloha';
      VPO_ROVNO: Result:='Základná';
      VPO_ODBOCKA: Result:='Odboèná';
      VPO_ROVNO_OTAZNIK: Result:='Základná, bez doh¾adu';
      VPO_ODBOCKA_OTAZNIK: Result:='Odboèná, bez doh¾adu';
    end;
  end;

  //**************************************************************************//

  function SvetloPoziciaNaText(p_hodnota: TSvetloPozicia): string;
  begin
    case p_hodnota of
      SPO_NEZNAMA: Result:='Neznáma';
      SPO_ZHASNUTE: Result:='Nesvieti';
      SPO_ZHASINA: Result:='K zhasnutiu';
      SPO_ROZSVECUJE: Result:='K rozsvieteniu';
      SPO_ROZSVIETENE: Result:='Svieti';
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function SvetloPoziciaNaSkratku(p_hodnota: TSvetloPozicia): string;
  begin
    case p_hodnota of
      SPO_NEZNAMA: Result:='?';
      SPO_ZHASNUTE: Result:='X';
      SPO_ZHASINA: Result:=chr($02C5);
      SPO_ROZSVECUJE: Result:=chr($02C4);
      SPO_ROZSVIETENE: Result:='O';
    end;
  end;


  //**************************************************************************//

  function NavestNaText(p_hodnota: TNavest): string;
  begin
    case p_hodnota of
      CN_NEZNAMA: Result:='Neznáma/pochybná';
      CN_STOJ: Result:='Stoj';
      CN_POSUN_DOVOLENY: Result:='Posun dovolený';
      CN_VYSTRAHA: Result:='Výstraha';
      CN_VOLNO: Result:='Vo¾no';
      CN_OCAK40: Result:='Oèakávaj 40';
      CN_40AVYSTRAHA: Result:='40 a výstraha';
      CN_40A40: Result:='40 a oèakávaj 40';
      CN_40AVOLNO: Result:='40 a vo¾no';
      CN_PRIVOLAVACKA: Result:='Privolávaèka';
    end;
  end;

  //**************************************************************************//

  function Jednotka(p_kodjednotky: TKodJednotky; p_cjednotky: Integer): TJednotka;
  begin
    Result.KodJednotky:=p_kodjednotky;
    Result.CisloJednotky:=p_cjednotky;
  end;

  function VyrobPovel(p_adresa: Integer; p_smer: Boolean): TPair<Integer,Boolean>;
  begin
    Result.Key:=p_adresa;
    Result.Value:=p_smer;
  end;


  //**************************************************************************//

  constructor TDopravna.Create(p_nazov,p_skratka: string; p_lcislo: Integer);
  begin
    t_nazov:=p_nazov;
    t_skratka:=p_skratka;
    t_lcislo:=p_lcislo;
  end;

  //**************************************************************************//

  constructor TStavadloObjekt.Create(p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    t_cjednotky:=p_cjednotky;
    t_dopravna:=p_dopravna;
    t_je_zdroj:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.PercentaNaPixely(p_percenta,p_plan_zac,p_plan_kon: Integer): Integer;
  var
    sirka: Integer;
  begin
    sirka:=p_plan_kon-p_plan_zac;
    Result:=(p_percenta*sirka) div 110;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.DajJednotku: TJednotka;
  begin
    Result:=Jednotka(KodJednotky,CisloJednotky);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.DajStav: string;
  begin
    Result:='Stav prvku není k dispozici';
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TStavadloObjekt.NastavJeZdroj(p_posun: Boolean);
  begin
    t_je_zdroj:=True;
    t_je_zdroj_posun:=p_posun;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TStavadloObjekt.ZrusJeZdroj;
  begin
    t_je_zdroj:=False;
    t_je_zdroj_posun:=False;
  end;

  //**************************************************************************//

  constructor TText.Create(p_x_zac,p_y_zac: Integer; p_text: string; p_velkost: Integer; p_nastred: Boolean; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);

    t_x_zac:=p_x_zac;
    t_y_zac:=p_y_zac;
    t_text:=p_text;
    t_nastred:=p_nastred;
    t_velkost:=p_velkost;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TText.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y: Integer;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon);

    p_plan.Font.Color:=clWhite;
    p_plan.Font.Size:=t_velkost;

    if t_nastred then
    begin
      zac_x:=zac_x-(p_plan.TextWidth(t_text) div 2);
      zac_y:=zac_y-(p_plan.TextHeight(t_text) div 2);
    end;

    p_plan.TextOut(zac_x,zac_y,t_text);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_TEXT;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Textový prvok ';
    Result:=Result+t_text;
  end;

  //**************************************************************************//

  constructor TSulibrk.Create(p_x_zac,p_y_zac: Integer; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);

    t_x_zac:=p_x_zac;
    t_y_zac:=p_y_zac;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TSulibrk.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_SULIBRK;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TSulibrk.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y: Integer;
    rozmer: Integer;
    i: Extended;
    A1,A2,B1,B2,C1,C2: TPoint;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon);

    rozmer:=20;

    i:=2*PI/20*(SecondOf(Now) mod 20);

    A2.X:=Round(rozmer*Sin(2*PI/6*1+i));
    A1.X:=Round(rozmer*Sin(2*PI/6*0+i));

    A2.Y:=Round(rozmer*Cos(2*PI/6*1+i));
    A1.Y:=Round(rozmer*Cos(2*PI/6*0+i));

    B1.X:=Round(rozmer*Sin(2*PI/6*2+i));
    B2.X:=Round(rozmer*Sin(2*PI/6*3+i));

    B1.Y:=Round(rozmer*Cos(2*PI/6*2+i));
    B2.Y:=Round(rozmer*Cos(2*PI/6*3+i));

    C2.X:=Round(rozmer*Sin(2*PI/6*5+i));
    C1.X:=Round(rozmer*Sin(2*PI/6*4+i));

    C2.Y:=Round(rozmer*Cos(2*PI/6*5+i));
    C1.Y:=Round(rozmer*Cos(2*PI/6*4+i));

    p_plan.Canvas.Pen.Width:=1;

    p_plan.Canvas.Pen.Color:=clSilver;
    p_plan.Canvas.Brush.Color:=clRed;

    p_plan.Canvas.Pie(zac_x-rozmer,zac_y-rozmer,zac_x+rozmer,zac_y+rozmer,zac_x+A1.X,zac_y+A1.Y,zac_x+A2.X,zac_y+A2.Y);

    p_plan.Canvas.Pen.Color:=clSilver;
    p_plan.Canvas.Brush.Color:=clLime;

    p_plan.Canvas.Pie(zac_x-rozmer,zac_y-rozmer,zac_x+rozmer,zac_y+rozmer,zac_x+B1.X,zac_y+B1.Y,zac_x+B2.X,zac_y+B2.Y);

    p_plan.Canvas.Pen.Color:=clSilver;
    p_plan.Canvas.Brush.Color:=clBlue;

    p_plan.Canvas.Pie(zac_x-rozmer,zac_y-rozmer,zac_x+rozmer,zac_y+rozmer,zac_x+C1.X,zac_y+C1.Y,zac_x+C2.X,zac_y+C2.Y);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TSulibrk.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    Result:=Result+'Kontrolný prvok';
  end;

  //**************************************************************************//

  constructor TKolajCiara.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);

    t_x_zac:=p_x_zac;
    t_x_kon:=p_x_kon;
    t_y_zac:=p_y_zac;
    t_y_kon:=p_y_kon;
    t_cislo:=p_cislo;
    t_zaver:=ZVR_NENI;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TKolajCiara.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_KOLAJCIARA;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TKolajCiara.JeVolna: Boolean;
  begin
    Result:=t_zaver=ZVR_NENI;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure VykresliHrubuCiaru(p_plan: TBitmap32; p_hrubka: Integer; p_zac_x,p_zac_y,p_kon_x,p_kon_y: Integer; p_farba: TColor32);
  var
    polygon,obal,outline: TPolygon32;
  begin
    polygon:=TPolygon32.Create;
    try
      polygon.Add(FixedPoint(p_zac_x,p_zac_y));
      polygon.Add(FixedPoint(p_kon_x,p_kon_y));
      polygon.Closed:=False;
      obal:=polygon.Outline;
      obal.Closed:=False;
      try
        outline:=obal.Grow(Fixed((p_hrubka+1)*0.35),0.1);
        try
          outline.Antialiased:=True;
          outline.FillMode:=pfWinding;
          outline.AntialiasMode:=am8times;
          outline.Closed:=False;
          outline.DrawFill(p_plan,p_farba);
        finally
          outline.Free;
        end;
      finally
        obal.Free;
      end;
    finally
      polygon.Free;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TKolajCiara.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    farba: TColor32;
    hrubka: Integer;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    kon_x:=PercentaNaPixely(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_y:=PercentaNaPixely(t_y_kon,p_plan_y_zac,p_plan_y_kon);

    if t_zaver in [ZVR_RUCNY,ZVR_PREDBEZNY] then farba:=clAqua32
    else if t_zaver=ZVR_VLAKOVA then farba:=clLime32
    else if t_zaver=ZVR_POSUNOVA then farba:=clWhite32
    else farba:=clGray32;

    if JeZdroj then hrubka:=13
    else hrubka:=5;

    VykresliHrubuCiaru(p_plan,hrubka,zac_x,zac_y,kon_x,kon_y,farba);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TKolajCiara.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Ko¾aj ';

    Result:=Result+t_cislo;
  end;

  //**************************************************************************//

  constructor TNavestidlo.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);

    t_x_zac:=p_x_zac;
    t_x_kon:=p_x_kon;
    t_y_zac:=p_y_zac;
    t_y_kon:=p_y_kon;
    t_cislo:=p_cislo;
  end;

  //**************************************************************************//

  procedure TNavestidloHlavne.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    v_navest: TNavest;
    polygon,obal,outline: TPolygon32;
    obrys,vypln: TColor32;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    kon_x:=PercentaNaPixely(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_y:=PercentaNaPixely(t_y_kon,p_plan_y_zac,p_plan_y_kon);

    v_navest:=DajNavest(True);

    if v_navest=CN_STOJ then vypln:=clGray32
    else if v_navest=CN_NEZNAMA then vypln:=clBlack32
    else if v_navest=CN_PRIVOLAVACKA then vypln:=clAqua32
    else if v_navest=CN_POSUN_DOVOLENY then vypln:=clWhite32
    else vypln:=clLime32;

    if t_je_zdroj then
    begin
      if t_je_zdroj_posun then obrys:=clWhite32
      else obrys:=clLime32;
    end
    else obrys:=clGray32;

    polygon:=TPolygon32.Create;
    try
      polygon.Closed:=True;

      polygon.Add(FixedPoint(zac_x,zac_y));
      polygon.Add(FixedPoint(zac_x,kon_y));
      polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2));

      polygon.Antialiased:=True;
      polygon.FillMode:=pfWinding;
      polygon.AntialiasMode:=am8times;
      polygon.DrawFill(p_plan,vypln);

      obal:=polygon.Outline;
      obal.Closed:=True;
      try
        outline:=obal.Grow(Fixed(4*0.35),0.1);
        try
          outline.Antialiased:=True;
          outline.FillMode:=pfWinding;
          outline.AntialiasMode:=am8times;
          outline.Closed:=False;
          outline.DrawFill(p_plan,obrys)
        finally
          outline.Free;
        end;
      finally
        obal.Free;
      end;
    finally
      polygon.Free;
    end;
  end;
  
  //**************************************************************************//

  constructor TVyhybka.Create(p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);
  
    t_x_hrot:=p_x_hrot;
    t_y_hrot:=p_y_hrot;
    t_x_rovno:=p_x_rovno;
    t_y_rovno:=p_y_rovno;
    t_x_odboc:=p_x_odboc;
    t_y_odboc:=p_y_odboc;
    t_cislo:=p_cislo;
    t_poloha:=VPO_NEZNAMA;
    t_adresa:=p_adresa;
    t_otocit_polaritu:=p_otocit_pohohu;
    t_kolaj_hrot:=p_kolaj_hrot;
    t_kolaj_rovno:=p_kolaj_rovno;
    t_kolaj_odboc:=p_kolaj_odboc;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_VYHYBKA;  
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    hrot_x,rovno_x,odboc_x,hrot_y,rovno_y,odboc_y: Integer;
    kolaj_zaver: TKolajCiara;
    farba: TColor32;
  begin
    hrot_x:=PercentaNaPixely(t_x_hrot,p_plan_x_zac,p_plan_x_kon);
    rovno_x:=PercentaNaPixely(t_x_rovno,p_plan_x_zac,p_plan_x_kon);
    odboc_x:=PercentaNaPixely(t_x_odboc,p_plan_x_zac,p_plan_x_kon);
    hrot_y:=PercentaNaPixely(t_y_hrot,p_plan_y_zac,p_plan_y_kon);
    rovno_y:=PercentaNaPixely(t_y_rovno,p_plan_y_zac,p_plan_y_kon);
    odboc_y:=PercentaNaPixely(t_y_odboc,p_plan_y_zac,p_plan_y_kon);

    if t_rucny_zaver then farba:=clAqua32
    else
    begin
      if t_poloha in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then kolaj_zaver:=t_kolaj_rovno
      else if t_poloha in [VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then kolaj_zaver:=t_kolaj_odboc
      else kolaj_zaver:=nil;

      if(kolaj_zaver<>nil) and (kolaj_zaver.Zaver=ZVR_POSUNOVA) then farba:=clWhite32
      else if(kolaj_zaver<>nil) and (kolaj_zaver.Zaver=ZVR_VLAKOVA) then farba:=clLime32
      else
      begin
        if t_poloha in [VPO_ROVNO_OTAZNIK,VPO_ODBOCKA_OTAZNIK] then farba:=clYellow32
        else farba:=clGray32;
      end;
    end;

    if t_poloha in [VPO_NEZNAMA,VPO_ROVNO,VPO_ROVNO_OTAZNIK] then VykresliHrubuCiaru(p_plan,5,hrot_x,hrot_y,rovno_x,rovno_y,farba);

    if t_poloha in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then VykresliHrubuCiaru(p_plan,5,hrot_x,hrot_y,odboc_x,odboc_y,farba);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Výhybka ';
    Result:=Result+t_cislo;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.NastavPolohuCentrala(p_poloha,p_istota: Boolean);
  begin
    if p_istota then
    begin
      if t_otocit_polaritu then
      begin
        if p_poloha then t_poloha:=VPO_ODBOCKA
        else t_poloha:=VPO_ROVNO;
      end
      else
      begin
        if p_poloha then t_poloha:=VPO_ROVNO
        else t_poloha:=VPO_ODBOCKA;
      end;
    end
    else if t_poloha=VPO_NEZNAMA then
    begin
      if t_otocit_polaritu then
      begin
        if p_poloha then t_poloha:=VPO_ODBOCKA_OTAZNIK
        else t_poloha:=VPO_ROVNO_OTAZNIK;
      end
      else
      begin
        if p_poloha then t_poloha:=VPO_ROVNO_OTAZNIK
        else t_poloha:=VPO_ODBOCKA_OTAZNIK;
      end;    
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.JeVolna: Boolean;
  begin
    Result:=(not t_rucny_zaver) and ((t_kolaj_hrot=nil) or (t_kolaj_hrot.JeVolna)) and ((t_kolaj_rovno=nil) or (t_kolaj_rovno.JeVolna)) and ((t_kolaj_odboc=nil) or (t_kolaj_odboc.JeVolna))
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajStav: string;
  begin
    Result:='Poloha: '+VyhybkaPoziciaNaText(t_poloha)+' Ruè. záver: '+BoolToStr(t_rucny_zaver,True);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.NastavRucnyZaver(p_zaver: Boolean; p_potvrd: Boolean): Boolean;
  begin
    Result:=True;

    if p_zaver then
    begin
      t_rucny_zaver:=True;
      if t_poloha=VPO_ROVNO_OTAZNIK then t_poloha:=VPO_ROVNO;
      if t_poloha=VPO_ODBOCKA_OTAZNIK then t_poloha:=VPO_ODBOCKA;
    end
    else
    begin
      if p_potvrd then t_rucny_zaver:=False
      else
      begin

      end;
    end;

  end;

  //**************************************************************************//

  function NavestidloVchodoveFarbaNaText(p_hodnota: TNavestidloVchodoveFarba): string;
  begin
    case p_hodnota of
      NVF_C: Result:='È';
      NVF_HZ: Result:='HŽ';
      NVF_HZ_KMIT: Result:='HŽ kmit';
      NVF_Z: Result:='Z';
      NVF_B_KMIT: Result:='B kmit';
      NVF_DZ: Result:='DŽ';
      NVF_PREDV_HZ: Result:='pHŽ';
      NVF_PREDV_HZ_KMIT: Result:='pHŽ kmit';
      NVF_PREDV_Z: Result:='pZ';
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  constructor TNavestidloVchodove.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adresy: TNavestidloVchodoveAdresy; p_cjednotky: Integer; p_dopravna: TDopravna);
  var
    i: TNavestidloVchodoveFarba;
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky,p_dopravna);

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      t_adresy[i]:=p_adresy[i];
      t_stavy[i]:=SPO_NEZNAMA;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_NAVESTIDLOVCHODOVE;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.DajStav: string;
  var
    farba: TNavestidloVchodoveFarba;
  begin
    Result:='';

    for farba := Low(t_stavy) to High(t_stavy) do
    begin
      if Result<>'' then Result:=Result+'; ';
      Result:=Result+NavestidloVchodoveFarbaNaText(farba)+': '+SvetloPoziciaNaSkratku(t_stavy[farba]);
    end;
  end;


  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.DajNavest(p_fyzicky: Boolean): TNavest;
  var
    i: TNavestidloVchodoveFarba;
    svietia: set of TNavestidloVchodoveFarba;
  begin
    svietia:=[];

    for i := Low(t_stavy) to High(t_stavy) do
    begin
      if t_stavy[i]=SPO_NEZNAMA then
      begin
        Result:=CN_NEZNAMA;
        Exit;
      end
      else if (t_stavy[i]=SPO_ROZSVIETENE) or ((not p_fyzicky) and (t_stavy[i] in SPOS_SVIETI)) then svietia:=svietia+[i];
    end;

    if svietia=[NVF_C,NVF_PREDV_HZ] then Result:=CN_STOJ
    else if svietia=[NVF_HZ,NVF_PREDV_Z] then Result:=CN_VYSTRAHA
    else if svietia=[NVF_HZ_KMIT,NVF_PREDV_Z] then Result:=CN_OCAK40
    else if svietia=[NVF_Z,NVF_PREDV_Z] then Result:=CN_VOLNO
    else if svietia=[NVF_Z,NVF_DZ,NVF_PREDV_HZ_KMIT] then Result:=CN_40AVOLNO
    else if svietia=[NVF_HZ_KMIT,NVF_DZ,NVF_PREDV_HZ_KMIT] then Result:=CN_40A40
    else if svietia=[NVF_HZ,NVF_DZ,NVF_PREDV_HZ_KMIT] then Result:=CN_40AVYSTRAHA
    else if svietia=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ] then Result:=CN_PRIVOLAVACKA
    else Result:=CN_NEZNAMA;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.ObsahujeAdresu(p_adresa: Integer): Boolean;
  var
    i: TNavestidloVchodoveFarba;
  begin
    Result:=False;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if(t_adresy[i]=p_adresa) then
      begin
        Result:=True;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean;
  var
    rozsvietene: set of TNavestidloVchodoveFarba;
    i: TNavestidloVchodoveFarba;
  begin
    case p_navest of
      CN_STOJ:
      begin
        rozsvietene:=[NVF_C,NVF_PREDV_HZ];
        Result:=True;
      end;
      CN_VYSTRAHA:
      begin
        rozsvietene:=[NVF_HZ,NVF_PREDV_Z];
        Result:=True;
      end;
      CN_VOLNO:
      begin
        rozsvietene:=[NVF_Z,NVF_PREDV_Z];
        Result:=True;
      end;
      CN_OCAK40:
      begin
        rozsvietene:=[NVF_HZ_KMIT,NVF_PREDV_Z];
        Result:=True;
      end;
      CN_40AVYSTRAHA:
      begin
        rozsvietene:=[NVF_HZ,NVF_DZ,NVF_PREDV_HZ_KMIT];
        Result:=True;
      end;
      CN_40A40:
      begin
        rozsvietene:=[NVF_HZ_KMIT,NVF_DZ,NVF_PREDV_HZ_KMIT];
        Result:=True;
      end;
      CN_40AVOLNO:
      begin
        rozsvietene:=[NVF_Z,NVF_DZ,NVF_PREDV_HZ_KMIT];
        Result:=True;
      end;
      CN_PRIVOLAVACKA:
      begin
        rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        Result:=True;
      end;
      else Result:=False;
    end;

    if Result then
    begin
      for i := Low(t_stavy) to High(t_stavy) do
      begin
        if (i in rozsvietene) and (not (t_stavy[i] in SPOS_SVIETI)) then
        begin
          p_povely.Add(VyrobPovel(t_adresy[i],True));
          t_stavy[i]:=SPO_ROZSVECUJE;
        end
        else if (not (i in rozsvietene)) and (not (t_stavy[i] in SPOS_NESVIETI)) then
        begin
          p_povely.Add(VyrobPovel(t_adresy[i],False));
          t_stavy[i]:=SPO_ZHASINA;
        end;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloVchodove.NastavPolohu(p_adresa: Integer; p_smer: Boolean);
  var
    poloha: TSvetloPozicia;
    i: TNavestidloVchodoveFarba;
  begin
    if p_smer then poloha:=SPO_ROZSVIETENE else poloha:=SPO_ZHASNUTE;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if(t_adresy[i]=p_adresa) then
      begin
        t_stavy[i]:=poloha;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloVchodove.DajAdresy(p_adresy: TList<Integer>);
  var
    i: TNavestidloVchodoveFarba;
  begin
    for i := Low(t_adresy) to High(t_adresy) do p_adresy.Add(t_adresy[i]);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloVchodove.Reset(p_povely: TList<TPair<Integer,Boolean>>);
  var
    i: TNavestidloVchodoveFarba;
  begin
    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if i in [NVF_C,NVF_PREDV_HZ] then
      begin
        p_povely.Add(VyrobPovel(t_adresy[i],True));
        t_stavy[i]:=SPO_ROZSVECUJE;
      end
      else
      begin
        p_povely.Add(VyrobPovel(t_adresy[i],False));
        t_stavy[i]:=SPO_ZHASINA;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Náv. vch. ';
    Result:=Result+t_cislo;
  end;

  //**************************************************************************//

  function NavestidloOdchodoveFarbaNaText(p_hodnota: TNavestidloOdchodoveFarba): string;
  begin
    case p_hodnota of
      NOF_C: Result:='È';
      NOF_Z: Result:='Z';
      NOF_B: Result:='B';
      NOF_B_KMIT: Result:='B kmit';
      NOF_DZ: Result:='DŽ';
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  constructor TNavestidloOdchodove.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_spojit_zelenu,p_bez_zltej: Boolean; p_adresy: TNavestidloOdchodoveAdresy; p_cjednotky: Integer; p_dopravna: TDopravna);
  var
    i: TNavestidloOdchodoveFarba;
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky,p_dopravna);

    t_spojit_zelenu:=p_spojit_zelenu;
    t_bez_zltej:=p_bez_zltej;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      t_adresy[i]:=p_adresy[i];
      t_stavy[i]:=SPO_NEZNAMA;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_NAVESTIDLOODCHODOVE;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.DajNavest(p_fyzicky: Boolean): TNavest;
  var
    i: TNavestidloOdchodoveFarba;
    svietia: set of TNavestidloOdchodoveFarba;
  begin
    svietia:=[];

    for i := Low(t_stavy) to High(t_stavy) do
    begin
      if ((not t_bez_zltej) or (i<>NOF_DZ)) and (t_stavy[i]=SPO_NEZNAMA) then
      begin
        Result:=CN_NEZNAMA;
        Exit;
      end
      else if (t_stavy[i]=SPO_ROZSVIETENE) or ((not p_fyzicky) and (t_stavy[i] in SPOS_SVIETI)) then svietia:=svietia+[i];
    end;

    if svietia=[NOF_C] then Result:=CN_STOJ
    else if svietia=[NOF_Z] then Result:=CN_VOLNO
    else if svietia=[NOF_Z,NOF_DZ] then Result:=CN_40AVOLNO
    else if svietia=[NOF_B] then Result:=CN_POSUN_DOVOLENY
    else if svietia=[NOF_C,NOF_B_KMIT] then Result:=CN_PRIVOLAVACKA
    else Result:=CN_NEZNAMA;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Náv. odch. ';
    Result:=Result+t_cislo;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean;
  var
    rozsvietene: set of TNavestidloOdchodoveFarba;
    i: TNavestidloOdchodoveFarba;
  begin
    case p_navest of
      CN_STOJ:
      begin
        rozsvietene:=[NOF_C];
        Result:=True;
      end;
      CN_VOLNO:
      begin
        rozsvietene:=[NOF_Z];
        Result:=True;
      end;
      CN_40AVOLNO:
      begin
        rozsvietene:=[NOF_Z,NOF_DZ];
        Result:=True;
      end;
      CN_POSUN_DOVOLENY:
      begin
        rozsvietene:=[NOF_B];
        Result:=True;
      end;
      CN_PRIVOLAVACKA:
      begin
        rozsvietene:=[NOF_C,NOF_B_KMIT];
        Result:=True;
      end;
      else Result:=False;
    end;

    if Result then
    begin
      for i := Low(t_stavy) to High(t_stavy) do
      begin
        if (i in rozsvietene) and (not (t_stavy[i] in SPOS_SVIETI)) then
        begin
          if ((not t_spojit_zelenu) or (i<>NOF_Z)) and ((not t_bez_zltej) or (i<>NOF_DZ)) then p_povely.Add(VyrobPovel(t_adresy[i],True));
          if ((not t_bez_zltej) or (i<>NOF_DZ)) then t_stavy[i]:=SPO_ROZSVECUJE;
        end
        else if (not (i in rozsvietene)) and (not (t_stavy[i] in SPOS_NESVIETI)) then
        begin
          if ((not t_spojit_zelenu) or (i<>NOF_Z)) and ((not t_bez_zltej) or (i<>NOF_DZ)) then p_povely.Add(VyrobPovel(t_adresy[i],False));
          if ((not t_bez_zltej) or (i<>NOF_DZ)) then t_stavy[i]:=SPO_ZHASINA;
        end;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.ObsahujeAdresu(p_adresa: Integer): Boolean;
  var
    i: TNavestidloOdchodoveFarba;
  begin
    Result:=False;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if t_adresy[i]=p_adresa then
      begin
        Result:=True;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloOdchodove.NastavPolohu(p_adresa: Integer; p_smer: Boolean);
  var
    poloha: TSvetloPozicia;
    i: TNavestidloOdchodoveFarba;
  begin
    if p_smer then poloha:=SPO_ROZSVIETENE else poloha:=SPO_ZHASNUTE;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if t_adresy[i]=p_adresa then
      begin
        t_stavy[i]:=poloha;

        if(i=NOF_DZ) and t_spojit_zelenu then t_stavy[NOF_Z]:=poloha
        else if(i=NOF_Z) and t_spojit_zelenu then t_stavy[NOF_DZ]:=poloha;

        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloOdchodove.DajAdresy(p_adresy: TList<Integer>);
  var
    i: TNavestidloOdchodoveFarba;
  begin
    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if (not t_spojit_zelenu) or (i<>NOF_Z) then p_adresy.Add(t_adresy[i]);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloOdchodove.Reset(p_povely: TList<TPair<Integer,Boolean>>);
  var
    i: TNavestidloOdchodoveFarba;
  begin
    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if i=NOF_C then
      begin
        p_povely.Add(VyrobPovel(t_adresy[i],True));
        t_stavy[i]:=SPO_ROZSVECUJE;
      end
      else
      begin
        if(not t_spojit_zelenu) or (i<>NOF_Z) then p_povely.Add(VyrobPovel(t_adresy[i],False));
        t_stavy[i]:=SPO_ZHASINA;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.DajStav: string;
  var
    farba: TNavestidloOdchodoveFarba;
  begin
    Result:='';

    for farba := Low(t_stavy) to High(t_stavy) do
    begin
      if Result<>'' then Result:=Result+'; ';
      Result:=Result+NavestidloOdchodoveFarbaNaText(farba)+': '+SvetloPoziciaNaSkratku(t_stavy[farba]);
    end;
  end;

  //**************************************************************************//

  function NavestidloZriadovacieFarbaNaText(p_hodnota: TNavestidloZriadovacieFarba): string;
  begin
    case p_hodnota of
      NZF_B: Result:='B';
      NZF_M: Result:='M';
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  constructor TNavestidloZriadovacie.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adresy: TNavestidloZriadovacieAdresy; p_cjednotky: Integer; p_dopravna: TDopravna);
  var
    i: TNavestidloZriadovacieFarba;
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky,p_dopravna);

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      t_adresy[i]:=p_adresy[i];
      t_stavy[i]:=SPO_NEZNAMA;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_NAVESTIDLOZRIADOVACIE;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.DajNavest(p_fyzicky: Boolean): TNavest;
  var
    i: TNavestidloZriadovacieFarba;
    svietia: set of TNavestidloZriadovacieFarba;
  begin
    svietia:=[];

    for i := Low(t_stavy) to High(t_stavy) do
    begin
      if t_stavy[i]=SPO_NEZNAMA then
      begin
        Result:=CN_NEZNAMA;
        Exit;
      end
      else if (t_stavy[i]=SPO_ROZSVIETENE) or ((not p_fyzicky) and (t_stavy[i] in SPOS_SVIETI)) then svietia:=svietia+[i];
    end;

    if svietia=[NZF_M] then Result:=CN_STOJ
    else if svietia=[NZF_B] then Result:=CN_POSUN_DOVOLENY
    else Result:=CN_NEZNAMA;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloZriadovacie.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    polygon,obal,outline: TPolygon32;
    obrys,vypln: TColor32;
    sirka: Integer;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    kon_x:=PercentaNaPixely(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_y:=PercentaNaPixely(t_y_kon,p_plan_y_zac,p_plan_y_kon);

    sirka:=abs(kon_x-zac_x) div 3;

    if(t_je_zdroj) then obrys:=clWhite32
    else obrys:=clGray32;


    if DajNavest(True)=CN_STOJ then vypln:=clGray32
    else if DajNavest(True)<>CN_NEZNAMA then vypln:=clWhite32
    else vypln:=clBlack32;

    polygon:=TPolygon32.Create;
    try
      polygon.Closed:=True;

      if(zac_x<kon_x) then
      begin
        polygon.Add(FixedPoint(zac_x,zac_y));
        polygon.Add(FixedPoint(zac_X+sirka,zac_y));
        polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2));
        polygon.Add(FixedPoint(zac_x+sirka,kon_y));
        polygon.Add(FixedPoint(zac_x,kon_y));
        polygon.Add(FixedPoint(kon_x-sirka,(zac_y+kon_y) div 2));
      end
      else
      begin
        polygon.Add(FixedPoint(zac_x,zac_y));
        polygon.Add(FixedPoint(zac_x-sirka,zac_y));
        polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2));
        polygon.Add(FixedPoint(zac_x-sirka,kon_y));
        polygon.Add(FixedPoint(zac_x,kon_y));
        polygon.Add(FixedPoint(kon_x+sirka,(zac_y+kon_y) div 2));
      end;

      polygon.Antialiased:=True;
      polygon.FillMode:=pfAlternate;
      polygon.AntialiasMode:=am8times;
      polygon.DrawFill(p_plan,vypln);

      obal:=polygon.Outline;
      obal.Closed:=True;
      try
        outline:=obal.Grow(Fixed(4*0.35),0.1);
        try
          outline.Antialiased:=True;
          outline.FillMode:=pfWinding;
          outline.AntialiasMode:=am8times;
          outline.Closed:=False;
          outline.DrawFill(p_plan,obrys)
        finally
          outline.Free;
        end;
      finally
        obal.Free;
      end;
    finally
      polygon.Free;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Náv. zr. ';
    Result:=Result+t_cislo;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean;
  var
    rozsvietene: set of TNavestidloZriadovacieFarba;
    i: TNavestidloZriadovacieFarba;
  begin
    case p_navest of
      CN_STOJ:
      begin
        rozsvietene:=[NZF_M];
        Result:=True;
      end;
      CN_POSUN_DOVOLENY:
      begin
        rozsvietene:=[NZF_B];
        Result:=True;
      end;
      else Result:=False;
    end;

    if Result then
    begin
      for i := Low(t_stavy) to High(t_stavy) do
      begin
        if (i in rozsvietene) and (not (t_stavy[i] in SPOS_SVIETI)) then
        begin
          p_povely.Add(VyrobPovel(t_adresy[i],True));
          t_stavy[i]:=SPO_ROZSVECUJE;
        end
        else if (not (i in rozsvietene)) and (not (t_stavy[i] in SPOS_NESVIETI)) then
        begin
          p_povely.Add(VyrobPovel(t_adresy[i],False));
          t_stavy[i]:=SPO_ZHASINA;
        end;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.ObsahujeAdresu(p_adresa: Integer): Boolean;
  var
    i: TNavestidloZriadovacieFarba;
  begin
    Result:=False;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if t_adresy[i]=p_adresa then
      begin
        Result:=True;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloZriadovacie.NastavPolohu(p_adresa: Integer; p_smer: Boolean);
  var
    poloha: TSvetloPozicia;
    i: TNavestidloZriadovacieFarba;
  begin
    if p_smer then poloha:=SPO_ROZSVIETENE else poloha:=SPO_ZHASNUTE;

    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if t_adresy[i]=p_adresa then
      begin
        t_stavy[i]:=poloha;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloZriadovacie.DajAdresy(p_adresy: TList<Integer>);
  var
    i: TNavestidloZriadovacieFarba;
  begin
    for i := Low(t_adresy) to High(t_adresy) do p_adresy.Add(t_adresy[i]);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloZriadovacie.Reset(p_povely: TList<TPair<Integer,Boolean>>);
  var
    i: TNavestidloZriadovacieFarba;
  begin
    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if i=NZF_M then
      begin
        p_povely.Add(VyrobPovel(t_adresy[i],True));
        t_stavy[i]:=SPO_ROZSVECUJE;
      end
      else
      begin
        p_povely.Add(VyrobPovel(t_adresy[i],False));
        t_stavy[i]:=SPO_ZHASINA;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.DajStav: string;
  var
    farba: TNavestidloZriadovacieFarba;
  begin
    Result:='';

    for farba := Low(t_stavy) to High(t_stavy) do
    begin
      if Result<>'' then Result:=Result+'; ';
      Result:=Result+NavestidloZriadovacieFarbaNaText(farba)+': '+SvetloPoziciaNaText(t_stavy[farba]);
    end;
  end;

end.
