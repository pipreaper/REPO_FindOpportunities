//+------------------------------------------------------------------+
//|                                          generic percentiles.mq4 |
//|                                    Copyright 2017, Robert Baptie |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <WaveLibrary.mqh>
#property indicator_chart_window
#property indicator_buffers 3
extern int lowHighOffset=20;
extern double retrace=65;
double ExtBottom[];
double ExtTop[];
double ExtState[];

int shift=NULL;
int limit= NULL;
color clrLine=clrAliceBlue;
double mTop=0,iTop=1,sTop=2,mBottom=3,iBottom=4,sBottom=5;
double MT[3][2];//holds price information for trend
int d_1=ArrayRange(MT,0);
int d_2=ArrayRange(MT,1);
//+------------------------------------------------------------------+
//|Initialise                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(3);
   IndicatorShortName("EXTREME_TOP_BOTTOM "+string(Period()));

   SetIndexStyle(0,DRAW_ARROW,1,30,clrCrimson);
   SetIndexArrow(0,160);
   SetIndexLabel(0,"EXTREME TOP");
   SetIndexBuffer(0,ExtTop);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,1,30,clrBlueViolet);
   SetIndexArrow(1,160);
   SetIndexLabel(1,"EXTREME BOTTOM");
   SetIndexBuffer(1,ExtBottom);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_NONE,10,10,clrBlueViolet);
   SetIndexArrow(2,160);
   SetIndexLabel(2,"EXTREME STATE");
   SetIndexBuffer(2,ExtState);
   SetIndexEmptyValue(2,EMPTY_VALUE);

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
//-- Set up conditions for new bar
   static int htfShift=-1;
   static int phtfShift=-1;
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ExtTop,true);
   ArraySetAsSeries(ExtBottom,true);
   ArraySetAsSeries(ExtState,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>0; shift--)//start rates_total down to zero
        {
         if(shift>(rates_total-lowHighOffset-1))
            continue;
         double elowestLow=low[iLowest(Symbol(),Period(),MODE_LOW,lowHighOffset,shift+1)];
         double ehighestHigh=high[iHighest(Symbol(),Period(),MODE_HIGH,lowHighOffset,shift+1)];
         //EXTREME TOP
         double closePercent=0;
         if(ehighestHigh==high[shift+2])
           {
            double wick=high[shift+2]-low[shift+2];
            double highestOC=MathMax(close[shift+2],open[shift+2]);
            if(wick>0)
               closePercent=((high[shift+2]-highestOC)/wick)*100;
            if(closePercent>=retrace)
              {
               ExtTop[shift+1]=high[shift+2];
               ExtState[shift+1]=6;
              }
           }
         //EXTREME BOTTOM
         else if(elowestLow==low[shift+2])
           {
            double wick=high[shift+2]-low[shift+2];
            double lowestOC=MathMin(close[shift+2],open[shift+2]);
            if(wick>0)
               closePercent=((lowestOC-low[shift+2])/wick)*100;
            else
               closePercent=0;
            if(closePercent>=retrace)
              {
               ExtBottom[shift+1]=low[shift+2];
               ExtState[shift+1]=7;
              }
           }
         ChartRedraw(ChartID());
         Sleep(200);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      // string nm=ObjectName(i);
      // Print("Deinit ",nm);
      //  ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+
