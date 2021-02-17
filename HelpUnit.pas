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

{$hints off}
{$B-,I-,Q-,S-,R-,A+,J+}

unit HelpUnit;

{$MODE Delphi}

interface

procedure ShowHelp(const URL : widestring);

implementation

uses Windows, SysUtils, ActiveX, ComObj, Forms;

procedure ShowHelp(const URL : widestring);
var InternetExplorer : OLEVariant;
begin
 try
  InternetExplorer := CreateOleObject('InternetExplorer.Application');
  InternetExplorer.Visible := True;
  InternetExplorer.Navigate(URL);
 except
  Application.MessageBox('Kryloff Personal Password Manager version 1.1'#13#10, PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
 end;
end;

Initialization
 OleInitialize(nil);

Finalization
 OleUninitialize();

end.
