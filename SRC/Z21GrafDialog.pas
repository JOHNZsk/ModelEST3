unit Z21GrafDialog;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, VclTee.TeeGDIPlus,
  VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart;

type
  TOKRightDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
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
