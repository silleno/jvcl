{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvWizardRouteMapSteps.PAS, released on 2002-02-11.

The Initial Developer of the Original Code is Max Evans.
Portions created by Max Evans are Copyright (C) 2002 Max Evans

Contributor(s):

Last Modified: 2002-02-12

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Purpose:
  Step style route map for TJvWizardRouteMap

History:

Known Issues:
-----------------------------------------------------------------------------}

unit JvWizardRouteMapSteps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  JvWizard;

type
  TJvWizardRouteMapSteps = class(TJvWizardRouteMapControl)
  private
    FIndent: Integer;
    FNextStepText: string;
    FPreviousStepText: string;
    FShowDivider: Boolean;
    FShowNavigators: Boolean;
    function  GetActiveStepRect: TRect;
    function  GetPreviousStepRect: TRect;
    function  GetNextStepRect: TRect;
    function  GetPreviousArrowRect: TRect;
    function  GetNextArrowRect: TRect;
    procedure SetIndent(const Value: Integer);
    procedure SetNextStepText(const Value: string);
    procedure SetPreviousStepText(const Value: string);
    procedure SetShowDivider(const Value: Boolean);
    procedure SetShowNavigators(const Value: Boolean);
    function  DetectPageCount(var ActivePageIndex: Integer): Integer; // Add by Yu Wei
    function  DetectPage(const Pt: TPoint): TJvWizardCustomPage; // Add by Yu Wei
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function PageAtPos(Pt: TPoint): TJvWizardCustomPage; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Color;
    property Font;
    property Indent: Integer read FIndent write SetIndent default 5;
    property PreviousStepText: string read FPreviousStepText write SetPreviousStepText;
    property NextStepText: string read FNextStepText write SetNextStepText;
    property ShowDivider: Boolean read FShowDivider write SetShowDivider default True;
    property ShowNavigators: Boolean read FShowNavigators write SetShowNavigators  default True;
  end;

implementation

uses
  JvResources;

constructor TJvWizardRouteMapSteps.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIndent := 5;
  Color := clBackground;
  Font.Color := clWhite;
  FPreviousStepText := rsBackTo;
  FNextStepText := rsNextStep;
  FShowNavigators := True;
  FShowDivider := True;
end;

function TJvWizardRouteMapSteps.DetectPage(const Pt: TPoint): TJvWizardCustomPage;
begin
  // Ignore all disabled pages at run time.
  if PtInRect(GetPreviousArrowRect, Pt) then
    Result := Wizard.FindNextPage(PageIndex, -1, not (csDesigning in ComponentState))
  else
  if PtInRect(GetNextArrowRect, Pt) then
    Result := Wizard.FindNextPage(PageIndex, 1, not (csDesigning in ComponentState))
  else
    Result := nil;
end;

function TJvWizardRouteMapSteps.GetActiveStepRect: TRect;
begin
  Result := Rect(Left + FIndent,(ClientHeight div 2 - Canvas.TextHeight('Yy')),
    Width, ClientHeight div 2);
end;

function TJvWizardRouteMapSteps.GetNextArrowRect: TRect;
begin
  Result := Rect(Left + FIndent, Height - Indent - 32, Left + FIndent + 16,
    (Height - FIndent) - 16);
end;

function TJvWizardRouteMapSteps.GetNextStepRect: TRect;
begin
  Result := Rect(Left + FIndent, Height - FIndent - 32, Width,
    Height - FIndent - 32  +  Canvas.TextHeight('Yy'));
end;

function TJvWizardRouteMapSteps.DetectPageCount(var ActivePageIndex: Integer): Integer;
var
  I: Integer;
begin
  // Ignore all disabled pages at run time.
  ActivePageIndex := 0;
  Result := 0;
  for I := 0 to PageCount - 1 do
  begin
    if (csDesigning in ComponentState) or Pages[I].Enabled then
    begin
      if I <= PageIndex then
        Inc(ActivePageIndex);
      Inc(Result);
    end;
  end;
end;

function TJvWizardRouteMapSteps.GetPreviousArrowRect: TRect;
begin
  Result := Rect(Left + FIndent, Top + FIndent, Left + FIndent + 16,
    Top + FIndent + 16);
end;

function TJvWizardRouteMapSteps.GetPreviousStepRect: TRect;
begin
  Result := Rect(Left + FIndent, Top + FIndent, Width,
    Top + FIndent + Canvas.TextHeight('Yy'));
end;

procedure TJvWizardRouteMapSteps.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
  APage: TJvWizardCustomPage;
