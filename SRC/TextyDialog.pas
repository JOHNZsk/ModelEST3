unit TextyDialog;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.ComCtrls;
Const
  USER_EDITLISTVIEW = WM_USER + 666;
type
  TTextyDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Panel1: TPanel;
    ListView1: TListView;
    procedure ListView1Click(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    ListViewEditor: TEdit;
    LItem: TListitem;

    { Private declarations }
    procedure UserEditListView( Var Message: TMessage); message USER_EDITLISTVIEW;
    procedure ListViewEditorExit(Sender: TObject);
  public
    { Public declarations }
  end;

var
  TextyDlg: TTextyDlg;

implementation

{$R *.dfm}

uses
  Winapi.CommCtrl,
  StavadloObjekty,
  LogikaStavadlo;
const
  EDIT_COLUMN = 3; //Index of the column to Edit

////////////////////////////////////////////////////////////////////////////////

procedure TTextyDlg.CancelBtnClick(Sender: TObject);
begin
  Hide;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TTextyDlg.FormShow(Sender: TObject);
Var
  objekt: TStavadloObjekt;
  Item : TListItem;
begin
  if ListView1.Items.Count=0 then
  begin
    for objekt in LogikaES.DajObjekty do
    begin
      if objekt is TText then
      begin
        Item:=ListView1.Items.Add;
        Item.Caption:=KodJednotkyNaSkratku(objekt.KodJednotky);
        Item.SubItems.Add(IntToStr(objekt.CisloJednotky));
        Item.SubItems.Add((objekt as TText).DajOrigText);
        Item.SubItems.Add((objekt as TText).DajPredefText);
      end;
    end;

    //create the TEdit and assign the OnExit event
    ListViewEditor:=TEdit.Create(Self);
    ListViewEditor.Parent:=ListView1;
    ListViewEditor.OnExit:=ListViewEditorExit;
    ListViewEditor.Visible:=False;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TTextyDlg.ListView1Click(Sender: TObject);
var
  LPoint: TPoint;
  LVHitTestInfo: TLVHitTestInfo;
begin
  LPoint:= listview1.ScreenToClient(Mouse.CursorPos);
  ZeroMemory( @LVHitTestInfo, SizeOf(LVHitTestInfo));
  LVHitTestInfo.pt := LPoint;
  //Check if the click was made in the column to edit
  If (ListView1.perform( LVM_SUBITEMHITTEST, 0, LPARAM(@LVHitTestInfo))<>-1) and ( LVHitTestInfo.iSubItem = EDIT_COLUMN ) Then
    PostMessage( self.Handle, USER_EDITLISTVIEW, LVHitTestInfo.iItem, 0 )
  else
    ListViewEditor.Visible:=False; //hide the TEdit
end;

////////////////////////////////////////////////////////////////////////////////

procedure TTextyDlg.ListViewEditorExit(Sender: TObject);
begin
  If Assigned(LItem) Then
  Begin
    //assign the vslue of the TEdit to the Subitem
    LItem.SubItems[ EDIT_COLUMN-1 ] := ListViewEditor.Text;
    LItem := nil;
  End;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TTextyDlg.OKBtnClick(Sender: TObject);
var
  i: Integer;
  objekt: TStavadloObjekt;
begin
  ListViewEditorExit(ListViewEditor);

  for i := 0 to ListView1.Items.Count-1 do
  begin
    objekt:=LogikaES.DajObjekt(KJ_TEXT,StrToIntDef(ListView1.Items[i].SubItems[0],-1));
    if (objekt<>nil) and (objekt is TText) then (objekt as TText).NastavPredefText(ListView1.Items[i].SubItems[2]);
  end;

  LogikaES.UlozStitkyVyluky;
  Hide;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TTextyDlg.UserEditListView(var Message: TMessage);
var
  LRect: TRect;
begin
  LRect.Top := EDIT_COLUMN;
  LRect.Left:= LVIR_BOUNDS;
  listview1.Perform( LVM_GETSUBITEMRECT, Message.wparam,  LPARAM(@LRect) );
  MapWindowPoints( listview1.Handle, ListViewEditor.Parent.Handle, LRect, 2 );
  //get the current Item to edit
  LItem := listview1.Items[ Message.wparam ];
  //set the text of the Edit
  ListViewEditor.Text := LItem.Subitems[ EDIT_COLUMN-1];
  //set the bounds of the TEdit
  ListViewEditor.BoundsRect := LRect;
  //Show the TEdit
  ListViewEditor.Visible:=True;
end;
end.
