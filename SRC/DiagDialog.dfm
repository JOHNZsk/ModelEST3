object DiagDlg: TDiagDlg
  Left = 227
  Top = 108
  BorderStyle = bsToolWindow
  Caption = 'Technologick'#253' monitor LocoNet'
  ClientHeight = 599
  ClientWidth = 752
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 24
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 329
    Top = 8
    Width = 415
    Height = 583
    Margins.Left = 0
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Caption = 'V'#253'pis komunikace'
    TabOrder = 0
    object Memo1: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 29
      Width = 405
      Height = 549
      Align = alClient
      Lines.Strings = (
        'Memo1')
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 313
    Height = 583
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object GroupBox2: TGroupBox
      Left = 0
      Top = 65
      Width = 313
      Height = 97
      Align = alTop
      Caption = 'Vo'#318'ba COM portu'
      TabOrder = 0
      object Button4: TButton
        AlignWithMargins = True
        Left = 5
        Top = 67
        Width = 303
        Height = 30
        Align = alTop
        Caption = 'Nastavi'#357
        TabOrder = 0
        OnClick = Button4Click
      end
      object Edit2: TEdit
        AlignWithMargins = True
        Left = 5
        Top = 29
        Width = 303
        Height = 32
        Align = alTop
        TabOrder = 1
        Text = 'Edit2'
      end
    end
    object GroupBox4: TGroupBox
      Left = 0
      Top = 162
      Width = 313
      Height = 134
      Align = alTop
      Caption = 'Riadenie komunik'#225'cie'
      TabOrder = 1
      object Button1: TButton
        AlignWithMargins = True
        Left = 5
        Top = 62
        Width = 303
        Height = 30
        Align = alTop
        Caption = 'Pripoji'#357' LocoNet'
        TabOrder = 0
        OnClick = Button1Click
      end
      object SimPripoj: TCheckBox
        AlignWithMargins = True
        Left = 5
        Top = 29
        Width = 303
        Height = 27
        Align = alTop
        Caption = 'Simulova'#357' Loconet'
        TabOrder = 1
      end
      object Button2: TButton
        AlignWithMargins = True
        Left = 160
        Top = 98
        Width = 148
        Height = 31
        Align = alRight
        Caption = 'PWR-'
        TabOrder = 2
        OnClick = Button2Click
      end
      object Button5: TButton
        AlignWithMargins = True
        Left = 5
        Top = 98
        Width = 148
        Height = 31
        Align = alLeft
        Caption = 'PWR+'
        TabOrder = 3
        OnClick = Button5Click
      end
    end
    object GroupBox5: TGroupBox
      AlignWithMargins = True
      Left = 0
      Top = 304
      Width = 313
      Height = 142
      Margins.Left = 0
      Margins.Top = 8
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      Caption = 'Testovanie pr'#237'slu'#353'enstva'
      TabOrder = 2
      object Button3: TButton
        AlignWithMargins = True
        Left = 5
        Top = 107
        Width = 303
        Height = 30
        Align = alBottom
        Caption = 'Vykona'#357' povel'
        TabOrder = 0
        OnClick = Button3Click
      end
      object Panel3: TPanel
        AlignWithMargins = True
        Left = 5
        Top = 29
        Width = 303
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Panel3'
        ShowCaption = False
        TabOrder = 1
        object Label4: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 61
          Height = 26
          Align = alLeft
          AutoSize = False
          Caption = 'Adresa'
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitHeight = 24
        end
        object Edit1: TEdit
          Left = 67
          Top = 0
          Width = 236
          Height = 32
          Align = alClient
          TabOrder = 0
          Text = 'Edit1'
        end
      end
      object Panel4: TPanel
        AlignWithMargins = True
        Left = 5
        Top = 67
        Width = 303
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Panel4'
        ShowCaption = False
        TabOrder = 2
        object RadioButton1: TRadioButton
          Left = 0
          Top = 0
          Width = 105
          Height = 32
          Align = alLeft
          Caption = 'Zhoden'#253
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object RadioButton2: TRadioButton
          Left = 105
          Top = 0
          Width = 127
          Height = 32
          Align = alClient
          Caption = 'Nahoden'#253
          TabOrder = 1
        end
        object RadioButton3: TRadioButton
          Left = 232
          Top = 0
          Width = 71
          Height = 32
          Align = alRight
          Caption = 'Test'
          TabOrder = 2
        end
      end
    end
    object GroupBox6: TGroupBox
      Left = 0
      Top = 519
      Width = 313
      Height = 57
      Align = alTop
      Caption = 'V'#253'pis'
      TabOrder = 3
      object VypisCele: TCheckBox
        AlignWithMargins = True
        Left = 5
        Top = 26
        Width = 303
        Height = 27
        Margins.Top = 0
        Align = alTop
        Caption = 'Vypisova'#357' prijat'#233' bajty'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
    end
    object GroupBox7: TGroupBox
      Left = 0
      Top = 454
      Width = 313
      Height = 65
      Align = alTop
      Caption = 'Fronta povelov'
      TabOrder = 4
      object Label6: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 29
        Width = 303
        Height = 24
        Align = alTop
        Alignment = taCenter
        Caption = 'Label6'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 67
      end
    end
    object GroupBox3: TGroupBox
      Left = 0
      Top = 0
      Width = 313
      Height = 65
      Align = alTop
      Caption = 'Aktu'#225'lny COM port'
      TabOrder = 5
      object Label5: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 29
        Width = 303
        Height = 24
        Align = alTop
        Alignment = taCenter
        Caption = 'Label5'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 67
      end
    end
  end
  object ApplicationEvents1: TApplicationEvents
    Left = 665
    Top = 8
  end
end
