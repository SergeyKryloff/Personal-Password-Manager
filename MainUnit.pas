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

{$B-,I-,Q-,S-,R-,A+,J+}

unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, Menus;

type
  TMainForm = class(TForm)
    Timer: TTimer;
    PasswordStringGrid: TStringGrid;
    MainMenu: TMainMenu;
    PasswordMainMenuItem: TMenuItem;
    EditMainMenuItem: TMenuItem;
    HelpMainMenuItem: TMenuItem;
    AboutMainMenuItem: TMenuItem;
    ExitMainMenuItem: TMenuItem;
    ToggleEditingMainMenuItem: TMenuItem;
    FindMainMenuItem: TMenuItem;
    N1: TMenuItem;
    InsertRowMainMenuItem: TMenuItem;
    DeleteRowMainMenuItem: TMenuItem;
    MoveUpMainMenuItem: TMenuItem;
    MoveDownMainMenuItem: TMenuItem;
    TypeMainMenuItem: TMenuItem;
    AppendRandomMainMenuItem: TMenuItem;
    FileMainMenuItem: TMenuItem;
    OpenUrltMainMenuItem: TMenuItem;
    CellMainMenuItem: TMenuItem;
    CutMainMenuItem: TMenuItem;
    CopyMainMenuItem: TMenuItem;
    PasteMainMenuItem: TMenuItem;
    DeleteMainMenuItem: TMenuItem;
    UndoMainMenuItem: TMenuItem;
    Undo1MainMenuItem: TMenuItem;
    SelectAllMainMenuItem: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    OpenMainMenuItem: TMenuItem;
    SaveMainMenuItem: TMenuItem;
    StopEditingMainMenuItem: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure EditMenuItemClick(Sender: TObject);
    procedure PasswordStringGridSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure AboutMenuItemClick(Sender: TObject);
    procedure DeleteRowMenuItemClick(Sender: TObject);
    procedure PasswordStringGridDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure PasswordStringGridMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MoveUpMenuItemClick(Sender: TObject);
    procedure MoveDownMenuItemClick(Sender: TObject);
    procedure InsertRowMenuItemClick(Sender: TObject);
    procedure FindMenuItemClick(Sender: TObject);
    procedure SelectAllMenuItemClick(Sender: TObject);
    procedure CopyMenuItemClick(Sender: TObject);
    procedure CutMenuItemClick(Sender: TObject);
    procedure UndoMenuItemClick(Sender: TObject);
    procedure PasteMenuItemClick(Sender: TObject);
    procedure DeleteMenuItemClick(Sender: TObject);
    procedure ExitMainMenuItemClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure EditMainMenuItemClick(Sender: TObject);
    procedure PasswordMainMenuItemClick(Sender: TObject);
    procedure AppendRandomMenuItemClick(Sender: TObject);
    procedure FileMenuItemClick(Sender: TObject);
    procedure PasswordStringGridDoubleClick(Sender: TObject);
    procedure CellMainMenuItemClick(Sender: TObject);
    procedure SaveMainMenuItemClick(Sender: TObject);
    procedure OpenMainMenuItemClick(Sender: TObject);
  private
    { Private declarations }
    PasswordWindow, PredPasswordWindow : HWND;
    PredPasswordTitle                  : ShortString;
    Password                           : WideString;
    DataModified                       : boolean;
    OriginalToggleEditingMainMenuItemShortCut, OriginalStopEditingMainMenuItemShortCut : TShortCut;
    function LoadData(var ErrorMessage : WideString) : boolean;
    function SaveData(var ErrorMessage : WideString) : boolean;
    procedure FindItem(var Msg : TMessage); message WM_USER + 1;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses UITypes, ShellApi, FileCypher, InitUnit, IniFiles, Clipbrd, Functs, FindUnit,
     SavePasswordUnit, OpenPasswordUnit, ShowPasswordUnit, HelpUnit, AwDialogs;

{$R *.dfm}
{$R help.res} // navigate to "res://C:\.....\PssMngr.exe/HELP_ENTRY"

const TAB : ansichar = #9;
      DESCRIPTION_COLUMN = 0;
      LOGIN_COLUMN       = 1;
      PASSWORD_COLUMN    = 2;
      URL_COLUMN         = 3;
      COMMENTS_COLUMN    = 4;
      SettingsSection = 'Options';
      WindowSection   = 'Window';
      WindowMaximizedItem = 'Maximized';
      LeftItem            = 'Left';
      TopItem             = 'Top';
      WidthItem           = 'Width';
      HeightItem          = 'Heigh';
      DESCRIPTION_DEFAULT_WIDTH =  97;
      LOGIN_NDEFAULT_WIDTH      = 111;
      PASSWORD_DEFAULT_WIDTH    =  71;
      URL_DEFAULT_WIDTH         = 288;
      NoWindowCaptured = 'no window captured';
      DEFAULT_PASSWORD = 'Password';
      FILE_SUFFIX = 'File Suffix';
      FILE_SUFFIX_LENGTH = Length(FILE_SUFFIX);
      ERROR_MESSAGE_WRONG_PASWORD =
        'The keyword you have just specified does not allow to decrypt your passwords. ' +
        'If you can''t memorize the keyword, consider your passwords to be lost.'#13#10#13#10 +
        'Would you like to back up the file with passwords and start working with an empty one?';

function AnsiCharPos(const c : ansichar; const S : ansistring) : integer;
var i : integer;
begin
 for i := 1 to Length(S) do
 if S[i] = c then begin
  Result := i;
  Exit;
 end;
 Result := 0;
