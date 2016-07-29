program MES3;

uses
  Vcl.Forms,
  GUI1 in 'GUI1.pas' {Form1},
  ComPort in 'ComPort.pas' {CPort: TDataModule},
  DiagDialog in 'DiagDialog.pas' {DiagDlg},
  DratotahDialog in 'DratotahDialog.pas' {OKRightDlg},
  LogikaStavadlo in 'LogikaStavadlo.pas' {LogikaES: TDataModule},
  StavadloObjekty in 'StavadloObjekty.pas',
  Cesta in 'Cesta.pas',
  synaser in '..\..\synapse\source\lib\synaser.pas',
  LoadConfig in 'LoadConfig.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TCPort, CPort);
  Application.CreateForm(TDiagDlg, DiagDlg);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.CreateForm(TLogikaES, LogikaES);
  Application.Run;
end.
