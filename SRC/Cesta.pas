unit Cesta;

interface
  uses Generics.Collections, StavadloObjekty;

  type TCestaVyhybka=record
    Vyhybka: TVyhybka;
    Poloha: TVyhybkaPozicia;
  end;

  type TCestaKolaj=record
    Kolaj: TKolajCiara;
    Presah: Boolean;
  end;

  type TCestaZnak=(CZ_TRATOVA,CZ_40);

  function CestaZnakText(p_hodnota: string): TCestaZnak;

  type TCesta=class(TObject)
    private
      t_cislo: Integer;

      t_vlakova: Boolean;
      t_posunova: Boolean;
      t_znak: TCestaZnak;
      t_dalsie: TNavestidloHlavne;

      t_aktual_posun: Boolean;
      t_aktual_zdroj: TStavadloObjekt;

      t_navest: TNavest;

      t_zdroje: TList<TStavadloObjekt>;
      t_ciele: TList<TStavadloObjekt>;
      t_kolaje: TList<TCestaKolaj>;
      t_vyhybky: TList<TCestaVyhybka>;

      t_zavreta: Boolean;

      function DajNavestidlo: TNavestidlo;
      procedure VyberVolnoznak(p_navestidlo: TNavestidlo);
    public
      property Zavreta: Boolean read t_zavreta;
      property Cislo: Integer read t_cislo;
      property Dalsie: TNavestidloHlavne read t_dalsie;

      constructor Create(p_cislo: Integer; p_vlakova: Boolean; p_posunova: Boolean; p_znak: TCestaZnak; p_dalsie: TNavestidloHlavne);

      procedure PridajZdroj(p_zdroj: TStavadloObjekt);
      procedure PridajCiel(p_ciel: TStavadloObjekt);
      procedure PridajKolaj(p_kolaj: TKolajCiara; p_presah: Boolean);
      procedure PridajVyhybku(p_vyhybka: TVyhybka; p_pozica: TVyhybkaPozicia);

      function OverVolbu(p_posun: Boolean; p_zdroj: TStavadloObjekt; p_ciel: TStavadloObjekt): Boolean;
      function OverZdroj(p_objekt: TStavadloObjekt; p_posun: Boolean): Boolean;

      procedure PridajVolbu(p_posun: Boolean; p_volby: TList<TPair<TStavadloObjekt,Boolean>>);

      procedure Zapevni;
      function Zavri(p_posun: Boolean; p_zdroj: TStavadloObjekt): Boolean;
      procedure Postav;

      function Postavena: Boolean;
      function VolnoZnak(p_natvrdo: Boolean): Boolean;

      procedure AktualizujVolnoznak(p_natvrdo: Boolean);
      procedure ZrusVolnoznak;

      procedure Zrus;

      destructor Destroy; override;
  end;

  //**************************************************************************//

  type TZlozenaCesta=class(TObject)
    private
      t_vlakova: Boolean;
      t_posunova: Boolean;

      t_zdroje: TList<TStavadloObjekt>;
      t_ciele: TList<TStavadloObjekt>;

      t_cesty: TList<TCesta>;

    public
      constructor Create(p_vlakova,p_posunova: Boolean);

      procedure PridajZdroj(p_zdroj: TStavadloObjekt);
      procedure PridajCiel(p_ciel: TStavadloObjekt);
      procedure PridajCestu(p_cesta: TCesta; p_poradie: Integer);

      function OverVolbu(p_posun: Boolean; p_zdroj: TStavadloObjekt; p_ciel: TStavadloObjekt): Boolean;
      procedure PridajVolbu(p_posun: Boolean; p_volby: TList<TPair<TStavadloObjekt,Boolean>>);

      destructor Destroy; override;
  end;


