program ThreadNames;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  Posix.Pthread, Posix.SysTypes, Posix.Base;

type
  TNamedThread = class(TThread)
  public
    procedure MyNameThreadForDebugging(const AThreadName: string);
    function GetThreadName: string;
  end;

function pthread_setname_np(Thread: pthread_t; Name: MarshaledAString): Integer; external libpthread name _PU + 'pthread_setname_np';

{ TNamedThread }

function TNamedThread.GetThreadName: string;
var
  M: TMarshaller;
  LName: MarshaledAString;
  LSize: Integer;
begin
  LSize := 16;
  LName := M.AllocMem(LSize).ToPointer;
  pthread_getname_np(ThreadID, LName, LSize);
  Result := string(LName);
end;

procedure TNamedThread.MyNameThreadForDebugging(const AThreadName: string);
var
  M: TMarshaller;
  LName: MarshaledAString;
begin
  LName := M.AsAnsi(AThreadName).ToPointer;
  pthread_setname_np(ThreadID, LName);
end;

procedure Main;
var
  LThread1, LThread2: TThread;
begin
  LThread1 := TNamedThread.CreateAnonymousThread(procedure
  var
    LThreadName1: string;
  begin
    TNamedThread(LThread1).MyNameThreadForDebugging('你好');
    Sleep(1000);
    LThreadName1 := TNamedThread(LThread1).GetThreadName;
    Sleep(1000);  // place a  breakpoint here and look at the name
  end);

//  LThread2 := TNamedThread.CreateAnonymousThread(procedure
//  var
//    LThreadName1: string;
//  begin
//    TNamedThread(LThread2).MyNameThreadForDebugging('Thread 2');
//    Sleep(1000);
//    LThreadName1 := TNamedThread(LThread2).GetThreadName;
//    Sleep(1000); // place a  breakpoint here and look at the name
//  end);

  LThread1.Start;
//  LThread2.Start;

  LThread1.WaitFor;
//  LThread2.WaitFor;

end;

begin
  Main;
end.
