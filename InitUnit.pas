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

Unit InitUnit;

{$MODE Delphi}

Interface

const ApplicationTitleUntyped = 'The Kryloff Personal Password Manager';
      ApplicationTitleAsShortstring : ShortString = ApplicationTitleUntyped;
      ApplicationTitleAsString      : String      = ApplicationTitleUntyped;

var AlreadyRunning : boolean;

Implementation

Uses LCLIntf, LCLType, Windows;

function CheckExistingInstance : boolean;
var PreviousInstanceWnd : HWND;
begin
 PreviousInstanceWnd := FindWindowA(Nil { 'TMainForm' }, ApplicationTitleUntyped);
 Result := PreviousInstanceWnd <> 0;
 if Result then SetForegroundWindow(PreviousInstanceWnd)
end;


Initialization
 AlreadyRunning := CheckExistingInstance();

End.
