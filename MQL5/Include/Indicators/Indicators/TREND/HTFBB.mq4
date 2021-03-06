//+------------------------------------------------------------------+
//| HTFADXs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 1
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_M15;
extern bool drawLines=false;
extern double lowerPercentile=4;//low percent
extern double lowerMiddlePercentile=14;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=80;//upper Middle Percentile
extern double upperPercentile=95;//upper percentile
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=3.0; // Bands Deviations  
extern int maxBarsDraw=50000;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtStatus[];//BB STATUS GAP
int htfIndex=NULL;
string instrument=Symbol();
ENUM_TIMEFRAMES startEnum=NULL;
int wtfIndex=findWTFIndex(enumHTFPeriod,startEnum);
int wtf=Period();
int shift=NULL;
int limit= NULL;
color clrLine=clrNONE;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex);
   //   Print(__FUNCTION__," has checkedEnumDesied:  ",checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex)," enumHTFPERIOD: ",enumHTFPeriod);
   clrLine=TF_C_Colors[htfIndex];   
   IndicatorBuffers(4);
   IndicatorShortName("HTF2MA"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   IndicatorBuffers(1);
   IndicatorShortName("HTF BB"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_ARROW,0,5,clrCornflowerBlue);
   SetIndexArrow(0,39);
   SetIndexLabel(0,"BB STATUS");
   SetIndexBuffer(0,ExtStatus);
   SetIndexEmptyValue(0,EMPTY_VALUE);


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

   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ExtStatus,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-4; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,time[shift+1],false);
         if((htfShift==phtfShift) && (shift<(rates_total-2)))
            continue;
         if(shift>(rates_total-2))
            continue;

         //double SBTrend=iCustom(instrument,enumHTFPeriod,"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,phtfShift);
         double status=iCustom(instrument,enumHTFPeriod,"getLevel BB",drawLines,lowerPercentile,lowerMiddlePercentile,middlePercentile,upperMiddlePercentile,upperPercentile,Boll_Period,Boll_Shift,Boll_Deviations,2,phtfShift);//rates_total-(shift+1));
         if(status!=EMPTY_VALUE)
            ExtStatus[shift+1]=low[shift+1];//+((high[shift+1]-low[shift+1])/2);

        }//for
      ChartRedraw(ChartID());
      Sleep(200);
     }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      //    string nm=ObjectName(i);
      //    Print("Deinit ",nm);
      ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+
