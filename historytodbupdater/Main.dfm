object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'HistoryToDBUpdater'
  ClientHeight = 357
  ClientWidth = 486
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
    000000000000D0CDC500FF1F2A00FEEFA900FF1F2A00CDCDCD00CDCDCD00CDCD
    CD00CDCDCD00FF1F2A00FEEFA900FF1F2A000000000000000000000000000000
    0000D0CDC500FF1F2A00FEEFA900FFE55F00FF1F2A00FF1F2A00FF1F2A00FF1F
    2A00FF1F2A00FF1F2A00FFE55F00FEEFA900FF1F2A00D0CDC500000000000000
    0000FF1F2A00FEEFA900FFE55F00FFE55F00FFE55F00FFD35000FECF4D00FFCC
    4A00FFD35000FFE55F00FFE55F00FFE55F00FEEFA900FF1F2A0000000000FF1F
    2A00FEEFA900FFE55F00FFE55F00FFE55F00FFE55F00FFD35000FFCA4800FFCC
    4A00FFD35000FFE55F00FFE55F00FFE55F00FFE55F00FF1F2A00FF1F2A000000
    0000FF1F2A00FEEFA900FFE55F00FFE55F00FFE55F00FFD35000FFCA4800FFCC
    4A00FFD35000FFE55F00FFE55F00FFE55F00FEEFA900FF1F2A00000000000000
    0000C1BDB600FF1F2A00FEEFA900FFE55F00FF1F2A00FF1F2A00FF1F2A00FF1F
    2A00FF1F2A00FF1F2A00FFE55F00FEEFA900FF1F2A00CFC7BF00000000000000
    0000C1BDB600F9F3ED00FF1F2A00FEEFA900FF1F2A00D2D2D200D2D2D200D2D2
    D200D2D2D200FF1F2A00FEEFA900FF1F2A00BAB7AF00CFC7BF00000000000000
    0000BAB7AF00A39A8F00BAB2A700FF1F2A00D2D2D200D2D2D200D2D2D200D2D2
    D200D2D2D200D2D2D200FF1F2A00CFC7BF00A39A8F00BAB7AF00000000000000
    0000B1AB9F00C9C2B900CFC7BF00D5CCC400DCD3CA00E4D9D200E8DDD500E4D6
    CF00E4D6CF00E4D6CF00D5CCC400CFC7BF00C9C2B900B1AB9F00000000000000
    0000B0AB9E00C7C0B600CCC4BB00D3C9C100DAD0C700E1D7CF00EBE1DA00E4D9
    D100E4D9D100DDD2CA00DBCDC500DDCAC400DBC4BF00C1ADA400000000000000
    0000AFAA9D00C8C1B700E8E3DB00F5F0E800FDF8F200FCF8F100FBF7F000FCF7
    F100FCF7F100FDF8F200F7F0EA00ECE3DC00CDC3BB00B2AA9E00000000000000
    0000AEA89C00FBF5EF00EEE7DE00E0D8CE00DDD5CC00DDD4CB00DDD4CB00DDD4
    CB00DDD4CB00DDD5CC00E0D7CE00EDE6DE00FBF6EF00AEA89C00000000000000
    0000AFA99D00E1D8CE00E1D7CE00DFD6CC00DFD5CB00DFD5CB00DFD5CB00DFD5
    CB00DFD5CB00DFD5CB00DFD6CC00E1D7CE00E1D8CE00AFA99D00000000000000
    000000000000B6B0A400D6CFC400E6DED500EFE7DD00EEE6DC00EEE6DC00EEE6
    DC00EEE6DC00EFE7DD00E6DED500D6CFC400B6B0A40000000000000000000000
    00000000000000000000C4C0B700AEA99C00AEA89C00AEA89C00AEA89C00AEA8
    9C00AEA89C00AEA89C00AEA99C00C4C0B700000000000000000000000000F7EF
    FFFFC007FFFF8001FFFF8001FFFF0000FFFF8001FFFF8001FFFF8001FFFF8001
    FFFF8001FFFF8001FFFF8001FFFF8001FFFF8001FFFFC003FFFFE007FFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    486
    357)
  PixelsPerInch = 96
  TextHeight = 13
  object GBUpdater: TGroupBox
    Left = 8
    Top = 8
    Width = 472
    Height = 145
    Anchors = [akLeft, akTop, akRight]
    Caption = ' '#1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '
    TabOrder = 0
    DesignSize = (
      472
      145)
    object LAmountDesc: TLabel
      Left = 16
      Top = 56
      Width = 37
      Height = 13
      Caption = #1054#1073#1098#1077#1084':'
    end
    object LAmount: TLabel
      Left = 59
      Top = 56
      Width = 30
      Height = 13
      Caption = '10000'
    end
    object LSpeedDesc: TLabel
      Left = 16
      Top = 75
      Width = 52
      Height = 13
      Caption = #1057#1082#1086#1088#1086#1089#1090#1100':'
    end
    object LSpeed: TLabel
      Left = 74
      Top = 75
      Width = 49
      Height = 13
      Caption = '1000 '#1050#1073'/c'
    end
    object LFileDesc: TLabel
      Left = 210
      Top = 75
      Width = 53
      Height = 13
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
    end
    object LFileDescription: TLabel
      Left = 269
      Top = 75
      Width = 62
      Height = 13
      Caption = #1053#1077' '#1080#1079#1074#1077#1089#1090#1085#1086
    end
    object LFileMD5Desc: TLabel
      Left = 210
      Top = 94
      Width = 25
      Height = 13
      Caption = 'MD5:'
    end
    object LFileMD5: TLabel
      Left = 241
      Top = 94
      Width = 62
      Height = 13
      Caption = #1053#1077' '#1080#1079#1074#1077#1089#1090#1085#1086
    end
    object LFileNameDesc: TLabel
      Left = 210
      Top = 56
      Width = 58
      Height = 13
      Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072':'
    end
    object LFileName: TLabel
      Left = 274
      Top = 56
      Width = 62
      Height = 13
      Caption = #1053#1077' '#1080#1079#1074#1077#1089#1090#1085#1086
    end
    object LStatus: TLabel
      Left = 17
      Top = 21
      Width = 322
      Height = 13
      Caption = #1053#1072#1078#1084#1080#1090#1077' '#1082#1085#1086#1087#1082#1091' "'#1054#1073#1085#1086#1074#1080#1090#1100'" '#1076#1083#1103' '#1085#1072#1095#1072#1083#1072' '#1087#1088#1086#1094#1077#1089#1089#1072' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103'.'
    end
    object ProgressBarDownloads: TProgressBar
      Left = 16
      Top = 40
      Width = 444
      Height = 10
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object ButtonSettings: TButton
      Left = 97
      Top = 109
      Width = 75
      Height = 25
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      TabOrder = 2
      OnClick = ButtonSettingsClick
    end
    object ButtonUpdate: TButton
      Left = 16
      Top = 109
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 1
      OnClick = ButtonUpdateStartClick
    end
  end
  object SettingsPageControl: TPageControl
    Left = 8
    Top = 159
    Width = 472
    Height = 193
    ActivePage = TabSheetSettings
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    object TabSheetSettings: TTabSheet
      Caption = #1054#1073#1097#1080#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
      ImageIndex = 2
      object GBSettings: TGroupBox
        Left = 3
        Top = 0
        Width = 458
        Height = 161
        Caption = ' '#1054#1073#1097#1080#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
        TabOrder = 0
        object LLanguage: TLabel
          Left = 16
          Top = 81
          Width = 88
          Height = 13
          Caption = #1071#1079#1099#1082' '#1087#1088#1086#1075#1088#1072#1084#1084#1099':'
        end
        object LIMClientType: TLabel
          Left = 16
          Top = 27
          Width = 56
          Height = 13
          Caption = 'IM-'#1082#1083#1080#1077#1085#1090':'
        end
        object LDBType: TLabel
          Left = 16
          Top = 54
          Width = 39
          Height = 13
          Caption = #1058#1080#1087' '#1041#1044':'
        end
        object CBLang: TComboBox
          Left = 110
          Top = 78
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = CBLangChange
        end
        object CBIMClientType: TComboBox
          Left = 110
          Top = 24
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnChange = CBIMClientTypeChange
        end
        object CBDBType: TComboBox
          Left = 110
          Top = 51
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 2
          OnChange = CBDBTypeChange
        end
      end
    end
    object TabSheetConnectSettings: TTabSheet
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
      DesignSize = (
        464
        165)
      object GBConnectSettings: TGroupBox
        Left = 3
        Top = 0
        Width = 458
        Height = 161
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' '
        TabOrder = 0
        object LProxyAddress: TLabel
          Left = 16
          Top = 47
          Width = 118
          Height = 13
          Caption = #1040#1076#1088#1077#1089' '#1087#1088#1086#1082#1089#1080'-'#1089#1077#1088#1074#1077#1088#1072':'
        end
        object LProxyPort: TLabel
          Left = 267
          Top = 48
          Width = 29
          Height = 13
          Caption = #1055#1086#1088#1090':'
        end
        object LProxyUser: TLabel
          Left = 16
          Top = 98
          Width = 76
          Height = 13
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
        end
        object LProxyUserPasswd: TLabel
          Left = 16
          Top = 125
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object CBUseProxy: TCheckBox
          Left = 16
          Top = 24
          Width = 193
          Height = 17
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1088#1086#1082#1089#1080'-'#1089#1077#1088#1074#1077#1088
          TabOrder = 0
          OnClick = CBUseProxyClick
        end
        object EProxyAddress: TEdit
          Left = 140
          Top = 44
          Width = 121
          Height = 21
          TabOrder = 1
          Text = '127.0.0.1'
        end
        object EProxyPort: TEdit
          Left = 302
          Top = 44
          Width = 73
          Height = 21
          MaxLength = 5
          NumbersOnly = True
          TabOrder = 2
          Text = '3128'
        end
        object EProxyUser: TEdit
          Left = 98
          Top = 95
          Width = 163
          Height = 21
          TabOrder = 3
        end
        object CBProxyAuth: TCheckBox
          Left = 16
          Top = 71
          Width = 233
          Height = 17
          Caption = #1055#1088#1086#1082#1089#1080'-'#1089#1077#1088#1074#1077#1088' '#1090#1088#1077#1073#1091#1077#1090' '#1072#1074#1090#1086#1088#1080#1079#1072#1094#1080#1102
          TabOrder = 4
          OnClick = CBProxyAuthClick
        end
        object EProxyUserPasswd: TEdit
          Left = 98
          Top = 122
          Width = 163
          Height = 21
          PasswordChar = '*'
          TabOrder = 5
        end
      end
    end
    object TabSheetLog: TTabSheet
      Caption = #1051#1086#1075#1080
      ImageIndex = 1
      DesignSize = (
        464
        165)
      object LogMemo: TMemo
        Left = 3
        Top = 3
        Width = 458
        Height = 159
        Anchors = [akLeft, akTop, akRight, akBottom]
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object IMDownloader1: TIMDownloader
    OnError = IMDownloader1Error
    OnAccepted = IMDownloader1Accepted
    OnHeaders = IMDownloader1Headers
    OnDownloading = IMDownloader1Downloading
    OnStartDownload = IMDownloader1StartDownload
    OnBreak = IMDownloader1Break
    Left = 384
    Top = 112
  end
end
