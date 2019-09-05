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

{$hints off}
{$B-,I-,Q-,S-,R-,A+,J+}

unit HelpUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls;

type
  THelpForm = class(TForm)
    WebBrowser: TWebBrowser;
    CancelButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  HelpForm: THelpForm;

implementation

uses ActiveX;

{$R *.dfm}

procedure THelpForm.CancelButtonClick(Sender: TObject);
begin
 Close()
end;

procedure THelpForm.FormCreate(Sender: TObject);
begin
 CancelButton.Width := 0; CancelButton.Height := 0
end;

procedure THelpForm.CreateParams(var Params: TCreateParams);
begin
 inherited CreateParams(Params);
 Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

Initialization
 OleInitialize(nil);

Finalization
 OleUninitialize();

end.
