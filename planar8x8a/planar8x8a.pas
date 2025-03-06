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
//2025.01.06 renamed dataporttest01->planar8x8
//01.07,08 x/y mark fix?
//01.09 +RadioGroupS11S21 +RadioGroupMagPhase
//01.10 line colors
//01.14 Chart1.LeftAxis.Range.Max unsuccessfull attempts
//01.15 +sleep(dt) +SetAxisMaxMin->SetAxisMinMax
//01.25 setfstart/fstop, f-axis fix, create fixes
//01.26 +Send/receiveStringTerminatedAndCheck +Set/getSweepPoints; fix ontimer
//01.29 fix(SpinEditCurrentPlotNum.Value < 1); +MarkerParameters
//01.30 +SwitchParameters  +ButtonConnect
//02.02 +ip-addr-editors +Chart[ii,jj].Extent.YMin +Marks.AutoMargins := False
//03.02 +marker & switch controls;
//04.02 +CalibrationData; data[NumPlotX, NumPlotY]->data[numplot];+CopyToClipboard; +test
//05.02 +CalibrationFile  +try
//09.02 CalibrationFile->FileTemp; +struct Parameters (for freq)
//10.02 +more params  +ioresult
//11.02 fixed LoadFile(blockread(^buf)) +SaveFile
//12.02 SaveFile ok?; checkbox cal restore fix; LoadFile fix; CurrentPlotNum fix; +spineditmaxys11/s21;
//21.02 +save IPaddr; edit ip planar/witch fix; ipport str->int
//23.02 debug - DebugLn GetPlotNum SwitchParams ok?s
//25.02 gui reaction time fixes; refactoring; fix SpinEditMarkerChartNumChange

unit planar8x8a;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Math, DateUtils,
  StdCtrls, Menus, PairSplitter, Spin, TAGraph,
  TASeries, TACustomSeries, TATransformations, blcksock,  //synapse/blcksock
  synaip,  //synapse/isip()
  LazLogger;