end;

function TMainForm.LoadData(var ErrorMessage : WideString) : boolean;
var S, DecryptedFileContents  : AnsiString;
    i, CurrentRow, ReadOffset : Integer;
    FileName                  : WideString;
begin
 ErrorMessage := '';
 FileName := ChangeFileExt(ParamStr(0), '.csv');
 if not FileExists(FileName) then begin
  PasswordStringGrid.RowCount := 2;
  for i := 0 to PasswordStringGrid.ColCount - 1 do PasswordStringGrid.Cells[i, PasswordStringGrid.RowCount - 1] := '';
  Result := true;
  Exit
 end;

 Result := DecryptFileToString(FileName, AnsiString(Password), DecryptedFileContents, ErrorMessage);
 if not Result then Exit;
 Result := (Length(DecryptedFileContents) >= FILE_SUFFIX_LENGTH) and
           (Copy(DecryptedFileContents, Length(DecryptedFileContents) - FILE_SUFFIX_LENGTH + 1, FILE_SUFFIX_LENGTH) = FILE_SUFFIX);
 if not Result then begin
  ErrorMessage := ERROR_MESSAGE_WRONG_PASWORD;
  Exit
 end;
 Delete(DecryptedFileContents, Length(DecryptedFileContents) - FILE_SUFFIX_LENGTH + 1, FILE_SUFFIX_LENGTH);

 ReadOffset := 0;
 CurrentRow := 0;
 while ReadOffset < Length(DecryptedFileContents) do begin
  ReadLnFromString(DecryptedFileContents, ReadOffset, S);
  if AnsiTrim(S) = '' then continue;

  Inc(CurrentRow);
  if CurrentRow >= PasswordStringGrid.RowCount
  then PasswordStringGrid.RowCount := PasswordStringGrid.RowCount + 1;

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[DESCRIPTION_COLUMN, CurrentRow] := StrToUnicodeUnderCodePage(copy(S, 1, i - 1), CP_UTF8);
  Delete(S, 1, i);

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[LOGIN_COLUMN, CurrentRow] := StrToUnicodeUnderCodePage(copy(S, 1, i - 1), CP_UTF8);
  Delete(S, 1, i);

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[PASSWORD_COLUMN, CurrentRow] := StrToUnicodeUnderCodePage(copy(S, 1, i - 1), CP_UTF8);
  Delete(S, 1, i);

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[URL_COLUMN, CurrentRow] := StrToUnicodeUnderCodePage(copy(S, 1, i - 1), CP_UTF8);
  Delete(S, 1, i);

  PasswordStringGrid.Cells[COMMENTS_COLUMN, CurrentRow] := StrToUnicodeUnderCodePage(S, CP_UTF8)
 end;

 i := PasswordStringGrid.RowCount - 1;
 if (i <= 0) or (PasswordStringGrid.Cells[DESCRIPTION_COLUMN, i] <> '') or
    (PasswordStringGrid.Cells[LOGIN_COLUMN, i] <> '') or
    (PasswordStringGrid.Cells[PASSWORD_COLUMN, i] <> '') or
    (PasswordStringGrid.Cells[URL_COLUMN, i] <> '') or
    (PasswordStringGrid.Cells[COMMENTS_COLUMN, i] <> '')
 then begin
  PasswordStringGrid.RowCount := PasswordStringGrid.RowCount + 1;
  for i := 0 to PasswordStringGrid.ColCount - 1 do PasswordStringGrid.Cells[i, PasswordStringGrid.RowCount - 1] := ''
 end
end;

function TMainForm.SaveData(var ErrorMessage : WideString) : boolean;
var Data         : AnsiString;
    Row          : Integer;
begin
 Data := '';
 for Row := 1 to PasswordStringGrid.RowCount - 1
 do Data := Data +
            UnicodeToStrUnderCodePage(PasswordStringGrid.Cells[DESCRIPTION_COLUMN, Row], CP_UTF8, Nil) + TAB +
            UnicodeToStrUnderCodePage(PasswordStringGrid.Cells[LOGIN_COLUMN, Row],       CP_UTF8, Nil) + TAB +
            UnicodeToStrUnderCodePage(PasswordStringGrid.Cells[PASSWORD_COLUMN, Row],    CP_UTF8, Nil) + TAB +
            UnicodeToStrUnderCodePage(PasswordStringGrid.Cells[URL_COLUMN, Row],         CP_UTF8, Nil) + TAB +
            UnicodeToStrUnderCodePage(PasswordStringGrid.Cells[COMMENTS_COLUMN, Row],    CP_UTF8, Nil) + #10;
 Data := Data + FILE_SUFFIX;
 Result := EncryptStringToFile(Data, ChangeFileExt(ParamStr(0), '.csv'), AnsiString(Password), ErrorMessage);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var INIFile      : TIniFile;
    ErrorMessage : WideString;
    i            : integer;
