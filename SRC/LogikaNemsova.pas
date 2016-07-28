unit LogikaNemsova;

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
  TDataModule1 = class(TDataModule)
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

    procedure VytvorPlan;
    procedure VytvorZaverovku;

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
  DataModule1: TDataModule1;

implementation
  uses GUI1, DiagDialog, ComPort;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function HitBox(p_rect: TRect; p_objekt: TStavadloObjekt): THitBox;
begin
  Result.Poloha:=p_rect;
  Result.Objekt:=p_objekt;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TDataModule1.DataModuleCreate(Sender: TObject);
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

  VytvorPlan;
  VytvorZaverovku;
end;

////////////////////////////////////////////////////////////////////////////////

function TDataModule1.DajKolajCiara(p_c_jednotky: Integer): TKolajCiara;
begin
  Result:=DajObjekt(KJ_KOLAJCIARA,p_c_jednotky) as TKolajCiara;
end;

////////////////////////////////////////////////////////////////////////////////

function TDataModule1.DajVyhybka(p_c_jednotky: Integer): TVyhybka;
begin
  Result:=DajObjekt(KJ_VYHYBKA,p_c_jednotky) as TVyhybka;
end;

////////////////////////////////////////////////////////////////////////////////

function TDataModule1.DajObjekt(p_kod_jednotky: TKodJednotky; p_c_jednotky: Integer): TStavadloObjekt;
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

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
var
  i: TObject;
begin
  for i in t_plan do i.Free;
  t_plan.Free;
  t_hitboxy.Free;
  t_postavene_cesty.Free;
end;

procedure TDataModule1.Timer1Timer(Sender: TObject);
begin
  Form1.PaintBox1.Invalidate;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TDataModule1.VykresliHitBox(p_ciel: TCanvas; p_objekt: TStavadloObjekt);
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

procedure TDataModule1.VykresliPlan(p_ciel: TPaintBox);
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

procedure TDataModule1.OtocPlan;
begin

end;

////////////////////////////////////////////////////////////////////////////////

function TDataModule1.SkontrolujConfig: Boolean;
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

procedure TDataModule1.VolbaTimerTimer(Sender: TObject);
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

procedure TDataModule1.VyberJednotku(p_x,p_y: Integer; p_shift: TShiftState; p_stredne: Boolean);
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

procedure TDataModule1.VyberZrusenie(p_x,p_y: Integer; p_shift: TShiftState);
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

procedure TDataModule1.AktualizujSpodPanel;
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

procedure TDataModule1.SpracujSpravuB0(p_adresa: Integer; p_smer: Boolean);
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

procedure TDataModule1.SpracujSpravuBCB4(p_adresa: Integer; p_smer: Boolean);
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

procedure TDataModule1.OtestujVyhybky;
var
  objekt: TStavadloObjekt;
begin
  for objekt in t_plan do
  begin
    if (objekt is TVyhybka) then CPort.VydajPovelBC((objekt as TVyhybka).Adresa);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TDataModule1.VytvorPlan;
