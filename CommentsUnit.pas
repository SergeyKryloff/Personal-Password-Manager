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

unit CommentsUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCommentsForm = class(TForm)
    CommentsMemo: TMemo;
    procedure CommentsMemoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var CommentsForm : TCommentsForm;

implementation

{$R *.lfm}

procedure TCommentsForm.CommentsMemoKeyPress(Sender: TObject; var Key: Char);
begin
 if Key = #27 then Close()
end;

end.