type
  { TForm1 }

  TForm1 = class(TForm)
    ButtonCalibrate: TButton;
    ButtonConnect: TButton;
    CheckBoxCalibrationApply: TCheckBox;
    CheckBoxMarkerEnabled: TCheckBox;
    EditIPAddressPlanar: TEdit;
    EditIPAddressSwitch: TEdit;
    FloatSpinEditMarkerFrequency: TFloatSpinEdit;
    FloatSpinEditFStart: TFloatSpinEdit;
    FloatSpinEditFStop: TFloatSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    LabelS21Max: TLabel;
    LabelS11Min: TLabel;
    LabelS11Max: TLabel;
    LabelS21Min: TLabel;
    LabelSwitchChartNum: TLabel;
    LabelArrow: TLabel;
    LabelMarkerFrequency: TLabel;
    LabelMarkerChartNum: TLabel;
    LabelMarkerNum: TLabel;
    LabelIPPlanar: TLabel;
    LabelIPSwitch: TLabel;
    LabelPoints: TLabel;
    LabelFStart: TLabel;
    LabelFStop: TLabel;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItemTest: TMenuItem;
    MenuItemCopy: TMenuItem;
    MenuItemEdit: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    RadioGroupSwitchOutNum: TRadioGroup;
    RadioGroupSwitchInNum: TRadioGroup;
    RadioGroupS11S21: TRadioGroup;
    RadioGroupMagPhase: TRadioGroup;
    SaveDialog: TSaveDialog;
    SpinEditYMinS11: TSpinEdit;
    SpinEditMarkerNum: TSpinEdit;
    SpinEditMarkerChartNum: TSpinEdit;
    SpinEditIPPortPlanar: TSpinEdit;
    SpinEditIPPortSwitch: TSpinEdit;
    SpinEditYMaxS11: TSpinEdit;
    SpinEditYMinS21: TSpinEdit;
    SpinEditYMaxS21: TSpinEdit;
    SpinEditSweepPoints: TSpinEdit;
    SpinEditCurrentPlotNum: TSpinEdit;
    SpinEditPlotsNum: TSpinEdit;
    StatusBar1: TStatusBar;
    TabSheetMain: TTabSheet;
    TabSheetSettings: TTabSheet;
    TabSheetMarkers: TTabSheet;
    TabSheetSwitch: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheetLog: TTabSheet;
    Timer1: TTimer;

    procedure ButtonCalibrateClick(Sender: TObject);
    procedure ButtonConnectClick(Sender: TObject);
    procedure CheckBoxCalibrationApplyChange(Sender: TObject);
    procedure CheckBoxMarkerEnabledChange(Sender: TObject);
    procedure EditIPAddressSwitchEditingDone(Sender: TObject);
    procedure EditIPAddressPlanarEditingDone(Sender: TObject);
    procedure FloatSpinEditFStartEditingDone(Sender: TObject);
    procedure FloatSpinEditFStopEditingDone(Sender: TObject);
    procedure FloatSpinEditMarkerFrequencyEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItemCopyClick(Sender: TObject);
    procedure MenuItemTestClick(Sender: TObject);
    procedure PairSplitter1Resize(Sender: TObject);
    procedure RadioGroupMagPhaseClick(Sender: TObject);
    procedure RadioGroupS11S21Click(Sender: TObject);
    procedure RadioGroupSwitchInNumClick(Sender: TObject);
    procedure RadioGroupSwitchOutNumClick(Sender: TObject);
    procedure SpinEditCurrentPlotNumChange(Sender: TObject);
    procedure SpinEditIPPortPlanarChange(Sender: TObject);
    procedure SpinEditIPPortSwitchChange(Sender: TObject);
    procedure SpinEditMarkerChartNumChange(Sender: TObject);
    procedure SpinEditMarkerNumChange(Sender: TObject);
    procedure SpinEditYMaxS11Change(Sender: TObject);
    procedure SpinEditYMaxS21Change(Sender: TObject);
    procedure SpinEditYMinS11Change(Sender: TObject);
    procedure SpinEditPlotsNumChange(Sender: TObject);
    procedure SpinEditSweepPointsEditingDone(Sender: TObject);
    procedure SpinEditYMinS21Change(Sender: TObject);
    procedure TabSheetSwitchEnter(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure PlotData(const NumPlotX, NumPlotY: integer);
    procedure GetData(const NumPlotX, NumPlotY: integer);
    function CheckSocketError(const info: String; const ShowMsg: Boolean): Boolean;
    function SendStringTerminatedAndCheck(const s, info: String; const ShowMsg: Boolean): Boolean;
    function ReceiveStringTerminatedAndCheck(out s:String; const info: String; const ShowMsg: Boolean): Boolean;
    procedure PlotGetSize(const Control: TWinControl);
    procedure PlotSetSize;
    procedure PlotsSetParams;
    procedure PlotsCreate;
    procedure PlotsSetVisibility(const Vis: Boolean);
    procedure PlotsSetColor(const Col: TColor);
    procedure MarkCurrentPlot;
    procedure GetCurrentPlotIJ;
    function GetPlotNum(const ii, jj: Integer): Integer; inline;
    procedure GetFrequency;
    procedure SetFrequency(const F1, F2: Double);
    procedure GetSweepPoints;
    procedure SetSweepPoints(const NumPoints: Integer);
    procedure SetAxisMinMax(const ii, jj: integer; Min, Max: Double);
    procedure LoadFile(const FileName: String; const FileSize: Integer; Target: Pointer);
    procedure SaveFile(const FileName: String; const FileSize: Integer; Target: Pointer);
    // S2P Save
    procedure SaveS2P(Sender: TObject);
    function FormatS2PString(PlotIndex, PointIndex: Integer): string;
    procedure SaveDataToS2P(const FileName: string; const SaveFormat:Integer);

    //Send switch POST request
    //function SendPostRequest(const IPAddr, IPPort: string; const Switch1, Switch2: Integer): Boolean;
    function ConnectToServer(const IPAddr, IPPort: string; out Socket: TTCPBlockSocket): Boolean;
    procedure DisconnectFromServer(var Socket: TTCPBlockSocket);
    function SendSwitchState(Socket: TTCPBlockSocket; const Switch1, Switch2: Integer): Boolean;

  private
    PrivateTest: Boolean;

  public

  end;  //TForm1

type

Parameters = record   //save/recall params
  PlotsNum, CurrentPlotNum: Integer;
  FStart, FStop: Double;  //
  SweepPoints: Integer;
  CalibrationApply: array[1..32] of Boolean;  //32>PlotsNumMax; array[1..PlotsNumMax]
  PlotExtentYMinS11, PlotExtentYMaxS11, PlotExtentYMinS21, PlotExtentYMaxS21: Single;
  IPAddressPlanar: ShortString;  // ShortString = String[255];
  IPPortPlanar: Integer;
  IPAddressSwitch: ShortString;  // ShortString = String[255];
  IPPortSwitch:  Integer;

end;  //record

PlotParameters = record
  SName, SFormat: integer;  //SName 0-s11, 1-s21; SFormat 0-mlog, 1-phase
end;  //record

MarkerParameters = record
  MarkerChartNum: integer;
  MarkerEnabled: Boolean;
  MarkerFrequency: Double;
end;  //record

SwitchParameters = record
  //SwitchChartNum: integer;
  InputNum, OutputNum: integer;
end;  //record


const
  PlotsNumMaxX = 4;  //4x4=16
  PlotsNumMaxY = 4;
  PlotsNumMax = PlotsNumMaxX*PlotsNumMaxY;
  MarkersNumMax = 6;
  dt = 1;  //time delay ms
  Timeout = 800; //If no data is received within TIMEOUT (in milliseconds)
  //FileNameBase: String = 'planar8x8.';
  FileNameCalibration: String = 'planar8x8' + '.cal';
  FileNameParameters: String = 'planar8x8.param';
  FileNameMarkers: String = 'planar8x8.mark';
  FileNamePlotParameters: String = 'planar8x8.plot';
  FileNameSwitchParameters: String = 'planar8x8.sw';
  DataSizeMax = 16384; //max SweepPoints

var
  Form1: TForm1;
  c: TTCPBlockSocket;
  s: String;
  err: Integer;
  StringList: TStringList;

  switchSocket: TTCPBlockSocket;

  Chart: array[1..PlotsNumMaxX, 1..PlotsNumMaxY] of TChart;
  ChartLineSeries:  array[1..PlotsNumMaxX, 1..PlotsNumMaxY] of TLineSeries;
  DataRe, DataIm, CalibrationDataRe, CalibrationDataIm: array[1..PlotsNumMax, 0..DataSizeMax-1] of Single;
  //type CalibrationDataRePtr = ^CalibrationDataRe;

  IPAddressPlanar: String = '127.0.0.1';
  IPPortPlanar: Integer = 5025;
  IPAddressSwitch: String = '172.16.22.251';
  IPPortSwitch: Integer = 80;

  TimerEnable: Boolean = False;
  //FStart, FStartOld, FStop, FStopOld, FStep, FStepOld: Double;
  FStartOld, FStopOld, FStep, FStepOld: Double;
  //SweepPoints, SweepPointsOld: Integer;
  SweepPointsOld: Integer;

  //PlotsNum: Integer = 1;
  //CurrentPlotNum, CurrentPlotNumI, CurrentPlotNumJ: Integer;
  CurrentPlotNumI, CurrentPlotNumJ: Integer;
  PlotsNumX, PlotsNumY: Integer;
  PlotSizeX, PlotSizeY: Integer;

  Params : Parameters;
  PlotParams : array[1..PlotsNumMax] of PlotParameters;
  MarkerParams : array[1..MarkersNumMax] of MarkerParameters;
  SwitchParams : array[1..PlotsNumMax] of SwitchParameters;

  Connected: Boolean = False;
  MarkerNum: Integer = 1;
  MarkerChartNum: Integer = 1;
  MarkerFrequency: Double = 1e9;
  CalibrationGetData : Boolean = False;
  //CalibrationApply: array[1..PlotsNumMax] of Boolean;
  //FileNameCalibration: String = FileNameBase + 'cal';
  ChartsVisible : Boolean = True;

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.CheckSocketError(const info: String; const ShowMsg: Boolean): Boolean;
var s: String;
begin
//DebugLn('CheckSocketError');
if (c.LastError = 0)
then
begin
Result := False;
Exit
end
else
begin
s := 'ERROR: '+ '(' + info + ')' + ' Socket err = ' + IntToStr(c.LastError) + ' (' + c.LastErrorDesc + ')';
if ShowMsg then ShowMessage(s);
DebugLn(s);
ListBox1.Items.Add(s);
Result := True;
end //else

end;  //procedure CheckSocketError;



//send s+#10 and CheckSocketError
function TForm1.SendStringTerminatedAndCheck(const s, info: String; const ShowMsg: Boolean): Boolean;
begin
c.SendString (s + #10); //send terminated string
if CheckSocketError(info, ShowMsg)=True  //error
then Result := False
else Result := True;
end; //SendStringTerminatedAndCheck


//receive s+#10 and CheckSocketError
function TForm1.ReceiveStringTerminatedAndCheck(out s:String; const info: String; const ShowMsg: Boolean): Boolean;
begin
s := c.RecvTerminated(Timeout, #10);
if CheckSocketError(info, ShowMsg)=True  //error
then Result := False
else Result := True;
end; //ReceiveStringTerminatedAndCheck



procedure TForm1.PlotsCreate;
var ii, jj: Integer;
begin
DebugLn('PlotsCreate');

for ii:=1 to PlotsNumMaxX do
begin
for jj:=1 to PlotsNumMaxY do
begin

Chart[ii, jj]:= TChart.Create(self);

Chart[ii, jj].AllowZoom :=False;
Chart[ii, jj].AllowPanning :=False;

 //Chart[ii, jj].Visible:=False;

Chart[ii, jj].Title.Text.Clear;  //remove default title
Chart[ii, jj].Title.Text.Add(IntToStr(ii)+', '+IntToStr(jj));
Chart[ii, jj].Title.Visible:=True;
//Chart[ii, jj].Foot.Text.Add(IntToStr(ii)+', '+IntToStr(jj));
//Chart[ii, jj].Foot.Visible:=True;
//Chart[ii, jj].Title.TextFormat.tfNormal '%2:s';
Chart[ii, jj].Parent:=PairSplitterSide2;

//Chart[ii,jj].LeftAxis.Transformations := ChartAxisTransformations1;
//Chart[ii,jj].LeftAxis.Range.Min := Min;
Chart[ii,jj].LeftAxis.Range.UseMin := True;
//Chart[ii,jj].LeftAxis.Range.Max := Max;
Chart[ii,jj].LeftAxis.Range.UseMax := True;
Chart[ii,jj].LeftAxis.MarginsForMarks:=False; //no effect?

Chart[ii,jj].BottomAxis.LabelSize:=22;
Chart[ii,jj].BottomAxis.MarginsForMarks:=True; //no effect?

//ChartLineSeries[ii, jj]:= TLineSeries.Create(Chart[ii, jj]);
ChartLineSeries[ii, jj]:= TLineSeries.Create(self);
ChartLineSeries[ii, jj].LinePen.Color:=clBlack;
ChartLineSeries[ii, jj].LinePen.Width:=3;
ChartLineSeries[ii, jj].AxisIndexX:=-1;  //-1=bottom axis
ChartLineSeries[ii, jj].AxisIndexY:=-1;  //-1=left axis

Chart[ii, jj].AddSeries(ChartLineSeries[ii, jj]);

try
//!!! marks visible/invisible
//ChartLineSeries[ii, jj].Marks.Format := '%2:s'; //!!! marks visible/invisible
 ChartLineSeries[ii, jj].Marks.Format := '%2:s'; //!!! marks visible/invisible
except
  On E : Exception do
    begin
    DebugLn ('ERROR : mark format Exception caught : ',E.Message);
    ShowMessage('ERROR : mark format Exception caught : ' + E.Message);
    ChartLineSeries[ii, jj].Marks.Format := '%2:s';
    end;
end; //try
ChartLineSeries[ii, jj].Marks.LinkPen.Color := clBlack;
//ChartLineSeries[1].Marks.Style := smsLabel;
//ChartLineSeries[1].Marks.Title := 'y=cos(x)';
//ChartLineSeries[1].LinePen.Color := clBlue;

end;  //for jj
end;  //for ii

PlotsSetVisibility(False);

end;  //PlotsCreate



procedure TForm1.PlotsSetVisibility(const Vis: Boolean);
var ii, jj: Integer;
begin
DebugLn(['PlotsSetVisibility : ', Vis]);
for ii:=1 to PlotsNumMaxX do
begin
for jj:=1 to PlotsNumMaxY do
begin
  Chart[ii, jj].Visible:=Vis;
end;  //for jj
end;  //for ii
end;  //PlotsSetVisibility



procedure TForm1.PlotsSetColor(const Col: TColor);
var ii, jj: Integer;
begin
DebugLn(['PlotsSetColor : ', Col]);
for ii:=1 to PlotsNumMaxX do
begin
for jj:=1 to PlotsNumMaxY do
begin
  Chart[ii, jj].Color := Col;
end;  //for jj
end;  //for ii
end;  //PlotsSetColor



procedure TForm1.PlotGetSize(const Control: TWinControl);
begin
DebugLn('PlotGetSize');
PlotSizeX := (Control.ClientWidth div PlotsNumX) - 1;
PlotSizeY := (Control.ClientHeight div PlotsNumY) - 1;
end;  //PlotGetSize



procedure TForm1.SetAxisMinMax(const ii, jj: integer; Min, Max: Double);
begin

  Chart[ii,jj].LeftAxis.UpdateBounds(Min, Max);

  Chart[ii,jj].LeftAxis.Range.Min := Min;
  Chart[ii,jj].LeftAxis.Range.UseMin := True;
  Chart[ii,jj].LeftAxis.Range.Max := Max;
  Chart[ii,jj].LeftAxis.Range.UseMax := True;

 //Chart[ii,jj].Update;

// Chart[ii,jj].VertAxis.Range.Min := Min;
// Chart[ii,jj].VertAxis.Range.UseMin := True;
// Chart[ii,jj].VertAxis.Range.Max := Max;
// Chart[ii,jj].VertAxis.Range.UseMax := True;
end; //SetAxisMaxMin



procedure TForm1.GetFrequency;
//var ii, jj: Integer;
begin
DebugLn('GetFrequency');

//c.SendString ('SENS1:FREQ:STARt?'#10);
SendStringTerminatedAndCheck('SENS1:FREQ:STARt?', 'send SENS1:FREQ:STARt?', True);
//s := c.RecvTerminated(100, #10); //ok
ReceiveStringTerminatedAndCheck(s, 'receive SENS1:FREQ:STARt?', True);

DebugLn(['FStart string = ', s]);
//FStart := StrToInt64(s);
Params.FStart := StrToFloat(s);
DebugLn(['FStart = ', Params.FStart]);

c.SendString ('SENS1:FREQ:STOP?'#10);
s := c.RecvTerminated(100, #10); //ok
DebugLn(['FEnd string = ', s]);
Params.FStop := StrToFloat(s);
DebugLn(['FEnd = ', Params.FStop]);

FloatSpinEditFStart.Value := Params.FStart;
FloatSpinEditFStop.Value := Params.FStop;

FStep:= (Params.FStop - Params.FStart) / (Params.SweepPoints-1);
DebugLn(['FStep = ', FStep]);
end;  //procedure TForm1.GetFrequency;



procedure TForm1.SetFrequency(const F1, F2: Double);
//var ii, jj: Integer;
//var s: String;
begin
DebugLn('SetFrequency');

//if Fstart changed
if ( (abs(Params.FStart-FStartOld)>1e-1) )
then
begin
//s := 'SENS1:FREQ:STARt ' + IntToStr(FStart) + #10;
s := 'SENS1:FREQ:STARt ' + FloatToStr(F1);
//c.SendString (s);
//DebugLn(['FStart = ', FStart]);
SendStringTerminatedAndCheck(s, 'send SENS1:FREQ:STARt', True);
end;  //if fstart

Sleep(dt);

//if Fstop changed
if ( (abs(Params.FStop-FStopOld) > 1e-1) )
then
begin
s := 'SENS1:FREQ:STOP ' + FloatToStr(F2) + #10;
//c.SendString (s);
SendStringTerminatedAndCheck(s, 'send SENS1:FREQ:STOP', True);
end;  //if fstop

//FStep:= (FStop - FStart) / (nos-1);

//c.SendString ('SENS1:SWEEP:POINTS?'#10);

GetFrequency; //!get actual Fstart/fstop

end;  //procedure TForm1.SetFrequency



procedure TForm1.SetSweepPoints(const NumPoints: Integer);
//var ii, jj: Integer;
//var s: String;
begin
DebugLn('SetSweepPoints');

if (abs(Params.SweepPoints-SweepPointsOld)=0) then Exit;  //no change

s := 'SENSe1:SWEep:POINts ' + IntToStr(NumPoints);
//DebugLn(['FStart = ', FStart]);
SendStringTerminatedAndCheck(s, 'send SENSe1:SWEep:POINts', True);

//s := 'SENSe1:SWEep:POINts?' + IntToStr(NumPoints);
//SendStringTerminatedAndCheck(s, 'receive SENSe1:SWEep:POINts?', True);

GetSweepPoints;  //get actual number of points

//Sleep(dt);
end; //SetSweepPoints



procedure TForm1.GetSweepPoints;
//var ii, jj: Integer;
//var s: String;
begin
DebugLn('GetSweepPoints');

SendStringTerminatedAndCheck('SENSe1:SWEep:POINts?', 'send SENSe1:SWEep:POINts?', True);
ReceiveStringTerminatedAndCheck(s, 'receive SENSe1:SWEep:POINts?', True);
Params.SweepPoints:=StrToInt(s);
SpinEditSweepPoints.Value:=Params.SweepPoints;

FStep:= (Params.FStop - Params.FStart) / (Params.SweepPoints-1);
DebugLn(['FStep = ', FStep]);

Sleep(dt);
end; //GetSweepPoints



procedure TForm1.PlotSetSize;
var ii, jj: Integer;
begin
DebugLn('PlotSetSize');

for jj:=1 to PlotsNumX do
begin
for ii:=1 to PlotsNumY do
begin
Chart[ii, jj].Left:=((jj-1)*PlotSizeX) div 1;
Chart[ii, jj].Top:=((ii-1)*PlotSizeY) div 1;

Chart[ii, jj].Width:=(PlotSizeX-1) div 1;
Chart[ii, jj].Height:=(PlotSizeY-1) div 1;
end;  //for jj
end;  //for ii
end;  //PlotSetSize



procedure TForm1.GetData(const NumPlotX, NumPlotY: integer);
var ii, NumPlot: Integer;
begin
//DebugLn('GetData');

//c.SendString (''#10);  //ok
//c.SendString ('CALC:DATA:FDAT?'#10);  //ok
//sleep(dt);
//s := c.RecvTerminated(100, #10); //ok

//c.SendString ('SENS1:FREQ:STARt?'#10);
SendStringTerminatedAndCheck('CALC:DATA:FDAT?', 'send CALC:DATA:FDAT?', True);
//s := c.RecvTerminated(100, #10); //ok
ReceiveStringTerminatedAndCheck(s, 'receive CALC:DATA:FDAT?', True);

//StringList := TStringList.Create;
StringList.Clear;
StringList.AddCommaText(s);

if (StringList.Count div 2 <> Params.SweepPoints)
then
begin
c.Purge;
DebugLn(['ERROR (GetData) : sl.Count <> 2*SweepPoints : ', StringList.Count div 1, ' <> ', 2*Params.SweepPoints]);
ListBox1.Items.Add('ERROR (GetData) : StringList.Count = ' + IntToStr(StringList.Count));
ShowMessage('ERROR (GetData) : sl.Count div 2 <> SweepPoints, StringList.Count = ' + IntToStr(StringList.Count));
exit;
end;  //if

//ListBox1.Items.Add( IntToStr(StringList.Count));
//ListBox1.Items.Add(StringList.Strings[0]);
//ListBox1.Items.Add(StringList.Strings[1]);
//ListBox1.Items.Add(StringList.Strings[StringList.Count-1]);

//DebugLn(StringList.Strings[0]);
//DebugLn(StringList.Strings[1]);
////DebugLn(StringList.Strings[2]);
////DebugLn(StringList.Strings[3]);
////DebugLn(StringList.Strings[4]);
////DebugLn(StringList.Strings[5]);
//DebugLn(StringList.Strings[StringList.Count-2]);
//DebugLn(StringList.Strings[StringList.Count-1]);
//DebugLn(StringList.Strings[StringList.Count-0]);

NumPlot := GetPlotNum(NumPlotX, NumPlotY);

//for ii:=0 to StringList.Count-1 do
for ii:=0 to Params.SweepPoints-1 do  //get VNA data
begin
  DataRe[NumPlot,  ii] := StrToFloat(StringList.Strings[2*ii]);
  //DebugLn(DataRe[1, ii]);
  DataIm[NumPlot,  ii] := StrToFloat(StringList.Strings[2*ii+1]);
end;  //for

if (CalibrationGetData = true) and (NumPlot = Params.CurrentPlotNum) then  //get calibration data
begin
  for ii:=0 to Params.SweepPoints-1 do
  begin
    CalibrationDataRe[NumPlot,  ii] := DataRe[NumPlot,  ii];
    CalibrationDataIm[NumPlot,  ii] := DataIm[NumPlot,  ii];
  end;  //for
  CalibrationGetData := False;  //calibration done
end; //if


end;  //procedure TForm1.GetData



procedure TForm1.RadioGroupMagPhaseClick(Sender: TObject);
begin
  PlotParams[Params.CurrentPlotNum].SFormat:=RadioGroupMagPhase.ItemIndex;
  DebugLn(['PlotParams[CurrentPlotNum].SFormat = ', PlotParams[Params.CurrentPlotNum].SFormat]);
end; //RadioGroupMagPhaseClick



procedure TForm1.RadioGroupS11S21Click(Sender: TObject);
begin
  PlotParams[Params.CurrentPlotNum].SName:=RadioGroupS11S21.ItemIndex;
end;  //RadioGroupS11S21Click



procedure TForm1.RadioGroupSwitchInNumClick(Sender: TObject);
begin
  SwitchParams[Params.CurrentPlotNum].InputNum := RadioGroupSwitchInNum.ItemIndex + 0;
end;



procedure TForm1.RadioGroupSwitchOutNumClick(Sender: TObject);
begin
  SwitchParams[Params.CurrentPlotNum].OutputNum := RadioGroupSwitchOutNum.ItemIndex + 0;
end;



procedure TForm1.SpinEditCurrentPlotNumChange(Sender: TObject);
begin
DebugLn(['SpinEditCurrentPlotNumChange : ', SpinEditCurrentPlotNum.Value]);

if (SpinEditCurrentPlotNum.Value < 1) then
begin
  SpinEditCurrentPlotNum.Value := 1;
  exit;
end;  //if < 1

if (SpinEditCurrentPlotNum.Value > Params.PlotsNum) then
begin
  Params.CurrentPlotNum := Params.PlotsNum;
  SpinEditCurrentPlotNum.Value := Params.PlotsNum;
  DebugLn(['SpinEditCurrentPlotNumChange FIXED: ', SpinEditCurrentPlotNum.Value]);
end  //if
else Params.CurrentPlotNum := SpinEditCurrentPlotNum.Value;

//set gui cotrols
RadioGroupS11S21.ItemIndex := PlotParams[Params.CurrentPlotNum].SName;
RadioGroupMagPhase.ItemIndex := PlotParams[Params.CurrentPlotNum].SFormat;
CheckBoxCalibrationApply.Checked := Params.CalibrationApply[Params.CurrentPlotNum];

MarkCurrentPlot;
end; //SpinEditCurrentPlotNumChange



//get plot x/y podition in the plot grid
procedure TForm1.GetCurrentPlotIJ;
begin
//DebugLn('GetCurrentPlotIJ');
CurrentPlotNumI := ((Params.CurrentPlotNum-1) div (PlotsNumX+0))+1; //ok
CurrentPlotNumJ := Params.CurrentPlotNum - (CurrentPlotNumI-1)*PlotsNumX; //ok
//DebugLn(['GetCurrentPlotIJ :  N=', CurrentPlotNum, ',  ii=', CurrentPlotNumI, ',  jj=', CurrentPlotNumJ ]);
end; //procedure GetCurrentPlotIJ



//convert chart  ii,jj -> chart num
function TForm1.GetPlotNum(const ii, jj: Integer): Integer; inline;
begin
//DebugLn('function GetPlotNum');
Result := (ii-1)*PlotsNumX+jj;
//DebugLn(['function GetPlotNum : ', Result]);
end; //function GetPlotNum



procedure TForm1.MarkCurrentPlot;
begin
DebugLn(['MarkCurrentPlot N=', Params.CurrentPlotNum]);
//Chart[CurrentPlotNumJ, CurrentPlotNumI].Color:=clWhite;  //reset old selection
PlotsSetColor(clWhite);

//CurrentPlotNum:=SpinEditCurrentPlotNum.Value;
//CurrentPlotNumJ:=(CurrentPlotNum div (PlotsNumX+1))+1;  //x<->y???
//CurrentPlotNumI:=CurrentPlotNum - (CurrentPlotNumJ-1)*PlotsNumX;
GetCurrentPlotIJ;

StatusBar1.SimpleText:=IntToStr(Params.CurrentPlotNum) +'  ' + IntToStr(CurrentPlotNumI)+ '  ' +IntToStr(CurrentPlotNumJ)+'  ';

Chart[CurrentPlotNumI, CurrentPlotNumJ].Color:=clSkyBlue;  //mark new selection
end; //MarkCurrentPlot



procedure TForm1.SpinEditPlotsNumChange(Sender: TObject);
begin
DebugLn(['SpinEditPlotsNumChange : ', SpinEditPlotsNum.Value]);
//if < 1
if (SpinEditPlotsNum.Value > PlotsNumMax) then
begin
  Params.PlotsNum := PlotsNumMax;
  SpinEditPlotsNum.Value := Params.PlotsNum;
  DebugLn(['SpinEditPlotsNum FIXED: ', SpinEditPlotsNum.Value]);
end  //if
else   Params.PlotsNum := SpinEditPlotsNum.Value;
                                                                                                                                                                                                  ;
PlotsSetParams;
end;  //SpinEditPlotsNumChange



procedure TForm1.SpinEditSweepPointsEditingDone(Sender: TObject);
begin
  SweepPointsOld:=Params.SweepPoints;
  Params.SweepPoints:=SpinEditSweepPoints.Value;

  SetSweepPoints(Params.SweepPoints);
end; //SpinEditSweepPointsEditingDone



procedure TForm1.SpinEditYMinS21Change(Sender: TObject);
begin
  Params.PlotExtentYMinS21 := SpinEditYMinS21.Value;
end;



procedure TForm1.TabSheetSwitchEnter(Sender: TObject);
begin
  RadioGroupSwitchInNum.ItemIndex:=SwitchParams[Params.CurrentPlotNum].InputNum - 0;
  RadioGroupSwitchOutNum.ItemIndex:=SwitchParams[Params.CurrentPlotNum].OutputNum - 0;
  LabelSwitchChartNum.Caption := 'N = ' + IntToStr(Params.CurrentPlotNum);
end;



procedure TForm1.PlotData(const NumPlotX, NumPlotY: integer);
var
  ii, NumPlot, MarkerIndex: Integer;
begin
//TimerEnable := False;

NumPlot := GetPlotNum(NumPlotX, NumPlotY);
DebugLn( ['PLOT1 - NumPlot = ', NumPlot]);

ChartLineSeries[NumPlotX, NumPlotY].BeginUpdate;

ChartLineSeries[NumPlotX, NumPlotY].Marks.AutoMargins := False;  //autosize for markers off

ChartLineSeries[NumPlotX, NumPlotY].Clear;

for ii:=0 to (Params.SweepPoints - 1) do
begin
  //DebugLn([2*ii, ' ', DataRe[1, 2*ii]]);
  //ChartLineSeries[1].AddXY(ii, DataRe[1, 2*ii]);  //even indexes
  //ChartLineSeries[NumPlotX, NumPlotY].AddXY(ii*FStep, DataRe[NumPlotX, NumPlotY, 2*ii]);  //even indexes

if Params.CalibrationApply[NumPlot] = False  //no calibration
then
  ChartLineSeries[NumPlotX, NumPlotY].AddXY(Params.FStart+ii*FStep, DataRe[NumPlot, ii])  //even indexes
else  //apply calibration
  ChartLineSeries[NumPlotX, NumPlotY].AddXY(Params.FStart+ii*FStep, DataRe[NumPlot, ii] - CalibrationDataRe[NumPlot, ii]);  //even indexes

end;  //for ii

//ChartLineSeries[NumPlotX, NumPlotY].Source.IsSorted;
ChartLineSeries[NumPlotX, NumPlotY].AxisIndexX:=-1;  //no axis transformations are applied
ChartLineSeries[NumPlotX, NumPlotY].AxisIndexY:=-1;  //no axis transformations are applied

ChartLineSeries[NumPlotX, NumPlotY].EndUpdate;  //ok

//ChartLineSeries[NumPlotX, NumPlotY].Marks.Visible:=True;  //!!!

//ChartLineSeries[NumPlotX, NumPlotY].Source.Item[SweepPoints div 2]^.Text := '' + FloatToStrF( ChartLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2], fffixed, 3, 2 );
//DebugLn( 'v=', [ChartLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2]] );
//DebugLn( 'sv=', FloatToStr(ChartLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2]) );
//DebugLn( 'svf=', FloatToStrF( ChartLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 2], fffixed, 3, 2 ) );

//ChartLineSeries[NumPlotX, NumPlotY].Source.Item[SweepPoints div 4]^.Text := '' + FloatToStrF( ChartLineSeries[NumPlotX, NumPlotY].YValue[SweepPoints div 4], fffixed, 3, 2 );
//DebugLn( 'v=', [ChartLineSeries[1].YValue[SweepPoints div 4]] );
//DebugLn( 'sv=', FloatToStr(ChartLineSeries[1].YValue[SweepPoints div 4]) );
//DebugLn( 'svf=', FloatToStrF( ChartLineSeries[1].YValue[SweepPoints div 4], fffixed, 3, 2 ) );

for ii:=1 to MarkersNumMax do   //show markers
begin
DebugLn([ 'MarkerParams[ii].MarkerChartNum = ', MarkerParams[ii].MarkerChartNum]);
if ( (MarkerParams[ii].MarkerChartNum = NumPlot) and (MarkerParams[ii].MarkerEnabled = True)
      and (MarkerParams[ii].MarkerFrequency > Params.FStart) and (MarkerParams[ii].MarkerFrequency < Params.FStop) )
then
begin
  DebugLn([ 'PLOT2 - NumPlot = ', NumPlot]);
//DebugLn([ 'FStart = ', FStart, ',   FStop = ', FStop]);
//ChartLineSeries[NumPlotX, NumPlotY].Source.Item[Markers[ii,2]]^.Text := IntToStr(NumPlot) + '/' + FloatToStrF( ChartLineSeries[NumPlotX, NumPlotY].YValue[Markers[ii,2]], fffixed, 3, 2 );
//MarkerIndex := trunc(((MarkerParams[ii].MarkerFrequency-Params.FStart)/(Params.FStop-Params.FStart))*(Params.SweepPoints - 1));
MarkerIndex := round( ((MarkerParams[ii].MarkerFrequency-Params.FStart)/(Params.FStop-Params.FStart))*(Params.SweepPoints - 1) );
//DebugLn( ['MarkerIndexF=', ((Markers[ii].MarkerFrequency-FStart)/(FStop-FStart))]);
//DebugLn( ['Marker ii = ', ii]);
//DebugLn( ['MarkerF = ', Markers[ii].MarkerFrequency]);
//DebugLn( ['MarkerIndex = ', MarkerIndex]);

if MarkerIndex > (Params.SweepPoints-1)
then MarkerIndex := Params.SweepPoints-1
else if MarkerIndex < 0 then MarkerIndex:=0;

//ChartLineSeries[NumPlotX, NumPlotY].Source.Item[MarkerIndex]^.Text := IntToStr(ii) + '/' + FloatToStrF( ChartLineSeries[NumPlotX, NumPlotY].YValue[MarkerIndex], fffixed, 3, 2 ); //ok
ChartLineSeries[NumPlotX, NumPlotY].SetText(MarkerIndex, IntToStr(ii) + '/' + FloatToStrF( ChartLineSeries[NumPlotX, NumPlotY].YValue[MarkerIndex], fffixed, 3, 2 ));  //ok

end; //if show markers
end;  //for ii:=1 to MarkersNumMax

//ChartLineSeries[NumPlotX, NumPlotY].EndUpdate;  //?series indexing err

Chart[NumPlotX, NumPlotY].Invalidate;

//TimerEnable := True;
end;  //procedure TForm1.PlotData



procedure TForm1.Timer1Timer(Sender: TObject);
var ii, jj: Integer;
begin
Application.ProcessMessages;

if (TabSheetMain.Visible = False) then Exit; //charts are invisible, no need to update them

//DebugLn(['enter Timer1Timer : TimerEnable = ', TimerEnable]);
//if (not TimerEnable) then Exit; //prevent preliminary re-entering
if (TimerEnable = False) then Exit; //prevent preliminary re-entering

TimerEnable := False;

//Application.ProcessMessages;

//if (abs(Params.SweepPoints-SweepPointsOld)>0) then
begin
SetSweepPoints(Params.SweepPoints);
//GetSweepPoints;  //!get actual number
end; //if

//if Fstart/Fstop changed
//if ( (abs(Params.FStart-FStartOld)>1) or (abs(Params.FStop-FStopOld)>1) )
//if Fstart/Fstop changed
if ( (abs(Params.FStart-FStartOld)>1) or (abs(Params.FStop-FStopOld)>1) ) then
begin
SetFrequency(Params.FStart, Params.FStop);
//GetFrequency; //!get actual F
end;  //if

for ii:=1 to PlotsNumY do
begin
for jj:=1 to PlotsNumX do
begin
//DebugLn('===============');
//DebugLn(['y=',jj,' x=',ii, ' PlotsNumX*(jj-1)+ii = ', PlotsNumY*(jj-1)+ii]);

if (PlotsNumX*(ii-1)+jj+0)>Params.PlotsNum then break;

//if (PlotsNumY*(ii-1)+jj+0)>PlotsNum then
//begin
//DebugLn('bbbbbbbbbbbbbb');
//DebugLn(['y=',jj,' x=',ii, ' PlotsNumX*(jj-1)+ii = ', PlotsNumY*(jj-1)+ii]);
//break;
//end;

Chart[ii, jj].Visible:=True;

if PlotParams[GetPlotNum(ii,jj)].SName=0 //s11
then
begin
  c.SendString ('CALC:PAR:DEF S11'#10);
  sleep(dt);
  ChartLineSeries[ii, jj].LinePen.Color:=clRed
end  //if
else //s21
begin
  c.SendString ('CALC:PAR:DEF S21'#10);
  sleep(dt);
  ChartLineSeries[ii, jj].LinePen.Color:=clBlue
end;  //else

if PlotParams[GetPlotNum(ii,jj)].SFormat=0  //mlog
then
begin
  c.SendString ('CALC:FORM MLOG'#10);
  sleep(dt);

if PlotParams[GetPlotNum(ii,jj)].SName=0 //s11
then
begin
//SetAxisMinMax(ii, jj, -400, 100);  //err
//Chart[ii,jj].LeftAxis.Range.Min := -50;
//Chart[ii,jj].LeftAxis.Range.UseMin := True;
//Chart[ii,jj].LeftAxis.Range.Max := 20;
//Chart[ii,jj].LeftAxis.Range.UseMax := True;
Chart[ii,jj].Extent.YMin := Params.PlotExtentYMinS11;
Chart[ii,jj].Extent.UseYMin := True;
Chart[ii,jj].Extent.YMax := Params.PlotExtentYMaxS11;
Chart[ii,jj].Extent.UseYMax := True;
//Chart[ii,jj].Extent.FixTo([]);
end  //if
else //s21
begin
Chart[ii,jj].Extent.YMin := Params.PlotExtentYMinS21;
Chart[ii,jj].Extent.UseYMin := True;
Chart[ii,jj].Extent.YMax := Params.PlotExtentYMaxS21;
Chart[ii,jj].Extent.UseYMax := True;
end;  //else

end  //if mlog
else  //phase
begin
  c.SendString ('CALC:FORM PHASE'#10);
  sleep(dt);
  Chart[ii,jj].Extent.YMin := -200;
  Chart[ii,jj].Extent.UseYMin := True;
  Chart[ii,jj].Extent.YMax := 200;
  Chart[ii,jj].Extent.UseYMax := True;

  //SetAxisMinMax(ii, jj, -1800, 1800);  //err
  //Chart[ii,jj].LeftAxis.Range.Visible := True;
//  Chart[ii,jj].LeftAxis.Range.Min := -190;
//  Chart[ii,jj].LeftAxis.Range.UseMin := True;
//  Chart[ii,jj].LeftAxis.Range.Max := 190;
//  Chart[ii,jj].LeftAxis.Range.UseMax := True;
  //Chart[ii,jj].LeftAxis.DisplayName.UpperCase('test');
  //Chart[ii,jj].BackColor:=clGreen;

  //Chart[ii,jj].LeftAxis.Transformations := ChartAxisTransformations1;
  //ChartAxisTransformations1AutoScaleAxisTransform1.MinValue:= -180;
  //ChartAxisTransformations1AutoScaleAxisTransform1.MaxValue:= 180;
  //ChartAxisTransformations1AutoScaleAxisTransform1.Enabled:=True;

if PlotParams[GetPlotNum(ii,jj)].SName=0  //s11
then
  ChartLineSeries[ii, jj].LinePen.Color:=clPurple
else  //s21
  ChartLineSeries[ii, jj].LinePen.Color:=clTeal;
  //ChartLineSeries[ii, jj].LinePen.Color:=clAqua;  //too light

end;  //else phase



SendSwitchState(switchSocket, SwitchParams[GetPlotNum(ii,jj)].OutputNum, SwitchParams[GetPlotNum(ii,jj)].InputNum);
//SendPostRequest(IPAddressSwitch, IPPortSwitch, SwitchParams[GetPlotNum(ii,jj)].InputNum, SwitchParams[GetPlotNum(ii,jj)].OutputNum);
DebugLn(['plt ',ii , ' / ', jj, ' / ', GetPlotNum(ii,jj),
                ' sw ', SwitchParams[GetPlotNum(ii,jj)].InputNum, ' / ', SwitchParams[GetPlotNum(ii,jj)].OutputNum]);
Sleep(500);

GetData(ii,jj);
Application.ProcessMessages;

PlotData(ii,jj);
Application.ProcessMessages;

end;  //for jj
end;  //for ii

TimerEnable := True;

end;  //OnTimer

function TForm1.ConnectToServer(const IPAddr, IPPort: string; out Socket: TTCPBlockSocket): Boolean;
begin
  Result := False;
  if (IPAddr = '') or (IPPort = '') then Exit;

  Socket := TTCPBlockSocket.Create;
  Socket.Connect(IPAddr, IPPort);

  if Socket.LastError = 0 then
    Result := True
  else
    FreeAndNil(Socket);
end;

procedure TForm1.DisconnectFromServer(var Socket: TTCPBlockSocket);
begin
  if Assigned(Socket) then
  begin
    Socket.CloseSocket;
    Socket.Free;
    Socket := nil;
  end;
end;

function TForm1.SendSwitchState(Socket: TTCPBlockSocket; const Switch1, Switch2: Integer): Boolean;
var
  PostData, Response: string;
begin
  Result := False;
  if not Assigned(Socket) then Exit;

  PostData := Format('sw1=%d&sw2=%d', [Switch1 + 1, Switch2 + 1]);

  Socket.SendString('POST / HTTP/1.1' + #13#10);
  Socket.SendString('Host: ' + Socket.GetRemoteSinIP + #13#10);
  Socket.SendString('Content-Type: application/x-www-form-urlencoded' + #13#10);
  Socket.SendString('Content-Length: ' + IntToStr(Length(PostData)) + #13#10);
  Socket.SendString(#13#10);
  Socket.SendString(PostData);

  Response := Socket.RecvTerminated(1000, #10);
  if Pos('200 OK', Response) > 0 then
    Result := True;
end;



procedure TForm1.PlotsSetParams;
begin
DebugLn('PlotsSetParams');
//PlotsNum := SpinEditPlotsNum.Value;                                                                                                                                                                                                   ;

//set plot grid size
case Params.PlotsNum of
  1: begin; PlotsNumX := 1; PlotsNumY := 1; end;
  2: begin; PlotsNumX := 2; PlotsNumY := 1; end;
  //3: begin; PlotsNumX := 3; PlotsNumY := 1; end;
  3..4: begin; PlotsNumX := 2; PlotsNumY := 2; end;
  5..6: begin; PlotsNumX := 3; PlotsNumY := 2; end;
  7..8: begin; PlotsNumX := 4; PlotsNumY := 2; end;
  9: begin; PlotsNumX := 3; PlotsNumY := 3; end;
  10..12: begin; PlotsNumX := 4; PlotsNumY := 3; end;
  13..16: begin; PlotsNumX := 4; PlotsNumY := 4; end;
else
  ShowMessage('ERROR: wrong PlotsNum');
  DebugLn('ERROR: wrong PlotsNum');
end;  //case

if (Params.CurrentPlotNum > Params.PlotsNum) then
begin
Params.CurrentPlotNum := Params.PlotsNum;
SpinEditCurrentPlotNum.Value := Params.CurrentPlotNum;
end;  //if
SpinEditCurrentPlotNum.MaxValue := Params.PlotsNum;

PlotsSetVisibility(False);
PlotGetSize(PairSplitterSide2);
PlotSetSize;

//GetCurrentPlotIJ;
MarkCurrentPlot;
end; //PlotsSetParams



procedure TForm1.LoadFile(const FileName: String; const FileSize: Integer; Target: Pointer);
var
    FileTemp: File;
    NumRead: Integer = 0;
    //Target2: array[0..10000000] of byte;

begin
if FileExists(FileName) then
begin

try
  AssignFile(FileTemp, FileName);
  //DebugLn(['LOAD AssignFile  ', FileName, '  - IOResult = ', IOResult]);
  //Reset(FileTemp, FileSize);
  //BlockRead(FileTemp, Target, 1);
  Reset(FileTemp, 1);
  //DebugLn(['LOAD Reset  ', FileName, '  - IOResult = ', IOResult]);
  BlockRead(FileTemp, Target^, FileSize, NumRead);
  DebugLn(['LOAD BlockRead 1 ', FileName, '  -  NumRead = ', NumRead]);
finally
begin
  DebugLn(['LOAD BlockRead 2 ', FileName, '  -  NumRead = ', NumRead]);
  DebugLn(['LOAD ', FileName, '  - IOResult = ', IOResult]);
  CloseFile(FileTemp);
end;  //finally
end;  //try

end  //if
else   DebugLn(['ERROR: LOAD - no file : ', FileName]);

end;  //LoadFile



procedure TForm1.SaveFile(const FileName: String; const FileSize: Integer; Target: Pointer);
var
    FileTemp: File;
    NumWritten: Integer = 0;
begin

try
  AssignFile(FileTemp, FileName);
  //DebugLn(['SAVE AssignFile  ', FileName, '  - IOResult = ', IOResult]);
  Rewrite(FileTemp, 1);
  //DebugLn(['SAVE Reset  ', FileName, '  - IOResult = ', IOResult]);
  Blockwrite(FileTemp, Target^, FileSize, NumWritten);
  DebugLn(['SAVE BlockRead 1 ', FileName, '  -  NumWritten = ', NumWritten]);
finally
begin
  DebugLn(['SAVE BlockRead 2 ', FileName, '  -  NumWritten = ', NumWritten]);
  DebugLn(['SAVE ', FileName, '  - IOResult = ', IOResult]);
  CloseFile(FileTemp);
end;  //finally
end;  //try
//DebugLn(['ERROR: SAVE - no file : ', FileName]);

end;  //SaveFile

//TODO
// обработка нажатия на подменюшку "Сохранить .s2p"
procedure TForm1.SaveS2P(Sender: TObject);
begin
if not Assigned(SaveDialog) then
  SaveDialog := TSaveDialog.Create(Self);

SaveDialog.FileName := Format('Plot_%d.s2p', [Params.CurrentPlotNum]); // дефолтное имя файла

if SaveDialog.Execute then
  SaveDataToS2P(SaveDialog.FileName, 0); // 1 - dB формат, dB в первом столбце, угол во втором
end;


// процедура сохранения
procedure TForm1.SaveDataToS2P(const FileName: string; const SaveFormat:Integer);
var
F: TextFile;
i: Integer;
Header, TimeStamp, CalStatus: string;
begin
AssignFile(F, FileName);
Rewrite(F);
try
  TimeStamp := FormatDateTime('yyyy-mm-dd hh:nn', Now);
  if Params.CalibrationApply[Params.CurrentPlotNum] then
    CalStatus := 'ON'
  else
    CalStatus := 'OFF';

  Writeln(F, '!Calibration ' + CalStatus);
  Writeln(F, '!Measurements: S11 S21 S12 S22');
  Writeln(F, Format('!Switch from port %d to port %d', [SwitchParams[Params.CurrentPlotNum].InputNum + 1, SwitchParams[Params.CurrentPlotNum].OutputNum + 1]));
  Writeln(F, '!' + TimeStamp);
  // Запись заголовка
  case SaveFormat of
    0: Header := '# Hz  S  RI  R 50';  // Real + Imag
    1: Header := '# Hz  S  dB  R 50';  // dB + angle
  end;
  Writeln(F, Header);

  for i := 0 to Params.SweepPoints - 1 do
    Writeln(F, FormatS2PString(Params.CurrentPlotNum, i));

finally
  CloseFile(F);
end;
end;


// создание строки, которая записывается в файл
function TForm1.FormatS2PString(PlotIndex, PointIndex: Integer): string;
var
Frequency, Re, Im, Mag, Phase, dB: Double;
S11_Re, S11_Im, S21_Re, S21_Im, S12_Re, S12_Im, S22_Re, S22_Im: Double;
begin
Frequency := Params.FStart + PointIndex * FStep;

S11_Re := 0; S11_Im := 0;
S21_Re := 0; S21_Im := 0;
S12_Re := 0; S12_Im := 0;
S22_Re := 0; S22_Im := 0;

Re := DataRe[PlotIndex, PointIndex];
Im := DataIm[PlotIndex, PointIndex];

case PlotParams[PlotIndex].SName of
  0: begin S11_Re := Re; S11_Im := Im; end;
  1: begin S21_Re := Re; S21_Im := Im; end;
end;

if PlotParams[PlotIndex].SFormat = 1 then
begin
  Mag := Hypot(Re, Im);
  dB := 20 * Log10(Mag);
  Phase := RadToDeg(ArcTan2(Im, Re));
  Re := dB;
  Im := Phase;
end;

Result := Format('%.6e %.6e %.6e %.6e %.6e %.6e %.6e %.6e %.6e',
  [Frequency, S11_Re, S11_Im, S21_Re, S21_Im, S12_Re, S12_Im, S22_Re, S22_Im]);
end;



procedure TForm1.FormCreate(Sender: TObject);
var ii: Integer;
begin

DefaultFormatSettings.DecimalSeparator:= '.';  //!!!win rus

DebugLn('FormCreate');

StringList := TStringList.Create;  //scpi Data string parser
StringList.Capacity := 65535;

DebugLn('start TChart.Creating');

PlotsCreate;
Params.PlotsNum:=3;

Params.CurrentPlotNum:=1;
SpinEditPlotsNum.Value:=Params.PlotsNum;
SpinEditCurrentPlotNum.Value:=Params.CurrentPlotNum;
SpinEditCurrentPlotNum.MaxValue:=Params.PlotsNum;

Params.PlotExtentYMinS11 := -40;
Params.PlotExtentYMaxS11 := 10;
Params.PlotExtentYMinS21 := -50;
Params.PlotExtentYMaxS21 := 10;

Params.IPAddressPlanar := IPAddressPlanar;
Params.IPPortPlanar := (IPPortPlanar);
Params.IPAddressSwitch := IPAddressSwitch;
Params.IPPortSwitch := (IPPortSwitch);

//set s params
for ii:=1 to PlotsNumMax do
begin
  PlotParams[ii].SName:=0;  //s11=0,s21=1
  RadioGroupS11S21.ItemIndex:=0;

  PlotParams[ii].SFormat:=0;  //mlog=0, phase=1
  RadioGroupMagPhase.ItemIndex:=0;
end;  //ii

EditIPAddressSwitch.Text := IPAddressPlanar;
SpinEditIPPortPlanar.Value := (IPPortPlanar);

EditIPAddressPlanar.Text := IPAddressSwitch;
SpinEditIPPortSwitch.Value := (IPPortSwitch);

////create test markers
//for ii:=1 to MarkersNumMax do
//begin
//  Markers[ii].MarkerChartNum := 2*ii;
//  Markers[ii].MarkerFrequency := 1e9*ii;
//  Markers[ii].MarkerEnabled := True;
//end;  //ii

//Load saved parameters
LoadFile(FileNameParameters, SizeOf(Params), addr(Params));

DebugLn(['SizeOf(CalibrationDataRe) = ', SizeOf(CalibrationDataRe)]);
LoadFile(FileNameCalibration, SizeOf(CalibrationDataRe), @CalibrationDataRe);

LoadFile(FileNameMarkers, SizeOf(MarkerParams), addr(MarkerParams));

LoadFile(FileNameSwitchParameters, SizeOf(SwitchParams), @SwitchParams);

LoadFile(FileNamePlotParameters, SizeOf(PlotParams), addr(PlotParams));

DebugLn(['Params loaded']);
//ShowMessage('loaded?');

//init gui
SpinEditMarkerNumChange(nil);

//update parameters
SpinEditPlotsNum.Value:=Params.PlotsNum;
SpinEditCurrentPlotNum.Value:=Params.CurrentPlotNum;
SpinEditCurrentPlotNum.MaxValue:=Params.PlotsNum;

SpinEditYMinS11.Value  := Params.PlotExtentYMinS11;
SpinEditYMaxS11.Value  := Params.PlotExtentYMaxS11;
SpinEditYMinS21.Value  := Params.PlotExtentYMinS21;
SpinEditYMaxS11.Value  := Params.PlotExtentYMaxS21;

//update IP addr/port
IPAddressPlanar := Params.IPAddressPlanar;
EditIPAddressPlanar.Text := IPAddressPlanar;

IPPortPlanar := (Params.IPPortPlanar);
SpinEditIPPortPlanar.Value := Params.IPPortPlanar;

IPAddressSwitch := Params.IPAddressSwitch;
EditIPAddressSwitch.Text := IPAddressSwitch;

IPPortSwitch := (Params.IPPortSwitch);
SpinEditIPPortSwitch.Value := Params.IPPortSwitch;


GetCurrentPlotIJ;

PlotsSetParams;

SpinEditCurrentPlotNumChange(nil);  //set CheckBoxCalibrationApply.State

ChartsVisible:=True;
DebugLn(['FormCreate - ChartsVisible = ', ChartsVisible]);

end;  //create



procedure TForm1.FloatSpinEditFStartEditingDone(Sender: TObject);
begin
 FStartOld := Params.FStart;
 Params.FStart := FloatSpinEditFStart.Value;

 SetFrequency(Params.FStart, Params.FStop);
end; //FloatSpinEditFStartEditingDone



procedure TForm1.ButtonConnectClick(Sender: TObject);
begin
DebugLn('TTCPBlockSocket.Create');
c := TTCPBlockSocket.Create;
DebugLn('Connecting');
try
//c.Connect ('127.0.0.1', '5025');
c.Connect ( IPAddressPlanar, IntToStr(IPPortPlanar) );
except  //!!!no exception
//  DebugLn('Error: cannot connect');
//  ListBox1.Items.Add('Error: cannot connect');
//  Exit;
end;



  if ConnectToServer(IPAddressSwitch, IntToStr(IPPortSwitch), switchSocket) then
      begin
        ShowMessage('Подключение успешно!');
      end
  else
        ShowMessage('Ошибка при попытке подключения. Проверьте данные.');



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

//c.SendString ('*IDN?'#10);  //ok
//sleep(dt);
//s := c.RecvTerminated(100, #10); //ok
SendStringTerminatedAndCheck('*IDN?', 'send *IDN?', True);
sleep(dt);
ReceiveStringTerminatedAndCheck(s, 'receive *IDN?', True);
DebugLn('*IDN? = ', s);
//DebugLn([err]);
//DebugLn('LastErrorDesc = ', c.LastErrorDesc);

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
FStartOld := Params.FStart;
FStopOld := Params.FStop;

GetSweepPoints;
DebugLn(['SweepPoints = ', Params.SweepPoints]);
SweepPointsOld:=Params.SweepPoints;

TimerEnable:=True;
Timer1.Enabled:=True;

Connected := True;

ButtonConnect.Enabled := False;
DebugLn('DONE ButtonConnectClick');
end;  //ButtonConnectClick



procedure TForm1.CheckBoxCalibrationApplyChange(Sender: TObject);
begin
  Params.CalibrationApply[Params.CurrentPlotNum] := CheckBoxCalibrationApply.Checked;
  //err CalibrationApply[GetPlotNum(PlotsNumX, PlotsNumY)] := CheckBoxCalibrationApply.Checked;
end;



procedure TForm1.ButtonCalibrateClick(Sender: TObject);
begin
  CalibrationGetData := True;
end;



procedure TForm1.EditIPAddressPlanarEditingDone(Sender: TObject);
begin
  if IsIP(EditIPAddressPlanar.Text) = True
  then
  begin
    IPAddressPlanar := EditIPAddressPlanar.Text;
    Params.IPAddressPlanar := IPAddressPlanar;
  end
  else EditIPAddressPlanar.Text := IPAddressPlanar;

   DebugLn('IPAddressPlanar = ', IPAddressPlanar);
end;  //EditIPAddressPlanarEditingDone



procedure TForm1.EditIPAddressSwitchEditingDone(Sender: TObject);
begin
  if IsIP(EditIPAddressSwitch.Text) = True
  then
  begin
    IPAddressSwitch := EditIPAddressSwitch.Text;
    Params.IPAddressSwitch := IPAddressSwitch;
  end
  else EditIPAddressSwitch.Text := IPAddressSwitch;

   DebugLn('IPAddressSwitch = ', IPAddressSwitch);
end;   //EditIPAddressSwitchEditingDone



procedure TForm1.SpinEditIPPortPlanarChange(Sender: TObject);
begin
  IPPortPlanar := (SpinEditIPPortPlanar.Value);
  Params.IPPortPlanar := SpinEditIPPortPlanar.Value;

  DebugLn(['IPPortPlanar = ', IPPortPlanar]);
end;  //SpinEditIPPortPlanarChange



procedure TForm1.SpinEditIPPortSwitchChange(Sender: TObject);
begin
  IPPortSwitch := (SpinEditIPPortSwitch.Value);
  Params.IPPortSwitch := SpinEditIPPortSwitch.Value;

  DebugLn(['IPPortSwitch = ', IPPortSwitch]);
end;  //SpinEditIPPortSwitchChange



procedure TForm1.SpinEditYMaxS11Change(Sender: TObject);
begin
  Params.PlotExtentYMaxS11 := SpinEditYMaxS11.Value;
end;


procedure TForm1.SpinEditYMaxS21Change(Sender: TObject);
begin
  Params.PlotExtentYMaxS21 := SpinEditYMaxS21.Value;
end;



procedure TForm1.SpinEditYMinS11Change(Sender: TObject);
begin
  Params.PlotExtentYMinS11 := SpinEditYMinS11.Value;
end;



procedure TForm1.FloatSpinEditMarkerFrequencyEditingDone(Sender: TObject);
begin
  MarkerParams[MarkerNum].MarkerFrequency := FloatSpinEditMarkerFrequency.Value;
end;



procedure TForm1.SpinEditMarkerChartNumChange(Sender: TObject);
begin
 //MarkerNum := SpinEditMarkerNum.Value;
 MarkerParams[MarkerNum].MarkerChartNum := SpinEditMarkerChartNum.Value;
 DebugLn(['SpinEdit - MarkerParams[MarkerNum].MarkerChartNum = ', MarkerParams[MarkerNum].MarkerChartNum]);
end;



procedure TForm1.SpinEditMarkerNumChange(Sender: TObject);
begin
  MarkerNum := SpinEditMarkerNum.Value;
  SpinEditMarkerChartNum.Value := MarkerParams[MarkerNum].MarkerChartNum;
  FloatSpinEditMarkerFrequency.Value := MarkerParams[MarkerNum].MarkerFrequency;
  CheckBoxMarkerEnabled.Checked := MarkerParams[MarkerNum].MarkerEnabled;
  SpinEditMarkerChartNumChange(nil);  //!
end;



procedure TForm1.CheckBoxMarkerEnabledChange(Sender: TObject);
begin
  MarkerParams[MarkerNum].MarkerEnabled := CheckBoxMarkerEnabled.Checked;
end;


procedure TForm1.FloatSpinEditFStopEditingDone(Sender: TObject);
begin
  FStopOld := Params.FStop;
  Params.FStop := FloatSpinEditFStop.Value;

  SetFrequency(Params.FStart, Params.FStop);
end; //FloatSpinEditFStopEditingDone



procedure TForm1.FormDestroy(Sender: TObject);
//var FileCal: TFileStream;
begin
TimerEnable:=False;
Timer1.Enabled:=False;

//AssignFile(FileTemp, FileNameCalibration);
//Rewrite (FileTemp, SizeOf(CalibrationDataRe));
//BlockWrite(FileTemp, CalibrationDataRe, 1);
//CloseFile(FileTemp);

//if c<>nil then //if connected to Planar
begin

//try
//  AssignFile(FileTemp, FileNameCalibration);
//  Rewrite(FileTemp, SizeOf(CalibrationDataRe));
//  BlockWrite(FileTemp, CalibrationDataRe, 1);
//finally
//begin
//  DebugLn(['SAVE CalibrationDataRe - IOResult = ', IOResult]);
//  CloseFile(FileTemp);
//end;  //finally
//end;  //try

SaveFile(FileNameParameters, SizeOf(Params), addr(Params));

SaveFile(FileNameCalibration, SizeOf(CalibrationDataRe), @CalibrationDataRe);

SaveFile(FileNameMarkers, SizeOf(MarkerParams), addr(MarkerParams));

SaveFile(FileNameSwitchParameters, SizeOf(SwitchParams), @SwitchParams);

SaveFile(FileNamePlotParameters, SizeOf(PlotParams), addr(PlotParams));

//ShowMessage('params saved');

end;  //if

//FileCal.Create('planar8x8.cal', fmOpenWrite);
//FileCal.Create('planar8x8.cal', fmCreate);
//ii := FileCal.Write(CalibrationDataRe, 1);
//FileCal.WriteBuffer(CalibrationDataRe, SizeOf(CalibrationDataRe));
//FileCal.WriteBuffer(CalibrationDataRe, 1);
//FileCal.WriteBuffer(ii, 1);
//FileCal.WriteByte(1);
//FileCal.WriteByte(bb);
//FileCal.Write(ii, 1);
//FileCal.Free;

sleep(100);

if c<>nil then c.CloseSocket;

if switchSocket<>nil then DisconnectFromServer(switchSocket);
end; //destroy



procedure TForm1.MenuItemCopyClick(Sender: TObject);
begin
  Chart[CurrentPlotNumI, CurrentPlotNumJ].CopyToClipboard(TBitmap);
end;



procedure TForm1.MenuItemTestClick(Sender: TObject);
begin
if c=nil then exit;  //not connected

SpinEditCurrentPlotNum.Value :=2;
Application.ProcessMessages;
sleep(2000);

RadioGroupS11S21.ItemIndex :=1;  //s21
Application.ProcessMessages;
sleep(2000);

SpinEditPlotsNum.Value :=7;
Application.ProcessMessages;
sleep(2000);

SpinEditCurrentPlotNum.Value :=7;
Application.ProcessMessages;
sleep(2000);

SpinEditPlotsNum.Value :=3;
Application.ProcessMessages;
sleep(2000);

end;  //test



procedure TForm1.PairSplitter1Resize(Sender: TObject);
begin
TimerEnable:=False;
DebugLn(['PairSplitter1Resize', '']);
  PlotGetSize(PairSplitterSide2);
  PlotSetSize;
TimerEnable:=True;
end;


END. //end unit planar8x8

