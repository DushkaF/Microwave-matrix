//2024.10.14 laz36
//15 dataport - pull/send doesn't work, synapse ok, stringlist ok
//16 +tchart
//17 +timer
//12.03 +marks/labels +mark format
//12.09 +show data on mark
//12.10 +idn +lazlogger writeln->debugln
//12.11 fix-data[2*ii] +fstart/stop +CheckSocketError
//12.17 runtime Charts[1].create
//12.23 +DecimalSeparator +MaxNumPlots +NumPlot +s11&s21
//12.25 +PlotsNumX,PlotsNumY +PlotGetSize
//12.26 3x2 chart matrix test;  +ontimer reentry fix
//12.27 +PlotSetSize,PlotsCreate +header/footer +FormResize
//12.28 fix PlotSetSize/plotcreate; +case PlotsNum of; fix global ii; ii/jj swap???
//12.29 x/y fix v63
//2025.01.05 refactoring etc; +pagecotrol +pairsplitter
//2025.01.05 renamed dataporttest01->planar8x8 

unit planar8x8;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, Menus, PairSplitter, Spin, TAGraph, TASeries,
  blcksock  //synapse
  , TADrawUtils, TACustomSeries,
  LazLogger;

type
  { TForm1 }

  TForm1 = class(TForm)
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    SpinEditCurrentPlot: TSpinEdit;
    SpinEditPlotsNum: TSpinEdit;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PairSplitter1Resize(Sender: TObject);
  procedure PlotData(const NumPlotX, NumPlotY: integer);
  procedure GetData(const NumPlotX, NumPlotY: integer);
  procedure SpinEditCurrentPlotChange(Sender: TObject);
  procedure SpinEditPlotsNumChange(Sender: TObject);
  procedure Timer1Timer(Sender: TObject);
  procedure CheckSocketError(const info: String; const ShowMsg: Boolean);
  procedure PlotGetSize(const Control: TWinControl);
  procedure PlotSetSize;
  procedure PlotsSetParams;
  procedure PlotsCreate;
  procedure GetFrequency;
  procedure PlotsSetVisibility(const Vis: Boolean);
  procedure MarkCurrentPlot;



  private

  public

  end;  //TForm1

const
  PlotsNumMaxX = 4;  //4x4=16
  PlotsNumMaxY = 4;

var
  Form1: TForm1;
  c: TTCPBlockSocket;
  s: String;
  err: Integer;
  StringList: TStringList;
  Charts: array[1..PlotsNumMaxX, 1..PlotsNumMaxY] of TChart;
  ChartsLineSeries:  array[1..PlotsNumMaxX, 1..PlotsNumMaxY] of TLineSeries;
  DataRe: array[1..PlotsNumMaxX, 1..PlotsNumMaxY, 0..65535] of double;
  DataIm: array[1..PlotsNumMaxX, 1..PlotsNumMaxY, 0..65535] of double;
  IPAddr: String = '127.0.0.1';
  IPPort: String = '5025';
  TimerEnable: Boolean;
  PlotsNumX, PlotsNumY: Integer;
  PlotSizeX, PlotSizeY: Integer;
  PlotsNum: Integer = 1;
  FStart, FStop, FStep: Double;
  SweepPoints: Integer;
  CurrentPlotNum, CurrentPlotX, CurrentPlotY: Integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.CheckSocketError(const info: String; const ShowMsg: Boolean);
var s: String;
begin
if (c.LastError = 0)
then Exit
else
begin
s := 'ERROR: '+ '(' + info + ')' + ' Socket err = ' + IntToStr(c.LastError) + ' (' + c.LastErrorDesc + ')';
if ShowMsg then ShowMessage(s);
DebugLn(s);
ListBox1.Items.Add(s);
end //else

end;  //procedure CheckSocketError;



procedure TForm1.PlotsCreate;
var ii, jj: Integer;
begin

for ii:=1 to PlotsNumMaxX do
begin
for jj:=1 to PlotsNumMaxY do
begin

Charts[ii, jj]:= TChart.Create(nil);

 //Charts[ii, jj].Visible:=False;

Charts[ii, jj].Title.Text.Clear;  //remove default title
Charts[ii, jj].Title.Text.Add(IntToStr(ii)+', '+IntToStr(jj));
Charts[ii, jj].Title.Visible:=True;
//Charts[ii, jj].Foot.Text.Add(IntToStr(ii)+', '+IntToStr(jj));
//Charts[ii, jj].Foot.Visible:=True;
//Charts[ii, jj].Title.TextFormat.tfNormal '%2:s';
Charts[ii, jj].Parent:=PairSplitterSide2;

