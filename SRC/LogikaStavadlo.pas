unit LogikaStavadlo;

interface

uses
  System.SysUtils, System.Classes, StavadloObjekty, Generics.Collections,
  Graphics, ExtCtrls, Types, Cesta;

type
  THitBox=record
    Poloha: TRect;
    Objekt: TStavadloObjekt;
  end;

  function HitBox(p_rect: TRect; p_objekt: TStavadloObjekt): THitBox;

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
    t_plan: TList<TStavadloObjekt>;
    t_hitboxy: TList<THitBox>;

    t_zdroj,t_ciel,t_druhy_zdroj,t_druhy_ciel: TStavadloObjekt;

    t_chyba: string;
    t_posun: Boolean;
    t_zaverovka: TList<TCesta>;

    t_stavana_cesta: TCesta;
    t_postavene_cesty: TDictionary<TStavadloObjekt,TCesta>;

    function DajObjekt(p_kod_jednotky: TKodJednotky; p_c_jednotky: Integer): TStavadloObjekt;
    function DajKolajCiara(p_c_jednotky: Integer): TKolajCiara;
    function DajVyhybka(p_c_jednotky: Integer): TVyhybka;
    function SkontrolujConfig: Boolean;
    procedure OtocPlan;

    procedure AktualizujSpodPanel;

    procedure VykresliHitBox(p_ciel: TCanvas; p_objekt: TStavadloObjekt);
  public
    { Public declarations }
    procedure VykresliPlan(p_ciel: TPAintBox);
    procedure VyberJednotku(p_x,p_y: Integer; p_shift: TShiftState; p_stredne: Boolean);
    procedure VyberZrusenie(p_x,p_y: Integer; p_shift: TShiftState);

    procedure SpracujSpravuB0(p_adresa: Integer; p_smer: Boolean);
    procedure SpracujSpravuBCB4(p_adresa: Integer; p_smer: Boolean);

    procedure OtestujVyhybky;
  end;

var
  LogikaES: TLogikaES;

implementation
  uses GUI1, DiagDialog, ComPort, IniFiles, Forms, LoadConfig;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function HitBox(p_rect: TRect; p_objekt: TStavadloObjekt): THitBox;
begin
  Result.Poloha:=p_rect;
  Result.Objekt:=p_objekt;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.DataModuleCreate(Sender: TObject);
var
  subor: TIniFile;
  nazov: string;
  config: TConfigLoader;
begin
  t_plan:=TList<TStavadloObjekt>.Create;
  t_hitboxy:=TList<THitBox>.Create;
  t_zaverovka:=TList<TCesta>.Create;

  t_zdroj:=nil;
  t_ciel:=nil;
  t_druhy_zdroj:=nil;
  t_druhy_ciel:=nil;

  t_chyba:='';
  t_posun:=False;
  t_stavana_cesta:=nil;
  t_postavene_cesty:=TDictionary<TStavadloObjekt,TCesta>.Create;

  subor:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\conf.ini');
  try
    nazov:=subor.ReadString('Plan','Subor','plan.xml');
  finally
    subor.Free;
  end;

  config:=TConfigLoader.Create(nazov);
  try
    config.NacitajKonfiguraciu;
  finally
    config.Free;
  end;
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

procedure TLogikaES.DataModuleDestroy(Sender: TObject);
var
  i: TObject;
begin
  for i in t_plan do i.Free;
  t_plan.Free;
  t_hitboxy.Free;
  t_postavene_cesty.Free;
end;

procedure TLogikaES.Timer1Timer(Sender: TObject);
begin
  Form1.PaintBox1.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VykresliHitBox(p_ciel: TCanvas; p_objekt: TStavadloObjekt);
var
  hitbox: THitBox;
  x_zac,y_zac,x_kon,y_kon: Integer;
begin
  for hitbox in t_hitboxy do
  begin
    if hitbox.Objekt=p_objekt then
    begin
//      x_zac:=((110-hitbox.Poloha.Left)*Form1.PaintBox1.Width) div 110;
//      x_kon:=((110-hitbox.Poloha.Top)*Form1.PaintBox1.Width) div 110;
      x_zac:=(hitbox.Poloha.Left*Form1.PaintBox1.Width) div 110;
      x_kon:=(hitbox.Poloha.Top*Form1.PaintBox1.Width) div 110;
