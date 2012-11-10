object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 391
  ClientWidth = 797
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
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SettingsPageControl: TPageControl
    Left = 167
    Top = 6
    Width = 622
    Height = 346
    ActivePage = AboutTabSheet
    TabOrder = 1
    object MainTabSheet: TTabSheet
      Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
      DesignSize = (
        614
        318)
      object DBGroupBox: TGroupBox
        Left = 3
        Top = 1
        Width = 608
        Height = 314
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' '#1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093' '
        TabOrder = 0
        object LDBType: TLabel
          Left = 16
          Top = 50
          Width = 39
          Height = 13
          Caption = #1058#1080#1087' '#1041#1044':'
        end
        object LDBAddress: TLabel
          Left = 16
          Top = 77
          Width = 96
          Height = 13
          Caption = #1040#1076#1088#1077#1089' '#1089#1077#1088#1074#1077#1088#1072' '#1041#1044':'
        end
        object LDBPort: TLabel
          Left = 16
          Top = 104
          Width = 90
          Height = 13
          Caption = #1055#1086#1088#1090' '#1089#1077#1088#1074#1077#1088#1072' '#1041#1044':'
        end
        object LDBName: TLabel
          Left = 16
          Top = 131
          Width = 40
          Height = 13
          Caption = #1048#1084#1103' '#1041#1044':'
        end
        object LDBLogin: TLabel
          Left = 16
          Top = 158
          Width = 34
          Height = 13
          Caption = #1051#1086#1075#1080#1085':'
        end
        object LDBPasswd: TLabel
          Left = 16
          Top = 185
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object LDBConnectMethod: TLabel
          Left = 16
          Top = 23
          Width = 107
          Height = 13
          Caption = #1052#1077#1090#1086#1076' '#1087#1086#1076#1082#1083'-'#1103' '#1082' '#1041#1044':'
        end
        object LDBReconnectCount: TLabel
          Left = 16
          Top = 212
          Width = 171
          Height = 13
          Caption = #1050#1086#1083'. '#1087#1086#1087#1099#1090#1086#1082' '#1087#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103':'
        end
        object LDBReconnectInterval: TLabel
          Left = 16
          Top = 239
          Width = 184
          Height = 13
          Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1087#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' ('#1084#1089#1077#1082'):'
        end
        object CBDBType: TComboBox
          Left = 136
          Top = 47
          Width = 174
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnChange = CBDBTypeChange
          Items.Strings = (
            'MySQL'
            'PostgreSQL'
            'SQLite')
        end
        object EDBAddress: TEdit
          Left = 136
          Top = 74
          Width = 174
          Height = 21
          TabOrder = 2
        end
        object EDBPort: TEdit
          Left = 136
          Top = 101
          Width = 174
          Height = 21
          NumbersOnly = True
          TabOrder = 3
        end
        object EDBName: TEdit
          Left = 136
          Top = 128
          Width = 174
          Height = 21
          TabOrder = 4
        end
        object EDBUserName: TEdit
          Left = 136
          Top = 155
          Width = 174
          Height = 21
          TabOrder = 5
        end
        object EDBPasswd: TEdit
          Left = 136
          Top = 182
          Width = 174
          Height = 21
          PasswordChar = '*'
          TabOrder = 6
        end
        object CBConnectMethod: TComboBox
          Left = 136
          Top = 20
          Width = 174
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemIndex = 0
          TabOrder = 0
          Text = #1053#1072#1087#1088#1103#1084#1091#1102
          Items.Strings = (
            #1053#1072#1087#1088#1103#1084#1091#1102
            #1063#1077#1088#1077#1079' HTTP '#1087#1088#1086#1082#1089#1080)
        end
        object TestConnectionButton: TButton
          Left = 136
          Top = 268
          Width = 174
          Height = 25
          Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
          ImageIndex = 29
          Images = MainForm.ImageList_Main
          TabOrder = 9
          OnClick = TestConnectionButtonClick
        end
        object EDBReconnectCount: TEdit
          Left = 216
          Top = 209
          Width = 94
          Height = 21
          MaxLength = 2
          NumbersOnly = True
          TabOrder = 7
          Text = '5'
        end
        object EDBReconnectInterval: TEdit
          Left = 216
          Top = 236
          Width = 94
          Height = 21
          MaxLength = 4
          NumbersOnly = True
          TabOrder = 8
          Text = '1500'
        end
      end
    end
    object SyncTabSheet: TTabSheet
      Caption = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1103
      ImageIndex = 1
      DesignSize = (
        614
        318)
      object SyncGroupBox: TGroupBox
        Left = 3
        Top = 1
        Width = 608
        Height = 80
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1057#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1103' '#1080#1089#1090#1086#1088#1080#1080' '
        TabOrder = 0
        object LSyncMethod: TLabel
          Left = 16
          Top = 23
          Width = 116
          Height = 13
          Caption = #1052#1077#1090#1086#1076' '#1089#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1080':'
        end
        object LSyncInterval: TLabel
          Left = 16
          Top = 50
          Width = 132
          Height = 13
          Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1089#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1080':'
          Enabled = False
        end
        object CBSyncMethod: TComboBox
          Left = 154
          Top = 20
          Width = 151
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = CBSyncMethodChange
          Items.Strings = (
            #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080#1081
            #1042#1088#1091#1095#1085#1091#1102
            #1055#1086' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1102)
        end
        object CBSyncInterval: TComboBox
          Left = 154
          Top = 47
          Width = 151
          Height = 21
          Style = csDropDownList
          Enabled = False
          TabOrder = 1
          OnChange = CBSyncIntervalChange
          Items.Strings = (
            #1050#1072#1078#1076#1099#1077' 5 '#1084#1080#1085#1091#1090
            #1050#1072#1078#1076#1099#1077' 10 '#1084#1080#1085#1091#1090
            #1050#1072#1078#1076#1099#1077' 20 '#1084#1080#1085#1091#1090
            #1050#1072#1078#1076#1099#1077' 30 '#1084#1080#1085#1091#1090
            #1055#1088#1080' '#1074#1099#1093#1086#1076#1077' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
            #1055#1086#1089#1083#1077' '#1082#1072#1078#1076'. 10-'#1075#1086' '#1089#1086#1086#1073'-'#1103
            #1055#1086#1089#1083#1077' '#1082#1072#1078#1076'. 20-'#1075#1086' '#1089#1086#1086#1073'-'#1103
            #1055#1086#1089#1083#1077' '#1082#1072#1078#1076'. 30-'#1075#1086' '#1089#1086#1086#1073'-'#1103
            #1050#1072#1078#1076#1099#1077' N '#1084#1080#1085#1091#1090
            #1055#1086#1089#1083#1077' '#1082#1072#1078#1076'. N-'#1075#1086' '#1089#1086#1086#1073'-'#1103)
        end
      end
      object GBSyncCustomInterval: TGroupBox
        Left = 3
        Top = 87
        Width = 608
        Height = 80
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1048#1085#1090#1077#1088#1074#1072#1083#1099' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '
        Enabled = False
        TabOrder = 1
        object LTimeInterval: TLabel
          Left = 16
          Top = 23
          Width = 146
          Height = 13
          Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080' ('#1084#1080#1085'.):'
          Enabled = False
        end
        object LMsgCountInterval: TLabel
          Left = 16
          Top = 50
          Width = 152
          Height = 13
          Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1087#1086' '#1082#1086#1083'. '#1089#1086#1086#1073#1097#1077#1085#1080#1081':'
          Enabled = False
        end
        object ETimeInterval: TSpinEdit
          Left = 176
          Top = 17
          Width = 129
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object EMsgCountInterval: TSpinEdit
          Left = 176
          Top = 45
          Width = 129
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 0
        end
      end
      object GBAddon: TGroupBox
        Left = 3
        Top = 173
        Width = 608
        Height = 142
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086' '
        TabOrder = 2
        object CBSyncWhenExit: TCheckBox
          Left = 16
          Top = 24
          Width = 393
          Height = 17
          Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086' '#1089#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1080#1089#1090#1086#1088#1080#1102' '#1087#1088#1080' '#1074#1099#1093#1086#1076#1077' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
          TabOrder = 0
        end
        object CBSkypeSupportEnable: TCheckBox
          Left = 16
          Top = 47
          Width = 393
          Height = 17
          Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1087#1086#1076#1076#1077#1088#1078#1082#1091' Skype'
          TabOrder = 1
          OnClick = CBSkypeSupportEnableClick
        end
        object CBAutoStartup: TCheckBox
          Left = 16
          Top = 70
          Width = 393
          Height = 17
          Caption = #1047#1072#1075#1088#1091#1078#1072#1090#1100' HistoryToDBSync '#1087#1088#1080' '#1089#1090#1072#1088#1090#1077' Windows'
          Enabled = False
          TabOrder = 2
        end
        object CBRunSkype: TCheckBox
          Left = 16
          Top = 93
          Width = 393
          Height = 17
          Caption = #1047#1072#1087#1091#1089#1082#1072#1090#1100' Skype '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077' HistoryToDBSync'
          Enabled = False
          TabOrder = 3
        end
        object CBExitSkype: TCheckBox
          Left = 16
          Top = 116
          Width = 393
          Height = 17
          Caption = #1042#1099#1093#1086#1076#1080#1090#1100' '#1080#1079' Skype '#1087#1088#1080' '#1079#1072#1082#1088#1099#1090#1080#1080' HistoryToDBSync'
          Enabled = False
          TabOrder = 4
        end
      end
    end
    object InterfaceTabSheet: TTabSheet
      Caption = #1048#1085#1090#1077#1088#1092#1077#1081#1089
      ImageIndex = 9
      object GBAlphaBlend: TGroupBox
        Left = 3
        Top = 3
        Width = 409
        Height = 58
        Caption = ' '#1055#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100' '#1086#1082#1086#1085' '
        TabOrder = 0
        object AlphaBlendVar: TLabel
          Left = 290
          Top = 39
          Width = 18
          Height = 13
          Caption = '255'
        end
        object CBAlphaBlend: TCheckBox
          Left = 16
          Top = 24
          Width = 177
          Height = 17
          Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1087#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100' '#1086#1082#1086#1085
          TabOrder = 0
          OnClick = CBAlphaBlendClick
        end
        object AlphaBlendTrackBar: TTrackBar
          Left = 210
          Top = 18
          Width = 186
          Height = 23
          Ctl3D = True
          Max = 255
          ParentCtl3D = False
          Frequency = 20
          ShowSelRange = False
          TabOrder = 1
          ThumbLength = 12
          TickMarks = tmTopLeft
          OnChange = AlphaBlendTrackBarChange
        end
      end
      object GBLang: TGroupBox
        Left = 3
        Top = 67
        Width = 193
        Height = 57
        Caption = ' '#1071#1079#1099#1082' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '
        TabOrder = 1
        object CBLang: TComboBox
          Left = 16
          Top = 24
          Width = 161
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = CBLangChange
        end
      end
    end
    object InformTabSheet: TTabSheet
      Caption = #1057#1086#1073#1099#1090#1080#1103
      ImageIndex = 2
      DesignSize = (
        614
        318)
      object EventsGroupBox: TGroupBox
        Left = 3
        Top = 1
        Width = 608
        Height = 312
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' '#1057#1086#1073#1099#1090#1080#1103' '
        TabOrder = 0
        object LNumLastHistoryMsg: TLabel
          Left = 85
          Top = 189
          Width = 500
          Height = 13
          AutoSize = False
          Caption = 
            #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1087#1086#1089#1083#1077#1076#1085#1080#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081' '#1076#1083#1103' '#1087#1086#1082#1072#1079#1072' '#1074' '#1086#1082#1085#1077' '#1080#1089#1090#1086#1088#1080#1080' '#1087#1077#1088#1077#1087#1080#1089 +
            #1082#1080
          WordWrap = True
        end
        object LErrLogSize: TLabel
          Left = 85
          Top = 217
          Width = 252
          Height = 13
          Caption = #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1099#1081' '#1088#1072#1079#1084#1077#1088' '#1083#1086#1075'-'#1092#1072#1081#1083#1072' '#1086#1096#1080#1073#1086#1082' ('#1050#1073#1072#1081#1090')'
        end
        object CBAni: TCheckBox
          Left = 15
          Top = 23
          Width = 281
          Height = 17
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1074#1089#1087#1083#1099#1074#1072#1102#1097#1080#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
          TabOrder = 0
          OnClick = CBAniClick
        end
        object CBWriteErrLog: TCheckBox
          Left = 15
          Top = 43
          Width = 281
          Height = 17
          Caption = #1055#1080#1089#1072#1090#1100' '#1086#1096#1080#1073#1082#1080' '#1074' '#1083#1086#1075'-'#1092#1072#1081#1083
          TabOrder = 1
          OnClick = CBWriteErrLogClick
        end
        object CBHideSyncIcon: TCheckBox
          Left = 15
          Top = 83
          Width = 562
          Height = 17
          Caption = #1057#1082#1088#1099#1090#1100' '#1080#1082#1086#1085#1082#1091' HistoryToDBSync '#1080#1079' '#1090#1088#1077#1103
          TabOrder = 3
          OnClick = CBHideSyncIconClick
        end
        object CBShowPluginButton: TCheckBox
          Left = 15
          Top = 103
          Width = 570
          Height = 17
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1085#1086#1087#1082#1091' '#1087#1083#1072#1075#1080#1085#1072' '#1074' '#1087#1072#1085#1077#1083#1100' '#1084#1086#1076#1091#1083#1077#1081
          TabOrder = 4
        end
        object ENumLastHistoryMsg: TSpinEdit
          Left = 15
          Top = 186
          Width = 64
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 8
          Value = 0
        end
        object CBAddSpecialContact: TCheckBox
          Left = 15
          Top = 123
          Width = 570
          Height = 17
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1087#1077#1094'-'#1082#1086#1085#1090#1072#1082#1090' ('#1090#1086#1083#1100#1082#1086' '#1076#1083#1103' IM-'#1082#1083#1080#1077#1085#1090#1072' QIP 2012)'
          TabOrder = 5
        end
        object SEErrLogSize: TSpinEdit
          Left = 15
          Top = 214
          Width = 64
          Height = 22
          MaxValue = 1024
          MinValue = 1
          TabOrder = 9
          Value = 1
        end
        object CBBlockSpamMsg: TCheckBox
          Left = 15
          Top = 143
          Width = 570
          Height = 17
          Caption = 
            #1053#1077' '#1079#1072#1087#1080#1089#1099#1074#1072#1090#1100' '#1074' '#1041#1044' '#1089#1086#1086#1073#1097#1077#1085#1080#1103' '#1087#1086#1084#1077#1095#1077#1085#1099#1077' '#1082#1072#1082' '#1089#1087#1072#1084' ('#1090#1086#1083#1100#1082#1086' '#1076#1083#1103' IM-'#1082 +
            #1083#1080#1077#1085#1090#1072' QIP 2012)'
          TabOrder = 6
        end
        object CBExPrivateChatName: TCheckBox
          Left = 15
          Top = 163
          Width = 570
          Height = 17
          Caption = 
            #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1088#1072#1089#1096#1080#1088#1077#1085#1085#1086#1077' '#1080#1084#1103' '#1076#1083#1103' '#1087#1088#1080#1074#1072#1090#1085#1099#1093' '#1095#1072#1090#1086#1074' ('#1048#1084#1103' '#1095#1072#1090#1072' / '#1053#1080#1082 +
            ' '#1089#1086#1073#1077#1089#1077#1076#1085#1080#1082#1072')'
          TabOrder = 7
        end
        object CBWriteDebugLog: TCheckBox
          Left = 15
          Top = 63
          Width = 562
          Height = 17
          Caption = #1042#1077#1089#1090#1080' '#1088#1072#1089#1096#1080#1088#1077#1085#1085#1099#1081' '#1083#1086#1075' '#1088#1072#1073#1086#1090#1099' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' (Debug-'#1088#1077#1078#1080#1084')'
          TabOrder = 2
        end
      end
    end
    object FontsTabSheet: TTabSheet
      Caption = #1064#1088#1080#1092#1090#1099' '#1080' '#1076#1088'.'
      ImageIndex = 4
      DesignSize = (
        614
        318)
      object GBMessageFonts: TGroupBox
        Left = 3
        Top = 1
        Width = 608
        Height = 160
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1064#1088#1080#1092#1090#1099' '
        TabOrder = 0
        object LIncommingMesTitle: TLabel
          Left = 16
          Top = 22
          Width = 172
          Height = 13
          Caption = #1064#1088#1080#1092#1090' '#1079#1072#1075#1086#1083#1086#1074#1082#1072' '#1076#1083#1103' '#1074#1093#1086#1076#1103#1097#1080#1093':'
        end
        object LOutgoingMesTitle: TLabel
          Left = 16
          Top = 50
          Width = 177
          Height = 13
          Caption = #1064#1088#1080#1092#1090' '#1079#1072#1075#1086#1083#1086#1074#1082#1072' '#1076#1083#1103' '#1080#1089#1093#1086#1076#1103#1097#1080#1093':'
        end
        object LOutgoingMes: TLabel
          Left = 16
          Top = 106
          Width = 181
          Height = 13
          Caption = #1064#1088#1080#1092#1090' '#1076#1083#1103' '#1080#1089#1093#1086#1076#1103#1097#1080#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081':'
        end
        object LIncommingMes: TLabel
          Left = 16
          Top = 78
          Width = 176
          Height = 13
          Caption = #1064#1088#1080#1092#1090' '#1076#1083#1103' '#1074#1093#1086#1076#1103#1097#1080#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081':'
        end
        object FontInTitle: TSpeedButton
          Left = 260
          Top = 18
          Width = 181
          Height = 22
          Caption = 'FontInTitle'
          Flat = True
          Margin = 5
          OnClick = FontInTitleClick
        end
        object FontOutTitle: TSpeedButton
          Left = 260
          Top = 46
          Width = 181
          Height = 22
          Caption = 'FontOutTitle'
          Flat = True
          Margin = 5
          OnClick = FontOutTitleClick
        end
        object FontInBody: TSpeedButton
          Left = 260
          Top = 74
          Width = 181
          Height = 22
          Caption = 'FontInBody'
          Flat = True
          Margin = 5
          OnClick = FontInBodyClick
        end
        object FontOutBody: TSpeedButton
          Left = 260
          Top = 102
          Width = 181
          Height = 22
          Caption = 'FontOutBody'
          Flat = True
          Margin = 5
          OnClick = FontOutBodyClick
        end
        object LServiceMes: TLabel
          Left = 16
          Top = 134
          Width = 178
          Height = 13
          Caption = #1064#1088#1080#1092#1090' '#1076#1083#1103' '#1089#1077#1088#1074#1080#1089#1085#1099#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081':'
        end
        object FontService: TSpeedButton
          Left = 260
          Top = 130
          Width = 181
          Height = 22
          Caption = 'FontService'
          Flat = True
          Margin = 5
          OnClick = FontServiceClick
        end
        object FontColorInTitle: TJvOfficeColorButton
          Left = 219
          Top = 18
          Width = 35
          Height = 22
          ColorDialogOptions = [cdFullOpen]
          TabOrder = 0
          SelectedColor = clDefault
          HotTrackFont.Charset = DEFAULT_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
          Properties.NoneColorCaption = 'No Color'
          Properties.DefaultColorCaption = 'Automatic'
          Properties.CustomColorCaption = 'Other Colors...'
          Properties.NoneColorHint = 'No Color'
          Properties.DefaultColorHint = 'Automatic'
          Properties.CustomColorHint = 'Other Colors...'
          Properties.NoneColorFont.Charset = DEFAULT_CHARSET
          Properties.NoneColorFont.Color = clWindowText
          Properties.NoneColorFont.Height = -11
          Properties.NoneColorFont.Name = 'Tahoma'
          Properties.NoneColorFont.Style = []
          Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
          Properties.DefaultColorFont.Color = clWindowText
          Properties.DefaultColorFont.Height = -11
          Properties.DefaultColorFont.Name = 'Tahoma'
          Properties.DefaultColorFont.Style = []
          Properties.CustomColorFont.Charset = DEFAULT_CHARSET
          Properties.CustomColorFont.Color = clWindowText
          Properties.CustomColorFont.Height = -11
          Properties.CustomColorFont.Name = 'Tahoma'
          Properties.CustomColorFont.Style = []
          Properties.FloatWindowCaption = 'Color Window'
          Properties.DragBarHint = 'Drag to float'
          OnColorChange = FontColorInTitleColorChange
        end
        object FontColorOutTitle: TJvOfficeColorButton
          Left = 219
          Top = 46
          Width = 35
          Height = 22
          ColorDialogOptions = [cdFullOpen]
          TabOrder = 1
          SelectedColor = clDefault
          HotTrackFont.Charset = DEFAULT_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
          Properties.NoneColorCaption = 'No Color'
          Properties.DefaultColorCaption = 'Automatic'
          Properties.CustomColorCaption = 'Other Colors...'
          Properties.NoneColorHint = 'No Color'
          Properties.DefaultColorHint = 'Automatic'
          Properties.CustomColorHint = 'Other Colors...'
          Properties.NoneColorFont.Charset = DEFAULT_CHARSET
          Properties.NoneColorFont.Color = clWindowText
          Properties.NoneColorFont.Height = -11
          Properties.NoneColorFont.Name = 'Tahoma'
          Properties.NoneColorFont.Style = []
          Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
          Properties.DefaultColorFont.Color = clWindowText
          Properties.DefaultColorFont.Height = -11
          Properties.DefaultColorFont.Name = 'Tahoma'
          Properties.DefaultColorFont.Style = []
          Properties.CustomColorFont.Charset = DEFAULT_CHARSET
          Properties.CustomColorFont.Color = clWindowText
          Properties.CustomColorFont.Height = -11
          Properties.CustomColorFont.Name = 'Tahoma'
          Properties.CustomColorFont.Style = []
          Properties.FloatWindowCaption = 'Color Window'
          Properties.DragBarHint = 'Drag to float'
          OnColorChange = FontColorOutTitleColorChange
        end
        object FontColorInBody: TJvOfficeColorButton
          Left = 219
          Top = 74
          Width = 35
          Height = 22
          ColorDialogOptions = [cdFullOpen]
          TabOrder = 2
          SelectedColor = clDefault
          HotTrackFont.Charset = DEFAULT_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
          Properties.NoneColorCaption = 'No Color'
          Properties.DefaultColorCaption = 'Automatic'
          Properties.CustomColorCaption = 'Other Colors...'
          Properties.NoneColorHint = 'No Color'
          Properties.DefaultColorHint = 'Automatic'
          Properties.CustomColorHint = 'Other Colors...'
          Properties.NoneColorFont.Charset = DEFAULT_CHARSET
          Properties.NoneColorFont.Color = clWindowText
          Properties.NoneColorFont.Height = -11
          Properties.NoneColorFont.Name = 'Tahoma'
          Properties.NoneColorFont.Style = []
          Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
          Properties.DefaultColorFont.Color = clWindowText
          Properties.DefaultColorFont.Height = -11
          Properties.DefaultColorFont.Name = 'Tahoma'
          Properties.DefaultColorFont.Style = []
          Properties.CustomColorFont.Charset = DEFAULT_CHARSET
          Properties.CustomColorFont.Color = clWindowText
          Properties.CustomColorFont.Height = -11
          Properties.CustomColorFont.Name = 'Tahoma'
          Properties.CustomColorFont.Style = []
          Properties.FloatWindowCaption = 'Color Window'
          Properties.DragBarHint = 'Drag to float'
          OnColorChange = FontColorInBodyColorChange
        end
        object FontColorOutBody: TJvOfficeColorButton
          Left = 219
          Top = 102
          Width = 35
          Height = 22
          ColorDialogOptions = [cdFullOpen]
          TabOrder = 3
          SelectedColor = clDefault
          HotTrackFont.Charset = DEFAULT_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
          Properties.NoneColorCaption = 'No Color'
          Properties.DefaultColorCaption = 'Automatic'
          Properties.CustomColorCaption = 'Other Colors...'
          Properties.NoneColorHint = 'No Color'
          Properties.DefaultColorHint = 'Automatic'
          Properties.CustomColorHint = 'Other Colors...'
          Properties.NoneColorFont.Charset = DEFAULT_CHARSET
          Properties.NoneColorFont.Color = clWindowText
          Properties.NoneColorFont.Height = -11
          Properties.NoneColorFont.Name = 'Tahoma'
          Properties.NoneColorFont.Style = []
          Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
          Properties.DefaultColorFont.Color = clWindowText
          Properties.DefaultColorFont.Height = -11
          Properties.DefaultColorFont.Name = 'Tahoma'
          Properties.DefaultColorFont.Style = []
          Properties.CustomColorFont.Charset = DEFAULT_CHARSET
          Properties.CustomColorFont.Color = clWindowText
          Properties.CustomColorFont.Height = -11
          Properties.CustomColorFont.Name = 'Tahoma'
          Properties.CustomColorFont.Style = []
          Properties.FloatWindowCaption = 'Color Window'
          Properties.DragBarHint = 'Drag to float'
          OnColorChange = FontColorOutBodyColorChange
        end
        object FontColorService: TJvOfficeColorButton
          Left = 219
          Top = 130
          Width = 35
          Height = 22
          ColorDialogOptions = [cdFullOpen]
          TabOrder = 4
          SelectedColor = clDefault
          HotTrackFont.Charset = DEFAULT_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
          Properties.NoneColorCaption = 'No Color'
          Properties.DefaultColorCaption = 'Automatic'
          Properties.CustomColorCaption = 'Other Colors...'
          Properties.NoneColorHint = 'No Color'
          Properties.DefaultColorHint = 'Automatic'
          Properties.CustomColorHint = 'Other Colors...'
          Properties.NoneColorFont.Charset = DEFAULT_CHARSET
          Properties.NoneColorFont.Color = clWindowText
          Properties.NoneColorFont.Height = -11
          Properties.NoneColorFont.Name = 'Tahoma'
          Properties.NoneColorFont.Style = []
          Properties.DefaultColorFont.Charset = DEFAULT_CHARSET
          Properties.DefaultColorFont.Color = clWindowText
          Properties.DefaultColorFont.Height = -11
          Properties.DefaultColorFont.Name = 'Tahoma'
          Properties.DefaultColorFont.Style = []
          Properties.CustomColorFont.Charset = DEFAULT_CHARSET
          Properties.CustomColorFont.Color = clWindowText
          Properties.CustomColorFont.Height = -11
          Properties.CustomColorFont.Name = 'Tahoma'
          Properties.CustomColorFont.Style = []
          Properties.FloatWindowCaption = 'Color Window'
          Properties.DragBarHint = 'Drag to float'
          OnColorChange = FontColorServiceColorChange
        end
      end
      object TitleSpacingBox: TGroupBox
        Left = 3
        Top = 167
        Width = 205
        Height = 74
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1076#1083#1103' '#1079#1072#1075#1086#1083#1086#1074#1082#1072' '
        TabOrder = 1
        object LTitleSpacingBefore: TLabel
          Left = 16
          Top = 20
          Width = 99
          Height = 13
          Caption = #1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1087#1077#1088#1077#1076': '
          FocusControl = TitleSpaceBefore
        end
        object LTitleSpacingAfter: TLabel
          Left = 16
          Top = 44
          Width = 94
          Height = 13
          Caption = #1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1087#1086#1089#1083#1077':'
          FocusControl = TitleSpaceAfter
        end
        object TitleSpaceBefore: TSpinEdit
          Left = 137
          Top = 17
          Width = 57
          Height = 22
          MaxValue = 100
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object TitleSpaceAfter: TSpinEdit
          Left = 137
          Top = 41
          Width = 57
          Height = 22
          MaxValue = 100
          MinValue = 0
          TabOrder = 1
          Value = 0
        end
      end
      object MessagesSpacingBox: TGroupBox
        Left = 214
        Top = 167
        Width = 198
        Height = 74
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1076#1083#1103' '#1090#1077#1082#1089#1090#1072' '
        TabOrder = 2
        object LMessagesSpacingBefore: TLabel
          Left = 16
          Top = 20
          Width = 99
          Height = 13
          Caption = #1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1087#1077#1088#1077#1076': '
          FocusControl = MessagesSpaceBefore
        end
        object LMessagesSpacingAfter: TLabel
          Left = 16
          Top = 44
          Width = 94
          Height = 13
          Caption = #1056#1072#1089#1089#1090#1086#1103#1085#1080#1077' '#1087#1086#1089#1083#1077':'
          FocusControl = MessagesSpaceAfter
        end
        object MessagesSpaceBefore: TSpinEdit
          Left = 128
          Top = 17
          Width = 57
          Height = 22
          MaxValue = 100
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object MessagesSpaceAfter: TSpinEdit
          Left = 128
          Top = 41
          Width = 57
          Height = 22
          MaxValue = 100
          MinValue = 0
          TabOrder = 1
          Value = 0
        end
      end
      object CBAutoScroll: TCheckBox
        Left = 3
        Top = 247
        Width = 205
        Height = 17
        Caption = #1040#1074#1090#1086#1089#1082#1088#1086#1083#1083#1080#1085#1075' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
        TabOrder = 3
      end
    end
    object HotKeyTabSheet: TTabSheet
      Caption = #1043#1086#1088#1103#1095#1080#1077' '#1082#1083#1072#1074#1080#1096#1080
      ImageIndex = 6
      DesignSize = (
        614
        318)
      object GBHotKey: TGroupBox
        Left = 3
        Top = 32
        Width = 608
        Height = 283
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' '#1043#1086#1088#1103#1095#1080#1077' '#1082#1083#1072#1074#1080#1096#1080' '
        TabOrder = 0
        Visible = False
        DesignSize = (
          608
          283)
        object HotKetStringGrid: TStringGrid
          Left = 16
          Top = 24
          Width = 577
          Height = 113
          Anchors = [akLeft, akTop, akRight]
          ColCount = 2
          DefaultColWidth = 150
          DefaultRowHeight = 18
          DrawingStyle = gdsClassic
          FixedCols = 0
          RowCount = 4
          Options = [goFixedVertLine, goFixedHorzLine, goRangeSelect, goColSizing, goRowSelect]
          TabOrder = 0
          OnSelectCell = HotKetStringGridSelectCell
          ColWidths = (
            296
            133)
        end
        object IMHotKey: THotKey
          Left = 16
          Top = 146
          Width = 153
          Height = 19
          HotKey = 32833
          TabOrder = 1
        end
        object SetHotKeyButton: TButton
          Left = 182
          Top = 143
          Width = 91
          Height = 25
          Caption = #1053#1072#1079#1085#1072#1095#1080#1090#1100
          ImageIndex = 45
          Images = MainForm.ImageList_Main
          TabOrder = 2
          OnClick = SetHotKeyButtonClick
        end
        object DeleteHotKeyButton: TButton
          Left = 276
          Top = 143
          Width = 93
          Height = 25
          Caption = #1059#1076#1072#1083#1080#1090#1100
          ImageIndex = 46
          Images = MainForm.ImageList_Main
          TabOrder = 3
          OnClick = DeleteHotKeyButtonClick
        end
      end
      object CBHotKey: TCheckBox
        Left = 3
        Top = 10
        Width = 358
        Height = 17
        Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1087#1086#1076#1076#1077#1088#1078#1082#1091' '#1075#1083#1086#1073#1072#1083#1100#1085#1099#1093' '#1075#1086#1088#1103#1095#1080#1093' '#1082#1083#1072#1074#1080#1096
        TabOrder = 1
        OnClick = CBHotKeyClick
      end
    end
    object EncryptionTabSheet: TTabSheet
      Caption = #1064#1080#1092#1088#1086#1074#1072#1085#1080#1077' '#1080#1089#1090#1086#1088#1080#1080
      ImageIndex = 1
      DesignSize = (
        614
        318)
      object GBKeys: TGroupBox
        Left = 3
        Top = 33
        Width = 608
        Height = 216
        Anchors = [akLeft, akTop, akRight]
        Caption = ' '#1050#1083#1102#1095#1080' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103' '#1085#1072' '#1089#1077#1088#1074#1077#1088#1077' '
        TabOrder = 0
        DesignSize = (
          608
          216)
        object DBGridKeys: TJvDBGrid
          Left = 8
          Top = 17
          Width = 592
          Height = 112
          Anchors = [akLeft, akTop, akRight]
          DataSource = DataSource1
          DrawingStyle = gdsClassic
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
          SelectColumnsDialogStrings.Caption = 'Select columns'
          SelectColumnsDialogStrings.OK = '&OK'
          SelectColumnsDialogStrings.NoSelectionWarning = 'At least one column must be visible!'
          EditControls = <>
          RowsHeight = 17
          TitleRowHeight = 17
          Columns = <
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'id'
              Title.Alignment = taCenter
              Title.Caption = #1053#1086#1084#1077#1088' '#1082#1083#1102#1095#1072
              Width = 75
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'status_key_text'
              Title.Alignment = taCenter
              Title.Caption = #1057#1090#1072#1090#1091#1089' '#1082#1083#1102#1095#1072
              Width = 85
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'encryption_method_text'
              Title.Alignment = taCenter
              Title.Caption = #1052#1077#1090#1086#1076' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103
              Width = 116
              Visible = True
            end>
        end
        object ButtonCreateEncryptionKey: TButton
          Left = 8
          Top = 181
          Width = 153
          Height = 25
          Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1099#1081' '#1082#1083#1102#1095
          ImageIndex = 15
          Images = MainForm.ImageList_Main
          TabOrder = 3
          OnClick = ButtonCreateEncryptionKeyClick
        end
        object ButtonGetEncryptionKey: TButton
          Left = 167
          Top = 181
          Width = 153
          Height = 25
          Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1082#1083#1102#1095#1080' '#1080#1079' '#1041#1044
          ImageIndex = 19
          Images = MainForm.ImageList_Main
          TabOrder = 4
          OnClick = ButtonGetEncryptionKeyClick
        end
        object CBSaveOnly: TCheckBox
          Left = 8
          Top = 135
          Width = 249
          Height = 17
          Caption = #1047#1072#1087#1086#1084#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100' '#1076#1086' '#1074#1099#1093#1086#1076#1072' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
          TabOrder = 1
        end
        object CBSave: TCheckBox
          Left = 8
          Top = 158
          Width = 249
          Height = 17
          Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
          TabOrder = 2
          OnClick = CBSaveClick
        end
      end
      object CBEnableEncryption: TCheckBox
        Left = 3
        Top = 10
        Width = 358
        Height = 17
        Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1077' '#1080#1089#1090#1086#1088#1080#1080' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
        TabOrder = 1
      end
    end
    object AboutTabSheet: TTabSheet
      Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      ImageIndex = 5
      object LProgramName: TLabel
        Left = 96
        Top = 16
        Width = 110
        Height = 13
        Caption = 'HistoryToDBViewer'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelCopyright: TLabel
        Left = 96
        Top = 32
        Width = 130
        Height = 13
        Caption = 'Copyright '#169' 2011-2012 by'
      end
      object LabelAuthor: TLabel
        Left = 227
        Top = 32
        Width = 80
        Height = 13
        Cursor = crHandPoint
        Caption = 'Michael Grigorev'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        OnClick = LabelAuthorClick
      end
      object LVersion: TLabel
        Left = 96
        Top = 48
        Width = 42
        Height = 13
        Caption = 'Version: '
      end
      object LVersionNum: TLabel
        Left = 138
        Top = 48
        Width = 36
        Height = 13
        Caption = '1.0.0.0'
      end
      object LLicense: TLabel
        Left = 96
        Top = 64
        Width = 42
        Height = 13
        Caption = 'License: '
      end
      object LLicenseType: TLabel
        Left = 139
        Top = 64
        Width = 30
        Height = 13
        Caption = 'GPLv3'
      end
      object LabelWeb: TLabel
        Left = 96
        Top = 80
        Width = 29
        Height = 13
        Caption = 'Web: '
      end
      object LabelWebSite: TLabel
        Left = 126
        Top = 80
        Width = 82
        Height = 13
        Cursor = crHandPoint
        Caption = 'www.im-history.ru'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        OnClick = LabelWebSiteClick
      end
      object AboutImage: TImage
        Left = 16
        Top = 10
        Width = 55
        Height = 55
        Transparent = True
      end
      object LThankYou: TLabel
        Left = 96
        Top = 99
        Width = 95
        Height = 13
        Caption = #1041#1083#1072#1075#1086#1076#1072#1088#1085#1086#1089#1090#1080':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ThankYou: TLabel
        Left = 96
        Top = 118
        Width = 305
        Height = 118
        AutoSize = False
        Caption = #1057#1087#1072#1089#1080#1073#1086' '#1074#1089#1077#1084'!'
        WordWrap = True
      end
    end
    object EncryptKeyCreateTabSheet: TTabSheet
      Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1082#1083#1102#1095#1072' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103
      ImageIndex = 7
      DesignSize = (
        614
        318)
      object GBKeyProp: TGroupBox
        Left = 3
        Top = 0
        Width = 352
        Height = 315
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' '#1057#1086#1079#1076#1072#1085#1080#1077' '#1082#1083#1102#1095#1072' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103' '
        TabOrder = 0
        object LKeyStatusTitle: TLabel
          Left = 16
          Top = 24
          Width = 76
          Height = 13
          Caption = #1057#1090#1072#1090#1091#1089' '#1082#1083#1102#1095#1072':'
        end
        object LCBEncryptionMethod: TLabel
          Left = 16
          Top = 51
          Width = 119
          Height = 13
          Caption = #1040#1083#1075#1086#1088#1080#1090#1084' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103':'
        end
        object LEncryptionKey: TLabel
          Left = 16
          Top = 133
          Width = 99
          Height = 13
          Caption = #1050#1083#1102#1095' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103':'
        end
        object LLocation: TLabel
          Left = 16
          Top = 192
          Width = 122
          Height = 13
          Caption = #1052#1077#1089#1090#1086' '#1093#1088#1072#1085#1077#1085#1080#1103' '#1082#1083#1102#1095#1072':'
        end
        object LKeyLength: TLabel
          Left = 16
          Top = 78
          Width = 130
          Height = 13
          Caption = #1044#1083#1080#1085#1072' '#1082#1083#1102#1095#1072' ('#1089#1080#1084#1074#1086#1083#1086#1074'):'
        end
        object LEncryptionKeyDesc: TLabel
          Left = 16
          Top = 158
          Width = 124
          Height = 13
          Caption = '('#1047#1072#1082#1086#1076#1080#1088#1086#1074#1072#1085' '#1074' BASE64)'
        end
        object LKeyPassword: TLabel
          Left = 16
          Top = 106
          Width = 77
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100' '#1082#1083#1102#1095#1072':'
        end
        object CBKeyStatus: TComboBox
          Left = 160
          Top = 21
          Width = 177
          Height = 21
          Style = csDropDownList
          TabOrder = 0
        end
        object CBEncryptionMethod: TComboBox
          Left = 160
          Top = 48
          Width = 177
          Height = 21
          Style = csDropDownList
          Enabled = False
          TabOrder = 1
        end
        object ButtonCreateKey: TButton
          Left = 160
          Top = 216
          Width = 177
          Height = 25
          Caption = #1057#1075#1077#1085#1077#1088#1080#1088#1086#1074#1072#1090#1100' '#1080' '#1089#1086#1093#1088#1072#1085#1080#1090#1100
          ImageIndex = 18
          Images = MainForm.ImageList_Main
          TabOrder = 2
          OnClick = ButtonCreateKeyClick
        end
        object CBLocation: TComboBox
          Left = 160
          Top = 189
          Width = 177
          Height = 21
          Style = csDropDownList
          Enabled = False
          TabOrder = 3
        end
        object EncryptionKey: TMemo
          Left = 160
          Top = 130
          Width = 177
          Height = 53
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 4
        end
        object KeyLength: TSpinEdit
          Left = 160
          Top = 75
          Width = 177
          Height = 22
          MaxValue = 1024
          MinValue = 10
          TabOrder = 5
          Value = 10
        end
        object KeyPassword: TEdit
          Left = 160
          Top = 103
          Width = 177
          Height = 21
          PasswordChar = '*'
          TabOrder = 6
        end
      end
    end
    object KeyPasswordChangeTabSheet: TTabSheet
      Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103' '#1082#1083#1102#1095#1072
      ImageIndex = 8
      DesignSize = (
        614
        318)
      object GBKeyPasswordChange: TGroupBox
        Left = 3
        Top = 0
        Width = 608
        Height = 315
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' '#1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103' '#1082#1083#1102#1095#1072' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103' '
        TabOrder = 0
        object LCurrentPassword: TLabel
          Left = 16
          Top = 24
          Width = 88
          Height = 13
          Caption = #1058#1077#1082#1091#1097#1080#1081' '#1087#1072#1088#1086#1083#1100':'
        end
        object LNewPassword: TLabel
          Left = 16
          Top = 51
          Width = 76
          Height = 13
          Caption = #1053#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100':'
        end
        object LReNewPassword: TLabel
          Left = 16
          Top = 78
          Width = 133
          Height = 13
          Caption = #1055#1086#1074#1090#1086#1088#1080#1090#1077' '#1085#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100':'
        end
        object ECurrentPassword: TEdit
          Left = 152
          Top = 21
          Width = 137
          Height = 21
          PasswordChar = '*'
          TabOrder = 0
        end
        object ENewPassword: TEdit
          Left = 152
          Top = 48
          Width = 137
          Height = 21
          PasswordChar = '*'
          TabOrder = 1
        end
        object EReNewPassword: TEdit
          Left = 152
          Top = 75
          Width = 137
          Height = 21
          PasswordChar = '*'
          TabOrder = 2
        end
        object ButtonNewKeyPassword: TButton
          Left = 152
          Top = 102
          Width = 137
          Height = 25
          Caption = #1057#1084#1077#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
          ImageIndex = 17
          Images = MainForm.ImageList_Main
          TabOrder = 3
          OnClick = ButtonNewKeyPasswordClick
        end
      end
    end
  end
  object SaveButton: TButton
    Left = 528
    Top = 358
    Width = 155
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
    ImageIndex = 10
    Images = MainForm.ImageList_Main
    TabOrder = 2
    OnClick = SaveButtonClick
  end
  object CloseButton: TButton
    Left = 689
    Top = 358
    Width = 100
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ImageIndex = 26
    Images = MainForm.ImageList_Main
    TabOrder = 3
    OnClick = CloseButtonClick
  end
  object SettingtButtonGroup: TIMButtonGroup
    Left = 8
    Top = 8
    Width = 153
    Height = 344
    BevelKind = bkTile
    BorderStyle = bsNone
    ButtonOptions = [gboFullSize, gboGroupStyle, gboShowCaptions]
    Images = MainForm.ImageList_Main
    Items = <
      item
        Caption = ' '#1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
        ImageIndex = 5
      end
      item
        Caption = ' '#1057#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1103
        ImageIndex = 122
      end
      item
        Caption = ' '#1048#1085#1090#1077#1088#1092#1077#1081#1089
        ImageIndex = 14
      end
      item
        Caption = ' '#1057#1086#1073#1099#1090#1080#1103
        ImageIndex = 50
      end
      item
        Caption = ' '#1064#1088#1080#1092#1090#1099' '#1080' '#1076#1088'.'
        ImageIndex = 59
      end
      item
        Caption = ' '#1043#1086#1088#1103#1095#1080#1077' '#1082#1083#1072#1074#1080#1096#1080
        ImageIndex = 118
      end
      item
        Caption = ' '#1064#1080#1092#1088#1086#1074#1072#1085#1080#1077' '#1080#1089#1090#1086#1088#1080#1080
        ImageIndex = 144
      end
      item
        Caption = ' '#1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
        ImageIndex = 31
      end>
    TabOrder = 0
    OnClick = SettingtButtonGroupClick
    OnKeyUp = SettingtButtonGroupKeyUp
    ButtonGradient = False
    Colors.BackColor = clWindow
    Colors.ButtonColor = clWindow
    Colors.ButtonColorFrom = clWindow
    Colors.ButtonColorTo = clWindow
    Colors.ButtonDownColor = 16772054
    Colors.ButtonDownColorFrom = 16772054
    Colors.ButtonDownColorTo = 16772054
    Colors.HotButtonColor = 16772054
    Colors.HotButtonColorFrom = 16772054
    Colors.HotButtonColorTo = 16772054
    Colors.BorderButtonColor = 6956042
    Colors.BorderButtonDownColor = 6956042
    HotTrack = False
    ButtonBorder = True
  end
  object DataSource1: TDataSource
    DataSet = VirtualTable1
    Left = 648
    Top = 152
  end
  object FontDialogInTitle: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = []
    Left = 648
    Top = 48
  end
  object FontDialogOutTitle: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = []
    Left = 712
    Top = 48
  end
  object FontDialogInBody: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = []
    Left = 648
    Top = 96
  end
  object FontDialogOutBody: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = []
    Left = 712
    Top = 88
  end
  object FontDialogService: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = []
    Left = 712
    Top = 136
  end
  object EncryptKeyPM: TPopupMenu
    Images = MainForm.ImageList_Main
    Left = 560
    Top = 48
    object StatusChangeKey: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1089#1090#1072#1090#1091#1089' '#1082#1083#1102#1095#1072
      ImageIndex = 17
      OnClick = StatusChangeKeyClick
    end
    object PasswordChangeKey: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100' '#1082#1083#1102#1095#1072
      ImageIndex = 18
      OnClick = PasswordChangeKeyClick
    end
    object DeleteKey: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1082#1083#1102#1095
      ImageIndex = 16
      OnClick = DeleteKeyClick
    end
  end
  object VirtualTable1: TVirtualTable
    Left = 568
    Top = 112
    Data = {03000000000000000000}
  end
end