begin
 Caption := ApplicationTitleUntyped + ' - ' + NoWindowCaptured;
 PasswordWindow := 0;
 PredPasswordWindow := 0;
 PredPasswordTitle := '';
 Password := DEFAULT_PASSWORD;
 PasswordStringGrid.Cells[DESCRIPTION_COLUMN, 0] := 'Description';
 PasswordStringGrid.Cells[LOGIN_COLUMN, 0]       := 'Login';
 PasswordStringGrid.Cells[PASSWORD_COLUMN, 0]    := 'Password';
 PasswordStringGrid.Cells[URL_COLUMN, 0]         := 'Web page or file';
 PasswordStringGrid.Cells[COMMENTS_COLUMN, 0]    := 'Comments';
 PasswordStringGrid.Visible := LoadData(ErrorMessage);
 DataModified := false;
 INIFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
 try
  PasswordStringGrid.ColWidths[DESCRIPTION_COLUMN] :=
  INIFile.ReadInteger(SettingsSection, PasswordStringGrid.Cells[DESCRIPTION_COLUMN, 0], DESCRIPTION_DEFAULT_WIDTH);

  PasswordStringGrid.ColWidths[LOGIN_COLUMN] :=
  INIFile.ReadInteger(SettingsSection, PasswordStringGrid.Cells[LOGIN_COLUMN, 0],       LOGIN_NDEFAULT_WIDTH);

  PasswordStringGrid.ColWidths[PASSWORD_COLUMN] :=
  INIFile.ReadInteger(SettingsSection, PasswordStringGrid.Cells[PASSWORD_COLUMN, 0],    PASSWORD_DEFAULT_WIDTH);

  PasswordStringGrid.ColWidths[URL_COLUMN] :=
  INIFile.ReadInteger(SettingsSection, PasswordStringGrid.Cells[URL_COLUMN, 0],         URL_DEFAULT_WIDTH);

  // restoring the window position and internal layout:
  i := INIFile.ReadInteger(WindowSection, LeftItem, MaxInt);
  if i <> MaxInt then Left := i;
  i := INIFile.ReadInteger(WindowSection, TopItem, MaxInt);
  if i <> MaxInt then Top := i;
  i := INIFile.ReadInteger(WindowSection, WidthItem, MaxInt);
  if (i <> MaxInt) and (i >= Constraints.MinWidth) then Width := i;
  i := INIFile.ReadInteger(WindowSection, HeightItem, MaxInt);
  if (i <> Maxint) and (i >= Constraints.MinHeight) then Height := i;
  // adjusting the width:
  if Left < Screen.WorkAreaRect.Left then Left := Screen.WorkAreaRect.Left;
  if Left + Width > Screen.WorkAreaRect.Right then begin
   if Screen.WorkAreaRect.Right - Left > Constraints.MinWidth
   then Width := Screen.WorkAreaRect.Right - Left
   else Width := Constraints.MinWidth;
   if Left + Width { still } > Screen.WorkAreaRect.Right then begin
    Left := Screen.WorkAreaRect.Right - Width;
    if Left < Screen.WorkAreaRect.Left then begin
     Left := Screen.WorkAreaRect.Left;
     Width := Constraints.MinWidth
    end
   end
  end;
  // adjusting the height:
  if Top < Screen.WorkAreaRect.Top then Top := Screen.WorkAreaRect.Top;
  if Top + Height > Screen.WorkAreaRect.Bottom then begin
   if Screen.WorkAreaRect.Bottom - Top > Constraints.MinHeight
   then Height := Screen.WorkAreaRect.Bottom - Top
   else Height := Constraints.MinHeight;
   if Top + Height { still } > Screen.WorkAreaRect.Bottom then begin
    Top := Screen.WorkAreaRect.Bottom - Height;
    if Top < Screen.WorkAreaRect.Top then begin
     Top := Screen.WorkAreaRect.Top;
     Height := Constraints.MinHeight
    end
   end
  end;
  if INIFile.ReadInteger(WindowSection, WindowMaximizedItem, 0) <> 0 // restoring maximized:
  then WindowState := wsMaximized; // PostMessage(Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  // End of restoring the window position and internal layout
 except
 end;
 INIFile.Free();
 PasswordStringGrid.Options := PasswordStringGrid.Options - [goEditing];
 PasswordStringGrid.EditorMode := false;
 OriginalToggleEditingMainMenuItemShortCut := ToggleEditingMainMenuItem.ShortCut;
 OriginalStopEditingMainMenuItemShortCut := StopEditingMainMenuItem.ShortCut;
end;

procedure TMainForm.FormResize(Sender: TObject);
var Sum, i : integer;
begin
 Sum := 0;
 for i := 0 to PasswordStringGrid.ColCount - 2 do Inc(Sum, PasswordStringGrid.ColWidths[i]);
 PasswordStringGrid.ColWidths[COMMENTS_COLUMN] :=
 LongMax(Canvas.TextWidth(PasswordStringGrid.Cells[COMMENTS_COLUMN, 0]), PasswordStringGrid.ClientWidth - Sum - 6);
end;

procedure TMainForm.TimerTimer(Sender: TObject);
const LastForegroundWindowCaption : ShortString = NoWindowCaptured;
var h                             : HWND;
    ForegroundWindowCaption       : ShortString;
begin
 h := GetCurrentHandle(ForegroundWindowCaption);
 if (h <> 0) and
    CompareMem(@ForegroundWindowCaption[0], @ApplicationTitleAsShortString[0], Byte(ApplicationTitleAsShortString[0]) + 1)
 then begin
  h := 0; // do not count itself
  ForegroundWindowCaption := NoWindowCaptured
 end;

 if h <> 0 then begin
  if PasswordWindow <> h then begin
   PredPasswordWindow := PasswordWindow;
   PredPasswordTitle := LastForegroundWindowCaption;
   PasswordWindow := h
  end
 end else begin
  if (PasswordWindow <> 0) and not IsWindowVisible(PasswordWindow) then begin
   if (PredPasswordWindow <> 0) and IsWindowVisible(PredPasswordWindow) then begin
    PasswordWindow := PredPasswordWindow;
    ForegroundWindowCaption := PredPasswordTitle
   end else begin
    PasswordWindow := 0;
    ForegroundWindowCaption := NoWindowCaptured
   end
  end else Exit
 end;
 if ForegroundWindowCaption <> LastForegroundWindowCaption then begin
  LastForegroundWindowCaption := ForegroundWindowCaption;
  Caption := ApplicationTitleAsString + ' - ' + String(ForegroundWindowCaption);
  PasswordStringGrid.Refresh()
 end
