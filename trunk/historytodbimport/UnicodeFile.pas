{ ############################################################################ }
{ #                                                                          # }
{ #  Просмотр истории HistoryToDBImport v2.1                                 # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Grigorev Michael (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit UnicodeFile;

interface

uses Windows, SysUtils, StrUtils, Classes;

type
  TUnicodeFile = class(TStringList)
  private
    FMemStream: TMemoryStream;
  public
    function IsUnicodeFile(const FileName: String): Boolean;
    procedure LoadFromUnicodeFile(const FileName: String);
    procedure SaveToUnicodeFile(const FileName: String);
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
  end;

implementation

constructor TUnicodeFile.Create;
begin
  inherited Create;
  FMemStream := TMemoryStream.Create;
end;

destructor TUnicodeFile.Destroy;
begin
  FMemStream.Free;
  inherited Destroy;
end;

function TUnicodeFile.IsUnicodeFile(const FileName: String): Boolean;
var
  UnicodeMagic: Word;
begin
  Result := False;
  FMemStream.LoadFromFile(FileName);
  if FMemStream.Size < 2 then
    Result := False;
  FMemStream.Position := 0;
  FMemStream.Read(UnicodeMagic, 2);
  if UnicodeMagic <> $FEFF then
    Result := False
  else
    Result := True;
end;

procedure TUnicodeFile.LoadFromUnicodeFile(const FileName: String);
var
  UnicodeBuf: PChar;
  UnicodeMagic: Word;
begin
  FMemStream.LoadFromFile(FileName);
  if FMemStream.Size < 2 then
    Exit;
  FMemStream.Position := 0;
  FMemStream.Read(UnicodeMagic, 2);
  if UnicodeMagic <> $FEFF then
    Exit;
  FMemStream.Position := 2;
  UnicodeBuf := StrAlloc(FMemStream.Size);
  try
    ZeroMemory(UnicodeBuf, FMemStream.Size);
    FMemStream.Read(UnicodeBuf^, FMemStream.Size-2);
    Add(WideCharToString(PWideChar(UnicodeBuf)));
    //Lines.Text := WideCharToString(PWideChar(wbuf));
  finally
    StrDispose(UnicodeBuf);
  end;
end;

procedure TUnicodeFile.SaveToUnicodeFile(const FileName: String);
var
  UnicodeDest: PWideChar;
  UnicodeMagic: Word;
begin
  FMemStream.Clear;
  FMemStream.Position := 0;
  UnicodeMagic := $FEFF;
  FMemStream.Write(UnicodeMagic, 2);
  FMemStream.Position := 2;
  GetMem(UnicodeDest, (Length(Text)+1)*2);
  try
    ZeroMemory(UnicodeDest, (Length(Text)+1)*2);
    StringToWideChar(Text, UnicodeDest, Length(Text)+1);
    FMemStream.Write(UnicodeDest^, Length(Text)*2);
    FMemStream.SaveToFile(FileName);
  finally
    FreeMem(UnicodeDest);
  end;
end;

end.