begin
  //zahlavie tepla
  t_plan.Add(TKolajCiara.Create(0,5,40,40,'TR',1));
  t_plan.Add(TNavestidloVchodove.Create(5,8,37,43,'L',0,0,0,0,0,0,0,0,0,1));
  t_plan.Add(TKolajCiara.Create(8,12,40,40,'TR-01K',2));
  t_plan.Add(TNavestidloZriadovacie.Create(12,15,37,43,'Se1',0,0,1));

  //zhlavie tepla
  t_plan.Add(TKolajCiara.Create(15,19,40,40,'',3));
  t_plan.Add(TKolajCiara.Create(25,29,37,30,'',4));
  t_plan.Add(TKolajCiara.Create(21,23,40,40,'',5));

  t_plan.Add(TKolajCiara.Create(25,37,40,40,'',6));
  t_plan.Add(TKolajCiara.Create(21,25,43,50,'',7));

  t_plan.Add(TKolajCiara.Create(27,37,50,50,'',8));
  t_plan.Add(TKolajCiara.Create(27,31,53,60,'',9));

  t_plan.Add(TKolajCiara.Create(29,37,30,30,'',10));
  t_plan.Add(TKolajCiara.Create(31,37,60,60,'',11));

  t_plan.Add(TVyhybka.Create(19,40,21,40,21,43,'1',101,False,DajKolajCiara(3),DajKolajCiara(5),DajKolajCiara(7),1));
  t_plan.Add(TVyhybka.Create(23,40,25,40,25,37,'2',102,False,DajKolajCiara(5),DajKolajCiara(6),DajKolajCiara(4),2));
  t_plan.Add(TVyhybka.Create(25,50,27,50,27,53,'3',103,True,DajKolajCiara(7),DajKolajCiara(8),DajKolajCiara(9),3));

  //pdchodove tepla
  t_plan.Add(TNavestidloOdchodove.Create(40,37,27,33,'S3',0,0,0,0,0,1));
  t_plan.Add(TNavestidloOdchodove.Create(40,37,37,43,'S1',0,0,0,0,0,2));
  t_plan.Add(TNavestidloOdchodove.Create(40,37,47,53,'S2',0,0,0,0,0,3));
  t_plan.Add(TNavestidloOdchodove.Create(40,37,57,63,'S4',0,0,0,0,0,4));

  //rozdelena kolaj 3
  t_plan.Add(TKolajCiara.Create(40,45,30,30,'3ASK',12));
  t_plan.Add(TKolajCiara.Create(47,52,30,30,'3SK',13));
  t_plan.Add(TKolajCiara.Create(54,65,30,30,'3BSK',14));

  //vlecka na tratovku
  t_plan.Add(TKolajCiara.Create(41,45,20,27,'VTSK',15));
  t_plan.Add(TVyhybka.Create(47,30,45,30,45,27,'4',104,True,DajKolajCiara(12),DajKolajCiara(13),DajKolajCiara(15),4));

  //kolaj pri nakladisku
  t_plan.Add(TKolajCiara.Create(54,58,27,20,'',16));
  t_plan.Add(TKolajCiara.Create(58,64,20,20,'5SK',17));
  t_plan.Add(TKolajCiara.Create(66,70,20,27,'',180));
  t_plan.Add(TVyhybka.Create(52,30,54,30,54,27,'5',105,False,DajKolajCiara(13),DajKolajCiara(14),DajKolajCiara(16),5));
  t_plan.Add(TKolajCiara.Create(48,60,10,10,'7SK',170));
  t_plan.Add(TKolajCiara.Create(60,64,10,17,'',171));
  t_plan.Add(TVyhybka.Create(66,20,64,20,64,17,'6',106,True,DajKolajCiara(180),DajKolajCiara(17),DajKolajCiara(171),16));

  //ostatne stanicne kolaje
  t_plan.Add(TKolajCiara.Create(40,65,40,40,'1SK',18));
  t_plan.Add(TKolajCiara.Create(40,65,50,50,'2SK',19));
  t_plan.Add(TKolajCiara.Create(40,65,60,60,'4SK',20));

  //navestidla srnie
  t_plan.Add(TNavestidloOdchodove.Create(65,68,27,33,'L3',0,0,0,0,0,5));
  t_plan.Add(TNavestidloOdchodove.Create(65,68,37,43,'L1',0,0,0,0,0,6));
  t_plan.Add(TNavestidloOdchodove.Create(65,68,47,53,'L2',0,0,0,0,0,7));
  t_plan.Add(TNavestidloOdchodove.Create(65,68,57,63,'L4',0,0,0,0,0,8));

  //zhlavnie Srnie
  t_plan.Add(TKolajCiara.Create(68,70,30,30,'',21));
  t_plan.Add(TKolajCiara.Create(68,70,60,60,'',22));
  t_plan.Add(TKolajCiara.Create(68,76,40,40,'',23));
  t_plan.Add(TKolajCiara.Create(68,76,50,50,'',24));

  t_plan.Add(TKolajCiara.Create(72,76,30,37,'',25));
  t_plan.Add(TKolajCiara.Create(72,76,57,53,'',26));

  t_plan.Add(TVyhybka.Create(72,30,70,30,70,27,'7',107,True,DajKolajCiara(25),DajKolajCiara(21),DajKolajCiara(180),6));

  //vojenska vlecka
  t_plan.Add(TKolajCiara.Create(72,78,60,60,'',27));
  t_plan.Add(TNavestidloZriadovacie.Create(81,78,57,63,'Se2',0,0,2));
  t_plan.Add(TKolajCiara.Create(81,108,60,60,'VVSK',270));

  //zhlavie srnie
  t_plan.Add(TKolajCiara.Create(78,80,50,50,'',28));
  t_plan.Add(TKolajCiara.Create(78,80,40,40,'',29));

  t_plan.Add(TVyhybka.Create(70,60,72,60,72,57,'9/10',109,False,DajKolajCiara(20),DajKolajCiara(27),DajKolajCiara(26),7));
  t_plan.Add(TVyhybka.Create(78,50,76,50,76,53,'9/10',109,False,DajKolajCiara(28),DajKolajCiara(24),DajKolajCiara(26),8));
  t_plan.Add(TVyhybka.Create(78,40,76,40,76,37,'8',108,False,DajKolajCiara(29),DajKolajCiara(23),DajKolajCiara(25),9));

  t_plan.Add(TKolajCiara.Create(82,86,40,40,'',30));
  t_plan.Add(TKolajCiara.Create(82,86,50,50,'',31));
  t_plan.Add(TKolajCiara.Create(82,86,43,47,'',32));
  t_plan.Add(TKolajCiara.Create(82,86,47,43,'',33));

  t_plan.Add(TVyhybka.Create(80,40,82,40,82,43,'11/12',111,True,DajKolajCiara(29),DajKolajCiara(30),DajKolajCiara(32),10));
  t_plan.Add(TVyhybka.Create(80,50,82,50,82,47,'13/14',113,True,DajKolajCiara(28),DajKolajCiara(31),DajKolajCiara(33),11));

  //zahlavie Srnie + vlecka
  t_plan.Add(TKolajCiara.Create(88,90,40,40,'',34));
  t_plan.Add(TKolajCiara.Create(92,100,40,40,'HS01K',35));
  t_plan.Add(TKolajCiara.Create(103,110,40,40,'HS',36));

  //zahlavie Rovne
  t_plan.Add(TKolajCiara.Create(88,90,50,50,'',37));
  t_plan.Add(TKolajCiara.Create(93,100,50,50,'LR01K',38));
  t_plan.Add(TKolajCiara.Create(103,110,50,50,'LR',39));

  t_plan.Add(TNavestidloZriadovacie.Create(93,90,47,53,'Se3',0,0,3));

  t_plan.Add(TVyhybka.Create(88,40,86,40,86,43,'13/14',113,True,DajKolajCiara(34),DajKolajCiara(30),DajKolajCiara(33),12));
  t_plan.Add(TVyhybka.Create(88,50,86,50,86,47,'11/12',111,True,DajKolajCiara(37),DajKolajCiara(31),DajKolajCiara(32),13));

  t_plan.Add(TNavestidloVchodove.Create(103,100,37,43,'S',0,0,0,0,0,0,0,0,0,2));
  t_plan.Add(TNavestidloVchodove.Create(103,100,47,53,'PS',0,0,0,0,0,0,0,0,0,3));

  //vlecka
  t_plan.Add(TKolajCiara.Create(92,96,37,33,'',40));
  t_plan.Add(TKolajCiara.Create(98,100,30,30,'',41));
  t_plan.Add(TKolajCiara.Create(103,108,30,30,'VSASK',42));
  t_plan.Add(TKolajCiara.Create(90,96,30,30,'',43));
  t_plan.Add(TKolajCiara.Create(80,87,30,30,'VSBSK',44));

  t_plan.Add(TKolajCiara.Create(108,108,28,32,'',45));
  t_plan.Add(TKolajCiara.Create(80,80,28,32,'',46));

  t_plan.Add(TVyhybka.Create(90,40,92,40,92,37,'15',115,True,DajKolajCiara(34),DajKolajCiara(35),DajKolajCiara(40),14));
  t_plan.Add(TVyhybka.Create(98,30,96,30,96,33,'16',116,True,DajKolajCiara(41),DajKolajCiara(43),DajKolajCiara(40),15));

  t_plan.Add(TNavestidloZriadovacie.Create(87,90,27,33,'Se4',0,0,4));
  t_plan.Add(TNavestidloZriadovacie.Create(103,100,27,33,'Se5',0,0,5));

  t_plan.Add(TText.Create(55,80,'Nemšová',40,True,1));
  t_plan.Add(TText.Create(01,34,'Tr. Teplá',10,False,3));
  t_plan.Add(TText.Create(100,34,'Horné Srnie',10,False,4));
  t_plan.Add(TText.Create(100,54,'Lednické Rovne',10,False,5));

  t_plan.Add(TText.Create(50,60,'4',15,True,6));
  t_plan.Add(TText.Create(50,50,'2',15,True,7));
  t_plan.Add(TText.Create(50,40,'1',15,True,8));
  t_plan.Add(TText.Create(50,30,'3',15,True,9));
  t_plan.Add(TText.Create(61,20,'5',15,True,10));
  t_plan.Add(TText.Create(54,10,'7',15,True,11));
  t_plan.Add(TText.Create(43,30,'3A',15,True,12));
  t_plan.Add(TText.Create(61,30,'3B',15,True,13));

  t_plan.Add(TSulibrk.Create(101,05,1));

  SkontrolujConfig;

  //hitboxy
  t_hitboxy.Add(HitBox(Rect(0,5,37,43),DajObjekt(KJ_KOLAJCIARA,1)));
  t_hitboxy.Add(HitBox(Rect(5,8,37,43),DajObjekt(KJ_NAVESTIDLOVCHODOVE,1)));

  //zahlavie tepla
  t_hitboxy.Add(HitBox(Rect(8,12,37,43),DajObjekt(KJ_KOLAJCIARA,2)));
  t_hitboxy.Add(HitBox(Rect(12,15,37,43),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,1)));

  //zhlavie tepla
  t_hitboxy.Add(HitBox(Rect(19,21,37,42),DajObjekt(KJ_VYHYBKA,1)));
  t_hitboxy.Add(HitBox(Rect(23,25,37,43),DajObjekt(KJ_VYHYBKA,2)));
  t_hitboxy.Add(HitBox(Rect(25,27,47,53),DajObjekt(KJ_VYHYBKA,3)));

  //pdchodove tepla
  t_hitboxy.Add(HitBox(Rect(37,40,27,33),DajObjekt(KJ_NAVESTIDLOODCHODOVE,1)));
  t_hitboxy.Add(HitBox(Rect(37,40,37,43),DajObjekt(KJ_NAVESTIDLOODCHODOVE,2)));
  t_hitboxy.Add(HitBox(Rect(37,40,47,53),DajObjekt(KJ_NAVESTIDLOODCHODOVE,3)));
  t_hitboxy.Add(HitBox(Rect(37,40,57,63),DajObjekt(KJ_NAVESTIDLOODCHODOVE,4)));

  //rozdelena kolaj 3
  t_hitboxy.Add(HitBox(Rect(40,45,27,33),DajObjekt(KJ_KOLAJCIARA,12)));
  t_hitboxy.Add(HitBox(Rect(47,52,27,33),DajObjekt(KJ_KOLAJCIARA,13)));
  t_hitboxy.Add(HitBox(Rect(54,65,27,33),DajObjekt(KJ_KOLAJCIARA,14)));

  //vlecka na tratovku
  t_hitboxy.Add(HitBox(Rect(41,45,20,27),DajObjekt(KJ_KOLAJCIARA,15)));
  t_hitboxy.Add(HitBox(Rect(45,47,27,33),DajObjekt(KJ_VYHYBKA,4)));

  //kolaj pri nakladisku
  t_hitboxy.Add(HitBox(Rect(58,64,17,23),DajObjekt(KJ_KOLAJCIARA,17)));
  t_hitboxy.Add(HitBox(Rect(52,54,27,33),DajObjekt(KJ_VYHYBKA,5)));
  t_hitboxy.Add(HitBox(Rect(48,60,07,13),DajObjekt(KJ_KOLAJCIARA,170)));
  t_hitboxy.Add(HitBox(Rect(64,66,17,23),DajObjekt(KJ_VYHYBKA,16)));

  //ostatne stanicne kolaje
  t_hitboxy.Add(HitBox(Rect(40,65,37,43),DajObjekt(KJ_KOLAJCIARA,18)));
  t_hitboxy.Add(HitBox(Rect(40,65,47,53),DajObjekt(KJ_KOLAJCIARA,19)));
  t_hitboxy.Add(HitBox(Rect(40,65,57,63),DajObjekt(KJ_KOLAJCIARA,20)));

  t_hitboxy.Add(HitBox(Rect(65,68,27,33),DajObjekt(KJ_NAVESTIDLOODCHODOVE,5)));
  t_hitboxy.Add(HitBox(Rect(65,68,37,43),DajObjekt(KJ_NAVESTIDLOODCHODOVE,6)));
  t_hitboxy.Add(HitBox(Rect(65,68,47,53),DajObjekt(KJ_NAVESTIDLOODCHODOVE,7)));
  t_hitboxy.Add(HitBox(Rect(65,68,57,63),DajObjekt(KJ_NAVESTIDLOODCHODOVE,8)));

  //zhlavnie Srnie
  t_hitboxy.Add(HitBox(Rect(70,72,27,33),DajObjekt(KJ_VYHYBKA,6)));

  //vojenska vlecka
  t_hitboxy.Add(HitBox(Rect(78,81,57,63),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,2)));
  t_hitboxy.Add(HitBox(Rect(81,108,57,63),DajObjekt(KJ_KOLAJCIARA,270)));

  //zhlavie srnie
  t_hitboxy.Add(HitBox(Rect(70,72,57,63),DajObjekt(KJ_VYHYBKA,7)));
  t_hitboxy.Add(HitBox(Rect(76,78,47,53),DajObjekt(KJ_VYHYBKA,8)));
  t_hitboxy.Add(HitBox(Rect(76,78,37,43),DajObjekt(KJ_VYHYBKA,9)));

  t_hitboxy.Add(HitBox(Rect(80,82,37,43),DajObjekt(KJ_VYHYBKA,10)));
  t_hitboxy.Add(HitBox(Rect(80,82,47,53),DajObjekt(KJ_VYHYBKA,11)));

  //zahlavie Srnie + vlecka
  t_hitboxy.Add(HitBox(Rect(92,100,37,43),DajObjekt(KJ_KOLAJCIARA,35)));
  t_hitboxy.Add(HitBox(Rect(103,110,37,43),DajObjekt(KJ_KOLAJCIARA,36)));

  //zahlavie Rovne
  t_hitboxy.Add(HitBox(Rect(93,100,47,53),DajObjekt(KJ_KOLAJCIARA,38)));
  t_hitboxy.Add(HitBox(Rect(103,110,47,53),DajObjekt(KJ_KOLAJCIARA,39)));

  t_hitboxy.Add(HitBox(Rect(90,93,47,53),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3)));

  t_hitboxy.Add(HitBox(Rect(86,88,37,43),DajObjekt(KJ_VYHYBKA,12)));
  t_hitboxy.Add(HitBox(Rect(86,88,47,53),DajObjekt(KJ_VYHYBKA,13)));

  t_hitboxy.Add(HitBox(Rect(100,103,37,43),DajObjekt(KJ_NAVESTIDLOVCHODOVE,2)));
  t_hitboxy.Add(HitBox(Rect(100,103,47,53),DajObjekt(KJ_NAVESTIDLOVCHODOVE,3)));

  //vlecka
  t_hitboxy.Add(HitBox(Rect(103,108,27,33),DajObjekt(KJ_KOLAJCIARA,42)));
  t_hitboxy.Add(HitBox(Rect(80,87,27,33),DajObjekt(KJ_KOLAJCIARA,44)));

  t_hitboxy.Add(HitBox(Rect(90,92,37,43),DajObjekt(KJ_VYHYBKA,14)));
  t_hitboxy.Add(HitBox(Rect(96,98,27,33),DajObjekt(KJ_VYHYBKA,15)));

  t_hitboxy.Add(HitBox(Rect(87,90,27,33),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,4)));
  t_hitboxy.Add(HitBox(Rect(100,103,27,33),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5)));
