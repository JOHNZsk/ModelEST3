object KonfigDlg: TKonfigDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = #218'prava konfigura'#269'n'#233'ho s'#250'boru'
  ClientHeight = 179
  ClientWidth = 384
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 300
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 300
    Top = 38
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Zru'#353'i'#357
    ModalResult = 2
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object OtocPohladR: TRadioButton
    Left = 8
    Top = 8
    Width = 113
    Height = 17
    Caption = 'Oto'#269'enie poh'#318'adu'
    TabOrder = 2
  end
  object Edit1: TEdit
    Left = 16
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 
      'c:\Users\kandrik\Documents\Embarcadero\Studio\Projects\MES3git\S' +
      'RC\planspr.xml'
  end
  object Button1: TButton
    Left = 143
    Top = 78
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 4
  end
  object PrehodHitBox: TRadioButton
    Left = 8
    Top = 31
    Width = 113
    Height = 17
    Caption = 'Prehodenie hitboxov'
    TabOrder = 5
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 232
    Top = 96
  end
  object XML: TXMLDocument
    Left = 312
    Top = 96
    DOMVendorDesc = 'MSXML'
  end
end
