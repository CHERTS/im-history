{*************************************}
{                                     }
{       QIP INFIUM SDK                }
{       Copyright(c) Ilham Z.         }
{       ilham@qip.ru                  }
{       http://www.qip.im             }
{                                     }
{*************************************}

unit u_plugin_msg;

interface

uses Windows;

type
  //see http://wiki.qip.ru/SDK_Types#TPluginMessage
  TPluginMessage = record
    Msg       : DWord;
    WParam    : Integer;
    LParam    : Integer;
    NParam    : Integer;
    Result    : Integer;
    DllHandle : DWord;   //Plugin dll handle, this value have to be always actual if plugin sending msg to qip core!
  end;
  PPluginMessage = ^TPluginMessage;
  
implementation

end.
