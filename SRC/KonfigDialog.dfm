object KonfigDlg: TKonfigDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = #218'prava konfigura'#269'n'#233'ho s'#250'boru'
  ClientHeight = 179
  ClientWidth = 384
  Color = clBtnFace
  ParentFont = True
  Position = poScreenCenter
  TextHeight = 15
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
    Width = 265
    Height = 23
    TabOrder = 3
    Text = 
      'c:\Users\kandr-jan\Documents\Embarcadero\Studio\Projects\MES3-co' +
      'nfig\planLRop.xml'
  end
  object Button1: TButton
    Left = 301
    Top = 79
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 4
    OnClick = Button1Click
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
  object ipwXML1: TipwXML
    Left = 232
    Top = 8
  end
end
