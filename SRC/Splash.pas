unit Splash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Generics.Collections;

  type TOblastKonfiguracia=record
    Nazov: string;
    Plan: string;
    Stitky: string;
    DotazNavestidiel: Boolean;
    Predvolene: Boolean;
  end;

  type TPripojenieKonfiguracia=record
    Nazov: string;
    Typ: string;
    COMPort: string;
    Rychlost: integer;
    HWFlow: Boolean;
    Predvolene: Boolean;
    
  end;
  
type
  TForm2 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    CancelBtn: TButton;
    OKBtn: TButton;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Z21Povolit: TCheckBox;
    Panel4: TPanel;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    t_fullscreen: Boolean;
    t_maximalizovat: Boolean;
    t_reset_navestidiel: Boolean;
    t_reset_vyhybiek: Boolean;
    t_konfiguracie: TList<TOblastKonfiguracia>;
    t_pripojenia: TList<TPripojenieKonfiguracia>;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses GUI1, LogikaStavadlo, IniFiles, ComPort, UITypes, Z21Dialog;

procedure TForm2.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm2.FormCreate(Sender: TObject);
var
  subor: TIniFile;
  pocet_konf,pocet_prip: Integer;
  konf: TOblastKonfiguracia;
  prip: TPripojenieKonfiguracia;
  i: Integer;
begin
  t_konfiguracie:=TList<TOblastKonfiguracia>.Create;
  t_pripojenia:=TList<TPripojenieKonfiguracia>.Create;

  try
    subor:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'conf.ini');
    try
      t_fullscreen:=subor.ReadBool('Main','Fullscreen',False);
      t_maximalizovat:=subor.ReadBool('Main','Maximalizovat',False);
      t_reset_navestidiel:=subor.ReadBool('Main','ResetNavestidiel',False);
      t_reset_vyhybiek:=subor.ReadBool('Main','ResetVyhybiek',False);
      pocet_konf:=subor.ReadInteger('Main','Konfiguracie',0);
      pocet_prip:=subor.ReadInteger('Main','Pripojenia',0);
      Z21Povolit.Checked:=subor.ReadBool('Main','Z21Implicitne',False);

      ListBox1.Items.BeginUpdate;
      try
        for i := 1 to pocet_konf do
        begin
          if subor.ReadBool('Konfiguracia'+IntToStr(i),'Povolit',False) then
          begin
            konf.Nazov:=subor.ReadString('Konfiguracia'+IntToStr(i),'Nazov','???');
            konf.Plan:=subor.ReadString('Konfiguracia'+IntToStr(i),'Plan','');
            konf.Stitky:=subor.ReadString('Konfiguracia'+IntToStr(i),'Stitky','');
            konf.Predvolene:=subor.ReadBool('Konfiguracia'+IntToStr(i),'Predvolene',False);

            t_konfiguracie.Add(konf);
            ListBox1.AddItem(konf.Nazov,nil);
            if konf.Predvolene then ListBox1.ItemIndex:=ListBox1.Count-1;
          end;
        end;
      finally
        ListBox1.Items.EndUpdate;
      end;

      ListBox2.Items.BeginUpdate;
      try
        for i := 1 to pocet_prip do
        begin
          if subor.ReadBool('Pripojenie'+IntToStr(i),'Povolit',False) then
          begin
            prip.Nazov:=subor.ReadString('Pripojenie'+IntToStr(i),'Nazov','???');
            prip.Typ:=subor.ReadString('Pripojenie'+IntToStr(i),'Typ','');
            prip.COMPort:=subor.ReadString('Pripojenie'+IntToStr(i),'COMPort','');
            prip.Rychlost:=subor.ReadInteger('Pripojenie'+IntToStr(i),'Rychlost',-1);
            prip.HWFlow:=subor.ReadBool('Pripojenie'+IntToStr(i),'HWFlow',False);
            prip.Predvolene:=subor.ReadBool('Pripojenie'+IntToStr(i),'Predvolene',False);
            
            t_pripojenia.Add(prip);
            ListBox2.AddItem(prip.Nazov,nil);
            if prip.Predvolene then ListBox2.ItemIndex:=ListBox2.Count-1;        
          end;
        end;      
      finally
        ListBox2.Items.EndUpdate;
      end;
    finally
      subor.Free;
    end;
  except
    MessageDlg('Nepodarilo sa naèíta systémovú konfiguráciu',mtError,[mbOK],0);
    Close;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm2.FormDestroy(Sender: TObject);
begin
  t_konfiguracie.Free;
  t_pripojenia.Free;

  inherited;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm2.OKBtnClick(Sender: TObject);
var
  konf: TOblastKonfiguracia;
  prip: TPripojenieKonfiguracia;
begin
  if (ListBox1.ItemIndex>=0) and (ListBox2.ItemIndex>=0) then
  begin
    konf:=t_konfiguracie[ListBox1.ItemIndex];
    prip:=t_pripojenia[ListBox2.ItemIndex];
    
    if (konf.Plan<>'') and (konf.Stitky<>'') then
    begin
      if (prip.Typ='Loconet') or (prip.Typ='LoconetSIM') then CPort.Nastav(prip.COMPort,prip.Rychlost,prip.HWFlow,prip.Typ='LoconetSIM');
      Form1.Show;
      Form1.Spusti(t_fullscreen,t_maximalizovat);
      LogikaES.Spusti(konf.Plan,konf.Stitky);
      if (prip.Typ='Loconet') or (prip.Typ='LoconetSIM') then CPort.Pripoj;
      LogikaES.Reset(t_reset_navestidiel,t_reset_vyhybiek);

      if Z21Povolit.Checked then Z21Dlg.Pripoj
      else
      begin
        Form1.Z21Panel.Visible:=False;
        Form1.Z21M.Visible:=False;
        Form1.Z21M.ShortCut:=0;
      end;

      Hide;
    end;
  end;
end;

end.
