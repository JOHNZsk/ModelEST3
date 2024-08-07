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
  KonfigDialog in 'KonfigDialog.pas' {KonfigDlg},
  Splash in 'Splash.pas' {Form2},
  CPortThread in 'CPortThread.pas',
  Z21Dialog in 'Z21Dialog.pas' {Z21Dlg},
  Z21GrafDialog in 'Z21GrafDialog.pas' {OKRightDlg},
  CasDialog in 'CasDialog.pas' {CasDlg},
  ProgDialog in 'ProgDialog.pas' {ProgDlg};

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
  Application.CreateForm(TKonfigDlg, KonfigDlg);
  Application.CreateForm(TZ21Dlg, Z21Dlg);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.CreateForm(TCasDlg, CasDlg);
  Application.CreateForm(TProgDlg, ProgDlg);
  Application.Run;
end.
