unit SNES.Chips.OBC1;

interface

uses
   System.SysUtils,
   SNES.DataTypes;

type
   TSOBC1 = record
      address: Word;
      basePtr: Word;
      shift: Word;
   end;

var
   OBC1: TSOBC1;
   G_Memory: TMemory; // Simula a variável global `Memory`

function GetOBC1(Address: Word): Byte;
procedure SetOBC1(ByteValue: Byte; Address: Word);
procedure ResetOBC1;
function GetBasePointerOBC1(Address: Word): PByte;
function GetMemPointerOBC1(Address: Word): PByte;

implementation

uses
   SNES.Globals; // Supondo que a variável global de memória esteja aqui

procedure ResetOBC1;
begin
   OBC1.address := 0;
   OBC1.basePtr := $1c00;
   OBC1.shift := 0;
   FillChar(G_Memory.OBC1RAM^, $2000, 0);
end;

function GetOBC1(Address: Word): Byte;
begin
   case Address of
      $7ff0..$7ff3: Result := G_Memory.OBC1RAM[OBC1.basePtr + (OBC1.address shl 2) + (Address and not $7ff0)];
      $7ff4: Result := G_Memory.OBC1RAM[OBC1.basePtr + (OBC1.address shr 2) + $200];
      else
         Result := G_Memory.OBC1RAM[Address and $1fff];
   end;
end;

procedure SetOBC1(ByteValue: Byte; Address: Word);
var
   Temp: Byte;
begin
   case Address of
      $7ff0..$7ff3: G_Memory.OBC1RAM[OBC1.basePtr + (OBC1.address shl 2) + (Address and not $7ff0)] := ByteValue;
      $7ff4:
      begin
         Temp := G_Memory.OBC1RAM[OBC1.basePtr + (OBC1.address shr 2) + $200];
         Temp := (Temp and not (3 shl OBC1.shift)) or ((ByteValue and 3) shl OBC1.shift);
         G_Memory.OBC1RAM[OBC1.basePtr + (OBC1.address shr 2) + $200] := Temp;
      end;
      $7ff5:
      begin
         if (ByteValue and 1) <> 0 then
            OBC1.basePtr := $1800
         else
            OBC1.basePtr := $1c00;
      end;
      $7ff6:
      begin
         OBC1.address := ByteValue and $7f;
         OBC1.shift := (ByteValue and 3) shl 1;
      end;
   end;
   G_Memory.OBC1RAM[Address and $1fff] := ByteValue;
end;

function GetBasePointerOBC1(Address: Word): PByte;
begin
   if (Address >= $7ff0) and (Address <= $7ff6) then
      Exit(nil);
   Result := G_Memory.OBC1RAM - $6000;
end;

function GetMemPointerOBC1(Address: Word): PByte;
begin
   if (Address >= $7ff0) and (Address <= $7ff6) then
      Exit(nil);
   Result := G_Memory.OBC1RAM + Address - $6000;
end;

end.