unit StavadloObjekty;

interface
  uses Graphics, GR32, Generics.Collections;

  type TZaver=(ZVR_NENI,ZVR_RUCNY,ZVR_PREDBEZNY,ZVR_PRESAH,ZVR_POSUNOVA,ZVR_VLAKOVA);

  function ZaverText(p_hodnota: TZaver): string;

  type TKodJednotky=(KJ_KOLAJCIARA,KJ_NAVESTIDLOZRIADOVACIE,KJ_NAVESTIDLOVCHODOVE,KJ_NAVESTIDLOODCHODOVE,KJ_VYHYBKA,KJ_TEXT,KJ_SULIBRK,KJ_STANOB,KJ_NASTUPISTE);

  function KodJednotkyXML(p_popis: string): TKodJednotky;
  function KodJednotkyNaXML(p_popis: TKodJednotky): string;
  function KodJednotkyNaSkratku(p_hodnota: TKodJednotky): string;

  //**************************************************************************//

  type TJednotka=record
    KodJednotky: TKodJednotky;
    CisloJednotky: Integer;
  end;

  function Jednotka(p_kodjednotky: TKodJednotky; p_cjednotky: Integer): TJednotka;

  //**************************************************************************//

  type TVyhybkaPozicia=(VPO_NEZNAMA,VPO_ROVNO,VPO_ODBOCKA,VPO_ROVNO_OTAZNIK,VPO_ODBOCKA_OTAZNIK);

  function VyhybkaPoziciaXML(p_popis: string): TVyhybkaPozicia;
  function VyhybkaPoziciaNaText(p_popis: TVyhybkaPozicia): string;

  //**************************************************************************//

  type TSvetloPozicia=(SPO_NEZNAMA,SPO_ZHASNUTE,SPO_ZHASINA,SPO_ROZSVECUJE,SPO_ROZSVIETENE);

  const SPOS_SVIETI=[SPO_ROZSVECUJE,SPO_ROZSVIETENE];
  const SPOS_NESVIETI=[SPO_ZHASNUTE,SPO_ZHASINA];

  function SvetloPoziciaNaText(p_hodnota: TSvetloPozicia): string;
  function SvetloPoziciaNaSkratku(p_hodnota: TSvetloPozicia): string;

  //**************************************************************************//

  type TNavest=(CN_NEZNAMA,CN_STOJ,CN_POSUN_DOVOLENY,CN_VYSTRAHA,CN_VOLNO,CN_OCAK40,CN_40AVYSTRAHA,CN_40A40,CN_40AVOLNO,CN_PRIVOLAVACKA,CN_VCRP,CN_40AVCRP);

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

      function PercentaNaPixelyX(p_percenta,p_plan_zac,p_plan_kon: Integer): Integer;
      function PercentaNaPixelyY(p_percenta,p_plan_zac,p_plan_kon: Integer): Integer;

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

      procedure VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean); virtual;
  end;

  //**************************************************************************//

  type TStanObsluhy=class(TStavadloObjekt)
    private
      t_x_zac,t_y_zac,t_x_kon,t_y_kon: Integer;
      t_ciara_poloha: Integer;
      t_nazov: string;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_y_zac,p_x_kon,p_y_kon: Integer; p_ciara_poloha: Integer; p_nazov: string; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TText=class(TStavadloObjekt)
    private
      t_x_zac,t_y_zac: Integer;
      t_text,t_predef_text: string;
      t_nastred: Boolean;
      t_napravo: Boolean;
      t_velkost: Integer;

      function DajText: string;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      property Text: string read DajText;

      constructor Create(p_x_zac,p_y_zac: Integer; p_text: string; p_velkost: Integer; p_nastred,p_napravo: Boolean; p_cjednotky: Integer; p_dopravna: TDopravna);

      function DajOrigText: string;
      function DajPredefText: string;
      procedure NastavPredefText(p_hodnota: string);
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

  type TKolajCiaraZavSposob=(ZSO_VYHRADNY,ZSO_STAVANIE,ZSO_ZOBRAZENIE);

  type TKolajCiara=class(TStavadloObjekt)
    private
      t_x_zac,t_x_kon,t_y_zac,t_y_kon: Integer;
      t_cislo: string;
      t_zaver: TZaver;
      t_stitok: string;
      t_vyluka: string;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      property Stitok: string read t_stitok;
      property Vyluka: string read t_vyluka;
      property Zaver: TZaver read t_zaver write t_zaver;

      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
      function JeVolna(p_sposob: TKolajCiaraZavSposob): Boolean;

      procedure VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean); override;

      procedure NastavVyluku(p_text: string);
      procedure NastavStitok(p_text: string);
  end;

  //**************************************************************************//

  type TNavestidlo=class(TStavadloObjekt)
    protected
      t_x_zac,t_x_kon,t_y_zac,t_y_kon: Integer;
      t_cislo: string;
      t_rucny_zaver: Boolean;
      t_stitok: string;

      function DajNavest(p_fyzicky: Boolean): TNavest; virtual; abstract;

    public
      property Stitok: string read t_stitok;
      property RucnyZaver: Boolean read t_rucny_zaver;
      property Navest[Fyzicka: Boolean]: TNavest read DajNavest;

      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer; p_dopravna: TDopravna);

      function RozsvietNavest(p_navest: TNavest; p_povely: TList<TPair<Integer,Boolean>>): Boolean; virtual; abstract;

      function ObsahujeAdresu(p_adresa: Integer): Boolean; virtual; abstract;
      procedure NastavPolohu(p_adresa: Integer; p_smer: Boolean); virtual; abstract;

      procedure DajAdresy(p_adresy: TList<Integer>); virtual; abstract;
      procedure Reset(p_povely: TList<TPair<Integer,Boolean>>); virtual; abstract;

      procedure NastavRucnyZaver(p_zaver: Boolean);

      procedure VypisNudzovyPovelReset(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);

      procedure NastavStitok(p_text: string);
  end;

  //**************************************************************************//

  type TNavestidloHlavne=class(TNavestidlo)
    protected
      t_skupina_pn: Integer;
      t_apn: Boolean;
    public
      property SkupinaPN: Integer read t_skupina_pn;
      property APN: Boolean read t_apn;

      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky,p_skupina_pn: Integer; p_dopravna: TDopravna);

      procedure NastavAPN(p_apn: Boolean);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;

      procedure VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean); override;
      procedure VypisNudzovyPovelPrivolavacka(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);
      procedure VypisNudzovyPovelAPN(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);      
  end;

  //**************************************************************************//

  type
    TVyhybka=class;

     TVyhybkaOdvrat=record
      Opacna: TVyhybka;
      Poloha: TVyhybkaPozicia;
    end;

    TVyhybka=class(TStavadloObjekt)
    private
      t_x_hrot,t_y_hrot,t_x_rovno,t_y_rovno,t_x_odboc,t_y_odboc: Integer;
      t_cislo: string;
      t_poloha: TVyhybkaPozicia;
      t_adresa: Integer;
      t_otocit_polaritu: Boolean;
      t_rucny_zaver: Boolean;

      t_kolaj_hrot,t_kolaj_rovno,t_kolaj_odboc: TKolajCiara;

      t_stitok: string;
      t_vyluka: string;

      t_odvraty_rovno: TList<TVyhybkaOdvrat>;
      t_odvraty_odbocka: TList<TVyhybkaOdvrat>;

    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

      function DajPolohu: TVyhybkaPozicia; virtual;

    public
      property Adresa: Integer read t_adresa;
      property Poloha: TVyhybkaPozicia read DajPolohu;
      property PolohaLog: TVyhybkaPozicia read t_poloha;
      property OtocitPolaritu: Boolean read t_otocit_polaritu;
      property RucnyZaver: Boolean read t_rucny_zaver;
      property Stitok: string read t_stitok;
      property Vyluka: string read t_vyluka;

      constructor Create(p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer; p_dopravna: TDopravna);

      procedure Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
      procedure NastavPolohuCentrala(p_poloha,p_istota: Boolean);

      function JeVolna(p_stavanie: Boolean): Boolean;
      function VyzadujeOdvrat(p_stavanie: Boolean): Boolean;
      function JeVOdvrate(p_stavanie: Boolean): Boolean;

      function DajStav: string; override;

      function NastavRucnyZaver(p_zaver: Boolean; p_potvrd: Boolean): Boolean;

      procedure VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean); override;
      procedure VypisNudzovyPovelZAV2(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);
      procedure VypisNudzovyPovelReset(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);

      procedure NastavVyluku(p_text: string);
      procedure NastavStitok(p_text: string);

      procedure PridajOdvrat(p_polohou: TVyhybkaPozicia; p_vyhybka: TVyhybka; p_poloha: TVyhybkaPozicia);

      destructor Destroy; override;
  end;

  TVyhybkaDohlad=class(TVyhybka)
    private
      t_dohlad_vypnuty: Boolean;

      t_dohlad_rovno: Integer;
      t_dohlad_odbocka: Integer;
      t_dohlad_reset: Integer;

      t_dohlad_rovno_stav: Boolean;
      t_dohlad_odbocka_stav: Boolean;

    protected
      function DajPolohu: TVyhybkaPozicia; override;

    public
      property DohladRovno: Integer read t_dohlad_rovno;
      property DohladOdbocka: Integer read t_dohlad_odbocka;
      property DohladReset: Integer read t_dohlad_reset;

      property DohladRovnoStav: Boolean read t_dohlad_rovno_stav;
      property DohladOdbockaStav: Boolean read t_dohlad_odbocka_stav;
      property DohladVypnuty: Boolean read t_dohlad_vypnuty;

      constructor Create(p_dohlad_rovno,p_dohlad_odbocka,p_dohlad_reset: Integer; p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer; p_dopravna: TDopravna);

      function DajStav: string; override;
      procedure NastavDohlad(p_adresa: Integer; p_stav: Boolean);
      procedure NastavDohladVypnuty(p_stav: Boolean);

      procedure VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean); override;
      procedure VypisNudzovyPovelDOH(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  end;

  //**************************************************************************//

  type TNavestidloVchodoveFarba=(NVF_C,NVF_HZ,NVF_HZ_KMIT,NVF_Z,NVF_B_KMIT,NVF_DZ,NVF_PREDV_HZ,NVF_PREDV_HZ_KMIT,NVF_PREDV_Z);
  const NVFS_VSETKY=[NVF_C,NVF_HZ,NVF_HZ_KMIT,NVF_Z,NVF_B_KMIT,NVF_DZ,NVF_PREDV_HZ,NVF_PREDV_HZ_KMIT,NVF_PREDV_Z];

  function NavestidloVchodoveFarbaNaText(p_hodnota: TNavestidloVchodoveFarba): string;

  type TNavestidloVchodoveAdresy=array[TNavestidloVchodoveFarba] of Integer;

  type TNavestidloVchodove=class(TNavestidloHlavne)
    private
      t_bez_dolneho_svetla,t_bez_bielej: Boolean;
      t_adresy: TNavestidloVchodoveAdresy;
      t_stavy: array[TNavestidloVchodoveFarba] of TSvetloPozicia;

    protected
      function DajNavest(p_fyzicky: Boolean): TNavest; override;
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov(p_kodjednotky, p_dopravna: Boolean): string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_bez_dolneho_svetla,p_bez_bielej: Boolean; p_adresy: TNavestidloVchodoveAdresy; p_cjednotky,p_skupina_pn: Integer; p_dopravna: TDopravna);

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
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_spojit_zelenu,p_bez_zltej: Boolean; p_adresy: TNavestidloOdchodoveAdresy; p_cjednotky,p_skupina_pn: Integer; p_dopravna: TDopravna);

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

      procedure VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean); override;
 end;

