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

type TPorucha=record
  Cas: TDateTime;
  Dopravna: TDopravna;
  Text: string;
end;

function Porucha(p_cas: TDateTime; p_dopravna: TDopravna; p_text: string): TPorucha;

type TMenuPolozka=(MK_STAV,MK_STOJ,MK_DN,MK_PN,MK_P1,MK_P2,MK_ZAV1,MK_ZAV2,MK_STIT,MK_VYL,MK_RESET);

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

    t_nazvy_dopravni: Boolean;
    t_plan_vyska,t_plan_sirka: Integer;
    t_plan_nazov: string;

    t_volby: TList<TPair<TStavadloObjekt,Boolean>>;

    t_poruchy: TList<TPorucha>;
    t_zaverovka: TList<TCesta>;
    t_zlozene: TList<TZlozenaCesta>;

    t_stavana_cesta: TCesta;
    t_postavene_cesty: TDictionary<TStavadloObjekt,TCesta>;

    t_volat_dratotah: Boolean;
    t_menu_objekt: TStavadloObjekt;

    function DajKolajCiara(p_c_jednotky: Integer): TKolajCiara;
    function DajVyhybka(p_c_jednotky: Integer): TVyhybka;

    function SkontrolujConfig: Boolean;

    procedure AktualizujPanely;

    function JeZaciatokCesty(p_objekt: TStavadloObjekt; p_posun: Boolean): Boolean;
  public
    { Public declarations }
    property SirkaPlanu: Integer read t_plan_sirka;
    property VyskaPlanu: Integer read t_plan_vyska;
    property NazovPlanu: string read t_plan_nazov;
    property NazvyDopravni: Boolean read t_nazvy_dopravni;

    procedure VyberJednotku(p_x,p_y: Integer; p_shift: TShiftState; p_stredne: Boolean);
    procedure VyberZrusenie(p_x,p_y: Integer; p_shift: TShiftState);

    procedure SpracujSpravuB0(p_adresa: Integer; p_smer: Boolean);
    procedure SpracujSpravuBCB4(p_adresa: Integer; p_smer: Boolean);

    procedure OtestujVyhybky;
    procedure OtestujNavestidla;
    procedure ResetujVyhybky(p_potvrd: Boolean);
    procedure ResetujNavestidla(p_potvrd: Boolean);
    procedure ResetujVyhybku(p_vyhybka: TVyhybka; p_potvrd: Boolean);
    procedure ResetujNavestidlo(p_navestidlo: TNavestidlo; p_potvrd: Boolean);
    procedure Privolavacka(p_navestidlo: TNavestidlo; p_potvrd: Boolean);

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

    procedure SpracujKlavesu(p_klavesta: Word; p_shift: TShiftState);
    procedure ZobrazMenu(p_x,p_y: Integer; p_objekt: TStavadloObjekt);
    procedure SpracujMenu(p_menu: TMenuPolozka);
  end;

var
  LogikaES: TLogikaES;

implementation
  uses GUI1, DiagDialog, ComPort, IniFiles, Forms, LoadConfig, DratotahDialog,
  DateUtils, Winapi.Windows;

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

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.DataModuleCreate(Sender: TObject);
var
  subor: TIniFile;
  nazov: string;
  config: TConfigLoader;
  fullscreen: Boolean;
begin
  t_dopravne:=TList<TDopravna>.Create;
  t_plan:=TList<TStavadloObjekt>.Create;
  t_hitboxy:=TList<THitBox>.Create;
  t_zaverovka:=TList<TCesta>.Create;
  t_zlozene:=TList<TZlozenaCesta>.Create;

  t_volby:=TList<TPair<TStavadloObjekt,Boolean>>.Create;

  t_poruchy:=TList<TPorucha>.Create;

  t_stavana_cesta:=nil;
  t_postavene_cesty:=TDictionary<TStavadloObjekt,TCesta>.Create;

  t_volat_dratotah:=False;
  t_menu_objekt:=nil;

  subor:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'conf.ini');
  try
    nazov:=subor.ReadString('Plan','Subor','plan.xml');
    fullscreen:=subor.ReadBool('Plan','Fulscreen',False);
  finally
    subor.Free;
  end;

  config:=TConfigLoader.Create(nazov);
  try
    if config.NacitajKonfiguraciu(self) then
    begin;
      SkontrolujConfig;
    end
  finally
    config.Free;
  end;

  if not fullscreen then
  begin
    Form1.WindowState:=wsNormal;
    Form1.BorderStyle:=bsSizeable;
  end;
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

