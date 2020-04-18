//+------------------------------------------------------------------+
//| HTFADXs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      ""
#property version   "1.07"
#property strict
#property description "Find extreme points according to HTF, retrace amount and #pegs to H/L"

#property indicator_chart_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 3
//+------------------------------------------------------------------+
//| Global variablesADX                                              |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_M15;//enumHTFPeriod
extern int lowHighOffset=20;//pegs to find interest point
extern double retrace=50;//required retrace to find interest point
double ExtState[];
double ExtLongArrow[];
double ExtShortArrow[];
//TimeFrames
int htfIndex=NULL;
string instrument=Symbol();
ENUM_TIMEFRAMES startEnum=NULL;
int wtfIndex=findWTFIndex(Period(),startEnum);
int wtf=Period();
int shift=NULL;
int limit= NULL;
color clrLine=clrNONE;
int font=18;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex))
      Print(__FUNCTION__," has checkedEnumDesied:  ",checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex)," enumHTFPERIOD: ",enumHTFPeriod);
   clrLine=TF_C_Colors[htfIndex]; 
   IndicatorBuffers(3);
   IndicatorShortName("EXT_TOPS_BOTTOMS"+" "+instrument+" "+string(enumHTFPeriod));

   SetIndexStyle(0,DRAW_ARROW,0,2,clrLine);
   SetIndexArrow(0,221);
   SetIndexLabel(0,"EX Long_"+string(enumHTFPeriod));
   SetIndexBuffer(0,ExtLongArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,0,2,clrLine);
   SetIndexArrow(1,222);
   SetIndexLabel(1,"EX Short_"+string(enumHTFPeriod));
   SetIndexBuffer(1,ExtShortArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrLine);
   SetIndexArrow(2,87);
   SetIndexLabel(2,"EXT NONE"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExtState);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//-- Set up conditions for new bar
   static int htfShift=-1;
   static int phtfShift=-1;
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   ArraySetAsSeries(ExtState,true);
   ArraySetAsSeries(ExtLongArrow,true);
   ArraySetAsSeries(ExtShortArrow,true);
   ArraySetAsSeries(time,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,time[shift+1],false);
         if(shift>(rates_total-lowHighOffset-1))
            continue;
         if(htfShift==phtfShift)
            continue;
         double top=iCustom(instrument,enumHTFPeriod,"OHLC_EX",lowHighOffset,retrace,0,phtfShift);
         double bottom=iCustom(instrument,enumHTFPeriod,"OHLC_EX",lowHighOffset,retrace,1,phtfShift);
         //    double state=iCustom(instrument,enumHTFPeriod,"OHLC_EX",lowHighOffset,retrace,bMajor,bInter,bMinor,bExtreme,bPinBar,2,phtfShift);      
         if(top!=EMPTY_VALUE)
            ExtShortArrow[shift+1]=top;
         if(bottom!=EMPTY_VALUE)
            ExtLongArrow[shift+1]=bottom;
        }//for
     }//new bar
   ChartRedraw(ChartID());
   Sleep(200);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| setString                                          |
//+------------------------------------------------------------------+
//void setString(string sym,int Shift,string name,double val,string text,int FontSize, datetime timePosition,color clr)
//  {
//   string         FontType="mono";
//   color          FontColorIndex=clr;
//   string showName=name+string(timePosition)+" "+string(Shift)+" "+string(val)+" "+sym;
//   if(!ObjectCreate(ChartID(),showName,OBJ_TEXT,0,timePosition,val))
//     {
//      Print(__FUNCTION__,": failed to create a : "+showName+" ! Error: ",ErrorDescription(GetLastError())+" x pos: "+string(timePosition)+" y pos: "+string(val));
//     }
//   ObjectSetText(showName,text,FontSize,FontType,FontColorIndex);
//  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//string textName1="EB";
//string textName2="ET";  
// for(int i=ObjectsTotal() -1; i>=0; i--)
//   {
//    string objName=ObjectName(i);
//    if( (StringSubstr(objName,0,2)==textName1) || (StringSubstr(objName,0,2)==textName2) )
//    ObjectDelete(ObjectName(i));
//   }
  }
//+------------------------------------------------------------------+
