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
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    Caption = 'HorPanel'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 794
    object VLoconet: TLabel
      AlignWithMargins = True
      Left = 264
      Top = 3
      Width = 75
      Height = 21
      Align = alLeft
      Caption = 'VLoconet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitHeight = 19
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 261
      Height = 27
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
        Height = 21
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
    ExplicitWidth = 794
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
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 94
      object PaintBoxRizika: TPaintBox32
        Left = 0
        Top = 0
        Width = 400
        Height = 96
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 3
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
    Top = 27
    Width = 1024
    Height = 343
    Align = alClient
    TabOrder = 2
    OnMouseUp = PaintBox1MouseUp
    OnPaintBuffer = PaintBox1Paint
    ExplicitLeft = 336
    ExplicitTop = 160
    ExplicitWidth = 192
    ExplicitHeight = 192
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
end
