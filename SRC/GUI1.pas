unit GUI1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, GR32, StavadloObjekty,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,
  Vcl.ExtCtrls, GR32_Image;

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
    PaintBoxPoruchy: TPaintBox32;
    PaintBoxRizika: TPaintBox32;
    PaintBox1: TPaintBox32;
    procedure Diagnostika1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Koniec1Click(Sender: TObject);
    procedure Drtoah1Click(Sender: TObject);
    procedure Resetnvstidel1Click(Sender: TObject);
    procedure Resetvhybej1Click(Sender: TObject);
    procedure PaintBoxPoruchyPaintBuffer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure VypisChybu(p_text: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses ComPort, DiagDialog, LogikaStavadlo, DratotahDialog, DateUtils,
Generics.Collections;

procedure TForm1.Diagnostika1Click(Sender: TObject);
begin
  if not DiagDlg.Visible then DiagDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Drtoah1Click(Sender: TObject);
begin
  if not DratotahDlg.Visible then DratotahDlg.Show;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormCreate(Sender: TObject);
begin
  VJednotka.Caption:='';
  VLoconet.Caption:='';

  DoubleBuffered:=True;
end;

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

procedure TForm1.FormShow(Sender: TObject);
begin
  CPort.Pripoj;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Koniec1Click(Sender: TObject);
begin
  Close;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button in [mbLeft,mbMiddle]) then LogikaES.VyberJednotku(X,Y,Shift,Button=mbMiddle)
  else if(Button=mbRight) then LogikaES.VyberZrusenie(X,Y,Shift);
end;

////////////////////////////////////////////////////////////////////////////////

procedure VykresliHitBox(p_ciel: TBitmap32; p_hitbox: THitBox; p_posun: Boolean);
var
  x_zac,y_zac,x_kon,y_kon: Integer;
  farba: TColor32;
begin
  x_zac:=(p_hitbox.Poloha.Left*p_ciel.Width) div LogikaES.SirkaPlanu;
  y_zac:=(p_hitbox.Poloha.Top*p_ciel.Height) div LogikaES.SirkaPlanu;
  x_kon:=(p_hitbox.Poloha.Right*p_ciel.Width) div LogikaES.VyskaPlanu;
  y_kon:=(p_hitbox.Poloha.Bottom*p_ciel.Height) div LogikaES.VyskaPlanu;

  if p_posun then farba:=clWhite32
  else farba:=clLime32;

  p_ciel.FrameRectS(x_zac,y_zac,x_kon,y_kon,farba);
  p_ciel.FrameRectS(x_zac+1,y_zac+1,x_kon-1,y_kon-1,farba);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  objekt: TStavadloObjekt;
  volba,volba_pred: TPair<TStavadloObjekt,Boolean>;
  bitmap: TBitmap32;
begin
  bitmap:=TBitmap32.Create;
  try
    bitmap.SetSizeFrom(PaintBox1);

    bitmap.FillRect(0,0,bitmap.Width,bitmap.Height,clBlack32);
    for objekt in LogikaES.DajObjekty do objekt.Vykresli(bitmap,0,bitmap.Width,0,bitmap.Height);

    volba_pred.Key:=nil;
    volba_pred.Value:=False;

    for volba in LogikaES.DajVolby do
    begin
      if volba.Key<>volba_pred.Key then
      begin
        VykresliHitBox(bitmap,LogikaES.DajHitBox(volba.Key),volba.Value);
        volba_pred.Key:=volba.Key;
        volba_pred.Value:=volba.Value;
      end;
    end;

    PaintBox1.Buffer.Draw(0,0,bitmap);
  finally
    bitmap.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure VykresliPoruchu(p_ciel: TBitmap32; p_nazvy_dopravni: Boolean; p_od,p_do: Integer; p_porucha: TPorucha);
var
  dopravna: string;
begin
  p_ciel.Font.Color:=clBlack;
  p_ciel.Font.Height:=-17;
  p_ciel.Font.Name:='Tahoma';

  if p_porucha.Dopravna<>nil then dopravna:=p_porucha.Dopravna.Skratka;

  p_ciel.Textout(22,p_od,Rect(22,p_od-2,p_ciel.Width-4,p_do),FormatDateTime('hh:nn:ss',p_porucha.Cas));
  if p_nazvy_dopravni then
  begin
    p_ciel.Textout(92,p_od,Rect(22,p_od-2,p_ciel.Width-4,p_do),'['+dopravna+']');
    p_ciel.Textout(142,p_od,Rect(22,p_od-2,p_ciel.Width-4,p_do),p_porucha.Text);
  end
  else p_ciel.Textout(92,p_od,Rect(22,p_od-2,p_ciel.Width-4,p_do),p_porucha.Text);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.PaintBoxPoruchyPaintBuffer(Sender: TObject);
var
  tmp: TBitmap32;
  cas: TDateTime;

begin
  tmp:=TBitmap32.Create;
  try
    cas:=Now;

    tmp.Width:=PaintBoxPoruchy.Width;
    tmp.Height:=PaintBoxPoruchy.Height;

    case LogikaES.PocetPoruch of
      0: tmp.FillRect(0,0,tmp.Width-1,tmp.Height-1,clBlack32);
      1:
      begin
        tmp.FillRect(0,0,tmp.Width-1,(tmp.Height div 3)-1,clWhite32);
        tmp.FillRect(0,tmp.Height div 3,tmp.Width-1,tmp.Height-1,clBlack32);

        if(SecondOf(cas) mod 2)=0 then tmp.FillRect(3,3,18,(tmp.Height div 3)-4,clFuchsia32);
      end;
      2:
      begin
        tmp.FillRect(0,0,tmp.Width-1,((tmp.Height*2) div 3)-1,clWhite32);
        tmp.FillRect(0,(tmp.Height*2) div 3,tmp.Width-1,tmp.Height-1,clBlack32);

        if(SecondOf(cas) mod 2)=0 then tmp.FillRect(3,3,18,((tmp.Height*2) div 3)-4,clFuchsia32);
      end;
      else
      begin
        tmp.FillRect(0,0,tmp.Width-1,tmp.Height-1,clWhite32);

        if(SecondOf(cas) mod 2)=0 then tmp.FillRect(3,3,18,tmp.Height-4,clFuchsia32);
      end;
    end;


    if(LogikaES.PocetPoruch>0) then VykresliPoruchu(tmp,LogikaES.NazvyDopravni,5,(tmp.Height div 3)-4,LogikaES.DajPoruchu(0));
    if(LogikaES.PocetPoruch>1) then VykresliPoruchu(tmp,LogikaES.NazvyDopravni,(tmp.Height div 3)+5,((tmp.Height*2) div 3)-4,LogikaES.DajPoruchu(1));
    if(LogikaES.PocetPoruch>2) then VykresliPoruchu(tmp,LogikaES.NazvyDopravni,((tmp.Height*2) div 3)+5,tmp.Height-4,LogikaES.DajPoruchu(2));

    PaintBoxPoruchy.Buffer.Draw(0,0,tmp);
  finally
    tmp.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Resetnvstidel1Click(Sender: TObject);
begin
  LogikaES.ResetujNavestidla(False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Resetvhybej1Click(Sender: TObject);
begin
  LogikaES.ResetujVyhybky(False);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.VypisChybu(p_text: string);
begin
  DiagDlg.Memo1.Lines.Add(p_text);
end;

end.
