unit DiagDialog;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, ComPort,
  Vcl.AppEvnts;

type
  TDiagDlg = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Edit1: TEdit;
    Button3: TButton;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Panel3: TPanel;
    Label4: TLabel;
    Panel4: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox6: TGroupBox;
    VypisCele: TCheckBox;
    Button4: TButton;
    ApplicationEvents1: TApplicationEvents;
    GroupBox7: TGroupBox;
    Label6: TLabel;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Edit2: TEdit;
    RadioButton3: TRadioButton;
    SimPripoj: TCheckBox;
    Button2: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DiagDlg: TDiagDlg;

implementation
  uses GUI1;

{$R *.dfm}

procedure TDiagDlg.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
var
  text: string;
begin
  Label5.Caption:=CPort.PortCislo;
  Label6.Caption:=IntToStr(Cport.DajPocetPovelov)+' povelov';
  text:='Loconet '+CPort.PortCislo+' ';
  if Button1.Enabled then text:=text+'odpojený' else text:=text+'pripojený';
  text:=text+', povelov vo fronte: '+IntToStr(Cport.DajPocetPovelov);

  if CPort.JeSimulacia then
  begin
    SimPripoj.Checked:=True;
    text:='POZOR SIMULÁTOR! '+text;
  end
  else SimPripoj.Checked:=False;

  Form1.VLoconet.Caption:=text;
end;

procedure TDiagDlg.Button1Click(Sender: TObject);
begin
  CPort.Pripoj;
end;

procedure TDiagDlg.Button2Click(Sender: TObject);
begin
  CPort.VydajPovel82;
end;

procedure TDiagDlg.Button3Click(Sender: TObject);
begin
  if RadioButton1.Checked or RadioButton2.Checked then CPort.VydajPovelB0(StrToIntDef(Edit1.Text,0),RadioButton2.Checked)
  else CPort.VydajPovelBC(StrToIntDef(Edit1.Text,0));
end;

procedure TDiagDlg.Button4Click(Sender: TObject);
begin
  CPort.NastavPort(StrToIntDef(Edit2.Text,1));
end;

procedure TDiagDlg.Button5Click(Sender: TObject);
begin
  CPort.VydajPovel83;
end;

procedure TDiagDlg.FormCreate(Sender: TObject);
begin
  Memo1.Text:='';
  Edit1.Text:='';
  Edit2.Text:='';
end;

end.
