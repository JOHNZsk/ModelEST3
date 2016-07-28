unit StavadloObjekty;

interface
  uses Graphics;

  type TZaver=(ZVR_NENI,ZVR_RUCNY,ZVR_PREDBEZNY,ZVR_PRESAH,ZVR_POSUNOVA,ZVR_VLAKOVA);
  type TKodJednotky=(KJ_KOLAJCIARA,KJ_NAVESTIDLOZRIADOVACIE,KJ_NAVESTIDLOVCHODOVE,KJ_NAVESTIDLOODCHODOVE,KJ_VYHYBKA,KJ_TEXT,KJ_SULIBRK);
  type TVyhybkaPozicia=(VPO_NEZNAMA,VPO_ROVNO,VPO_ODBOCKA,VPO_ROVNO_OTAZNIK,VPO_ODBOCKA_OTAZNIK);

  type TJednotka=record
    KodJednotky: TKodJednotky;
    CisloJednotky: Integer;
  end;

  function Jednotka(p_kodjednotky: TKodJednotky; p_cjednotky: Integer): TJednotka;

  //**************************************************************************//
  
  type TStavadloObjekt=class(TObject)
    private
      t_cjednotky: Integer;
      t_je_zdroj: Boolean;
      t_je_zdroj_posun: Boolean;

    protected
      function DajKodJednotky: TKodJednotky; virtual; abstract;
      function DajNazov: string; virtual; abstract;

      function PercentaNaPixely(p_percenta,p_plan_zac,p_plan_kon: Integer; p_x,p_y: Boolean): Integer;

    public
      property KodJednotky: TKodJednotky read DajKodJednotky;
      property CisloJednotky: Integer read t_cjednotky;
      property Nazov: string read DajNazov;
      property JeZdroj: Boolean read t_je_zdroj;
      property JeZdrojPosun: Boolean read t_je_zdroj_posun;

      constructor Create(p_cjednotky: Integer);

      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); virtual; abstract;
      function DajJednotku: TJednotka;

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
      function DajNazov: string; override;

    public
      constructor Create(p_x_zac,p_y_zac: Integer; p_text: string; p_velkost: Integer; p_nastred: Boolean; p_cjednotky: Integer);

      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TSulibrk=class(TStavadloObjekt)
    private
      t_x_zac,t_y_zac: Integer;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov: string; override;

    public
      constructor Create(p_x_zac,p_y_zac: Integer; p_cjednotky: Integer);

      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TKolajCiara=class(TStavadloObjekt)
    private
      t_x_zac,t_x_kon,t_y_zac,t_y_kon: Integer;
      t_cislo: string;
      t_zaver: TZaver;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov: string; override;

    public
      property Zaver: TZaver read t_zaver write t_zaver;

      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer);

      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
      function JeVolna: Boolean;
  end;

  //**************************************************************************//

  type TNavestidlo=class(TStavadloObjekt)
    protected
      t_x_zac,t_x_kon,t_y_zac,t_y_kon: Integer;
      t_cislo: string;
    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer);

  end;

  //**************************************************************************//

  type TNavestidloHlavne=class(TNavestidlo)
    public  
      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

  //**************************************************************************//

  type TVyhybka=class(TStavadloObjekt)
    private
      t_x_hrot,t_y_hrot,t_x_rovno,t_y_rovno,t_x_odboc,t_y_odboc: Integer;
      t_cislo: string;
      t_poloha: TVyhybkaPozicia;
      t_adresa: Integer;
      t_otocit_polaritu: Boolean;

      t_kolaj_hrot,t_kolaj_rovno,t_kolaj_odboc: TKolajCiara;

    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov: string; override;

    public
      property Adresa: Integer read t_adresa;
      property Pozicia: TVyhybkaPozicia read t_poloha;
      property OtocitPolaritu: Boolean read t_otocit_polaritu;

      constructor Create(p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer);

      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
      procedure NastavPolohuCentrala(p_poloha,p_istota: Boolean);

      function JeVolna: Boolean;
  end;
  
  //**************************************************************************//

  type TNavestidloVchodove=class(TNavestidloHlavne)
    private
      t_adr_cervena,t_adr_horna_zlta,t_adr_horna_zlta_kmit,t_adr_zelena,t_adr_biela_kmit,t_adr_dolna_zlta: Integer;
      t_adr_predvest_zlta,t_adr_predvest_zlta_kmit,t_adr_predvest_zelena: Integer;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov: string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adr_cervena,p_adr_horna_zlta,p_adr_horna_zlta_kmit,p_adr_zelena,p_adr_biela_kmit,p_adr_dolna_zlta,p_adr_predvest_zlta,p_adr_predvest_zlta_kmit,p_adr_predvest_zelena,p_cjednotky: Integer);
  end;

  //**************************************************************************//

  type TNavestidloOdchodove=class(TNavestidloHlavne)
    private
      t_adr_cervena,t_adr_zelena,t_adr_dolna_zlta,t_adr_biela,t_adr_biela_kmit: Integer;
    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov: string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adr_cervena,p_adr_zelena,p_adr_dolna_zlta,p_adr_biela,p_adr_biela_kmit,p_cjednotky: Integer);
  end;

  //**************************************************************************//

  type TNavestidloZriadovacie=class(TNavestidlo)
    private
      t_adr_biela,t_adr_modra: Integer;

    protected
      function DajKodJednotky: TKodJednotky; override;
      function DajNazov: string; override;

    public
      constructor Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adr_biela,p_adr_modra,p_cjednotky: Integer);

      procedure Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer); override;
  end;