//      y_zac:=((70-hitbox.Poloha.Right)*Form1.PaintBox1.Height) div 110;
//      y_kon:=((70-hitbox.Poloha.Bottom)*Form1.PaintBox1.Height) div 110;
      y_zac:=(hitbox.Poloha.Right*Form1.PaintBox1.Height) div 110;
      y_kon:=(hitbox.Poloha.Bottom*Form1.PaintBox1.Height) div 110;

      if t_posun then p_ciel.Pen.Color:=clWhite
      else p_ciel.Pen.COlor:=clLime;

      p_ciel.Pen.Width:=2;
      p_ciel.Brush.Style:=bsClear;
      try
        p_ciel.Rectangle(x_kon,y_kon,x_zac,y_zac);
      finally
        p_ciel.Brush.Style:=bsSolid;
      end;

      break;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VykresliPlan(p_ciel: TPaintBox);
var
  objekt: TStavadloObjekt;
  bitmap: TBitmap;
begin
  bitmap:=TBitmap.Create;
  try
    bitmap.SetSize(p_ciel.Width,p_ciel.Height);

    bitmap.Canvas.Pen.Color:=clBlack;
    bitmap.Canvas.Brush.Color:=clBlack;
    bitmap.Canvas.Rectangle(0,0,p_ciel.Width,p_ciel.Height);

    for objekt in t_plan do objekt.Vykresli(bitmap.Canvas,0,p_ciel.Width,0,p_ciel.Height);

    if(t_zdroj<>nil) then VykresliHitBox(bitmap.Canvas,t_zdroj);
    if(t_ciel<>nil) then VykresliHitBox(bitmap.Canvas,t_ciel);
    if(t_druhy_zdroj<>nil) then VykresliHitBox(bitmap.Canvas,t_druhy_zdroj);
    if(t_druhy_ciel<>nil) then VykresliHitBox(bitmap.Canvas,t_druhy_ciel);

    p_ciel.Canvas.Draw(0,0,bitmap);
  finally
    bitmap.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.OtocPlan;
begin

end;

////////////////////////////////////////////////////////////////////////////////

function TLogikaES.SkontrolujConfig: Boolean;
var
  jednotky: TList<TJednotka>;
  objekt: TStavadloObjekt;
begin
  Result:=True;

  jednotky:=TList<TJednotka>.Create;
  try
    for objekt in t_plan do
    begin
      if not jednotky.Contains(objekt.DajJednotku) then jednotky.Add(objekt.DajJednotku)
      else
      begin
        DiagDlg.Memo1.Lines.Insert(0,'Duplicitní jednotka: '+IntToStr(Ord(objekt.KodJednotky))+'/'+IntToStr(objekt.CisloJednotky));
        Result:=False;
      end;
    end;
  finally
    jednotky.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VolbaTimerTimer(Sender: TObject);
var
  cesta: TCesta;
  najdena: Boolean;
begin
  if(t_stavana_cesta<>nil) then
  begin
    if t_stavana_cesta.VolnoZnak then t_stavana_cesta:=nil
    else if t_stavana_cesta.Postavena then
    begin
      t_stavana_cesta.Zapevni;
      t_stavana_cesta:=nil;
    end;
  end
  else
  begin
    najdena:=True;

    if (t_zdroj<>nil) and (t_ciel<>nil) then
    begin
      najdena:=False;

      for cesta in t_zaverovka do
      begin
        najdena:=cesta.OverVolbu(t_posun,t_zdroj,t_ciel);

        if najdena then
        begin
          if cesta.Zavri(t_posun,t_zdroj) then
          begin
            t_stavana_cesta:=cesta;
            cesta.Postav;
            t_postavene_cesty.Add(t_zdroj,t_stavana_cesta);
            t_zdroj.NastavJeZdroj(t_posun);
          end
          else t_chyba:='Nelze postavit';

          break;
        end;
      end;

      if not najdena then
      begin
        t_chyba:='Cesta nenalezena';