end;

procedure TMainForm.EditMenuItemClick(Sender: TObject);
var Row, Col : integer;
begin
 if PasswordStringGrid.EditorMode then begin
  Row := PasswordStringGrid.Row;
  if (Sender = ToggleEditingMainMenuItem) and (Row + 1 >= PasswordStringGrid.RowCount) then begin
   PasswordStringGrid.RowCount := PasswordStringGrid.RowCount + 1;
   for Col := 0 to PasswordStringGrid.ColCount - 1
   do PasswordStringGrid.Cells[Col, PasswordStringGrid.RowCount - 1] := ''
  end;
  Col := PasswordStringGrid.Col + 1;
  if Col >= PasswordStringGrid.ColCount then begin
   Col := 0;
   if Sender = ToggleEditingMainMenuItem then Inc(Row)
  end;
  PasswordStringGrid.Col := Col;
  PasswordStringGrid.Row := Row
 end else begin
  PasswordStringGrid.Options := PasswordStringGrid.Options + [goEditing];
  PasswordStringGrid.EditorMode := true;
  PasswordStringGrid.OnMouseUp :=  Nil;
  DataModified := true;
 end
end;

procedure TMainForm.PasswordStringGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
 if PasswordStringGrid.EditorMode then begin
  PasswordStringGrid.EditorMode := false;
  PasswordStringGrid.OnMouseUp := PasswordStringGridMouseUp;
  PasswordStringGrid.Options := PasswordStringGrid.Options - [goEditing];
  Application.ProcessMessages();
  PasswordStringGrid.EditorMode := false;
  PasswordStringGrid.Options := PasswordStringGrid.Options - [goEditing]
 end
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var INIFile      : TIniFile;
    WndPlacement : TWindowPlacement;
    ErrorMessage : WideString;
begin
 if DataModified and not SaveData(ErrorMessage) then begin
  case MsgBox(Handle, 'Unable to save data due to the following reason: ' +
                      ErrorMessage +
                      #13#10#13#10'Would you like to discard the changes you might have made during this session?',
                      ApplicationTitleUntyped, MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) of
   ID_NO  : begin CanClose := false; Exit end;
   ID_YES : { do nothing };
   else     { do nothing };
  end // case
 end;
 INIFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
 try
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[DESCRIPTION_COLUMN, 0], PasswordStringGrid.ColWidths[DESCRIPTION_COLUMN]);
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[LOGIN_COLUMN, 0],       PasswordStringGrid.ColWidths[LOGIN_COLUMN]);
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[PASSWORD_COLUMN, 0],    PasswordStringGrid.ColWidths[PASSWORD_COLUMN]);
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[URL_COLUMN, 0],         PasswordStringGrid.ColWidths[URL_COLUMN]);

  // saving the main window placement and state:
  INIFile.WriteInteger(WindowSection, WindowMaximizedItem, Byte(WindowState = wsMaximized));
  FillChar(WndPlacement, sizeof(WndPlacement), 0);
  WndPlacement.Length := sizeof(WndPlacement);
  if not GetWindowPlacement(Handle, @WndPlacement) then begin
   // to ignore when loading:
   WndPlacement.rcNormalPosition.Left   := MaxInt;
   WndPlacement.rcNormalPosition.Top    := MaxInt;
   WndPlacement.rcNormalPosition.Right  := MaxInt;
   WndPlacement.rcNormalPosition.Bottom := MaxInt
  end;
  INIFile.WriteInteger(WindowSection, LeftItem, WndPlacement.rcNormalPosition.Left);
  INIFile.WriteInteger(WindowSection, TopItem, WndPlacement.rcNormalPosition.Top);
  INIFile.WriteInteger(WindowSection, WidthItem, WndPlacement.rcNormalPosition.Right - WndPlacement.rcNormalPosition.Left);
  INIFile.WriteInteger(WindowSection, HeightItem, WndPlacement.rcNormalPosition.Bottom - WndPlacement.rcNormalPosition.Top);
 except
 end;
 INIFile.Free();
end;

procedure TMainForm.PasswordStringGridDoubleClick(Sender: TObject);
var TextToType             : WideString;
    CurrentCol, CurrentRow : integer;
begin
 CurrentRow := PasswordStringGrid.Row;
 CurrentCol := PasswordStringGrid.Col;
 if (CurrentRow <= 0) or (CurrentRow >= PasswordStringGrid.RowCount) or
    (CurrentCol < 0)  or (CurrentCol >= PasswordStringGrid.ColCount)
 then Exit;
 case CurrentCol of
  DESCRIPTION_COLUMN, COMMENTS_COLUMN : { do nothing };
  LOGIN_COLUMN, PASSWORD_COLUMN : begin
   TextToType := PasswordStringGrid.Cells[CurrentCol, CurrentRow];
   if (PasswordWindow <> 0) and IsWindow(PasswordWindow) and (TextToType <> '') then begin
    SetForegroundWindow(PasswordWindow);
    SendText(TextToType)
   end
  end;
  URL_COLUMN : begin
   TextToType := PasswordStringGrid.Cells[CurrentCol, CurrentRow];
   if TextToType <> '' then begin
    if ShellExecuteW(handle, 'open', PWideChar(TextToType), Nil, Nil, SW_SHOW) <= 32
    then MsgBox(Handle, 'Error opening ' + TextToType, ApplicationTitleUntyped, MB_OK + MB_ICONINFORMATION)
   end
  end
  // else do nothing
 end