end;
//
//  //zahlavie tepla
//  t_plan.Add(TKolajCiara.Create(0,5,40,40,'TR',1));
//  t_plan.Add(TNavestidloVchodove.Create(5,8,37,43,'L',0,0,0,0,0,0,0,0,0,1));
//  t_plan.Add(TKolajCiara.Create(8,12,40,40,'TR-01K',2));
//  t_plan.Add(TNavestidloZriadovacie.Create(12,15,37,43,'Se1',0,0,1));
//
//  //zhlavie tepla
//  t_plan.Add(TKolajCiara.Create(15,19,40,40,'',3));
//  t_plan.Add(TKolajCiara.Create(25,29,37,30,'',4));
//  t_plan.Add(TKolajCiara.Create(21,23,40,40,'',5));
//
//  t_plan.Add(TKolajCiara.Create(25,37,40,40,'',6));
//  t_plan.Add(TKolajCiara.Create(21,25,43,50,'',7));
//
//  t_plan.Add(TKolajCiara.Create(27,37,50,50,'',8));
//  t_plan.Add(TKolajCiara.Create(27,31,53,60,'',9));
//
//  t_plan.Add(TKolajCiara.Create(29,37,30,30,'',10));
//  t_plan.Add(TKolajCiara.Create(31,37,60,60,'',11));
//
//  t_plan.Add(TVyhybka.Create(19,40,21,40,21,43,'1',101,False,DajKolajCiara(3),DajKolajCiara(5),DajKolajCiara(7),1));
//  t_plan.Add(TVyhybka.Create(23,40,25,40,25,37,'2',102,False,DajKolajCiara(5),DajKolajCiara(6),DajKolajCiara(4),2));
//  t_plan.Add(TVyhybka.Create(25,50,27,50,27,53,'3',103,True,DajKolajCiara(7),DajKolajCiara(8),DajKolajCiara(9),3));
//
//  //pdchodove tepla
//  t_plan.Add(TNavestidloOdchodove.Create(40,37,27,33,'S3',0,0,0,0,0,1));
//  t_plan.Add(TNavestidloOdchodove.Create(40,37,37,43,'S1',0,0,0,0,0,2));
//  t_plan.Add(TNavestidloOdchodove.Create(40,37,47,53,'S2',0,0,0,0,0,3));
//  t_plan.Add(TNavestidloOdchodove.Create(40,37,57,63,'S4',0,0,0,0,0,4));
//
//  //rozdelena kolaj 3
//  t_plan.Add(TKolajCiara.Create(40,45,30,30,'3ASK',12));
//  t_plan.Add(TKolajCiara.Create(47,52,30,30,'3SK',13));
//  t_plan.Add(TKolajCiara.Create(54,65,30,30,'3BSK',14));
//
//  //vlecka na tratovku
//  t_plan.Add(TKolajCiara.Create(41,45,20,27,'VTSK',15));
//  t_plan.Add(TVyhybka.Create(47,30,45,30,45,27,'4',104,True,DajKolajCiara(12),DajKolajCiara(13),DajKolajCiara(15),4));
//
//  //kolaj pri nakladisku
//  t_plan.Add(TKolajCiara.Create(54,58,27,20,'',16));
//  t_plan.Add(TKolajCiara.Create(58,64,20,20,'5SK',17));
//  t_plan.Add(TKolajCiara.Create(66,70,20,27,'',180));
//  t_plan.Add(TVyhybka.Create(52,30,54,30,54,27,'5',105,False,DajKolajCiara(13),DajKolajCiara(14),DajKolajCiara(16),5));
//  t_plan.Add(TKolajCiara.Create(48,60,10,10,'7SK',170));
//  t_plan.Add(TKolajCiara.Create(60,64,10,17,'',171));
//  t_plan.Add(TVyhybka.Create(66,20,64,20,64,17,'6',106,True,DajKolajCiara(180),DajKolajCiara(17),DajKolajCiara(171),16));
//
//  //ostatne stanicne kolaje
//  t_plan.Add(TKolajCiara.Create(40,65,40,40,'1SK',18));
//  t_plan.Add(TKolajCiara.Create(40,65,50,50,'2SK',19));
//  t_plan.Add(TKolajCiara.Create(40,65,60,60,'4SK',20));
//
//  //navestidla srnie
//  t_plan.Add(TNavestidloOdchodove.Create(65,68,27,33,'L3',0,0,0,0,0,5));
//  t_plan.Add(TNavestidloOdchodove.Create(65,68,37,43,'L1',0,0,0,0,0,6));
//  t_plan.Add(TNavestidloOdchodove.Create(65,68,47,53,'L2',0,0,0,0,0,7));
//  t_plan.Add(TNavestidloOdchodove.Create(65,68,57,63,'L4',0,0,0,0,0,8));
//
//  //zhlavnie Srnie
//  t_plan.Add(TKolajCiara.Create(68,70,30,30,'',21));
//  t_plan.Add(TKolajCiara.Create(68,70,60,60,'',22));
//  t_plan.Add(TKolajCiara.Create(68,76,40,40,'',23));
//  t_plan.Add(TKolajCiara.Create(68,76,50,50,'',24));
//
//  t_plan.Add(TKolajCiara.Create(72,76,30,37,'',25));
//  t_plan.Add(TKolajCiara.Create(72,76,57,53,'',26));
//
//  t_plan.Add(TVyhybka.Create(72,30,70,30,70,27,'7',107,True,DajKolajCiara(25),DajKolajCiara(21),DajKolajCiara(180),6));
//
//  //vojenska vlecka
//  t_plan.Add(TKolajCiara.Create(72,78,60,60,'',27));
//  t_plan.Add(TNavestidloZriadovacie.Create(81,78,57,63,'Se2',0,0,2));
//  t_plan.Add(TKolajCiara.Create(81,108,60,60,'VVSK',270));
//
//  //zhlavie srnie
//  t_plan.Add(TKolajCiara.Create(78,80,50,50,'',28));
//  t_plan.Add(TKolajCiara.Create(78,80,40,40,'',29));
//
//  t_plan.Add(TVyhybka.Create(70,60,72,60,72,57,'9/10',109,False,DajKolajCiara(20),DajKolajCiara(27),DajKolajCiara(26),7));
//  t_plan.Add(TVyhybka.Create(78,50,76,50,76,53,'9/10',109,False,DajKolajCiara(28),DajKolajCiara(24),DajKolajCiara(26),8));
//  t_plan.Add(TVyhybka.Create(78,40,76,40,76,37,'8',108,False,DajKolajCiara(29),DajKolajCiara(23),DajKolajCiara(25),9));
//
//  t_plan.Add(TKolajCiara.Create(82,86,40,40,'',30));
//  t_plan.Add(TKolajCiara.Create(82,86,50,50,'',31));
//  t_plan.Add(TKolajCiara.Create(82,86,43,47,'',32));
//  t_plan.Add(TKolajCiara.Create(82,86,47,43,'',33));
//
//  t_plan.Add(TVyhybka.Create(80,40,82,40,82,43,'11/12',111,False,DajKolajCiara(29),DajKolajCiara(30),DajKolajCiara(32),10));
//  t_plan.Add(TVyhybka.Create(80,50,82,50,82,47,'13/14',113,False,DajKolajCiara(28),DajKolajCiara(31),DajKolajCiara(33),11));
//
//  //zahlavie Srnie + vlecka
//  t_plan.Add(TKolajCiara.Create(88,90,40,40,'',34));
//  t_plan.Add(TKolajCiara.Create(92,100,40,40,'HS01K',35));
//  t_plan.Add(TKolajCiara.Create(103,110,40,40,'HS',36));
//
//  //zahlavie Rovne
//  t_plan.Add(TKolajCiara.Create(88,90,50,50,'',37));
//  t_plan.Add(TKolajCiara.Create(93,100,50,50,'LR01K',38));
//  t_plan.Add(TKolajCiara.Create(103,110,50,50,'LR',39));
//
//  t_plan.Add(TNavestidloZriadovacie.Create(93,90,47,53,'Se3',0,0,3));
//
//  t_plan.Add(TVyhybka.Create(88,40,86,40,86,43,'13/14',113,False,DajKolajCiara(34),DajKolajCiara(30),DajKolajCiara(33),12));
//  t_plan.Add(TVyhybka.Create(88,50,86,50,86,47,'11/12',111,False,DajKolajCiara(37),DajKolajCiara(31),DajKolajCiara(32),13));
//
//  t_plan.Add(TNavestidloVchodove.Create(103,100,37,43,'S',0,0,0,0,0,0,0,0,0,2));
//  t_plan.Add(TNavestidloVchodove.Create(103,100,47,53,'PS',0,0,0,0,0,0,0,0,0,3));
//
//  //vlecka
//  t_plan.Add(TKolajCiara.Create(92,96,37,33,'',40));
//  t_plan.Add(TKolajCiara.Create(98,100,30,30,'',41));
//  t_plan.Add(TKolajCiara.Create(103,108,30,30,'VSASK',42));
//  t_plan.Add(TKolajCiara.Create(90,96,30,30,'',43));
//  t_plan.Add(TKolajCiara.Create(80,87,30,30,'VSBSK',44));
//
//  t_plan.Add(TKolajCiara.Create(108,108,28,32,'',45));
//  t_plan.Add(TKolajCiara.Create(80,80,28,32,'',46));
//
//  t_plan.Add(TVyhybka.Create(90,40,92,40,92,37,'15',115,False,DajKolajCiara(34),DajKolajCiara(35),DajKolajCiara(40),14));
//  t_plan.Add(TVyhybka.Create(98,30,96,30,96,33,'16',116,True,DajKolajCiara(41),DajKolajCiara(43),DajKolajCiara(40),15));
//
//  t_plan.Add(TNavestidloZriadovacie.Create(87,90,27,33,'Se4',0,0,4));
//  t_plan.Add(TNavestidloZriadovacie.Create(103,100,27,33,'Se5',0,0,5));
//
//  t_plan.Add(TText.Create(55,80,'Nemšová',40,True,1));
//  t_plan.Add(TText.Create(98,33,'Tr. Teplá',10,False,3));
//  t_plan.Add(TText.Create(03,33,'Horné Srnie',10,False,4));
//  t_plan.Add(TText.Create(03,13,'Lednické Rovne',10,False,5));
//
//  t_plan.Add(TText.Create(60,10,'4',15,True,6));
//  t_plan.Add(TText.Create(60,20,'2',15,True,7));
//  t_plan.Add(TText.Create(60,30,'1',15,True,8));
//  t_plan.Add(TText.Create(60,40,'3',15,True,9));
//  t_plan.Add(TText.Create(49,50,'5',15,True,10));
//  t_plan.Add(TText.Create(56,60,'7',15,True,11));
//  t_plan.Add(TText.Create(67,40,'3A',15,True,12));
//  t_plan.Add(TText.Create(49,40,'3B',15,True,13));
//
//  t_plan.Add(TSulibrk.Create(101,05,1));
//
//  SkontrolujConfig;
//
//  //hitboxy
//  t_hitboxy.Add(HitBox(Rect(0,5,37,43),DajObjekt(KJ_KOLAJCIARA,1)));
//  t_hitboxy.Add(HitBox(Rect(5,8,37,43),DajObjekt(KJ_NAVESTIDLOVCHODOVE,1)));
//
//  //zahlavie tepla
//  t_hitboxy.Add(HitBox(Rect(8,12,37,43),DajObjekt(KJ_KOLAJCIARA,2)));
//  t_hitboxy.Add(HitBox(Rect(12,15,37,43),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,1)));
//
//  //zhlavie tepla
//  t_hitboxy.Add(HitBox(Rect(19,21,37,42),DajObjekt(KJ_VYHYBKA,1)));
//  t_hitboxy.Add(HitBox(Rect(23,25,37,43),DajObjekt(KJ_VYHYBKA,2)));
//  t_hitboxy.Add(HitBox(Rect(25,27,47,53),DajObjekt(KJ_VYHYBKA,3)));
//
//  //pdchodove tepla
//  t_hitboxy.Add(HitBox(Rect(37,40,27,33),DajObjekt(KJ_NAVESTIDLOODCHODOVE,1)));
//  t_hitboxy.Add(HitBox(Rect(37,40,37,43),DajObjekt(KJ_NAVESTIDLOODCHODOVE,2)));
//  t_hitboxy.Add(HitBox(Rect(37,40,47,53),DajObjekt(KJ_NAVESTIDLOODCHODOVE,3)));
//  t_hitboxy.Add(HitBox(Rect(37,40,57,63),DajObjekt(KJ_NAVESTIDLOODCHODOVE,4)));
//
//  //rozdelena kolaj 3
//  t_hitboxy.Add(HitBox(Rect(40,45,27,33),DajObjekt(KJ_KOLAJCIARA,12)));
//  t_hitboxy.Add(HitBox(Rect(47,52,27,33),DajObjekt(KJ_KOLAJCIARA,13)));
//  t_hitboxy.Add(HitBox(Rect(54,65,27,33),DajObjekt(KJ_KOLAJCIARA,14)));
//
//  //vlecka na tratovku
//  t_hitboxy.Add(HitBox(Rect(41,45,20,27),DajObjekt(KJ_KOLAJCIARA,15)));
//  t_hitboxy.Add(HitBox(Rect(45,47,27,33),DajObjekt(KJ_VYHYBKA,4)));
//
//  //kolaj pri nakladisku
//  t_hitboxy.Add(HitBox(Rect(58,64,17,23),DajObjekt(KJ_KOLAJCIARA,17)));
//  t_hitboxy.Add(HitBox(Rect(52,54,27,33),DajObjekt(KJ_VYHYBKA,5)));
//  t_hitboxy.Add(HitBox(Rect(48,60,07,13),DajObjekt(KJ_KOLAJCIARA,170)));
//  t_hitboxy.Add(HitBox(Rect(64,66,17,23),DajObjekt(KJ_VYHYBKA,16)));
//
//  //ostatne stanicne kolaje
//  t_hitboxy.Add(HitBox(Rect(40,65,37,43),DajObjekt(KJ_KOLAJCIARA,18)));
//  t_hitboxy.Add(HitBox(Rect(40,65,47,53),DajObjekt(KJ_KOLAJCIARA,19)));
//  t_hitboxy.Add(HitBox(Rect(40,65,57,63),DajObjekt(KJ_KOLAJCIARA,20)));
//
//  t_hitboxy.Add(HitBox(Rect(65,68,27,33),DajObjekt(KJ_NAVESTIDLOODCHODOVE,5)));
//  t_hitboxy.Add(HitBox(Rect(65,68,37,43),DajObjekt(KJ_NAVESTIDLOODCHODOVE,6)));
//  t_hitboxy.Add(HitBox(Rect(65,68,47,53),DajObjekt(KJ_NAVESTIDLOODCHODOVE,7)));
//  t_hitboxy.Add(HitBox(Rect(65,68,57,63),DajObjekt(KJ_NAVESTIDLOODCHODOVE,8)));
//
//  //zhlavnie Srnie
//  t_hitboxy.Add(HitBox(Rect(70,72,27,33),DajObjekt(KJ_VYHYBKA,6)));
//
//  //vojenska vlecka
//  t_hitboxy.Add(HitBox(Rect(78,81,57,63),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,2)));
//  t_hitboxy.Add(HitBox(Rect(81,108,57,63),DajObjekt(KJ_KOLAJCIARA,270)));
//
//  //zhlavie srnie
//  t_hitboxy.Add(HitBox(Rect(70,72,57,63),DajObjekt(KJ_VYHYBKA,7)));
//  t_hitboxy.Add(HitBox(Rect(76,78,47,53),DajObjekt(KJ_VYHYBKA,8)));
//  t_hitboxy.Add(HitBox(Rect(76,78,37,43),DajObjekt(KJ_VYHYBKA,9)));
//
//  t_hitboxy.Add(HitBox(Rect(80,82,37,43),DajObjekt(KJ_VYHYBKA,10)));
//  t_hitboxy.Add(HitBox(Rect(80,82,47,53),DajObjekt(KJ_VYHYBKA,11)));
//
//  //zahlavie Srnie + vlecka
//  t_hitboxy.Add(HitBox(Rect(92,100,37,43),DajObjekt(KJ_KOLAJCIARA,35)));
//  t_hitboxy.Add(HitBox(Rect(103,110,37,43),DajObjekt(KJ_KOLAJCIARA,36)));
//
//  //zahlavie Rovne
//  t_hitboxy.Add(HitBox(Rect(93,100,47,53),DajObjekt(KJ_KOLAJCIARA,38)));
//  t_hitboxy.Add(HitBox(Rect(103,110,47,53),DajObjekt(KJ_KOLAJCIARA,39)));
//
//  t_hitboxy.Add(HitBox(Rect(90,93,47,53),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3)));
//
//  t_hitboxy.Add(HitBox(Rect(86,88,37,43),DajObjekt(KJ_VYHYBKA,12)));
//  t_hitboxy.Add(HitBox(Rect(86,88,47,53),DajObjekt(KJ_VYHYBKA,13)));
//
//  t_hitboxy.Add(HitBox(Rect(100,103,37,43),DajObjekt(KJ_NAVESTIDLOVCHODOVE,2)));
//  t_hitboxy.Add(HitBox(Rect(100,103,47,53),DajObjekt(KJ_NAVESTIDLOVCHODOVE,3)));
//
//  //vlecka
//  t_hitboxy.Add(HitBox(Rect(103,108,27,33),DajObjekt(KJ_KOLAJCIARA,42)));
//  t_hitboxy.Add(HitBox(Rect(80,87,27,33),DajObjekt(KJ_KOLAJCIARA,44)));
//
//  t_hitboxy.Add(HitBox(Rect(90,92,37,43),DajObjekt(KJ_VYHYBKA,14)));
//  t_hitboxy.Add(HitBox(Rect(96,98,27,33),DajObjekt(KJ_VYHYBKA,15)));
//
//  t_hitboxy.Add(HitBox(Rect(87,90,27,33),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,4)));
//  t_hitboxy.Add(HitBox(Rect(100,103,27,33),DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5)));
////////////////////////////////////////////////////////////////////////////////

