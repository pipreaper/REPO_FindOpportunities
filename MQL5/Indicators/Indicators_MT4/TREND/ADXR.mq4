//+------------------------------------------------------------------+
//|                                                         ADXR.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 YellowGreen
#property indicator_color2 Wheat
#property indicator_color3 LightSeaGreen
#property indicator_color4 Red
extern int adxPeriod=14;
extern int adxAgo=14;
//---- buffers
double di_plus[],di_minus[],adx[],adxr[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 1 additional buffer used for counting.
   IndicatorBuffers(4);
   IndicatorDigits(Digits);
//--- indicator buffers mapping
//--- di+
   SetIndexStyle(0,DRAW_NONE,2);
   SetIndexBuffer(0,di_plus);
  // SetIndexDrawBegin(0,drawBegin);
   SetIndexLabel(0,"DI+");
//--- di-
   SetIndexStyle(1,DRAW_NONE,2);
   SetIndexBuffer(1,di_minus);
  // SetIndexDrawBegin(1,drawBegin);
   SetIndexLabel(1,"DI-");
//--- adx
   SetIndexStyle(2,DRAW_LINE,2);
   SetIndexBuffer(2,adx);
   //SetIndexDrawBegin(2,drawBegin);
   SetIndexLabel(2,"ADX");
//--- adxr
   SetIndexStyle(3,DRAW_LINE,2);
   SetIndexBuffer(3,adxr);
   //SetIndexDrawBegin(3,drawBegin);
   SetIndexLabel(3,"ADXR");
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
   if((rates_total<=(adxPeriod+adxAgo)) || ((adxPeriod+adxAgo)<=0))
      return(0);
   bool isSameSeries=true;
   ArraySetAsSeries(di_minus,isSameSeries);
   ArraySetAsSeries(di_plus,isSameSeries);
   ArraySetAsSeries(adxr,isSameSeries);
   ArraySetAsSeries(adx,isSameSeries);
//--- starting calculation

   int limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(int shift=0; shift<limit; shift++)
     {
      if(shift>(rates_total-(adxPeriod)))
         continue;
      di_plus[shift]=iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_PLUSDI,shift);
      di_minus[shift]=iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MINUSDI,shift);
      adx[shift]=iADX(NULL,0,adxPeriod,PRICE_CLOSE,MODE_MAIN,shift);
     }
   for(int shift=0; shift<limit; shift++)
     {
      if(shift>(rates_total-(adxPeriod+adxAgo)))
         continue;     
      adxr[shift]=(adx[shift]+adx[shift+adxAgo])/2;
      int debug=1;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
