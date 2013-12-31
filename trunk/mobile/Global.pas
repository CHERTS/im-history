{ ############################################################################ }
{ #                                                                          # }
{ #  IM-History for Android v1.0                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Global;

interface

uses
  System.Classes, FMX.Graphics, FMX.Dialogs, System.IOUtils, SysUtils, DCPsha1, DCPdes, DCPmd5, TypInfo, XMLIntf, XMLDoc, IniFiles;

type
  TDBType = (MySQL);
  TSettings = record
    ServerType: Integer;
    DBType: TDBType;
    DBAddress: String;
    DBSchema: String;
    DBPort: Integer;
    DBName: String;
    DBUserName: String;
    DBUserPassword: String;
    SaveUserPassword: Boolean;
  end;
  TUINInfo = record
    NickName: String;
    UIN: String;
    Proto: Integer;
  end;
  pUINInfo = record
    pCount: Cardinal;
    pID: Array of TUINInfo;
  end;
  TCHATInfo = record
    CHATName: String;
    Proto: String;
  end;
  pCHATInfo = record
    pCount: Cardinal;
    pID: Array of TCHATInfo;
  end;
  TEncodeType = (etUSASCII, etUTF8, etANSI);

const
  ProgramsName = 'IM-History for Android';
  ProgramsVer : String = '1.0.0.0';
  DefaultDBType = 0;
  DefaultDBAddress = 'db01.im-history.ru';
  DefaultDBSchema = 'default';
  DefaultDBPort = 3306;
  DefaultDBName = 'imhistory';
  ININame = 'imhistory.ini';
  MSG_TITLE = '%s (%s) (%s)';
  CHAT_MSG_TITLE = '%s (%s)';
  // Ключь для расшифровки параметра DBPasswd из конфига и для шифрования/расшифровки посылок программам HistoryToDBSync и HistoryToDBViewer
  EncryptKey = 'jsU6s2msoxghsKsn7';
  dirLangs = 'langs\';
  defaultLangFile = 'English.xml';
  ReconnectCount = 3;
  ReconnectInterval = 500;

var
  DocumentPath: String;
  Settings: TSettings;
  // Шифрование
  Cipher: TDCP_3des;
  Digest: Array[0..19] of Byte;
  Hash: TDCP_sha1;
  // Для мультиязыковой поддержки
  LangDoc: IXMLDocument;

procedure LoadINI(INIPath: String);
procedure SaveINI(INIPath: String);
function BoolToIntStr(Bool: Boolean): String;
function IsNumber(const S: String): Boolean;
function PrepareString(const Source : PWideChar) : String;
function UnPrepareString(const Source: String) : String;
function EncryptStr(const Str: String): String;
function DecryptStr(const Str: String): String;
function MatchStrings(source, pattern: String): Boolean;
function RemoveInvalidStr(InvalidStr, Str: String): String;
function EncryptMD5(Str: String): String;
function Tok(Sep: String; var s: String): String;
procedure EncryptInit;
procedure EncryptFree;
function IsUTF8Memory(AMem: PBYTE; ASize: Int64): BOOLEAN;
function DetectUTF8Encoding(const s: String): TEncodeType;
function IsUTF8String(const s: String): Boolean;

implementation

// Загружаем настройки
procedure LoadINI(INIPath: String);
var
  Path: String;
  INI: TIniFile;
begin
  Path := INIPath + ININame;
  INI := TIniFile.Create(Path);
  try
    if FileExists(Path) then
    begin
      Settings.ServerType := INI.ReadInteger('Main', 'ServerType', 0);
      Settings.DBType := TDBType(INI.ReadInteger('Main', 'DBType', DefaultDBType));
      Settings.DBAddress := INI.ReadString('Main', 'DBAddress', DefaultDBAddress);
      Settings.DBSchema := INI.ReadString('Main', 'DBSchema', DefaultDBSchema);
      Settings.DBPort := INI.ReadInteger('Main', 'DBPort', DefaultDBPort);
      Settings.DBName := INI.ReadString('Main', 'DBName', DefaultDBName);
      Settings.DBUserName := INI.ReadString('Main', 'DBUserName', '');
      Settings.DBUserPassword := INI.ReadString('Main', 'DBUserPassword', '');
      {if Settings.DBUserPassword <> '' then
        Settings.DBUserPassword := DecryptStr(Settings.DBUserPassword);}
      Settings.SaveUserPassword := INI.ReadBool('Main', 'SaveUserPassword', False);
    end
    else
    begin
      INI.WriteInteger('Main', 'ServerType', 0);
      INI.WriteInteger('Main', 'DBType', DefaultDBType);
      INI.WriteString('Main', 'DBAddress', DefaultDBAddress);
      INI.WriteString('Main', 'DBSchema', DefaultDBSchema);
      INI.WriteInteger('Main', 'DBPort', DefaultDBPort);
      INI.WriteString('Main', 'DBName', DefaultDBName);
      INI.WriteBool('Main', 'SaveUserPassword', False);
    end;
    INI.Free;
  except
    on e: Exception do
    begin
      INI.Free;
      Exit;
    end;
  end;
end;

// Сохраняем настройки
procedure SaveINI(INIPath: String);
var
  Path: String;
  INI: TIniFile;
begin
  Path := INIPath + ININame;
  INI := TIniFile.Create(Path);
  try
    INI.WriteInteger('Main', 'ServerType', Settings.ServerType);
    INI.WriteInteger('Main', 'DBType', Integer(Settings.DBType));
    INI.WriteString('Main', 'DBAddress', Settings.DBAddress);
    INI.WriteString('Main', 'DBSchema', Settings.DBSchema);
    INI.WriteInteger('Main', 'DBPort', Settings.DBPort);
    INI.WriteString('Main', 'DBName', Settings.DBName);
    if Settings.SaveUserPassword then
    begin
      INI.WriteString('Main', 'DBUserName', Settings.DBUserName);
      INI.WriteString('Main', 'DBUserPassword', Settings.DBUserPassword);
      {if Settings.DBUserPassword <> '' then
        INI.WriteString('Main', 'DBUserPassword', EncryptStr(Settings.DBUserPassword))
      else
        INI.WriteString('Main', 'DBUserPassword', '');}
    end
    else
    begin
      INI.WriteString('Main', 'DBUserName', '');
      INI.WriteString('Main', 'DBUserPassword', '');
    end;
    INI.WriteBool('Main', 'SaveUserPassword', Settings.SaveUserPassword);
    INI.Free;
  except
    on e: Exception do
    begin
      INI.Free;
      Exit;
    end;
  end;
end;

function BoolToIntStr(Bool: Boolean): String;
begin
  if Bool then
    Result := '1'
  else
    Result := '0'
end;

function IsNumber(const S: string): Boolean;
begin
  Result := True;
  try
    StrToInt(S);
  except
    Result := False;
  end;
end;

// Функция для экранирования спецсимволов в строке
function PrepareString(const Source : PWideChar) : String;
var
  SLen,i : Cardinal;
  WSTmp : String;
  WChar : WideChar;
begin
 Result := '';
 SLen := Length(String(Source));
 if (SLen>0) then
  begin
   for i:=1 to SLen do
    begin
     WChar:=String(Source)[i];
     case WChar of
      #$09 :{tab}  WSTmp:=WSTmp+'\t';
      #$0A :{line feed}  WSTmp:=WSTmp+'\n';
      #$0D :{carriage return}  WSTmp:=WSTmp+'\r';
      #$27 :{single quote mark aka apostrophe?} WSTmp:=WSTmp+WChar+WChar;
      #$22, {double quote mark aka inch sign?}
      #$5C, {backslash itself}
      #$60 :{another single quote mark} WSTmp:=WSTmp+'\'+WChar;
      else WSTmp := WSTmp + WChar;
     end;
    end;
   Result := WSTmp;
  end;
end;

// Функция обратная PrepareString
function UnPrepareString(const Source: String) : String;
var
  Msg_Result: String;
begin
  Result := '';
  Msg_Result := Source;
  Msg_Result := StringReplace(Msg_Result, '\r', #$0D, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '\n', #$0A, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '\t', #$09, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '\"', #$22, [RFReplaceall]);
  Msg_Result := StringReplace(Msg_Result, '''', #$27, [RFReplaceall]);
  Result := Msg_Result;
end;

// Инициируем криптование
procedure EncryptInit;
begin
  Hash:= TDCP_sha1.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(EncryptKey);
    Hash.Final(Digest);
  finally
    Hash.Free;
  end;
  Cipher := TDCP_3des.Create(nil);
  Cipher.Init(Digest,Sizeof(Digest)*8,nil);
end;

// Освобождаем ресурсы
procedure EncryptFree;
begin
  if Assigned(Cipher) then
  begin
    Cipher.Burn;
    Cipher.Free;
  end;
end;

// Зашифровываем строку
function EncryptStr(const Str: String): String;
begin
  Result := '';
  if Str <> '' then
  begin
    Cipher.Reset;
    Result := Cipher.EncryptString(Str);
  end;
end;

// Расшифровываем строку
function DecryptStr(const Str: String): String;
begin
  Result := '';
  if Str <> '' then
  begin
    Cipher.Reset;
    Result := Cipher.DecryptString(Str);;
  end;
end;

// Подсчет MD5 строки
function EncryptMD5(Str: String): String;
var
  Hash: TDCP_md5;
  Digest: Array[0..15] of Byte;
  I: Integer;
  P: String;
begin
  if Str <> '' then
  begin
    Hash:= TDCP_md5.Create(nil);
    try
      Hash.HashSize := 128;
      Hash.Init;
      Hash.UpdateStr(Str);
      Hash.Final(Digest);
      P := '';
      for I:= 0 to 15 do
        P:= P + IntToHex(Digest[I], 2);
    finally
      Hash.Free;
    end;
    Result := P;
  end
  else
    Result := '';
end;

{Функция осуществляет сравнение двух строк. Первая строка
может быть любой, но она не должна содержать символов соответствия (* и ?).
Строка поиска (искомый образ) может содержать абсолютно любые символы.
Для примера: MatchStrings('David Stidolph','*St*') возвратит True.
Автор оригинального C-кода Sean Stanley
Автор портации на Delphi David Stidolph}
function MatchStrings(source, pattern: String): Boolean;
var
  pSource: array[0..255] of Char;
  pPattern: array[0..255] of Char;

  function MatchPattern(element, pattern: PChar): Boolean;

  function IsPatternWild(pattern: PChar): Boolean;
  begin
    Result := StrScan(pattern, '*') <> nil;
    if not Result then
      Result := StrScan(pattern, '?') <> nil;
  end;

  begin
    if 0 = StrComp(pattern, '*') then
      Result := True
    else if (element^ = Chr(0)) and (pattern^ <> Chr(0)) then
      Result := False
    else if element^ = Chr(0) then
      Result := True
    else
    begin
      case pattern^ of
        '*': if MatchPattern(element, @pattern[1]) then
            Result := True
          else
            Result := MatchPattern(@element[1], pattern);
        '?': Result := MatchPattern(@element[1], @pattern[1]);
      else
        if element^ = pattern^ then
          Result := MatchPattern(@element[1], @pattern[1])
        else
          Result := False;
      end;
    end;
  end;
begin
  StrPCopy(pSource, source);
  StrPCopy(pPattern, pattern);
  Result := MatchPattern(pSource, pPattern);
end;

// Для мультиязыковой поддержки
function GetLangStr(StrID: String): String;
begin
  if (not Assigned(LangDoc)) or (not LangDoc.Active) then
  begin
    Result := '';
    Exit;
  end;
  if LangDoc.ChildNodes['strings'].ChildNodes.FindNode(StrID) <> nil then
    Result := LangDoc.ChildNodes['strings'].ChildNodes[StrID].Text
  else
    Result := 'String not found';
end;

// Функция удаляет подстроку InvalidStr из строки Str
function RemoveInvalidStr(InvalidStr, Str: String): String;
var
  MyStr: String;
begin
  MyStr := Str;
  while Pos(InvalidStr, MyStr) > 0 do
    MyStr := Copy(MyStr,1,pos(InvalidStr,MyStr)-1) +
  Copy(MyStr,Pos(InvalidStr,MyStr)+Length(MyStr),Length(MyStr));
  Result := MyStr;
end;

{ Функция разбивает строку S на слова, разделенные символами-разделителями,
указанными в строке Sep. Функция возвращает первое найденное слово, при
этом из строки S удаляется начальная часть до следующего слова }
function Tok(Sep: String; var S: String): String;

  function isoneof(c, s: string): Boolean;
  var
    iTmp: integer;
  begin
    Result := False;
    for iTmp := 1 to Length(s) do
    begin
      if c = Copy(s, iTmp, 1) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

var
  c, t: String;
begin
  if s = '' then
  begin
    Result := s;
    Exit;
  end;
  c := Copy(s, 1, 1);
  while isoneof(c, sep) do
  begin
    s := Copy(s, 2, Length(s) - 1);
    c := Copy(s, 1, 1);
  end;
  t := '';
  while (not isoneof(c, sep)) and (s <> '') do
  begin
    t := t + c;
    s := Copy(s, 2, length(s) - 1);
    c := Copy(s, 1, 1);
  end;
  Result := t;
end;

{ Генерируем ключ указанной длины
  Если RusAlfa = True, то будут присутствовать русский набор символов
  Иначе только Английский набор, Спец. символы и Цифры }
function RandomWord(RusAlfa: Boolean; PwdLen: Integer): String;
const
  Con1='qwertyuiopasdfghjklzxcvbnm';
  Con2='QWERTYUIOPASDFGHJKLZXCVBNM';
  Con3='qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  Con4='!@#$%^&*()_+|\=-<>. ,/?'';:"][}{';
  Con5='йцукенгшщзхъфывапролджэячсмитьбю';
  Con6='ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
  Con7='йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
var
  Pw: String;
  PasswordLen, Rand: Integer;
begin
  Randomize;
  Result := '';
  PasswordLen := PwdLen;
  repeat
    if RusAlfa then
      Rand := Random(8)+1
    else
      Rand := Random(5)+1;
    if PasswordLen > 0 then
        case Rand of
          1: Pw := Pw + Con1[Random(25)+1];
          2: Pw := Pw + Con2[Random(25)+1];
          3: Pw := Pw + Con3[Random(49)+1];
          4: Pw := Pw + Con4[Random(30)+1];
          5: Pw := Pw + IntToStr(Random(10));
          6: Pw := Pw + Con5[Random(31)+1];
          7: Pw := Pw + Con6[Random(31)+1];
          8: Pw := Pw + Con7[Random(63)+1];
        end
    else
      PasswordLen := Length(Pw);
  until Length(Pw) >= PasswordLen;
  while Length(Pw) > PasswordLen do
    Delete(Pw,1,1);
  Result := Pw;
end;

function UTF8CharLength(const c: BYTE): Integer;
begin
  // First Byte: 0xxxxxxx
  if ((c and $80) = $00) then
  begin
    result := 1;
  end
  // First Byte: 110yyyyy
  else if ((c and $E0) = $C0) then
  begin
    result := 2;
  end
  // First Byte: 1110zzzz
  else if ((c and $F0) = $E0) then
  begin
    result := 3;
  end
  // First Byte: 11110uuu
  else if ((c and $F8) = $F0) then
  begin
    result := 4;
  end
  // not valid, return the error value
  else
  begin
    result := -1;
  end;
end;

function UTF8IsTrailChar(const c: BYTE): BOOLEAN;
begin
  // trail bytes have this form: 10xxxxxx
  result := ((c and $C0) = $80);
end;

// Использование
// isutf8 := IsUTF8Memory(PBYTE(AStream.Memory), AStream.Size);
// для строк
// isutf8 := IsUTF8Memory(PBYTE(PChar(AString)), Length(AString));
function IsUTF8Memory(AMem: PBYTE; ASize: Int64): BOOLEAN;
  var i: Int64;
  c: Integer;
begin
  result := TRUE;
  i := 0;
  while (i < ASize) do
  begin
    // get the length if the current UTF-8 character
    c := UTF8CharLength(AMem^);
    // check if it is valid and fits into ASize
    if ((c>= 1) and (c <= 4) and ((i+c-1) < ASize)) then
    begin
      inc(i, c);
      inc(AMem);
      // if it is a multi-byte character, check the trail bytes
      while (c>1) do
      begin
        if (not UTF8IsTrailChar(AMem^)) then
        begin
          result := FALSE;
          break;
        end
        else
        begin
          dec(c);
          inc(AMem);
        end;
      end;
    end
    else
    begin
      result := FALSE;
    end;
    if (not result) then
      break;
  end;
end;


function DetectUTF8Encoding(const s: String): TEncodeType;
var
  c : Byte;
  P, EndPtr: PByte;
begin
  Result := etUSASCII;
  P := PByte(PChar(s));
  EndPtr := P + Length(s);

  // skip leading US-ASCII part.
  while P < EndPtr do
  begin
    if P^ >= $80 then break;
    inc(P);
  end;

  // If all character is US-ASCII, done.
  if P = EndPtr then exit;

  while P < EndPtr do
  begin
    c := p^;
    case c of
      $00..$7F:
        inc(P);

      $C2..$DF:
        if (P+1 < EndPtr)
            and ((P+1)^ in [$80..$BF]) then
          Inc(P, 2)
        else
          break;

      $E0:
        if (P+2 < EndPtr)
            and ((P+1)^ in [$A0..$BF])
            and ((P+2)^ in [$80..$BF]) then
          Inc(P, 3)
        else
          break;

      $E1..$EF:
        if (P+2 < EndPtr)
            and ((P+1)^ in [$80..$BF])
            and ((P+2)^ in [$80..$BF]) then
          Inc(P, 3)
        else
          break;

      $F0:
        if (P+3 < EndPtr)
            and ((P+1)^ in [$90..$BF])
            and ((P+2)^ in [$80..$BF])
            and ((P+3)^ in [$80..$BF]) then
          Inc(P, 4)
        else
          break;

      $F1..$F3:
        if (P+3 < EndPtr)
            and ((P+1)^ in [$80..$BF])
            and ((P+2)^ in [$80..$BF])
            and ((P+3)^ in [$80..$BF]) then
          Inc(P, 4)
        else
          break;

      $F4:
        if (P+3 < EndPtr)
            and ((P+1)^ in [$80..$8F])
            and ((P+2)^ in [$80..$BF])
            and ((P+3)^ in [$80..$BF]) then
          Inc(P, 4)
        else
          break;
    else
      break;
    end;
  end;

  if P = EndPtr then Result := etUTF8
  else Result := etANSI;
end;

function IsUTF8String(const s: String): Boolean;
begin
  result := DetectUTF8Encoding(s) = etUTF8;
end;

begin
end.
