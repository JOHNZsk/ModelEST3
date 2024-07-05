unit CasDialog;

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
  LogikaStavadlo;

type
  TCasDlg = class(TForm)
    CasTyp: TRadioGroup;
    GroupBox1: TGroupBox;
    HodinyL: TLabel;
    Panel2: TPanel;
    HodinyM: TButton;
    HodinyP: TButton;
    Label2: TLabel;
    HodinyT: TEdit;
    Label3: TLabel;
    Panel4: TPanel;
    MinutyL: TLabel;
    MinutyP: TButton;
    MinutyM: TButton;
    MinutyT: TEdit;
    Label5: TLabel;
    Panel6: TPanel;
    SekundyL: TLabel;
    SekundyP: TButton;
    SekundyM: TButton;
    SekundyT: TEdit;
    Label7: TLabel;
    Panel8: TPanel;
    DniL: TLabel;
    DniP: TButton;
    DniM: TButton;
    DniT: TEdit;
    HodinyTextPanel: TPanel;
    HodinySpodPanel: TPanel;
    CasNastav: TButton;
    CasSTOP: TButton;
    Label9: TLabel;
    CasZrychlenie: TComboBox;
    CasReset: TButton;
    HodinyLabelPanel: TPanel;
    HodinyNadpisPanel: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    procedure DniTEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CasNastavClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure CasTypClick(Sender: TObject);
    procedure CasResetClick(Sender: TObject);
    procedure CasSTOPClick(Sender: TObject);
    procedure DniMClick(Sender: TObject);
    procedure DniPClick(Sender: TObject);
  private
    { Private declarations }
    t_potlac_zmeny: Boolean;
    t_zmeneny_cas: Boolean;
  public
    { Public declarations }

    procedure AktualizujCas(p_cas_typ: TCasTyp; p_cas: TDateTime; p_zrychlenie: Integer; p_stoji: Boolean);
  end;

var
  CasDlg: TCasDlg;

implementation
  uses
    System.DateUtils,
    GUI1;

{$R *.dfm}

procedure TCasDlg.AktualizujCas(p_cas_typ: TCasTyp; p_cas: TDateTime; p_zrychlenie: Integer; p_stoji: Boolean);
begin
  t_potlac_zmeny:=True;
  try
    case p_cas_typ of
      TCA_REALNY: CasTyp.ItemIndex:=0;
      TCA_ZRYCHLENY: CasTyp.ItemIndex:=1;
      TCA_LOCONET: CasTyp.ItemIndex:=2;
    end;

    if p_cas_typ<>TCA_REALNY then
    begin
      DniL.Caption:=IntToStr(DaysBetween(p_cas,EncodeDate(2000,1,1)));
      CasNastav.Enabled:=True;
      CasSTOP.Enabled:=True;
      CasReset.Enabled:=True;
      CasZrychlenie.Enabled:=True;
      DniT.Enabled:=True;
      HodinyT.Enabled:=True;
      MinutyT.Enabled:=True;
      SekundyT.Enabled:=True;

      DniM.Enabled:=True;
      DniP.Enabled:=True;
      HodinyM.Enabled:=True;
      HodinyP.Enabled:=True;
      MinutyM.Enabled:=True;
      MinutyP.Enabled:=True;
      SekundyM.Enabled:=True;
      SekundyP.Enabled:=True;
    end
    else
    begin
      DniL.Caption:=IntToStr(0);
      CasNastav.Enabled:=False;
      CasSTOP.Enabled:=False;
      CasReset.Enabled:=False;
      CasZrychlenie.Enabled:=False;
      DniT.Enabled:=False;
      HodinyT.Enabled:=False;
      MinutyT.Enabled:=False;
      SekundyT.Enabled:=False;

      DniM.Enabled:=False;
      DniP.Enabled:=False;
      HodinyM.Enabled:=False;
      HodinyP.Enabled:=False;
      MinutyM.Enabled:=False;
      MinutyP.Enabled:=False;
      SekundyM.Enabled:=False;
      SekundyP.Enabled:=False;
    end;

    HodinyL.Caption:=IntToStr(HourOf(p_cas));
    MinutyL.Caption:=IntTOStr(MinuteOf(p_cas));
    SekundyL.Caption:=IntToStr(SecondOf(p_cas));

    if not t_zmeneny_cas then
    begin
      CasZrychlenie.Text:=IntToStr(p_zrychlenie);
      DniT.Text:=DniL.Caption;
      HodinyT.Text:=HodinyL.Caption;
      MinutyT.Text:=MinutyL.Caption;
      SekundyT.Text:=SekundyL.Caption;
    end;

    if p_stoji then CasSTOP.Caption:='Spustiť'
    else CasSTOP.Caption:='STOP';
  finally
    t_potlac_zmeny:=False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.CasResetClick(Sender: TObject);
