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

var AlreadyRunning : boolean = False;

Implementation

Uses LCLIntf, LCLType, Windows, SysUtils;

function ExistingInstanceFunc(h : HWND; l : LPARAM) : WinBool; stdcall;
var Caption : packed array[0..255] of char;
begin
 Caption[255] := #0;
 if (GetWindowText(h, caption, sizeof(caption) - 1) > 0) and
    (strpos(Caption, ApplicationTitleUntyped) <> Nil)
 then begin
  AlreadyRunning := True;
  ShowWindow(h, SW_RESTORE);
  SetForegroundWindow(h);
  PostMessage(h, WM_USER + 2, 0, 0);
  Result := FALSE
 end else begin
  Result := TRUE
 end
end;

Initialization
 EnumChildWindows(0, @ExistingInstanceFunc, 0);

End.
