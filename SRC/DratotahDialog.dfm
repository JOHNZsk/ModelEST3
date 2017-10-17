object DratotahDlg: TDratotahDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Dr'#225'to'#357'ah'
  ClientHeight = 317
  ClientWidth = 722
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 706
    Height = 301
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 615
    object TabSheet1: TTabSheet
      Caption = 'V'#253'hybky'
      ExplicitWidth = 607
      object ListViewVyhybky: TListView
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 692
        Height = 267
        Align = alClient
        Columns = <
          item
            Caption = #268'J'
          end
          item
            Caption = 'Doprav'#328'a'
            Width = 80
          end
          item
            Caption = 'N'#225'zev'
            Width = 80
          end
          item
            Caption = 'Adresa'
          end
          item
            AutoSize = True
            Caption = 'Stav'
          end>
        DoubleBuffered = True
        GridLines = True
        ReadOnly = True
        RowSelect = True
        ParentDoubleBuffered = False
        TabOrder = 0
        ViewStyle = vsReport
        ExplicitWidth = 601
      end
    end
    object Návestidlá: TTabSheet
      Caption = 'N'#225'vestidl'#225
      ImageIndex = 1
      ExplicitWidth = 607
      object ListViewNavestidla: TListView
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 692
        Height = 267
        Align = alClient
        Columns = <
          item
            Caption = #268'J'
          end
          item
            Caption = 'Doprav'#328'a'
            Width = 80
          end
          item
            Caption = 'N'#225'zev'
            Width = 80
          end
          item
            Caption = 'N'#225'v'#283'st. po'#382
            Width = 80
          end
          item
            Caption = 'N'#225'v'#283'st sv.'
            Width = 80
          end
          item
            AutoSize = True
            Caption = 'Stav'
          end>
        DoubleBuffered = True
        GridLines = True
        Groups = <
          item
            Header = 'Vchodov'#233' n'#225'vestidl'#225
            GroupID = 0
            State = [lgsNormal]
            HeaderAlign = taLeftJustify
            FooterAlign = taLeftJustify
            TitleImage = -1
          end
          item
            Header = 'Odchodov'#233' n'#225'vestidl'#225
            GroupID = 1
            State = [lgsNormal]
            HeaderAlign = taLeftJustify
            FooterAlign = taLeftJustify
            TitleImage = -1
          end
          item
            Header = 'Zria'#271'ovacie n'#225'vestidl'#225
            GroupID = 2
            State = [lgsNormal]
            HeaderAlign = taLeftJustify
            FooterAlign = taLeftJustify
            TitleImage = -1
          end
          item
            Header = 'Ostatn'#233
            GroupID = 3
            State = [lgsNormal]
            HeaderAlign = taLeftJustify
            FooterAlign = taLeftJustify
            TitleImage = -1
          end>
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentDoubleBuffered = False
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
end
