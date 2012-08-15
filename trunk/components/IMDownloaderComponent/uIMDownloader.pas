unit uIMDownloader;

interface

uses Classes, WinInet, SysUtils, Dialogs, Windows, Forms;

const
 Accept = 'Accept: */*' + sLineBreak;
 ProxyConnection = 'Proxy-Connection: Keep-Alive' + sLineBreak;
 Lang = 'Accept-Language: ru' + sLineBreak;
 Agent =
   'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; ' +
   'Windows NT 5.1; SV1; .NET CLR 2.0.50727)' + sLineBreak;

type
  PMemoryStream = ^TMemoryStream;
  TIMDownloadError = (deInternetOpen, deInternetOpenUrl, deDownloadingFile, deConnect, deRequest);
  TErrorEvent = procedure(Sender: TObject; E: TIMDownloadError) of object;
  TDownloadingEvent = procedure(Sender: TObject; AcceptedSize, MaxSize: Cardinal) of object;
  THeadersEvent = procedure(Sender: TObject; Headers: String) of object;

  TIMDownloadThread = class(TThread)
  private
    fURL: String;
    fProxy: String;
    fProxyBypass: String;
    fAuthUserName: String;
    fAuthPassword: String;
    MemoryStream: TMemoryStream;
    Err: TIMDownloadError;
    fError: TErrorEvent;
    fAccepted: TNotifyEvent;
    fBreak: TNotifyEvent;
    fDownloading: TDownloadingEvent;
    fHeaders: THeadersEvent;
    AcceptedSize: Cardinal;
    AllSize: Cardinal;
    Headers: String;
    procedure toError;
    procedure toHeaders;
    procedure toDownloading;
    procedure toAccepted;
    procedure toBreak;
    procedure Complete;
    function ErrorResult(E: Boolean; eType: TIMDownloadError): Boolean;
    function GetQueryInfo(hRequest: Pointer; Flag: Integer): String;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; const URL, Proxy, ProxyBypass, AuthUserName, AuthPassword: String; Stream: PMemoryStream);
    property URL: string read fURL;
    property Proxy: string read fProxy;			// Список прокси
    property ProxyBypass: string read fProxyBypass;     // Дополниотельный список прокси
    property AuthUserName: string read fAuthUserName;   // Логин для Authorization: Basic
    property AuthPassword: string read fAuthPassword;   // Пароль для Authorization: Basic
    property OnError: TErrorEvent read fError write fError;
    property OnAccepted: TNotifyEvent read fAccepted write fAccepted;
    property OnBreak: TNotifyEvent read fBreak write fBreak;
    property OnDownloading: TDownloadingEvent read fDownloading write fDownloading;
    property OnHeaders: THeadersEvent read fHeaders write fHeaders;
  end;

  TIMDownloader = class(TComponent)
  private
    fOutStream: TMemoryStream;
    fURL: String;
    fProxy: String;
    fProxyBypass: String;
    fAuthUserName: String;
    fAuthPassword: String;
    Downloader: TIMDownloadThread;
    fOnError: TErrorEvent;
    fOnAccepted: TNotifyEvent;
    fOnBreak: TNotifyEvent;
    fOnStartDownload: TNotifyEvent;
    fInDowloading: Boolean;
    fAcceptedSize: Cardinal;
    fMyHeaders: String;
    fHeaders: THeadersEvent;
    fDownloading: TDownloadingEvent;
    procedure AcceptDownload(Sender: TObject);
    procedure Break_Download(Sender: TObject);
    procedure Downloading(Sender: TObject; AcceptedSize, MaxSize: Cardinal);
    procedure GetHeaders(Sender: TObject; Headers: String);
    procedure ErrorDownload(Sender: TObject; Error: TIMDownloadError);
  public
    procedure DownLoad;
    procedure BreakDownload;
    property OutStream: TMemoryStream read fOutStream;
    property InDowloading: Boolean read fInDowloading;
    property AcceptedSize: Cardinal read fAcceptedSize;
    property MyHeaders: String read fMyHeaders;
  published
    property URL: string read fURL write fURL;
    property Proxy: string read fProxy write fProxy;			  // Список прокси
    property ProxyBypass: string read fProxyBypass write fProxyBypass;    // Дополниотельный список прокси
    property AuthUserName: string read fAuthUserName write fAuthUserName; // Логин для Authorization: Basic
    property AuthPassword: string read fAuthPassword write fAuthPassword; // Пароль для Authorization: Basic
    property OnError: TErrorEvent read fOnError write fOnError;
    property OnAccepted: TNotifyEvent read fOnAccepted write fOnAccepted;
    property OnHeaders: THeadersEvent read fHeaders write fHeaders;
    property OnDownloading: TDownloadingEvent read fDownloading write fDownloading;
    property OnStartDownload: TNotifyEvent read fOnStartDownload write fOnStartDownload;
    property OnBreak: TNotifyEvent read fOnBreak write fOnBreak;
  end;

{$R IMDownloader.dcr}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('IM-History', [TIMDownloader]);
end;

procedure TIMDownloadThread.toHeaders;
begin
  if Assigned(fHeaders) then
    fHeaders(Self, Headers);
