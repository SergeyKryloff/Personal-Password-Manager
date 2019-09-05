object HelpForm: THelpForm
  Left = 204
  Top = 48
  Width = 1122
  Height = 689
  Caption = 'Introduction to the Kryloff Personal Password Manager'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser: TWebBrowser
    Left = 0
    Top = 0
    Width = 1106
    Height = 650
    Align = alClient
    TabOrder = 0
    ControlData = {
      4C0000004F7200002E4300000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object CancelButton: TButton
    Left = 0
    Top = 0
    Width = 75
    Height = 25
    Cancel = True
    TabOrder = 1
    TabStop = False
    OnClick = CancelButtonClick
  end
end
