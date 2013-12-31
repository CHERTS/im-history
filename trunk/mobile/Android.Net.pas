{ ############################################################################ }
{ #                                                                          # }
{ #  IM-History for Android v1.0                                             # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit Android.Net;

interface

function IsConnected: Boolean;
function IsWiFiConnected: Boolean;
function IsMobileConnected: Boolean;

implementation

uses
  System.SysUtils,
  FMX.Helpers.Android,
  Androidapi.JNIBridge,
  Androidapi.JNI.Os,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes;

type
  JConnectivityManager = interface;
  JNetworkInfo         = interface;
  JURL                 = interface;
  JURLStreamHandler    = interface;
  JURLConnection       = interface;
  JURI                 = interface;

  // ----------------------------------------------------------------------
  // JNetworkInfo Class
  // ----------------------------------------------------------------------
  JNetworkInfoClass = interface(JObjectClass)
  ['{E92E86E8-0BDE-4D5F-B44E-3148BD63A14C}']
  end;

  [JavaSignature('android/net/NetworkInfo')]
  JNetworkInfo = interface(JObject)
  ['{6DF61A40-8D17-4E51-8EF2-32CDC81AC372}']
    {Methods}
    function isAvailable: Boolean; cdecl;
    function isConnected: Boolean; cdecl;
    function isConnectedOrConnecting: Boolean; cdecl;
  end;
  TJNetworkInfo = class(TJavaGenericImport<JNetworkInfoClass, JNetworkInfo>) end;

  // ----------------------------------------------------------------------
  // JConnectivityManager Class
  // ----------------------------------------------------------------------
  JConnectivityManagerClass = interface(JObjectClass)
  ['{E03A261F-59A4-4236-8CDF-0068FC6C5FA1}']
    {Property methods}
    function _GetTYPE_WIFI: Integer; cdecl;
    function _GetTYPE_WIMAX: Integer; cdecl;
    function _GetTYPE_MOBILE: Integer; cdecl;
    {Properties}
    property TYPE_WIFI: Integer read _GetTYPE_WIFI;
    property TYPE_WIMAX: Integer read _GetTYPE_WIMAX;
    property TYPE_MOBILE: Integer read _GetTYPE_MOBILE;
  end;

  [JavaSignature('android/net/ConnectivityManager')]
  JConnectivityManager = interface(JObject)
  ['{1C4C1873-65AE-4722-8EEF-36BBF423C9C5}']
    {Methods}
    function getActiveNetworkInfo: JNetworkInfo; cdecl;
    function getNetworkInfo(networkType: Integer): JNetworkInfo; cdecl;
  end;
  TJConnectivityManager = class(TJavaGenericImport<JConnectivityManagerClass, JConnectivityManager>) end;

  // ----------------------------------------------------------------------
  // JURLStreamHandler Class
  // ----------------------------------------------------------------------
  JURLStreamHandlerClass = interface(JObjectClass)
    ['{B4F1C7EE-5B0B-4D67-B4A2-D3D953D1C708}']
    function init: JURLConnection; cdecl; overload;
  end;

  [JavaSignature('java/net/URLStreamHandler')]
  JURLStreamHandler = interface( JObject )
    ['{12829A3C-F1DF-4109-A28F-2CC89A007CF6}']
  end;

  TJURLStreamHandler = class( TJavaGenericImport<JURLStreamHandlerClass, JURLStreamHandler> )
  end;

  // ----------------------------------------------------------------------
  // JURI Class
  // ----------------------------------------------------------------------
  JURIClass = interface( JObjectClass )
    ['{8F3A8CD5-B782-479C-B02A-794C4F991907}']

    function init( spec: JString ): JURI; cdecl; overload;
    function init( scheme: JString; schemeSpecificPart: JString; fragment: JString ): JURI; cdecl; overload;
    function init( scheme: JString; userInfo: JString; host: JString; port: integer; path: JString; query: JString; fragment: JString ): JURI; cdecl; overload;
    function init( scheme: JString; host: JString; path: JString; fragment: JString ): JURI; cdecl; overload;
    function init( scheme: JString; authority: string; path: JString; query: JString; fragment: JString ): JURI; cdecl; overload;

    function encode( s: JString ): JString; cdecl; overload;
    function encode( s: JString; allow: JString ): JString; cdecl; overload;
    function decode( s: JString ): integer; cdecl;
  end;

  [JavaSignature( 'java/net/URI' )]
  JURI = interface( JObject )
    ['{9B674F6E-3E81-48E4-BB2E-6136ADB5533F}']
  end;

  TJURI = class( TJavaGenericImport<JURIClass, JURI> )
  end;

  // ----------------------------------------------------------------------
  // JURLConnection Class
  // ----------------------------------------------------------------------
  JURLConnectionClass = interface( JObjectClass )
    ['{D98D92F1-C184-40A3-91A5-C7366B32980E}']
    function init( url: JURL ): JURLConnection; cdecl; overload;
    function getAllowUserInteraction: boolean; cdecl;
  end;

  [JavaSignature( 'java/net/URLConnection' )]
  JURLConnection = interface( JObject )
    ['{B1312058-A490-4CE5-BFFF-1BD5BE114A4C}']
    procedure connect; cdecl;
    function getURL: JURL; cdecl;
    function getConnectTimeout: integer; cdecl;
    function getContent: JObject; cdecl;
    function getContentEncoding: JString; cdecl;
    function getRequestProperty( field: JString ): JString; cdecl;
    function getHeaderFieldKey( posn: Integer ): JString; cdecl;
    function getHeaderField( pos: integer ): JString; cdecl; overload;
    function getHeaderField( key: JString ): JString; cdecl; overload;
    function getContentLength: integer; cdecl;
    function getReadTimeout: integer; cdecl;
    function getHeaderFieldInt( field: JString; defaultValue: Integer ): integer; cdecl;
    function getContentType: JString; cdecl;
    function getDate: Int64; cdecl;
    function getLastModified: Int64; cdecl;
    function getHeaderFieldDate( field: JString; defaultValue: int64 ): Int64; cdecl;
    function getExpiration: Int64; cdecl;
    function getIfModifiedSince: Int64; cdecl;
    function getDefaultUseCaches: boolean; cdecl;
    function getDoInput: boolean; cdecl;
    function getUseCaches: boolean; cdecl;
    function getDoOutput: boolean; cdecl;
    function getInputStream: JInputStream; cdecl;
    procedure setAllowUserInteraction( newValue: boolean ); cdecl;
    procedure setConnectTimeout( timeoutMillis: integer ); cdecl;
    procedure setDoInput(newValue: boolean ); cdecl;
  end;

  TJURLConnection = class( TJavaGenericImport<JURLConnectionClass, JURLConnection> )
  end;

  // ----------------------------------------------------------------------
  // JURL Class
  // ----------------------------------------------------------------------
  JURLClass = interface(JObjectClass)
    ['{1BE949A5-9F11-4B67-8EDB-6D85FDC4666C}']
    function init( spec: JString ): JURL; cdecl; overload;
    function init( context: JURL; spec: JString ): JURL; cdecl; overload;
    function init( context: JURL; spec: JString; handler: JURLStreamHandler ): JURL; cdecl; overload;
    function init( protocol: JString; host: JString; &file: JString ): JURL; cdecl; overload;
    function init( protocol: JString; host: JString; port: integer; &file: JString ): JURL; cdecl; overload;
    function init( protocol: JString; host: JString; port: integer; &file: JString; handler: JURLStreamHandler ): JURL; cdecl; overload;
  end;

  [JavaSignature('java/net/URL')]
  JURL = interface( JObject )
    ['{EB4F9273-48C6-40CE-A0CE-A01E202335E4}']
    function getDefaultPort: integer; cdecl;
    function getPort: integer; cdecl;
    function getHost: JString; cdecl;
    function getFile: JString; cdecl;
    function getPath: JString; cdecl;
    function getQuery: JString; cdecl;
    function getProtocol: JString; cdecl;
    function getRef: JString; cdecl;
    function getUserInfo: JString; cdecl;
    function getAuthority: JString; cdecl;
    function getContent: JObject; cdecl;
    function hashCode: integer; cdecl;
    function openConnection: JURLConnection; cdecl;
    function sameFile( otherURL: JURL ): boolean; cdecl;
    function toString: JString; cdecl;
    function toURI: JURI; cdecl;
  end;

  TJURL = class(TJavaGenericImport<JURLClass, JURL>)
  end;

  // ----------------------------------------------------------------------
  // JHttpURLConnection Class
  // ----------------------------------------------------------------------
  JHttpURLConnectionClass = interface(JURLConnectionClass)
    ['{BA9FABB8-1444-46F3-9950-EE1054CECE61}']
  end;

  [JavaSignature( 'java/net/HttpURLConnection' )]
  JHttpURLConnection = interface(JURLConnection)
    ['{F5F417E2-EB99-4EA1-A391-243F2363D146}']
  end;

  TJHttpURLConnection = class(TJavaGenericImport<JHttpURLConnectionClass, JHttpURLConnection>)
  end;

function GetConnectivityManager: JConnectivityManager;
var
  ConnectivityServiceNative: JObject;
begin
  ConnectivityServiceNative := SharedActivityContext.getSystemService(TJContext.JavaClass.CONNECTIVITY_SERVICE);
  if not Assigned(ConnectivityServiceNative) then
    raise Exception.Create('Could not locate Connectivity Service');
  Result := TJConnectivityManager.Wrap(
    (ConnectivityServiceNative as ILocalObject).GetObjectID);
  if not Assigned(Result) then
    raise Exception.Create('Could not access Connectivity Manager');
end;

function IsConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  ActiveNetwork: JNetworkInfo;
begin
  ConnectivityManager := GetConnectivityManager;
  ActiveNetwork := ConnectivityManager.getActiveNetworkInfo;
  Result := Assigned(ActiveNetwork) and ActiveNetwork.isConnected;
end;

function IsWiFiConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  WiFiNetwork: JNetworkInfo;
begin
  ConnectivityManager := GetConnectivityManager;
  WiFiNetwork := ConnectivityManager.getNetworkInfo(TJConnectivityManager.JavaClass.TYPE_WIFI);
  Result := WiFiNetwork.isConnected;
end;

function IsMobileConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  MobileNetwork: JNetworkInfo;
begin
  ConnectivityManager := GetConnectivityManager;
  MobileNetwork := ConnectivityManager.getNetworkInfo(TJConnectivityManager.JavaClass.TYPE_MOBILE);
  Result := MobileNetwork.isConnected;
end;

end.
