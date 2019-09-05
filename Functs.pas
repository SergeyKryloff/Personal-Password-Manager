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

{$B-,I-,Q-,S-,R-,A+}

Unit Functs;

Interface

uses Windows;

type TANsiCharSet = set of AnsiChar;

function AnsiCharPosEx(const c : ansichar; const S : ansistring; const StartFromPosition : integer) : integer;
function AnsiTrim(const S : AnsiString) : AnsiString;
function AnsiSetPos(const Symbols : TANsiCharSet; const S : AnsiString) : integer;
function StrToUnicodeUnderCodePage(const S : ANSIString; CodePage : cardinal) : WideString;
function UnicodeToStrUnderCodePage(const S               : WideString;
                                         CodePage        : cardinal;
                                         UnmappablePChar : Pointer) : ANSIString;
// Returns a Windows handle of the currently focused control and
// the foreground window caption. To activate it later, use SetForegroundWindow()
function GetCurrentHandle(var WndTitle : ShortString) : HWND;
function LongMax(i, j : LongInt) : LongInt;
function LongMin(i, j : LongInt) : LongInt;
procedure SendText(const S : WideString);
function GenerateRandom8Chars : AnsiString;
procedure ReadLnFromString(const FromString : AnsiString; var ZeroBasedOffset : integer; var ToString : AnsiString);

Implementation

uses SysUtils, StrUtils, Wcrypt2, InitUnit;

function AnsiCharPosEx(const c : ansichar; const S : ansistring; const StartFromPosition : integer) : integer;
var i : integer;
begin
 for i := LongMax(1, StartFromPosition) to Length(S) do
 if S[i] = c then begin
  Result := i;
  Exit;
 end;
 Result := 0;
end;

function AnsiTrim(const S : AnsiString) : AnsiString;
var i, ResultLength : integer;
begin
 Result := S;
 ResultLength := Length(Result);
 for i := Length(Result) downto 1 do if S[i] <= ' ' then ResultLength := i - 1 else break;
 SetLength(Result, ResultLength);
 ResultLength := 0;
 for i := 1 to Length(Result) do if S[i] <= ' ' then ResultLength := i else break;
 Delete(Result, 1, ResultLength);
end;

function AnsiSetPos(const Symbols : TANsiCharSet; const S : AnsiString) : integer;
var i : integer;
begin
 for i := 1 to Length(S) do
 if S[i] in Symbols then begin
  Result := i;
  Exit
 end;
 Result := 0;
end;

function StrToUnicodeUnderCodePage(const S : ANSIString; CodePage : cardinal) : WideString;
begin
 SetLength(Result, 2 * (Length(S) + 1));
 SetLength(Result, MultiByteToWideChar(CodePage,	// code page
                                       0, // DWORD  dwFlags, // character-type options
                                       @S[1],	// address of string to map
                                       Length(S),	// number of characters in string
                                       @Result[1],	// address of wide-character buffer
                                       Length(Result) // size of buffer
                                      ))
end;

function UnicodeToStrUnderCodePage(const S               : WideString;
                                         CodePage        : cardinal;
                                         UnmappablePChar : Pointer) : ANSIString;
const WC_NO_BEST_FIT_CHARS = $00000400;
begin
 SetLength(Result, 4 * (Length(S) + 1));
 if CodePage = CP_UTF8
 then SetLength(Result, WideCharToMultiByte(CodePage,	// code page
                        0, // DWORD  dwFlags, character-type options
                        @S[1],	// address of wide string
                        Length(S),	// number of wide characters in string
                        @Result[1],	// address of character buffer
                        Length(Result), // size of buffer
                        UnmappablePChar, // address of default for unmappable characters
                        Nil // address of flag set when default char. used
                       ))
 else SetLength(Result, WideCharToMultiByte(CodePage,	// code page
                        WC_COMPOSITECHECK or WC_NO_BEST_FIT_CHARS, // DWORD  dwFlags, character-type options
                        @S[1],	// address of wide string
                        Length(S),	// number of wide characters in string
                        @Result[1],	// address of character buffer
                        Length(Result), // size of buffer
                        UnmappablePChar, // address of default for unmappable characters
                        Nil // address of flag set when default char. used
                       ))
end;

// Returns a Windows handle of the currently focused control and
// the foreground window caption. To activate it later, use SetForegroundWindow()
function GetCurrentHandle(var WndTitle : ShortString) : HWND;
var ActiveWinHandle : HWND;
    FocusedThreadID : DWORD;
begin
 Result := 0;
 ActiveWinHandle := GetForegroundWindow();
 WndTitle[0] := AnsiChar(GetWindowTextA(ActiveWinHandle, @WndTitle[1], sizeof(WndTitle) - 1));
 FocusedThreadID := GetWindowThreadProcessID(activeWinHandle, Nil);
 if AttachThreadInput(GetCurrentThreadID(), FocusedThreadID, true) then begin
  Result := GetFocus();
  if Result = 0 then Result := ActiveWinHandle;
  AttachThreadInput(GetCurrentThreadID(), FocusedThreadID, false)
 end // if AttachThreadInput()
end;

function LongMax(i, j : LongInt) : LongInt; begin if i > j then Result := i else Result := j end;
function LongMin(i, j : LongInt) : LongInt; begin if i < j then Result := i else Result := j end;

procedure SendText(const S : WideString);
const KEYEVENTF_UNICODE = $0004;
var I  : Integer;
    TI : TInput;
