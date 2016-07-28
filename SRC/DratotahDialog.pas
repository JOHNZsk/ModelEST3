unit DratotahDialog;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TOKRightDlg = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OKRightDlg: TOKRightDlg;

implementation

{$R *.dfm}

end.
