{------------------------------------------------------------------------------}
{                                                                              }
{  TTextFader v1.24                                                            }
{  by Kambiz R. Khojasteh                                                      }
{                                                                              }
{  kambiz@delphiarea.com                                                       }
{  http://www.delphiarea.com                                                   }
{                                                                              }
{------------------------------------------------------------------------------}

{$I Compilers.inc}

unit TextFade;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type

  TPercent = 0..100;
  TProgressStep = 1..100;

  TBackgroundMode = (bmNone, bmTiled, bmStretched, bmCentered);

  TTextFader = class(TGraphicControl)
  private
    fActive: Boolean;
    fLineDelay: Word;
    fFadeDelay: Word;
    fFadeStep: TProgressStep;
    fAlignment: TAlignment;
    fBackgroundMode: TBackgroundMode;
    fBackground: TPicture;
    fLineIndex: Integer;
    fLines: TStrings;
    fWordWrap: Boolean;
    fTransparent: Boolean;
    fRepeatCount: TBorderWidth;
    fRepeatedCount: Integer;
    fOnComplete: TNotifyEvent;
    fOnMouseEnter: TNotifyEvent;
    fOnMouseLeave: TNotifyEvent;
    Timer: TTimer;
    Drawing: Boolean;
    FadeProgress: TPercent;
    CurText: String;
    OldText: String;
    procedure SetActive(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetLineIndex(Value: Integer);
    procedure SetLineDelay(Value: Word);
    procedure SetFadeDelay(Value: Word);
    procedure SetBackgroundMode(Value: TBackgroundMode);
    procedure SetBackground(Value: TPicture);
    procedure SetLines(Value: TStrings);
    procedure SetWordWrap(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
    procedure BackgroundChanged(Sender: TObject);
    procedure LinesChanged(Sender: TObject);
    procedure TimerExpired(Sender: TObject);
    function IsLinesStored: Boolean;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure PaintCanvas;
  protected
    procedure Paint; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset;
    property ReapeatedCount: Integer read fRepeatedCount;
    property LineIndex: Integer read fLineIndex write SetLineIndex default -1;
  published
    property Active: Boolean read fActive write SetActive default False;
    property Align;
    property Alignment: TAlignment read fAlignment write SetAlignment default taCenter;
    property Background: TPicture read fBackground write SetBackground;
    property BackgroundMode: TBackgroundMode read fBackgroundMode write SetBackgroundMode default bmTiled;
    {$IFDEF COMPILER4_UP}
    property Anchors;
    property BiDiMode;
    property ParentBiDiMode;
    {$ENDIF}
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FadeDelay: Word read fFadeDelay write SetFadeDelay default 30;
    property FadeStep: TProgressStep read fFadeStep write fFadeStep default 4;
    property Font;
    property Height default 16;
    property LineDelay: Word read fLineDelay write SetLineDelay default 2000;
    property Lines: TStrings read fLines write SetLines stored IsLinesStored;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RepeatCount: TBorderWidth read fRepeatCount write fRepeatCount default 0;
    property ShowHint;
    property Transparent: Boolean read fTransparent write SetTransparent default False;
    property Visible;
    property Width default 200;
    property WordWrap: Boolean read fWordWrap write SetWordWrap default True;
    property OnClick;
    property OnComplete: TNotifyEvent read fOnComplete write fOnComplete;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseEnter: TNotifyEvent read fOnMouseEnter write fOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read fOnMouseLeave write fOnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure DrawTiled(Canvas: TCanvas; const Rect: TRect; Graphic: TGraphic);
procedure DrawTransparent(dstBitmap, srcBitmap: TBitmap; Transparency: TPercent);

procedure Register;

implementation

type
  TParentControl = class(TWinControl);

{ This procedure is copied from RxLibrary VCLUtils }
procedure CopyParentImage(Control: TControl; Dest: TCanvas);
var
  I, Count, X, Y, SaveIndex: Integer;
  DC: HDC;
  R, SelfR, CtlR: TRect;
begin
  if (Control = nil) or (Control.Parent = nil) then Exit;
  Count := Control.Parent.ControlCount;
  DC := Dest.Handle;
{$IFDEF WIN32}
  with Control.Parent do ControlState := ControlState + [csPaintCopy];
  try
{$ENDIF}
    with Control do
    begin
      SelfR := Bounds(Left, Top, Width, Height);
      X := -Left; Y := -Top;
    end;
    { Copy parent control image }
    SaveIndex := SaveDC(DC);
    try
      SetViewportOrgEx(DC, X, Y, nil);
      IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth,
        Control.Parent.ClientHeight);
      with TParentControl(Control.Parent) do
      begin
        Perform(WM_ERASEBKGND, DC, 0);
        PaintWindow(DC);
      end;
    finally
      RestoreDC(DC, SaveIndex);
    end;
    { Copy images of graphic controls }
    for I := 0 to Count - 1 do begin
      if Control.Parent.Controls[I] = Control then Break
      else if (Control.Parent.Controls[I] <> nil) and
        (Control.Parent.Controls[I] is TGraphicControl) then
      begin
        with TGraphicControl(Control.Parent.Controls[I]) do begin
          CtlR := Bounds(Left, Top, Width, Height);
          if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then begin
{$IFDEF WIN32}
            ControlState := ControlState + [csPaintCopy];
{$ENDIF}
            SaveIndex := SaveDC(DC);
            try
              SetViewportOrgEx(DC, Left + X, Top + Y, nil);
              IntersectClipRect(DC, 0, 0, Width, Height);
              Perform(WM_PAINT, DC, 0);
            finally
              RestoreDC(DC, SaveIndex);
{$IFDEF WIN32}
              ControlState := ControlState - [csPaintCopy];
{$ENDIF}
            end;
          end;
        end;
      end;
    end;
{$IFDEF WIN32}
  finally
    with Control.Parent do ControlState := ControlState - [csPaintCopy];
  end;
{$ENDIF}
end;

procedure DrawTiled(Canvas: TCanvas; const Rect: TRect; Graphic: TGraphic);
var
  X, Y: Integer;
  SavedDC: Integer;
begin
  if (Graphic <> nil) and (not Graphic.Empty) then
  begin
    SavedDC := SaveDC(Canvas.Handle);
    try
      IntersectClipRect(Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
      Y := Rect.Top;
      while Y < Rect.Bottom do
      begin
        X := Rect.Left;
        while X < Rect.Right do
        begin
          Canvas.Draw(X, Y, Graphic);
          Inc(X, Graphic.Width);
        end;
        Inc(Y, Graphic.Height);
      end;
    finally
      RestoreDC(Canvas.Handle, SavedDC);
    end;
  end;
end;

procedure DrawTransparent(dstBitmap, srcBitmap: TBitmap; Transparency: TPercent);
var
  dstPixel, srcPixel: PRGBQuad;
  InvertTransparency: TPercent;
  bmpWidth, bmpHeight: Integer;
  X, Y: Integer;
begin
  srcBitmap.PixelFormat := pf32bit;
  dstBitmap.PixelFormat := pf32bit;
  bmpWidth := srcBitmap.Width;
  bmpHeight := srcBitmap.Height;
  InvertTransparency := 100 - Transparency;
  for Y := 0 to bmpHeight - 1 do
  begin
    srcPixel := srcBitmap.ScanLine[y];
    dstPixel := dstBitmap.ScanLine[y];
    for X := 0 to bmpWidth - 1 do
    begin
      dstPixel^.rgbRed := ((InvertTransparency * dstPixel^.rgbRed) +
                            (Transparency * srcPixel^.rgbRed)) div 100;
      dstPixel^.rgbGreen := ((InvertTransparency * dstPixel^.rgbGreen) +
                              (Transparency * srcPixel^.rgbGreen)) div 100;
      dstPixel^.rgbBlue := ((InvertTransparency * dstPixel^.rgbBlue) +
                             (Transparency * srcPixel^.rgbBlue)) div 100;
      Inc(srcPixel);
      Inc(dstPixel);
    end;
  end;
end;

{ TTextFader }

const
  AboutStr: String = 'TTextFader v1.24'                    + #13#10
                   + 'Copyright(c) Kambiz R. Khojasteh'    + #13#10
                   +                                         #13#10
                   + 'kambiz@delphiarea.com'               + #13#10
                   + 'http://www.delphiarea.com'           + #13#10
                   +                                         #13#10;

constructor TTextFader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  fLineIndex := -1;
  fActive := False;
  fLineDelay := 2000;
  fFadeDelay := 30;
  fFadeStep := 4;
  fWordWrap := True;
  fAlignment := taCenter;
  fBackgroundMode := bmTiled;
  fBackground := TPicture.Create;
  Background.OnChange := BackgroundChanged;
  fLines := TStringList.Create;
  TStringList(Lines).OnChange := LinesChanged;
  TStringList(Lines).Text := AboutStr;
  Timer := TTimer.Create(Self);
  Timer.Enabled := False;
  Timer.OnTimer := TimerExpired;
  Width := 200;
  Height := 16;
end;

destructor TTextFader.Destroy;
begin
  Active := False;
  Background.Free;
  Lines.Free;
  inherited Destroy;
end;

procedure TTextFader.Paint;
begin
  if not Drawing then
  begin
    Drawing := True;
    try
      PaintCanvas;
    finally
      Drawing := False;
    end;
  end;
end;

procedure TTextFader.Loaded;
begin
  inherited Loaded;
  if Active then
  begin
    Timer.Enabled := Active;
    Timer.Interval := 5
  end;
end;

procedure TTextFader.Reset;
begin
  FadeProgress := High(TPercent);
  OldText := EmptyStr;
  CurText := EmptyStr;
  fLineIndex := -1;
  if Active then
    Timer.Interval := 5
  else
    Invalidate;
end;

function TTextFader.IsLinesStored: Boolean;
begin
  Result := (Lines.Text <> AboutStr);
end;

procedure TTextFader.SetActive(Value: Boolean);
begin
  if Active <> Value then
  begin
    fActive := Value;
    FadeProgress := High(TPercent);
    if not (csLoading in ComponentState) then
    begin
      Timer.Enabled := Active;
      if Active then
      begin
        fRepeatedCount := 0;
        Timer.Interval := 5;
      end
      else
        Invalidate;
    end;
  end;
end;

procedure TTextFader.SetAlignment(Value: TAlignment);
begin
  if Alignment <> Value then
  begin
    fAlignment := Value;
    Invalidate;
  end;
end;

procedure TTextFader.SetWordWrap(Value: Boolean);
begin
  if WordWrap <> Value then
  begin
    fWordWrap := Value;
    Invalidate;
  end;
end;

procedure TTextFader.SetTransparent(Value: Boolean);
begin
  if Transparent <> Value then
  begin
    fTransparent := Value;
    Invalidate;
  end;
end;

procedure TTextFader.SetLineIndex(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if Value >= Lines.Count then
    Value := Lines.Count-1;
  if LineIndex <> Value then
  begin
    fLineIndex := Value;
    if FadeProgress = High(TPercent) then
      Timer.Interval := LineDelay;
  end;
end;

procedure TTextFader.SetLineDelay(Value: Word);
begin
  if LineDelay <> Value then
  begin
    fLineDelay := Value;
    if FadeProgress = High(TPercent) then
      Timer.Interval := LineDelay;
  end;
end;

procedure TTextFader.SetFadeDelay(Value: Word);
begin
  if FadeDelay <> Value then
  begin
    fFadeDelay := Value;
    if FadeProgress < High(TPercent) then
      Timer.Interval := FadeDelay;
  end;
end;

procedure TTextFader.SetBackgroundMode(Value: TBackgroundMode);
begin
  if BackgroundMode <> Value then
  begin
    fBackgroundMode := Value;
    Invalidate;
  end;
end;

procedure TTextFader.SetBackground(Value: TPicture);
begin
  Background.Assign(Value);
end;

procedure TTextFader.SetLines(Value: TStrings);
begin
  Lines.Assign(Value);
end;

procedure TTextFader.BackgroundChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TTextFader.LinesChanged(Sender: TObject);
begin
  if LineIndex >= Lines.Count then
    LineIndex := Lines.Count-1;
end;

procedure TTextFader.TimerExpired(Sender: TObject);

  function Translate(const S: String): String;
  var
    I: Integer;
    IsTag: Boolean;
  begin
    IsTag := False;
    Result := EmptyStr;
    for I := 1 to Length(S) do
    begin
      if IsTag then
      begin
        case S[I] of
          '\': Result := Result + '\';
          'n': Result := Result + #13#10;
          't': Result := Result + #9;
        end;
        IsTag := False;
      end
      else if S[I] = '\' then
        IsTag := True
      else
        Result := Result + S[I];
    end
  end;

  function GetNextLine: String;
  begin
    if LineIndex = Lines.Count-1 then
    begin
      Inc(fRepeatedCount);
      if (RepeatCount = 0) or (ReapeatedCount < RepeatCount) then
        LineIndex := 0
      else
        Active := False;
    end
    else
      LineIndex := LineIndex + 1;
    if LineIndex >= 0 then
      Result := Translate(Lines[LineIndex])
    else
      Result := EmptyStr;
  end;

begin
  if FadeProgress = High(TPercent) then
  begin
    OldText := CurText;
    CurText := GetNextLine;
    if Active then
    begin
      FadeProgress := Low(TPercent);
      Timer.Interval := FadeDelay;
    end;
  end;
  Inc(FadeProgress, FadeStep);
  if FadeProgress > High(TPercent) then
    FadeProgress := High(TPercent);
  Refresh;
  if FadeProgress = High(TPercent) then
  begin
    Timer.Interval := LineDelay;
    if Assigned(OnComplete) then
      OnComplete(Self);
  end;
end;

procedure TTextFader.PaintCanvas;

  procedure PaintText(ACanvas: TCanvas; const Text: String);
  const
    AlignFlags: array[TAlignment] of Integer = (DT_LEFT, DT_RIGHT, DT_CENTER);
    WrapFlags: array[Boolean] of Integer = (0, DT_WORDBREAK);
  var
    R: TRect;
    Flags: Integer;
  begin
    ACanvas.Font := Font;
    SetBkMode(ACanvas.Handle, Windows.TRANSPARENT);
    Flags := AlignFlags[Alignment] or WrapFlags[WordWrap] or DT_NOPREFIX or DT_EXPANDTABS;
    {$IFDEF COMPILER4_UP}
    Flags := DrawTextBiDiModeFlags(Flags);
    {$ENDIF}
    SetRect(R, 0, 0, Width, 0);
    DrawText(ACanvas.Handle, PChar(Text), Length(Text), R, Flags or DT_CALCRECT);
    R.Left := 0;
    R.Right := Width;
    OffSetRect(R, 0, (Height - R.Bottom) div 2);
    DrawText(ACanvas.Handle, PChar(Text), Length(Text), R, Flags);
  end;

var
  R: TRect;
  CurScreen, OldScreen: TBitmap;
begin
  CurScreen := TBitmap.Create;
  try
    CurScreen.Width := Width;
    CurScreen.Height := Height;
    if Transparent then
      CopyParentImage(Self, CurScreen.Canvas)
    else
    begin
      CurScreen.Canvas.Brush.Style := bsSolid;
      CurScreen.Canvas.Brush.Color := Color;
      SetRect(R, 0, 0, Width, Height);
      CurScreen.Canvas.FillRect(R);
      if Assigned(Background.Graphic) and not Background.Graphic.Empty then
        case BackgroundMode of
          bmTiled: DrawTiled(CurScreen.Canvas, R, Background.Graphic);
          bmStretched: CurScreen.Canvas.StretchDraw(R, Background.Graphic);
          bmCentered: CurScreen.Canvas.Draw((R.Right - R.Left - Background.Width) div 2,
                      (R.Bottom - R.Top - Background.Height) div 2, Background.Graphic);
        end;
    end;
    if FadeProgress = High(TPercent) then
      PaintText(CurScreen.Canvas, CurText)
    else
    begin
      OldScreen := TBitmap.Create;
      try
        OldScreen.Assign(CurScreen);
        PaintText(OldScreen.Canvas, OldText);
        PaintText(CurScreen.Canvas, CurText);
        DrawTransparent(CurScreen, OldScreen, 100-FadeProgress);
      finally
        OldScreen.Free;
      end;
    end;
    Canvas.Draw(0, 0, CurScreen);
  finally
    CurScreen.Free;
  end;
end;

procedure TTextFader.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(fOnMouseEnter) then
    fOnMouseEnter(Self);
end;

procedure TTextFader.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(fOnMouseLeave) then
    fOnMouseLeave(Self);
end;

procedure Register;
begin
  RegisterComponents('Delphi Area', [TTextFader]);
end;

end.
