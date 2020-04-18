//+------------------------------------------------------------------+
//| VOLHTFs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.02"
#property description" Find CANDLE VOLUME on HTF"
//--- set the maximum and minimum values for the indicator window
//#property indicator_minimum 0
//#property indicator_maximum 100
#property strict
#property indicator_separate_window
#include <INCLUDE_FILES\\WaveLibrary.mqh>
//#include <status.mqh>
#property  indicator_buffers 1
//+------------------------------------------------------------------+
//| Global variables VOL                                             |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H4;
extern bool drawLines=true;
extern double lowerPercentile=5;//low percent
extern double lowerMiddlePercentile=10;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=90;//upper Middle Percentile
extern double upperPercentile=95;//upper percentile
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
string    shortName="HTF_PERCENTILE_VOL"+" "+Symbol()+" "+string(enumHTFPeriod);
double ExtVolume[];
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
   if(!checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex))
      Print(__FUNCTION__," has checkedEnumDesied:  ",checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex)," enumHTFPERIOD: ",enumHTFPeriod);
   IndicatorBuffers(1);
   IndicatorShortName(shortName);
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_HISTOGRAM,0,4,clrLine);
   string VOLLabel="HTF_VOL_"+string(enumHTFPeriod);
   SetIndexLabel(0,VOLLabel);
   SetIndexBuffer(0,ExtVolume);
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

   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ExtVolume,true);
   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   for(shift=limit; shift>=0; shift--)//start rates_total down to zero
     {
      if(shift>(rates_total-2))
         continue;
      htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
      phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);
      //   Print(ChartID());
      if(isNewBar)// ***** the chart tf the indicator is applied to
        {
         //Print("in IT",shortName);
         double tfVOL0=iCustom(instrument,enumHTFPeriod,"\\VOLUME\\AUXILLARY\\AUX_PERCENTILE_VOLUME",shortName,drawLines,lowerPercentile,lowerMiddlePercentile,middlePercentile,upperMiddlePercentile,upperPercentile,0,phtfShift);

         if(htfShift==phtfShift)
           {
            ExtVolume[shift+1]=EMPTY_VALUE;
            continue;
           }
         ExtVolume[shift+1]=tfVOL0;
        }//new bar          
     }//for
   if(limit<=0)
     {
      double tfVOL0=iCustom(instrument,enumHTFPeriod,"\\VOLUME\\AUXILLARY\\AUX_PERCENTILE_VOLUME",false,lowerPercentile,lowerMiddlePercentile,middlePercentile,upperMiddlePercentile,upperPercentile,0,0);
      ExtVolume[shift+1]=tfVOL0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
