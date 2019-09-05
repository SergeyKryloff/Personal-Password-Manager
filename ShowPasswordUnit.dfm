object ShowPasswordForm: TShowPasswordForm
  Left = 726
  Top = 346
  BorderStyle = bsToolWindow
  Caption = 'Your keyword'
  ClientHeight = 282
  ClientWidth = 483
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 192
    Width = 78
    Height = 13
    Caption = 'Your keyword is:'
    FocusControl = PasswordEdit
  end
  object InfoImage: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
    Transparent = True
  end
  object InfoMemo: TMemo
    Left = 48
    Top = 8
    Width = 425
    Height = 177
    TabStop = False
    Lines.Strings = (
      
        'You have successfully changed the keyword with which you protect' +
        ' your passwords. '
      
        'Please, next time you launch this application, specify the new k' +
        'eyword only.'
      ''
      
        'Note, that Password Manager does not store your keywords anywher' +
        'e, so if you '
      
        'forget your keyword, you will not be able to access your passwor' +
        'ds anymore!'
      ''
      
        'It is recommended that you keep your keyword in a safe place. If' +
        ' you are not sure '
      
        'about your memory, write it down on a piece of paper or your per' +
        'sonal and private '
      'flash drive.'
      ''
      'Your current keyword is shown below.')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object PasswordEdit: TEdit
    Left = 48
    Top = 208
    Width = 425
    Height = 21
    PasswordChar = '*'
    ReadOnly = True
    TabOrder = 1
  end
  object OkButton: TButton
    Left = 397
    Top = 240
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = OkButtonClick
  end
  object ShowKeywordCheckBox: TCheckBox
    Left = 48
    Top = 244
    Width = 97
    Height = 17
    Caption = 'Show &keyword'
    TabOrder = 2
    OnClick = ShowKeywordCheckBoxClick
  end
end