implementation
  uses ComPort, LogikaStavadlo;

  function CestaZnakText(p_hodnota: string): TCestaZnak;
  begin
    if p_hodnota='CZ_TRATOVA' then Result:=CZ_TRATOVA
    else Result:=CZ_40;
  end;

  //**************************************************************************//

  constructor TCesta.Create(p_cislo: Integer; p_vlakova: Boolean; p_posunova: Boolean; p_znak: TCestaZnak; p_dalsie: TNavestidloHlavne);
  begin
    t_cislo:=p_cislo;

    t_vlakova:=p_vlakova;
    t_posunova:=p_posunova;
    t_znak:=p_znak;
    t_dalsie:=p_dalsie;

    t_aktual_posun:=False;
    t_aktual_zdroj:=nil;

    t_navest:=CN_NEZNAMA;

    t_zdroje:=TList<TStavadloObjekt>.Create;
    t_ciele:=TList<TStavadloObjekt>.Create;
    t_kolaje:=TList<TCestaKolaj>.Create;
    t_vyhybky:=TList<TCestaVyhybka>.Create;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.PridajZdroj(p_zdroj: TStavadloObjekt);
  begin
    t_zdroje.Add(p_zdroj);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.PridajCiel(p_ciel: TStavadloObjekt);
  begin
    t_ciele.Add(p_ciel);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.PridajKolaj(p_kolaj: TKolajCiara; p_presah: Boolean);
  var
    kolaj: TCestaKolaj;
  begin
    kolaj.Kolaj:=p_kolaj;
    kolaj.Presah:=p_presah;

    t_kolaje.Add(kolaj);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.PridajVyhybku(p_vyhybka: TVyhybka; p_pozica: TVyhybkaPozicia);
  var
    vyhybka: TCestaVyhybka;
  begin
    vyhybka.Vyhybka:=p_vyhybka;
    vyhybka.Poloha:=p_pozica;

    t_vyhybky.Add(vyhybka);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.OverVolbu(p_posun: Boolean; p_zdroj: TStavadloObjekt; p_ciel: TStavadloObjekt): Boolean;
  begin
    Result:=OverZdroj(p_zdroj,p_posun) and t_ciele.Contains(p_ciel);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.OverZdroj(p_objekt: TStavadloObjekt; p_posun: Boolean): Boolean;
  begin
    if p_posun and (not t_posunova) then Result:=False
    else if(not p_posun) and (not t_vlakova) then Result:=False
    else Result:=t_zdroje.Contains(p_objekt);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.PridajVolbu(p_posun: Boolean; p_volby: TList<TPair<TStavadloObjekt,Boolean>>);
  var
    volba: TPair<TStavadloObjekt,Boolean>;
  begin
    volba.Value:=p_posun;
    volba.Key:=t_ciele.First;

    p_volby.Insert(0,volba);

    volba.Key:=t_zdroje.First;
    p_volby.Insert(0,volba);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.DajNavestidlo: TNavestidlo;
  var
    zdroj: TStavadloObjekt;
  begin
    Result:=nil;

    for zdroj in t_zdroje do
    begin
      if zdroj.KodJednotky in [KJ_NAVESTIDLOZRIADOVACIE,KJ_NAVESTIDLOVCHODOVE,KJ_NAVESTIDLOODCHODOVE] then
      begin
        Result:=zdroj as TNavestidlo;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.VyberVolnoznak(p_navestidlo: TNavestidlo);
  var
    povely: TList<TPair<Integer,Boolean>>;
    povel: TPair<Integer,Boolean>;
  begin
    povely:=TList<TPair<Integer,Boolean>>.Create;
    try
      if(t_aktual_posun) or (p_navestidlo.KodJednotky=KJ_NAVESTIDLOZRIADOVACIE) then t_navest:=CN_POSUN_DOVOLENY
      else if(t_znak=CZ_TRATOVA) then
      begin
        if(t_dalsie=nil) then t_navest:=CN_VOLNO
        else if(t_dalsie.Navest[False] in [CN_40AVYSTRAHA,CN_40A40,CN_40AVOLNO]) then t_navest:=CN_OCAK40
        else if(t_dalsie.Navest[False] in [CN_VYSTRAHA,CN_VOLNO]) then t_navest:=CN_VOLNO
        else t_navest:=CN_VYSTRAHA
      end
      else if(t_znak=CZ_40) then
      begin
        if(t_dalsie=nil) then t_navest:=CN_40AVOLNO
        else if(t_dalsie.Navest[False] in [CN_40AVYSTRAHA,CN_40A40,CN_40AVOLNO]) then t_navest:=CN_40A40
        else if(t_dalsie.Navest[False] in [CN_VYSTRAHA,CN_VOLNO]) then t_navest:=CN_40AVOLNO
        else t_navest:=CN_40AVYSTRAHA
      end;

      if p_navestidlo.RucnyZaver then p_navestidlo.RozsvietNavest(CN_STOJ,povely)
      else p_navestidlo.RozsvietNavest(t_navest,povely);

      for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
      LogikaES.AktualizujVolnoZnak(p_navestidlo);
    finally
      povely.Free;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.Zapevni;
  var
    kolaj: TCestaKolaj;
    navestidlo: TNavestidlo;
  begin
    for kolaj in t_kolaje do
    begin
      if kolaj.Presah then kolaj.Kolaj.Zaver:=ZVR_PRESAH
      else
      begin
        if t_aktual_posun then kolaj.Kolaj.Zaver:=ZVR_POSUNOVA
        else kolaj.Kolaj.Zaver:=ZVR_VLAKOVA;
      end;
    end;

    navestidlo:=DajNavestidlo;

    if navestidlo<>nil then VyberVolnoznak(navestidlo)
    else t_navest:=CN_POSUN_DOVOLENY;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.Postav;
  var
    vyhybka: TCestaVyhybka;
  begin
    t_zavreta:=False;

    for vyhybka in t_vyhybky do
    begin
      if vyhybka.Vyhybka.PolohaLog<>vyhybka.Poloha then
      begin
        if vyhybka.Vyhybka.OtocitPolaritu then
        begin
          if vyhybka.Poloha=VPO_ODBOCKA then CPort.VydajPovelB0(vyhybka.Vyhybka.Adresa,True)
          else CPort.VydajPovelB0(vyhybka.Vyhybka.Adresa,False);
        end
        else
        begin
          if vyhybka.Poloha=VPO_ROVNO then CPort.VydajPovelB0(vyhybka.Vyhybka.Adresa,True)
          else CPort.VydajPovelB0(vyhybka.Vyhybka.Adresa,False);
        end;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.Zavri(p_posun: Boolean; p_zdroj: TStavadloObjekt): Boolean;
  var
    kolaj: TCestaKolaj;
    vyhybka: TCestaVyhybka;
  begin
    assert(t_posunova or (not p_posun));
    t_aktual_posun:=p_posun;
    t_aktual_zdroj:=p_zdroj;
    t_zavreta:=True;

    Result:=True;

    for kolaj in t_kolaje do
    begin
      if not kolaj.Kolaj.JeVolna(ZSO_VYHRADNY) then
      begin
        Result:=False;
        break;
      end;
    end;

    for vyhybka in t_vyhybky do
    begin
      if vyhybka.Vyhybka.RucnyZaver and (vyhybka.Vyhybka.Poloha<>vyhybka.Poloha) then
      begin
        Result:=False;
        break;
      end;
    end;

    if Result then
    begin
      for vyhybka in t_vyhybky do
      begin
        if (vyhybka.Vyhybka.Stitok<>'') or (vyhybka.Vyhybka.Vyluka<>'') then LogikaES.PridajVolbaStitok(vyhybka.Vyhybka);
      end;

      for kolaj in t_kolaje do
      begin
        kolaj.Kolaj.Zaver:=ZVR_PREDBEZNY;
        if (kolaj.Kolaj.Stitok<>'') or (kolaj.Kolaj.Vyluka<>'') then LogikaES.PridajVolbaStitok(kolaj.Kolaj);
      end;

      if (DajNavestidlo<>nil) and (DajNavestidlo.Stitok<>'') then LogikaES.PridajVolbaStitok(DajNavestidlo);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.Postavena: Boolean;
  var
    vyhybka: TCestaVyhybka;
  begin
    Result:=True;

    for vyhybka in t_vyhybky do
    begin
      if vyhybka.Poloha<>vyhybka.Vyhybka.Poloha then
      begin
        Result:=False;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.VolnoZnak(p_natvrdo: Boolean): Boolean;
  var
    kolaj: TCestaKolaj;
  begin
    if (p_natvrdo) or (t_navest<>CN_STOJ) then
    begin
      Result:=True;

      for kolaj in t_kolaje do
      begin
        if not (kolaj.Kolaj.Zaver in [ZVR_POSUNOVA,ZVR_VLAKOVA,ZVR_PRESAH]) then
        begin
          if not (t_navest in [CN_STOJ,CN_NEZNAMA]) then ZrusVolnoznak;          
          Result:=False;
          break;
        end;
      end;
    end
    else Result:=False;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.AktualizujVolnoZnak(p_natvrdo: Boolean);
  var
    navestidlo: TNavestidlo;
  begin
    if VolnoZnak(p_natvrdo) then
    begin
      navestidlo:=DajNavestidlo;
      if navestidlo<>nil then VyberVolnoznak(navestidlo)
      else t_navest:=CN_POSUN_DOVOLENY;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.ZrusVolnoZnak;
  var
    navestidlo: TNavestidlo;
    povely: TList<TPair<Integer,Boolean>>;
    povel: TPair<Integer,Boolean>;
  begin
    navestidlo:=DajNavestidlo;

    if navestidlo<>nil then
    begin
      povely:=TList<TPair<Integer,Boolean>>.Create;
      try
         navestidlo.RozsvietNavest(CN_STOJ,povely);
         for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
         LogikaES.AktualizujVolnoZnak(navestidlo);
      finally
        povely.Free;
      end;
    end;

    t_navest:=CN_STOJ;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.Zrus;
  var
    kolaj: TCestaKolaj;
  begin
    t_zavreta:=False;
    ZrusVolnoznak;
    for kolaj in t_kolaje do kolaj.Kolaj.Zaver:=ZVR_NENI;
  end;

  //////////////////////////////////////////////////////////////////////////////

  destructor TCesta.Destroy;
  begin
    t_zdroje.Free;
    t_ciele.Free;
    t_kolaje.Free;
    t_vyhybky.Free;

    inherited;
  end;

  //**************************************************************************//

  constructor TZlozenaCesta.Create(p_vlakova,p_posunova: Boolean);
  begin
    t_vlakova:=p_vlakova;
    t_posunova:=p_posunova;

    t_zdroje:=TList<TStavadloObjekt>.Create;
    t_ciele:=TList<TStavadloObjekt>.Create;
    t_cesty:=TList<TCesta>.Create;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TZlozenaCesta.PridajZdroj(p_zdroj: TStavadloObjekt);
  begin
    t_zdroje.Add(p_zdroj);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TZlozenaCesta.PridajCiel(p_ciel: TStavadloObjekt);
  begin
    t_ciele.Add(p_ciel);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TZlozenaCesta.PridajCestu(p_cesta: TCesta; p_poradie: Integer);
  begin
    //poradie zacneme pouzivat az sa zisti ze parser prehadzuje polozky
    t_cesty.Add(p_cesta);
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TZlozenaCesta.OverVolbu(p_posun: Boolean; p_zdroj: TStavadloObjekt; p_ciel: TStavadloObjekt): Boolean;
  begin
    if p_posun and (not t_posunova) then Result:=False
    else if(not p_posun) and (not t_vlakova) then Result:=False
    else Result:=t_zdroje.Contains(p_zdroj) and t_ciele.Contains(p_ciel);
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TZlozenaCesta.PridajVolbu(p_posun: Boolean; p_volby: TList<TPair<TStavadloObjekt,Boolean>>);
  var
    i: Integer;
  begin
    for i := 0 to t_cesty.Count-1 do t_cesty[i].PridajVolbu(p_posun,p_volby);
  end;

  //////////////////////////////////////////////////////////////////////////////

  destructor TZlozenaCesta.Destroy;
  begin
    t_zdroje.Free;
    t_ciele.Free;
    t_cesty.Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
end.