function TLogikaES.DajKolajCiara(p_c_jednotky: Integer): TKolajCiara;
begin
  Result:=DajObjekt(KJ_KOLAJCIARA,p_c_jednotky) as TKolajCiara;
end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.DajVyhybka(p_c_jednotky: Integer): TVyhybka;
begin
  Result:=DajObjekt(KJ_VYHYBKA,p_c_jednotky) as TVyhybka;
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
  t_volby.Free;
  t_hitboxy.Free;
  t_postavene_cesty.Free;
  t_poruchy.Free;

  for i in t_zaverovka do i.Free;
  t_zaverovka.Free;

  for i in t_zlozene do i.Free;
  t_zlozene.Free;
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
  Form1.Cas.Caption:=FormatDateTime('dd.mm.yyyy hh:nn:ss',Now);
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
begin
  if(t_stavana_cesta<>nil) then
  begin
    if t_stavana_cesta.VolnoZnak(False) then t_stavana_cesta:=nil
    else if t_stavana_cesta.Postavena then
    begin
      t_stavana_cesta.Zapevni;
      t_stavana_cesta:=nil;
    end;
  end
  else
  begin
    if t_volby.Count>=2 then
    begin
      zdroj:=t_volby[0].Key;
      ciel:=t_volby[1].Key;
      posun:=t_volby[0].Value;

      najdena:=False;

      //overenie zlozenych ciest
      for zcesta in t_zlozene do
      begin
        najdena:=zcesta.OverVolbu(posun,zdroj,ciel);

        if najdena then
        begin
          t_volby.Delete(0);
          t_volby.Delete(0);

          zcesta.PridajVolbu(posun,t_volby);

          break;
        end;
      end;

      if(najdena) then
      begin
        najdena:=False;

        zdroj:=t_volby[0].Key;
        ciel:=t_volby[1].Key;
        posun:=t_volby[0].Value;
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
            cesta.Postav;
            t_postavene_cesty.Add(zdroj,t_stavana_cesta);
            zdroj.NastavJeZdroj(posun);
          end
          else VytvorPoruchu(Now,zdroj.Dopravna,'Cestu nejde navoliù');

          break;
        end;
      end;

      if not najdena then VytvorPoruchu(Now,zdroj.Dopravna,'Cesta neexistuje');

      //zmazanie volieb
      t_volby.Delete(0);
      t_volby.Delete(0);
    end;

    if (t_stavana_cesta=nil) and (t_volby.Count<2) then VolbaTimer.Enabled:=False;
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
      povely:=TList<TPair<Integer,Boolean>>.Create;
      try
        if (vysledok as TNavestidloHlavne).Navest[False]=CN_PRIVOLAVACKA then (vysledok as TNavestidloHlavne).RozsvietNavest(CN_STOJ,povely)
        else if (vysledok as TNavestidloHlavne).Navest[False] in [CN_STOJ,CN_NEZNAMA] then (vysledok as TNavestidloHlavne).RozsvietNavest(CN_PRIVOLAVACKA,povely);

        for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
      finally
        povely.Free;
      end;
    end
    else if(vysledok is TNavestidlo) and (t_postavene_cesty.TryGetValue(vysledok,cesta)) then
    begin
      if ((vysledok as TNavestidloHlavne).Navest[False]<>CN_STOJ) then cesta.ZrusVolnoznak
      else cesta.AktualizujVolnoznak(True);
    end
    else  if(not (vysledok is TVyhybka)) and ((not (ssAlt in p_shift)) or (not (ssShift in p_shift))) then
    begin
      if (t_volby.Count mod 2=0) then
      begin
        posun:=(ssCtrl in p_shift) or (p_stredne) or (vysledok is TNavestidloZriadovacie) or (vysledok is TKolajCiara);

        if JeZaciatokCesty(vysledok,posun) then
        begin
          volba.Key:=vysledok;
          volba.Value:=posun;
          t_volby.Add(volba);
        end;
      end
      else if (t_volby.Count mod 2=1) then
      begin
        volba.Key:=vysledok;
        volba.Value:=t_volby.Last.Value;
        t_volby.Add(volba);

        posun:=(ssCtrl in p_shift) or (p_stredne) or (vysledok is TNavestidloZriadovacie) or (vysledok is TKolajCiara);

        if (vysledok is TNavestidlo) and JeZaciatokCesty(vysledok,posun) then
        begin
          volba.Value:=posun;
          t_volby.Add(volba);
        end;

        if not VolbaTimer.Enabled then VolbaTimer.Enabled:=True;
      end;
    end
    else if(vysledok is TVyhybka) then
    begin
      if (vysledok as TVyhybka).JeVolna then
      begin
        if (vysledok as TVyhybka).Pozicia in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then CPort.VydajPovelB0((vysledok as TVyhybka).Adresa,not (vysledok as TVyhybka).OtocitPolaritu)
        else if (vysledok as TVyhybka).Pozicia in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then  CPort.VydajPovelB0((vysledok as TVyhybka).Adresa,(vysledok as TVyhybka).OtocitPolaritu);
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
  if t_volby.Count>0 then t_volby.Remove(t_volby.Last)
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

    if(vysledok<>nil) and (ssCtrl in p_shift) and ((vysledok is TNavestidlo) or (vysledok is TKolajCiara) or (vysledok is TVyhybka)) then
    begin
      ZobrazMenu(p_x,p_y,vysledok);
    end
    else if(vysledok<>nil) and (vysledok is TNavestidloHlavne) and ((vysledok as TNavestidloHlavne).Navest[False]=CN_PRIVOLAVACKA) then
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
    end;
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
  if t_volby.Count>0 then
  begin
    text:=t_volby[0].Key.Nazov[True,True];

    if(t_volby.Count>1) then
    begin
      text:=text+' -> ';
      text:=text+t_volby[1].Key.Nazov[True,True];
    end;
  end
  else text:='';

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