end;

procedure TMainForm.AboutMenuItemClick(Sender: TObject);
begin
 if HelpForm.WebBrowser.LocationURL = '' then HelpForm.WebBrowser.Navigate('res://' + ParamStr(0) + '/HELP_ENTRY');
 HelpForm.Show()
end;

procedure TMainForm.DeleteRowMenuItemClick(Sender: TObject);
var CurrentRow, Row, Col : integer;
begin
 CurrentRow := PasswordStringGrid.Row;
 if (CurrentRow <= 0) or (CurrentRow >= PasswordStringGrid.RowCount) then Exit;

 if PasswordStringGrid.EditorMode
 then EditMenuItemClick(Sender);
 PasswordStringGrid.Col := 0;

 for Row := CurrentRow + 1 to PasswordStringGrid.RowCount - 1 do begin
  for Col := 0 to PasswordStringGrid.ColCount - 1
  do PasswordStringGrid.Cells[Col, Row - 1] := PasswordStringGrid.Cells[Col, Row]
 end;
 if PasswordStringGrid.RowCount = 2
 then for Col := 0 to PasswordStringGrid.ColCount - 1 do PasswordStringGrid.Cells[Col, 1] := ''
 else PasswordStringGrid.RowCount := PasswordStringGrid.RowCount - 1;
 DataModified := true
end;

procedure TMainForm.InsertRowMenuItemClick(Sender: TObject);
var CurrentRow, Row, Col : integer;
begin
 CurrentRow := PasswordStringGrid.Row;
 if (CurrentRow <= 0) or (CurrentRow >= PasswordStringGrid.RowCount) then Exit;

 PasswordStringGrid.RowCount := PasswordStringGrid.RowCount + 1;
 for Row := PasswordStringGrid.RowCount - 1 downto CurrentRow + 1 do begin
  for Col := 0 to PasswordStringGrid.ColCount - 1
  do PasswordStringGrid.Cells[Col, Row] := PasswordStringGrid.Cells[Col, Row - 1]
 end;
 for Col := 0 to PasswordStringGrid.ColCount - 1 do PasswordStringGrid.Cells[Col, CurrentRow] := '';
 DataModified := true
end;

procedure TMainForm.MoveUpMenuItemClick(Sender: TObject);
var CurrentRow, Col : integer;
    Tmp             : WideString;
begin
 CurrentRow := PasswordStringGrid.Row;
 if (CurrentRow <= 1) or (CurrentRow >= PasswordStringGrid.RowCount) then Exit;
 for Col := 0 to PasswordStringGrid.ColCount - 1 do begin
  Tmp := PasswordStringGrid.Cells[Col, CurrentRow];
  PasswordStringGrid.Cells[Col, CurrentRow] := PasswordStringGrid.Cells[Col, CurrentRow - 1];
  PasswordStringGrid.Cells[Col, CurrentRow - 1] := Tmp
 end;
 PasswordStringGrid.Row := CurrentRow - 1;
 DataModified := true
end;

procedure TMainForm.MoveDownMenuItemClick(Sender: TObject);
var CurrentRow, Col : integer;
    Tmp             : WideString;
begin
 CurrentRow := PasswordStringGrid.Row;
 if (CurrentRow <= 0) or (CurrentRow + 1 >= PasswordStringGrid.RowCount) then Exit;
 for Col := 0 to PasswordStringGrid.ColCount - 1 do begin
  Tmp := PasswordStringGrid.Cells[Col, CurrentRow];
  PasswordStringGrid.Cells[Col, CurrentRow] := PasswordStringGrid.Cells[Col, CurrentRow + 1];
  PasswordStringGrid.Cells[Col, CurrentRow + 1] := Tmp
 end;
 PasswordStringGrid.Row := CurrentRow + 1;
 DataModified := true
end;

procedure TMainForm.FindMenuItemClick(Sender: TObject);
begin
 try FindForm.ActiveControl := FindForm.FindTextEdit except end;
 FindForm.Show()
end;

procedure TMainForm.FindItem(var Msg : TMessage); // message WM_USER + 1;
var SearchString                                     : widestring;
    CurrentRow, OriginalRow, CurrentCol, OriginalCol : integer;
    procedure Increment(var ACol, ARow : integer);
    begin
     Inc(ACol); if ACol = PASSWORD_COLUMN then Inc(ACol);
     if ACol >= PasswordStringGrid.ColCount then begin
      ACol := 0;
      Inc(ARow);
      if ARow >= PasswordStringGrid.RowCount then ARow := 1
     end
    end;
    procedure Decrement(var ACol, ARow : integer);
    begin
     Dec(ACol); if ACol = PASSWORD_COLUMN then Dec(ACol);
     if ACol < 0 then begin
      ACol := PasswordStringGrid.ColCount - 1;
      Dec(ARow);
      if ARow < 1 then ARow := PasswordStringGrid.RowCount - 1
     end
    end;
