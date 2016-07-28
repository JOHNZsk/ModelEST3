unit GUI1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Funkcie1: TMenuItem;
    Drtoah1: TMenuItem;
    Diagnostika1: TMenuItem;
    PaintBox1: TPaintBox;
    SPodPanel: TPanel;
    VJednotka: TLabel;
    Panel1: TPanel;
    VLoconet: TLabel;
    Koniec1: TMenuItem;
    procedure Diagnostika1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Koniec1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses ComPort, DiagDialog, LogikaNemsova;

procedure TForm1.Diagnostika1Click(Sender: TObject);
begin
  if not DiagDlg.Visible then DiagDlg.Show;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  VJednotka.Caption:='';
  VLoconet.Caption:='';

  DoubleBuffered:=True;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CPort.Pripoj;
end;

procedure TForm1.Koniec1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button in [mbLeft,mbMiddle]) then DataModule1.VyberJednotku(X,Y,Shift,Button=mbMiddle)
  else if(Button=mbRight) then DataModule1.VyberZrusenie(X,Y,Shift);
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  DataModule1.VykresliPlan(PaintBox1);
end;

end.
