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

unit FindUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type                                        
  TFindForm = class(TForm)
    FindWhatLabel: TLabel;
    FindTextEdit: TEdit;
    PreviousButton: TButton;
    NextButton: TButton;
    CloseButton: TButton;
    procedure CloseButtonClick(Sender: TObject);
    procedure FindTextEditChange(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure PreviousButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var FindForm : TFindForm;

implementation

{$R *.dfm}

procedure TFindForm.FindTextEditChange(Sender: TObject);
begin
 NextButton.Enabled := FindTextEdit.Text <> '';
 PreviousButton.Enabled := NextButton.Enabled;
end;

procedure TFindForm.NextButtonClick(Sender: TObject);
begin
 PostMessage(Application.MainForm.Handle, WM_USER + 1, 1, 0);
end;

procedure TFindForm.PreviousButtonClick(Sender: TObject);
begin
 PostMessage(Application.MainForm.Handle, WM_USER + 1, 0, 0);
end;

procedure TFindForm.CloseButtonClick(Sender: TObject);
begin
 Close();
end;

end.
