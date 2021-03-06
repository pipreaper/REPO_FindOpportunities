//+------------------------------------------------------------------+
//|                                       Toby_Crabel_NR_Pattern.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Robert Baptie"
#property link      "http:"
#property version"1.12"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#include <WaveLibrary.mqh>
extern string methodStr="method: 0 - 2NR, 1 - 3NR, 2 - 4NR, 3 - 8NR, 4 - Customizable";
extern int method=0;  // 0 - 2NR, 1 - 3NR, 2 - 4NR, 3 - 8NR, 4 - Customizable
extern int sample=2;
extern int length=20;
extern bool showWideRangeBar=true;
extern bool showNarrowRangeBar=true;

double ExtWideBars[],ExtNarrowBars[],HL[];
int _Sample,_Length;
int arrowSize=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName("Toby Crabel NR Pattern");
   IndicatorDigits(Digits);
   IndicatorBuffers(2);

   SetIndexBuffer(0,ExtWideBars);
   SetIndexStyle(0,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(0,181);//34   
   SetIndexLabel(0,"WIDE bar");
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexBuffer(1,ExtNarrowBars);
   SetIndexStyle(1,DRAW_ARROW,0,1,clrYellow);
   SetIndexArrow(1,36);//36   
   SetIndexLabel(1,"NR bar");
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,HL);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   if(method==0)
     {
      _Sample=2;
      _Length=20;
     }
   if(method==1)
     {
      _Sample=3;
      _Length=20;
     }
   if(method==2)
     {
      _Sample=4;
      _Length=40;
     }
   if(method==3)
     {
      _Sample=8;
      _Length=40;
     }
   if(method>3)
     {
      _Sample=sample;
      _Length=length;
     }
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
   ArraySetAsSeries(ExtNarrowBars,true);
   ArraySetAsSeries(ExtWideBars,true);
   ArraySetAsSeries(close,true);   

   int limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=rates_total-1; //include zero
   else
      limit++;
   double min=INF,max=-1;
   for(int shift=limit; shift>=0; shift--)//start rates_total down to zero
     {
      min=Low[iLowest(NULL, 0, MODE_LOW, _Sample, shift)];
      max=High[iHighest(NULL, 0, MODE_HIGH, _Sample, shift)];
      HL[shift]=max-min;
     }
   for(int shift=limit; shift>=0; shift--)//start rates_total down to zero
     {
      min=HL[ArrayMinimum(HL, _Length, shift)];
      max=HL[ArrayMaximum(HL, _Length, shift)];
      if(showWideRangeBar)
        {
         if(max==HL[shift])
           {
            ExtWideBars[shift]=close[shift];
            //if(shift<20)
            //   Print("WB ",shift,"value: ",High[shift]);
           }
         else
           {
            ExtWideBars[shift]=EMPTY_VALUE;
           }
        }
      if(showNarrowRangeBar)
        {
         if(min==HL[shift])
           {
            ExtNarrowBars[shift]=close[shift];
            //if(shift<20)
            //   Print("NR ",shift,"value: ",High[shift]);
           }
         else
           {
            ExtNarrowBars[shift]=EMPTY_VALUE;
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
