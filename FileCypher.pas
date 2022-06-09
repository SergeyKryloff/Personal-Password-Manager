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

Unit FileCypher;

Interface

//-------------------------------------------------------------------
// DecryptFileToString() decrypts file contents into a string.
function DecryptFileToString(const SourceFileName        : WideString; // the name of the input file, an encrypted file.
                             const Password              : AnsiString; // the password string; must not be empty.
                             out   DecryptedFileContents : AnsiString; // the descrypted data are placed to.
                             var   ErrorMessage          : WideString  // the error message if the function returns false.
                                                                     ) : boolean;

//-------------------------------------------------------------------
// EncryptStringToFile() encrypts a string into a file.
function EncryptStringToFile(const Data                : AnsiString; // the plain text data to be encrypted.
                             const DestinationFileName : WideString; // the name of the output, an encrypted file to be created.
                             const Password            : AnsiString; // the password string; must not be empty.
                             out   ErrorMessage        : WideString  // the error message if the function returns false.
                            ) : boolean;

Implementation

uses SysUtils, DataCript;

function DecryptFileToString(const SourceFileName        : WideString; // the name of the input file, an encrypted file.
                             const Password              : AnsiString; // the password string; must not be empty.
                             out   DecryptedFileContents : AnsiString; // the descrypted data are placed to.
                             var   ErrorMessage          : WideString  // the error message if the function returns false.
                                                                     ) : boolean;
var F     : file;
    FSize : integer;
begin
 FileMode := 0;
 System.Assign(F, SourceFileName); System.Reset(F, 1);
 FSize := FileSize(F);
 if FSize > 0 then begin
  SetLength(DecryptedFileContents, FSize);
  BlockRead(F, DecryptedFileContents[1], Length(DecryptedFileContents));
  CypherString(DecryptedFileContents, Password);
 end else DecryptedFileContents := '';
 System.Close(F);

 Result := IOResult() = 0;
 if Result
 then ErrorMessage := ''
 else ErrorMessage := 'Errow reading the file ' + SourceFileName;
end;

function EncryptStringToFile(const Data                : AnsiString; // the plain text data to be encrypted.
                             const DestinationFileName : WideString; // the name of the output, an encrypted file to be created.
                             const Password            : AnsiString; // the password string; must not be empty.
                             out   ErrorMessage        : WideString  // the error message if the function returns false.
                            ) : boolean;
var T             : Text;
    EncryptedData : AnsiString;
begin
 System.Assign(T, DestinationFileName); System.Rewrite(T);
 EncryptedData := Data;
 CypherString(EncryptedData, Password);
 Write(T, EncryptedData);
 System.Close(T);
 Result := IOResult() = 0;
 if Result
 then ErrorMessage := ''
 else ErrorMessage := 'Errow writing into the file ' + DestinationFileName;
end;

End.

