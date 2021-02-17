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

unit MainUnit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, Menus;

type

  { TMainForm }

  TMainForm = class(TForm)
    ExitWithoutSavingMainMenuItem: TMenuItem;
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
    procedure ExitWithoutSavingMainMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PasswordStringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PasswordStringGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PasswordStringGridSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: string);
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
    function LoadData(out ErrorMessage : WideString) : boolean;
    function SaveData(out ErrorMessage : WideString) : boolean;
    procedure FindItem(var Msg : TMessage); message WM_USER + 1;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses { UITypes, }
     Windows, FileCypher, InitUnit, IniFiles, Clipbrd, Functs, FindUnit,
     SavePasswordUnit, OpenPasswordUnit, ShowPasswordUnit, HelpUnit,
     CommentsUnit;

{$R *.lfm}
{$R WindowsXP.res}
{$R help.res} // navigate browser to "res://C:\.....\PssMngr.exe/HELP_ENTRY"

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

var EXE_NAME : WideString; // initialized in the Initialization section

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

function TMainForm.LoadData(out ErrorMessage : WideString) : boolean;
var S, DecryptedFileContents  : AnsiString;
    i, CurrentRow, ReadOffset : Integer;
    FileName                  : WideString;
begin
 ErrorMessage := '';
 FileName := StrToUnicodeUnderCodePage(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.csv'), CP_UTF8);
 if not FileExists(FileName) then begin
  PasswordStringGrid.RowCount := 2;
  for i := 0 to PasswordStringGrid.ColCount - 1 do PasswordStringGrid.Cells[i, PasswordStringGrid.RowCount - 1] := '';
  Result := true;
  Exit
 end;

 Result := DecryptFileToString(FileName, UnicodeToStrUnderCodePage(Password, CP_UTF8, Nil), DecryptedFileContents, ErrorMessage);
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
  PasswordStringGrid.Cells[DESCRIPTION_COLUMN, CurrentRow] := copy(S, 1, i - 1);
  Delete(S, 1, i);

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[LOGIN_COLUMN, CurrentRow] := copy(S, 1, i - 1);
  Delete(S, 1, i);

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[PASSWORD_COLUMN, CurrentRow] := copy(S, 1, i - 1);
  Delete(S, 1, i);

  i := AnsiCharPos(TAB, S); if i <= 0 then i := Length(S) + 1;
  PasswordStringGrid.Cells[URL_COLUMN, CurrentRow] := copy(S, 1, i - 1);
  Delete(S, 1, i);

  PasswordStringGrid.Cells[COMMENTS_COLUMN, CurrentRow] := S
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

function TMainForm.SaveData(out ErrorMessage : WideString) : boolean;
var Data : AnsiString;
    Row  : Integer;
begin
 Data := '';
 for Row := 1 to PasswordStringGrid.RowCount - 1
 do Data := Data +
            PasswordStringGrid.Cells[DESCRIPTION_COLUMN, Row] + TAB +
            PasswordStringGrid.Cells[LOGIN_COLUMN, Row]       + TAB +
            PasswordStringGrid.Cells[PASSWORD_COLUMN, Row]    + TAB +
            PasswordStringGrid.Cells[URL_COLUMN, Row]         + TAB +
            PasswordStringGrid.Cells[COMMENTS_COLUMN, Row]    + #10;
 Data := Data + FILE_SUFFIX;
 Result := EncryptStringToFile(Data,
                               StrToUnicodeUnderCodePage(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.csv'), CP_UTF8),
                               UnicodeToStrUnderCodePage(Password, CP_UTF8, Nil),
                               ErrorMessage);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var INIFile      : TIniFile;
    ErrorMessage : WideString;
    i, j, k, l   : integer;
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
 INIFile := TIniFile.Create(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.ini'));
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
  j := INIFile.ReadInteger(WindowSection, TopItem, MaxInt);
  k := INIFile.ReadInteger(WindowSection, WidthItem, MaxInt);
  l := INIFile.ReadInteger(WindowSection, HeightItem, MaxInt);
  if (i <> MaxInt) and (j <> MaxInt) and
     (k <> MaxInt) and (k >= Constraints.MinWidth) and
     (l <> MaxInt) and (l >= Constraints.MinHeight)
  then begin
   Left := i;
   Top  := j;
   Width := k;
   Height := l;
  end else begin
   Left := 0;
   Top  := 0;
   Width := Constraints.MinWidth;
   Height := Constraints.MinHeight;
  end;
  // adjusting the width:
  i := Screen.WorkAreaRect.Left;
  j := Screen.WorkAreaRect.Top;
  k := Screen.WorkAreaRect.Width - 8;
  l := Screen.WorkAreaRect.Height - 32;
  if Left < i then Left := i;
  if Left + Width > i + k then begin
   if i + k - Left > Constraints.MinWidth
   then Width := i + k - Left
   else Width := Constraints.MinWidth;
   if Left + Width { still } > i + k then begin
    Left := i + k - Width;
    if Left < i then begin
     Left := i;
     Width := Constraints.MinWidth
    end
   end
  end;
  // adjusting the height:
  if Top < j then Top := j;
  if Top + Height > j + l then begin
   if j + l - Top > Constraints.MinHeight
   then Height := j + l - Top
   else Height := Constraints.MinHeight;
   if Top + Height { still } > j + l then begin
    Top := j + l - Height;
    if Top < j then begin
     Top := j;
     Height := Constraints.MinHeight
    end
   end
  end;
  if INIFile.ReadInteger(WindowSection, WindowMaximizedItem, 0) <> 0 // restoring maximized:
  then PostMessage(Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  // End of restoring the window position and internal layout
 except
 end;
 INIFile.Free();
 PasswordStringGrid.Options := PasswordStringGrid.Options - [goEditing];
 PasswordStringGrid.EditorMode := false;
 OriginalToggleEditingMainMenuItemShortCut := ToggleEditingMainMenuItem.ShortCut;
 OriginalStopEditingMainMenuItemShortCut := StopEditingMainMenuItem.ShortCut;
end;

procedure TMainForm.ExitWithoutSavingMainMenuItemClick(Sender: TObject);
begin
 if not DataModified then begin Close(); Exit end;
 if Application.MessageBox('Would you like to exit and discard the changes you might have made during this session?',
                           ApplicationTitleUntyped, MB_YESNO + MB_ICONQUESTION) <> IDYES
 then Exit; // do nothing
 DataModified := False;
 Close();
end;

procedure TMainForm.PasswordStringGridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if (Key = 13) and (Shift = []) then Key := 0; // to prevent selection of the grid cell text
end;

procedure TMainForm.PasswordStringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var row : integer;
begin
 // The main menu ctrl+up/down shortcuts do not work in Lazarus grids, so handling them here.
 if (key = 38) and (Shift = [ssCtrl]) then begin
  MoveUpMenuItemClick(Sender);
  row := PasswordStringGrid.Row;
  if (1 < row) and (row < PasswordStringGrid.RowCount) then PasswordStringGrid.Row := row + 1;
  Exit
 end;
 if (key = 40) and (Shift = [ssCtrl]) then begin
  MoveDownMenuItemClick(Sender);
  row := PasswordStringGrid.Row;
  if (1 < row) and (row <= PasswordStringGrid.RowCount) then PasswordStringGrid.Row := row - 1;
 end;
end;

procedure TMainForm.PasswordStringGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
 DataModified := True;
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
  PasswordStringGrid.OnMouseUp :=  Nil;
  PasswordStringGrid.Options := PasswordStringGrid.Options + [goEditing];
  PasswordStringGrid.EditorMode := true;
  PostMessage(GetFocus(), EM_SETSEL, 0, 0);
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
    ErrorMessage : WideString;
begin
 if DataModified and not SaveData(ErrorMessage) then begin
  case Application.MessageBox(PChar('Unable to save data due to the following reason: ' +
                      UnicodeToStrUnderCodePage(ErrorMessage, CP_UTF8, Nil) +
                      #13#10#13#10'Would you like to exit and discard the changes you might have made during this session?'),
                      ApplicationTitleUntyped, MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) of
   ID_NO  : begin CanClose := false; Exit end;
   ID_YES : { do nothing };
   else     { do nothing };
  end // case
 end;
 INIFile := TIniFile.Create(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.ini'));
 try
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[DESCRIPTION_COLUMN, 0], PasswordStringGrid.ColWidths[DESCRIPTION_COLUMN]);
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[LOGIN_COLUMN, 0],       PasswordStringGrid.ColWidths[LOGIN_COLUMN]);
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[PASSWORD_COLUMN, 0],    PasswordStringGrid.ColWidths[PASSWORD_COLUMN]);
  INIFile.WriteInteger(SettingsSection, PasswordStringGrid.Cells[URL_COLUMN, 0],         PasswordStringGrid.ColWidths[URL_COLUMN]);

  // saving the main window placement and state:
  INIFile.WriteInteger(WindowSection, WindowMaximizedItem, Byte(WindowState = wsMaximized));
  if WindowState <> wsNormal then begin
   WindowState := wsNormal;
   Application.ProcessMessages();
  end;
  INIFile.WriteInteger(WindowSection, LeftItem, Left);
  INIFile.WriteInteger(WindowSection, TopItem, Top);
  INIFile.WriteInteger(WindowSection, WidthItem, Width);
  INIFile.WriteInteger(WindowSection, HeightItem, Height);
 except
 end;
 INIFile.Free();
end;

procedure TMainForm.PasswordStringGridDoubleClick(Sender: TObject);
var TextToType             : WideString;
    S                      : AnsiString;
    CurrentCol, CurrentRow : integer;
begin
 CurrentRow := PasswordStringGrid.Row;
 CurrentCol := PasswordStringGrid.Col;
 if (CurrentRow <= 0) or (CurrentRow >= PasswordStringGrid.RowCount) or
    (CurrentCol < 0)  or (CurrentCol >= PasswordStringGrid.ColCount)
 then Exit;
 case CurrentCol of
  DESCRIPTION_COLUMN : { do nothing };
  COMMENTS_COLUMN : begin
   S := StrRepl(PasswordStringGrid.Cells[CurrentCol, CurrentRow], #32#9, #13#10);
   CommentsForm.CommentsMemo.Text := S;
   CommentsForm.ShowModal();
   if CommentsForm.CommentsMemo.Text <> S then begin
    PasswordStringGrid.Cells[CurrentCol, CurrentRow] := StrRepl(CommentsForm.CommentsMemo.Text, #13#10, #32#9);
    DataModified := True;
   end;
  end;
  LOGIN_COLUMN, PASSWORD_COLUMN : begin
   TextToType := StrToUnicodeUnderCodePage(PasswordStringGrid.Cells[CurrentCol, CurrentRow], CP_UTF8);
   if (PasswordWindow <> 0) and IsWindow(PasswordWindow) and (TextToType <> '') then begin
    SetForegroundWindow(PasswordWindow);
    SendText(TextToType)
   end
  end;
  URL_COLUMN : begin
   TextToType := StrToUnicodeUnderCodePage(PasswordStringGrid.Cells[CurrentCol, CurrentRow], CP_UTF8);
   if TextToType <> '' then begin
    if ShellExecuteW(handle, 'open', PWideChar(TextToType), Nil, Nil, SW_SHOW) <= 32
    then Application.MessageBox(PChar('Error opening ' + UnicodeToStrUnderCodePage(TextToType, CP_UTF8, Nil)),
                                ApplicationTitleUntyped, MB_OK + MB_ICONINFORMATION)
   end
  end
  // else do nothing
 end
end;

procedure TMainForm.AboutMenuItemClick(Sender: TObject);
begin
 HelpUnit.ShowHelp('res://' + EXE_NAME + '/HELP_ENTRY')
end;

procedure TMainForm.DeleteRowMenuItemClick(Sender: TObject);
var CurrentRow, Row, Col : integer;
begin
 CurrentRow := PasswordStringGrid.Row;
 if (CurrentRow <= 0) or (CurrentRow >= PasswordStringGrid.RowCount) then Exit;

 if Application.MessageBox('Delete the selected row, are you sure?',
                           ApplicationTitleUntyped, MB_YESNO + MB_ICONQUESTION) <> IDYES
 then Exit;

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
    Tmp             : String;
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
    Tmp             : String;
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
 FindForm.FindTextEdit.SelectAll();
 FindForm.Show()
end;

procedure TMainForm.FindItem(var Msg : TMessage); // message WM_USER + 1;
var SearchString                                     : widestring;
    CurrentRow, OriginalRow, CurrentCol, OriginalCol : integer;
    procedure Increment(var ACol, ARow : integer);
    begin
     Inc(ACol);
     if ACol >= PasswordStringGrid.ColCount then begin
      ACol := 0;
      Inc(ARow);
      if ARow >= PasswordStringGrid.RowCount then ARow := 1
     end
    end;
    procedure Decrement(var ACol, ARow : integer);
    begin
     Dec(ACol);
     if ACol < 0 then begin
      ACol := PasswordStringGrid.ColCount - 1;
      Dec(ARow);
      if ARow < 1 then ARow := PasswordStringGrid.RowCount - 1
     end
    end;
begin
 Msg.Result := 0;
 SearchString := WideUppercase(StrToUnicodeUnderCodePage(FindForm.FindTextEdit.Text, CP_UTF8));
 CurrentRow := LongMin(LongMax(PasswordStringGrid.Row, 1), PasswordStringGrid.RowCount - 1);
 OriginalRow := CurrentRow;
 CurrentCol := LongMin(LongMax(PasswordStringGrid.Col, 0), PasswordStringGrid.ColCount - 1);
 OriginalCol := CurrentCol;

 repeat
  if Msg.WParam <> 0
  then Increment(CurrentCol, CurrentRow)
  else Decrement(CurrentCol, CurrentRow);
  if (CurrentCol <> PASSWORD_COLUMN) and
     (Pos(SearchString, WideUpperCase(StrToUnicodeUnderCodePage(PasswordStringGrid.Cells[CurrentCol, CurrentRow], CP_UTF8))) > 0)
  then begin
   PasswordStringGrid.Col := CurrentCol;
   PasswordStringGrid.Row := CurrentRow;
   Exit
  end
 until (CurrentRow = OriginalRow) and (CurrentCol = OriginalCol);

 // FindForm.Hide();
 Application.MessageBox(PChar('No occurrences found for "' + FindForm.FindTextEdit.Text + '".'), ApplicationTitleUntyped, MB_OK + MB_ICONINFORMATION);
 // FindForm.Show()
end;

procedure TMainForm.PasswordStringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var StringToDraw                       : String;
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
  PasswordStringGrid.Canvas.FillRect(Rect);
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
  ACol := 0; ARow := 0; // to make the compiler 'happy'
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
  {$hints off} SendMessage(FocusWindow, EM_GETSEL, wParam(@SelStart), lParam(@SelEnd)); {$hints on}
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
 else OpenPasswordForm.PasswordEdit.Text := UnicodeToStrUnderCodePage(Password, CP_UTF8, Nil);
 OpenPasswordForm.ShowModal();
 if OpenPasswordForm.OkPressed then begin
  Password := StrToUnicodeUnderCodePage(OpenPasswordForm.PasswordEdit.Text, CP_UTF8);
  if Password = '' then Password := DEFAULT_PASSWORD;
  if LoadData(ErrorMessage) then begin
   PasswordStringGrid.Visible := true;
   FormResize(Sender);
   DataModified := false
  end else begin
   if ErrorMessage = ERROR_MESSAGE_WRONG_PASWORD then begin
    if Application.MessageBox(PChar(UnicodeToStrUnderCodePage(ErrorMessage, CP_UTF8, Nil)),
       ApplicationTitleUntyped, MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = ID_YES
    then begin
     if Windows.CopyFileW(
          PWideChar(StrToUnicodeUnderCodePage(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.csv'), CP_UTF8)),
          PWideChar(StrToUnicodeUnderCodePage(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.bak'), CP_UTF8)),
          false)
        and Windows.DeleteFileW(PWideChar(StrToUnicodeUnderCodePage(ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.csv'), CP_UTF8)))
     then begin
      PasswordStringGrid.Visible := true;
      FormResize(Sender);
      DataModified := false;
      Password := DEFAULT_PASSWORD;
      Application.MessageBox(PChar('The file '#13#10 +
             ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.csv') +
             #13#10'has been copied into'#13#10 +
             ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.bak') +
             #13#10#13#10'To restore the original file in the future, ' +
             'close this application, copy the file in the reverse order manually, and restart Password Manager.'),
             ApplicationTitleUntyped, MB_OK + MB_ICONINFORMATION);
     end else Application.MessageBox(PChar('Unable to rename ' +
                                           ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.csv') +
                                           ' into ' +
                                           ChangeFileExt(UnicodeToStrUnderCodePage(EXE_NAME, CP_UTF8, Nil), '.bak')),
                                     ApplicationTitleUntyped, MB_OK + MB_ICONSTOP)
    end
   end else Windows.MessageBoxW(Handle, PWideChar(ErrorMessage), ApplicationTitleUntyped, MB_OK + MB_ICONSTOP)
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
 else SavePasswordForm.PasswordEdit.Text := UnicodeToStrUnderCodePage(Password, CP_UTF8, Nil);
 SavePasswordForm.ConfirmPasswordEdit.Text := SavePasswordForm.PasswordEdit.Text;
 SavePasswordForm.ShowModal();
 if SavePasswordForm.OkPressed then begin
  WasPassword := Password;
  Password := StrToUnicodeUnderCodePage(SavePasswordForm.PasswordEdit.Text, CP_UTF8);
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
  end else Application.MessageBox(PChar(UnicodeToStrUnderCodePage(ErrorMessage, CP_UTF8, Nil)),
                                  ApplicationTitleUntyped, MB_OK + MB_ICONSTOP)
 end;
 SavePasswordForm.Free();
end;

Initialization
 EXE_NAME := ''; // to make the compiler happy
 SetLength(EXE_NAME, MAX_PATH);
 SetLength(EXE_NAME, GetModuleFileNameW(hInstance, PWideChar(EXE_NAME), MAX_PATH));

End.