ChartsLineSeries[ii, jj]:= TLineSeries.Create(Charts[ii, jj]);
ChartsLineSeries[ii, jj].LinePen.Color:=clRed;
ChartsLineSeries[ii, jj].LinePen.Width:=3;
Charts[ii, jj].AddSeries(ChartsLineSeries[ii, jj]);

try
//!!! marks visible/invisible
//ChartsLineSeries[ii, jj].Marks.Format := '%2:s'; //!!! marks visible/invisible
 ChartsLineSeries[ii, jj].Marks.Format := '%2:s'; //!!! marks visible/invisible
except
  On E : Exception do
    begin
    DebugLn ('mark format Exception caught : ',E.Message);
    ChartsLineSeries[ii, jj].Marks.Format := '%2:s';
    end;
end; //try
ChartsLineSeries[ii, jj].Marks.LinkPen.Color := clBlack;
//ChartsLineSeries[1].Marks.Style := smsLabel;
//ChartsLineSeries[1].Marks.Title := 'y=cos(x)';
//ChartsLineSeries[1].LinePen.Color := clBlue;

end;  //for jj
end;  //for ii

PlotsSetVisibility(False);

end;  //PlotsCreate


procedure TForm1.PlotsSetVisibility(const Vis: Boolean);
var ii, jj: Integer;
begin

for ii:=1 to PlotsNumMaxX do
begin
for jj:=1 to PlotsNumMaxY do
begin
  Charts[ii, jj].Visible:=Vis;
end;  //for jj
end;  //for ii

end;  //PlotsSetVisibility

procedure TForm1.PlotGetSize(const Control: TWinControl);
begin
PlotSizeX := (Control.ClientWidth div PlotsNumX) - 1;
PlotSizeY := (Control.ClientHeight div PlotsNumY) - 1;
end;  //PlotGetSize


procedure TForm1.GetFrequency;
//var ii, jj: Integer;
begin

