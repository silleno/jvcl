{$I JVCL.INC}
unit JvProgressEditor;

interface
uses
  Windows, Classes, SysUtils,
  {$IFDEF COMPILER6_UP}
  RTLConsts, DesignIntf, VCLEditors, DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  Controls, Forms;

type
  TJvProgressControlProperty = class(TComponentProperty)
  private
    FProc: TGetStrProc;
    procedure CheckComponent(const AName: string);
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

implementation
uses
  Consts, Dialogs,
  JvConsts, JvProgressUtils;

//=== TJvProgressControlProperty =============================================

procedure TJvProgressControlProperty.CheckComponent(const AName: string);
var
  Component: TComponent;
begin
  Component := Designer.GetComponent(AName);
  if (Component <> nil) and (Component is TControl) and
    SupportsProgressControl(TControl(Component)) and Assigned(FProc) then
    FProc(AName);
end;

procedure TJvProgressControlProperty.GetValues(Proc: TGetStrProc);
begin
  FProc := Proc;
  try
    inherited GetValues(CheckComponent);
  finally
    FProc := nil;
  end;
end;

end.
