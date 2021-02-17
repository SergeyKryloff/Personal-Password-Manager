object SavePasswordForm: TSavePasswordForm
  Left = 444
  Height = 355
  Top = 251
  Width = 370
  BorderStyle = bsToolWindow
  Caption = 'Encrypt and save data'
  ClientHeight = 355
  ClientWidth = 370
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  OnCreate = FormCreate
  OnShow = PasswordEditChange
  Position = poMainFormCenter
  LCLVersion = '2.0.10.0'
  object PasswordLabel: TLabel
    Left = 8
    Height = 13
    Top = 8
    Width = 213
    Caption = '&Specify a keyword to protect passwords with:'
    FocusControl = PasswordEdit
    ParentColor = False
  end
  object ConfirmPasswordLabel: TLabel
    Left = 8
    Height = 13
    Top = 56
    Width = 104
    Caption = '&Confirm your keyword:'
    FocusControl = ConfirmPasswordEdit
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    ParentColor = False
    ParentFont = False
  end
  object PasswordEdit: TEdit
    Left = 8
    Height = 21
    Top = 24
    Width = 354
    EchoMode = emPassword
    OnChange = PasswordEditChange
    PasswordChar = '*'
    TabOrder = 0
  end
  object OkButton: TButton
    Left = 206
    Height = 25
    Top = 322
    Width = 75
    Caption = 'OK'
    Default = True
    OnClick = OkButtonClick
    TabOrder = 5
  end
  object ConfirmPasswordEdit: TEdit
    Left = 8
    Height = 21
    Top = 72
    Width = 354
    EchoMode = emPassword
    OnChange = PasswordEditChange
    PasswordChar = '*'
    TabOrder = 1
  end
  object ShowKeywordCheckBox: TCheckBox
    Left = 16
    Height = 19
    Top = 326
    Width = 90
    Caption = 'Show &keyword'
    OnClick = ShowKeywordCheckBoxClick
    TabOrder = 3
  end
  object CancelButton: TButton
    Left = 287
    Height = 25
    Top = 322
    Width = 75
    Cancel = True
    Caption = 'Cancel'
    OnClick = CancelButtonClick
    TabOrder = 6
  end
  object StrengthGroupBox: TGroupBox
    Left = 8
    Height = 212
    Top = 104
    Width = 354
    Caption = ' The keyword strength: weak  '
    ClientHeight = 194
    ClientWidth = 350
    TabOrder = 2
    object KeyWordLengthLabel: TLabel
      Left = 31
      Height = 13
      Top = 9
      Width = 202
      Caption = 'Length exceeds 15 characters (currently 0)'
      ParentColor = False
    end
    object IncludesSymbolsLabel: TLabel
      Left = 31
      Height = 13
      Top = 32
      Width = 179
      Caption = 'Includes symbols (e.g. @#$%^&*_-+=?)'
      ParentColor = False
    end
    object IncludesNumbersLabel: TLabel
      Left = 31
      Height = 13
      Top = 55
      Width = 161
      Caption = 'Includes numbers (e.g. 23456789)'
      ParentColor = False
    end
    object IncludesLowercaseLabel: TLabel
      Left = 31
      Height = 13
      Top = 78
      Width = 225
      Caption = 'Includes lowercase characters (e.g. abcdefg ...)'
      ParentColor = False
    end
    object IncludesUppercaseLabel: TLabel
      Left = 31
      Height = 13
      Top = 101
      Width = 238
      Caption = 'Includes uppercase characters (e.g. ABCDEFG ...)'
      ParentColor = False
    end
    object ExcludesSimilarLabel: TLabel
      Left = 31
      Height = 13
      Top = 123
      Width = 246
      Caption = 'Excludes similar characters (e.g. i, l, |, !, 1, L, o, 0, O)'
      ParentColor = False
    end
    object ExcludesAmbiguousLabel: TLabel
      Left = 31
      Height = 13
      Top = 147
      Width = 313
      Caption = 'Excludes ambiguous characters ( { } [ ] ( ) / \< > '' " ` ~ ; : . , space)'
      ParentColor = False
    end
    object ExcludesNonLatinCharsLabel: TLabel
      Left = 31
      Height = 13
      Top = 170
      Width = 321
      Caption = 'Excludes non-Latin characters (National ones such as Æ, Ø, æ ...)   '
      ParentColor = False
    end
    object IncludesSymbolsCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 30
      Width = 20
      Enabled = False
      TabOrder = 1
      TabStop = False
    end
    object IncludesNumbersCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 53
      Width = 20
      Enabled = False
      TabOrder = 2
      TabStop = False
    end
    object IncludesLowercaseCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 76
      Width = 20
      Enabled = False
      TabOrder = 3
      TabStop = False
    end
    object IncludesUppercaseCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 99
      Width = 20
      Enabled = False
      TabOrder = 4
      TabStop = False
    end
    object KeyWordLengthCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 6
      Width = 20
      Color = clBtnFace
      Enabled = False
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      ParentColor = False
      ParentFont = False
      TabOrder = 0
      TabStop = False
    end
    object ExcludesSimilarCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 121
      Width = 20
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 5
      TabStop = False
    end
    object ExcludesAmbiguousCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 145
      Width = 20
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 6
      TabStop = False
    end
    object ExcludesNonLatinCharsCheckBox: TCheckBox
      Left = 8
      Height = 19
      Top = 168
      Width = 20
      Checked = True
      Enabled = False
      Font.CharSet = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      ParentFont = False
      State = cbChecked
      TabOrder = 7
      TabStop = False
    end
  end
  object MakeRandomButton: TButton
    Left = 125
    Height = 25
    Top = 322
    Width = 75
    Caption = 'Make random'
    Enabled = False
    OnClick = MakeRandomButtonClick
    TabOrder = 4
  end
end
