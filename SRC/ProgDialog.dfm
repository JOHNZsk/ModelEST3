object ProgDlg: TProgDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Programovanie vozidiel a FREDov'
  ClientHeight = 380
  ClientWidth = 496
  Color = clBtnFace
  ParentFont = True
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 480
    Height = 53
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alTop
    Caption = 'Odoslanie adresy do FREDa'
    TabOrder = 0
    ExplicitWidth = 476
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 470
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      ExplicitWidth = 466
      object FREDAdresa: TNumberBox
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 235
        Height = 26
        Margins.Left = 0
        Margins.Top = 0
        Margins.Bottom = 0
        Align = alClient
        Alignment = taCenter
        MaxValue = 10239.000000000000000000
        TabOrder = 0
        SpinButtonOptions.Placement = nbspInline
        ExplicitWidth = 310
        ExplicitHeight = 23
      end
      object FREDBtn: TButton
        Left = 238
        Top = 0
        Width = 232
        Height = 26
        Align = alRight
        Caption = 'Odosla'#357' adresu do FREDa'
        TabOrder = 1
        OnClick = FREDBtnClick
      end
    end
  end
  object GroupBox2: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 69
    Width = 480
    Height = 116
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alTop
    Caption = 'Programovanie adresy loko (len prog. ko'#318'aj)'
    TabOrder = 1
    object AddressReadBtn: TButton
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 470
      Height = 25
      Align = alTop
      Caption = 'Na'#269#237'ta'#357' adresu'
      TabOrder = 0
      OnClick = AddressReadBtnClick
      ExplicitLeft = 200
      ExplicitTop = 32
      ExplicitWidth = 75
    end
    object Panel3: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 51
      Width = 470
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 1
      object AdresaKratka: TRadioButton
        Left = 0
        Top = 0
        Width = 129
        Height = 25
        Align = alLeft
        Caption = 'Kr'#225'tka (CV1)'
        TabOrder = 0
        OnClick = AdresaKratkaClick
      end
      object AdresaDlha: TRadioButton
        Left = 129
        Top = 0
        Width = 144
        Height = 25
        Align = alLeft
        Caption = 'Dlh'#225' (CV17+18) adresa '
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = AdresaDlhaClick
      end
      object AdresaHodnota: TNumberBox
        Left = 273
        Top = 0
        Width = 197
        Height = 25
        Align = alClient
        Alignment = taCenter
        MinValue = 1.000000000000000000
        MaxValue = 10239.000000000000000000
        TabOrder = 2
        Value = 1.000000000000000000
        SpinButtonOptions.Placement = nbspInline
        ExplicitLeft = 279
      end
    end
    object AddressWriteBtn: TButton
      AlignWithMargins = True
      Left = 5
      Top = 82
      Width = 470
      Height = 25
      Align = alTop
      Caption = 'Zap'#237'sa'#357' adresu'
      TabOrder = 2
      OnClick = AddressWriteBtnClick
      ExplicitLeft = 6
      ExplicitTop = 132
    end
  end
  object GroupBox3: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 193
    Width = 480
    Height = 146
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Caption = 'Programovanie CV'
    TabOrder = 2
    ExplicitTop = 182
    ExplicitWidth = 476
    ExplicitHeight = 190
    object Panel4: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 470
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel4'
      ShowCaption = False
      TabOrder = 0
      object RezimDirect: TRadioButton
        Left = 0
        Top = 0
        Width = 226
        Height = 25
        Align = alLeft
        Caption = 'Priamy re'#382'im (prog. ko'#318'aj)'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object RezimPOM: TRadioButton
        Left = 226
        Top = 0
        Width = 103
        Height = 25
        Align = alLeft
        Caption = 'POM (layout)'
        Enabled = False
        TabOrder = 1
      end
    end
    object Panel5: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 82
      Width = 470
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel5'
      ShowCaption = False
      TabOrder = 2
      ExplicitLeft = 2
      ExplicitTop = 48
      ExplicitWidth = 476
      object Label1: TLabel
        AlignWithMargins = True
        Left = 266
        Top = 4
        Width = 54
        Height = 18
        Margins.Left = 8
        Margins.Top = 4
        Align = alLeft
        AutoSize = False
        Caption = 'Bity'
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 4
        Width = 100
        Height = 18
        Margins.Top = 4
        Align = alLeft
        AutoSize = False
        Caption = 'Hodnota CV'
      end
      object CVHodnota: TNumberBox
        Left = 106
        Top = 0
        Width = 152
        Height = 25
        Align = alLeft
        Alignment = taCenter
        MaxValue = 255.000000000000000000
        TabOrder = 0
        SpinButtonOptions.Placement = nbspInline
        OnChangeValue = CVHodnotaChangeValue
        ExplicitLeft = 109
      end
      object Bit7: TCheckBox
        Left = 323
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 1
        OnClick = Bit0Click
        ExplicitLeft = 328
        ExplicitHeight = 17
      end
      object Bit6: TCheckBox
        Left = 340
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 2
        OnClick = Bit0Click
        ExplicitLeft = 336
        ExplicitTop = 8
        ExplicitHeight = 17
      end
      object Bit5: TCheckBox
        Left = 357
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 3
        OnClick = Bit0Click
        ExplicitLeft = 344
        ExplicitTop = 8
        ExplicitHeight = 17
      end
      object Bit4: TCheckBox
        Left = 374
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 4
        OnClick = Bit0Click
        ExplicitLeft = 352
        ExplicitTop = 8
        ExplicitHeight = 17
      end
      object Bit3: TCheckBox
        Left = 391
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 5
        OnClick = Bit0Click
        ExplicitLeft = 360
        ExplicitTop = 8
        ExplicitHeight = 17
      end
      object Bit2: TCheckBox
        Left = 408
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 6
        OnClick = Bit0Click
        ExplicitLeft = 368
        ExplicitTop = 8
        ExplicitHeight = 17
      end
      object Bit1: TCheckBox
        Left = 425
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 7
        OnClick = Bit0Click
        ExplicitLeft = 376
        ExplicitTop = 8
        ExplicitHeight = 17
      end
      object Bit0: TCheckBox
        Left = 442
        Top = 0
        Width = 17
        Height = 25
        Align = alLeft
        TabOrder = 8
        OnClick = Bit0Click
        ExplicitLeft = 384
        ExplicitTop = 8
        ExplicitHeight = 17
      end
    end
    object Panel6: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 51
      Width = 470
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel5'
      ShowCaption = False
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 48
      ExplicitWidth = 476
      object Label3: TLabel
        AlignWithMargins = True
        Left = 266
        Top = 4
        Width = 54
        Height = 18
        Margins.Left = 8
        Margins.Top = 4
        Align = alLeft
        Caption = 'Adresa CV'
        ExplicitHeight = 15
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 4
        Width = 100
        Height = 18
        Margins.Top = 4
        Align = alLeft
        Caption = 'Adresa loko (POM)'
        ExplicitHeight = 15
      end
      object POMAdresa: TNumberBox
        Left = 106
        Top = 0
        Width = 152
        Height = 25
        Align = alLeft
        Alignment = taCenter
        Enabled = False
        MaxValue = 10239.000000000000000000
        TabOrder = 0
        SpinButtonOptions.Placement = nbspInline
        ExplicitLeft = 103
      end
      object CVAdresa: TNumberBox
        Left = 323
        Top = 0
        Width = 147
        Height = 25
        Align = alClient
        Alignment = taCenter
        MinValue = 1.000000000000000000
        MaxValue = 1023.000000000000000000
        TabOrder = 1
        SpinButtonOptions.Placement = nbspInline
        ExplicitWidth = 153
        ExplicitHeight = 23
      end
    end
    object Panel7: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 113
      Width = 470
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel7'
      ShowCaption = False
      TabOrder = 3
      object CVReadBtn: TButton
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 232
        Height = 25
        Margins.Left = 0
        Margins.Top = 0
        Margins.Bottom = 0
        Align = alLeft
        Caption = 'Vy'#269#237'ta'#357' hodnotu'
        TabOrder = 0
        OnClick = CVReadBtnClick
      end
      object CVWriteBtn: TButton
        AlignWithMargins = True
        Left = 238
        Top = 0
        Width = 232
        Height = 25
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alClient
        Caption = 'Zap'#237'sa'#357' hodnotu'
        TabOrder = 1
        OnClick = CVWriteBtnClick
        ExplicitLeft = 296
        ExplicitTop = 16
        ExplicitWidth = 75
      end
    end
  end
  object Panel2: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 347
    Width = 480
    Height = 25
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'TButt'
    ShowCaption = False
    TabOrder = 3
    ExplicitTop = 403
    ExplicitWidth = 476
    object Stav: TLabel
      AlignWithMargins = True
      Left = 0
      Top = 3
      Width = 397
      Height = 14
      Margins.Left = 0
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alClient
      Caption = 'Stav'
      ExplicitLeft = 8
      ExplicitTop = 381
      ExplicitWidth = 22
      ExplicitHeight = 15
    end
    object Button3: TButton
      Left = 405
      Top = 0
      Width = 75
      Height = 25
      Align = alRight
      Caption = 'Zavrie'#357
      TabOrder = 0
      OnClick = Button3Click
      ExplicitLeft = 408
      ExplicitTop = 8
    end
  end
end
