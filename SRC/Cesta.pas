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

  type TCesta=class(TObject)
    private
      t_vlakova: Boolean;
      t_posunova: Boolean;
      t_znak: TCestaZnak;

      t_aktual_posun: Boolean;
      t_aktual_zdroj: TStavadloObjekt;

      t_zdroje: TList<TStavadloObjekt>;
      t_ciele: TList<TStavadloObjekt>;
      t_kolaje: TList<TCestaKolaj>;
      t_vyhybky: TList<TCestaVyhybka>;

    public
      constructor Create(p_vlakova: Boolean; p_posunova: Boolean; p_znak: TCestaZnak);

      procedure PridajZdroj(p_zdroj: TStavadloObjekt);
      procedure PridajCiel(p_ciel: TStavadloObjekt);
      procedure PridajKolaj(p_kolaj: TKolajCiara; p_presah: Boolean);
      procedure PridajVyhybku(p_vyhybka: TVyhybka; p_pozica: TVyhybkaPozicia);

      function OverVolbu(p_posun: Boolean; p_zdroj: TStavadloObjekt; p_ciel: TStavadloObjekt): Boolean;

      procedure Zapevni;
      function Zavri(p_posun: Boolean; p_zdroj: TStavadloObjekt): Boolean;
      procedure Postav;

      function Postavena: Boolean;
      function VolnoZnak: Boolean;

      procedure Zrus;

      destructor Destroy; override;
  end;


implementation
  uses ComPort;

  constructor TCesta.Create(p_vlakova: Boolean; p_posunova: Boolean; p_znak: TCestaZnak);
  begin
    t_vlakova:=p_vlakova;
    t_posunova:=p_posunova;
    t_znak:=p_znak;

    t_aktual_posun:=False;
    t_aktual_zdroj:=nil;

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
    if p_posun and (not t_posunova) then Result:=False
    else if(not p_posun) and (not t_vlakova) then Result:=False
    else Result:=(t_zdroje.Contains(p_zdroj) and t_ciele.Contains(p_ciel));
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.Zapevni;
  var
    kolaj: TCestaKolaj;
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

   {TODO -oJa -cDorobit : Volnoznak}
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.Postav;
  var
    vyhybka: TCestaVyhybka;
  begin
    for vyhybka in t_vyhybky do
    begin
      if vyhybka.Vyhybka.Pozicia<>vyhybka.Poloha then
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
  begin
    assert(t_posunova or (not p_posun));
    t_aktual_posun:=p_posun;
    t_aktual_zdroj:=p_zdroj;

    Result:=True;

    for kolaj in t_kolaje do
    begin
      if not kolaj.Kolaj.JeVolna then Result:=False;
      break;
    end;

    if Result then for kolaj in t_kolaje do kolaj.Kolaj.Zaver:=ZVR_PREDBEZNY;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.Postavena: Boolean;
  var
    vyhybka: TCestaVyhybka;
  begin
    Result:=True;

    for vyhybka in t_vyhybky do
    begin
      if vyhybka.Poloha<>vyhybka.Vyhybka.Pozicia then
      begin
        Result:=False;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  function TCesta.VolnoZnak: Boolean;
  var
    kolaj: TCestaKolaj;
  begin
    {TODO -oJa -cDorobit : Volnoznak}

    Result:=True;

    for kolaj in t_kolaje do
    begin
      if not (kolaj.Kolaj.Zaver in [ZVR_POSUNOVA,ZVR_VLAKOVA]) then
      begin
        Result:=False;
        break;
      end;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TCesta.Zrus;
  var
    kolaj: TCestaKolaj;
  begin
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

  //////////////////////////////////////////////////////////////////////////////
end.