//        t_druha_volba_zdroj:=nil;
//        t_druha_volba_ciel:=nil;
      end;

      t_zdroj:=nil;
      t_ciel:=nil;
    end;
    
    if t_stavana_cesta=nil then VolbaTimer.Enabled:=False;
  end;

  AktualizujSpodPanel;
  Form1.PaintBox1.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VyberJednotku(p_x,p_y: Integer; p_shift: TShiftState; p_stredne: Boolean);
var
  perc_x,perc_y: Integer;
  hitbox: THitBox;
  vysledok: TStavadloObjekt;
begin
//  perc_x:=109-((p_x*110) div Form1.PaintBox1.Width);
//  perc_y:=69-((p_y*110) div Form1.PaintBox1.Height);
  perc_x:=((p_x*110) div Form1.PaintBox1.Width);
  perc_y:=((p_y*110) div Form1.PaintBox1.Height);

  vysledok:=nil;

  for hitbox in t_hitboxy do
  begin
    if (perc_x>=hitbox.Poloha.Left) and (perc_x<hitbox.Poloha.Top) and (perc_y>=hitbox.Poloha.Right) and (perc_y<hitbox.Poloha.Bottom) then
    begin
       vysledok:=hitbox.Objekt;
       break;
    end;
  end;

  if vysledok<>nil then
  begin
    if(not (vysledok is TVyhybka)) and (t_stavana_cesta=nil) then
    begin
      if t_zdroj=nil then
      begin
        t_zdroj:=vysledok;
        t_posun:=(ssCtrl in p_shift) or (p_stredne) or (t_zdroj is TNavestidloZriadovacie) or (t_zdroj is TKolajCiara);
      end
      else if t_ciel=nil then
      begin
        t_ciel:=vysledok;
        VolbaTimer.Enabled:=True;
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
  AktualizujSpodPanel;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.VyberZrusenie(p_x,p_y: Integer; p_shift: TShiftState);
var
  perc_x,perc_y: Integer;
  hitbox: THitBox;
  vysledok: TStavadloObjekt;
  cesta: TCesta;
begin
  if t_ciel<>nil then t_ciel:=nil
  else if t_zdroj<>nil then t_zdroj:=nil
  else
  begin
//    perc_x:=109-((p_x*110) div Form1.PaintBox1.Width);
//    perc_y:=69-((p_y*110) div Form1.PaintBox1.Height);
    perc_x:=((p_x*110) div Form1.PaintBox1.Width);
    perc_y:=((p_y*110) div Form1.PaintBox1.Height);

    vysledok:=nil;

    for hitbox in t_hitboxy do
    begin
      if (perc_x>=hitbox.Poloha.Left) and (perc_x<=hitbox.Poloha.Top) and (perc_y>=hitbox.Poloha.Right) and (perc_y<=hitbox.Poloha.Bottom) then
      begin
         vysledok:=hitbox.Objekt;
         break;
      end;
    end;

    if (vysledok<>nil) and (t_postavene_cesty.TryGetValue(vysledok,cesta)) then
    begin
      cesta.Zrus;
      t_postavene_cesty.Remove(vysledok);
      vysledok.ZrusJeZdroj;
      if t_stavana_cesta=cesta then t_stavana_cesta:=nil;
    end;
  end;

  Form1.PaintBox1.Invalidate;
  AktualizujSpodPanel;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.AktualizujSpodPanel;
var
  text: string;
begin
  if t_zdroj<>nil then
  begin
    text:=t_zdroj.Nazov;

    if(t_ciel<>nil) then
    begin
      text:=text+' -> ';
      text:=text+t_ciel.Nazov;
    end;
  end
  else if t_chyba<>'' then
  begin
    text:=t_chyba;
    t_chyba:='';
  end
  else text:='';

  Form1.VJednotka.Caption:=text;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujSpravuB0(p_adresa: Integer; p_smer: Boolean);
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if (objekt is TVyhybka) and ((objekt as TVyhybka).Adresa=p_adresa) then (objekt as TVyhybka).NastavPolohuCentrala(p_smer,True);
  end;

  Form1.PaintBox1.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TLogikaES.SpracujSpravuBCB4(p_adresa: Integer; p_smer: Boolean);
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if (objekt is TVyhybka) and ((objekt as TVyhybka).Adresa=p_adresa) then (objekt as TVyhybka).NastavPolohuCentrala(p_smer,False);
  end;

  Form1.PaintBox1.Invalidate;
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


end.
