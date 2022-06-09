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

unit FindUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type

  { TFindForm }

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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var FindForm : TFindForm;

implementation

{$R *.lfm}

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

procedure TFindForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caHide
end;

procedure TFindForm.CloseButtonClick(Sender: TObject);
begin
 Close();
end;

end.
(*
procedure TFindForm.FormActivate(Sender: TObject);
var i         : integer;
    TopicList : TStringList;
begin
 TopicList := TStringList.Create();
 MainUnit.MainForm.FillInTopicList(TopicList);

 for i := 0 to TopicList.Count - 1 do
 if SearchInComboBox.Items.IndexOf(TopicList.Strings[i]) < 0
 then SearchInComboBox.Items.Append(TopicList.Strings[i]);

 for i := SearchInComboBox.Items.Count - 1 downto 0 do
 if TopicList.IndexOf(SearchInComboBox.Items.Strings[i]) < 0
 then SearchInComboBox.Items.Delete(i);

 SearchInComboBox.Items.Append('*** All items regardless of the topic ***');
 TopicList.Free();
end;
*)

