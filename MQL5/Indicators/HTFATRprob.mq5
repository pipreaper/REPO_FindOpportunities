//+------------------------------------------------------------------+
//|                                                 Copyright © 2020 |
//+------------------------------------------------------------------+
#property description "ATR, Multi-timeframe"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <CLASS_FILES\CAtr.mqh>
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
input ENUM_TIMEFRAMES      waveHTFPeriod  =  PERIOD_M2;      // Timeframe 2 (TF2) period
input int                  inpAtrPeriod   =  14; // ATR period
input ENUM_LINE_STYLE      lineStyle      =   STYLE_DOT;//Line Style
input ENUM_CAT_ID          catalystID =  TRD;// TRD or VOL
//input bool                 showErrorMessages = false;
//int htfIndex=findIndexPeriod(waveHTFPeriod);
double valATR[];
//bool timedEvent = false;
int               bufferSize  =  -1;
static datetime   time0       =  NULL;
int               limit       =  -1;
static int        htfShift    =  -1;
static int        pHtfShift   =  -1;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   ResetLastError();
   ArrayInitialize(valATR, EMPTY_VALUE);
   if(!iAtr.Create(_Symbol,waveHTFPeriod,inpAtrPeriod))
      Print(__FUNCTION__,"iAtr create error: ",ErrorDescription(GetLastError()));
// map index buffers
   SetIndexBuffer(0,valATR,INDICATOR_DATA);
//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(valATR,true);
//--- set color for tf
   PlotIndexSetInteger(0, PLOT_LINE_COLOR,    iAtr.findColor(iAtr.findIndexPeriod(waveHTFPeriod)));
   PlotIndexSetString(0,PLOT_LABEL,"ATR("+EnumToString(catalystID)+":"+string(inpAtrPeriod)+":"+EnumToString(waveHTFPeriod)+")");
//--- Set the line drawing
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE, lineStyle);
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR("+EnumToString(catalystID)+":"+string(inpAtrPeriod)+":"+EnumToString(waveHTFPeriod)+")");
   int waitMS = 1;
   Print("-----------------------",TimeCurrent(),"--------------------------");
   EventSetMillisecondTimer(waitMS);
   Print("OnTimer set to ",waitMS," ms");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|ensure have a refreshed dataset for indicator                     |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ResetLastError();
   iAtr.Refresh();
   CIndicatorBuffer *buff = iAtr.At(0);
   if(!iAtr.timedEvent && (buff.Total() > 0))
     {
      Print(__FUNCTION__," buffer total ", buff.Total());
      EventKillTimer();
      iAtr.timedEvent = true;
     }
// else
//  Print(__FUNCTION__, "buffer size < 1 ",ErrorDescription(GetLastError())+" "+TimeToString(TimeCurrent()));
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
   if(!iAtr.timedEvent)
     {
      Print(__FUNCTION__," !timedEvent "+TimeToString(TimeCurrent()));
      return rates_total;
     }
   else if(!iAtr.haveData)
     {
      // first pass
      iAtr.haveData = true;
      return (1);
      Print(__FUNCTION__," !havedata, limit: ",limit);
     }
   else
     {
      limit=rates_total-prev_calculated;
      if(limit > 0)
         limit -=1;
     }
// new bar of CTF?
//   datetime tda[];
   ArraySetAsSeries(time,true);
//   bool isNewBar=(time0!=time[0]);
//   if(isNewBar)
//     {
//     Print(__FUNCTION__," limit:  ",limit);
//     time0=time[0];
//       {
   ResetLastError();
   CIndicatorBuffer *buff = iAtr.At(0);
   bufferSize = buff.Total();
   if(bufferSize <= 0)
     {
      iAtr.Refresh();
      Print(__FUNCTION__, " Failure 1: size been reset < 1 Attempt to refresh Rates because buffersize < 0 "+TimeToString(TimeCurrent()));
     }
   if(bufferSize <= 0)
      Print(__FUNCTION__, " Failure 2: Buffer size < 1 after Reset ",ErrorDescription(GetLastError())+TimeToString(TimeCurrent()));
   else
     {
      for(int shift=limit; shift>=0; shift--)//start rates_total down to zero
        {
         if(shift>(rates_total-inpAtrPeriod-1))
            continue;
         else
           {
            htfShift=iBarShift(_Symbol,waveHTFPeriod,time[shift],true);
            pHtfShift=iBarShift(_Symbol,waveHTFPeriod,time[shift+1],true);
            //     if((shift == 0) || (shift == rates_total-inpAtrPeriod-1))
            //        Print("shift ",shift," limit ",limit," time[shift] ",time[shift]," time,[shift+1] ",time[shift+1], " hffshift ",htfShift," pHtfShift ",pHtfShift);
            if((pHtfShift == -1) || (htfShift == -1))
               continue;
            if(htfShift != pHtfShift)
              {
               double tempATRArray[];
               if(CopyBuffer(iAtr.Handle(),0,htfShift,1,tempATRArray)<=0)
                  Print(__FUNCTION__," failed to get ATR buffer, phtfShoft: "+IntegerToString(pHtfShift));
               else
                  valATR[shift]=tempATRArray[0];
               continue;
              }
            else
               valATR[shift]=valATR[shift+1];
           }
        }
      //         }
      //      }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// iAtr.DeleteFromChart(ChartID(),CHART_WINDOWS_TOTAL);
//iAtr.FullRelease();
   return;
  }
CAtr iAtr;
//+------------------------------------------------------------------+
