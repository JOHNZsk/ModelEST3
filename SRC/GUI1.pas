unit GUI1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  Vcl.Graphics,
  StavadloObjekty,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Skia,
  Vcl.Skia;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Funkcie1: TMenuItem;
    Drtoah1: TMenuItem;
    Diagnostika1: TMenuItem;
    HorPanel: TPanel;
    VJednotka: TLabel;
    Panel1: TPanel;
    VLoconet: TLabel;
    Koniec1: TMenuItem;
    N1: TMenuItem;
    Resetnvstidel1: TMenuItem;
    Resetvhybej1: TMenuItem;
    Panel2: TPanel;
    PanelRizik: TPanel;
    PanelPoruch: TPanel;
    Cas: TLabel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    STOJ1: TMenuItem;
    DN1: TMenuItem;
    SNAV: TMenuItem;
    P1: TMenuItem;
    P2: TMenuItem;
    SZAV: TMenuItem;
    STIT1: TMenuItem;
    VYL1: TMenuItem;
    PN1: TMenuItem;
    STAV1: TMenuItem;
    SSTAV: TMenuItem;
    SVYL: TMenuItem;
    RESET1: TMenuItem;
    ZAV1: TMenuItem;
    ZAV2: TMenuItem;
    SVYH: TMenuItem;
    ZAM1: TMenuItem;
    ZAM2: TMenuItem;
    SZAM: TMenuItem;
    Panel4: TPanel;
    VZ21: TLabel;
    PanelSV: TPanel;
    Label1: TLabel;
    StitokVyluka: TEdit;
    Panel5: TPanel;
    KPV1: TMenuItem;
    KSV1: TMenuItem;
    RNAV1: TMenuItem;
    RVYH1: TMenuItem;
    Nastavenia1: TMenuItem;
    Predefinovanietextov1: TMenuItem;
    NAZOV1: TMenuItem;
    N2: TMenuItem;
    Nacelobrazovku1: TMenuItem;
    PanelOkraj: TPanel;
    Predefinovaniekonfigurcie1: TMenuItem;
    Z211: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Z21Panel: TPanel;
    Z21TeplotaVnitrni: TLabel;
    Z21ProudZpetny: TLabel;
    Z21NapetiVnejsi: TLabel;
    Z21NapetiVnitrni: TLabel;
    Z21ProudVstup: TLabel;
    Z21Stav: TLabel;
    Z21Vystraha: TLabel;
    Z21ProgramKolejProud: TLabel;
    Label2: TLabel;
    ZrusStopBtn: TButton;
    Panel7: TPanel;
    Z21M: TMenuItem;
    StopBtn: TButton;
    Modelovas1: TMenuItem;
    CasDvojklikTimer: TTimer;
    N3: TMenuItem;
    ProgramovanieadriesaFREDov1: TMenuItem;
    DOH1: TMenuItem;
    DOH2: TMenuItem;
    APN1: TMenuItem;
    APN2: TMenuItem;
    PaintBoxPoruchy: TSkPaintBox;
    PaintBoxRizika: TSkPaintBox;
    PaintBox1: TSkPaintBox;
    procedure Diagnostika1Click(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Koniec1Click(Sender: TObject);
    procedure Drtoah1Click(Sender: TObject);
    procedure Resetnvstidel1Click(Sender: TObject);
    procedure Resetvhybej1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure STAV1Click(Sender: TObject);
    procedure PaintBox1MouseLeave(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure StitokVylukaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Predefinovanietextov1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Nacelobrazovku1Click(Sender: TObject);
    procedure Predefinovaniekonfigurcie1Click(Sender: TObject);
    procedure Z211Click(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ZrusStopBtnClick(Sender: TObject);
    procedure Z21MClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure CasDblClick(Sender: TObject);
    procedure Modelovas1Click(Sender: TObject);
    procedure CasClick(Sender: TObject);
    procedure PaintBoxPoruchyClick(Sender: TObject);
    procedure CasDvojklikTimerTimer(Sender: TObject);
    procedure ProgramovanieadriesaFREDov1Click(Sender: TObject);
    procedure STAV1DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure STOJ1DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure PaintBoxPoruchyDraw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxRizikaDraw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
    procedure PaintBox1Draw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
  private
    { Private declarations }
    t_maximalizovat: Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    property Maximalizovat: Boolean read t_maximalizovat;
    { Public declarations }

    procedure VypisChybu(p_text: string);
    procedure Spusti(p_fullscreen,p_maximalizovat: Boolean);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.DateUtils,
  System.UITypes,
  System.Math,
  Generics.Collections,
  Vcl.Themes,
  ComPort,
  DiagDialog,
  LogikaStavadlo,
  DratotahDialog,
  TextyDialog,
  Splash,
  KonfigDialog,
  Z21Dialog,
  CasDialog,
  ProgDialog;

procedure TForm1.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  DiagDlg.AppIdle;
  Z21Dlg.AppIdle;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.ZrusStopBtnClick(Sender: TObject);
begin
  Z21Dlg.ZrusSkrat;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.CasClick(Sender: TObject);
begin
  if not CasDvojklikTimer.Enabled then CasDvojklikTimer.Enabled:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.CasDblClick(Sender: TObject);
begin
  CasDvojklikTimer.Enabled:=False;
  if not CasDlg.Visible then CasDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.CasDvojklikTimerTimer(Sender: TObject);
begin
  CasDvojklikTimer.Enabled:=False;

  if LogikaES.CasTyp<>TCA_REALNY then
  begin
    if LogikaES.CasStoji then LogikaES.SpustiCas
    else LogikaES.ZastavCas;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Diagnostika1Click(Sender: TObject);
begin
  DiagDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Drtoah1Click(Sender: TObject);
begin
  DratotahDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form2.Close;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormCreate(Sender: TObject);
begin
  t_maximalizovat:=False;

  VJednotka.Caption:='';
  VLoconet.Caption:='';
  VZ21.Caption:='';
  PanelSV.Visible:=False;

  DoubleBuffered:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Spusti(p_fullscreen,p_maximalizovat: Boolean);
begin
  Show;
  t_maximalizovat:=p_maximalizovat;

  if p_fullscreen then
  begin
    Form1.BorderStyle:=bsNone;
    Nacelobrazovku1.Checked:=True;
  end;
  if p_fullscreen or p_maximalizovat then Form1.WindowState:=wsMaximized;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  LogikaES.SpracujKlavesu(Key,Shift);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormResize(Sender: TObject);
begin
  if Form1.Width>1024 then
  begin
    PanelPoruch.Width:=Form1.Width div 3;
  end
  else PanelPoruch.Width:=400;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Z21MClick(Sender: TObject);
begin
  if not Z21Panel.Visible and Z21Dlg.JePripojene then
  begin
    Z21Panel.Visible:=True;
    Z21M.Checked:=True;
  end
  else if Z21Panel.Visible then
  begin
    Z21Panel.Visible:=False;
    Z21M.Checked:=False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Koniec1Click(Sender: TObject);
begin
  Close;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Modelovas1Click(Sender: TObject);
begin
  CasDlg.Show
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Nacelobrazovku1Click(Sender: TObject);
begin
  if BorderStyle=bsNone then
  begin
    if not Maximalizovat then WindowState:=wsNormal;
    Form1.BorderStyle:=bsSizeable;
    Nacelobrazovku1.Checked:=False;
  end
  else
  begin
    if WindowState=wsMaximized then WindowState:=wsNormal;
    BorderStyle:=bsNone;
    WindowState:=wsMaximized;
    Nacelobrazovku1.Checked:=True;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBox1MouseLeave(Sender: TObject);
begin
  LogikaES.ZrusHint;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  LogikaES.VyberHint(X,Y);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button in [mbLeft,mbMiddle]) then LogikaES.VyberJednotku(X,Y,Shift,Button=mbMiddle)
  else if(Button=mbRight) then LogikaES.VyberZrusenie(X,Y,Shift);
end;

////////////////////////////////////////////////////////////////////////////////

procedure VykresliHitBox(p_ciel: ISkSurface; p_dest: TRectF; p_hitbox: THitBox; p_posun: Boolean);
var
  x_zac,y_zac,x_kon,y_kon: Single;
  farba: ISKPaint;
begin
  x_zac:=(p_hitbox.Poloha.Left*p_dest.Width)/LogikaES.SirkaPlanu;
  y_zac:=(p_hitbox.Poloha.Top*p_dest.Height)/LogikaES.VyskaPlanu;
  x_kon:=(p_hitbox.Poloha.Right*p_dest.Width)/LogikaES.SirkaPlanu;
  y_kon:=(p_hitbox.Poloha.Bottom*p_dest.Height)/LogikaES.VyskaPlanu;

  farba:=TSKPaint.Create;

  if p_posun then farba.Color:=TAlphaColors.White
  else farba.Color:=TAlphaColors.Lime;

  farba.StrokeWidth:=2;
  farba.Style:=TSkPaintStyle.Stroke;

  p_ciel.Canvas.DrawRect(RectF(x_zac,y_zac,x_kon,y_kon),farba);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBox1Draw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  objekt: TStavadloObjekt;
  volba,volba_pred: TPair<TStavadloObjekt,Boolean>;
  bitmap: ISkSurface;
  farba_pozadie: ISkPaint;
  farba_relief: ISkPaint;
begin
  farba_pozadie:=TSkPaint.Create;
  farba_pozadie.Color:=TAlphaColors.Black;

  farba_relief:=TSkPaint.Create;
  farba_relief.Color:=TAlphaColors.Gray;
  farba_relief.AntiAlias:=True;
  farba_relief.StrokeCap:=TSkStrokeCap.Round;

  if LogikaES.NudzovyPovel then
  begin
    if (SecondOf(Now) mod 2)=0 then PanelOkraj.Color:=clRed
    else PanelOkraj.Color:=clLime;
  end
  else PanelOkraj.Color:=clBlack;

  bitmap:=TSkSurface.MakeRaster(Ceil(ADest.Width),Ceil(ADest.Height));

  bitmap.Canvas.Clear(TAlphaColors.Black);
  for objekt in LogikaES.DajObjekty do if not (objekt is TNavestidlo) then objekt.Vykresli(bitmap,ADest,farba_pozadie,farba_relief);
  for objekt in LogikaES.DajObjekty do if (objekt is TNavestidlo) then objekt.Vykresli(bitmap,ADest,farba_pozadie,farba_relief);

  volba_pred.Key:=nil;
  volba_pred.Value:=False;

  for volba in LogikaES.DajVolby do
  begin
    if volba.Key<>volba_pred.Key then
    begin
      VykresliHitBox(bitmap,ADest,LogikaES.DajHitBox(volba.Key),volba.Value);
      volba_pred.Key:=volba.Key;
      volba_pred.Value:=volba.Value;
    end;
  end;

  bitmap.Draw(ACanvas,0,0);
end;

////////////////////////////////////////////////////////////////////////////////

procedure VykresliPoruchu(p_ciel: ISkSurface; p_rozm: TRectF; p_nazvy_dopravni: Boolean; p_od,p_do: Single; p_porucha: TPorucha);
var
  dopravna: string;
  font: ISkFont;
  farba: ISkPaint;
begin
  font:=TSkFont.Create(TSkTypeface.MakeFromName('Tahoma',TSkFontStyle.Normal),18);
  farba:=TSkPaint.Create;
  farba.Color:=TAlphaColors.Black;

  if p_porucha.Dopravna<>nil then dopravna:=p_porucha.Dopravna.Skratka
  else dopravna:='';

  p_ciel.Canvas.DrawSimpleText(FormatDateTime('hh:nn:ss',p_porucha.Cas),28,p_do-6,font,farba);

  if p_nazvy_dopravni and (dopravna<>'') then
  begin
    p_ciel.Canvas.DrawSimpleText('['+dopravna+']',108,p_do-6,font,farba);
    p_ciel.Canvas.DrawSimpleText(p_porucha.Text,158,p_do-6,font,farba);
  end
  else p_ciel.Canvas.DrawSimpleText(p_porucha.Text,108,p_do-6,font,farba);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBoxPoruchyClick(Sender: TObject);
begin
  LogikaES.PotvrdPoruchu;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBoxPoruchyDraw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  tmp: ISkSurface;
  cas: TDateTime;
  biela_rect: ISkPaint;
  fuchsia_rect: ISkPaint;
begin
  cas:=Now;

  tmp:=TSkSurface.MakeRaster(Ceil(ADest.Width),Ceil(ADest.Height));

  biela_rect:=TSkPaint.Create;
  biela_rect.Color:=TAlphaColors.White;

  fuchsia_rect:=TSkPaint.Create;
  fuchsia_rect.Color:=TAlphaColors.Fuchsia;

  tmp.Canvas.Clear(TAlphaColors.Black);

  case LogikaES.PocetPoruch of
    0:
    begin
      //does nth
    end;
    1:
    begin
      tmp.Canvas.DrawRect(RectF(0,0,ADest.Width-1,(ADest.Height/4)-1),biela_rect);
      if(SecondOf(cas) mod 2)=0 then tmp.Canvas.DrawRect(RectF(3,3,18,(ADest.Height/4)-4),fuchsia_rect);
    end;
    2:
    begin
      tmp.Canvas.DrawRect(RectF(0,0,ADest.Width-1,((ADest.Height*2)/4)-1),biela_rect);
      if(SecondOf(cas) mod 2)=0 then tmp.Canvas.DrawRect(RectF(3,3,18,((ADest.Height*2)/4)-4),fuchsia_rect);
    end;
    3:
    begin
      tmp.Canvas.DrawRect(RectF(0,0,ADest.Width-1,((ADest.Height*3)/4)-1),biela_rect);
      if(SecondOf(cas) mod 2)=0 then tmp.Canvas.DrawRect(RectF(3,3,18,((ADest.Height*3)/4)-4),fuchsia_rect);
    end
    else
    begin
      tmp.Canvas.DrawRect(RectF(0,0,ADest.Width-1,ADest.Height-1),biela_rect);
      if(SecondOf(cas) mod 2)=0 then tmp.Canvas.DrawRect(RectF(3,3,18,ADest.Height-4),fuchsia_rect);
    end;
  end;


  if(LogikaES.PocetPoruch>0) then VykresliPoruchu(tmp,ADest,LogikaES.NazvyDopravni,5,(ADest.Height/4)-4,LogikaES.DajPoruchu(0));
  if(LogikaES.PocetPoruch>1) then VykresliPoruchu(tmp,ADest,LogikaES.NazvyDopravni,(ADest.Height/4)+5,((ADest.Height*2)/4)-4,LogikaES.DajPoruchu(1));
  if(LogikaES.PocetPoruch>2) then VykresliPoruchu(tmp,ADest,LogikaES.NazvyDopravni,((ADest.Height*2)/4)+5,((ADest.Height*3)/4)-4,LogikaES.DajPoruchu(2));
  if(LogikaES.PocetPoruch>3) then VykresliPoruchu(tmp,ADest,LogikaES.NazvyDopravni,((ADest.Height*3)/4)+5,ADest.Height-4,LogikaES.DajPoruchu(3));

  tmp.Draw(ACanvas,ADest.Left,ADest.Top);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBoxRizikaDraw(ASender: TObject; const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  tmp: ISkSurface;
  font: ISkFont;
  farba_cervena,farba_cierna,farba_biela,farba_vypis: ISkPaint;
  max_sirka,max_popis: Single;
  text_dopravna: string;
  text_nazov: string;
  popis_a,popis_b,popis_c,popis_d,popis_e: string;
  text_a,text_b,text_c,text_d,text_e: string;
  cervena_a,cervena_b,cervena_c,cervena_d,cervena_e: Boolean;
  text_potvrd: string;
  vyska_r,pozicia_r: Single;
begin
  tmp:=TSkSurface.MakeRaster(PaintBoxRizika.Width,PaintBoxRizika.Height);
  font:=TSkFont.Create(TSkTypeface.MakeFromName('Tahoma',TSkFontStyle.Bold),10);

  farba_cervena:=TSkPaint.Create;
  farba_cervena.Color:=TAlphaColors.Red;

  farba_cierna:=TSkPaint.Create;
  farba_cierna.Color:=TAlphaColors.Black;

  farba_biela:=TSkPaint.Create;
  farba_biela.Color:=TAlphaColors.White;

  tmp.Canvas.Clear(TAlphaColors.Black);

  max_sirka:=0;

  if LogikaES.NudzovyPovel then
  begin
    if(LogikaES.NudzovyPovelDopravna<>nil) then text_dopravna:=LogikaES.NudzovyPovelDopravna.Nazov
    else text_dopravna:='Globálny';

    if font.MeasureText(text_dopravna,farba_cierna)>max_sirka then max_sirka:=font.MeasureText(text_dopravna,farba_cierna);

    text_nazov:=NudzovyPovelTypText(LogikaES.NudzovyPovelTyp);
    if font.MeasureText(text_nazov,farba_cierna)>max_sirka then max_sirka:=font.MeasureText(text_nazov,farba_cierna);

    popis_a:='(A)';
    popis_b:='(B)';
    popis_c:='(C)';
    popis_d:='(D)';
    popis_e:='(E)';

    text_a:='';
    text_b:='';
    text_c:='';
    text_d:='';
    text_e:='';

    cervena_a:=False;
    cervena_b:=False;
    cervena_c:=False;
    cervena_d:=False;
    cervena_e:=False;

    case LogikaES.NudzovyPovelTyp of
      NPT_STAV,NPT_ZRUSVYLUKU,NPT_ZRUSSTITOK: LogikaES.NudzovyPovelPrvok.VypisNudzovyPovelStav(popis_a,popis_b,popis_c,popis_d,popis_e,text_a,text_b,text_c,text_d,text_e,cervena_a,cervena_b,cervena_c,cervena_d,cervena_e);
      NPT_RESETNAV: (LogikaES.NudzovyPovelPrvok as TNavestidlo).VypisNudzovyPovelReset(popis_a,popis_b,popis_c,popis_d,text_a,text_b,text_c,text_d,cervena_a,cervena_b,cervena_c,cervena_d);
      NPT_RESETVYH: (LogikaES.NudzovyPovelPrvok as TVyhybka).VypisNudzovyPovelReset(popis_a,popis_b,popis_c,popis_d,text_a,text_b,text_c,text_d,cervena_a,cervena_b,cervena_c,cervena_d);
      NPT_RESETNAVGLOBAL: LogikaES.VypisNudzovyPovelNavestidla(nil,popis_a,popis_b,popis_c,text_a,text_b,text_c,cervena_a,cervena_b,cervena_c);
      NPT_RESETVYHGLOBAL: LogikaES.VypisNudzovyPovelVyhybky(nil,popis_a,popis_b,popis_c,text_a,text_b,text_c,cervena_a,cervena_b,cervena_c);
      NPT_PRIVOLAVACKA: (LogikaES.NudzovyPovelPrvok as TNavestidloHlavne).VypisNudzovyPovelPrivolavacka(popis_a,popis_b,popis_c,popis_d,text_a,text_b,text_c,text_d,cervena_a,cervena_b,cervena_c,cervena_d);
      NPT_ZAV2: (LogikaES.NudzovyPovelPrvok as TVyhybka).VypisNudzovyPovelZAV2(popis_a,popis_b,popis_c,popis_d,text_a,text_b,text_c,text_d,cervena_a,cervena_b,cervena_c,cervena_d);
      NPT_DOH1,NPT_DOH2: (LogikaES.NudzovyPovelPrvok as TVyhybkaDohlad).VypisNudzovyPovelDOH(popis_a,popis_b,popis_c,popis_d,popis_e,text_a,text_b,text_c,text_d,text_e,cervena_a,cervena_b,cervena_c,cervena_d,cervena_e);
      NPT_APN1,NPT_APN2: (LogikaES.NudzovyPovelPrvok as TNavestidloHlavne).VypisNudzovyPovelAPN(popis_a,popis_b,popis_c,popis_d,popis_e,text_a,text_b,text_c,text_d,text_e,cervena_a,cervena_b,cervena_c,cervena_d,cervena_e);
      NPT_KPV: LogikaES.VypisNudzovyPovelKPV(LogikaES.NudzovyPovelDopravna,popis_a,popis_b,popis_c,popis_d,popis_e,text_a,text_b,text_c,text_d,text_e,cervena_a,cervena_b,cervena_c,cervena_d,cervena_e);
      NPT_KSV: LogikaES.VypisNudzovyPovelKSV(LogikaES.NudzovyPovelDopravna,popis_a,popis_b,popis_c,text_a,text_b,text_c,cervena_a,cervena_b,cervena_c);
      NPT_RESETNAVDOP: LogikaES.VypisNudzovyPovelNavestidla(LogikaES.NudzovyPovelDopravna,popis_a,popis_b,popis_c,text_a,text_b,text_c,cervena_a,cervena_b,cervena_c);
      NPT_RESETVYHDOP: LogikaES.VypisNudzovyPovelVyhybky(LogikaES.NudzovyPovelDopravna,popis_a,popis_b,popis_c,text_a,text_b,text_c,cervena_a,cervena_b,cervena_c);
    end;

    max_popis:=0;
    if font.MeasureText(popis_a,farba_cierna)>max_popis then max_popis:=font.MeasureText(popis_a,farba_cierna);
    if font.MeasureText(popis_b,farba_cierna)>max_popis then max_popis:=font.MeasureText(popis_b,farba_cierna);
    if font.MeasureText(popis_c,farba_cierna)>max_popis then max_popis:=font.MeasureText(popis_c,farba_cierna);
    if font.MeasureText(popis_d,farba_cierna)>max_popis then max_popis:=font.MeasureText(popis_d,farba_cierna);
    if font.MeasureText(popis_e,farba_cierna)>max_popis then max_popis:=font.MeasureText(popis_e,farba_cierna);
    max_popis:=max_popis+8;

    if max_popis+font.MeasureText(text_a,farba_cierna)>max_sirka then max_sirka:=max_popis+font.MeasureText(text_a,farba_cierna)+8;
    if max_popis+font.MeasureText(text_b,farba_cierna)>max_sirka then max_sirka:=max_popis+font.MeasureText(text_b,farba_cierna)+8;
    if max_popis+font.MeasureText(text_c,farba_cierna)>max_sirka then max_sirka:=max_popis+font.MeasureText(text_c,farba_cierna)+8;
    if max_popis+font.MeasureText(text_d,farba_cierna)>max_sirka then max_sirka:=max_popis+font.MeasureText(text_d,farba_cierna)+8;
    if max_popis+font.MeasureText(text_e,farba_cierna)>max_sirka then max_sirka:=max_popis+font.MeasureText(text_e,farba_cierna)+8;

    case LogikaES.NudzovyPovelPotvrdTyp of
      NPP_ENTER: text_potvrd:='Potvrď (ENTER)';
      NPP_ASDF: text_potvrd:='Potvrď (ASDF): ';
      else text_potvrd:='Potvrď';
    end;

    text_potvrd:=text_potvrd+LogikaES.NudzovyPovelSekvencia;
    if font.MeasureText(text_potvrd,farba_cierna)>max_sirka then max_sirka:=font.MeasureText(text_potvrd,farba_cierna);

    max_sirka:=max_sirka+15;

    tmp.Canvas.DrawRect(RectF(0,0,max_sirka-1,(ADest.Height/4)-1),farba_biela);
    tmp.Canvas.DrawRect(RectF(0,(ADest.Height/4)+1,max_sirka-1,(ADest.Height*7)/8),farba_biela);

    tmp.Canvas.DrawSimpleText(text_dopravna,(max_sirka-font.MeasureText(text_dopravna,farba_cervena))/2,12,font,farba_cervena);
    tmp.Canvas.DrawSimpleText(text_nazov,(max_sirka-font.MeasureText(text_nazov,farba_cierna))/2,26,font,farba_cierna);

    vyska_r:=(((ADest.Height*7)/8)-((ADest.Height/4)+1))/5;
    pozicia_r:=(ADest.Height/4)+2+10;

    if cervena_a then farba_vypis:=farba_cervena else farba_vypis:=farba_cierna;

    tmp.Canvas.DrawSimpleText(popis_a,5,pozicia_r,font,farba_vypis);
    tmp.Canvas.DrawSimpleText(text_a,max_popis,pozicia_r,font,farba_vypis);
    pozicia_r:=pozicia_r+vyska_r;

    if cervena_b then farba_vypis:=farba_cervena else farba_vypis:=farba_cierna;

    tmp.Canvas.DrawSimpleText(popis_b,5,pozicia_r,font,farba_vypis);
    tmp.Canvas.DrawSimpleText(text_b,max_popis,pozicia_r,font,farba_vypis);
    pozicia_r:=pozicia_r+vyska_r;

    if cervena_c then farba_vypis:=farba_cervena else farba_vypis:=farba_cierna;

    tmp.Canvas.DrawSimpleText(popis_c,5,pozicia_r,font,farba_vypis);
    tmp.Canvas.DrawSimpleText(text_c,max_popis,pozicia_r,font,farba_vypis);
    pozicia_r:=pozicia_r+vyska_r;

    if cervena_d then farba_vypis:=farba_cervena else farba_vypis:=farba_cierna;

    tmp.Canvas.DrawSimpleText(popis_d,5,pozicia_r,font,farba_vypis);
    tmp.Canvas.DrawSimpleText(text_d,max_popis,pozicia_r,font,farba_vypis);
    pozicia_r:=pozicia_r+vyska_r;

    if cervena_e then farba_vypis:=farba_cervena else farba_vypis:=farba_cierna;

    tmp.Canvas.DrawSimpleText(popis_e,5,pozicia_r,font,farba_vypis);
    tmp.Canvas.DrawSimpleText(text_e,max_popis,pozicia_r,font,farba_vypis);

    tmp.Canvas.DrawSimpleText(text_potvrd,1,(ADest.Height*7)/8+1+10,font,farba_biela);
  end;

  tmp.Draw(ACanvas,ADest.Left,ADest.Top);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Predefinovaniekonfigurcie1Click(Sender: TObject);
begin
  KonfigDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Predefinovanietextov1Click(Sender: TObject);
begin
  TextyDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.ProgramovanieadriesaFREDov1Click(Sender: TObject);
begin
  ProgDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Resetnvstidel1Click(Sender: TObject);
begin
  LogikaES.ResetujNavestidla(nil,False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Resetvhybej1Click(Sender: TObject);
begin
  LogikaES.ResetujVyhybky(nil,False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.STAV1Click(Sender: TObject);
begin
  if Sender=STAV1 then LogikaES.SpracujMenu(MK_STAV)
  else if Sender=STOJ1 then LogikaES.SpracujMenu(MK_STOJ)
  else if Sender=DN1 then LogikaES.SpracujMenu(MK_DN)
  else if Sender=PN1 then LogikaES.SpracujMenu(MK_PN)
  else if Sender=ZAM1 then LogikaES.SpracujMenu(MK_ZAM1)
  else if Sender=ZAM2 then LogikaES.SpracujMenu(MK_ZAM2)
  else if Sender=P1 then LogikaES.SpracujMenu(MK_P1)
  else if Sender=P2 then LogikaES.SpracujMenu(MK_P2)
  else if Sender=ZAV1 then LogikaES.SpracujMenu(MK_ZAV1)
  else if Sender=ZAV2 then LogikaES.SpracujMenu(MK_ZAV2)
  else if Sender=DOH1 then LogikaES.SpracujMenu(MK_DOH1)
  else if Sender=DOH2 then LogikaES.SpracujMenu(MK_DOH2)
  else if Sender=APN1 then LogikaES.SpracujMenu(MK_APN1)
  else if Sender=APN2 then LogikaES.SpracujMenu(MK_APN2)
  else if Sender=STIT1 then LogikaES.SpracujMenu(MK_STIT)
  else if Sender=VYL1 then LogikaES.SpracujMenu(MK_VYL)
  else if Sender=RESET1 then LogikaES.SpracujMenu(MK_RESET)
  else if Sender=KPV1 then LogikaES.SpracujMenu(MK_KPV)
  else if Sender=KSV1 then LogikaES.SpracujMenu(MK_KSV)
  else if Sender=RNAV1 then LogikaES.SpracujMenu(MK_RNAV)
  else if Sender=RVYH1 then LogikaES.SpracujMenu(MK_RVYH)
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.STAV1DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
  LStyles: TCustomStyleServices;
  Text: string;
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scComboBox);
begin

 LStyles := StyleServices;

 Text := StringReplace((Sender as TMenuItem).Caption,'&','',[rfReplaceAll]);

 ACanvas.Brush.Color := LStyles.GetStyleColor(ColorStates[(Sender as TMenuItem).Enabled]);
 ACanvas.Font.Color  := clRed;
 ACanvas.Font.Style:=[fsBold];

 if Selected then
 begin
   ACanvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
   ACanvas.Font.Color  := clRed;
 end;

 ACanvas.FillRect(ARect);
 ACanvas.TextOut(ARect.Left + 40, ARect.Top +4, Text);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.StitokVylukaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then LogikaES.PotvrdStitokVyluku
  else if Key=VK_ESCAPE then LogikaES.ZrusStitokVyluku;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.STOJ1DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
  LStyles: TCustomStyleServices;
  Text: string;
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scComboBox);
  FontColorStates: array[Boolean] of TStyleFont = (sfPopupMenuItemTextDisabled, sfPopupMenuItemTextNormal);
begin

 LStyles := StyleServices;

 Text := StringReplace((Sender as TMenuItem).Caption,'&','',[rfReplaceAll]);

 ACanvas.Brush.Color := LStyles.GetStyleColor(ColorStates[(Sender as TMenuItem).Enabled]);
 ACanvas.Font.Color  := LStyles.GetStyleFontColor(FontColorStates[(Sender as TMenuItem).Enabled]);
 ACanvas.Font.Style:=[fsBold];

 if Selected then
 begin
   ACanvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
   ACanvas.Font.Color  := LStyles.GetSystemColor(clHighlightText);
 end;

 ACanvas.FillRect(ARect);
 ACanvas.TextOut(ARect.Left + 40, ARect.Top +4, Text);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.StopBtnClick(Sender: TObject);
begin
  Z21Dlg.Stop;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.VypisChybu(p_text: string);
begin
  DiagDlg.Memo1.Lines.Add(p_text);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Z211Click(Sender: TObject);
begin
  Z21Dlg.Show;
end;

end.
