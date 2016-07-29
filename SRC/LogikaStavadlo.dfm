object DataModule1: TDataModule1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object Timer1: TTimer
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