procedure TDataModule1.VytvorZaverovku;
var
  cesta: TCesta;
begin
  //Tepla - kolaj 3
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(4),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(10),False);
    cesta.PridajKolaj(DajKolajCiara(12),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(4),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(10),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;


  //// TEPLA ////////////////////

  //Tepla - kolaj 1
  cesta:=TCesta.Create(True,False,CZ_TRATOVA);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(6),False);
    cesta.PridajKolaj(DajKolajCiara(18),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(6),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Tepla - kolaj 2
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(8),False);
    cesta.PridajKolaj(DajKolajCiara(19),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(8),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Tepla - kolaj 4
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(9),False);
    cesta.PridajKolaj(DajKolajCiara(11),False);
    cesta.PridajKolaj(DajKolajCiara(20),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,4));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(2),False);
    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(9),False);
    cesta.PridajKolaj(DajKolajCiara(11),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Tepla ZR - kolaj 3
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(4),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(10),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(4),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(10),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Tepla ZR - kolaj 1
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(6),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(5),False);
    cesta.PridajKolaj(DajKolajCiara(6),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(2),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Tepla ZR - kolaj 2
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(8),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(8),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Tepla ZR - kolaj 4
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,1));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(9),False);
    cesta.PridajKolaj(DajKolajCiara(11),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,4));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,2));

    cesta.PridajKolaj(DajKolajCiara(3),False);
    cesta.PridajKolaj(DajKolajCiara(7),False);
    cesta.PridajKolaj(DajKolajCiara(9),False);
    cesta.PridajKolaj(DajKolajCiara(11),False);

    cesta.PridajVyhybku(DajVyhybka(1),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(3),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //// Kolaj 3 ////////////////////
  // Kolaj 3B - Kolaj 3A
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(12),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,12));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(12),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;
  
  // Kolaj 3B - vlecka Tratovky
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,15));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(15),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ODBOCKA);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,15));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(15),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ODBOCKA);

  finally
    t_zaverovka.Add(cesta);
  end;

  //Kolaj 3B - Kolaj 3C
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,14));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  //Kolaj 3B - Kolaj 5
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,17));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(16),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(5),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,17));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));

    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(16),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(5),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //3A - 3C
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,14));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));

    cesta.PridajKolaj(DajKolajCiara(14),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(12),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,12));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(14),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(12),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  //3C - vlecka tratovky
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,14));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,15));

    cesta.PridajKolaj(DajKolajCiara(15),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,15));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(15),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ODBOCKA);

  finally
    t_zaverovka.Add(cesta);
  end;

  //kolaj 3A - kolaj 5
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,12));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,17));

    cesta.PridajKolaj(DajKolajCiara(12),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(16),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,17));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));

    cesta.PridajKolaj(DajKolajCiara(12),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(16),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //// SRNIE ////////////////////

  //Srnie - kolaj 3
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(12),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,5));

    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,36));

    cesta.PridajKolaj(DajKolajCiara(35),False);

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie - kolaj 1
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(35),False);

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajKolaj(DajKolajCiara(18),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,6));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,36));

    cesta.PridajKolaj(DajKolajCiara(35),False);

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie - kolaj 2
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajKolaj(DajKolajCiara(19),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,7));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,36));

    cesta.PridajKolaj(DajKolajCiara(35),False);

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie - kolaj 4
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(35),False);

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajKolaj(DajKolajCiara(20),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,8));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,36));

    cesta.PridajKolaj(DajKolajCiara(35),False);

    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie ZR - kolaj 7
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,170));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(170),False);
    cesta.PridajKolaj(DajKolajCiara(171),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,170));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(170),False);
    cesta.PridajKolaj(DajKolajCiara(171),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie ZR - Kolaj 5
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,17));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,17));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie ZR - Kolaj 3
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));
    
    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie ZR - Kolaj 1
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,6));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie ZR - Kolaj 2
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,7));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Srnie ZR - Kolaj 4
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,35));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,8));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,35));

    cesta.PridajKolaj(DajKolajCiara(35),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //// Rovne //////////////////////

  //Rovne - Kolaj 3
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,12));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,13));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(38),False);

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);
    
    cesta.PridajKolaj(DajKolajCiara(12),False);
    cesta.PridajKolaj(DajKolajCiara(13),False);
    cesta.PridajKolaj(DajKolajCiara(14),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(4),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(5),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,39));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(38),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne - Kolaj 1
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(38),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajKolaj(DajKolajCiara(18),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,6));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,39));

    cesta.PridajKolaj(DajKolajCiara(38),False);

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne - Kolaj 2
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(38),False);

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajKolaj(DajKolajCiara(19),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,7));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,39));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(38),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne - Kolaj 4
  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOVCHODOVE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(38),False);

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajKolaj(DajKolajCiara(20),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(True,False,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,8));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,39));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(38),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne ZR - Kolaj 7
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,170));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(170),False);
    cesta.PridajKolaj(DajKolajCiara(171),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,170));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(170),False);
    cesta.PridajKolaj(DajKolajCiara(171),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne ZR - Kolaj 5
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,17));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,17));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne ZR - Kolaj 3
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne ZR - Kolaj 1
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,6));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(32),False);
    cesta.PridajKolaj(DajKolajCiara(33),True);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(13),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne ZR - Kolaj 2
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,7));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Rovne ZR - Kolaj 4
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,3));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,8));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,38));

    cesta.PridajKolaj(DajKolajCiara(37),False);
    cesta.PridajKolaj(DajKolajCiara(31),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(12),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(13),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //// Vlecka
  // Vlecka A - Vlecka B
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,4));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(43),False);

    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,44));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(43),False);

    cesta.PridajVyhybku(DajVyhybka(15),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  // Vlecka B - Kolaj 7
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,170));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(170),False);
    cesta.PridajKolaj(DajKolajCiara(171),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,170));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(170),False);
    cesta.PridajKolaj(DajKolajCiara(171),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  // Vlecka B - Kolaj 5
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,17));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_KOLAJCIARA,17));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajKolaj(DajKolajCiara(180),False);
    cesta.PridajKolaj(DajKolajCiara(17),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(16),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  // Vlecka B - Kolaj 3
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,14));
    
    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));
    
    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(21),False);
    cesta.PridajKolaj(DajKolajCiara(25),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(6),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  // VLecka B - Kolaj 1
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,18));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,6));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(30),False);
    cesta.PridajKolaj(DajKolajCiara(29),False);
    cesta.PridajKolaj(DajKolajCiara(23),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(10),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(11),VPO_ROVNO);
    cesta.PridajVyhybku(DajVyhybka(9),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  // Vlecka B - Kolaj 2
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,19));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,7));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(24),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);

  finally
    t_zaverovka.Add(cesta);
  end;

  // Vlecka B - Kolaj 4
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,5));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,8));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,42));

    cesta.PridajKolaj(DajKolajCiara(41),False);
    cesta.PridajKolaj(DajKolajCiara(40),False);
    cesta.PridajKolaj(DajKolajCiara(34),False);
    cesta.PridajKolaj(DajKolajCiara(32),True);
    cesta.PridajKolaj(DajKolajCiara(33),False);
    cesta.PridajKolaj(DajKolajCiara(28),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);
    cesta.PridajKolaj(DajKolajCiara(26),False);

    cesta.PridajVyhybku(DajVyhybka(14),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(15),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(12),VPO_ODBOCKA);
    cesta.PridajVyhybku(DajVyhybka(8),VPO_ODBOCKA);
  finally
    t_zaverovka.Add(cesta);
  end;

  //Vlecka VP
  //Vlecka VP - Kolaj 4
  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOODCHODOVE,8));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,270));

    cesta.PridajKolaj(DajKolajCiara(27),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);

    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

  cesta:=TCesta.Create(False,True,CZ_40);
  try
    cesta.PridajZdroj(DajObjekt(KJ_NAVESTIDLOZRIADOVACIE,2));
    cesta.PridajCiel(DajObjekt(KJ_KOLAJCIARA,20));

    cesta.PridajKolaj(DajKolajCiara(27),False);
    cesta.PridajKolaj(DajKolajCiara(22),False);

    cesta.PridajVyhybku(DajVyhybka(8),VPO_ROVNO);
  finally
    t_zaverovka.Add(cesta);
  end;

end;

end.