implementation
  uses DateUtils, SysUtils, Types, GR32_Polygons, GR32_Backends, LogikaStavadlo;

  function ZaverText(p_hodnota: TZaver): string;
  begin
    case p_hodnota of
      ZVR_NENI: Result:='bez záveru';
      ZVR_RUCNY,ZVR_PREDBEZNY: Result:='nerozlíšený';
      ZVR_PRESAH: Result:='držaný cestou';
      ZVR_POSUNOVA: Result:='posunová cesta';
      ZVR_VLAKOVA: Result:='vlaková cesta';
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function KodJednotkyXML(p_popis: string): TKodJednotky;
  begin
    if(p_popis='KJ_KOLAJCIARA') then Result:=KJ_KOLAJCIARA
    else if(p_popis='KJ_NAVESTIDLOZRIADOVACIE') then Result:=KJ_NAVESTIDLOZRIADOVACIE
    else if(p_popis='KJ_NAVESTIDLOVCHODOVE') then Result:=KJ_NAVESTIDLOVCHODOVE
    else if(p_popis='KJ_NAVESTIDLOODCHODOVE') then Result:=KJ_NAVESTIDLOODCHODOVE
    else if(p_popis='KJ_VYHYBKA') then Result:=KJ_VYHYBKA
    else if(p_popis='KJ_TEXT') then Result:=KJ_TEXT
    else if(p_popis='KJ_SULIBRK') then Result:=KJ_SULIBRK
    else if(p_popis='KJ_STANOB') then Result:=KJ_STANOB
    else if(p_popis='KJ_NASTUPISTE') then Result:=KJ_NASTUPISTE
    else Result:=KJ_KOLAJCIARA
  end;

  //////////////////////////////////////////////////////////////////////////////

  function KodJednotkyNaXML(p_popis: TKodJednotky): string;
  begin
    case p_popis of
      KJ_NAVESTIDLOZRIADOVACIE: Result:='KJ_NAVESTIDLOZRIADOVACIE';
      KJ_NAVESTIDLOVCHODOVE: Result:='KJ_NAVESTIDLOVCHODOVE';
      KJ_NAVESTIDLOODCHODOVE: Result:='KJ_NAVESTIDLOODCHODOVE';
      KJ_VYHYBKA: Result:='KJ_VYHYBKA';
      KJ_TEXT: Result:='KJ_TEXT';
      KJ_SULIBRK: Result:='KJ_SULIBRK';
      KJ_STANOB: Result:='KJ_STANOB';
      KJ_NASTUPISTE: Result:='KJ_NASTUPISTE';
      else Result:='KJ_KOLAJCIARA';
    end;
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
      KJ_STANOB: Result:='SOB';
      KJ_NASTUPISTE: Result:='NST';
    end;
  end;

  //**************************************************************************//

  function VyhybkaPoziciaXML(p_popis: string): TVyhybkaPozicia;
  begin
    if p_popis='VPO_ROVNO' then Result:=VPO_ROVNO
    else if p_popis='VPO_ODBOCKA' then Result:=VPO_ODBOCKA
    else if p_popis='VPO_ROVNO_OTAZNIK' then Result:=VPO_ROVNO_OTAZNIK
    else if p_popis='VPO_ODBOCKA_OTAZNIK' then Result:=VPO_ODBOCKA_OTAZNIK
    else Result:=VPO_NEZNAMA
  end;

  //////////////////////////////////////////////////////////////////////////////

  function VyhybkaPoziciaNaText(p_popis: TVyhybkaPozicia): string;
  begin
    case p_popis of
      VPO_NEZNAMA: Result:='Neznáma/medzipoloha';
      VPO_ROVNO: Result:='Základná';
      VPO_ODBOCKA: Result:='Odbočná';
      VPO_ROVNO_OTAZNIK: Result:='Základná, bez dohľadu';
      VPO_ODBOCKA_OTAZNIK: Result:='Odbočná, bez dohľadu';
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
      CN_VOLNO: Result:='Voľno';
      CN_OCAK40: Result:='Očakávaj 40';
      CN_40AVYSTRAHA: Result:='40 a výstraha';
      CN_40A40: Result:='40 a očakávaj 40';
      CN_40AVOLNO: Result:='40 a voľno';
      CN_PRIVOLAVACKA: Result:='Privolávačka';
      CN_VCRP: Result:='Jazda podľa roz. pomerov';
      CN_40AVCRP: Result:='40 a jazda podľa roz. pomerov';
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

  function TStavadloObjekt.PercentaNaPixelyX(p_percenta,p_plan_zac,p_plan_kon: Integer): Integer;
  var
    sirka: Integer;
  begin
    sirka:=p_plan_kon-p_plan_zac;
    Result:=(p_percenta*sirka) div LogikaES.SirkaPlanu;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.PercentaNaPixelyY(p_percenta,p_plan_zac,p_plan_kon: Integer): Integer;
  var
    sirka: Integer;
  begin
    sirka:=p_plan_kon-p_plan_zac;
    Result:=(p_percenta*sirka) div LogikaES.VyskaPlanu;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.DajJednotku: TJednotka;
  begin
    Result:=Jednotka(KodJednotky,CisloJednotky);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.DajStav: string;
  begin
    Result:='Stav prvku nie je k dispozícii';
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

  //////////////////////////////////////////////////////////////////////////////

  procedure TStavadloObjekt.VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_popis_b:='(B) ';
    p_popis_c:='(C) ';
    p_popis_d:='(D) ';
    p_popis_e:='(E) ';

    p_text_a:=Nazov[True,False];
    p_text_b:='';
    p_text_c:='';
    p_text_d:='';
    p_text_e:='';

    p_cervena_a:=False;
    p_cervena_b:=False;
    p_cervena_c:=False;
    p_cervena_d:=False;
    p_cervena_e:=False;
  end;

  //**************************************************************************//

  constructor TText.Create(p_x_zac,p_y_zac: Integer; p_text: string; p_velkost: Integer; p_nastred,p_napravo: Boolean; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);

    t_x_zac:=p_x_zac;
    t_y_zac:=p_y_zac;
    t_text:=p_text;
    t_predef_text:='';
    t_nastred:=p_nastred;
    t_napravo:=p_napravo;
    t_velkost:=p_velkost;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajText: string;
  begin
    if t_predef_text<>'' then Result:=t_predef_text
    else Result:=t_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajOrigText: string;
  begin
    Result:=t_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajPredefText: string;
  begin
    Result:=t_predef_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TText.NastavPredefText(p_hodnota: string);
  begin
    t_predef_text:=p_hodnota;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TText.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y: Integer;
    vtext: TSize;
  begin
    zac_x:=PercentaNaPixelyX(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixelyY(t_y_zac,p_plan_y_zac,p_plan_y_kon);

    p_plan.Font.Color:=clWhite;
    p_plan.Font.Size:=-1*PercentaNaPixelyY(t_velkost,p_plan_y_zac,p_plan_y_kon);

    vtext:=p_plan.TextExtent(Text);

    if t_nastred then
    begin
      if not t_napravo then zac_x:=zac_x-(vtext.Width div 2);
      zac_y:=zac_y-(vtext.Height div 2);
    end;

    if t_napravo then zac_x:=zac_x-vtext.Width;

    p_plan.FillRect(zac_x-3,zac_y-3,zac_x+vtext.Width+3,zac_y+vtext.Height+3,clBlack32);
    p_plan.TextOut(zac_x,zac_y,Text);
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
    if p_kodjednotky then Result:=Result+'textový prvok ';
    Result:=Result+t_text;
  end;

  //**************************************************************************//

  constructor TStanObsluhy.Create(p_x_zac,p_y_zac,p_x_kon,p_y_kon: Integer; p_ciara_poloha: Integer; p_nazov: string; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_cjednotky,p_dopravna);

    t_x_zac:=p_x_zac;
    t_y_zac:=p_y_zac;
    t_x_kon:=p_x_kon;
    t_y_kon:=p_y_kon;
    t_nazov:=p_nazov;
    t_ciara_poloha:=p_ciara_poloha;
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
        outline:=obal.Grow(Fixed(p_hrubka-3),0.1);
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

  procedure TStanObsluhy.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y,deltax,deltay: Integer;
  begin
    zac_x:=PercentaNaPixelyX(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixelyY(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_x:=PercentaNaPixelyX(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    kon_y:=PercentaNaPixelyY(t_y_kon,p_plan_y_zac,p_plan_y_kon);

    VykresliHrubuCiaru(p_plan,5,zac_x,zac_y,zac_x,kon_y,clGray32);
    VykresliHrubuCiaru(p_plan,5,zac_x,zac_y,kon_x,zac_y,clGray32);
    VykresliHrubuCiaru(p_plan,5,zac_x,kon_y,kon_x,kon_y,clGray32);
    VykresliHrubuCiaru(p_plan,5,kon_x,zac_y,kon_x,kon_y,clGray32);

    deltax:=(kon_x-zac_x) div 5;
    deltay:=(kon_y-zac_y) div 5;

    case t_ciara_poloha of
      1:
      begin
        VykresliHrubuCiaru(p_plan,5,zac_x+deltax,zac_y+deltay,zac_x+deltax,kon_y-deltay,clGray32);
        VykresliHrubuCiaru(p_plan,5,zac_x+deltax*2,zac_y+deltay*2,zac_x+deltax*2,kon_y-deltay*2,clGray32);
      end;
      2:
      begin
        VykresliHrubuCiaru(p_plan,5,zac_x+deltax,zac_y+deltay,kon_x-deltax,zac_y+deltay,clGray32);
        VykresliHrubuCiaru(p_plan,5,zac_x+deltax*2,zac_y+deltay*2,kon_x-deltax*2,zac_y+deltay*2,clGray32);
      end;
      3:
      begin
        VykresliHrubuCiaru(p_plan,5,zac_x+deltax,kon_y-deltay,kon_x-deltax,kon_y-deltay,clGray32);
        VykresliHrubuCiaru(p_plan,5,zac_x+deltax*2,kon_y-deltay*2,kon_x-deltax*2,kon_y-deltay*2,clGray32);
      end
      else
      begin
        VykresliHrubuCiaru(p_plan,5,kon_x-deltax,zac_y+deltay,kon_x-deltax,kon_y-deltay,clGray32);
        VykresliHrubuCiaru(p_plan,5,kon_x-deltax*2,zac_y+deltay*2,kon_x-deltax*2,kon_y-deltay*2,clGray32);
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStanObsluhy.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_STANOB;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStanObsluhy.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'stanovište obsluhy ';
    Result:=Result+t_nazov;
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

  procedure VykresliKolac(p_plan: TBitmap32; p_polygon: TPolygon32; p_ciara,p_vypln: TColor32);
  begin
    p_polygon.Closed:=True;
    p_polygon.Antialiased:=True;
    p_polygon.FillMode:=pfWinding;
    p_polygon.AntialiasMode:=am16times;
    p_polygon.Draw(p_plan,p_ciara,p_vypln);
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  procedure TSulibrk.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,x,y: Integer;
    rozmer: Integer;
    i: Integer;
    fi: Extended;
    polygon_r,polygon_g,polygon_b: TPolygon32;

  begin
    zac_x:=PercentaNaPixelyX(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixelyY(t_y_zac,p_plan_y_zac,p_plan_y_kon);

    rozmer:=20;

    fi:=2*PI/60*(SecondOf(Now) mod 20)*3;

    polygon_r:=TPolygon32.Create;
    try
      polygon_r.Add(FixedPoint(zac_x,zac_y));

      polygon_g:=TPolygon32.Create;
      try
        polygon_g.Add(FixedPoint(zac_x,zac_y));

        polygon_b:=TPolygon32.Create;
        try
          polygon_b.Add(FixedPoint(zac_x,zac_y));
        
          for i := 0 to 119 do
          begin
            x:=Round(rozmer*Sin((2*PI*i)/120+fi));
            y:=Round(rozmer*Cos((2*PI*i)/120+fi));

            if(i>=0) and (i<20) then polygon_r.Add(FixedPoint(zac_x+x,zac_y+y));
            if(i>=40) and (i<60) then polygon_g.Add(FixedPoint(zac_x+x,zac_y+y));
            if(i>=80) and (i<100) then polygon_b.Add(FixedPoint(zac_x+x,zac_y+y));
          end;

          VykresliKolac(p_plan,polygon_r,clSilver32,clRed32);
          VykresliKolac(p_plan,polygon_g,clSilver32,clLime32);
          VykresliKolac(p_plan,polygon_b,clSilver32,clBlue32);         
        finally
          polygon_b.Free;
        end;
      finally
        polygon_g.Free;
      end;
    
//    p_plan.Canvas.Pen.Width:=1;
//
//    p_plan.Canvas.Pen.Color:=clSilver;
//    p_plan.Canvas.Brush.Color:=clRed;
//
//    p_plan.Canvas.Pie(zac_x-rozmer,zac_y-rozmer,zac_x+rozmer,zac_y+rozmer,zac_x+A1.X,zac_y+A1.Y,zac_x+A2.X,zac_y+A2.Y);
//
//    p_plan.Canvas.Pen.Color:=clSilver;
//    p_plan.Canvas.Brush.Color:=clLime;
//
//    p_plan.Canvas.Pie(zac_x-rozmer,zac_y-rozmer,zac_x+rozmer,zac_y+rozmer,zac_x+B1.X,zac_y+B1.Y,zac_x+B2.X,zac_y+B2.Y);
//
//    p_plan.Canvas.Pen.Color:=clSilver;
//    p_plan.Canvas.Brush.Color:=clBlue;
//
//    p_plan.Canvas.Pie(zac_x-rozmer,zac_y-rozmer,zac_x+rozmer,zac_y+rozmer,zac_x+C1.X,zac_y+C1.Y,zac_x+C2.X,zac_y+C2.Y);
    finally
      polygon_r.Free;
    end;
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

    t_stitok:='';
    t_vyluka:='';
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TKolajCiara.NastavVyluku(p_text: string);
  begin
    t_vyluka:=p_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TKolajCiara.NastavStitok(p_text: string);
  begin
    t_stitok:=p_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TKolajCiara.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_KOLAJCIARA;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TKolajCiara.JeVolna(p_sposob: TKolajCiaraZavSposob): Boolean;
  begin
    case p_sposob of
      ZSO_VYHRADNY: Result:=t_zaver=ZVR_NENI;
      ZSO_STAVANIE: Result:=t_zaver in [ZVR_NENI,ZVR_PRESAH];
      else Result:=t_zaver in [ZVR_NENI,ZVR_PRESAH,ZVR_NENI];
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TKolajCiara.VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    inherited;

    p_popis_b:=p_popis_b+'Záver';
    p_text_b:=ZaverText(t_zaver);

    p_popis_c:=p_popis_c+'Štítok';
    p_text_c:=t_stitok;
    if t_stitok<>'' then p_cervena_c:=True;

    p_popis_d:=p_popis_d+'Výluka';
    p_text_d:=t_vyluka;
    if t_vyluka<>'' then p_cervena_d:=True;    
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TKolajCiara.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    farba: TColor32;
    hrubka: Integer;
    hb: THitBox;
  begin
    if (t_stitok<>'') or (t_vyluka<>'') then
    begin
      hb:=LogikaES.DajHitBox(self);
      if hb.Objekt=self then
      begin
        zac_x:=PercentaNaPixelyX(hb.Poloha.Left,p_plan_x_zac,p_plan_x_kon);
        kon_x:=PercentaNaPixelyX(hb.Poloha.Right,p_plan_x_zac,p_plan_x_kon);
        zac_y:=PercentaNaPixelyY(hb.Poloha.Top,p_plan_y_zac,p_plan_y_kon);
        kon_y:=PercentaNaPixelyY(hb.Poloha.Bottom,p_plan_y_zac,p_plan_y_kon);

        if t_vyluka<>'' then farba:=clMaroon32
        else farba:=clTeal32;

        p_plan.FillRectS(zac_x,zac_y,kon_x,kon_y,farba);
      end
    end;

    zac_x:=PercentaNaPixelyX(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    kon_x:=PercentaNaPixelyX(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixelyY(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_y:=PercentaNaPixelyY(t_y_kon,p_plan_y_zac,p_plan_y_kon);

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
    if p_kodjednotky then Result:=Result+'Koľaj ';

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

    t_stitok:='';
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidlo.NastavStitok(p_text: string);
  begin
    t_stitok:=p_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidlo.NastavRucnyZaver(p_zaver: Boolean);
  begin
    t_rucny_zaver:=p_zaver;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidlo.VypisNudzovyPovelReset(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_text_a:=Nazov[True,False];

    p_popis_b:='(B) Návesť';
    p_text_b:=NavestNaText(Navest[False]);
    if not (Navest[False] in [CN_STOJ,CN_NEZNAMA]) then p_cervena_b:=True;


    p_popis_c:='(C) Ručný záver';
    if t_rucny_zaver then p_text_c:='Áno'
    else
    begin
      p_cervena_c:=True;
      p_text_c:='Nie';
    end;

    p_popis_d:='(D) Štítok';
    p_text_d:=t_stitok;
    if t_stitok<>'' then p_cervena_d:=True;
  end;

  //**************************************************************************//

  constructor TNavestidloHlavne.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky,p_skupina_pn: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky,p_dopravna);

    t_skupina_pn:=p_skupina_pn;
    t_apn:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloHlavne.NastavAPN(p_apn: Boolean);
  begin
    t_apn:=p_apn;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloHlavne.Vykresli(p_plan: TBitmap32; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    v_navest: TNavest;
    polygon,obal,outline: TPolygon32;
    obrys,vypln: TColor32;
  begin
    zac_x:=PercentaNaPixelyX(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    kon_x:=PercentaNaPixelyX(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixelyY(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_y:=PercentaNaPixelyY(t_y_kon,p_plan_y_zac,p_plan_y_kon);

    if t_rucny_zaver then vypln:=clRed32
    else
    begin
      v_navest:=DajNavest(True);

      if v_navest=CN_STOJ then vypln:=clGray32
      else if v_navest=CN_NEZNAMA then vypln:=clBlack32
      else if v_navest=CN_PRIVOLAVACKA then vypln:=clAqua32
      else if v_navest=CN_POSUN_DOVOLENY then vypln:=clWhite32
      else vypln:=clLime32;
    end;

    if t_stitok<>'' then
    begin
      if zac_x<kon_x then p_plan.FillRectS(zac_x-2,zac_y-2,kon_x+2,kon_y+2,clTeal32)
      else p_plan.FillRectS(kon_x-2,zac_y-2,zac_x+2,kon_y+2,clTeal32);
    end;

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
      polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2-1));
      polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2+2));

      polygon.Antialiased:=True;
      polygon.FillMode:=pfWinding;
      polygon.AntialiasMode:=am8times;
      polygon.DrawFill(p_plan,vypln);

      obal:=polygon.Outline;
      obal.Closed:=True;
      try
        outline:=obal.Grow(Fixed(1),0.1);
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

  procedure TNavestidloHlavne.VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    inherited;

    p_popis_b:=p_popis_b+'Návesť';
    p_popis_c:=p_popis_c+'Svieti';
    p_popis_d:=p_popis_d+'Uzamknuté';
    p_popis_e:=p_popis_e+'Štítok';

    p_text_b:=NavestNaText(Navest[False]);
    p_text_c:=NavestNaText(Navest[True]);

    if t_rucny_zaver then
    begin
      p_text_d:='Áno';
      p_cervena_d:=True;
    end
    else if t_apn then
    begin
      p_text_d:='APN';
      p_cervena_d:=True;    
    end
    else p_text_d:='Nie';

    p_text_e:=t_stitok;
    if t_stitok<>'' then p_cervena_e:=True;    
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloHlavne.VypisNudzovyPovelPrivolavacka(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_text_a:=Nazov[True,False];

    p_popis_b:='(B) Návesť';
    p_text_b:=NavestNaText(Navest[False]);
    if not (Navest[False] in [CN_STOJ,CN_NEZNAMA]) then p_cervena_b:=True;

    p_popis_c:='(C) Ručný záver';
    if t_rucny_zaver then
    begin
      p_text_c:='Áno';
      p_cervena_c:=True;
    end
    else p_text_c:='Nie';

    p_popis_d:='(D) Štítok';
    p_text_d:=t_stitok;
    if t_stitok<>'' then p_cervena_d:=True;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloHlavne.VypisNudzovyPovelAPN(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_text_a:=Nazov[True,False];

    p_popis_b:='(B) Návesť';
    p_text_b:=NavestNaText(Navest[False]);
    if not (Navest[False] in [CN_STOJ,CN_NEZNAMA]) then p_cervena_b:=True;

    p_popis_c:='(C) Ručný záver';
    if t_rucny_zaver then
    begin
      p_text_c:='Áno';
      p_cervena_c:=True;
    end
    else p_text_c:='Nie';

    p_popis_d:='(D) Štítok';
    p_text_d:=t_stitok;
    if t_stitok<>'' then p_cervena_d:=True;

    p_popis_e:='(E) APN';
    if t_apn then
    begin
      p_text_e:='Áno';
      p_cervena_e:=True;
    end
    else p_text_e:='Nie';    
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

    t_stitok:='';
    t_vyluka:='';

    t_odvraty_rovno:=TList<TVyhybkaOdvrat>.Create;
    t_odvraty_odbocka:=TList<TVyhybkaOdvrat>.Create;
  end;

  //////////////////////////////////////////////////////////////////////////////

  destructor TVyhybka.Destroy;
  begin
    t_odvraty_rovno.Free;
    t_odvraty_odbocka.Free;
    
    inherited;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.NastavVyluku(p_text: string);
  begin
    t_vyluka:=p_text;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.NastavStitok(p_text: string);
  begin
    t_stitok:=p_text;
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
    zac_x,zac_y,kon_x,kon_y: Integer;
    doc:Integer;
  begin
    hrot_x:=PercentaNaPixelyX(t_x_hrot,p_plan_x_zac,p_plan_x_kon);
    rovno_x:=PercentaNaPixelyX(t_x_rovno,p_plan_x_zac,p_plan_x_kon);
    odboc_x:=PercentaNaPixelyX(t_x_odboc,p_plan_x_zac,p_plan_x_kon);
    hrot_y:=PercentaNaPixelyY(t_y_hrot,p_plan_y_zac,p_plan_y_kon);
    rovno_y:=PercentaNaPixelyY(t_y_rovno,p_plan_y_zac,p_plan_y_kon);
    odboc_y:=PercentaNaPixelyY(t_y_odboc,p_plan_y_zac,p_plan_y_kon);

    zac_x:=hrot_x;
    zac_y:=odboc_y;
    kon_x:=rovno_x;
    kon_y:=rovno_y-(odboc_y-rovno_y);

    if zac_x>kon_x then
    begin
      doc:=zac_x;
      zac_x:=kon_x;
      kon_x:=doc;
    end;

    if zac_y>kon_y then
    begin
      doc:=zac_y;
      zac_y:=kon_y;
      kon_y:=doc;
    end;

    if t_stitok<>'' then
      p_plan.FillRect(zac_x,zac_y,kon_x,kon_y,clTeal32);
    if t_vyluka<>'' then p_plan.FillRect(zac_x,zac_y,kon_x,kon_y,clMaroon32);

    if t_rucny_zaver then farba:=clAqua32
    else
    begin
      if Poloha in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then kolaj_zaver:=t_kolaj_rovno
      else if Poloha in [VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then kolaj_zaver:=t_kolaj_odboc
      else kolaj_zaver:=nil;

      if(kolaj_zaver<>nil) and (kolaj_zaver.Zaver=ZVR_POSUNOVA) then farba:=clWhite32
      else if(kolaj_zaver<>nil) and (kolaj_zaver.Zaver=ZVR_VLAKOVA) then farba:=clLime32
      else
      begin
        if JeVOdvrate(False) then farba:=clAqua32
        else if Poloha in [VPO_ROVNO_OTAZNIK,VPO_ODBOCKA_OTAZNIK] then farba:=clYellow32
        else farba:=clGray32;
      end;
    end;

    if Poloha in [VPO_NEZNAMA,VPO_ROVNO,VPO_ROVNO_OTAZNIK] then VykresliHrubuCiaru(p_plan,5,hrot_x,hrot_y,rovno_x,rovno_y,farba);

    if Poloha in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then VykresliHrubuCiaru(p_plan,5,hrot_x,hrot_y,odboc_x,odboc_y,farba);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajNazov(p_kodjednotky, p_dopravna: Boolean): string;
  begin
    if p_dopravna then Result:=Dopravna.Skratka+' ' else Result:='';
    if p_kodjednotky then Result:=Result+'Výhybka ';
    Result:=Result+t_cislo;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajPolohu: TVyhybkaPozicia;
  begin
    Result:=t_poloha;
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

  function TVyhybka.JeVolna(p_stavanie: Boolean): Boolean;
  begin
    if (not t_rucny_zaver) and (not JeVOdvrate(p_stavanie)) then
    begin
      if p_stavanie then Result:=((t_kolaj_hrot=nil) or (t_kolaj_hrot.JeVolna(ZSO_STAVANIE))) and ((t_kolaj_rovno=nil) or (t_kolaj_rovno.JeVolna(ZSO_STAVANIE))) and ((t_kolaj_odboc=nil) or (t_kolaj_odboc.JeVolna(ZSO_STAVANIE)))
      else Result:=((t_kolaj_hrot=nil) or (t_kolaj_hrot.JeVolna(ZSO_ZOBRAZENIE))) and ((t_kolaj_rovno=nil) or (t_kolaj_rovno.JeVolna(ZSO_ZOBRAZENIE))) and ((t_kolaj_odboc=nil) or (t_kolaj_odboc.JeVolna(ZSO_ZOBRAZENIE)))
    end
    else Result:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.VyzadujeOdvrat(p_stavanie: Boolean): Boolean;
  begin
    if p_stavanie then Result:=t_rucny_zaver or ((t_kolaj_rovno<>nil) and (t_poloha in [VPO_ROVNO,VPO_ROVNO_OTAZNIK]) and (not t_kolaj_rovno.JeVolna(ZSO_STAVANIE))) or ((t_kolaj_odboc<>nil) and (t_poloha in [VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK]) and (not t_kolaj_odboc.JeVolna(ZSO_STAVANIE)))
    else Result:=t_rucny_zaver or ((t_kolaj_rovno<>nil) and (t_poloha in [VPO_ROVNO,VPO_ROVNO_OTAZNIK]) and (not t_kolaj_rovno.JeVolna(ZSO_ZOBRAZENIE))) or ((t_kolaj_odboc<>nil) and (t_poloha in [VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK]) and (not t_kolaj_odboc.JeVolna(ZSO_ZOBRAZENIE)))
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.JeVOdvrate(p_stavanie: Boolean): Boolean;
  var
    odvrat: TVyhybkaOdvrat;
  begin
    case t_poloha of
      VPO_ROVNO,VPO_ROVNO_OTAZNIK: 
      begin
        Result:=False;
      
        for odvrat in t_odvraty_rovno do
        begin
          if (odvrat.Opacna.PolohaLog=odvrat.Poloha) and (odvrat.Opacna.VyzadujeOdvrat(p_stavanie)) then
          begin
            Result:=True;
            break;
          end;
        end;
      end;
      VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK: 
      begin
        Result:=False;
      
        for odvrat in t_odvraty_odbocka do
        begin
          if (odvrat.Opacna.PolohaLog=odvrat.Poloha) and (odvrat.Opacna.VyzadujeOdvrat(p_stavanie)) then
          begin        
            Result:=True;
            break;
          end;
        end;
      end;
      else Result:=False;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.PridajOdvrat(p_polohou: TVyhybkaPozicia; p_vyhybka: TVyhybka; p_poloha: TVyhybkaPozicia);
  var
    odvrat: TVyhybkaOdvrat;
  begin
    odvrat.Opacna:=p_vyhybka;
    odvrat.Poloha:=p_poloha;

    case p_polohou of
      VPO_ROVNO:
        t_odvraty_rovno.Add(odvrat);
      VPO_ODBOCKA:
        t_odvraty_odbocka.Add(odvrat);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajStav: string;
  begin
    Result:='Poloha: '+VyhybkaPoziciaNaText(t_poloha)+' Ruč. záver: '+BoolToStr(t_rucny_zaver,True);
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
      else LogikaES.NastavNudzovyPovel(Dopravna,NPT_ZAV2,self,NPP_ASDF);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    inherited;
    p_popis_b:=p_popis_b+'Poloha';
    p_popis_c:=p_popis_c+'Záver';
    p_popis_d:=p_popis_d+'Štítok';
    p_popis_e:=p_popis_e+'Výluka';

    p_text_b:=VyhybkaPoziciaNaText(t_poloha);

    if t_rucny_zaver then
    begin
      p_text_c:='ručný';
      p_cervena_c:=True;
    end
    else if JeVOdvrate(True) then
    begin
      p_text_c:='odvrat jiné cesty';
      p_cervena_c:=True;    
    end
    else if not JeVolna(True) then
    begin
      p_text_c:='vlakovou/posunovou cestou';
      p_cervena_c:=True;
    end
    else p_text_c:='bez záveru';

    p_text_d:=t_stitok;
    if t_stitok<>'' then p_cervena_d:=True;

    p_text_e:=t_vyluka;
    if t_vyluka<>'' then p_cervena_e:=True;    
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.VypisNudzovyPovelZAV2(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_popis_b:='(B) Poloha';
    p_popis_c:='(C) Štítok';
    p_popis_d:='(E) Výluka';
    p_text_a:=Nazov[True,False];
    p_text_b:=VyhybkaPoziciaNaText(t_poloha);

    p_text_c:=t_stitok;
    if t_stitok<>'' then p_cervena_c:=True;
    
    p_text_d:=t_vyluka;
    if t_vyluka<>'' then p_cervena_d:=True;    
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybka.VypisNudzovyPovelReset(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_popis_b:='(B) Poloha';
    p_popis_c:='(C) Štítok';
    p_popis_d:='(E) Výluka';
    p_text_a:=Nazov[True,False];
    p_text_b:=VyhybkaPoziciaNaText(t_poloha);

    p_text_c:=t_stitok;
    if t_stitok<>'' then p_cervena_c:=True;

    p_text_d:=t_vyluka;
    if t_vyluka<>'' then p_cervena_d:=True;
  end;

  //**************************************************************************//

  constructor TVyhybkaDohlad.Create(p_dohlad_rovno,p_dohlad_odbocka,p_dohlad_reset: Integer; p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer; p_dopravna: TDopravna);
  begin
    inherited Create(p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc,p_cislo,p_adresa,p_otocit_pohohu,p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc,p_cjednotky,p_dopravna);

    t_dohlad_vypnuty:=False;

    t_dohlad_rovno:=p_dohlad_rovno;
    t_dohlad_odbocka:=p_dohlad_odbocka;
    t_dohlad_reset:=p_dohlad_reset;

    t_dohlad_rovno_stav:=False;
    t_dohlad_odbocka_stav:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybkaDohlad.DajPolohu: TVyhybkaPozicia;
  begin
    Result:=inherited DajPolohu;

    if not t_dohlad_vypnuty then
    begin
      if (Result in [VPO_ROVNO,VPO_ROVNO_OTAZNIK]) then
      begin
        if(not t_dohlad_rovno_stav) or t_dohlad_odbocka_stav then Result:=VPO_NEZNAMA;
        if(Result=VPO_ROVNO_OTAZNIK) and t_dohlad_rovno_stav and (not t_dohlad_odbocka_stav) then Result:=VPO_ROVNO;
      end
      else if (Result in [VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK]) then
      begin
        if(not t_dohlad_odbocka_stav) or t_dohlad_rovno_stav then Result:=VPO_NEZNAMA;
        if(Result=VPO_ODBOCKA_OTAZNIK) and t_dohlad_odbocka_stav and (not t_dohlad_rovno_stav) then Result:=VPO_ODBOCKA;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybkaDohlad.NastavDohlad(p_adresa: Integer; p_stav: Boolean);
  begin
    if not t_dohlad_vypnuty then
    begin
      if p_adresa=t_dohlad_rovno then
      begin
        t_dohlad_rovno_stav:=p_stav;
        if p_stav and (DajPolohu=VPO_NEZNAMA) then t_poloha:=VPO_ROVNO_OTAZNIK;
      end
      else if p_adresa=t_dohlad_odbocka then
      begin
        t_dohlad_odbocka_stav:=p_stav;
        if p_stav and (DajPolohu=VPO_NEZNAMA) then t_poloha:=VPO_ODBOCKA_OTAZNIK;
      end
      else assert(False);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybkaDohlad.NastavDohladVypnuty(p_stav: Boolean);
  begin
    t_dohlad_vypnuty:=p_stav;

    if not t_dohlad_vypnuty then
    begin
      t_dohlad_rovno_stav:=False;
      t_dohlad_odbocka_stav:=False;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybkaDohlad.DajStav: string;
  begin
    Result:='Poloha: '+VyhybkaPoziciaNaText(t_poloha)+' Ruč. záver: '+BoolToStr(t_rucny_zaver,True);

    if not t_dohlad_vypnuty then Result:=Result+' Doh. rovno: '+BoolToStr(t_dohlad_rovno_stav,True)+' Doh. odboč: '+BoolToStr(t_dohlad_odbocka_stav,True)
    else Result:=Result+' Doh. rovno: vyradený Doh. odboč: vyradený';
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybkaDohlad.VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    inherited;

    p_text_b:=VyhybkaPoziciaNaText(t_poloha);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TVyhybkaDohlad.VypisNudzovyPovelDOH(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    p_popis_a:='(A) Názov';
    p_popis_b:='(B) Poloha';
    p_popis_c:='(C) Štítok';
    p_popis_d:='(E) Výluka';
    p_popis_e:='(F) Dohľad';  
      
    p_text_a:=Nazov[True,False];
    p_text_b:=VyhybkaPoziciaNaText(t_poloha);

    p_text_c:=t_stitok;
    if t_stitok<>'' then p_cervena_c:=True;

    p_text_d:=t_vyluka;
    if t_vyluka<>'' then p_cervena_d:=True;

    if t_dohlad_vypnuty then
    begin
      p_text_e:='Vyradený';
      p_cervena_e:=True;
    end
    else
    begin
      p_text_e:='Aktívny';
      p_cervena_e:=False;    
    end;
  end;

  //**************************************************************************//

  function NavestidloVchodoveFarbaNaText(p_hodnota: TNavestidloVchodoveFarba): string;
  begin
    case p_hodnota of
      NVF_C: Result:='Č';
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

  constructor TNavestidloVchodove.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_bez_dolneho_svetla,p_bez_bielej: Boolean; p_adresy: TNavestidloVchodoveAdresy; p_cjednotky,p_skupina_pn: Integer; p_dopravna: TDopravna);
  var
    i: TNavestidloVchodoveFarba;
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky,p_skupina_pn,p_dopravna);

    t_bez_dolneho_svetla:=p_bez_dolneho_svetla;
    t_bez_bielej:=p_bez_bielej;

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
      if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) and (t_stavy[i]=SPO_NEZNAMA) then
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
    else if svietia=[NVF_HZ,NVF_B_KMIT,NVF_PREDV_HZ] then Result:=CN_VCRP
    else if svietia=[NVF_HZ,NVF_B_KMIT,NVF_DZ,NVF_PREDV_HZ] then Result:=CN_40AVCRP
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
        if not t_apn then rozsvietene:=[NVF_HZ,NVF_PREDV_Z]
        else rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        
        Result:=True;
      end;
      CN_VOLNO:
      begin
        if not t_apn then rozsvietene:=[NVF_Z,NVF_PREDV_Z]
        else rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        
        Result:=True;
      end;
      CN_OCAK40:
      begin
        if not t_apn then rozsvietene:=[NVF_HZ_KMIT,NVF_PREDV_Z]
        else rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        
        Result:=True;
      end;
      CN_40AVYSTRAHA:
      begin
        if not t_apn then rozsvietene:=[NVF_HZ,NVF_DZ,NVF_PREDV_HZ_KMIT]
        else rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        
        Result:=True;
      end;
      CN_40A40:
      begin
        if not t_apn then rozsvietene:=[NVF_HZ_KMIT,NVF_DZ,NVF_PREDV_HZ_KMIT]
        else rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        
        Result:=True;
      end;
      CN_40AVOLNO:
      begin
        if not t_apn then rozsvietene:=[NVF_Z,NVF_DZ,NVF_PREDV_HZ_KMIT]
        else rozsvietene:=[NVF_C,NVF_B_KMIT,NVF_PREDV_HZ];
        
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
          if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) then p_povely.Add(VyrobPovel(t_adresy[i],True));
          if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) then t_stavy[i]:=SPO_ROZSVECUJE;
        end
      end;

      for i := Low(t_stavy) to High(t_stavy) do
      begin
        if (not (i in rozsvietene)) and (not (t_stavy[i] in SPOS_NESVIETI)) then
        begin
          if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) then p_povely.Add(VyrobPovel(t_adresy[i],False));
          if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) then t_stavy[i]:=SPO_ZHASINA;
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
    for i := Low(t_adresy) to High(t_adresy) do
    begin
      if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) then p_adresy.Add(t_adresy[i]);
    end;
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
        if((not t_bez_dolneho_svetla) or (i<>NVF_DZ)) and ((not t_bez_bielej) or (i<>NVF_B_KMIT)) then p_povely.Add(VyrobPovel(t_adresy[i],False));
        t_stavy[i]:=SPO_ZHASINA;
      end;
    end;

    NastavRucnyZaver(False);
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
      NOF_C: Result:='Č';
      NOF_Z: Result:='Z';
      NOF_B: Result:='B';
      NOF_B_KMIT: Result:='B kmit';
      NOF_DZ: Result:='DŽ';
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  constructor TNavestidloOdchodove.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_spojit_zelenu,p_bez_zltej: Boolean; p_adresy: TNavestidloOdchodoveAdresy; p_cjednotky,p_skupina_pn: Integer; p_dopravna: TDopravna);
  var
    i: TNavestidloOdchodoveFarba;
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky,p_skupina_pn,p_dopravna);

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
        if not t_apn then rozsvietene:=[NOF_Z]
        else rozsvietene:=[NOF_C,NOF_B_KMIT];
        
        Result:=True;
      end;
      CN_40AVOLNO:
      begin
        if not t_apn then rozsvietene:=[NOF_Z,NOF_DZ]
        else rozsvietene:=[NOF_C,NOF_B_KMIT];
        
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
        end;
      end;

      for i := Low(t_stavy) to High(t_stavy) do
      begin
        if (not (i in rozsvietene)) and (not (t_stavy[i] in SPOS_NESVIETI)) then
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

    NastavRucnyZaver(False);
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
    zac_x:=PercentaNaPixelyX(t_x_zac,p_plan_x_zac,p_plan_x_kon);
    kon_x:=PercentaNaPixelyX(t_x_kon,p_plan_x_zac,p_plan_x_kon);
    zac_y:=PercentaNaPixelyY(t_y_zac,p_plan_y_zac,p_plan_y_kon);
    kon_y:=PercentaNaPixelyY(t_y_kon,p_plan_y_zac,p_plan_y_kon);

    sirka:=abs(kon_x-zac_x) div 3;

    if t_stitok<>'' then
    begin
      if zac_x<kon_x then p_plan.FillRectS(zac_x-2,zac_y-2,kon_x+2,kon_y+2,clTeal32)
      else p_plan.FillRectS(kon_x-2,zac_y-2,zac_x+2,kon_y+2,clTeal32);
    end;

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
        polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2+1));
        polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2-2));
        polygon.Add(FixedPoint(zac_x+sirka,kon_y));
        polygon.Add(FixedPoint(zac_x,kon_y));
        polygon.Add(FixedPoint(kon_x-sirka,(zac_y+kon_y) div 2));
      end
      else
      begin
        polygon.Add(FixedPoint(zac_x,zac_y));
        polygon.Add(FixedPoint(zac_x-sirka,zac_y));
        polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2+1));
        polygon.Add(FixedPoint(kon_x,(zac_y+kon_y) div 2-2));
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
        outline:=obal.Grow(Fixed(1),0.1);
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
        end;
      end;

      for i := Low(t_stavy) to High(t_stavy) do
      begin
        if (not (i in rozsvietene)) and (not (t_stavy[i] in SPOS_NESVIETI)) then
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

    NastavRucnyZaver(False);
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

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloZriadovacie.VypisNudzovyPovelStav(out p_popis_a: string; out p_popis_b: string; out p_popis_c: string; out p_popis_d: string; out p_popis_e: string; out p_text_a: string; out p_text_b: string; out p_text_c: string; out p_text_d: string; out p_text_e: string; out p_cervena_a: Boolean; out p_cervena_b: Boolean; out p_cervena_c: Boolean; out p_cervena_d: Boolean; out p_cervena_e: Boolean);
  begin
    inherited;

    p_popis_b:=p_popis_b+'Návesť';
    p_popis_c:=p_popis_c+'Svieti';
    p_popis_d:=p_popis_d+'Ručný záver';
    p_popis_e:=p_popis_e+'Štítok';

    p_text_b:=NavestNaText(Navest[False]);
    p_text_c:=NavestNaText(Navest[True]);

    if t_rucny_zaver then
    begin
      p_text_d:='Áno';
      p_cervena_d:=True;
    end
    else p_text_d:='Nie';

    p_text_e:=t_stitok;
    if t_stitok<>'' then p_cervena_e:=True;    
  end;
end.
