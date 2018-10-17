object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'modelK'
  ClientHeight = 428
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
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    Caption = 'HorPanel'
    ShowCaption = False
    TabOrder = 0
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 305
      Height = 38
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      object VJednotka: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 86
        Height = 32
        Align = alLeft
        Caption = 'VJednotka'
        Color = clBtnFace
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
      Height = 38
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
        Height = 38
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
        ExplicitWidth = 186
        ExplicitHeight = 24
      end
    end
    object Panel4: TPanel
      AlignWithMargins = True
      Left = 308
      Top = 3
      Width = 487
      Height = 35
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel4'
      ShowCaption = False
      TabOrder = 2
      object VLoconet: TLabel
        Left = 0
        Top = 0
        Width = 487
        Height = 19
        Align = alTop
        Caption = 'VLoconet'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 75
      end
      object VDebug: TLabel
        Left = 0
        Top = 19
        Width = 487
        Height = 19
        Align = alTop
        Caption = 'VDebug'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 63
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 295
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
    Top = 254
    Width = 1008
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel5'
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
    Top = 38
    Width = 1008
    Height = 216
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
      Width = 990
      Height = 198
      Align = alClient
      TabOrder = 0
      OnMouseMove = PaintBox1MouseMove
      OnMouseUp = PaintBox1MouseUp
      OnMouseLeave = PaintBox1MouseLeave
      OnPaintBuffer = PaintBox1Paint
    end
  end
  object MainMenu1: TMainMenu
    Left = 288
    Top = 208
    object Funkcie1: TMenuItem
      Caption = 'Funkcie'
      object Drtoah1: TMenuItem
        Caption = 'Dr'#225'to'#357'ah'
        ShortCut = 119
        OnClick = Drtoah1Click
      end
      object Diagnostika1: TMenuItem
        Caption = 'Technologick'#253' monitor'
        ShortCut = 120
        OnClick = Diagnostika1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Resetnvstidel1: TMenuItem
        Caption = 'Reset n'#225'v'#283'stidel'
        OnClick = Resetnvstidel1Click
      end
      object Resetvhybej1: TMenuItem
        Caption = 'Reset v'#253'hybek'
        OnClick = Resetvhybej1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Nacelobrazovku1: TMenuItem
        Caption = 'Na cel'#250' obrazovku'
        ShortCut = 122
        OnClick = Nacelobrazovku1Click
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
end
