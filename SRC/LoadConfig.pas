unit LoadConfig;

interface
  uses ipwXmlp, LogikaStavadlo, StavadloObjekty, Cesta;

  type TConfigLoader=class(TObject)
    private
      t_nazov: string;

      function Chyba(p_text: string): Boolean;

      function NacitajKonfiguraciuPlanKolCiara(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuPlanNavestidloVchodove(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
      function NacitajKonfiguraciuPlanNavestidloZriadovacie(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
      function NacitajKonfiguraciuPlanVyhybka(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
      function NacitajKonfiguraciuPlanNavestidloOdchodove(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
      function NacitajKonfiguraciuPlanText(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
      function NacitajKonfiguraciuPlanSulibrk(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      

      function NacitajKonfiguraciuPlanDopravna(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuHitBox(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuCestaZdroj(p_cesta: TCesta; p_poradie,p_poradie_zdroj: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuCestaCiel(p_cesta: TCesta; p_poradie,p_poradie_ciel: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuCestaKolaj(p_cesta: TCesta; p_poradie,p_poradie_kolaj: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuCestaVyhybka(p_cesta: TCesta; p_poradie,p_poradie_vyhybka: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuCesta(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuZlozenaZdroj(p_cesta: TZlozenaCesta; p_poradie,p_poradie_zdroj: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuZlozenaCiel(p_cesta: TZlozenaCesta; p_poradie,p_poradie_ciel: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuZlozenaCesta(p_cesta: TZlozenaCesta; p_poradie,p_poradie_ciel: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuZlozena(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuPlan(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuHitBoxy(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuZaverovka(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
      function NacitajKonfiguraciuZlozene(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

      function NacitajKonfiguraciuObsah(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;

    public
      constructor Create(p_nazov: string);
      function NacitajKonfiguraciu(p_ciel: TLogikaES): Boolean;
  end;

implementation
  uses SysUtils, Forms, GUI1, Types;

  constructor TConfigLoader.Create(p_nazov: string);
  begin
    inherited Create;

    t_nazov:=p_nazov;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.Chyba(p_text: string): Boolean;
  begin
    Form1.VypisChybu('Chyba pri na��tan� konfigur�cie: '+p_text);

    Result:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuPlanKolCiara(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    ciara: TKolajCiara;
    x_zac,x_kon,y_zac,y_kon: Integer;
    cislo: string;
    cjednotky: Integer;
    i: Integer;
  begin
    x_zac:=-1;
    x_kon:=-1;
    y_zac:=-1;
    y_kon:=-1;
    cislo:='???';
    cjednotky:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xzac' then x_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xkon' then x_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yzac' then y_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='ykon' then y_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cislo' then cislo:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    if(x_zac>=0) and (x_kon>=0) and (y_zac>=0) and (y_kon>=0) and (cislo<>'???') and (cjednotky>0) then
    begin
      ciara:=TKolajCiara.Create(x_zac,x_kon,y_zac,y_kon,cislo,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(ciara);
      Result:=True;
    end
    else Result:=Chyba('Chybn� ko�ajov� �iara �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuPlanNavestidloVchodove(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    navestidlo: TNavestidloVchodove;
    x_zac,x_kon,y_zac,y_kon: Integer;
    cislo: string;
    cjednotky: Integer;
    adresy: TNavestidloVchodoveAdresy;
    i: Integer;
    j: TNavestidloVchodoveFarba;
  begin
    x_zac:=-1;
    x_kon:=-1;
    y_zac:=-1;
    y_kon:=-1;
    cislo:='???';
    cjednotky:=0;

    for j := Low(adresy) to High(adresy) do adresy[j]:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xzac' then x_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xkon' then x_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yzac' then y_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='ykon' then y_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cislo' then cislo:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cervena' then adresy[NVF_C]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='hornazlta' then adresy[NVF_HZ]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='hornazltakmit' then adresy[NVF_HZ_KMIT]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='zelena' then adresy[NVF_Z]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='bielakmit' then adresy[NVF_B_KMIT]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='dolnazlta' then adresy[NVF_DZ]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='predvestzlta' then adresy[NVF_PREDV_HZ]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='predvestzltakmit' then adresy[NVF_PREDV_HZ_KMIT]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='predvestzelena' then adresy[NVF_PREDV_Z]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    if(x_zac>=0) and (x_kon>=0) and (y_zac>=0) and (y_kon>=0) and (cislo<>'???') and (cjednotky>0) then
    begin
      navestidlo:=TNavestidloVchodove.Create(x_zac,x_kon,y_zac,y_kon,cislo,adresy,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(navestidlo);
      Result:=True;
    end
    else Result:=Chyba('Chybn� vchodov� n�vestidlo �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuPlanNavestidloZriadovacie(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    navestidlo: TNavestidloZriadovacie;
    x_zac,x_kon,y_zac,y_kon: Integer;
    cislo: string;
    cjednotky: Integer;
    adresy: TNavestidloZriadovacieAdresy;
    i: Integer;
    j: TNavestidloZriadovacieFarba;
  begin
    x_zac:=-1;
    x_kon:=-1;
    y_zac:=-1;
    y_kon:=-1;
    cislo:='???';
    cjednotky:=0;

    for j := Low(adresy) to High(adresy) do adresy[j]:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xzac' then x_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xkon' then x_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yzac' then y_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='ykon' then y_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cislo' then cislo:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='biela' then adresy[NZF_B]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='modra' then adresy[NZF_M]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;
      
      
    if(x_zac>=0) and (x_kon>=0) and (y_zac>=0) and (y_kon>=0) and (cislo<>'???') and (cjednotky>0) then
    begin
      navestidlo:=TNavestidloZriadovacie.Create(x_zac,x_kon,y_zac,y_kon,cislo,adresy,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(navestidlo);
      Result:=True;
    end
    else Result:=Chyba('Chybn� vchodov� n�vestidlo �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////
  
  function TConfigLoader.NacitajKonfiguraciuPlanVyhybka(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
  var
    vyhybka: TVyhybka;
    x_hrot,y_hrot,x_rovno,y_rovno,x_odboc,y_odboc: Integer;
    cislo: string;
    cjednotky: Integer;
    adresa: Integer;
    otocit: Boolean;
    k_hrot,k_rovno,k_odboc: TKolajCiara;
    i: Integer;
  begin
    x_hrot:=-1;
    y_hrot:=-1;
    x_rovno:=-1;
    y_rovno:=-1;
    x_odboc:=-1;
    y_odboc:=-1;
    cislo:='???';
    cjednotky:=0;
    adresa:=0;
    otocit:=False;
    k_hrot:=nil;
    k_rovno:=nil;
    k_odboc:=nil;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xhrot' then x_hrot:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yhrot' then y_hrot:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xrovno' then x_rovno:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yrovno' then y_rovno:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xodboc' then x_odboc:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yodboc' then y_odboc:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cislo' then cislo:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='adresa' then adresa:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='invertovat' then otocit:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='kolajhrot' then k_hrot:=p_ciel.DajObjekt(KJ_KOLAJCIARA,StrToIntDef(p_zdroj.AttrValue[i],-1)) as TKolajCiara
      else if p_zdroj.AttrName[i]='kolajrovno' then k_rovno:=p_ciel.DajObjekt(KJ_KOLAJCIARA,StrToIntDef(p_zdroj.AttrValue[i],-1)) as TKolajCiara
      else if p_zdroj.AttrName[i]='kolajodboc' then k_odboc:=p_ciel.DajObjekt(KJ_KOLAJCIARA,StrToIntDef(p_zdroj.AttrValue[i],-1)) as TKolajCiara
    end;

    if(x_hrot>=0) and (y_hrot>=0) and (x_rovno>=0) and (y_rovno>=0) and (x_odboc>=0) and (y_odboc>=0) and (cislo<>'???') and (cjednotky>0) and (k_hrot<>nil) and (k_rovno<>nil) and (k_odboc<>nil) then
    begin
      vyhybka:=TVyhybka.Create(x_hrot,y_hrot,x_rovno,y_rovno,x_odboc,y_odboc,cislo,adresa,otocit,k_hrot,k_rovno,k_odboc,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(vyhybka);
      Result:=True;
    end
    else Result:=Chyba('Chybn� v�hybka �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuPlanNavestidloOdchodove(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    navestidlo: TNavestidloOdchodove;
    x_zac,x_kon,y_zac,y_kon: Integer;
    cislo: string;
    cjednotky: Integer;
    spojit_zelenu,bez_zltej: Boolean;
    adresy: TNavestidloOdchodoveAdresy;
    i: Integer;
    j: TNavestidloOdchodoveFarba;
  begin
    x_zac:=-1;
    x_kon:=-1;
    y_zac:=-1;
    y_kon:=-1;
    cislo:='???';
    cjednotky:=0;
    spojit_zelenu:=False;
    bez_zltej:=False;

    for j := Low(adresy) to High(adresy) do adresy[j]:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xzac' then x_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xkon' then x_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yzac' then y_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='ykon' then y_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cislo' then cislo:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='spojzelenu' then spojit_zelenu:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='bezzltej' then bez_zltej:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='cervena' then adresy[NOF_C]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='zelena' then adresy[NOF_Z]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='dolnazlta' then adresy[NOF_DZ]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='biela' then adresy[NOF_B]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='bielakmit' then adresy[NOF_B_KMIT]:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;
      
    if(x_zac>=0) and (x_kon>=0) and (y_zac>=0) and (y_kon>=0) and (cislo<>'???') and (cjednotky>0) then
    begin
      navestidlo:=TNavestidloOdchodove.Create(x_zac,x_kon,y_zac,y_kon,cislo,spojit_zelenu,bez_zltej,adresy,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(navestidlo);
      Result:=True;
    end
    else Result:=Chyba('Chybn� odchodov� n�vestidlo �. '+IntToStr(p_poradie));    
  end;

  //////////////////////////////////////////////////////////////////////////////
  
  function TConfigLoader.NacitajKonfiguraciuPlanText(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
  var
    text: TText;
    x_zac,y_zac: Integer;
    htext: string;
    cjednotky: Integer;
    nastred: Boolean;
    velkost: Integer;
    i: Integer;
  begin
    x_zac:=-1;
    y_zac:=-1;
    htext:='???';
    cjednotky:=0;
    nastred:=False;
    velkost:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xzac' then x_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yzac' then y_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='text' then htext:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='velkost' then velkost:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='nastred' then nastred:=p_zdroj.AttrValue[i]='True'
    end;

    if(x_zac>=0) and (y_zac>=0) and (cjednotky>0) then
    begin      
      text:=TText.Create(x_zac,y_zac,htext,velkost,nastred,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(text);
      Result:=True;
    end
    else Result:=Chyba('Chybn� polo�ka textu �. '+IntToStr(p_poradie));    
  end;

  //////////////////////////////////////////////////////////////////////////////
  
  function TConfigLoader.NacitajKonfiguraciuPlanSulibrk(p_dopravna: TDopravna; p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;      
  var
    sulibrk: TSulibrk;
    x,y: Integer;
    cjednotky: Integer;
    i: Integer;
  begin
    x:=-1;
    y:=-1;
    cjednotky:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='x' then x:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='y' then y:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    if(x>=0) and (y>=0) and (cjednotky>0) then
    begin
      sulibrk:=TSulibrk.Create(x,y,cjednotky,p_dopravna);
      p_ciel.PridajObjekt(sulibrk);
      Result:=True;
    end
    else Result:=Chyba('Chybn� �ulibrk �. '+IntToStr(p_poradie));    
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuPlanDopravna(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    poc: Integer;
    i: Integer;
    nazov: string;
    dnazov,dskratka: string;
    dlcislo: Integer;
    dopravna: TDopravna;
    poradie_kolciara: Integer;
    poradie_nav_vchodove: Integer;
    poradie_nav_zriadovacie: Integer;
    poradie_vyhybka: Integer;
    poradie_nav_odchodove: Integer;
    poradie_text: Integer;
    poradie_sulibrk: Integer;
  begin
    dnazov:='';
    dskratka:='';
    dlcislo:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='nazov' then dnazov:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='skratka' then dskratka:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='lcislo' then dlcislo:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;
        
    dopravna:=TDopravna.Create(dnazov,dskratka,dlcislo);
    p_ciel.PridajDopravnu(dopravna);
    
    poradie_kolciara:=1;
    poradie_nav_vchodove:=1;
    poradie_nav_zriadovacie:=1;
    poradie_vyhybka:=1;
    poradie_nav_odchodove:=1;
    poradie_text:=1;
    poradie_sulibrk:=1;
  
    poc:=p_zdroj.XChildrenCount;

    Result:=True;
    
    for i := 0 to poc-1 do
    begin
      nazov:=p_zdroj.XChildName[i];

      if(nazov='KolajCiara') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/KolajCiara['+IntToStr(poradie_kolciara)+']';
        Result:=NacitajKonfiguraciuPlanKolCiara(dopravna,poradie_kolciara,p_zdroj,p_ciel);
        Inc(poradie_kolciara);
      end
      else if(nazov='NavestidloVchodove') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/NavestidloVchodove['+IntToStr(poradie_nav_vchodove)+']';
        Result:=NacitajKonfiguraciuPlanNavestidloVchodove(dopravna,poradie_nav_vchodove,p_zdroj,p_ciel);
        Inc(poradie_nav_vchodove);
      end
      else if(nazov='NavestidloZriadovacie') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/NavestidloZriadovacie['+IntToStr(poradie_nav_zriadovacie)+']';
        Result:=NacitajKonfiguraciuPlanNavestidloZriadovacie(dopravna,poradie_nav_zriadovacie,p_zdroj,p_ciel);
        Inc(poradie_nav_zriadovacie);
      end
      else if(nazov='Vyhybka') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/Vyhybka['+IntToStr(poradie_vyhybka)+']';
        Result:=NacitajKonfiguraciuPlanVyhybka(dopravna,poradie_vyhybka,p_zdroj,p_ciel);
        Inc(poradie_vyhybka);
      end
      else if(nazov='NavestidloOdchodove') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/NavestidloOdchodove['+IntToStr(poradie_nav_odchodove)+']';
        Result:=NacitajKonfiguraciuPlanNavestidloOdchodove(dopravna,poradie_nav_odchodove,p_zdroj,p_ciel);
        Inc(poradie_nav_odchodove);
      end
      else if(nazov='Text') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/Text['+IntToStr(poradie_text)+']';
        Result:=NacitajKonfiguraciuPlanText(dopravna,poradie_text,p_zdroj,p_ciel);
        Inc(poradie_text);
      end
      else if(nazov='Sulibrk') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']/Sulibrk['+IntToStr(poradie_sulibrk)+']';
        NacitajKonfiguraciuPlanSulibrk(dopravna,poradie_sulibrk,p_zdroj,p_ciel);
        Inc(poradie_sulibrk);
      end
      else Result:=Chyba('Neplatn� element '+nazov+'v pl�ne dopravne '+IntToStr(p_poradie));

      p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(p_poradie)+']';

      if not Result then break;
    end;    
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuPlan(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    poc: Integer;
    i: Integer;
    poradie_dopravna: Integer; 
    nazov: string;
  begin
    poradie_dopravna:=1;
  
    poc:=p_zdroj.XChildrenCount;

    Result:=True;
    
    for i := 0 to poc-1 do
    begin
      nazov:=p_zdroj.XChildName[i];
    
      if(nazov='Dopravna') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Plan/Dopravna['+IntToStr(poradie_dopravna)+']';
        NacitajKonfiguraciuPlanDopravna(poradie_dopravna,p_zdroj,p_ciel);
        Inc(poradie_dopravna);
      end;
  
      p_zdroj.XPath:='/Konfiguracia/Plan/';

      if not Result then break;
    end;    
  end;
  

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuHitBox(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    v_hitbox: THitBox;
    x_zac,x_kon,y_zac,y_kon: Integer;
    kodjednotky: TKodJednotky;
    cjednotky: Integer;
    objekt: TStavadloObjekt;
    i: Integer;
  begin
    x_zac:=-1;
    x_kon:=-1;
    y_zac:=-1;
    y_kon:=-1;
    kodjednotky:=KJ_KOLAJCIARA;
    cjednotky:=0;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='xzac' then x_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='xkon' then x_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='yzac' then y_zac:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='ykon' then y_kon:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='kodjednotky' then kodjednotky:=KodJednotkyXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    objekt:=p_ciel.DajObjekt(kodjednotky,cjednotky);

    if(x_zac>=0) and (x_kon>=0) and (y_zac>=0) and (y_kon>=0) and (objekt<>nil) then
    begin
      v_hitbox:=HitBox(Rect(x_zac,y_zac,x_kon,y_kon),p_ciel.DajObjekt(kodjednotky,cjednotky));
      p_ciel.PridajHitBox(v_hitbox);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� hitbox');
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuHitBoxy(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    poc: Integer;
    i: Integer;
    nazov: string;
  begin  
    poc:=p_zdroj.XChildrenCount;

    Result:=True;
    
    for i := 0 to poc-1 do
    begin
      nazov:=p_zdroj.XChildName[i];

      if(nazov='HitBox') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/HitBoxy/HitBox['+IntToStr(i+1)+']';
        Result:=NacitajKonfiguraciuHitBox(i+1,p_zdroj,p_ciel);
      end
      else Result:=Chyba('Neplatn� element '+nazov+'v hitboxoch');

      p_zdroj.XPath:='/Konfiguracia/HitBoxy';

      if not Result then break;
    end;    
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuCestaZdroj(p_cesta: TCesta; p_poradie,p_poradie_zdroj: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    kodjednotky: TKodJednotky;
    cjednotky: Integer;
    v_zdroj: TStavadloObjekt;
    i: Integer;
  begin
    kodjednotky:=KJ_KOLAJCIARA;
    cjednotky:=0;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='kodjednotky' then kodjednotky:=KodJednotkyXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    v_zdroj:=p_ciel.DajObjekt(kodjednotky,cjednotky);

    if(v_zdroj<>nil) then
    begin
      p_cesta.PridajZdroj(v_zdroj);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� zdroj �. '+IntToStr(p_poradie_zdroj)+' v cest� �. '+IntToStr(p_poradie));  
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuCestaCiel(p_cesta: TCesta; p_poradie,p_poradie_ciel: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    kodjednotky: TKodJednotky;
    cjednotky: Integer;
    v_ciel: TStavadloObjekt;
    i: Integer;
  begin
    kodjednotky:=KJ_KOLAJCIARA;
    cjednotky:=0;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='kodjednotky' then kodjednotky:=KodJednotkyXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1);
    end;

    v_ciel:=p_ciel.DajObjekt(kodjednotky,cjednotky);

    if(v_ciel<>nil) then
    begin
      p_cesta.PridajCiel(v_ciel);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� zdroj �. '+IntToStr(p_poradie_ciel)+' v cest� �. '+IntToStr(p_poradie));
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuCestaKolaj(p_cesta: TCesta; p_poradie,p_poradie_kolaj: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    cjednotky: Integer;
    presah: Boolean;
    v_kolaj: TKolajCiara;
    i: Integer;
  begin
    presah:=False;
    cjednotky:=0;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='presah' then presah:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1);
    end;

    v_kolaj:=p_ciel.DajObjekt(KJ_KOLAJCIARA,cjednotky) as TKolajCiara;

    if(v_kolaj<>nil) then
    begin
      p_cesta.PridajKolaj(v_kolaj,presah);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� ko�aj �. '+IntToStr(p_poradie_kolaj)+' v ceste �. '+IntToStr(p_poradie));
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuCestaVyhybka(p_cesta: TCesta; p_poradie,p_poradie_vyhybka: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    cjednotky: Integer;
    poloha: TVyhybkaPozicia;
    v_vyhybka: TVyhybka;
    i: Integer;
  begin
    poloha:=VPO_NEZNAMA;
    cjednotky:=0;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='pozicia' then poloha:=VyhybkaPoziciaXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1);
    end;

    v_vyhybka:=p_ciel.DajObjekt(KJ_VYHYBKA,cjednotky) as TVyhybka;

    if(v_vyhybka<>nil) and (poloha in [VPO_ROVNO,VPO_ODBOCKA]) then
    begin
      p_cesta.PridajVyhybku(v_vyhybka,poloha);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� v�hybka �. '+IntToStr(p_poradie_vyhybka)+' v ceste �. '+IntToStr(p_poradie));
  end;
  
  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuCesta(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    cesta: TCesta;
    vlakova,posunova: Boolean;
    znak: TCestaZnak;
    i,cislo: Integer;
    nazov: string;
    poradie_zdroj,poradie_ciel,poradie_kolaj,poradie_vyhybka: Integer;
    dalsie_kj: TKodJednotky;
    dalsie_cj: Integer;
    dalsie: TNavestidloHlavne;
  begin
    cislo:=-1;
    vlakova:=False;
    posunova:=False;
    znak:=CZ_40;
    dalsie_kj:=KJ_KOLAJCIARA;
    dalsie_cj:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='cislo' then cislo:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='vlakova' then vlakova:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='posunova' then posunova:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='znak' then znak:=CestaZnakText(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='dalsiekodjednotky' then dalsie_kj:=KodJednotkyXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='dalsiecjednotky' then dalsie_cj:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    if (dalsie_kj in [KJ_NAVESTIDLOVCHODOVE,KJ_NAVESTIDLOODCHODOVE]) and (dalsie_cj>0) then dalsie:=p_ciel.DajObjekt(dalsie_kj,dalsie_cj) as TNavestidloHlavne
    else dalsie:=nil;

    cesta:=TCesta.Create(cislo,vlakova,posunova,znak,dalsie);

    Result:=True;  

    poradie_zdroj:=1;
    poradie_ciel:=1;
    poradie_kolaj:=1;
    poradie_vyhybka:=1;
    
    for i := 0 to p_zdroj.XChildrenCount-1 do
    begin
      nazov:=p_zdroj.XChildName[i];

      if(nazov='Zdroj') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Zaverovka/Cesta['+IntToStr(p_poradie)+']/Zdroj['+IntToStr(poradie_zdroj)+']';
        Result:=NacitajKonfiguraciuCestaZdroj(cesta,p_poradie,poradie_zdroj,p_zdroj,p_ciel);
        Inc(poradie_zdroj);
      end
      else if(nazov='Ciel') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Zaverovka/Cesta['+IntToStr(p_poradie)+']/Ciel['+IntToStr(poradie_ciel)+']';
        Result:=NacitajKonfiguraciuCestaCiel(cesta,p_poradie,poradie_ciel,p_zdroj,p_ciel);
        Inc(poradie_ciel);
      end
      else if(nazov='Kolaj') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Zaverovka/Cesta['+IntToStr(p_poradie)+']/Kolaj['+IntToStr(poradie_kolaj)+']';
        Result:=NacitajKonfiguraciuCestaKolaj(cesta,p_poradie,poradie_kolaj,p_zdroj,p_ciel);
        Inc(poradie_kolaj);
      end
      else if(nazov='Vyhybka') then 
      begin
        p_zdroj.XPath:='/Konfiguracia/Zaverovka/Cesta['+IntToStr(p_poradie)+']/Vyhybka['+IntToStr(poradie_vyhybka)+']';
        Result:=NacitajKonfiguraciuCestaVyhybka(cesta,p_poradie,poradie_vyhybka,p_zdroj,p_ciel);
        Inc(poradie_vyhybka);
      end
      else Result:=Chyba('Neplatn� element '+nazov+'v ceste '+IntToStr(p_poradie));

      p_zdroj.XPath:='/Konfiguracia/Zaverovka/Cesta['+IntToStr(p_poradie)+']';

      if not Result then break;    
    end;
    
    p_ciel.PridajCestu(cesta);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuZaverovka(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    poc: Integer;
    i: Integer;
    nazov: string;
  begin
    poc:=p_zdroj.XChildrenCount;

    Result:=True;

    for i := 0 to poc-1 do
    begin
      nazov:=p_zdroj.XChildName[i];

      if(nazov='Cesta') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Zaverovka/Cesta['+IntToStr(i+1)+']';
        Result:=NacitajKonfiguraciuCesta(i+1,p_zdroj,p_ciel);
      end
      else Result:=Chyba('Neplatn� element '+nazov+'v z�verovke');

      p_zdroj.XPath:='/Konfiguracia/Zaverovka';

      if not Result then break;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuZlozenaZdroj(p_cesta: TZlozenaCesta; p_poradie,p_poradie_zdroj: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    kodjednotky: TKodJednotky;
    cjednotky: Integer;
    v_zdroj: TStavadloObjekt;
    i: Integer;
  begin
    kodjednotky:=KJ_KOLAJCIARA;
    cjednotky:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='kodjednotky' then kodjednotky:=KodJednotkyXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1)
    end;

    v_zdroj:=p_ciel.DajObjekt(kodjednotky,cjednotky);

    if(v_zdroj<>nil) then
    begin
      p_cesta.PridajZdroj(v_zdroj);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� zdroj �. '+IntToStr(p_poradie_zdroj)+' v makre �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuZlozenaCiel(p_cesta: TZlozenaCesta; p_poradie,p_poradie_ciel: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    kodjednotky: TKodJednotky;
    cjednotky: Integer;
    v_ciel: TStavadloObjekt;
    i: Integer;
  begin
    kodjednotky:=KJ_KOLAJCIARA;
    cjednotky:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='kodjednotky' then kodjednotky:=KodJednotkyXML(p_zdroj.AttrValue[i])
      else if p_zdroj.AttrName[i]='cjednotky' then cjednotky:=StrToIntDef(p_zdroj.AttrValue[i],-1);
    end;

    v_ciel:=p_ciel.DajObjekt(kodjednotky,cjednotky);

    if(v_ciel<>nil) then
    begin
      p_cesta.PridajCiel(v_ciel);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� zdroj �. '+IntToStr(p_poradie_ciel)+' v makre �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuZlozenaCesta(p_cesta: TZlozenaCesta; p_poradie,p_poradie_ciel: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    ccesty,poradie: Integer;
    v_cesta: TCesta;
    i: Integer;
  begin
    ccesty:=0;
    poradie:=0;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='poradie' then poradie:=StrToIntDef(p_zdroj.AttrValue[i],-1)
      else if p_zdroj.AttrName[i]='cislo' then ccesty:=StrToIntDef(p_zdroj.AttrValue[i],-1);
    end;

    v_cesta:=p_ciel.DajCestu(ccesty);

    if(v_cesta<>nil) then
    begin
      p_cesta.PridajCestu(v_cesta,poradie);
      Result:=True;
    end
    else Result:=Chyba('Neplatn� diel�ia cesta �. '+IntToStr(p_poradie_ciel)+' v makre �. '+IntToStr(p_poradie));
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuZlozena(p_poradie: Integer; p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    cesta: TZlozenaCesta;
    vlakova,posunova: Boolean;
    i: Integer;
    nazov: string;
    poradie_zdroj,poradie_ciel,poradie_cesta: Integer;
  begin
    vlakova:=False;
    posunova:=False;

    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='vlakova' then vlakova:=p_zdroj.AttrValue[i]='True'
      else if p_zdroj.AttrName[i]='posunova' then posunova:=p_zdroj.AttrValue[i]='True'
    end;

    cesta:=TZlozenaCesta.Create(vlakova,posunova);

    Result:=True;

    poradie_zdroj:=1;
    poradie_ciel:=1;
    poradie_cesta:=1;

    for i := 0 to p_zdroj.XChildrenCount-1 do
    begin
      nazov:=p_zdroj.XChildName[i];

      if(nazov='Zdroj') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Zlozene/Zlozena['+IntToStr(p_poradie)+']/Zdroj['+IntToStr(poradie_zdroj)+']';
        Result:=NacitajKonfiguraciuZlozenaZdroj(cesta,p_poradie,poradie_zdroj,p_zdroj,p_ciel);
        Inc(poradie_zdroj);
      end
      else if(nazov='Ciel') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Zlozene/Zlozena['+IntToStr(p_poradie)+']/Ciel['+IntToStr(poradie_ciel)+']';
        Result:=NacitajKonfiguraciuZlozenaCiel(cesta,p_poradie,poradie_ciel,p_zdroj,p_ciel);
        Inc(poradie_ciel);
      end
      else if(nazov='Cesta') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Zlozene/Zlozena['+IntToStr(p_poradie)+']/Cesta['+IntToStr(poradie_cesta)+']';
        Result:=NacitajKonfiguraciuZlozenaCesta(cesta,p_poradie,poradie_cesta,p_zdroj,p_ciel);
        Inc(poradie_cesta);
      end
      else Result:=Chyba('Neplatn� element '+nazov+'v makre '+IntToStr(p_poradie));

      p_zdroj.XPath:='/Konfiguracia/Zlozene/Zlozena['+IntToStr(p_poradie)+']';

      if not Result then break;
    end;

    p_ciel.PridajZlozenu(cesta);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuZlozene(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    poc: Integer;
    i: Integer;
    nazov: string;
  begin
    poc:=p_zdroj.XChildrenCount;

    Result:=True;

    for i := 0 to poc-1 do
    begin
      nazov:=p_zdroj.XChildName[i];

      if(nazov='Zlozena') then
      begin
        p_zdroj.XPath:='/Konfiguracia/Zlozene/Zlozena['+IntToStr(i+1)+']';
        Result:=NacitajKonfiguraciuZlozena(i+1,p_zdroj,p_ciel);
      end
      else Result:=Chyba('Neplatn� element '+nazov+'v zozname makier');

      p_zdroj.XPath:='/Konfiguracia/Zlozene';

      if not Result then break;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciuObsah(p_zdroj: TipwXMLp; p_ciel: TLogikaES): Boolean;
  var
    i: Integer;
    vyska,sirka: Integer;
    dopravne: Boolean;
    nazov: string;
  begin
    vyska:=0;
    sirka:=0;
    nazov:='';
    dopravne:=False;
  
    for i := 0 to p_zdroj.AttrCount-1 do
    begin
      if p_zdroj.AttrName[i]='vyska' then vyska:=StrToIntDef(p_zdroj.AttrValue[i],0)
      else if p_zdroj.AttrName[i]='sirka' then sirka:=StrToIntDef(p_zdroj.AttrValue[i],0)
      else if p_zdroj.AttrName[i]='nazov' then nazov:=p_zdroj.AttrValue[i]
      else if p_zdroj.AttrName[i]='nazvydopravni' then dopravne:=p_zdroj.AttrValue[i]='True';
    end;

    p_ciel.NastavParametre(vyska,sirka,nazov,dopravne);
  
    if p_zdroj.HasXPath('/Konfiguracia/Plan') then
    begin
      p_zdroj.XPath:='/Konfiguracia/Plan';
      Result:=NacitajKonfiguraciuPlan(p_zdroj,p_ciel);
      p_zdroj.XPath:='/Konfiguracia';
    end
    else Result:=Chyba('Ch�ba pl�n ko�ajiska');

    if Result and p_zdroj.HasXPath('/Konfiguracia/HitBoxy') then
    begin
      p_zdroj.XPath:='/Konfiguracia/HitBoxy';
      Result:=NacitajKonfiguraciuHitBoxy(p_zdroj,p_ciel);
      p_zdroj.XPath:='/Konfiguracia';
    end
    else if Result then Result:=Chyba('Ch�ba defin�cia hitboxov');

    if Result and p_zdroj.HasXPath('/Konfiguracia/Zaverovka') then
    begin
      p_zdroj.XPath:='/Konfiguracia/Zaverovka';
      Result:=NacitajKonfiguraciuZaverovka(p_zdroj,p_ciel);
      p_zdroj.XPath:='/Konfiguracia';
    end
    else if Result then Result:=Chyba('Ch�ba z�verov� tabu�ka');

    if Result and p_zdroj.HasXPath('/Konfiguracia/Zlozene') then
    begin
      p_zdroj.XPath:='/Konfiguracia/Zlozene';
      Result:=NacitajKonfiguraciuZlozene(p_zdroj,p_ciel);
      p_zdroj.XPath:='/Konfiguracia';
    end
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TConfigLoader.NacitajKonfiguraciu(p_ciel: TLogikaES): Boolean;
  var
    parser: TipwXMLp;
  begin
    parser:=TipwXMLp.Create(nil);
    try
      parser.ParseFile(t_nazov);

      if parser.HasXPath('/Konfiguracia') then
      begin
        parser.XPath:='/Konfiguracia';
        Result:=NacitajKonfiguraciuObsah(parser,p_ciel);
      end
      else Result:=Chyba('V konfiguraci chyb� v�choz� prvek XML');
    finally
      parser.Free;
    end;
  end;

end.