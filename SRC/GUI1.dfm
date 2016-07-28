object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'MES3-Z'
  ClientHeight = 466
  ClientWidth = 794
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 0
    Top = 0
    Width = 794
    Height = 439
    Align = alClient
    Color = clBlack
    ParentColor = False
    OnMouseUp = PaintBox1MouseUp
    OnPaint = PaintBox1Paint
    ExplicitTop = -3
    ExplicitWidth = 778
    ExplicitHeight = 401
  end
  object SPodPanel: TPanel
    Left = 0
    Top = 439
    Width = 794
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'SPodPanel'
    ShowCaption = False
    TabOrder = 0
    object VLoconet: TLabel
      AlignWithMargins = True
      Left = 264
      Top = 3
      Width = 75
      Height = 21
      Align = alLeft
      Caption = 'VLoconet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
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
        Font.Color = clGray
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitHeight = 19
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 136
    Top = 64
    object Funkcie1: TMenuItem
      Caption = 'Funkcie'
      object Drtoah1: TMenuItem
        Caption = 'Dr'#225'to'#357'ah'
      end
      object Diagnostika1: TMenuItem
        Caption = 'Technologick'#253' monitor'
        OnClick = Diagnostika1Click
      end
    end
    object Koniec1: TMenuItem
      Caption = 'Koniec'
      OnClick = Koniec1Click
    end
  end
end
