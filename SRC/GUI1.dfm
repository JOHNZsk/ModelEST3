object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'modelK'
  ClientHeight = 530
  ClientWidth = 1008
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object HorPanel: TPanel
    Left = 0
    Top = 0
    Width = 1008
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Caption = 'HorPanel'
    Color = clBlack
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 305
      Height = 40
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel1'
      Color = clBlack
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object VJednotka: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 86
        Height = 34
        Align = alLeft
        Caption = 'VJednotka'
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        ExplicitHeight = 19
      end
    end
    object Panel3: TPanel
      Left = 798
      Top = 0
      Width = 210
      Height = 40
      Align = alRight
      BevelOuter = bvNone
      Caption = 'Panel3'
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      object Cas: TLabel
        Left = 0
        Top = 0
        Width = 210
        Height = 40
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Align = alClient
        Alignment = taCenter
        Caption = '88.88.8888 88:88:88'
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
        OnClick = CasClick
        OnDblClick = CasDblClick
        ExplicitWidth = 186
        ExplicitHeight = 24
      end
    end
    object Panel4: TPanel
      AlignWithMargins = True
      Left = 308
      Top = 3
      Width = 487
      Height = 37
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel4'
      Color = clBlack
      ParentBackground = False
      ShowCaption = False
      TabOrder = 2
      object Panel7: TPanel
        Left = 0
        Top = 0
        Width = 487
        Height = 37
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel7'
        Color = clBlack
        ParentBackground = False
        TabOrder = 0
        object VLoconet: TLabel
          Left = 0
          Top = 19
          Width = 487
          Height = 19
          Align = alTop
          AutoSize = False
          Caption = 'VLoconet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          ExplicitLeft = 1
          ExplicitTop = -3
          ExplicitWidth = 183
        end
        object VZ21: TLabel
          Left = 0
          Top = 0
          Width = 487
          Height = 19
          Align = alTop
          AutoSize = False
          Caption = 'VZ21'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clSilver
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          ExplicitLeft = 3
          ExplicitTop = -6
          ExplicitWidth = 352
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 397
    Width = 1008
    Height = 133
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    object PanelRizik: TPanel
      Left = 0
      Top = 0
      Width = 708
      Height = 133
      Align = alClient
      BevelOuter = bvNone
      Caption = 'PanelRizik'
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object PaintBoxRizika: TPaintBox32
        Left = 0
        Top = 0
        Width = 708
        Height = 133
        Align = alClient
        TabOrder = 0
        OnPaintBuffer = PaintBoxRizikaPaintBuffer
      end
    end
    object PanelPoruch: TPanel
      Left = 708
      Top = 0
      Width = 300
      Height = 133
      Align = alRight
      BevelOuter = bvNone
      Caption = 'PanelPoruch'
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      object PaintBoxPoruchy: TPaintBox32
        Left = 0
        Top = 0
        Width = 300
        Height = 133
        Align = alClient
        TabOrder = 0
        OnPaintBuffer = PaintBoxPoruchyPaintBuffer
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 356
    Width = 1008
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel5'
    Color = clBlack
    ParentBackground = False
    ShowCaption = False
    TabOrder = 2
    object PanelSV: TPanel
      Left = 0
      Top = 0
      Width = 1008
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'PanelSV'
      Color = clMaroon
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object Label1: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 5
        Width = 84
        Height = 31
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Align = alLeft
        Caption = 'Label1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -25
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitHeight = 30
      end
      object StitokVyluka: TEdit
        AlignWithMargins = True
        Left = 94
        Top = 5
        Width = 909
        Height = 31
        Margins.Left = 0
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = 'StitokVyluka'
        OnKeyUp = StitokVylukaKeyUp
        ExplicitHeight = 32
      end
    end
  end
  object PanelOkraj: TPanel
    Left = 0
    Top = 40
    Width = 813
    Height = 316
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PanelOkraj'
    Color = clBlack
    Padding.Left = 9
    Padding.Top = 9
    Padding.Right = 9
    Padding.Bottom = 9
    ParentBackground = False
    ShowCaption = False
    TabOrder = 3
    StyleElements = []
    object PaintBox1: TPaintBox32
      Left = 9
      Top = 9
      Width = 795
      Height = 298
      Align = alClient
      TabOrder = 0
      OnMouseMove = PaintBox1MouseMove
      OnMouseUp = PaintBox1MouseUp
      OnMouseLeave = PaintBox1MouseLeave
      OnPaintBuffer = PaintBox1Paint
    end
  end
  object Z21Panel: TPanel
    AlignWithMargins = True
    Left = 816
    Top = 43
    Width = 189
    Height = 310
    Align = alRight
    BevelOuter = bvNone
    Caption = 'Z21Panel'
    Color = clBlack
    ParentBackground = False
    ShowCaption = False
    TabOrder = 4
    object Z21TeplotaVnitrni: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 176
      Width = 183
      Height = 16
      Align = alTop
      Caption = 'Vn'#250'torn'#225' teplota:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 100
    end
    object Z21ProudZpetny: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 88
      Width = 183
      Height = 16
      Align = alTop
      Caption = 'Sp'#228'tn'#253' pr'#250'd: '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 78
    end
    object Z21NapetiVnejsi: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 132
      Width = 183
      Height = 16
      Align = alTop
      Caption = 'Nap'#225'jacie nap'#228'tie:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 107
    end
    object Z21NapetiVnitrni: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 154
      Width = 183
      Height = 16
      Align = alTop
      Caption = 'Nap'#228'tie v ko'#318'ajniciach:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 130
    end
    object Z21ProudVstup: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 66
      Width = 183
      Height = 16
      Align = alTop
      Caption = 'Vstupn'#253' pr'#250'd: '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 84
    end
    object Z21Stav: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 39
      Width = 183
      Height = 21
      Align = alTop
      Alignment = taCenter
      Caption = '!!! N'#218'DZOV'#221' STOP !!!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 181
    end
    object Z21Vystraha: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 198
      Width = 183
      Height = 17
      Align = alTop
      Alignment = taCenter
      Caption = 'Zisten'#253' skrat v boosteri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 162
    end
    object Z21ProgramKolejProud: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 110
      Width = 183
      Height = 16
      Align = alTop
      Caption = 'Programovacia ko'#318'aj:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 123
    end
    object Label2: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 183
      Height = 30
      Align = alTop
      Alignment = taCenter
      Caption = 'Centr'#225'la Z21'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -25
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 162
    end
    object ZrusStopBtn: TButton
      Left = 0
      Top = 277
      Width = 189
      Height = 33
      Align = alBottom
      Caption = 'ZRU'#352' SKRAT/STOP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Visible = False
      OnClick = ZrusStopBtnClick
    end
    object StopBtn: TButton
      Left = 0
      Top = 244
      Width = 189
      Height = 33
      Align = alBottom
      Caption = 'STOP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      Visible = False
      OnClick = StopBtnClick
    end
  end
  object MainMenu1: TMainMenu
    Left = 288
    Top = 208
    object Funkcie1: TMenuItem
      Caption = 'Funkcie'
      object Drtoah1: TMenuItem
        Caption = 'Dr'#225'to'#357'ah'
        ShortCut = 118
        OnClick = Drtoah1Click
      end
      object Diagnostika1: TMenuItem
        Caption = 'Technologick'#253' monitor LocoNet'
        ShortCut = 119
        OnClick = Diagnostika1Click
      end
      object Z211: TMenuItem
        Caption = 'Technologick'#253' monitor Z21'
        ShortCut = 120
        OnClick = Z211Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Resetnvstidel1: TMenuItem
        Caption = 'Reset n'#225'vestidiel'
        OnClick = Resetnvstidel1Click
      end
      object Resetvhybej1: TMenuItem
        Caption = 'Reset v'#253'hybiek'
        OnClick = Resetvhybej1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Z21M: TMenuItem
        Caption = 'Informa'#269'n'#253' panel Z21'
        ShortCut = 113
        OnClick = Z21MClick
      end
      object Nacelobrazovku1: TMenuItem
        Caption = 'Na cel'#250' obrazovku'
        ShortCut = 122
        OnClick = Nacelobrazovku1Click
      end
      object Modelovas1: TMenuItem
        Caption = 'Modelov'#253' '#269'as'
        ShortCut = 121
        OnClick = Modelovas1Click
      end
    end
    object Nastavenia1: TMenuItem
      Caption = 'Nastavenia'
      object Predefinovanietextov1: TMenuItem
        Caption = 'Predefinovanie textov'
        OnClick = Predefinovanietextov1Click
      end
      object Predefinovaniekonfigurcie1: TMenuItem
        Caption = 'Predefinovanie konfigur'#225'cie'
        OnClick = Predefinovaniekonfigurcie1Click
      end
    end
    object Koniec1: TMenuItem
      Caption = 'Koniec'
      OnClick = Koniec1Click
    end
  end
  object PopupMenu1: TPopupMenu
    MenuAnimation = [maTopToBottom]
    Left = 328
    Top = 208
    object NAZOV1: TMenuItem
      Caption = 'NAZOV'
      Enabled = False
    end
    object STAV1: TMenuItem
      Caption = 'STAV'
      OnClick = STAV1Click
    end
    object SSTAV: TMenuItem
      Caption = '-'
    end
    object STOJ1: TMenuItem
      Caption = 'STOJ'
      OnClick = STAV1Click
    end
    object DN1: TMenuItem
      Caption = 'DN'
      OnClick = STAV1Click
    end
    object PN1: TMenuItem
      Caption = 'PN'
      OnClick = STAV1Click
    end
    object SNAV: TMenuItem
      Caption = '-'
    end
    object ZAM1: TMenuItem
      Caption = 'ZAM>'
      OnClick = STAV1Click
    end
    object ZAM2: TMenuItem
      Caption = 'ZAM<'
      OnClick = STAV1Click
    end
    object SZAM: TMenuItem
      Caption = '-'
    end
    object P1: TMenuItem
      Caption = 'P+'
      OnClick = STAV1Click
    end
    object P2: TMenuItem
      Caption = 'P-'
      OnClick = STAV1Click
    end
    object SVYH: TMenuItem
      Caption = '-'
    end
    object ZAV1: TMenuItem
      Caption = 'ZAV>'
      OnClick = STAV1Click
    end
    object ZAV2: TMenuItem
      Caption = 'ZAV<'
      OnClick = STAV1Click
    end
    object SZAV: TMenuItem
      Caption = '-'
    end
    object STIT1: TMenuItem
      Caption = 'STIT'
      OnClick = STAV1Click
    end
    object VYL1: TMenuItem
      Caption = 'VYL'
      OnClick = STAV1Click
    end
    object SVYL: TMenuItem
      Caption = '-'
    end
    object RESET1: TMenuItem
      Caption = 'RESET'
      OnClick = STAV1Click
    end
    object KPV1: TMenuItem
      Caption = 'KPV'
      OnClick = STAV1Click
    end
    object KSV1: TMenuItem
      Caption = 'KSV'
      OnClick = STAV1Click
    end
    object RNAV1: TMenuItem
      Caption = 'RNAV'
      OnClick = STAV1Click
    end
    object RVYH1: TMenuItem
      Caption = 'RVYH'
      OnClick = STAV1Click
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 728
    Top = 136
  end
end
