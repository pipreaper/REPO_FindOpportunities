//+------------------------------------------------------------------+
//|                                                      Ema_MTF.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "2020, RObrt Baptie"
#property description "Ema, Multi-timeframe"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- indicator plots
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_width1  1
#property indicator_label1  "Ema_TF2"
//--- input parameters
input ENUM_TIMEFRAMES      inpHTF=PERIOD_H4;      // Timeframe 2 (TF2) period
input int                  InpPeriodEma=14;               // Ema period
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;   // Applied price
input ENUM_MA_METHOD       InpMethod=  MODE_EMA;//method
input string               catalystID =  "None";
//--- turn on/off error messages
input bool                 ShowErrorMessages=false;  // turn on/off error messages for debugging
//--- indicator buffers
double                     ExtEmaBufferHTF[];
//--- arrays TF2 - to retrieve TF 2 values of buffers and/or timeseries
double                     ExtEmaArrayHTF[];       // intermediate array to hold TF2 Ema buffer values
//--- variables
int                        PeriodRatio=1;           // ratio between timeframe 1 (TF1) and timeframe 2 (TF2)
int                        PeriodSecondsTF;       // TF1 period in seconds
int                        PeriodSecondsHTF;       // TF2 period in seconds
//--- indicator handles TF2
int                        ExtEmaHandleHTF;        // Ema handle TF2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   PeriodSecondsTF=PeriodSeconds();
   PeriodSecondsHTF=PeriodSeconds(inpHTF);  
   if(PeriodSecondsTF>PeriodSecondsHTF)
     {
      Print(__FUNCTION__, " Failed because chart TF, ",_Period, "is greater than desired HTF: ",inpHTF);
      return(INIT_FAILED);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtEmaBufferHTF,INDICATOR_DATA);
  
//--- set color for tf  
   PlotIndexSetInteger(0, PLOT_LINE_COLOR,    findColor(findIndexPeriod(inpHTF)));
   PlotIndexSetString(0,PLOT_LABEL,"EMA("+catalystID+":"+string(InpPeriodEma)+":"+EnumToString(inpHTF)+")");
//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(ExtEmaBufferHTF,true);
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(ExtEmaArrayHTF,true);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,30);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,70);
//--- set maximum and minimum for subwindow
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
//--- calculate at which bar to start drawing indicators
   if(PeriodSecondsTF<PeriodSecondsHTF)
      PeriodRatio=PeriodSecondsHTF/PeriodSecondsTF;
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA("+catalystID+":"+string(InpPeriodEma)+":"+EnumToString(inpHTF)+")");
//--- get Ema handle
   ExtEmaHandleHTF=iMA(NULL,inpHTF,InpPeriodEma,0,InpMethod, InpAppliedPrice);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Ema                                                              |
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
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(Time,true);
//--- check for data
   int bars_TF2=Bars(NULL,inpHTF);
   if(bars_TF2<InpPeriodEma)
      return(0);
//--- not all data may be calculated
   int calculatedHTF;

   calculatedHTF=BarsCalculated(ExtEmaHandleHTF);
   if(calculatedHTF<bars_TF2)
     {
      if(ShowErrorMessages)
         Print(__FUNCTION__," Not all data of ExtEmaHandleHTF has been calculated (",calculatedHTF," bars). Error",GetLastError());
      return(0);
     }
//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      limit=rates_total-1;
   else
      limit=rates_total-prev_calculated;
//--- create variable required to convert between TF1 and TF2
   datetime convertedTime=NULL;
//--- loop through TF1 bars to set buffer TF1 values
   for(int i=limit; i>=0; i--)
     {
      //--- convert time TF1 to nearest earlier time TF2 for a bar opened on TF2 which is to close during the current TF1 bar
      //--- use this for calculations with PRICE_CLOSE, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      if(InpAppliedPrice!=PRICE_OPEN)
         convertedTime=Time[i]+PeriodSecondsTF-PeriodSecondsHTF;
      //--- convert time TF1 to nearest earlier time TF2 for a bar opened on TF2 at the same time or before the current TF1 bar
      //--- use this for calculations with PRICE_OPEN
      if(InpAppliedPrice==PRICE_OPEN)
         convertedTime=Time[i];
      //--- check if TF2 data is available at convertedTime
      datetime tempTimeArray_TF2[];
      CopyTime(NULL,inpHTF,calculatedHTF-1,1,tempTimeArray_TF2);
      //--- no TF2 data available
      if(convertedTime<tempTimeArray_TF2[0])
        {
         ExtEmaBufferHTF[i]=EMPTY_VALUE;
         continue;
        }
      //--- get Ema buffer values of TF2
      if(CopyBuffer(ExtEmaHandleHTF,0,convertedTime,1,ExtEmaArrayHTF)<=0)
        {
         if(ShowErrorMessages)
            Print("Getting Ema TF2 failed! Error",GetLastError());
         return(0);
        }
      //--- set Ema TF2 buffer on TF1
      else
         ExtEmaBufferHTF[i]=ExtEmaArrayHTF[0];
     }
//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+