end;

procedure TIMDownloadThread.toDownloading;
begin
  if Assigned(fDownloading) then
    fDownloading(Self, AcceptedSize, AllSize);
end;

procedure TIMDownloadThread.toAccepted;
begin
  if Assigned(fAccepted) then
    fAccepted(Self);
end;

procedure TIMDownloadThread.toBreak;
begin
  if Assigned(fBreak) then
    fBreak(Self);
end;

procedure TIMDownloadThread.Complete;
begin
  if Terminated then
    Synchronize(toBreak)
  else
    Synchronize(toAccepted);
end;

procedure TIMDownloadThread.toError;
begin
  if Assigned(fError) then
    OnError(Self, err);
end;

function TIMDownloadThread.ErrorResult(E: Boolean; eType: TIMDownloadError): Boolean;
begin
  Result := E;
  if E then
  begin
    err := eType;
    toError;
  end;
end;

function TIMDownloadThread.GetQueryInfo(hRequest: Pointer; Flag: Integer): String;
var
  Code: String;
  Size, Index: Cardinal;
begin
  SetLength(Code, 8); // Достаточная длина для чтения статус-кода
  Size := Length(Code);
  Index := 0;
  if HttpQueryInfo(hRequest, Flag ,PChar(Code), Size, Index) then
    Result := Code
  else
  if GetLastError = ERROR_INSUFFICIENT_BUFFER then // Увеличиваем буффер
    begin
      SetLength(Code, Size);
      Size := Length(Code);
      if HttpQueryInfo(hRequest, Flag, PChar(Code), Size, Index) then
        Result := Code;
    end
  else
  begin
    //FErrorCode := GetLastError;
    Result := '';
  end;
end;

procedure TIMDownloadThread.Execute;
var
  Buffer: Array [0 .. 1024] of Byte;
  BytesRead: Cardinal;
  FSession, FConnect, FRequest: hInternet;
  dwBuffer: array [0 .. 1024] of Byte;
  dwBufferLen, dwIndex: DWORD;
  FHost, FScript, SRequest, ARequest: String;
  ProxyReqRes, ProxyReqLen: Cardinal;

 function DelHttp(sURL: String): String;
 var
   HttpPos: Integer;
 begin
   HttpPos := Pos('http://', sURL);
   if HttpPos > 0 then Delete(sURL, HttpPos, 7);
   Result := Copy(sURL, 1, Pos('/', sURL) - 1);
   if Result = '' then Result := sURL;
 end;

begin
  // Инициализируем WinInet
  if fProxy = '' then
    FSession := InternetOpen('IM-History Dowload Master', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0)
  else
    FSession := InternetOpen('IM-History Dowload Master', INTERNET_OPEN_TYPE_PROXY, PChar(fProxy), PChar(fProxyBypass), 0);
  if ErrorResult(FSession = nil, deInternetOpen) then
    Exit;
  if Assigned(FSession) then
  begin
    // Небольшой парсинг
    // Вытаскиваем имя хоста и параметры обращения к скрипту
    ARequest := fURL;
    FHost := DelHttp(ARequest);
    FScript := ARequest;
    Delete(FScript, 1, Pos(FHost, FScript) + Length(FHost));
    // Попытка соединения с сервером
    if fProxy = '' then
      FConnect := InternetOpenURL(FSession, PChar(fURL), nil, 0, INTERNET_FLAG_RELOAD, 0)
    else
      FConnect := InternetConnect(FSession, PChar(FHost), INTERNET_DEFAULT_HTTP_PORT, PChar(fAuthUserName),
                  PChar(fAuthPassword), INTERNET_SERVICE_HTTP, 0, 0);
    if ErrorResult(FConnect = nil, deInternetOpenUrl) then
      Exit;
    dwIndex := 0;
    dwBufferLen := Length(dwBuffer);
    if fProxy <> '' then
    begin
      // Подготавливаем запрос
      FRequest := HttpOpenRequest(FConnect, 'GET', PChar(FScript), nil, '', nil, 0, 0);
      // Добавляем необходимые заголовки к запросу
      HttpAddRequestHeaders(FRequest, Accept, Length(Accept), HTTP_ADDREQ_FLAG_ADD);
      HttpAddRequestHeaders(FRequest, ProxyConnection, Length(ProxyConnection), HTTP_ADDREQ_FLAG_ADD);
      HttpAddRequestHeaders(FRequest, Lang, Length(Lang), HTTP_ADDREQ_FLAG_ADD);
      HttpAddRequestHeaders(FRequest, Agent, Length(Agent), HTTP_ADDREQ_FLAG_ADD);
      // Проверяем запрос:
      ProxyReqLen := 0;
      ProxyReqRes := 0;
      SRequest := ' ';
      HttpQueryInfo(FRequest, HTTP_QUERY_RAW_HEADERS_CRLF or
        HTTP_QUERY_FLAG_REQUEST_HEADERS, @SRequest[1], ProxyReqLen, ProxyReqRes);
      if ProxyReqLen > 0 then
      begin
        SetLength(SRequest, ProxyReqLen);
        HttpQueryInfo(FRequest, HTTP_QUERY_RAW_HEADERS_CRLF or
          HTTP_QUERY_FLAG_REQUEST_HEADERS, @SRequest[1], ProxyReqLen, ProxyReqRes);
      end;
      // Отправляем запрос
      if ErrorResult(not HttpSendRequest(FRequest, nil, 0, nil, 0), deRequest) then Exit;
    end;
    if fProxy = '' then
    begin
      // Получаем заголовок ответа с сервера
      Headers := GetQueryInfo(FConnect, HTTP_QUERY_RAW_HEADERS_CRLF);
      Synchronize(toHeaders);
      // Запрос размера
      if HttpQueryInfo(FConnect, HTTP_QUERY_CONTENT_LENGTH, @dwBuffer, dwBufferLen, dwIndex) then
        AllSize := StrToInt('0' + PChar(@dwBuffer));
    end
    else
    begin
      // Получаем заголовок ответа с сервера
      Headers := GetQueryInfo(FRequest, HTTP_QUERY_RAW_HEADERS_CRLF);
      Synchronize(toHeaders);
      // Запрос размера
      if HttpQueryInfo(FRequest, HTTP_QUERY_CONTENT_LENGTH, @dwBuffer, dwBufferLen, dwIndex) then
        AllSize := StrToInt('0' + PChar(@dwBuffer));
    end;
    repeat
      if Terminated then
        Break;
      FillChar(Buffer, SizeOf(Buffer), 0);
      if fProxy = '' then
      begin
        if ErrorResult(not InternetReadFile(FConnect, @Buffer, Length(Buffer), BytesRead), deDownloadingFile) then
          Exit
        else
          MemoryStream.Write(Buffer, BytesRead);
      end
      else
      begin
        if ErrorResult(not InternetReadFile(FRequest, @Buffer, Length(Buffer), BytesRead), deDownloadingFile) then
          Exit
        else
          MemoryStream.Write(Buffer, BytesRead);
      end;
      AcceptedSize := MemoryStream.Size;
      Synchronize(toDownloading);
    until (BytesRead = 0);
    MemoryStream.Position := 0;
    if Assigned(FRequest) then
      InternetCloseHandle(FRequest);
    if Assigned(FConnect) then
      InternetCloseHandle(FConnect);
    InternetCloseHandle(FSession);
    Pointer(MemoryStream) := nil;
    Complete;
  end;
