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

{$MODE Delphi}

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

uses LCLIntf, LCLType, Windows, Wcrypt2, SysUtils, Functs, InitUnit;

function DecryptFileToString(const SourceFileName        : WideString; // the name of the input file, an encrypted file.
                             const Password              : AnsiString; // the password string; must not be empty.
                             out   DecryptedFileContents : AnsiString; // the descrypted data are placed to.
                             var   ErrorMessage          : WideString  // the error message if the function returns false.
                                                                     ) : boolean;

label Exit_DecryptFile;

const FILE_READ_DATA     = $0001; // file & pipe
const KEYLENGTH = $00800000;
const ENCRYPT_ALGORITHM = CALG_RC4;
const ENCRYPT_BLOCK_SIZE = 8;
const BLOCK_LENGTH = 1000 - 1000 MOD ENCRYPT_BLOCK_SIZE; // the number of bytes to decrypt at a time; must be a multiple of ENCRYPT_BLOCK_SIZE.

var hSourceFile  : THANDLE;
    hKey         : HCRYPTKEY;
    hHash        : HCRYPTHASH;
    CryptProv    : HCRYPTPROV;
    dwCount      : DWORD;
    Buffer       : packed array[0..BLOCK_LENGTH - 1] of byte;
    fEOF         : LongBool;

