//+------------------------------------------------------------------+
//|                                                      ATR_MTF.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "2020, RObrt Baptie"
#property description "ATR, Multi-timeframe"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- indicator plots
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_width1  1
#property indicator_label1  "ATR"
//--- input parameters
input ENUM_TIMEFRAMES      waveHTFPeriod     =  PERIOD_H1;      // Timeframe 2 (TF2) period
input int                  periodATR         =  14;               // ATR period
input ENUM_LINE_STYLE      lineStyle         =  STYLE_DOT;//Line Style
input ENUM_CAT_ID          catalystID        =  TRD;// TRD or VOL
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int               ExtATRHandleHTF; // ATR handle TF2
double            ExtATR[];
bool              showErrorMessages =  false;
int               htfIndex          =  findIndexPeriod(waveHTFPeriod);
int               wtfIndex          =  NULL;
string            instrument        =  _Symbol;
int               shift             =  NULL;
int               limit             =  NULL;
static datetime   time0             =  NULL;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtATR,INDICATOR_DATA);
//--- set color for tf
   PlotIndexSetInteger(0, PLOT_LINE_COLOR,    findColor(findIndexPeriod(waveHTFPeriod)));
   PlotIndexSetString(0,PLOT_LABEL,"ATR("+EnumToString(catalystID)+":"+string(periodATR)+":"+EnumToString(waveHTFPeriod)+")");
//--- Set the line drawing
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE, lineStyle);
//  PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(ExtATR,true);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
////--- set levels
//   IndicatorSetInteger(INDICATOR_LEVELS,2);
//   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,-100);
//   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,100);
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR("+EnumToString(catalystID)+":"+string(periodATR)+":"+EnumToString(waveHTFPeriod)+")");
//--- get ATR handle
   ExtATRHandleHTF=iATR(NULL,waveHTFPeriod,periodATR);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   if(Bars(NULL,waveHTFPeriod)<periodATR)
      return(0);
//--- not all data may be calculated
   if(BarsCalculated(ExtATRHandleHTF)<Bars(NULL,waveHTFPeriod))
     {
      if(showErrorMessages)
         Print("SYCHRONIZED : ",EnumToString(waveHTFPeriod)," ",SeriesInfoInteger(Symbol(),waveHTFPeriod,SERIES_SYNCHRONIZED),"SYCHRONIZED : ",EnumToString(_Period)," ",SeriesInfoInteger(Symbol(),_Period,SERIES_SYNCHRONIZED)," Not all data of HTF calculated calculatedTF2: ",BarsCalculated(ExtATRHandleHTF), " barsTF2: ",Bars(NULL,waveHTFPeriod));
      return(0);
     }
   ArraySetAsSeries(Time,true);
   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
// new bar of CTF
   datetime tda[];
   ArraySetAsSeries(Time,true);
   bool isNewBar=(time0!=Time[0]);
   if(isNewBar)
     {
      time0=Time[0];
        {
         for(shift=limit; shift>=0; shift--)//start rates_total down to zero
           {
            if(shift<(rates_total-periodATR-1))
              {
               if(iBarShift(instrument,waveHTFPeriod,Time[shift],false)!=iBarShift(instrument,waveHTFPeriod,Time[shift+1],false))
                 {
                  double tempATRArray[];
                  if(CopyBuffer(ExtATRHandleHTF,0,iBarShift(instrument,waveHTFPeriod,Time[shift],false),1,tempATRArray)>0)
                     ExtATR[shift]=tempATRArray[0];
                  continue;
                 }
               else
                  ExtATR[shift]=ExtATR[shift+1];
              }
           }
        }
     }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
