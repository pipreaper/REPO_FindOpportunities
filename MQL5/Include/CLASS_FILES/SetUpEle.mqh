////+------------------------------------------------------------------+
////|                                                     SetUpEle.mqh |
////|                                    Copyright 2019, Robert Baptie |
////|                                             https://www.mql5.com |
////+------------------------------------------------------------------+
//#property copyright "Copyright 2019, Robert Baptie"
//#property link      "https://www.mql5.com"
//#property version   "1.00"
//#include <Arrays\List.mqh>
//#include    <\\INCLUDE_FILES\\WaveLibrary.mqh>
//#include    <\\INCLUDE_FILES\\drawing.mqh>
//class SetUpEle : public CObject
//  {
//private:
//
//public:
//   color             clrDiaLine;
//   int               countN;
//   trendState        prevTipState;
//   // store price values
//   double            YVals[2];
//   // store time values
//   datetime          XTimes[2];
//   string            diaTrendLineName;
//public:
//   void              SetUpEle::SetUpEle(color _clr, string _diaTrendLineName);
//   void              SetUpEle::drawDiaLine();
//   trendState        SetUpEle::getPrevTipState();
//   void              SetUpEle::moveDiagLine(double _p1,double _p2,datetime _t1,datetime _t2);
//   void              SetUpEle::setPrevTipState(trendState _updateCurrTrend);
//   void              SetUpEle::updateTrendPriceTime(datetime _d);
//   void              SetUpEle::~SetUpEle();                     
//  };
////+------------------------------------------------------------------+
////|  Constructor                                                     |
////+------------------------------------------------------------------+
//void SetUpEle::SetUpEle(color _clr, string _diaTrendLineName)
//  {
//   countN=0;
//   clrDiaLine = _clr;
//   YVals[0]=0;
//   YVals[1]=0;
//   XTimes[0]=0;
//   XTimes[1]=0;
//   diaTrendLineName = _diaTrendLineName;
//   setTipState(initialTipState);
//   this.drawDiaLine();
//  }
//// +------------------------------------------------------------------+
//// | setTipState                                                      |
//// +------------------------------------------------------------------+
//void              SetUpEle::setPrevTipState(trendState _updateCurrTrend)
//  {
//   prevTipState = _updateCurrTrend;
//  }
//// +------------------------------------------------------------------+
//// | getPrevTipState                                                  |
//// +------------------------------------------------------------------+
//trendState        SetUpEle::getPrevTipState()
//  {
//   return prevTipState;
//  }
////+------------------------------------------------------------------+
////|  SetNewTrendLineData                                             |
////+------------------------------------------------------------------+
//void SetUpEle::moveDiagLine(double _p1,double _p2,datetime _t1,datetime _t2)
//  {
//   YVals[0]=_p1;
//   YVals[1]=_p2;
//   XTimes[0]=_t1;
//   XTimes[1]=_t2;
////new line to chart
////if(_p1 <6200)
////DebugBreak();
//   TrendPointChange(ChartID(),diaTrendLineName,0,_t1,_p1);
//   TrendPointChange(ChartID(),diaTrendLineName,1,_t2,_p2);
//  }
////+------------------------------------------------------------------+
////|  Destructor                                                      |
////+------------------------------------------------------------------+
//void SetUpEle::~SetUpEle() {}
////+------------------------------------------------------------------+
////|//Draw a diagonal trend Line                                      |
////+------------------------------------------------------------------+
//void SetUpEle::drawDiaLine()
//  {
//   ENUM_LINE_STYLE style=STYLE_DASHDOT;  // line style
//   int             width=3;            // line width
//   bool            back=true;          // in the background
//   bool            selection=false;    // highlight to move
//   bool            ray_right=true;     // line's continuation to the right
//   bool            hidden=true;        // hidden in the object list
//   long            z_order=0;          // priority for mouse click
//   if(!TrendCreate(0,diaTrendLineName,0,NULL,NULL,NULL,NULL,clrDiaLine,style,width,back,selection,ray_right,hidden,z_order))
//      DebugBreak();
//   ChartRedraw();
//// Sleep(1000);
//  }
////+------------------------------------------------------------------+
////|  SetUpEle:extendline to next active candle                        |
////+------------------------------------------------------------------+
//void SetUpEle::updateTrendPriceTime(datetime _d)
//  {
//   XTimes[1]=_d;
//   YVals[1] = ObjectGetValueByTime(0, diaTrendLineName, XTimes[1],0);
//// Only do point change if has initialised - time consumming in init stage
//// TrendPointChange(0,diaTrendLineName,1,_d,YVals[1]);
////update 2nd data point
//  }
//// +------------------------------------------------------------------+
//// | reduceNumTipElements:reduct the size of the held                 |
//// | tipe elements - not required for calculations                    |
//// +------------------------------------------------------------------+
////void             ContainerDiagonalTip:: reduceNumDLElements(int totDLElements, int acceptibleNumDL = 1)
////  {
////   if(totDLElements >= acceptibleNumDL)
////     {
////      //Delete least significant TipElement from Tip
////      SetUpEle *dle = GetFirstNode();
////      //Check its not in use at the back of the Tip trend queue before removing
////      if(CheckPointer(dle)!=POINTER_INVALID)
////        {
////         dle = this.DetachCurrent();
////         // delete the graphical aspect of the line
////         ObjectDelete(ChartID(),dle.diaTrendLineName);
////         delete(dle);
////        }
////      else
////         Print(__FUNCTION__," POINTER_INVALID");
////     }
////  }
////+------------------------------------------------------------------+
