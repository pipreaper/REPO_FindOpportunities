//+------------------------------------------------------------------+
//|                                                        volume.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.08"
#property strict
#property indicator_separate_window
#property indicator_buffers 2

extern int  CandleWidth=2;
int shift=NULL;
int limit= NULL;

//---- buffers
double volUp[],volDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName("Volume Candles");
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM,0,CandleWidth,clrGreen);
   SetIndexBuffer(0,volUp);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,CandleWidth,clrRed);
   SetIndexBuffer(1,volDown);
   SetIndexEmptyValue(1,EMPTY_VALUE);
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
//---
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volUp,true);
   ArraySetAsSeries(volDown,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
//--MAIN LOOP     
   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   for(shift=limit; shift>=0; shift--)//start rates_total down to zero
     {
      if(shift>rates_total-3)
         continue;
      if(tick_volume[shift]>=tick_volume[shift+1])
         //green
        {
         volUp[shift]=(double)tick_volume[shift];
         volDown[shift]=EMPTY_VALUE;
        }
      else if(tick_volume[shift]<tick_volume[shift+1])
      //red
        {
         volDown[shift]=(double)tick_volume[shift];
         volUp[shift]=EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double iSMAVOL(const int position,const int period,const long &tick_price[])
  {
//---
   double result=0.0;
//--- check position
   if(position>=period-1 && period>0)
     {
      //--- calculate value
      //for(int i=0;i<period;i++) 
      for(int i=(period-1); i>=0; i--)
         result+=(double)tick_price[position-i];
      result/=period;
     }
   else
      result=-1;
   return(result);
  }
//+------------------------------------------------------------------+
