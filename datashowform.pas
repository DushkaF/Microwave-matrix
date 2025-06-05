unit DataShowForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Menus, Grids;

type

  { TFormDataShow }

  TFormDataShow = class(TForm)
    MainMenu1: TMainMenu;
    PageControlData: TPageControl;
    StatusBarFormDataShow: TStatusBar;
    Markers: TTabSheet;
    StringGridMarkers2: TStringGrid;
    TabSheet2: TTabSheet;
  private

  public

  end;

var
  FormDataShow: TFormDataShow;

implementation

{$R *.lfm}

end.