end;

constructor TIMDownloadThread.Create(CreateSuspennded: Boolean; const URL, Proxy, ProxyBypass, AuthUserName, AuthPassword: String; Stream: PMemoryStream);
begin
  inherited Create(CreateSuspennded);
  FreeOnTerminate := True;
  Pointer(MemoryStream) := Stream;
  AcceptedSize := 0;
  Headers := '';
  fURL := URL;
  fProxy := Proxy;
  fProxyBypass := ProxyBypass;
  fAuthUserName := AuthUserName;
  fAuthPassword := AuthPassword;
end;

procedure TIMDownloader.Download;
begin
  fInDowloading := True;
  if Assigned(Downloader) then
    Downloader.Terminate;
  if Assigned(fOutStream) then
    FreeAndNil(fOutStream);
  fAcceptedSize := 0;
  fMyHeaders := '';
  fOutStream := TMemoryStream.Create;
  Downloader := TIMDownloadThread.Create(True, fURL, fProxy, fProxyBypass, fAuthUserName, fAuthPassword, Pointer(fOutStream));
  Downloader.OnAccepted := AcceptDownload;
  Downloader.OnError := ErrorDownload;
  Downloader.OnHeaders := GetHeaders;
  Downloader.OnDownloading := Downloading;
  Downloader.OnBreak := Break_Download;
  Downloader.Resume;
  if Assigned(fOnStartDownload) then
    fOnStartDownload(Self);
end;

procedure TIMDownloader.BreakDownload;
begin
  if not InDowloading then
    Exit;
  if Assigned(Downloader) then
    Downloader.Terminate;
end;

procedure TIMDownloader.Break_Download(Sender: TObject);
begin
  fInDowloading := False;
  Downloader := nil;
  if Assigned(fOnBreak) then
    fOnBreak(Self);
end;

procedure TIMDownloader.AcceptDownload(Sender: TObject);
begin
  fInDowloading := False;
  Downloader := nil;
  if Assigned(fOnAccepted) then
    fOnAccepted(Self);
end;

procedure TIMDownloader.GetHeaders(Sender: TObject; Headers: String);
begin
  fMyHeaders := Headers;
  if Assigned(fHeaders) then
    fHeaders(Self, Headers);
end;

procedure TIMDownloader.Downloading(Sender: TObject; AcceptedSize, MaxSize: Cardinal);
begin
  fAcceptedSize := AcceptedSize;
  if Assigned(fDownloading) then
    fDownloading(Self, AcceptedSize, MaxSize);
end;

procedure TIMDownloader.ErrorDownload(Sender: TObject; Error: TIMDownloadError);
begin
  fInDowloading := False;
  Downloader := nil;
  fOutStream := nil;
  if Assigned(fOnError) then
    fOnError(Self, Error);
end;

end.
