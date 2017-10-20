object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'MES3-Z'
  ClientHeight = 466
  ClientWidth = 1024
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object HorPanel: TPanel
    Left = 0
    Top = 0
    Width = 1024
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    Caption = 'HorPanel'
    ShowCaption = False
    TabOrder = 0
    object VLoconet: TLabel
      AlignWithMargins = True
      Left = 268
      Top = 3
      Width = 75
      Height = 32
      Align = alLeft
      Caption = 'VLoconet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 264
      ExplicitHeight = 19
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 265
      Height = 38
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      ExplicitHeight = 27
      object VJednotka: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 86
        Height = 32
        Align = alLeft
        Caption = 'VJednotka'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitHeight = 19
      end
    end
    object Panel3: TPanel
      Left = 814
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
        ExplicitLeft = 136
        ExplicitTop = 1
        ExplicitWidth = 186
        ExplicitHeight = 24
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 370
    Width = 1024
    Height = 96
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    object PanelRizik: TPanel
      Left = 0
      Top = 0
      Width = 400
      Height = 96
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'PanelRizik'
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object PaintBoxRizika: TPaintBox32
        Left = 0
        Top = 0
        Width = 400
        Height = 96
        Align = alClient
        TabOrder = 0
      end
    end
    object PanelPoruch: TPanel
      Left = 724
      Top = 0
      Width = 300
      Height = 96
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
        Height = 96
        Align = alClient
        TabOrder = 0
        OnPaintBuffer = PaintBoxPoruchyPaintBuffer
      end
    end
  end
  object PaintBox1: TPaintBox32
    Left = 0
    Top = 38
    Width = 1024
    Height = 332
    Align = alClient
    TabOrder = 2
    OnMouseUp = PaintBox1MouseUp
    OnPaintBuffer = PaintBox1Paint
    ExplicitTop = 27
    ExplicitHeight = 343
  end
  object MainMenu1: TMainMenu
    Left = 136
    Top = 64
    object Funkcie1: TMenuItem
      Caption = 'Funkcie'
      object Drtoah1: TMenuItem
        Caption = 'Dr'#225'to'#357'ah'
        OnClick = Drtoah1Click
      end
      object Diagnostika1: TMenuItem
        Caption = 'Technologick'#253' monitor'
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
    end
    object Koniec1: TMenuItem
      Caption = 'Koniec'
      OnClick = Koniec1Click
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 416
    Top = 248
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
  end
end