implementation
  uses DateUtils, SysUtils, Types;
  
  function Jednotka(p_kodjednotky: TKodJednotky; p_cjednotky: Integer): TJednotka;
  begin
    Result.KodJednotky:=p_kodjednotky;
    Result.CisloJednotky:=p_cjednotky;
  end;

  //**************************************************************************//

  constructor TStavadloObjekt.Create(p_cjednotky: Integer);
  begin
    t_cjednotky:=p_cjednotky;
    t_je_zdroj:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.PercentaNaPixely(p_percenta,p_plan_zac,p_plan_kon: Integer; p_x,p_y: Boolean): Integer;
  var
    sirka: Integer;
  begin
//    if(p_x) then p_percenta:=110-p_percenta
//    else if((p_y) and (p_percenta<70)) then p_percenta:=70-p_percenta;

    sirka:=p_plan_kon-p_plan_zac;
    Result:=(p_percenta*sirka) div 110;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TStavadloObjekt.DajJednotku: TJednotka;
  begin
    Result:=Jednotka(KodJednotky,CisloJednotky);
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

  constructor TText.Create(p_x_zac,p_y_zac: Integer; p_text: string; p_velkost: Integer; p_nastred: Boolean; p_cjednotky: Integer);
  begin
    inherited Create(p_cjednotky);

    t_x_zac:=p_x_zac;
    t_y_zac:=p_y_zac;
    t_text:=p_text;
    t_nastred:=p_nastred;
    t_velkost:=p_velkost;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TText.Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y: Integer;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon,False,False);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon,False,False);

    p_plan.Pen.Color:=clWhite;
    p_plan.Brush.Color:=clBlack;
    p_plan.Font.Color:=clWhite;
    p_plan.Font.Size:=t_velkost;

    if t_nastred then
    begin
      zac_x:=zac_x-(p_plan.TextWidth(t_text) div 2);    
      zac_y:=zac_y-(p_plan.TextHeight(t_text) div 2);
    end;

    p_plan.Pen.Width:=1;
    p_plan.TextOut(zac_x,zac_y,t_text);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_TEXT;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TText.DajNazov: string;
  begin
    Result:='Textový prvek '+t_text;
  end;

  //**************************************************************************//

  constructor TSulibrk.Create(p_x_zac,p_y_zac: Integer; p_cjednotky: Integer);
  begin
    inherited Create(p_cjednotky);

    t_x_zac:=p_x_zac;
    t_y_zac:=p_y_zac;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TSulibrk.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_SULIBRK;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TSulibrk.Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y: Integer;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon,False,False);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_x_zac,p_plan_x_kon,False,False);

    p_plan.Pen.Width:=1;

    if (SecondOf(Now) mod 4)<2 then
    begin
      p_plan.Pen.Color:=clRed;
      p_plan.Brush.Color:=clRed;

      p_plan.Rectangle(zac_x,zac_y,zac_x+30,zac_y+10);

      p_plan.Pen.Color:=clLime;
      p_plan.Brush.Color:=clLime;

      p_plan.Rectangle(zac_x,zac_y+10,zac_x+30,zac_y+20);

      p_plan.Pen.Color:=clBlue;
      p_plan.Brush.Color:=clBlue;

      p_plan.Rectangle(zac_x,zac_y+20,zac_x+30,zac_y+30);
    end
    else
    begin
      p_plan.Pen.Color:=clRed;
      p_plan.Brush.Color:=clRed;

      p_plan.Rectangle(zac_x,zac_y,zac_x+10,zac_y+30);

      p_plan.Pen.Color:=clLime;
      p_plan.Brush.Color:=clLime;

      p_plan.Rectangle(zac_x+10,zac_y,zac_x+20,zac_y+30);

      p_plan.Pen.Color:=clBlue;
      p_plan.Brush.Color:=clBlue;

      p_plan.Rectangle(zac_x+20,zac_y,zac_x+30,zac_y+30);    
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TSulibrk.DajNazov: string;
  begin
    Result:='Kontrolní prvek';
  end;

  //**************************************************************************//

  constructor TKolajCiara.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer);
  begin
    inherited Create(p_cjednotky);

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

  procedure TKolajCiara.Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon,True,False);
    kon_x:=PercentaNaPixely(t_x_kon,p_plan_x_zac,p_plan_x_kon,True,False);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon,False,True);
    kon_y:=PercentaNaPixely(t_y_kon,p_plan_y_zac,p_plan_y_kon,False,True);

    if t_zaver in [ZVR_RUCNY,ZVR_PREDBEZNY] then
    begin
      p_plan.Pen.Color:=clAqua;
      p_plan.Brush.Color:=clAqua;
    end
    else if t_zaver=ZVR_VLAKOVA then
    begin
      p_plan.Pen.Color:=clLime;
      p_plan.Brush.Color:=clLime;
    end
    else if t_zaver=ZVR_POSUNOVA then
    begin
      p_plan.Pen.Color:=clWhite;
      p_plan.Brush.Color:=clWhite;
    end
    else
    begin
      p_plan.Pen.Color:=clGray;
      p_plan.Brush.Color:=clGray;
    end;

    if JeZdroj then p_plan.Pen.Width:=9
    else p_plan.Pen.Width:=5;

    p_plan.MoveTo(zac_x,zac_y);
    p_plan.LineTo(kon_x,kon_y);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TKolajCiara.DajNazov: string;
  begin
    Result:='Ko¾aj '+t_cislo;
  end;

  //**************************************************************************//

  constructor TNavestidlo.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_cjednotky: Integer);
  begin
    inherited Create(p_cjednotky);

    t_x_zac:=p_x_zac;
    t_x_kon:=p_x_kon;
    t_y_zac:=p_y_zac;
    t_y_kon:=p_y_kon;
    t_cislo:=p_cislo;
  end;

  //**************************************************************************//

  procedure TNavestidloHlavne.Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    poly: array of TPoint;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon,True,False);
    kon_x:=PercentaNaPixely(t_x_kon,p_plan_x_zac,p_plan_x_kon,True,False);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon,False,True);
    kon_y:=PercentaNaPixely(t_y_kon,p_plan_y_zac,p_plan_y_kon,False,True);

    SetLength(poly,3);

    poly[0]:=Point(zac_x,zac_y);
    poly[1]:=Point(zac_x,kon_y);
    poly[2]:=Point(kon_x,(zac_y+kon_y) div 2);
    
    p_plan.Pen.Width:=2;

    if t_je_zdroj then
    begin
      if t_je_zdroj_posun then p_plan.Pen.Color:=clWhite
      else p_plan.Pen.Color:=clLime;
    end
    else p_plan.Pen.Color:=clGray;
    p_plan.Brush.Color:=clGray;
    
    p_plan.Polygon(poly);
  end;
  
  //**************************************************************************//

  constructor TVyhybka.Create(p_x_hrot,p_y_hrot,p_x_rovno,p_y_rovno,p_x_odboc,p_y_odboc: Integer; p_cislo: string; p_adresa: Integer; p_otocit_pohohu: Boolean; p_kolaj_hrot,p_kolaj_rovno,p_kolaj_odboc: TKolajCiara; p_cjednotky: Integer);
  begin
    inherited Create(p_cjednotky);
  
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

  procedure TVyhybka.Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    hrot_x,rovno_x,odboc_x,hrot_y,rovno_y,odboc_y: Integer;
    kolaj_zaver: TKolajCiara;
  begin
    hrot_x:=PercentaNaPixely(t_x_hrot,p_plan_x_zac,p_plan_x_kon,True,False);
    rovno_x:=PercentaNaPixely(t_x_rovno,p_plan_x_zac,p_plan_x_kon,True,False);
    odboc_x:=PercentaNaPixely(t_x_odboc,p_plan_x_zac,p_plan_x_kon,True,False);
    hrot_y:=PercentaNaPixely(t_y_hrot,p_plan_y_zac,p_plan_y_kon,False,True);
    rovno_y:=PercentaNaPixely(t_y_rovno,p_plan_y_zac,p_plan_y_kon,False,True);
    odboc_y:=PercentaNaPixely(t_y_odboc,p_plan_y_zac,p_plan_y_kon,False,True);

    p_plan.Pen.Width:=5;

    if t_poloha in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then kolaj_zaver:=t_kolaj_rovno
    else if t_poloha in [VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then kolaj_zaver:=t_kolaj_odboc
    else kolaj_zaver:=nil;

    if(kolaj_zaver<>nil) and (kolaj_zaver.Zaver=ZVR_POSUNOVA) then
    begin
      p_plan.Pen.Color:=clWhite;
      p_plan.Brush.Color:=clWhite;
    end
    else if(kolaj_zaver<>nil) and (kolaj_zaver.Zaver=ZVR_VLAKOVA) then
    begin
      p_plan.Pen.Color:=clLime;
      p_plan.Brush.Color:=clLime;
    end
    else
    begin
      if t_poloha in [VPO_ROVNO_OTAZNIK,VPO_ODBOCKA_OTAZNIK] then p_plan.Pen.Color:=clYellow
      else p_plan.Pen.Color:=clGrayText;;
    end;


    if t_poloha in [VPO_NEZNAMA,VPO_ROVNO,VPO_ROVNO_OTAZNIK] then
    begin
      p_plan.MoveTo(hrot_x,hrot_y);
      p_plan.LineTo(rovno_x,rovno_y);
    end;

    if t_poloha in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then
    begin
      p_plan.MoveTo(hrot_x,hrot_y);
      p_plan.LineTo(odboc_x,odboc_y);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TVyhybka.DajNazov: string;
  begin
    Result:='Výhybka '+t_cislo;
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
    Result:=((t_kolaj_hrot=nil) or (t_kolaj_hrot.JeVolna)) and ((t_kolaj_rovno=nil) or (t_kolaj_rovno.JeVolna)) and ((t_kolaj_odboc=nil) or (t_kolaj_odboc.JeVolna))
  end;

  //**************************************************************************//

  constructor TNavestidloVchodove.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adr_cervena,p_adr_horna_zlta,p_adr_horna_zlta_kmit,p_adr_zelena,p_adr_biela_kmit,p_adr_dolna_zlta,p_adr_predvest_zlta,p_adr_predvest_zlta_kmit,p_adr_predvest_zelena,p_cjednotky: Integer);
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky);

    t_adr_cervena:=p_adr_cervena;
    t_adr_horna_zlta:=p_adr_horna_zlta;
    t_adr_horna_zlta_kmit:=p_adr_horna_zlta_kmit;
    t_adr_zelena:=p_adr_zelena;
    t_adr_biela_kmit:=p_adr_biela_kmit;
    t_adr_dolna_zlta:=p_adr_dolna_zlta;
    t_adr_predvest_zlta:=p_adr_predvest_zlta;
    t_adr_predvest_zlta_kmit:=p_adr_predvest_zlta_kmit;
    t_adr_predvest_zelena:=p_adr_predvest_zelena;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_NAVESTIDLOVCHODOVE;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloVchodove.DajNazov: string;
  begin
    Result:='Náv. vch. '+t_cislo;
  end;

  //**************************************************************************//

  constructor TNavestidloOdchodove.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adr_cervena,p_adr_zelena,p_adr_dolna_zlta,p_adr_biela,p_adr_biela_kmit,p_cjednotky: Integer);
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky);
  
    t_adr_cervena:=p_adr_cervena;
    t_adr_zelena:=p_adr_zelena;
    t_adr_dolna_zlta:=p_adr_dolna_zlta;
    t_adr_biela:=p_adr_biela;
    t_adr_biela_kmit:=p_adr_biela_kmit;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_NAVESTIDLOODCHODOVE;  
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloOdchodove.DajNazov: string;
  begin
    Result:='Náv. odch. '+t_cislo;
  end;

  //**************************************************************************//

  constructor TNavestidloZriadovacie.Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon: Integer; p_cislo: string; p_adr_biela,p_adr_modra,p_cjednotky: Integer);
  begin
    inherited Create(p_x_zac,p_x_kon,p_y_zac,p_y_kon,p_cislo,p_cjednotky);

    t_adr_biela:=p_adr_biela;
    t_adr_modra:=p_adr_modra;
  
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.DajKodJednotky: TKodJednotky;
  begin
    Result:=KJ_NAVESTIDLOZRIADOVACIE;  
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TNavestidloZriadovacie.Vykresli(p_plan: TCanvas; p_plan_x_zac,p_plan_x_kon,p_plan_y_zac,p_plan_y_kon: Integer);
  var
    zac_x,zac_y,kon_x,kon_y: Integer;
    poly: array of TPoint;
  begin
    zac_x:=PercentaNaPixely(t_x_zac,p_plan_x_zac,p_plan_x_kon,True,False);
    kon_x:=PercentaNaPixely(t_x_kon,p_plan_x_zac,p_plan_x_kon,True,False);
    zac_y:=PercentaNaPixely(t_y_zac,p_plan_y_zac,p_plan_y_kon,False,True);
    kon_y:=PercentaNaPixely(t_y_kon,p_plan_y_zac,p_plan_y_kon,False,True);

    SetLength(poly,6);

    if(zac_x<kon_x) then
    begin
      poly[0]:=Point(zac_x,zac_y);
      poly[1]:=Point(zac_X+9,zac_y);
      poly[2]:=Point(kon_x,(zac_y+kon_y) div 2);
      poly[3]:=Point(zac_x+9,kon_y);
      poly[4]:=Point(zac_x,kon_y);
      poly[5]:=Point(kon_x-9,(zac_y+kon_y) div 2);
    end
    else
    begin
      poly[0]:=Point(zac_x,zac_y);
      poly[1]:=Point(zac_x-9,zac_y);
      poly[2]:=Point(kon_x,(zac_y+kon_y) div 2);
      poly[3]:=Point(zac_x-9,kon_y);
      poly[4]:=Point(zac_x,kon_y);
      poly[5]:=Point(kon_x+9,(zac_y+kon_y) div 2);
    end;

    p_plan.Pen.Width:=2;

    if(t_je_zdroj) then p_plan.Pen.Color:=clWhite
    else p_plan.Pen.Color:=clGray;

    p_plan.Brush.Color:=clGray;
    
    p_plan.Polygon(poly);
  end;  

  //////////////////////////////////////////////////////////////////////////////

  function TNavestidloZriadovacie.DajNazov: string;
  begin
    Result:='Náv. zr. '+t_cislo;
  end;
end.
