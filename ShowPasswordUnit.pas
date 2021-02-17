{**********************************************************************}
{                                                                      }
{ Developed by Sergey A. Kryloff under the GNU General Public License. }
{                                                                      }
{ Software distributed under the License is provided on an             }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either expressed or     }
{ implied. See the License for the specific language governing         }
{ rights and limitations under the License.                            }
{                                                                      }
{**********************************************************************}

{$B-,I-,Q-,S-,R-,A+,J+}

unit ShowPasswordUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TShowPasswordForm = class(TForm)
    InfoMemo: TMemo;
    PasswordEdit: TEdit;
    Label1: TLabel;
    OkButton: TButton;
    InfoImage: TImage;
    ShowKeywordCheckBox: TCheckBox;
    procedure OkButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShowKeywordCheckBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ShowPasswordForm: TShowPasswordForm;

implementation

{$R *.lfm}

uses Windows;

procedure TShowPasswordForm.OkButtonClick(Sender: TObject);
begin
 Close()
end;

function LoadStandardIcon(hInstance: integer; lpIconNum: integer): integer; stdcall; external 'user32.dll' name 'LoadIconA';

procedure TShowPasswordForm.FormShow(Sender: TObject);
const IDI_ASTERISK = 32516;
var h : HICON;
begin
 h := LoadStandardIcon(0, IDI_ASTERISK);
 {$warnings off}
 DrawIconEx(InfoImage.Canvas.Handle, 0, 0, h, InfoImage.Width, InfoImage.Height, 0, InfoImage.Canvas.Brush.Handle, DI_NORMAL);
 {$warnings on}
end;

procedure TShowPasswordForm.ShowKeywordCheckBoxClick(Sender: TObject);
begin
 if ShowKeywordCheckBox.Checked
 then PasswordEdit.PasswordChar := #0
 else PasswordEdit.PasswordChar := '*';
 try ActiveControl := PasswordEdit except { nothing } end
end;

end.
