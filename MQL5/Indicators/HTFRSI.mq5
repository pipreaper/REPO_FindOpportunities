//+------------------------------------------------------------------+
//|                                                      RSI_MTF.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "2020, RObrt Baptie"
#property description "RSI, Multi-timeframe"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- indicator plots
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_width1  1
#property indicator_label1  "RSI"
//--- input parameters
input ENUM_TIMEFRAMES      waveHTFPeriod=PERIOD_H1;      // Timeframe 2 (TF2) period
input int                  periodRSI=14;               // RSI period
input ENUM_APPLIED_PRICE   appliedPrice=PRICE_CLOSE;   // Applied price
input string               catalystID =  "None";
bool                       showErrorMessages = false;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int                        ExtRSIHandleHTF;        // RSI handle TF2
//--- indicator buffers
double                     ExtRSIBufferHTF[];
int htfIndex=findIndexPeriod(waveHTFPeriod);
int wtfIndex= NULL;
double ExtRSI[];
string instrument=Symbol();
int shift=NULL;
int limit= NULL;
static datetime         time0             =  NULL;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRSI,INDICATOR_DATA);
//--- set color for tf
   PlotIndexSetInteger(0, PLOT_LINE_COLOR,    findColor(findIndexPeriod(waveHTFPeriod)));
   PlotIndexSetString(0,PLOT_LABEL,"RSI("+catalystID+":"+string(periodRSI)+":"+EnumToString(waveHTFPeriod)+")");
//--- Set the line drawing
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(ExtRSI,true);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,70);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-70);
//--- calculate at which bar to start drawing indicators
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI("+catalystID+":"+string(periodRSI)+":"+EnumToString(waveHTFPeriod)+")");
//--- get RSI handle
   ExtRSIHandleHTF=iRSI(NULL,waveHTFPeriod,periodRSI,appliedPrice);
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
//-- Set up conditions for new bar

//--- check for data
   int barsTF2=Bars(NULL,waveHTFPeriod);
   if(barsTF2<periodRSI)
      return(0);
//--- not all data may be calculated
   int calculatedTF2;

   calculatedTF2=BarsCalculated(ExtRSIHandleHTF);
   if(calculatedTF2<barsTF2)
     {
      if(showErrorMessages)
         Print("Not all data of ExtRsiHandle_TF2 has been calculated (",calculatedTF2," bars). Error",GetLastError());
      return(0);
     }

   static int htfShift=-1;
   static int phtfShift=-1;
// new bar of CTF?
 //  datetime tda[];
   ArraySetAsSeries(Time,true);
 //  bool isNewBar=(time0!=Time[0]);
 //  time0=Time[0];

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
 //  if(isNewBar)// ***** the chart tf the indicator is applied to
  //   {
      for(shift=limit; shift>=0; shift--)//start rates_total down to zero
        {
         if(shift<(rates_total-periodRSI-1))
           {
            htfShift=iBarShift(instrument,waveHTFPeriod,Time[shift],false);
            phtfShift=iBarShift(instrument,waveHTFPeriod,Time[shift+1],false);

            if(htfShift!=phtfShift)
              {
               double tempRSIArray[];
               if(CopyBuffer(ExtRSIHandleHTF,0,htfShift,1,tempRSIArray)<=0)
                  Print(__FUNCTION__," failed to get RSI buffer");
               else
                  ExtRSI[shift]=tempRSIArray[0];
               continue;
              }
            else
               ExtRSI[shift]=ExtRSI[shift+1];
           }
        }
 //    }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
