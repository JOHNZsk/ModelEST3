unit DratotahDialog;

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
  Vcl.ComCtrls;

type
  TDratotahDlg = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Návestidlá: TTabSheet;
    ListViewVyhybky: TListView;
    ListViewNavestidla: TListView;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }

    procedure ObnovVyhybky;
    procedure ObnovNavestidla;
  public
    { Public declarations }

    procedure Obnov;
  end;

var
  DratotahDlg: TDratotahDlg;

implementation
  uses
    Generics.Collections,
    LogikaStavadlo,
    StavadloObjekty;

{$R *.dfm}

procedure TDratotahDlg.ObnovVyhybky;
var
  prvky: TList<TVyhybka>;
  prvok: TVyhybka;
  i,j: Integer;
  polozka: TListItem;
begin
  prvky:=TList<TVyhybka>.Create;
  try
    i:=0;

    LogikaES.DajVyhybky(prvky);

    ListViewVyhybky.Items.BeginUpdate;
    try

      for prvok in prvky do
      begin
        if i>=ListViewVyhybky.Items.Count then
        begin
          polozka:=ListViewVyhybky.Items.Add;
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
        end
        else polozka:=ListViewVyhybky.Items[i];

        polozka.Caption:=IntToStr(prvok.CisloJednotky);
        polozka.SubItems[0]:=prvok.Dopravna.Nazov;
        polozka.SubItems[1]:=prvok.Nazov[False,False];
        polozka.SubItems[2]:=IntToStr(prvok.Adresa);
        polozka.SubItems[3]:=prvok.DajStav;

        Inc(i);
      end;

      if i<ListViewVyhybky.Items.Count-1 then
      begin
        for j := ListViewVyhybky.Items.Count-1 downto i do ListViewVyhybky.Items.Delete(j);
      end;

    finally
      ListViewVyhybky.Items.EndUpdate;
      ListViewVyhybky.Columns[3].Width:=-2;
    end;
  finally
    prvky.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TDratotahDlg.ObnovNavestidla;
var
  prvky: TList<TNavestidlo>;
  prvok: TNavestidlo;
  i,j: Integer;
  polozka: TListItem;
begin
  prvky:=TList<TNavestidlo>.Create;
  try
    i:=0;

    LogikaES.DajNavestidla(prvky);

    ListViewNavestidla.Items.BeginUpdate;
    try

      for prvok in prvky do
      begin
        if i>=ListViewNavestidla.Items.Count then
        begin
          polozka:=ListViewNavestidla.Items.Add;
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
          polozka.SubItems.Add('');
        end
        else polozka:=ListViewNavestidla.Items[i];

        polozka.Caption:=IntToStr(prvok.CisloJednotky);
        polozka.SubItems[0]:=prvok.Dopravna.Nazov;
        polozka.SubItems[1]:=prvok.Nazov[False,False];
        polozka.SubItems[2]:=NavestNaText(prvok.Navest[False]);
        polozka.SubItems[3]:=NavestNaText(prvok.Navest[True]);
        polozka.SubItems[4]:=prvok.DajStav;

        case prvok.KodJednotky of
          KJ_NAVESTIDLOZRIADOVACIE: polozka.GroupID:=2;
          KJ_NAVESTIDLOVCHODOVE: polozka.GroupID:=0;
          KJ_NAVESTIDLOODCHODOVE: polozka.GroupID:=1;
          else polozka.GroupID:=3;
        end;

        Inc(i);
      end;

      if i<ListViewNavestidla.Items.Count-1 then
      begin
        for j := ListViewNavestidla.Items.Count-1 downto i do ListViewNavestidla.Items.Delete(j);
      end;
    finally
      ListViewNavestidla.Items.EndUpdate;
      ListViewNavestidla.Columns[3].Width:=-2;
    end;
  finally
    prvky.Free;
  end;
end;

procedure TDratotahDlg.FormHide(Sender: TObject);
begin
  LogikaES.ZakazDratotah;
end;

procedure TDratotahDlg.FormShow(Sender: TObject);
begin
  Obnov;
  LogikaES.PovolDratotah;
end;

procedure TDratotahDlg.Obnov;
begin
  if Visible then
  begin
    ObnovNavestidla;
    ObnovVyhybky;
  end;
end;

end.
