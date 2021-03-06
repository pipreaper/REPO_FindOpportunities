//+------------------------------------------------------------------+
//|                                             Keltner Channels.mq4 |
//|                                                  Coded by Gilani |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Robert Baptie"
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrBurlyWood
#property indicator_color2 clrBurlyWood
#property indicator_color3 clrBurlyWood
//#include <MovingAverages.mqh>
double ExtUpper[],ExtMiddle[],ExtLower[];
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=1.5;


int OnInit(void)
  {
   IndicatorDigits(Digits);
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"Kelt Upper");
//   SetIndexDrawBegin(0,drawBegin);
   SetIndexBuffer(0,ExtUpper);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexLabel(1,"Kelt Middle");
//   SetIndexDrawBegin(1,drawBegin);
   SetIndexBuffer(1,ExtMiddle);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexLabel(2,"Kelt Lower");
//   SetIndexDrawBegin(2,drawBegin);
   SetIndexBuffer(2,ExtLower);

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
   if(rates_total<=Keltner_Period || Keltner_Period<=0)
      return(0);
   bool isSameSeries=false;
   ArraySetAsSeries(ExtUpper,isSameSeries);
   ArraySetAsSeries(ExtMiddle,isSameSeries);
   ArraySetAsSeries(ExtLower,isSameSeries);
   ArraySetAsSeries(open,isSameSeries);
   ArraySetAsSeries(high,isSameSeries);
   ArraySetAsSeries(low,isSameSeries);
//--MAIN LOOP     
   int pos=prev_calculated-1;
   if(pos<0)
      pos=0;
   for(int shift=pos; shift<rates_total; shift++)
     {
     // counts from left to right ignore less than average calculation
      if(shift<Keltner_Period)
         continue;
      ExtMiddle[shift]=iMA(Symbol(),Period(),Keltner_Period,0,Keltner_MaMode,PRICE_TYPICAL,rates_total-shift-1);      
      double avg=iATR(Symbol(),Period(),Keltner_ATR_Period,rates_total-shift-1);
      ExtUpper[shift] = ExtMiddle[shift] + Keltner_ATR_Flex * avg;
      ExtLower[shift] = ExtMiddle[shift] - Keltner_ATR_Flex * avg;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
