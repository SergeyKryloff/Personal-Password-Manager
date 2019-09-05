object SavePasswordForm: TSavePasswordForm
  Left = 444
  Top = 251
  BorderStyle = bsToolWindow
  Caption = 'Encrypt and save data'
  ClientHeight = 355
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = PasswordEditChange
  PixelsPerInch = 96
  TextHeight = 13
  object PasswordLabel: TLabel
    Left = 8
    Top = 8
    Width = 213
    Height = 13
    Caption = '&Specify a keyword to protect passwords with:'
    FocusControl = PasswordEdit
  end
  object ConfirmPasswordLabel: TLabel
    Left = 8
    Top = 56
    Width = 104
    Height = 13
    Caption = '&Confirm your keyword:'
    FocusControl = ConfirmPasswordEdit
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object PasswordEdit: TEdit
    Left = 8
    Top = 24
    Width = 354
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
    OnChange = PasswordEditChange
  end
  object OkButton: TButton
    Left = 206
    Top = 322
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 5
    OnClick = OkButtonClick
  end
  object ConfirmPasswordEdit: TEdit
    Left = 8
    Top = 72
    Width = 354
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    OnChange = PasswordEditChange
  end
  object ShowKeywordCheckBox: TCheckBox
    Left = 16
    Top = 326
    Width = 97
    Height = 17
    Caption = 'Show &keyword'
    TabOrder = 3
    OnClick = ShowKeywordCheckBoxClick
  end
  object CancelButton: TButton
    Left = 287
    Top = 322
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = CancelButtonClick
  end
  object StrengthGroupBox: TGroupBox
    Left = 8
    Top = 112
    Width = 354
    Height = 204
    Caption = ' The keyword strength: weak  '
    TabOrder = 2
    object KeyWordLengthLabel: TLabel
      Left = 24
      Top = 17
      Width = 202
      Height = 13
      Caption = 'Length exceeds 15 characters (currently 0)'
    end
    object IncludesSymbolsLabel: TLabel
      Left = 24
      Top = 40
      Width = 179
      Height = 13
      Caption = 'Includes symbols (e.g. @#$%^&*_-+=?)'
    end
    object IncludesNumbersLabel: TLabel
      Left = 24
      Top = 63
      Width = 161
      Height = 13
      Caption = 'Includes numbers (e.g. 23456789)'
    end
    object IncludesLowercaseLabel: TLabel
      Left = 24
      Top = 86
      Width = 225
      Height = 13
      Caption = 'Includes lowercase characters (e.g. abcdefg ...)'
    end
    object IncludesUppercaseLabel: TLabel
      Left = 24
      Top = 109
      Width = 238
      Height = 13
      Caption = 'Includes uppercase characters (e.g. ABCDEFG ...)'
    end
    object ExcludesSimilarLabel: TLabel
      Left = 24
      Top = 132
      Width = 246
      Height = 13
      Caption = 'Excludes similar characters (e.g. i, l, |, !, 1, L, o, 0, O)'
    end
    object ExcludesAmbiguousLabel: TLabel
      Left = 24
      Top = 155
      Width = 313
      Height = 13
      Caption = 
        'Excludes ambiguous characters ( { } [ ] ( ) / \< > '#39' " ` ~ ; : .' +
        ' , space)'
    end
    object ExcludesNonLatinCharsLabel: TLabel
      Left = 24
      Top = 178
      Width = 321
      Height = 13
      Caption = 
        'Excludes non-Latin characters (National ones such as '#198', '#216', '#230' ...' +
        ')   '
    end
    object IncludesSymbolsCheckBox: TCheckBox
      Left = 8
      Top = 39
      Width = 17
      Height = 17
      TabStop = False
      Enabled = False
      TabOrder = 1
    end
    object IncludesNumbersCheckBox: TCheckBox
      Left = 8
      Top = 62
      Width = 17
      Height = 17
      TabStop = False
      Enabled = False
      TabOrder = 2
    end
    object IncludesLowercaseCheckBox: TCheckBox
      Left = 8
      Top = 85
      Width = 17
      Height = 17
      TabStop = False
      Enabled = False
      TabOrder = 3
    end
    object IncludesUppercaseCheckBox: TCheckBox
      Left = 8
      Top = 108
      Width = 17
      Height = 17
      TabStop = False
      Enabled = False
      TabOrder = 4
    end
    object KeyWordLengthCheckBox: TCheckBox
      Left = 8
      Top = 16
      Width = 17
      Height = 17
      TabStop = False
      Color = clBtnFace
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 0
    end
    object ExcludesSimilarCheckBox: TCheckBox
      Left = 8
      Top = 131
      Width = 17
      Height = 17
      TabStop = False
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 5
    end
    object ExcludesAmbiguousCheckBox: TCheckBox
      Left = 8
      Top = 154
      Width = 17
      Height = 17
      TabStop = False
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 6
    end
    object ExcludesNonLatinCharsCheckBox: TCheckBox
      Left = 8
      Top = 177
      Width = 17
      Height = 17
      TabStop = False
      Checked = True
      Enabled = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 7
    end
  end
  object MakeRandomButton: TButton
    Left = 125
    Top = 322
    Width = 75
    Height = 25
    Caption = 'Make random'
    Enabled = False
    TabOrder = 4
    OnClick = MakeRandomButtonClick
  end
end