begin
 Msg.Result := 0;
 SearchString := WideUppercase(FindForm.FindTextEdit.Text);
 CurrentRow := LongMin(LongMax(PasswordStringGrid.Row, 1), PasswordStringGrid.RowCount - 1);
 OriginalRow := CurrentRow;
 CurrentCol := LongMin(LongMax(PasswordStringGrid.Col, 0), PasswordStringGrid.ColCount - 1);
 OriginalCol := CurrentCol;

 repeat
  if Msg.WParam <> 0
  then Increment(CurrentCol, CurrentRow)
  else Decrement(CurrentCol, CurrentRow);
  if Pos(SearchString, WideUpperCase(PasswordStringGrid.Cells[CurrentCol, CurrentRow])) > 0 then begin
   PasswordStringGrid.Col := CurrentCol;
   PasswordStringGrid.Row := CurrentRow;
   Exit
  end;
 until (CurrentRow = OriginalRow) and (CurrentCol = OriginalCol);

 FindForm.Hide();
 MsgBox(Handle, 'No occurrences found for "' + FindForm.FindTextEdit.Text + '".', ApplicationTitleUntyped, MB_OK + MB_ICONINFORMATION);
 FindForm.Show()
end;

procedure TMainForm.PasswordStringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var StringToDraw                       : WideString;
    i, TextWidth, SpaceWidth, TextLeft : integer;
begin
 PasswordStringGrid.Canvas.Brush.Style := bsClear;

 if (ARow < 0) or (ARow > PasswordStringGrid.RowCount) or (ACol < 0) or (ACol >= PasswordStringGrid.ColCount) then begin
  PasswordStringGrid.Canvas.Brush.Color := clWindow;
  PasswordStringGrid.Canvas.FillRect(Rect);
  Exit
 end;

 StringToDraw := PasswordStringGrid.Cells[ACol, ARow];
 if ARow = 0 then begin
  DrawFrameControl(PasswordStringGrid.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH);
  TextWidth := PasswordStringGrid.Canvas.TextWidth(StringToDraw);
  SpaceWidth := PasswordStringGrid.Canvas.TextWidth('W');
  TextLeft := (Rect.Left + Rect.Right - TextWidth - SpaceWidth) DIV 2 - 1;

  if PasswordWindow <> 0 then begin
   PasswordStringGrid.Canvas.Font.Color := clWindowText;
   PasswordStringGrid.Canvas.Font.Style := PasswordStringGrid.Canvas.Font.Style + [fsBold]
  end else begin
   PasswordStringGrid.Canvas.Font.Color := clInactiveCaptionText;
   PasswordStringGrid.Canvas.Font.Style := PasswordStringGrid.Canvas.Font.Style - [fsBold]
  end;
  PasswordStringGrid.Canvas.TextRect(Rect, TextLeft, Rect.Top + 2, StringToDraw)
 end { Row = 0 } else begin
  if ACol = PASSWORD_COLUMN then for i := 1 to Length(StringToDraw) do StringToDraw[i] := '*';

  if gdSelected in State then begin
   PasswordStringGrid.Canvas.Brush.Color := clHighlight;
   PasswordStringGrid.Canvas.Font.Color  := clHighlightText
  end else begin
   PasswordStringGrid.Canvas.Brush.Color := clWindow;
   if PasswordWindow <> 0
   then PasswordStringGrid.Canvas.Font.Color := clWindowText
   else PasswordStringGrid.Canvas.Font.Color := clInactiveCaptionText;
  end;
  PasswordStringGrid.Canvas.Font.Style := PasswordStringGrid.Canvas.Font.Style - [fsBold];
  PasswordStringGrid.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, StringToDraw)
 end { Row <> 0 }
end;

procedure TMainForm.PasswordStringGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ScreenCursorPoint, CursorPoint : TPoint;
    ACol, ARow                     : integer;
begin
 if (Button = mbRight) and GetCursorPos(ScreenCursorPoint) then begin
  CursorPoint := PasswordStringGrid.ScreenToClient(ScreenCursorPoint);
  PasswordStringGrid.MouseToCell(CursorPoint.X, CursorPoint.Y, ACol, ARow);
  if (0 < ARow) and (ARow < PasswordStringGrid.RowCount) and
     (0 <= ACol) and (ACol < PasswordStringGrid.ColCount)
  then begin
   PasswordStringGrid.Row := ARow;
   PasswordStringGrid.Col := ACol
  end
 end
end;

procedure TMainForm.SelectAllMenuItemClick(Sender: TObject);
begin
 if PasswordStringGrid.EditorMode
 then PostMessage(GetFocus(), EM_SETSEL, 0, -1)
 // else nothing
end;

procedure TMainForm.CopyMenuItemClick(Sender: TObject);
var Col, Row : integer;
begin
 if PasswordStringGrid.EditorMode
 then PostMessage(GetFocus(), WM_COPY, 0, 0)
 else begin
  Col := PasswordStringGrid.Col;
  Row := PasswordStringGrid.Row;
  if (0 < Row) and (Row < PasswordStringGrid.RowCount) and
     (0 <= Col) and (Col < PasswordStringGrid.ColCount) and
     (PasswordStringGrid.Cells[Col, Row] <> '')
  then Clipboard.AsText := PasswordStringGrid.Cells[Col, Row]
 end
end;

