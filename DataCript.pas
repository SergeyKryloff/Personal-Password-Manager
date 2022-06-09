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

Unit DataCript;

Interface

procedure CypherString(var S : AnsiString; const Password : AnsiString);

Implementation

uses MD5;

type UInt32 = cardinal;

function pseudo_random32(prev_value: UInt32) : UInt32;
begin
 Result := $08088405 * prev_value + 1;
 //  I read that Knuth reports the multiplier 6364136223846793005 (Hex 5851F42D4C957F2D)
 // as excellent (but not necessarily best) for 64-bit:
 // X[n+1] = 6364136223846793005 * X[n] + 1 (mod 2^64).
end;

procedure CypherString(var S : AnsiString; const Password : AnsiString);
Type TPUint32 = ^Uint32;
     TPByte8  = ^Byte;
var Context   : MD5Context;
    Digest    : record
      case integer of
       0 : (AsUint32    : packed array[0..3] of UInt32);
       1 : (AsMD5Digest : MD5Digest);
    end;
    PUInt32 : TPUint32;
    PByte8  : TPByte8;
    i, k    : integer;
    r       : packed array[0..3] of UInt32;
begin
 if S = '' then Exit;
 Context.State[0] := 0; // to make the compilter "happy"
 MD5Init(Context);
 MD5Update(Context, PChar(Password), Length(Password));
 Digest.AsMD5Digest[0] := 0; // to make the compilter "happy"
 MD5Final(Context, Digest.AsMD5Digest);
 for i := 0 to 3 do r[i] := Digest.AsUint32[i];

 PUInt32 := @(S[1]);
 for i := 1 to Length(S) DIV 4 do begin
  PUInt32^ := PUInt32^ XOR (r[0] XOR r[1] XOR r[2] XOR r[3]);
  Inc(PUInt32);
  for k := 0 to 3 do r[k] := pseudo_random32(r[k]);
 end;

 PByte8 := TPByte8(PUInt32);
 for i := 1 to Length(S) MOD 4 do begin
  PByte8^ := PByte8^ XOR (byte(r[0]) XOR byte(r[1]) XOR byte(r[2]) XOR byte(r[3]));
  Inc(Pbyte8);
  for k := 0 to 3 do r[k] := r[k] SHR 8;
 end;
end;

End.