procedure TLogikaES.ResetujVyhybky(p_potvrd: Boolean);
var
  objekt: TStavadloObjekt;
begin
  if p_potvrd then
  begin
    for objekt in t_plan do
    begin
      if (objekt is TVyhybka) then ResetujVyhybku((objekt as TVyhybka),p_potvrd);
    end;

    if t_volat_dratotah then DratotahDlg.Obnov;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujNavestidla(p_potvrd: Boolean);
var
  objekt: TStavadloObjekt;
begin
  if p_potvrd then
  begin
    for objekt in t_plan do
    begin
      if (objekt is TNavestidlo) then ResetujNavestidlo(objekt as TNavestidlo,p_potvrd);
    end;

    if t_volat_dratotah then DratotahDlg.Obnov;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujVyhybku(p_vyhybka: TVyhybka; p_potvrd: Boolean);
begin
  if p_vyhybka.Pozicia in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK] then CPort.VydajPovelB0((p_vyhybka as TVyhybka).Adresa,(p_vyhybka as TVyhybka).OtocitPolaritu)
  else if p_vyhybka.Pozicia in [VPO_ROVNO,VPO_ROVNO_OTAZNIK] then  CPort.VydajPovelB0((p_vyhybka as TVyhybka).Adresa,not (p_vyhybka as TVyhybka).OtocitPolaritu);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ResetujNavestidlo(p_navestidlo: TNavestidlo; p_potvrd: Boolean);
var
  povely: TList<TPair<Integer,Boolean>>;
  povel: TPair<Integer,Boolean>;
begin
  povely:=TList<TPair<Integer,Boolean>>.Create;
  try
    (p_navestidlo as TNavestidlo).Reset(povely);
    for povel in povely do CPort.VydajPovelB0(povel.Key,povel.Value);
  finally
    povely.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.Privolavacka(p_navestidlo: TNavestidlo; p_potvrd: Boolean);
begin

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
  Result:=t_volby;
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

procedure TLogikaES.SpracujKlavesu(p_klavesta: Word; p_shift: TShiftState);
begin
  case p_klavesta of
    VK_RETURN:
    begin
      if t_poruchy.Count>0 then
      begin
        t_poruchy.Delete(0);
        Form1.PaintBoxPoruchy.Invalidate;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.ZobrazMenu(p_x,p_y: Integer; p_objekt: TStavadloObjekt);
