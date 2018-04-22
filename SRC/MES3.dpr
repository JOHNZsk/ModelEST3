program MES3;

uses
  Vcl.Forms,
  GUI1 in 'GUI1.pas' {Form1},
  ComPort in 'ComPort.pas' {CPort: TDataModule},
  DiagDialog in 'DiagDialog.pas' {DiagDlg},
  DratotahDialog in 'DratotahDialog.pas' {DratotahDlg},
  LogikaStavadlo in 'LogikaStavadlo.pas' {LogikaES: TDataModule},
  StavadloObjekty in 'StavadloObjekty.pas',
  Cesta in 'Cesta.pas',
  synaser in '..\..\synapse\source\lib\synaser.pas',
  LoadConfig in 'LoadConfig.pas',
  TextyDialog in 'TextyDialog.pas' {TextyDlg},
  KonfigDialog in 'KonfigDialog.pas' {OKRightDlg},
  Splash in 'Splash.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TCPort, CPort);
  Application.CreateForm(TLogikaES, LogikaES);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDiagDlg, DiagDlg);
  Application.CreateForm(TDratotahDlg, DratotahDlg);
  Application.CreateForm(TTextyDlg, TextyDlg);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.Run;
end.
