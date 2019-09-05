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

unit OpenPasswordUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TOpenPasswordForm = class(TForm)
    PasswordEdit: TEdit;
    OkButton: TButton;
    ShowKeywordCheckBox: TCheckBox;
    CancelButton: TButton;
    PasswordLabel: TLabel;
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ShowKeywordCheckBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OkPressed : boolean;
  end;

implementation

{$R *.dfm}

procedure TOpenPasswordForm.FormCreate(Sender: TObject);
begin
 OkPressed := false
end;

procedure TOpenPasswordForm.OkButtonClick(Sender: TObject);
begin
 OkPressed := true;
 Close();
end;

procedure TOpenPasswordForm.CancelButtonClick(Sender: TObject);
begin
 Close()
end;

procedure TOpenPasswordForm.ShowKeywordCheckBoxClick(Sender: TObject);
begin
 if ShowKeywordCheckBox.Checked
 then PasswordEdit.PasswordChar := #0
 else PasswordEdit.PasswordChar := '*';
 try ActiveControl := PasswordEdit except { nothing } end
end;

End.