begin
  if LogikaES.CasTyp<>TCA_REALNY then
  begin
    var cas_typ:=TCA_ZRYCHLENY;
    if CasTyp.ItemIndex=2 then cas_typ:=TCA_LOCONET;

    LogikaES.ZastavCas;
    LogikaES.NastavCas(cas_typ,EncodeDate(2000,1,1),1);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.CasSTOPClick(Sender: TObject);
begin
  if LogikaES.CasTyp<>TCA_REALNY then
  begin
    if LogikaES.CasStoji then LogikaES.SpustiCas
    else LogikaES.ZastavCas;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.CasNastavClick(Sender: TObject);
begin
  if CasTyp.ItemIndex=0 then LogikaES.NastavCas(TCA_REALNY,Now,1)
  else
  begin
    var cas_typ:=TCA_ZRYCHLENY;
    if CasTyp.ItemIndex=2 then cas_typ:=TCA_LOCONET;

    LogikaES.NastavCas(cas_typ,IncDay(EncodeDateTime(2000,1,1,StrToIntDef(HodinyT.Text,0),StrToIntDef(MinutyT.Text,0),StrToIntDef(SekundyT.Text,0),0),StrToIntDef(DniT.Text,0)),StrToIntDef(CasZrychlenie.Text,1));
  end;

  t_zmeneny_cas:=False;
  LogikaES.ZapniCasOkno;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.CasTypClick(Sender: TObject);
begin
  if not t_potlac_zmeny then CasNastavClick(CasNastav);
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.DniMClick(Sender: TObject);
begin
  if Sender=DniM then LogikaES.UberCasZlozka(ZCA_DEN)
  else if Sender=HodinyM then LogikaES.UberCasZlozka(ZCA_HODINA)
  else if Sender=MinutyM then LogikaES.UberCasZlozka(ZCA_MINUTA)
  else if Sender=SekundyM then LogikaES.UberCasZlozka(ZCA_SEKUNDA);

  t_zmeneny_cas:=False;
  LogikaES.ZapniCasOkno;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.DniPClick(Sender: TObject);
begin
  if Sender=DniP then LogikaES.PridajCasZlozka(ZCA_DEN)
  else if Sender=HodinyP then LogikaES.PridajCasZlozka(ZCA_HODINA)
  else if Sender=MinutyP then LogikaES.PridajCasZlozka(ZCA_MINUTA)
  else if Sender=SekundyP then LogikaES.PridajCasZlozka(ZCA_SEKUNDA);

  t_zmeneny_cas:=False;
  LogikaES.ZapniCasOkno;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.DniTEnter(Sender: TObject);
begin
  t_zmeneny_cas:=True;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TCasDlg.FormHide(Sender: TObject);
begin
  LogikaES.VypniCasOkno;
end;

procedure TCasDlg.FormShow(Sender: TObject);
begin
  LogikaES.ZapniCasOkno;
  t_zmeneny_cas:=False;
end;

end.
