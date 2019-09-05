{***********************************************************************************************}
{* Originally written by Mark van Renswoude (http://www.nldelphi.com/forum/member.php?u=201);  *}
{* See NLDMessageBox at https://svn.apada.nl/svn/NLDelphi-opensource/psychomark/nldmessagebox/ *}
{***********************************************************************************************}

{$B-,I-,Q-,S-,R-,A+,J+}

unit AwDialogs;

interface

uses Dialogs, Forms, Windows, Controls, Messages, AwHookInstance, Math, MultiMon;

procedure CenterWindow(WindowToStay, WindowToCenter: HWND);
function GetTopWindow: HWND;
function ExecuteCentered(Dialog          : TCommonDialog;
                        WindowToCenterIn : HWND = 0)      : Boolean;
function MsgBox(WindowToCenterIn       : HWND; // 0 means, "not centered"
                const Text             : String;
                const Caption          : String;
                      Flags            : Cardinal)    : Integer;

implementation

procedure CenterWindow(WindowToStay, WindowToCenter: HWND);
var R1, R2, MonRect : TRect;
    Monitor         : HMonitor;
    MonInfo         : TMonitorInfo;
    X, Y            : Integer;
begin
 GetWindowRect(WindowToStay, R1);
 GetWindowRect(WindowToCenter, R2);
 Monitor := MonitorFromWindow(WindowToStay, MONITOR_DEFAULTTONEAREST);
 MonInfo.cbSize := SizeOf(MonInfo);
 GetMonitorInfo(Monitor, @MonInfo);
 MonRect := MonInfo.rcWork;
 with R1 do begin
  X := (Right - Left - R2.Right + R2.Left) div 2 + Left;
  Y := (Bottom - Top - R2.Bottom + R2.Top) div 2 + Top;
 end;
 X := Max(MonRect.Left, Min(X, MonRect.Right - R2.Right + R2.Left));
 Y := Max(MonRect.Top, Min(Y, MonRect.Bottom - R2.Bottom + R2.Top));
 SetWindowPos(WindowToCenter, 0, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOZORDER);
end;

function GetTopWindow: HWND;
begin
 Result := GetLastActivePopup(Application.Handle);
 if (Result = Application.Handle) or not IsWindowVisible(Result)
 then Result := Screen.ActiveCustomForm.Handle;
end;

{ TAwCommonDialog }

type
  TAwCommonDialog = class(TObject)
  private
    FCenterWnd: HWND;
    FDialog: TCommonDialog;
    FHookProc: TFarProc;
    FWndHook: HHOOK;
    procedure HookProc(var Message: THookMessage);
    function Execute: Boolean;
  end;

function TAwCommonDialog.Execute: Boolean;
begin
 try
  Application.NormalizeAllTopMosts;
  FHookProc := MakeHookInstance(HookProc);
  FWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, FHookProc, 0, GetCurrentThreadID);
  Result := FDialog.Execute;
 finally
  if FWndHook <> 0 then UnhookWindowsHookEx(FWndHook);
  if FHookProc <> nil then FreeHookInstance(FHookProc);
  Application.RestoreTopMosts;
 end;
end;

procedure TAwCommonDialog.HookProc(var Message: THookMessage);
var Data   : PCWPRetStruct;
    Parent : HWND;
begin
 with Message do
 if nCode < 0
 then Result := CallNextHookEx(FWndHook, nCode, wParam, lParam)
 else Result := 0;

 if Message.nCode = HC_ACTION then begin
  Data := PCWPRetStruct(Message.lParam);
  if (FDialog.Handle <> 0) and (Data.message = WM_SHOWWINDOW) then begin
   Parent := GetWindowLong(FDialog.Handle, GWL_HWNDPARENT);
   if ((Data.hwnd = FDialog.Handle) and (Parent = Application.Handle)) or
      ((Data.hwnd = FDialog.Handle) and (FDialog is TFindDialog)) or
      (Data.hwnd = Parent)
   then begin
    CenterWindow(FCenterWnd, Data.hwnd);
    SetWindowPos(Data.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
    UnhookWindowsHookEx(FWndHook);
    FWndHook := 0;
    FreeHookInstance(FHookProc);
    FHookProc := nil;
   end;
  end;
 end;
end;

function ExecuteCentered(Dialog: TCommonDialog; WindowToCenterIn: HWND = 0): Boolean;
begin
 with TAwCommonDialog.Create do
 try
  if WindowToCenterIn = 0
  then FCenterWnd := GetTopWindow
  else FCenterWnd := WindowToCenterIn;
  FDialog := Dialog;
  Result := Execute;
 finally
  Free;
 end;
end;

{ TAwMessageBox }

type
  TAwMessageBox = class(TObject)
  private
    FCaption: String;
    FCenterWnd: HWND;
    FFlags: Cardinal;
    FHookProc: TFarProc;
    FText: String;
    FWndHook: HHOOK;
    function Execute: Integer;
    procedure HookProc(var Message: THookMessage);
  end;

function TAwMessageBox.Execute: Integer;
begin
 try
  try
   Application.NormalizeAllTopMosts;
   FHookProc := MakeHookInstance(HookProc);
   FWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, FHookProc, 0, GetCurrentThreadID);
   Result := Application.MessageBox(PChar(FText), PChar(FCaption), FFlags);
  finally
   if FWndHook <> 0 then UnhookWindowsHookEx(FWndHook);
   if FHookProc <> nil then FreeHookInstance(FHookProc);
   Application.RestoreTopMosts;
  end;
 except
  Result := 0;
 end;
end;

procedure TAwMessageBox.HookProc(var Message: THookMessage);
var Data  : PCWPRetStruct;
    Title : array[0..255] of Char;
begin
 with Message do
 if nCode < 0
 then Result := CallNextHookEx(FWndHook, nCode, wParam, lParam)
 else Result := 0;

 if Message.nCode = HC_ACTION then begin
  Data := PCWPRetStruct(Message.lParam);
  if Data.message = WM_INITDIALOG then begin
   FillChar(Title, SizeOf(Title), 0);
   GetWindowText(Data.hwnd, @Title, SizeOf(Title));
   if String(Title) = FCaption then begin
    CenterWindow(FCenterWnd, Data.hwnd);
    SetWindowPos(Data.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
    UnhookWindowsHookEx(FWndHook);
    FWndHook := 0;
    FreeHookInstance(FHookProc);
    FHookProc := nil;
   end;
  end;
 end;
end;

function MsgBox(WindowToCenterIn       : HWND; // 0 means, "not centered"
                const Text             : String;
                const Caption          : String;
                      Flags            : Cardinal)    : Integer;
begin
 with TAwMessageBox.Create() do
 try
  FCaption := Caption;
  if WindowToCenterIn = 0 then FCenterWnd := GetTopWindow else FCenterWnd := WindowToCenterIn;
  FText := Text;
  FFlags := Flags;
  Result := Execute();
 finally
  Free();
 end;
end;

end.