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

program PssMngr;

{$MODE Delphi}

uses
  InitUnit,
  Forms, Interfaces,
  MainUnit in 'MainUnit.pas' {MainForm},
  FindUnit in 'FindUnit.pas' {FindForm},
  ShowPasswordUnit in 'ShowPasswordUnit.pas' {ShowPasswordForm},
  CommentsUnit in 'CommentsUnit.pas' {CommentsForm};

{$R VerInfo.res}

begin
  if AlreadyRunning then Exit;
  Application.Initialize;
  Application.Title := 'The Kryloff Personal Password Manager';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFindForm, FindForm);
  Application.CreateForm(TShowPasswordForm, ShowPasswordForm);
  Application.CreateForm(TCommentsForm, CommentsForm);
  Application.Run;
end.