c.SendString ('SENS1:FREQ:STARt?'#10);
s := c.RecvTerminated(100, #10); //ok
FStart := StrToFloat(s);
DebugLn(['FStart = ', FStart]);

c.SendString ('SENS1:FREQ:STOP?'#10);
s := c.RecvTerminated(100, #10); //ok
FStop := StrToFloat(s);
DebugLn(['FEnd = ', FStop]);

//FStep:= (FStop - FStart) / (nos-1);

c.SendString ('SENS1:SWEEP:POINTS?'#10);
s := c.RecvTerminated(100, #10); //ok
SweepPoints := StrToInt(s);
DebugLn(['SENS1:SWEEP:POINTS? = ', SweepPoints]);

FStep:= (FStop - FStart) / (SweepPoints-1);

end;  //procedure TForm1.GetFrequency;


procedure TForm1.PlotSetSize;
var ii, jj: Integer;
begin

for jj:=1 to PlotsNumX do
begin
for ii:=1 to PlotsNumY do
begin

Charts[ii, jj].Left:=((jj-1)*PlotSizeX) div 1;
Charts[ii, jj].Top:=((ii-1)*PlotSizeY) div 1;

Charts[ii, jj].Width:=(PlotSizeX-1) div 1;
Charts[ii, jj].Height:=(PlotSizeY-1) div 1;

end;  //for jj
end;  //for ii

end;  //PlotSetSize


procedure TForm1.GetData(const NumPlotX, NumPlotY: integer);
var
  ii, jj: Integer;

begin
DebugLn('getting data');

//c.SendString (''#10);  //ok

c.SendString ('CALC:DATA:FDAT?'#10);  //ok
s := c.RecvTerminated(100, #10); //ok

//StringList := TStringList.Create;
StringList.Clear;
StringList.AddCommaText(s);

if (StringList.Count div 2 <> SweepPoints)
then
begin
DebugLn(['sl.Count div 2 <> SweepPoints : ', StringList.Count div 2, ' <> ', SweepPoints]);
ShowMessage('ERROR: sl.Count div 2 <> SweepPoints');
exit;
end;  //if

ListBox1.Items.Add( IntToStr(StringList.Count));
ListBox1.Items.Add(StringList.Strings[0]);
ListBox1.Items.Add(StringList.Strings[1]);
ListBox1.Items.Add(StringList.Strings[StringList.Count-1]);

DebugLn(StringList.Strings[0]);
DebugLn(StringList.Strings[1]);
//DebugLn(StringList.Strings[2]);
//DebugLn(StringList.Strings[3]);
//DebugLn(StringList.Strings[4]);
//DebugLn(StringList.Strings[5]);
DebugLn(StringList.Strings[StringList.Count-2]);
DebugLn(StringList.Strings[StringList.Count-1]);
//DebugLn(StringList.Strings[StringList.Count-0]);

//for ii:=0 to StringList.Count-1 do
for ii:=0 to SweepPoints-1 do
begin
  DataRe[NumPlotX, NumPlotY,  ii] := StrToFloat(StringList.Strings[2*ii]);
  //DebugLn(DataRe[1, ii]);
  DataIm[NumPlotX, NumPlotY,  ii] := StrToFloat(StringList.Strings[2*ii+1]);
end;  //for

end;  //procedure TForm1.GetData


procedure TForm1.SpinEditCurrentPlotChange(Sender: TObject);
begin
CurrentPlotNum := SpinEditCurrentPlot.Value;
MarkCurrentPlot;
end;


procedure TForm1.MarkCurrentPlot;
begin
Charts[CurrentPlotX, CurrentPlotY].Color:=clWhite;  //drop old selection

//CurrentPlotNum:=SpinEditCurrentPlot.Value;
CurrentPlotX:=(CurrentPlotNum div (PlotsNumX+1))+1;  //x/y???
CurrentPlotY:=CurrentPlotNum - (CurrentPlotX-1)*PlotsNumX;

StatusBar1.SimpleText:=IntToStr(CurrentPlotNum)
+'  ' + IntToStr(CurrentPlotX)
+ '  ' +IntToStr(CurrentPlotY)+'  ';

Charts[CurrentPlotX, CurrentPlotY].Color:=clTeal;  //mark new selection
end;


procedure TForm1.SpinEditPlotsNumChange(Sender: TObject);
begin
  PlotsSetParams;
end;


procedure TForm1.PlotData(const NumPlotX, NumPlotY: integer);
var
  ii, jj: Integer;
begin

//TimerEnable := False;

ChartsLineSeries[NumPlotX, NumPlotY].Clear;

ChartsLineSeries[NumPlotX, NumPlotY].BeginUpdate;

for ii:=0 to (SweepPoints - 1) do
begin
  //DebugLn([2*ii, ' ', DataRe[1, 2*ii]]);
  //ChartsLineSeries[1].AddXY(ii, DataRe[1, 2*ii]);  //even indexes
  //ChartsLineSeries[NumPlotX, NumPlotY].AddXY(ii*FStep, DataRe[NumPlotX, NumPlotY, 2*ii]);  //even indexes

  ChartsLineSeries[NumPlotX, NumPlotY].AddXY(ii*FStep, DataRe[NumPlotX, NumPlotY, ii]);  //even indexes
end;  //for

ChartsLineSeries[NumPlotX, NumPlotY].Marks.Visible:=True;  //!!!

ChartsLineSeries[NumPlotX, NumPlotY].Source.Item[SweepPoints div 2]^.Text := 's=' + FloatToStrF( ChartsLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2], fffixed, 3, 2 );
DebugLn( 'v=', [ChartsLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2]] );
DebugLn( 'sv=', FloatToStr(ChartsLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2]) );
DebugLn( 'svf=', FloatToStrF( ChartsLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2], fffixed, 3, 2 ) );


ChartsLineSeries[NumPlotX, NumPlotY].Source.Item[SweepPoints div 4]^.Text := 's=' + FloatToStrF( ChartsLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 4], fffixed, 3, 2 );
//DebugLn( 'v=', [ChartsLineSeries[1].YValue[SweepPoints div 4]] );
//DebugLn( 'sv=', FloatToStr(ChartsLineSeries[1].YValue[SweepPoints div 4]) );
//DebugLn( 'svf=', FloatToStrF( ChartsLineSeries[1].YValue[SweepPoints div 4], fffixed, 3, 2 ) );

ChartsLineSeries[NumPlotX, NumPlotY].EndUpdate;

Charts[NumPlotX, NumPlotY].Invalidate;

//TimerEnable := True;

end;  //procedure TForm1.PlotData



procedure TForm1.Timer1Timer(Sender: TObject);
var ii, jj: Integer;
begin
if (not TimerEnable) then Exit; //prevent preliminary re-entering

TimerEnable := False;

for ii:=1 to PlotsNumY do
begin
for jj:=1 to PlotsNumX do
begin

//DebugLn('===============');
//DebugLn(['y=',jj,' x=',ii, ' PlotsNumX*(jj-1)+ii = ', PlotsNumY*(jj-1)+ii]);

if (PlotsNumX*(ii-1)+jj+0)>PlotsNum then break;

//if (PlotsNumY*(ii-1)+jj+0)>PlotsNum then
begin
//DebugLn('bbbbbbbbbbbbbb');
//DebugLn(['y=',jj,' x=',ii, ' PlotsNumX*(jj-1)+ii = ', PlotsNumY*(jj-1)+ii]);
//break;
end;

Charts[ii, jj].Visible:=True;

if Odd(ii+jj)
then
begin
c.SendString ('CALC:PAR:DEF S11'#10);
c.SendString ('CALC:FORM MLOG'#10);
ChartsLineSeries[ii, jj].LinePen.Color:=clRed
end  //if
else
begin
c.SendString ('CALC:PAR:DEF S21'#10);
c.SendString ('CALC:FORM MLOG'#10);
ChartsLineSeries[ii, jj].LinePen.Color:=clBlue
end;  //else

GetData(ii,jj);
PlotData(ii,jj);

end;  //for jj
end;  //for ii

TimerEnable := True;

end;  //timer


procedure TForm1.PlotsSetParams;
begin

PlotsNum := SpinEditPlotsNum.Value;                                                                                                                                                                                                   ;

case PlotsNum of
1: begin; PlotsNumX := 1; PlotsNumY := 1; end;
2: begin; PlotsNumX := 2; PlotsNumY := 1; end;
//3: begin; PlotsNumX := 3; PlotsNumY := 1; end;
3..4: begin; PlotsNumX := 2; PlotsNumY := 2; end;
5..6: begin; PlotsNumX := 3; PlotsNumY := 2; end;
7..8: begin; PlotsNumX := 4; PlotsNumY := 2; end;
9: begin; PlotsNumX := 3; PlotsNumY := 3; end;
10..12: begin; PlotsNumX := 4; PlotsNumY := 3; end;
13..16: begin; PlotsNumX := 4; PlotsNumY := 4; end;
else ShowMessage('ERROR: wrong PlotsNum');
end;  //case

PlotsSetVisibility(False);
PlotGetSize(PairSplitterSide2);
PlotSetSize;

end; //PlotsSetParams


procedure TForm1.FormCreate(Sender: TObject);
//var ii, jj: Integer;
begin

DefaultFormatSettings.DecimalSeparator:= '.';  //!!!win rus

DebugLn('starting');


DebugLn('TTCPBlockSocket.Create');
c := TTCPBlockSocket.Create;
DebugLn('Connecting');
try
//c.Connect ('127.0.0.1', '5025');
c.Connect (IPAddr, IPPort);
except  //!!!no exception
//  DebugLn('Error: cannot connect');
//  ListBox1.Items.Add('Error: cannot connect');
//  Exit;
end;

CheckSocketError('TTCPBlockSocket.Create', true);

err := c.LastError;
DebugLn([err]);
DebugLn('LastErrorDesc = ', c.LastErrorDesc);

if err<>0 then
begin
ShowMessage('ERROR: TTCPBlockSocket cannot connect');
DebugLn('ERROR: TTCPBlockSocket cannot connect');
ListBox1.Items.Add('ERROR: TTCPBlockSocket cannot connect');
c.CloseSocket;
Exit;
end
else
DebugLn('OK: TTCPBlockSocket connected');

//c.SendString ('SENS1:FREQ:STAR?'#10);  //ok

c.SendString ('*IDN?'#10);  //ok
s := c.RecvTerminated(100, #10); //ok
DebugLn('*IDN? = ', s);
DebugLn([err]);
DebugLn('LastErrorDesc = ', c.LastErrorDesc);


if (not s.Contains('Planar')) then
begin
ShowMessage('ERROR: Planar not found');
DebugLn('ERROR: Planar not found');
ListBox1.Items.Add('ERROR: Planar not found');
c.CloseSocket;
Exit;
end
else
DebugLn('OK: Planar identified');

GetFrequency;

StringList := TStringList.Create;  //scpi Data string parser
StringList.Capacity := 65535;

DebugLn('TChart.Creating');

PlotsCreate;
PlotsSetParams;

CurrentPlotX:=1;
CurrentPlotY:=1;
CurrentPlotNum:=1;
MarkCurrentPlot;


TimerEnable:=True;
Timer1.Enabled:=True;

end;  //create


procedure TForm1.FormDestroy(Sender: TObject);
begin
//if Assigned(dp) then dp.Close();
c.CloseSocket;
end; //destroy


procedure TForm1.PairSplitter1Resize(Sender: TObject);
begin
TimerEnable:=False;
  PlotGetSize(PairSplitterSide2);
  PlotSetSize;
TimerEnable:=True;
end;

end. //end planar8x8

