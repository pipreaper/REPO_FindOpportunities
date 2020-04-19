//+------------------------------------------------------------------+
//|                                                 Copyright © 2020 |
//+------------------------------------------------------------------+
#property description "ATR, Multi-timeframe"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
//#include <CLASS_FILES\CAtr.mqh>
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
input ENUM_TIMEFRAMES      waveHTFPeriod  =  PERIOD_M5;      // Timeframe 2 (TF2) period
input int                  inpAtrPeriod   =  14; // ATR period
input ENUM_LINE_STYLE      lineStyle      =   STYLE_DOT;//Line Style
input ENUM_CAT_ID          catalystID =  TRD;// TRD or VOL
double valATR[];
double tempATRArray[1];
int atrHandle;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   ResetLastError();
// ArraySetAsSeries(tempATRArray,true);
//  ArrayInitialize(valATR, EMPTY_VALUE);
// if(!iAtr.Create(_Symbol,waveHTFPeriod,inpAtrPeriod))
//     Print(__FUNCTION__,"iAtr create error: ",ErrorDescription(GetLastError()));
// map index buffers
   SetIndexBuffer(0,valATR,INDICATOR_DATA);
//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(valATR,true);
//--- set color for tf
   PlotIndexSetInteger(0, PLOT_LINE_COLOR,    findColor(findIndexPeriod(waveHTFPeriod)));
   PlotIndexSetString(0,PLOT_LABEL,"ATR("+EnumToString(catalystID)+":"+string(inpAtrPeriod)+":"+EnumToString(waveHTFPeriod)+")");
//--- Set the line drawing
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE, STYLE_SOLID);
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR("+EnumToString(catalystID)+":"+string(inpAtrPeriod)+":"+EnumToString(waveHTFPeriod)+")");
   if((atrHandle=iATR(_Symbol,waveHTFPeriod,inpAtrPeriod))==INVALID_HANDLE)
      return(INIT_FAILED);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int begin, shift;
   if(prev_calculated>rates_total || prev_calculated<=0)
      begin = rates_total-waveHTFPeriod-1;
   else
      begin = prev_calculated-1;
//---
   shift=iBarShift(_Symbol,waveHTFPeriod,time[0]);
//---
   ArraySetAsSeries(time,true);
   if(BarsCalculated(atrHandle)<shift)
      return(0);
//---
   for(int i=begin; i>0 && !_StopFlag; i--)
     {
      shift=iBarShift(_Symbol,waveHTFPeriod,time[i]);
      if(shift <=0)
      continue;
      if(CopyBuffer(atrHandle,0,shift,1,tempATRArray)!=-1)
         valATR[shift]=tempATRArray[0];
      else
         valATR[shift]=valATR[i+1];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//CAtr iAtr;
//+------------------------------------------------------------------+
