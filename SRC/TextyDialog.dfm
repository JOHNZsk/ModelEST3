object TextyDlg: TTextyDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Predefinovanie textov'
  ClientHeight = 330
  ClientWidth = 545
  Color = clBtnFace
  ParentFont = True
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 297
    Width = 529
    Height = 25
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    ExplicitTop = 296
    ExplicitWidth = 525
    object OKBtn: TButton
      AlignWithMargins = True
      Left = 375
      Top = 0
      Width = 75
      Height = 25
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Caption = 'Ulo'#382'i'#357
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = OKBtnClick
      ExplicitLeft = 371
    end
    object CancelBtn: TButton
      AlignWithMargins = True
      Left = 454
      Top = 0
      Width = 75
      Height = 25
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Cancel = True
      Caption = 'Zru'#353'i'#357
      ModalResult = 2
      TabOrder = 1
      OnClick = CancelBtnClick
      ExplicitLeft = 450
    end
  end
  object ListView1: TListView
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 529
    Height = 281
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Columns = <
      item
        Caption = 'KJ'
      end
      item
        Caption = #268'J'
      end
      item
        Caption = 'P'#244'vodn'#253' text'
        Width = 200
      end
      item
        Caption = 'Nov'#253' text'
        Width = 200
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = ListView1Click
    ExplicitWidth = 525
    ExplicitHeight = 280
  end
end