begin
 FillChar(TI, sizeof(TI), 0);
 TI.Itype := INPUT_KEYBOARD;
 for I := 1 to Length(S) do begin
  TI.ki.dwFlags := KEYEVENTF_UNICODE;
  TI.ki.wScan := Ord(S[I]);
  SendInput(1, TI, SizeOf(TI));
  sleep(10);
  TI.ki.dwFlags := TI.ki.dwFlags or KEYEVENTF_KEYUP;
  SendInput(1, TI, SizeOf(TI));
  sleep(10)
 end
end;

function GenerateRandom8Chars : AnsiString;
const ALLOWED_NUMBER_COUNT = 8; // 0..9 but 0 and 1
      ALLOWED_SYMBOL_COUNT = 12; // @#$%^&*_-+=?
      ALLOWED_LOWERCASE_CHAR_COUNT = 26 - 3; // a..z but i, l, and o
      ALLOWED_UPPERCASE_CHAR_COUNT = ALLOWED_LOWERCASE_CHAR_COUNT; // A..Z but I, L, and O
      ALLOWED_CHAR_COUNT = 2 * (26 - 3) + ALLOWED_NUMBER_COUNT + ALLOWED_SYMBOL_COUNT;
      AllowedChars : array[0..ALLOWED_CHAR_COUNT - 1] of ansichar =
     (
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
      {'i'}'j', 'k', {'l'}'m', 'n', {'o'}'p',
      'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
      'y', 'z',
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
      {'I'}'J', 'K', {'L'}'M', 'N', {'O'}'P',
      'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
      'Y', 'Z',
      '2', '3', '4', '5', '6', '7', '8', '9',
      '@', '#', '$', '%', '^', '&', '*', '_', '-', '+', '=', '?'
      );
      AllowedSymbols = ['@', '#', '$', '%', '^', '&', '*', '_', '-', '+', '=', '?'];
      AllowedSymbol : array[0..ALLOWED_SYMBOL_COUNT - 1] of ansichar =
                       ('@', '#', '$', '%', '^', '&', '*', '_', '-', '+', '=', '?');
      AllowedNumbers = ['2', '3', '4', '5', '6', '7', '8', '9'];
      AllowedNumber : array[0..ALLOWED_NUMBER_COUNT - 1] of ansichar =
                       ('2', '3', '4', '5', '6', '7', '8', '9');
      AllowedLowercaseChars = ['a'..'z'] - ['i', 'l', 'o'];
      AllowedLowercaseChar : array[0..ALLOWED_LOWERCASE_CHAR_COUNT - 1] of ansichar = (
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', {'i'} 'j', 'k', {'l'} 'm', 'n', {'o'} 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
      AllowedUppercaseChars = ['A'..'Z'] - ['I', 'L', 'O'];
      AllowedUppercaseChar : array[0..ALLOWED_UPPERCASE_CHAR_COUNT - 1] of ansichar = (
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', {'I'} 'J', 'K', {'L'} 'M', 'N', {'O'} 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');

var i                     : integer;
    Buffer                : array[0..7] of byte;
    hCryptProvider        : HCRYPTPROV;
    GeneratedWithCryptLib : boolean;

begin
 GeneratedWithCryptLib := CryptAcquireContext(@hCryptProvider, ApplicationTitleUntyped, MS_ENHANCED_PROV, PROV_RSA_FULL, 0) or
                          CryptAcquireContext(@hCryptProvider, ApplicationTitleUntyped, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET);
 if GeneratedWithCryptLib then begin
  GeneratedWithCryptLib := CryptGenRandom(hCryptProvider, sizeof(Buffer), @Buffer);
  if GeneratedWithCryptLib then for i := 0 to sizeof(Buffer) - 1 do Buffer[i] := Buffer[i] MOD ALLOWED_CHAR_COUNT;
  if not CryptReleaseContext(hCryptProvider, 0) then GeneratedWithCryptLib := false
 end;

 if not GeneratedWithCryptLib then for i := 0 to sizeof(Buffer) - 1 do  begin Randomize(); Buffer[i] := random(ALLOWED_CHAR_COUNT) end;

 SetLength(Result, sizeof(Buffer));
 for i := 1 to sizeof(Buffer) do Result[i] := AllowedChars[Buffer[i - 1]];

 if AnsiSetPos(AllowedSymbols, Result) <= 0 then begin
  Randomize();
  Result := Result + AllowedSymbol[random(ALLOWED_SYMBOL_COUNT)]
 end;
 if AnsiSetPos(AllowedNumbers, Result) <= 0 then begin
  Randomize();
  Result := Result + AllowedNumber[random(ALLOWED_NUMBER_COUNT)]
 end;
 if AnsiSetPos(AllowedLowercaseChars, Result) <= 0 then begin
  Randomize();
  Result := Result + AllowedLowercaseChar[random(ALLOWED_LOWERCASE_CHAR_COUNT)]
 end;
 if AnsiSetPos(AllowedUppercaseChars, Result) <= 0 then begin
  Randomize();
  Result := Result + AllowedUppercaseChar[random(ALLOWED_UPPERCASE_CHAR_COUNT)]
 end;
end;

procedure ReadLnFromString(const FromString : AnsiString; var ZeroBasedOffset : integer; var ToString : AnsiString);
var i : integer;
begin
 i := AnsiCharPosEx(#10, FromString, ZeroBasedOffset + 1);
 if i <= 0 then i := Length(FromString) + 1;
 ToString := copy(FromString, ZeroBasedOffset + 1, i - ZeroBasedOffset - 1);
 ZeroBasedOffset := i
end;

End.
