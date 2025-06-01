unit KonfigDialog;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Xml.xmldom,
  Xml.XMLIntf,
  Xml.Win.msxmldom,
  Xml.XMLDoc, ipwcore, ipwtypes, ipwxml;

type
  TKonfigDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    OtocPohladR: TRadioButton;
    FileOpenDialog1: TFileOpenDialog;
    Edit1: TEdit;
    Button1: TButton;
    PrehodHitBox: TRadioButton;
    ipwXML1: TipwXML;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

    procedure OtocitPohlad;
    procedure PrehoditHitBox;
  public
    { Public declarations }
  end;

var
  KonfigDlg: TKonfigDlg;

implementation
uses
  System.RegularExpressions;

{$R *.dfm}

procedure TKonfigDlg.Button1Click(Sender: TObject);
begin

end;

////////////////////////////////////////////////////////////////////////////////


procedure TKonfigDlg.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TKonfigDlg.OKBtnClick(Sender: TObject);
begin
  OtocitPohlad;
  PrehoditHitBox;
end;

////////////////////////////////////////////////////////////////////////////////

function OtocAtribut(p_text: string; p_atribut: string; p_odpocet: Integer): string;
var
  i: Integer;
begin
  Result:=p_text;

  for i := 0 to p_odpocet do
  begin
    Result:=StringReplace(Result,p_atribut+'="'+IntToStr(i)+'"',p_atribut+'=A"'+IntToStr(i)+'"',[rfReplaceAll,rfIgnoreCase]);
  end;

  for i := 0 to p_odpocet do
  begin
    Result:=StringReplace(Result,p_atribut+'=A"'+IntToStr(i)+'"',p_atribut+'="'+IntToStr(p_odpocet-i)+'"',[rfReplaceAll,rfIgnoreCase]);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TKonfigDlg.OtocitPohlad;
var
  konf: TStringList;
  text: string;
begin
  konf:=TStringList.Create;
  try
    konf.LoadFromFile(Edit1.Text);
    text:=konf.Text;

    text:=OtocAtribut(text,'xzac',110);
    text:=OtocAtribut(text,'yzac',80);
    text:=OtocAtribut(text,'xkon',110);
    text:=OtocAtribut(text,'ykon',80);
    text:=OtocAtribut(text,'xhrot',110);
    text:=OtocAtribut(text,'yhrot',80);
    text:=OtocAtribut(text,'xrovno',110);
    text:=OtocAtribut(text,'yrovno',80);
    text:=OtocAtribut(text,'xodboc',110);
    text:=OtocAtribut(text,'yodboc',80);

    konf.Text:=text;
    konf.SaveToFile(Edit1.Text+'a');
  finally
    konf.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TKonfigDlg.PrehoditHitBox;
var
  konf: TStringList;
  text: string;
begin
  konf:=TStringList.Create;
  try
    konf.LoadFromFile(Edit1.Text+'a');
    text:=konf.Text;

    text:=TRegEx.Replace(text,'<HitBox xzac="([0-9]*)" xkon="([0-9]*)" yzac="([0-9]*)" ykon="([0-9]*)"','<HitBox xzac="\2" xkon="\1" yzac="\4" ykon="\3"');


    konf.Text:=text;
    konf.SaveToFile(Edit1.Text+'b');
  finally
    konf.Free;
  end;
end;


//xzac, xkon, yzac, ykon, xhrot, yhrot, xrovno, yrovno, xodboc, yodboc,

end.