procedure TMainForm.CutMenuItemClick(Sender: TObject);
var Col, Row : integer;
begin
 if PasswordStringGrid.EditorMode
 then PostMessage(GetFocus(), WM_CUT, 0, 0)
 else begin
  Col := PasswordStringGrid.Col;
  Row := PasswordStringGrid.Row;
  if (0 < Row) and (Row < PasswordStringGrid.RowCount) and
     (0 <= Col) and (Col < PasswordStringGrid.ColCount) and
     (PasswordStringGrid.Cells[Col, Row] <> '')
  then begin
   Clipboard.AsText := PasswordStringGrid.Cells[Col, Row];
   PasswordStringGrid.Cells[Col, Row] := '';
   DataModified := true
  end
 end
end;

procedure TMainForm.UndoMenuItemClick(Sender: TObject);
begin
 if PasswordStringGrid.EditorMode
 then PostMessage(GetFocus(), EM_UNDO, 0, 0)
 // else nothing
end;

procedure TMainForm.PasteMenuItemClick(Sender: TObject);
var Col, Row : integer;
begin
 if PasswordStringGrid.EditorMode
 then PostMessage(GetFocus(), WM_PASTE, 0, 0)
 else begin
  Col := PasswordStringGrid.Col;
  Row := PasswordStringGrid.Row;
  if (0 < Row) and (Row < PasswordStringGrid.RowCount) and
     (0 <= Col) and (Col < PasswordStringGrid.ColCount)
  then begin
   PasswordStringGrid.Cells[Col, Row] := Clipboard.AsText;
   DataModified := true
  end
 end
end;

procedure TMainForm.DeleteMenuItemClick(Sender: TObject);
var Col, Row : integer;
begin
 if PasswordStringGrid.EditorMode
 then PostMessage(GetFocus(), WM_CLEAR, 0, 0)
 else begin
  Col := PasswordStringGrid.Col;
  Row := PasswordStringGrid.Row;
  if (0 < Row) and (Row < PasswordStringGrid.RowCount) and
     (0 <= Col) and (Col < PasswordStringGrid.ColCount)
  then begin
   PasswordStringGrid.Cells[Col, Row] := '';
   DataModified := true
  end
 end
end;

procedure TMainForm.ExitMainMenuItemClick(Sender: TObject);
begin
 Close()
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
 ToggleEditingMainMenuItem.ShortCut := OriginalToggleEditingMainMenuItemShortCut;
 StopEditingMainMenuItem.ShortCut := OriginalStopEditingMainMenuItemShortCut;
end;

procedure TMainForm.FormDeactivate(Sender: TObject);
begin
 ToggleEditingMainMenuItem.ShortCut := 0;
 StopEditingMainMenuItem.ShortCut := 0
end;

procedure TMainForm.EditMainMenuItemClick(Sender: TObject);
begin
 MoveUpMainMenuItem.Enabled         := PasswordStringGrid.Visible and (PasswordStringGrid.Row > 1);
 MoveDownMainMenuItem.Enabled       := PasswordStringGrid.Visible and (PasswordStringGrid.Row + 1 < PasswordStringGrid.RowCount);
 InsertRowMainMenuItem.Enabled      := PasswordStringGrid.Visible;
 DeleteRowMainMenuItem.Enabled      := PasswordStringGrid.Visible;
 ToggleEditingMainMenuItem.Enabled  := PasswordStringGrid.Visible;
 StopEditingMainMenuItem.Enabled    := PasswordStringGrid.Visible and PasswordStringGrid.EditorMode
end;

procedure TMainForm.PasswordMainMenuItemClick(Sender: TObject);
begin
 TypeMainMenuItem.Enabled := PasswordStringGrid.Visible and
   (0 < PasswordStringGrid.Row) and (PasswordStringGrid.Row < PasswordStringGrid.RowCount) and
   (PasswordStringGrid.Col in [LOGIN_COLUMN, PASSWORD_COLUMN]) and
   (PasswordWindow <> 0) and IsWindowVisible(PasswordWindow);
 AppendRandomMainMenuItem.Enabled := PasswordStringGrid.Visible and (PasswordStringGrid.Col = PASSWORD_COLUMN);
 FindMainMenuItem.Enabled := PasswordStringGrid.Visible;
end;

procedure TMainForm.AppendRandomMenuItemClick(Sender: TObject);
var Col, Row : integer;
begin
 Col := PasswordStringGrid.Col; if Col <> PASSWORD_COLUMN then Exit;
 Row := PasswordStringGrid.Row; if (Row <= 0) or (Row >= PasswordStringGrid.RowCount) then Exit;
 PasswordStringGrid.Cells[Col, Row] := PasswordStringGrid.Cells[Col, Row] + string(GenerateRandom8Chars());
 DataModified := true;
end;

procedure TMainForm.FileMenuItemClick(Sender: TObject);
begin
 OpenUrltMainMenuItem.Enabled := PasswordStringGrid.Col = URL_COLUMN;
 OpenMainMenuItem.Enabled := not PasswordStringGrid.Visible;
 SaveMainMenuItem.Enabled := PasswordStringGrid.Visible;
end;

procedure TMainForm.CellMainMenuItemClick(Sender: TObject);
var TextSelected, CellFilledIn : boolean;
    SelStart, SelEnd, TextLen  : integer;
    FocusWindow                : HWND;
    Col, Row                   : integer;
