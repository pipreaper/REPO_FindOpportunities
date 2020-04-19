//+------------------------------------------------------------------+
//|                                                           dd.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include    <\\CLASS_FILES\\ContainerTip.mqh>
#include    <\\CLASS_FILES\\Tip.mqh>
//#include    <\\CLASS_FILES\\TipElement.mqh>
// +------------------------------------------------------------------+
// |DiagTip                                                           |
// +------------------------------------------------------------------+
class DiagTip : public Tip
  {
public:
   color             clrDiaLine;
   //  Tip               *tipHTF;
   int               countN;
   trendState        prevTipState;

   // color             clr;
   string            diaTrendLineName;
public:
   void              DiagTip::DiagTip(color _clr, string _diaTrendLineName);
   bool              DiagTip::cleanDiagLine();
   void              DiagTip::drawDiaLine();
   trendState        DiagTip::getPrevTipState();
   void              DiagTip::moveDiagLine(double _p1,double _p2,datetime _t1,datetime _t2);
   void              DiagTip::setPrevTipState(trendState _updateCurrTrend);
   void              DiagTip::updateTrendPriceTime(datetime _d);
   void              DiagTip::~DiagTip();
  };

//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
void DiagTip::DiagTip(color _clr, string _diaTrendLineName)
  {
   countN=0;
   clrDiaLine = _clr;
   YVals[0]=0;
   YVals[1]=0;
   XTimes[0]=0;
   XTimes[1]=0;
   diaTrendLineName = _diaTrendLineName;
   setPrevTipState(initialTipState);
   this.drawDiaLine();
  }
// +------------------------------------------------------------------+
// | setPrevTipState                                                  |
// +------------------------------------------------------------------+
void              DiagTip::setPrevTipState(trendState _updateCurrTrend)
  {
// Print(__FUNCTION__," time:  ",TimeCurrent()," prevstate: ",EnumToString(_updateCurrTrend));
   prevTipState = _updateCurrTrend;
  }
// +------------------------------------------------------------------+
// | getPrevTipState                                                  |
// +------------------------------------------------------------------+
trendState        DiagTip::getPrevTipState()
  {
   return prevTipState;
  }
//+------------------------------------------------------------------+
//|  SetNewTrendLineData                                             |
//+------------------------------------------------------------------+
void DiagTip::moveDiagLine(double _p1,double _p2,datetime _t1,datetime _t2)
  {
   YVals[0]=_p1;
   YVals[1]=_p2;
   XTimes[0]=_t1;
   XTimes[1]=_t2;
   TrendPointChange(ChartID(),diaTrendLineName,0,_t1,_p1);
   TrendPointChange(ChartID(),diaTrendLineName,1,_t2,_p2);
  }
//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
void DiagTip::~DiagTip() {}
//+------------------------------------------------------------------+
//|//Draw a diagonal trend Line                                      |
//+------------------------------------------------------------------+
void DiagTip::drawDiaLine()
  {
   ENUM_LINE_STYLE style=STYLE_DASHDOT;  // line style
   int             width=6;            // line width
   bool            back=true;          // in the background
   bool            selection=false;    // highlight to move
   bool            ray_right=true;     // line's continuation to the right
   bool            hidden=true;        // hidden in the object list
   long            z_order=0;          // priority for mouse click
   if(!TrendCreate(0,diaTrendLineName,0,NULL,NULL,NULL,NULL,clrDiaLine,style,width,back,selection,ray_right,hidden,z_order))
      DebugBreak();
   ChartRedraw();
// Sleep(1000);
  }
//+------------------------------------------------------------------+
//|  DiagTip:extendline values to next active candle                 |
//+------------------------------------------------------------------+
void DiagTip::updateTrendPriceTime(datetime _d)
  {
   XTimes[1]=_d;
   YVals[1] = ObjectGetValueByTime(ChartID(), diaTrendLineName, XTimes[1],0);
// Only do point change if has initialised - time consumming in init stage
//   TrendPointChange(ChartID(),diaTrendLineName,1,XTimes[1],YVals[1]);
// TrendPointChange(0,diaTrendLineName,1,_d,YVals[1]);
//  ChartRedraw();
//update 2nd data point
  }
//+------------------------------------------------------------------+
//| delete diagonal lines                                            |
//+------------------------------------------------------------------+
bool DiagTip::cleanDiagLine()
  {
   ResetLastError();
// --- create a trend line by the given coordinates
//   for(int line = 0; line<this.Total(); line++)
//   {
//  SetUpEle *sue = this.GetNodeAtIndex(line);
   if(!(ObjectDelete(ChartID(),diaTrendLineName)))
     {
      //No trend line to delete
      //Print(_dl.diaTrendLineName);
      // Print(__FUNCTION__,": failed to delete a trend line! Error code = ",GetLastError()," Description: ",ErrorDescription(GetLastError()));
      return(false);
     }
//   }
   return true;
  }
// +------------------------------------------------------------------+
// | reduceNumTipElements:reduct the size of the held                 |
// | tipe elements - not required for calculations                    |
// +------------------------------------------------------------------+
//void             ContainerDiagonalTip:: reduceNumDLElements(int totDLElements, int acceptibleNumDL = 1)
//  {
//   if(totDLElements >= acceptibleNumDL)
//     {
//      //Delete least significant TipElement from Tip
//      DiagTip *dle = GetFirstNode();
//      //Check its not in use at the back of the Tip trend queue before removing
//      if(CheckPointer(dle)!=POINTER_INVALID)
//        {
//         dle = this.DetachCurrent();
//         // delete the graphical aspect of the line
//         ObjectDelete(ChartID(),dle.diaTrendLineName);
//         delete(dle);
//        }
//      else
//         Print(__FUNCTION__," POINTER_INVALID");
//     }
//  }
//+------------------------------------------------------------------+
