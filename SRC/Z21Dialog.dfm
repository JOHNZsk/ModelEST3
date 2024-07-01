object Z21Dlg: TZ21Dlg
  Left = 227
  Top = 108
  BorderStyle = bsToolWindow
  Caption = 'Technologick'#253' monitor Z21'
  ClientHeight = 411
  ClientWidth = 704
  Color = clBtnFace
  ParentFont = True
  PopupMode = pmExplicit
  PopupParent = Form1.Owner
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 516
    Height = 395
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 508
    ExplicitHeight = 383
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 532
    Top = 8
    Width = 164
    Height = 395
    Margins.Left = 0
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alRight
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = 524
    ExplicitHeight = 383
    object PripojBtn: TButton
      AlignWithMargins = True
      Left = 0
      Top = 0
      Width = 164
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Pripoji'#357' Z21'
      TabOrder = 0
      OnClick = PripojBtnClick
    end
    object OdpojBtn: TButton
      AlignWithMargins = True
      Left = 0
      Top = 29
      Width = 164
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Odpoji'#357' Z21'
      Enabled = False
      TabOrder = 1
      OnClick = OdpojBtnClick
    end
    object Button2: TButton
      AlignWithMargins = True
      Left = 0
      Top = 66
      Width = 164
      Height = 25
      Margins.Left = 0
      Margins.Top = 8
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Na'#269#237'ta'#345' broadcasty'
      TabOrder = 2
      OnClick = Button2Click
    end
    object FWVBtn: TButton
      AlignWithMargins = True
      Left = 0
      Top = 95
      Width = 164
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Na'#269#237'ta'#357' verziu FW'
      TabOrder = 3
      OnClick = FWVBtnClick
    end
    object Button4: TButton
      AlignWithMargins = True
      Left = 0
      Top = 124
      Width = 164
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Na'#269#237'ta'#357' s'#233'riov'#233' '#269#237'slo'
      TabOrder = 4
      OnClick = Button4Click
    end
    object StopBtn: TButton
      AlignWithMargins = True
      Left = 0
      Top = 161
      Width = 164
      Height = 25
      Margins.Left = 0
      Margins.Top = 8
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alTop
      Caption = 'Stop'
      TabOrder = 5
      OnClick = StopBtnClick
    end
    object Button3: TButton
      Left = 0
      Top = 190
      Width = 164
      Height = 25
      Align = alTop
      Caption = 'Zru'#353' stop'
      TabOrder = 6
      OnClick = Button3Click
    end
  end
  object IdUDPClient1: TIdUDPClient
    BoundIP = '0.0.0.0'
    BoundPortMin = 21105
    BoundPortMax = 21106
    Host = '192.168.0.111'
    Port = 21105
    ReuseSocket = rsTrue
    Left = 584
    Top = 64
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 536
    Top = 56
  end
end
