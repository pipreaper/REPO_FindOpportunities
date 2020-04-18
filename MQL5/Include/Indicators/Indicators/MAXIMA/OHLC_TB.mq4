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

extern int lowHighOffset=30;
extern bool bMajor=true;
extern bool bInter= false;
extern bool bMinor= false;
extern bool bPinBar = false;
double ExtBottom[];
double ExtTop[];
double ExtState[];
int shift=NULL;
int limit= NULL;
color clrLine=clrAliceBlue;
double mTop=0,iTop=1,sTop=2,mBottom=3,iBottom=4,sBottom=5,eTop=6,ebottom=7;
//double MT[3][2];//holds price information for trend
//int d_1=ArrayRange(MT,0);
//int d_2=ArrayRange(MT,1);
//+------------------------------------------------------------------+
//|Initialise                                                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(3);
   IndicatorShortName("OHLC_TB"+string(Period()));

   SetIndexStyle(0,DRAW_ARROW,0,1,clrBlue);
   SetIndexArrow(0,108);
   SetIndexLabel(0,"E_M_TOP");
   SetIndexBuffer(0,ExtTop);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(1,108);
   SetIndexLabel(1,"E_M_BOTTOM");
   SetIndexBuffer(1,ExtBottom);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_NONE,0,1,clrMediumPurple);
   SetIndexLabel(2,"STATE_"+string(Period()));
   SetIndexBuffer(2,ExtState);
   SetIndexEmptyValue(2,EMPTY_VALUE);

//for(int i=0; i<=d_1-1; i++)
//   for(int y=0; y<=d_2-1; y++)
//     {
//      MT[i,y]=EMPTY_VALUE;
//      // Print(MT[i,y]);
//     }

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
         double lowestLow=low[iLowest(Symbol(),Period(),MODE_LOW,lowHighOffset,shift+2)];
         double highestHigh=high[iHighest(Symbol(),Period(),MODE_HIGH,lowHighOffset,shift+2)];
         double elowestLow=low[iLowest(Symbol(),Period(),MODE_LOW,lowHighOffset,shift+1)];
         double ehighestHigh=high[iHighest(Symbol(),Period(),MODE_HIGH,lowHighOffset,shift+1)];       
         double pinBarHigh= high[iHighest(Symbol(),Period(),MODE_HIGH,3,shift+1)];
         double pinBarLow = low[iLowest(Symbol(),Period(),MODE_LOW,3,shift+1)];
         if(bPinBar && (pinBarHigh==high[shift+2]) && (close[shift+1]<low[shift+2]) && (close[shift+1]<low[shift+3]))
           {
            ExtTop[shift+1]=high[shift+2];
            ExtState[shift+1]=8;
           }
         if(bPinBar && (pinBarLow==low[shift+2]) && (close[shift+1]>high[shift+2]) && (close[shift+1]>high[shift+3]))
           {
            ExtBottom[shift+1]=low[shift+2];
            ExtState[shift+1]=9;
           }
         //MAJOR TOP
         if(highestHigh==high[shift+2])
           {
            double mTopLow=low[iLowest(Symbol(),Period(),MODE_LOW,4,shift+1)];
            double iTopLow=low[iLowest(Symbol(),Period(),MODE_LOW,3,shift+1)];
            double sTopLow=low[iLowest(Symbol(),Period(),MODE_LOW,2,shift+1)];
            if(bMajor && (mTopLow==low[shift+1]) && (low[shift+1]<low[shift+2]))
              {
               ExtTop[shift+1]=high[shift+2];
               //              updateTrend(high[shift+2],mTop);
               ExtState[shift+1]=0;
              }
            else if(bInter && (iTopLow==low[shift+1]) && (low[shift+1]<low[shift+2]))
              {
               ExtTop[shift+1]=high[shift+2];
               //             updateTrend(high[shift+2],iTop);
               ExtState[shift+1]=1;
              }
            else if(bMinor && (sTopLow==low[shift+1]) && (low[shift+1]<low[shift+2]))
              {
               ExtTop[shift+1]=high[shift+2];
               //               updateTrend(high[shift+2],sTop);
               ExtState[shift+1]=2;
              }
           }
         //MAJOR BOTTOM
         else if(lowestLow==low[shift+2])
           {
            double mBottomHigh=high[iHighest(Symbol(),Period(),MODE_HIGH,4,shift+1)];
            double iBottomHigh=high[iHighest(Symbol(),Period(),MODE_HIGH,3,shift+1)];
            double sBottomHigh=high[iHighest(Symbol(),Period(),MODE_HIGH,2,shift+1)];
            if(bMajor && (mBottomHigh==high[shift+1]) && (high[shift+1]>high[shift+2]))
              {
               ExtBottom[shift+1]=low[shift+2];
               //             updateTrend(low[shift+2],mBottom);
               ExtState[shift+1]=3;
              }
            else if(bInter && (iBottomHigh==high[shift+1]) && (high[shift+1]>high[shift+2]))
              {
               ExtBottom[shift+1]=low[shift+2];
               //             updateTrend(low[shift+2],iBottom);
               ExtState[shift+1]=4;
              }
            else if(bMinor && (sBottomHigh==high[shift+1]) && (high[shift+1]>high[shift+2]))
              {
               ExtBottom[shift+1]=low[shift+2];
               //              updateTrend(low[shift+2],sBottom);
               ExtState[shift+1]=5;
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
//+------------------------------------------------------------------+
//| updateTrend  Update the trend array with new info                |
//+------------------------------------------------------------------+
//void updateTrend(double val,double TB)
//  {
//   double lastTrend=MT[d_1-1,1];
////Have new Top or Bottom to replace old Top or Bottom   
//   if(lastTrend==TB)
//      MT[d_1-1,0]=val;
//// cycle and update top or bottom to new form and value
//   else
//     {
//      for(int i=0; i<=d_1-2; i++)
//        {
//         MT[i,0]=MT[i+1,0];
//         MT[i,1]=MT[i+1,1];
//        }
//      MT[d_1-1,0]=val;
//      MT[d_1-1,1]=TB;
//     }
//  }
//+------------------------------------------------------------------+
//| whatsTrend report to buffers trend status                        |
//+------------------------------------------------------------------+
//void whatsTrend(int Shift,double high,double low,double close)
//  {
//   for(int i=ArraySize(MT)-1; i>=0; i--)
//     {
//      //TBT
//      if((MT[2,0]>MT[0,0]) && (MT[1,0]>MT[2,0]))
//         ExtExtremeLongArrow[Shift]=low;
//      //BTB
//      else if((MT[2,0]>MT[0,0]) && (MT[0,0]>MT[1,0]))
//         ExtExtremeLongArrow[Shift]=low;
//      //BTB      
//      else if((MT[2,0]<MT[0,0]) && (MT[1,0]>MT[0,0]))
//         ExtExtremeShortArrow[Shift]=high;
//      //TBT      
//      else if((MT[2,0]<MT[0,0]) && (MT[1,0]<MT[2,0]))
//         ExtExtremeShortArrow[Shift]=high;
//     }
//  }
