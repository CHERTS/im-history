{------------------------------------------------------------------------------
  DTPEx.pas

  written by  Precision software & consulting
              e-mail: info@be-precision.com
              web: http://www.be-precision.com

  Purpose:    Extended TDateTimePicker control,
              property FormatString - supports both date and time editing

              For Delphi 5 to XE3

  The source code is given as is. The author is not responsible
  for any possible damage done due to the use of this code.
  This unit can be freely used in any application. The complete
  source code remains property of the author and may not be distributed,
  published, given or sold in any form as such. No parts of the source
  code can be included in any other component or application without
  written authorization of the author.

  Copyright (c) 2008 - 2009  Precision software & consulting
  All rights reserved
  
  Change log:
    v1.2, 15.11.2012
    - added support for Delphi XE3

    v1.1, 14.10.2008
    - added support for Delphi 2009
    
    v1.0  21.8.2006
    - initiall release
------------------------------------------------------------------------------}

unit DTPEx;

{$I jedi.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TDateTimePickerEx = class(TDateTimePicker)
  private
    FIsBlank:Boolean;
    FWasBlank:Boolean;
    FFormatString:string;
    FFormatBlank:string;
    FLastDateTime:TDateTime;
    procedure SetFormatString(const Value:string);
    procedure SetFormatBlank(const Value:string);
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
  protected
    procedure CreateWnd; override;
    function MsgSetDateTime(Value: TSystemTime): Boolean; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CheckEmptyDate; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FormatString:string read FFormatString Write SetFormatString;
    property FormatBlank:string read FFormatBlank Write SetFormatBlank;
    property DateTime;
  end;

procedure Register;

implementation

uses CommCtrl;

procedure Register;
begin
  RegisterComponents('Precision VCL', [TDateTimePickerEx]);
end;

constructor TDateTimePickerEx.Create(AOwner: TComponent);
begin
  FIsBlank:=False;
  FWasBlank:=False;
  FFormatBlank:='''''';
  FFormatString:={$IFDEF DELPHI16_UP}FormatSettings.{$ENDIF}ShortDateFormat+' HH:mm:ss';
  inherited Create(AOwner);
  FLastDateTime:=DateTime;
end;

procedure TDateTimePickerEx.CreateWnd;
begin
  inherited CreateWnd;
  if DateTime=0 then
    Perform(DTM_SETFORMAT, 0, Integer(PChar(FFormatBlank)))
  else
    Perform(DTM_SETFORMAT, 0, Integer(PChar(FFormatString)));
end;

procedure TDateTimePickerEx.CheckEmptyDate;
begin
  Invalidate;
end;

procedure TDateTimePickerEx.SetFormatString(const Value:string);
begin
  if Value<>FFormatString then
  begin
    FFormatString := Value;
    RecreateWnd;
  end;
end;

procedure TDateTimePickerEx.SetFormatBlank(const Value:string);
begin
	if Value<>FFormatBlank then
  begin
    FFormatBlank := Value;
    RecreateWnd;
  end;
end;

function IsBlankSysTime(const ST: TSystemTime): Boolean;
type
  TFast = array [0..3] of DWORD;
begin
  Result := (TFast(ST)[0] or TFast(ST)[1] or TFast(ST)[2] or TFast(ST)[3]) = 0;
end;

procedure TDateTimePickerEx.DoEnter;
begin
  if FIsBlank then
  begin
    datetime:=now;
    FWasBlank:=True;
  end;
  inherited;
end;

procedure TDateTimePickerEx.DoExit;
begin
  if FWasBlank then
  begin
    FWasBlank:=False;
    datetime:=0;
  end;
  inherited;
end;

procedure TDateTimePickerEx.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_F2:
      if FWasBlank then
      begin
        FWasBlank:=False;
        FIsBlank:=False;
        Change;
      end;
  end;
end;

function TDateTimePickerEx.MsgSetDateTime(Value: TSystemTime): Boolean;
var
  tmp:string;
  h,m:Integer;
begin
  if not ShowCheckbox then
  begin
    if SystemTimeToDateTime(Value)=0 then
    begin
      if not FIsBlank then
      begin
        FIsBlank:=True;
        Perform(DTM_SETFORMAT, 0, Integer(PChar(FFormatBlank)));
      end
    end
    else
    begin
      if FIsBlank then
      begin
        Perform(DTM_SETFORMAT, 0, Integer(PChar(FFormatString)));
      end;
      FIsBlank:=False;
      if FWasBlank then
        FWasBlank:=False;
    end;
  end;
  if (FFormatString<>'') and (Pos('tt',FFormatString)=0) then
  begin
    tmp:=LowerCase(FFormatString);
    h:=Pos('h',tmp);
    if h=0 then
    begin
      if Pos('t',FFormatString)=0 then
      begin
        Value.wHour:=0;
        Value.wMinute:=0;
      end;
      Value.wSecond:=0;
      Value.wMilliseconds:=0;
    end
    else
    begin
      m:=Pos('m',tmp);
      if (Pos('n',tmp)=0) and ((m=0) or (LastDelimiter('m',tmp)<h) or (m-h>3)) then
      begin
        Value.wMinute:=0;
        Value.wSecond:=0;
        Value.wMilliseconds:=0;
      end
      else
      if Pos('s',tmp)=0 then
      begin
        Value.wSecond:=0;
        Value.wMilliseconds:=0;
      end
      else
        if Pos('z',tmp)=0 then
          Value.wMilliseconds:=0;
    end;
  end;
  Result:=inherited MsgSetDateTime(Value);
end;

procedure TDateTimePickerEx.CNNotify(var Message: TWMNotify);
begin
  with Message, NMHdr^ do
  begin
    Result := 0;
    case code of
      DTN_DROPDOWN:
        begin
          inherited;
          FLastDateTime:=DateTime;
        end;
      DTN_CLOSEUP:
        begin
          inherited;
          DateTime := FLastDateTime;
        end;
      DTN_DATETIMECHANGE:
        begin
          with PNMDateTimeChange(NMHdr)^ do
          begin
            if DroppedDown and (dwFlags = GDT_VALID) then
            begin
              FLastDateTime:=SystemTimeToDateTime(st);
              DateTime:=FLastDateTime;
            end
            else
            begin
              if ShowCheckbox and IsBlankSysTime(st) then
                Checked := False
              else
                if dwFlags = GDT_VALID then
                begin
                  if st.wMonth=2 then
                  begin
                    if IsLeapYear(st.wYear) then
                    begin
                      if st.wDay>29 then
                        st.wDay:=29
                    end
                    else
                      if st.wDay>28 then
                        st.wDay:=28
                  end
                  else
                    if MonthDays[IsLeapYear(st.wYear),st.wMonth]<st.wDay then
                      st.wDay:=MonthDays[IsLeapYear(st.wYear),st.wMonth];
                  FLastDateTime:=SystemTimeToDateTime(st);
                  if FormatString='' then
                  begin
                    if Kind = dtkDate then
                      FLastDateTime:=Trunc(FLastDateTime)
                    else
                      FLastDateTime:=frac(FLastDateTime)
                  end;
                  DateTime:=FLastDateTime;
                  if ShowCheckbox then
                    Checked := True;
                end;
            end;
            Change;
          end;
        end;
      else
        inherited;
    end;
  end;
end;

end.

