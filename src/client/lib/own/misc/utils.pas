unit utils;

interface

uses SysUtils;

function ExtractParam(var S: string; Separator: string): string;
function ExtractParamLong(var S: AnsiString; Separator: string): AnsiString;

implementation

function ExtractParam(var S: string; Separator: string): string;
var
  i: Longint;
begin
  i := Pos(Separator, S);
  if i > 0 then
  begin
    Result := Copy(S, 1, i - 1);
    Delete(S, 1, i);
  end
  else
  begin
    Result := S;
    S      := '';
  end;
end;


function ExtractParamLong(var S: AnsiString; Separator: string): AnsiString;
var
  i: Longint;
begin
  i := Pos(Separator, S);
  if i > 0 then
  begin
    Result := Copy(S, 1, i - 1);
    Delete(S, 1, i);
  end
  else
  begin
    Result := S;
    S      := '';
  end;
end;

end.
