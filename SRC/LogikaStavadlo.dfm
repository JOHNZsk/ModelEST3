object LogikaES: TLogikaES
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object Timer1: TTimer
    Enabled = False
    Interval = 240
    OnTimer = Timer1Timer
    Left = 24
    Top = 16
  end
  object VolbaTimer: TTimer
    Enabled = False
    OnTimer = VolbaTimerTimer
    Left = 72
    Top = 16
  end
end