begin
  if p_objekt is TVyhybka then
  begin
    t_menu_objekt:=p_objekt;
    Form1.STAV1.Visible:=True;
    Form1.SSTAV.Visible:=True;
    Form1.STOJ1.Visible:=False;
    Form1.DN1.Visible:=False;
    Form1.PN1.Visible:=False;
    Form1.SNAV.Visible:=False;
    Form1.P1.Visible:=(t_menu_objekt as TVyhybka).JeVolna and ((t_menu_objekt as TVyhybka).Pozicia in [VPO_NEZNAMA,VPO_ODBOCKA,VPO_ODBOCKA_OTAZNIK]);
    Form1.P2.Visible:=(t_menu_objekt as TVyhybka).JeVolna and ((t_menu_objekt as TVyhybka).Pozicia in [VPO_NEZNAMA,VPO_ROVNO,VPO_ROVNO_OTAZNIK]);
    Form1.SVYH.Visible:=True;
    Form1.ZAV1.Visible:=(not (t_menu_objekt as TVyhybka).RucnyZaver) and ((t_menu_objekt as TVyhybka).Pozicia<>VPO_NEZNAMA);
    Form1.ZAV2.Visible:=(t_menu_objekt as TVyhybka).RucnyZaver;
    Form1.SZAV.Visible:=True;
    Form1.STIT1.Visible:=True;
    Form1.VYL1.Visible:=True;
    Form1.SVYL.Visible:=True;
    Form1.RESET1.Visible:=True;
  end
  else if p_objekt is TNavestidlo then
  begin
    t_menu_objekt:=p_objekt;
    Form1.STAV1.Visible:=True;
    Form1.SSTAV.Visible:=True;
    Form1.STOJ1.Visible:=(t_menu_objekt as TNavestidlo).Navest[False]<>CN_STOJ;
    Form1.DN1.Visible:=((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ) and ((t_menu_objekt as TNavestidlo).JeZdroj);
    Form1.PN1.Visible:=(t_menu_objekt is TNavestidloHlavne) and ((t_menu_objekt as TNavestidlo).Navest[False]=CN_STOJ);
    Form1.SNAV.Visible:=True;
    Form1.P1.Visible:=False;
    Form1.P2.Visible:=False;
    Form1.SVYH.Visible:=False;
    Form1.ZAV1.Visible:=False;
    Form1.ZAV2.Visible:=False;
    Form1.SZAV.Visible:=False;
    Form1.STIT1.Visible:=True;
    Form1.VYL1.Visible:=False;
    FOrm1.SVYL.Visible:=True;
    Form1.RESET1.Visible:=True;
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
    Form1.P1.Visible:=False;
    Form1.P2.Visible:=False;
    Form1.SVYH.Visible:=False;
    Form1.ZAV1.Visible:=False;
    Form1.ZAV2.Visible:=False;
    Form1.SZAV.Visible:=False;
    Form1.STIT1.Visible:=True;
    Form1.VYL1.Visible:=True;
    FOrm1.SVYL.Visible:=True;
    Form1.RESET1.Visible:=False;
  end;

  Form1.PopupMenu1.Popup(p_x,p_y);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujMenu(p_menu: TMenuPolozka);
begin
  case p_menu of
//    MK_STAV: Form1.ZobrazStav(;
    MK_STOJ: ;
    MK_DN: ;
    MK_PN: ;
    MK_P1: if (t_menu_objekt as TVyhybka).JeVolna then CPort.VydajPovelB0((t_menu_objekt as TVyhybka).Adresa,not (t_menu_objekt as TVyhybka).OtocitPolaritu);
    MK_P2: if (t_menu_objekt as TVyhybka).JeVolna then CPort.VydajPovelB0((t_menu_objekt as TVyhybka).Adresa,(t_menu_objekt as TVyhybka).OtocitPolaritu);
    MK_ZAV1: (t_menu_objekt as TVyhybka).NastavRucnyZaver(True,False);
    MK_ZAV2: (t_menu_objekt as TVyhybka).NastavRucnyZaver(False,False);
    MK_STIT: ;
    MK_VYL: ;
    MK_RESET: ResetujNavestidlo(t_menu_objekt as TNavestidlo,False);
  end;

  AktualizujPanely;
end;

end.
