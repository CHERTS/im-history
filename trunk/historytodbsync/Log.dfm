object LogForm: TLogForm
  Left = 0
  Top = 0
  Caption = 'HistoryToDBSyncLog'
  ClientHeight = 286
  ClientWidth = 615
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000000680400001600000028000000100000002000
    0000010020000000000000040000000000000000000000000000000000000000
    0000000000000000000000000000FF1F2A000000000000000000000000000000
    00000000000000000000FF1F2A00000000000000000000000000000000000000
    00000000000000000000FF1F2A00FEEFA900FF1F2A00CDCDCD00CDCDCD00CDCD
    CD00CDCDCD00FF1F2A00FEEFA900FF1F2A000000000000000000000000000000
    000000000000FF1F2A00FEEFA900FFE55F00FF1F2A00FF1F2A00FF1F2A00FF1F
    2A00FF1F2A00FF1F2A00FFE55F00FEEFA900FF1F2A0000000000000000000000
    0000FF1F2A00FEEFA900FFE55F00FFE55F00FFE55F00FFD35000FECF4D00FFCC
    4A00FFD35000FFE55F00FFE55F00FFE55F00FEEFA900FF1F2A0000000000FF1F
    2A00FEEFA900FFE55F00FFE55F00FFE55F00FFE55F00FFD35000FFCA4800FFCC
    4A00FFD35000FFE55F00FFE55F00FFE55F00FFE55F00FEEFA900FF1F2A000000
    0000FF1F2A00FEEFA900FFE55F00FFE55F00FFE55F00FFD35000FFCA4800FFCC
    4A00FFD35000FFE55F00FFE55F00FFE55F00FEEFA900FF1F2A00000000000000
    000000000000FF1F2A00FEEFA900FFE55F00FF1F2A00FF1F2A00FF1F2A00FF1F
    2A00FF1F2A00FF1F2A00FFE55F00FEEFA900FF1F2A0000000000000000000000
    000000000000C1BDB600FF1F2A00FEEFA900FF1F2A00C1B7AF00D2BEB900D2BE
    B900D2BEB900FF1F2A00FEEFA900FF1F2A00C1BDB60000000000000000000000
    000000000000BAB7AF00A39A8F00FF1F2A00CAC1B800DFD5CC00FAE2DF00F7DB
    D900DFD5CC00CAC1B800FF1F2A00A39A8F00BAB7AF0000000000000000000000
    000000000000B1AB9F00C9C2B900CFC7BF00D5CCC400DCD3CA00E8DDD500E4D6
    CF00E4D6CF00D5CCC400CFC7BF00C9C2B900B1AB9F0000000000000000000000
    000000000000B0AB9E00C7C0B600CCC4BB00D3C9C100DAD0C700EBE1DA00E4D9
    D100DDD2CA00DBCDC500DDCAC400DBC4BF00C1ADA40000000000000000000000
    000000000000AFAA9D00C8C1B700E8E3DB00F5F0E800FDF8F200FBF7F000FCF7
    F100FDF8F200F7F0EA00ECE3DC00CDC3BB00B2AA9E0000000000000000000000
    000000000000AEA89C00FBF5EF00EEE7DE00E0D8CE00DDD5CC00DDD4CB00DDD4
    CB00DDD5CC00E0D7CE00EDE6DE00FBF6EF00AEA89C0000000000000000000000
    000000000000AFA99D00E1D8CE00E1D7CE00DFD6CC00DFD5CB00DFD5CB00DFD5
    CB00DFD5CB00DFD6CC00E1D7CE00E1D8CE00AFA99D0000000000000000000000
    000000000000D9D9D900B6B0A400D6CFC400E6DED500EFE7DD00EEE6DC00EEE6
    DC00EFE7DD00E6DED500D6CFC400B6B0A400D9D9D90000000000000000000000
    00000000000000000000D9D9D900C4C0B700AEA99C00AEA89C00AEA89C00AEA8
    9C00AEA89C00AEA99C00C4C0B700D9D9D900000000000000000000000000F7EF
    FFFFE007FFFFC003FFFF8001FFFF0000FFFF8001FFFFC003FFFFC003FFFFC003
    FFFFC003FFFFC003FFFFC003FFFFC003FFFFC003FFFFC003FFFFE007FFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    615
    286)
  PixelsPerInch = 96
  TextHeight = 13
  object LFileNameDesc: TLabel
    Left = 8
    Top = 12
    Width = 79
    Height = 13
    Caption = #1048#1084#1103' '#1083#1086#1075'-'#1092#1072#1081#1083#1072':'
  end
  object CBFileName: TComboBox
    Left = 93
    Top = 9
    Width = 268
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = CBFileNameChange
    OnDropDown = CBFileNameDropDown
  end
  object DeleteLogButton: TButton
    Left = 485
    Top = 7
    Width = 122
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1083#1086#1075'-'#1092#1072#1081#1083
    Enabled = False
    ImageIndex = 26
    Images = MainSyncForm.ImageList_Main
    TabOrder = 2
    OnClick = DeleteLogButtonClick
  end
  object ReloadLogButton: TButton
    Left = 367
    Top = 7
    Width = 112
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    Enabled = False
    ImageIndex = 0
    Images = MainSyncForm.ImageList_Main
    TabOrder = 1
    OnClick = ReloadLogButtonClick
  end
  object GIFPanel: TPanel
    Left = 200
    Top = 128
    Width = 83
    Height = 28
    AutoSize = True
    BevelKind = bkTile
    BevelOuter = bvNone
    BorderWidth = 3
    Color = clWindow
    DoubleBuffered = False
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 4
    Visible = False
    object JvGIFAnimator: TJvGIFAnimator
      Left = 3
      Top = 3
      Width = 16
      Height = 16
      Hint = #1046#1076#1080#1090#1077'...'
      AsyncDrawing = True
      Animate = True
      Center = True
      FrameIndex = 7
      Image.Data = {
        9802000047494638396110001000A20000FFFFFF000000C2C2C2424242000000
        62626282828292929221FF0B4E45545343415045322E30030100000021FE1A43
        726561746564207769746820616A61786C6F61642E696E666F0021F904000A00
        00002C000000001000100000033308BADCFE30CA496B1363083A08199C074E98
        660945B131C2BA1499C1B62E60C4C271D02D5B1839DDA60739180C074A6BE748
        000021F904000A0000002C000000001000100000033408BADCFE4E8C21201B84
        0CBBB0E68A447142515460311920604C455B1AA87C1CB575DFED6118078020D7
        18E2864319B225242A120021F904000A0000002C000000001000100000033608
        BA32232BCA41C890CC94562F0685631C0EF4194EF149426198AB701CF00ACCB3
        BD1CC6A82B0259ED17FC0183C30F32A9641A9FBF040021F904000A0000002C00
        0000001000100000033308BA62252BCA328691EC9C565F858BA60985210C0431
        4487611C11AA4682B0D11F0362525DF33D1F30382C1A8FC8A472394C000021F9
        04000A0000002C000000001000100000033208BA72272B4AE76414F018F34C81
        0C2676C3605C6254948584B91E68594229CFCA4010031EE93C1FC3262C1A8FC8
        A45292000021F904000A0000002C000000001000100000033308BA20C2903917
        E374E7BCDA9E3019C71CE0212E42B69DCA57ACA2310C060B147361BBB035F795
        018130B00989BB9F6D294A000021F904000A0000002C00000000100010000003
        3208BADCFEF00911D99C555D9A01EEDA7170956088DD619CDD3496854146C530
        1490609BB6010D04C240109B3180C2D6CE91000021F904000A0000002C000000
        001000100000033208BADCFE30CA49AB6542D49C29D71E0808C3208EC7710E04
        3130A9CAB0AE5018C261180756DAA50220756218829E5B119000003B}
      ParentShowHint = False
      ShowHint = False
    end
    object GIFStaticText: TStaticText
      Left = 25
      Top = 4
      Width = 51
      Height = 17
      Caption = #1046#1076#1080#1090#1077'...'
      TabOrder = 0
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 267
    Width = 615
    Height = 19
    Panels = <
      item
        Width = 210
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object TextListView: TListView
    Left = 0
    Top = 40
    Width = 615
    Height = 225
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        AutoSize = True
        Caption = 'Text'
      end>
    ColumnClick = False
    MultiSelect = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 3
    ViewStyle = vsReport
    OnContextPopup = TextListViewContextPopup
    OnCustomDrawItem = TextListViewCustomDrawItem
    OnData = TextListViewData
  end
  object LogFormStorage: TJvFormStorage
    AppStorage = MainSyncForm.AppIniFileStorage
    AppStoragePath = '%FORM_NAME%\'
    StoredValues = <>
    Left = 366
    Top = 48
  end
  object FileReadThread: TJvThread
    Exclusive = True
    MaxCount = 0
    RunOnCreate = True
    FreeOnTerminate = True
    OnExecute = FileReadThreadExecute
    OnFinish = FileReadThreadFinish
    Left = 448
    Top = 48
  end
  object LogPopupMenu: TPopupMenu
    Left = 368
    Top = 96
    object LogCopy: TMenuItem
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      OnClick = LogCopyClick
    end
    object SelectAllRow: TMenuItem
      Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077
      OnClick = SelectAllRowClick
    end
  end
end
