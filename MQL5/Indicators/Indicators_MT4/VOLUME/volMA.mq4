//+------------------------------------------------------------------+
//|                                                        volMA.mq4 |
//+------------------------------------------------------------------+
//**************----------------  Simple Moving Average of Volume   ---------*************************
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.07"
#property strict
#property indicator_separate_window


#property indicator_buffers 4
#property indicator_color1 Green//wick
#property indicator_color2 Red//wick
#property indicator_color3 Blue//wick
#property indicator_color4 Yellow//wick
//#property indicator_color3 Blue//candle
//#property indicator_color4 Red//candle
#property indicator_width1 1
//#property indicator_width2 1
//#property indicator_width4 3

int debug=-1;
//---- input parameters
//extern int   volPeriod=100;
extern int  CandleWidth=3;
//---- buffers
double volUp[],volDown[],volMA[],volNow[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName("Volume Candles");
   IndicatorBuffers(3);
   SetIndexBuffer(0,volUp);
   SetIndexBuffer(1,volDown);
   SetIndexBuffer(2,volMA);
   SetIndexBuffer(3,volNow);

   SetIndexStyle(0,DRAW_HISTOGRAM,0,CandleWidth);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,CandleWidth);
   SetIndexStyle(2,DRAW_LINE,0);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,CandleWidth);
//---
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
   ArraySetAsSeries(tick_volume,false);
   ArraySetAsSeries(volMA,false);
   ArraySetAsSeries(volUp,false);
   ArraySetAsSeries(volDown,false);
   ArraySetAsSeries(volNow,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(open,false);
//--MAIN LOOP     
   int pos=prev_calculated-1;
   if(pos<0)
      pos=0;
   for(int shift=pos; shift<rates_total; shift++)
     {
      // if (shift==rates_total-1)
      //debug =-1;
      //volMA[shift]=iSMAVOL(shift,volPeriod,tick_volume);
      if(shift==0)
         continue;
      if(shift==rates_total-1)
         //yellow
        {
         volNow[shift]=(double)tick_volume[shift];
         volUp[shift]=EMPTY_VALUE;
         volDown[shift]=EMPTY_VALUE;
         continue;
        }
      if(tick_volume[shift]<=tick_volume[shift-1])
         //green
        {
         volDown[shift]=(double)tick_volume[shift];
         volUp[shift]=EMPTY_VALUE;
         volNow[shift]=EMPTY_VALUE;
        }
      else
      //red
        {
         volUp[shift]=(double)tick_volume[shift];
         volDown[shift]=EMPTY_VALUE;
         volNow[shift]=EMPTY_VALUE;
        }
     }
//--- return value of prev_calculated for next call
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