begin
 //---------------------------------------------------------------
 // Declare and initialize local variables.
 Result := false;
 hKey := 0;
 hHash := 0;
 CryptProv := 0;
 ErrorMessage := '';
 DecryptedFileContents := '';
 hSourceFile := INVALID_HANDLE_VALUE;

 //---------------------------------------------------------------
 // Checking the password
 if Length(Password) <= 0 then begin
  ErrorMessage := 'No password specified';
  goto Exit_DecryptFile;
 end;

 //---------------------------------------------------------------
 // Open the source file.
 hSourceFile := CreateFileW(PWideChar(SourceFileName), FILE_READ_DATA, FILE_SHARE_READ, Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
 if hSourceFile = INVALID_HANDLE_VALUE then begin
  ErrorMessage := 'Error opening the file ' + SourceFileName;
  goto Exit_DecryptFile;
 end;

 //---------------------------------------------------------------
 // Get the handle to the default provider.
 if not CryptAcquireContext(@CryptProv, ApplicationTitleUntyped, MS_ENHANCED_PROV, PROV_RSA_FULL, 0) and
    not CryptAcquireContext(@CryptProv, ApplicationTitleUntyped, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)
 then begin
  ErrorMessage := 'CryptAcquireContext fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_DecryptFile;
 end;

 //---------------------------------------------------------------
 // Create a session key.

 //-----------------------------------------------------------
 // Decrypt the file with a session key derived from a
 // password.

 //-----------------------------------------------------------
 // Create a hash object.
 if not CryptCreateHash(CryptProv, CALG_MD5, 0, 0, @hHash) then begin
  ErrorMessage := 'CryptCreateHash fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_DecryptFile;
 end;

 //-----------------------------------------------------------
 // Hash in the password data.
 if not CryptHashData(hHash, PBYTE(@Password[1]), Length(Password), 0) then begin
  ErrorMessage := 'CryptHashData fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_DecryptFile;
 end;

 //-----------------------------------------------------------
 // Derive a session key from the hash object.
 if not CryptDeriveKey(CryptProv, ENCRYPT_ALGORITHM, hHash, KEYLENGTH, @hKey) then begin
  ErrorMessage := 'CryptDeriveKey fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_DecryptFile;
 end;

 //---------------------------------------------------------------
 // The decryption key is now available having
 // been created by using the password. This point in the program
 // is not reached if the decryption key is not available.

 //---------------------------------------------------------------
 // Decrypt the source file, and write to the destination file.
 dwCount := 0; Buffer[0] := 0; // to make the compiler 'happy'
 repeat
  //-----------------------------------------------------------
  // Read up to dwBlockLen bytes from the source file.
  if not ReadFile(hSourceFile, Buffer, BLOCK_LENGTH, dwCount, Nil) then begin
   ErrorMessage := 'Error reading from the file ' + SourceFileName;
   goto Exit_DecryptFile;
  end;

  fEOF := dwCount <= 0;

  //-----------------------------------------------------------
  // Decrypt the block of data.
  if not CryptDecrypt(hKey, 0, fEOF, 0, @Buffer, @dwCount) then begin
   ErrorMessage := 'CryptDecrypt fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
   goto Exit_DecryptFile;
  end;

  //-----------------------------------------------------------
  // Append the decrypted data to the file contents.
  SetLength(DecryptedFileContents, Length(DecryptedFileContents) + integer(dwCount));
  Move(Buffer, DecryptedFileContents[Length(DecryptedFileContents) - integer(dwCount) + 1], integer(dwCount));

  //-----------------------------------------------------------
  // End the repeat loop when the last block of the source file
  // has been read, encrypted, and appended to the destination string
 until fEOF;

 Result := true;

Exit_DecryptFile:
 //---------------------------------------------------------------
 // Close files.
 if hSourceFile <> INVALID_HANDLE_VALUE
 then FileClose(hSourceFile); { *Converted from CloseHandle* }

 //-----------------------------------------------------------
 // Release the hash object.
 if (hHash <> 0) and not CryptDestroyHash(hHash)
 then ErrorMessage := 'CryptDestroyHash fauils with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);

 //---------------------------------------------------------------
 // Release the session key.
 if (hKey <> 0) and not CryptDestroyKey(hKey)
 then ErrorMessage := 'CryptDestroyKey fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);

 //---------------------------------------------------------------
 // Release the provider handle.
 if (CryptProv <> 0) and not CryptReleaseContext(CryptProv, 0)
 then ErrorMessage := 'CryptReleaseContext fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
end;

function EncryptStringToFile(const Data                : AnsiString; // the plain text data to be encrypted.
                             const DestinationFileName : WideString; // the name of the output, an encrypted file to be created.
                             const Password            : AnsiString; // the password string; must not be empty.
                             out   ErrorMessage        : WideString  // the error message if the function returns false.
                            ) : boolean;

label Exit_EncryptFile;

const FILE_WRITE_DATA    = $0002; // file & pipe
const KEYLENGTH          = $00800000;
const ENCRYPT_ALGORITHM  = CALG_RC4;
const ENCRYPT_BLOCK_SIZE = 8;
const BLOCK_LENGTH = 1000 - 1000 MOD ENCRYPT_BLOCK_SIZE; // The number of bytes to encrypt at a time; must be a multiple of ENCRYPT_BLOCK_SIZE.
const BUFFER_LENGTH = BLOCK_LENGTH + ENCRYPT_BLOCK_SIZE; // The block size. If a block cipher is used, it must have room for an extra block.

var fEOF                  : LongBool;
    hDestinationFile      : THANDLE;
    CryptProv             : HCRYPTPROV;
    hKey                  : HCRYPTKEY;
    hHash                 : HCRYPTHASH;
    Buffer                : packed array[0..BUFFER_LENGTH - 1] of byte;
    dwDataOffset, dwCount : DWORD;

begin
 //---------------------------------------------------------------
 // Initialize local variables.
 Result := false;
 CryptProv := 0;
 hKey := 0;
 hHash := 0;
 dwDataOffset := 0;
 hDestinationFile := INVALID_HANDLE_VALUE;
 ErrorMessage := '';

 //---------------------------------------------------------------
 // Checking the password
 if Length(Password) <= 0 then begin
  ErrorMessage := 'No password specified';
  goto Exit_EncryptFile;
 end;

 //---------------------------------------------------------------
 // Open the destination file.
 hDestinationFile := CreateFileW(
   PWideChar(DestinationFileName),
   FILE_WRITE_DATA,
   FILE_SHARE_READ,
   Nil,
   OPEN_ALWAYS,
   FILE_ATTRIBUTE_NORMAL,
   0);
 if hDestinationFile = INVALID_HANDLE_VALUE then begin
  ErrorMessage := 'Error opening the file ' + DestinationFileName;
  goto Exit_EncryptFile;
 end;

 //---------------------------------------------------------------
 // Get the handle to the default provider.
 if not CryptAcquireContext(@CryptProv, ApplicationTitleUntyped, MS_ENHANCED_PROV, PROV_RSA_FULL, 0) and
    not CryptAcquireContext(@CryptProv, ApplicationTitleUntyped, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)
 then begin
  ErrorMessage := 'CryptAcquireContext fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_EncryptFile;
 end;

 //---------------------------------------------------------------
 // Create the session key.

 //-----------------------------------------------------------
 // The file will be encrypted with a session key derived
 // from a password.
 // The session key will be recreated when the file is
 // decrypted only if the password used to create the key is
 // available.

 //-----------------------------------------------------------
 // Create a hash object.
 if not CryptCreateHash(CryptProv, CALG_MD5, 0, 0, @hHash) then begin
  ErrorMessage := 'CryptCreateHash fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_EncryptFile;
 end;

 //-----------------------------------------------------------
 // Hash the password.
 if not CryptHashData(hHash, PBYTE(@Password[1]), Length(Password), 0) then begin
  ErrorMessage := 'CryptHashData fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_EncryptFile;
 end;

 //-----------------------------------------------------------
 // Derive a session key from the hash object.
 if not CryptDeriveKey(CryptProv, ENCRYPT_ALGORITHM, hHash, KEYLENGTH, @hKey) then begin
  ErrorMessage := 'CryptDeriveKey fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
  goto Exit_EncryptFile;
 end;

 //---------------------------------------------------------------
 // The session key is now ready. If it is not a key derived from
 // a  password, the session key encrypted with the private key
 // has been written to the destination file.

 //---------------------------------------------------------------
 // In a do loop, encrypt the source file,
 // and write to the source file.
 Buffer[0] := 0; // to make the compiler 'happy'
 repeat
  //-----------------------------------------------------------
  // Pick up to dwBlockLen bytes from the source data.
  if dwDataOffset + BLOCK_LENGTH <= DWORD(Length(Data))
  then dwCount := BLOCK_LENGTH
  else dwCount := DWORD(Length(Data)) - dwDataOffset;
  Move(Data[dwDataOffset + 1], Buffer, dwCount);
  Inc(dwDataOffset, dwCount);
  fEOF := dwCount <= 0;

  //-----------------------------------------------------------
  // Encrypt data.
  if not CryptEncrypt(hKey, 0, fEOF, 0, @Buffer, @dwCount, BUFFER_LENGTH) then begin
   ErrorMessage := 'CryptEncrypt fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
   goto Exit_EncryptFile;
  end;

  //-----------------------------------------------------------
  // Write the encrypted data to the destination file.
  if not WriteFile(hDestinationFile, Buffer, dwCount, dwCount, Nil) then begin
   ErrorMessage := 'Error writing into the file ' + DestinationFileName;
   goto Exit_EncryptFile;
  end;

  //-----------------------------------------------------------
  // End the do loop when the last block of the source file
  // has been read, encrypted, and written to the destination
  // file.
 until fEOF;

 Result := true;

Exit_EncryptFile:
 //---------------------------------------------------------------
 // Close files.
 if hDestinationFile <> INVALID_HANDLE_VALUE then begin
  SetEndOfFile(hDestinationFile);
  FileClose(hDestinationFile); { *Converted from CloseHandle* }
 end;

 //-----------------------------------------------------------
 // Release the hash object.
 if (hHash <> 0) and not CryptDestroyHash(hHash)
 then ErrorMessage := 'CryptDestroyHash fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);

 //---------------------------------------------------------------
 // Release the session key.
 if (hKey <> 0) and not CryptDestroyKey(hKey)
 then ErrorMessage := 'CryptDestroyKey fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);

 //---------------------------------------------------------------
 // Release the provider handle.
 if (CryptProv <> 0) and not CryptReleaseContext(CryptProv, 0)
 then ErrorMessage := 'CryptReleaseContext fails with error ' + StrToUnicodeUnderCodePage(IntToStr(GetLastError()), CP_UTF8);
end; // Encryptfile()

End.
