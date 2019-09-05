{**********************************************************************}
{                                                                      }
{ Developed by Sergey A. Kryloff under the GNU General Public License. }
{                                                                      }
{ Software distributed under the License is distributed on an          }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either expressed or     }
{ implied. See the License for the specific language governing         }
{ rights and limitations under the License.                            }
{                                                                      }
{**********************************************************************}

{$B-,I-,Q-,S-,R-,A+,J+}

unit SavePasswordUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSavePasswordForm = class(TForm)
    PasswordEdit: TEdit;
    OkButton: TButton;
    PasswordLabel: TLabel;
    ConfirmPasswordEdit: TEdit;
    ConfirmPasswordLabel: TLabel;
    ShowKeywordCheckBox: TCheckBox;
    CancelButton: TButton;
    IncludesSymbolsCheckBox: TCheckBox;
    IncludesNumbersCheckBox: TCheckBox;
    IncludesLowercaseCheckBox: TCheckBox;
    IncludesUppercaseCheckBox: TCheckBox;
    KeyWordLengthCheckBox: TCheckBox;
    ExcludesSimilarCheckBox: TCheckBox;
    ExcludesAmbiguousCheckBox: TCheckBox;
    StrengthGroupBox: TGroupBox;
    MakeRandomButton: TButton;
    ExcludesNonLatinCharsCheckBox: TCheckBox;
    KeyWordLengthLabel: TLabel;
    IncludesSymbolsLabel: TLabel;
    IncludesNumbersLabel: TLabel;
    IncludesLowercaseLabel: TLabel;
    IncludesUppercaseLabel: TLabel;
    ExcludesSimilarLabel: TLabel;
    ExcludesAmbiguousLabel: TLabel;
    ExcludesNonLatinCharsLabel: TLabel;
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PasswordEditChange(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ShowKeywordCheckBoxClick(Sender: TObject);
    procedure MakeRandomButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OkPressed : boolean;
  end;

implementation

{$R *.dfm}

uses Functs;

procedure TSavePasswordForm.FormCreate(Sender: TObject);
begin
 OkPressed := false
end;

procedure TSavePasswordForm.MakeRandomButtonClick(Sender: TObject);
begin
 PasswordEdit.Text := string(GenerateRandom8Chars() + GenerateRandom8Chars());
 ConfirmPasswordEdit.Text := ''
end;

procedure TSavePasswordForm.OkButtonClick(Sender: TObject);
begin
 OkPressed := true;
 Close()
end;

procedure TSavePasswordForm.PasswordEditChange(Sender: TObject);
const Symbols = [
'!', // Exclamation mark
'"', //	Quotes
'#', //	Hash
'$', //	Dollar
'%', //	Percent
'&', //	Ampersand
'''',//	Apostrophe
'(', //	Open bracket
')', //	Close bracket
'*', //	Asterisk
'+', //	Plus
',', //	Comma
'-', //	Dash
'.', //	Full stop
'/', //	Slash
':', //	Colon
';', //	Semi-colon
'<', //	Less than
'=', //	Equals
'>', //	Greater than
'?', //	Question mark
'@', //	At
'[', //	Open square bracket
'\', //	Backslash
']', //	Close square bracket
'^', //	Caret / hat
'_', //	Underscore
'`', //	Grave accent
'{', //	Open brace
'|', //	Pipe
'}', //	Close brace
'~'];//	Tilde
Numbers = ['0'..'9'];
LowercaseChars = ['a'..'z'];
UppercaseChars = ['A'..'Z'];
SimilarChars = ['i', 'I', 'l', '1', 'L', 'o', '0', 'O', '|', '!'];
AmbigousChars = ['{', '}', '[', ']', '(', ')', '/', '\', '''', '"', '`', '~', ',', ';', ':', '.', '<', '>', ' '];
NationalChars = [#128..#255];
FontColour : array[boolean] of TColor = (clMaroon, clWindowText);

var AnsiPassword : AnsiString;
    CheckedCount : Integer;

begin
 OkButton.Enabled := ShowKeywordCheckBox.Checked or (PasswordEdit.Text = ConfirmPasswordEdit.Text);
 AnsiPassword := AnsiString(PasswordEdit.Text);
 KeyWordLengthLabel.Caption := 'Length exceeds 15 characters (currently, ' + IntToStr(Length(PasswordEdit.Text)) + ')';

 CheckedCount := 0;
 KeyWordLengthCheckBox.Checked := Length(PasswordEdit.Text) > 15;
 Inc(CheckedCount, byte(KeyWordLengthCheckBox.Checked));
 KeyWordLengthLabel.Font.Color := FontColour[KeyWordLengthCheckBox.Checked];

 IncludesSymbolsCheckBox.Checked := AnsiSetPos(Symbols, AnsiPassword) > 0;
 Inc(CheckedCount, byte(IncludesSymbolsCheckBox.Checked));
 IncludesSymbolsLabel.Font.Color := FontColour[IncludesSymbolsCheckBox.Checked];

 IncludesNumbersCheckBox.Checked := AnsiSetPos(Numbers, AnsiPassword) > 0;
 Inc(CheckedCount, byte(IncludesNumbersCheckBox.Checked));
 IncludesNumbersLabel.Font.Color := FontColour[IncludesNumbersCheckBox.Checked];

 IncludesLowercaseCheckBox.Checked := AnsiSetPos(LowercaseChars, AnsiPassword) > 0;
 Inc(CheckedCount, byte(IncludesLowercaseCheckBox.Checked));
 IncludesLowercaseLabel.Font.Color := FontColour[IncludesLowercaseCheckBox.Checked];

 IncludesUppercaseCheckBox.Checked := AnsiSetPos(UppercaseChars, AnsiPassword) > 0;
 Inc(CheckedCount, byte(IncludesUppercaseCheckBox.Checked));
 IncludesUppercaseLabel.Font.Color := FontColour[IncludesUppercaseCheckBox.Checked];

 ExcludesSimilarCheckBox.Checked := AnsiSetPos(SimilarChars, AnsiPassword) <= 0;
 Inc(CheckedCount, byte(ExcludesSimilarCheckBox.Checked));
 ExcludesSimilarLabel.Font.Color := FontColour[ExcludesSimilarCheckBox.Checked];

 ExcludesAmbiguousCheckBox.Checked := AnsiSetPos(AmbigousChars, AnsiPassword) <= 0;
 Inc(CheckedCount, byte(ExcludesAmbiguousCheckBox.Checked));
 ExcludesAmbiguousLabel.Font.Color := FontColour[ExcludesAmbiguousCheckBox.Checked];

 ExcludesNonLatinCharsCheckBox.Checked := (AnsiSetPos(NationalChars, AnsiPassword) <= 0) and
                                          (WideString(AnsiPassword) = PasswordEdit.Text);
 Inc(CheckedCount, byte(ExcludesNonLatinCharsCheckBox.Checked));
 ExcludesNonLatinCharsLabel.Font.Color := FontColour[ExcludesNonLatinCharsCheckBox.Checked];

 StrengthGroupBox.Caption := ' The keyword strength: ' + IntToStr((100 * CheckedCount) DIV 8) + '%'
end;

procedure TSavePasswordForm.CancelButtonClick(Sender: TObject);
begin
 Close();
end;

procedure TSavePasswordForm.ShowKeywordCheckBoxClick(Sender: TObject);
begin
 if ShowKeywordCheckBox.Checked then begin
  OkButton.Enabled := true;
  ConfirmPasswordLabel.Visible := false;
  ConfirmPasswordEdit.Visible := false;
  MakeRandomButton.Enabled := true;
  PasswordEdit.PasswordChar := #0;
 end else begin
  OkButton.Enabled := PasswordEdit.Text = ConfirmPasswordEdit.Text;
  ConfirmPasswordLabel.Visible := true;
  ConfirmPasswordEdit.Visible := true;
  MakeRandomButton.Enabled := false;
  PasswordEdit.PasswordChar := '*'
 end;
 try ActiveControl := PasswordEdit except { nothing } end
end;

End.

