{***********************************************************************************************}
{* Originally written by Mark van Renswoude (http://www.nldelphi.com/forum/member.php?u=201);  *}
{* See NLDMessageBox at https://svn.apada.nl/svn/NLDelphi-opensource/psychomark/nldmessagebox/ *}
{***********************************************************************************************}

{$B-,I-,Q-,S-,R-,A+,J+}

unit AwHookInstance;

interface

uses Windows;

type
  THookMessage = packed record
    nCode: Integer;
    wParam: WPARAM;
    lParam: LPARAM;
    Result: LRESULT;
  end;

  THookMethod = procedure(var Message: THookMessage) of object;

function MakeHookInstance(Method: THookMethod): Pointer;
procedure FreeHookInstance(HookInstance: Pointer);

implementation

const InstanceCount = 313;

type
  PHookInstance = ^THookInstance;
  THookInstance = packed record
    Code: Byte;
    Offset: Integer;
    case Integer of
      0: (Next: PHookInstance);
      1: (Method: THookMethod);
  end;

  PInstanceBlock = ^TInstanceBlock;
  TInstanceBlock = packed record
    Next: PInstanceBlock;
    Code: array[1..2] of Byte;
    HookProcPtr: Pointer;
    Instances: array[0..InstanceCount] of THookInstance;
  end;

var
  InstBlockList: PInstanceBlock;
  InstFreeList: PHookInstance;

function StdHookProc(nCode: Integer; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall; assembler;
{ In    ECX = Address of method pointer }
{ Out   EAX = Result }
asm
  XOR     EAX,EAX
  PUSH    EAX
  PUSH    LParam
  PUSH    WParam
  PUSH    nCode
  MOV     EDX,ESP
  MOV     EAX,[ECX].Longint[4]
  CALL    [ECX].Pointer
  ADD     ESP,12
  POP     EAX
end;

function CalcJmpOffset(Src, Dest: Pointer): Longint;
begin
  Result := Longint(Dest) - (Longint(Src) + 5);
end;

function MakeHookInstance(Method: THookMethod): Pointer;
const BlockCode : array[1..2] of Byte = ($59 { POP ECX }, $E9 { JMP StdHookProc });
      PageSize = 4096;
var Block    : PInstanceBlock;
    Instance : PHookInstance;
begin
 if InstFreeList = nil then begin
  Block := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  Block^.Next := InstBlockList;
  Move(BlockCode, Block^.Code, SizeOf(BlockCode));
  Block^.HookProcPtr := Pointer(CalcJmpOffset(@Block^.Code[2], @StdHookProc));
  Instance := @Block^.Instances;
  repeat
   Instance^.Code := $E8;  { CALL NEAR PTR Offset }
   Instance^.Offset := CalcJmpOffset(Instance, @Block^.Code);
   Instance^.Next := InstFreeList;
   InstFreeList := Instance;
   Inc(Longint(Instance), SizeOf(THookInstance));
  until Longint(Instance) - Longint(Block) >= SizeOf(TInstanceBlock);
  InstBlockList := Block;
 end;
 Result := InstFreeList;
 Instance := InstFreeList;
 InstFreeList := Instance^.Next;
 Instance^.Method := Method;
end;

procedure FreeHookInstance(HookInstance: Pointer);
begin
 if HookInstance <> nil then begin
  PHookInstance(HookInstance)^.Next := InstFreeList;
  InstFreeList := HookInstance;
 end;
end;

end.