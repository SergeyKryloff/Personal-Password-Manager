object OpenPasswordForm: TOpenPasswordForm
  Left = 752
  Top = 253
  BorderStyle = bsToolWindow
  Caption = 'Decrypt and open passwords'
  ClientHeight = 95
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PasswordLabel: TLabel
    Left = 8
    Top = 8
    Width = 292
    Height = 13
    Caption = '&Specify the keyword you have protected passwords your with:'
    FocusControl = PasswordEdit
  end
  object PasswordEdit: TEdit
    Left = 8
    Top = 24
    Width = 297
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
  end
  object OkButton: TButton
    Left = 136
    Top = 56
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = OkButtonClick
  end
  object ShowKeywordCheckBox: TCheckBox
    Left = 8
    Top = 62
    Width = 97
    Height = 17
    Caption = 'Show &keyword'
    TabOrder = 1
    OnClick = ShowKeywordCheckBoxClick
  end
  object CancelButton: TButton
    Left = 230
    Top = 56
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = CancelButtonClick
  end
end
