object CPort: TCPort
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object Timer1: TTimer
    Interval = 70
    OnTimer = Timer1Timer
    Left = 88
    Top = 24
  end
end