begin
  inherited MouseMove(Shift, X, Y);
  Pt := Point(X, Y);
  if PtInRect(ClientRect, Pt) and ShowNavigators then
  begin
    APage := DetectPage(Pt);
    if Assigned(APage) then
      Screen.Cursor := crHandPoint
    else
      Screen.Cursor := crDefault;
  end;
end;

function TJvWizardRouteMapSteps.PageAtPos(Pt: TPoint): TJvWizardCustomPage;
begin
  Result := DetectPage(Pt);
end;

procedure TJvWizardRouteMapSteps.Paint;
var
  ARect, TextRect, ArrowRect, DividerRect: TRect;
  ActivePageIndex, TotalPageCount: Integer;
  StepHeight: Integer;
  APage: TJvWizardCustomPage;
begin
  ARect := ClientRect;
  TotalPageCount := DetectPageCount(ActivePageIndex);

  TextRect := GetActiveStepRect;
  Canvas.Font.Assign(Font);
  Canvas.Font.Style:= [fsBold];
  Canvas.Brush.Style:= bsClear;

  StepHeight := DrawText(Canvas.Handle, PChar(Format(rsActiveStepFormat,
     [ActivePageIndex, TotalPageCount])), -1, TextRect,
     DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);

  // Display Active Page Description
  Canvas.Font.Style:= [];
  OffsetRect(TextRect, 0, StepHeight);
  DrawText(Canvas.Handle, PChar(Pages[PageIndex].Caption), -1, TextRect,
           DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);
  Canvas.Font.Style:= [];
  if FShowDivider then
  begin
    SetRect(DividerRect, Left + FIndent, TextRect.Bottom + 5, Width - FIndent,
      TextRect.Bottom + 6);
    DrawEdge(Canvas.Handle, DividerRect, EDGE_RAISED, BF_FLAT OR BF_BOTTOM);
  end;

  { do the prevous step}
  
  // YW - Ignore all disabled pages at run time
  APage := Wizard.FindNextPage(PageIndex, -1, not (csDesigning in ComponentState));
  if Assigned(APage) then
  begin
    TextRect := GetPreviousStepRect;
    ArrowRect := GetPreviousArrowRect;
    Canvas.Font.Style:= [];
    if ShowNavigators then
    begin
      if TextRect.Left + FIndent + ArrowRect.Right - ArrowRect.Left < Width then
        OffSetRect(TextRect, ArrowRect.Right, 0);
      DrawFrameControl(Canvas.Handle, ArrowRect, DFC_SCROLL,
        DFCS_SCROLLLEFT or DFCS_FLAT);
    end;
    StepHeight := DrawText(Canvas.Handle, PChar(FPreviousStepText), -1, TextRect,
      DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);
    OffsetRect(TextRect, 0, StepHeight);
    DrawText(Canvas.Handle, PChar(APage.Caption), -1, TextRect,
      DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);
  end;

  { do the next step}

  // YW - Ignore all disabled pages at run time
  APage := Wizard.FindNextPage(PageIndex, 1, not (csDesigning in ComponentState));
  if Assigned(APage) then
  begin
    TextRect := GetNextStepRect;
    ArrowRect := GetNextArrowRect;
    Canvas.Font.Style := [];
    if ShowNavigators then
    begin
      OffsetRect(TextRect, ArrowRect.Right, 0);
      DrawFrameControl(Canvas.Handle, ArrowRect, DFC_SCROLL,
        DFCS_SCROLLRIGHT or DFCS_FLAT);
    end;
    StepHeight := DrawText(Canvas.Handle, PChar(FNextStepText), -1, TextRect,
      DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);
    OffsetRect(TextRect, 0, StepHeight);
    DrawText(Canvas.Handle, PChar(APage.Caption), -1, TextRect,
      DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);
  end;
end;

procedure TJvWizardRouteMapSteps.SetShowDivider(const Value: Boolean);
begin
  if FShowDivider <> Value then
  begin
    FShowDivider := Value;
    Invalidate;
  end;
end;

procedure TJvWizardRouteMapSteps.SetIndent(const Value: Integer);
begin
  if FIndent <> Value then
  begin
    FIndent := Value;
    Invalidate;
  end;
end;

procedure TJvWizardRouteMapSteps.SetNextStepText(const Value: string);
begin
  if FNextStepText <> Value then
  begin
    FNextStepText := Value;
    Invalidate;
  end;
end;

procedure TJvWizardRouteMapSteps.SetPreviousStepText(const Value: string);
begin
  if FPreviousStepText <> Value then
  begin
    FPreviousStepText := Value;
    Invalidate;
  end;
end;

procedure TJvWizardRouteMapSteps.SetShowNavigators(const Value: Boolean);
begin
  if FShowNavigators <> Value then
  begin
    FShowNavigators := Value;
    Invalidate;
  end;
end;

end.