begin
 if PasswordStringGrid.EditorMode then begin
  FocusWindow := GetFocus();
  UndoMainMenuItem.Enabled := SendMessage(FocusWindow, EM_CANUNDO, 0, 0) <> 0;
  Undo1MainMenuItem.Enabled := UndoMainMenuItem.Enabled;
  TextLen := SendMessage(FocusWindow, WM_GETTEXTLENGTH, 0, 0);
  SendMessage(FocusWindow, EM_GETSEL, wParam(@SelStart), lParam(@SelEnd));
  TextSelected := SelEnd - SelStart > 0;
  CutMainMenuItem.Enabled := TextSelected;
  CopyMainMenuItem.Enabled := TextSelected;
  DeleteMainMenuItem.Enabled := TextSelected;
  PasteMainMenuItem.Enabled := IsClipboardFormatAvailable(CF_TEXT);
  SelectAllMainMenuItem.Enabled := (TextLen > 0) and (TextLen <> SelEnd - SelStart)
 end else begin
  Col := PasswordStringGrid.Col;
  Row := PasswordStringGrid.Row;
  TextSelected := PasswordStringGrid.Visible and
                  (0 < Row) and (Row < PasswordStringGrid.RowCount) and
                  (0 <= Col) and (Col < PasswordStringGrid.ColCount);
  CellFilledIn := TextSelected and (PasswordStringGrid.Cells[Col, Row] <> '');

  UndoMainMenuItem.Enabled := false;
  Undo1MainMenuItem.Enabled := false;
  CutMainMenuItem.Enabled := CellFilledIn;
  CopyMainMenuItem.Enabled := CellFilledIn;
  DeleteMainMenuItem.Enabled := CellFilledIn;
  PasteMainMenuItem.Enabled := TextSelected and IsClipboardFormatAvailable(CF_TEXT);
  SelectAllMainMenuItem.Enabled := False
 end
end;

procedure TMainForm.OpenMainMenuItemClick(Sender: TObject);
var OpenPasswordForm : TOpenPasswordForm;
    ErrorMessage     : WideString;
begin
 Application.CreateForm(TOpenPasswordForm, OpenPasswordForm);
 if Password = DEFAULT_PASSWORD
 then OpenPasswordForm.PasswordEdit.Text := ''
 else OpenPasswordForm.PasswordEdit.Text := Password;
 OpenPasswordForm.ShowModal();
 if OpenPasswordForm.OkPressed then begin
  Password := OpenPasswordForm.PasswordEdit.Text;
  if Password = '' then Password := DEFAULT_PASSWORD;
  if LoadData(ErrorMessage) then begin
   PasswordStringGrid.Visible := true;
   FormResize(Sender);
   DataModified := false
  end else begin
   if ErrorMessage = ERROR_MESSAGE_WRONG_PASWORD then begin
    if MsgBox(handle, ErrorMessage, ApplicationTitleUntyped, MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = ID_YES then begin
     if CopyFile(PChar(ChangeFileExt(ParamStr(0), '.csv')), PChar(ChangeFileExt(ParamStr(0), '.bak')), false) and
        DeleteFile(ChangeFileExt(ParamStr(0), '.csv'))
     then begin
      PasswordStringGrid.Visible := true;
      FormResize(Sender);
      DataModified := false;
      Password := DEFAULT_PASSWORD;
      MsgBox(Handle, 'The file '#13#10 + ChangeFileExt(ParamStr(0), '.csv') + #13#10'has been copied into'#13#10 + ChangeFileExt(ParamStr(0), '.bak') +
             #13#10#13#10'To restore the original file in the future, close this application, copy the file in the reverse order manually, and restart Password Manager.',
             ApplicationTitleUntyped, MB_OK + MB_ICONINFORMATION);
     end else MsgBox(handle, 'Unable to rename ' + ChangeFileExt(ParamStr(0), '.csv') + ' into ' + ChangeFileExt(ParamStr(0), '.bak'),
                     ApplicationTitleUntyped, MB_OK + MB_ICONSTOP)
    end
   end else MsgBox(handle, ErrorMessage, ApplicationTitleUntyped, MB_OK + MB_ICONSTOP)
  end
 end;
 OpenPasswordForm.Free();
end;

procedure TMainForm.SaveMainMenuItemClick(Sender: TObject);
var SavePasswordForm          : TSavePasswordForm;
    ErrorMessage, WasPassword : WideString;
begin
 Application.CreateForm(TSavePasswordForm, SavePasswordForm);
 if Password = DEFAULT_PASSWORD
 then SavePasswordForm.PasswordEdit.Text := ''
 else SavePasswordForm.PasswordEdit.Text := Password;
 SavePasswordForm.ConfirmPasswordEdit.Text := SavePasswordForm.PasswordEdit.Text;
 SavePasswordForm.ShowModal();
 if SavePasswordForm.OkPressed then begin
  WasPassword := Password;
  Password := SavePasswordForm.PasswordEdit.Text;
  if Password = '' then Password := DEFAULT_PASSWORD;
  if SaveData(ErrorMessage) then begin
   DataModified := false;
   if Password <> WasPassword then begin
    if Password = DEFAULT_PASSWORD
    then ShowPasswordForm.PasswordEdit.Text := ''
    else ShowPasswordForm.PasswordEdit.Text := SavePasswordForm.PasswordEdit.Text;
    ShowPasswordForm.ShowKeywordCheckBox.Checked := false;
    ShowPasswordForm.Show()
   end
  end else MsgBox(handle, ErrorMessage, ApplicationTitleUntyped, MB_OK + MB_ICONSTOP)
 end;
 SavePasswordForm.Free();
end;

End.
