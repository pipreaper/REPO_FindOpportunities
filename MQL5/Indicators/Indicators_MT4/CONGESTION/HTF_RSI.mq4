//+------------------------------------------------------------------+
//| RSIHTFs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.02"
#property description "RSI show markers for extremes"
//--- set the maximum and minimum values for the indicator window
#property indicator_minimum 0
#property indicator_maximum 100
#property strict
#property indicator_separate_window
#include <WaveLibrary.mqh>
#include <status.mqh>
#property  indicator_buffers 6
//+------------------------------------------------------------------+
//| Global variables RSI                                             |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H4;
extern int periodRSI=5;
extern int levelBottom=20;
extern int levelTop=80;
extern int considerationHighLevel=50;
extern int considerationLowLevel = 50;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

//Buffers
double ExtRSI[];
double ExtStatus[];
double ExtShortArrow[];
double ExtLongArrow[];
double ExtShortHArrow[];
double ExtLongHArrow[];
//TimeFrames
int htfIndex=NULL;
string instrument=Symbol();
ENUM_TIMEFRAMES startEnum=NULL;
int wtfIndex=findWTFIndex(enumHTFPeriod,startEnum);
int wtf=Period();
int shift=NULL;
int limit= NULL;
color clrLine=clrNONE;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex))
      Print(__FUNCTION__," has checkedEnumDesied:  ",checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex)," enumHTFPERIOD: ",enumHTFPeriod);
   clrLine=TF_C_Colors[htfIndex];

   IndicatorBuffers(6);
   IndicatorShortName("HTFRSI"+" "+Symbol()+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_SECTION,0,1,clrLine);
   string RSILabel="HTFRSI_"+string(enumHTFPeriod);
   SetIndexArrow(0,159);
   SetIndexLabel(0,RSILabel);
   SetIndexBuffer(0,ExtRSI);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_NONE,2,3,clrNONE);
   string statusLabel="HTFRSI Status_"+string(enumHTFPeriod);
   SetIndexLabel(1,statusLabel);
   SetIndexBuffer(1,ExtStatus);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrLine);
   SetIndexArrow(2,181);
   SetIndexLabel(2,"HTFRSI Long_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExtLongArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_ARROW,0,1,clrLine);
   SetIndexArrow(3,182);
   SetIndexLabel(3,"HTFRSI Short_"+string(enumHTFPeriod));
   SetIndexBuffer(3,ExtShortArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,DRAW_ARROW,0,1,clrViolet);
   SetIndexArrow(4,181);
   SetIndexLabel(4,"HTFRSI Long_H_"+string(enumHTFPeriod));
   SetIndexBuffer(4,ExtLongHArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);

   SetIndexStyle(5,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(5,181);
   SetIndexLabel(5,"HTFRSI Short_H_"+string(enumHTFPeriod));
   SetIndexBuffer(5,ExtShortHArrow);
   SetIndexEmptyValue(5,EMPTY_VALUE);

   SetLevelStyle(STYLE_DASH,1,clrLine);
   SetLevelValue(0,levelBottom);
   SetLevelValue(1,levelTop);
   SetLevelValue(2,50);
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

   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ExtRSI,true);
   ArraySetAsSeries(ExtStatus,true);
   ArraySetAsSeries(ExtLongArrow,true);
   ArraySetAsSeries(ExtShortArrow,true);
   ArraySetAsSeries(ExtLongHArrow,true);
   ArraySetAsSeries(ExtShortHArrow,true);
   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
     {
      if(shift>(rates_total-periodRSI-6))
         continue;
      htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
      phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);
      double tfRSI0=iRSI(instrument,enumHTFPeriod,periodRSI,0,phtfShift);
      if(isNewBar)// ***** the chart tf the indicator is applied to
        {
         //if(htfShift==phtfShift)
         //  {
         //   //ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
         //   // ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
         //   // ExtStatus[shift+1]=ExtStatus[shift+2];
         //  // ExtRSI[shift+1]=ExtRSI[shift+2];
         //   continue;
         //  }

         if(htfShift!=phtfShift)
           {
            ExtRSI[shift+1]=tfRSI0;

            if(ExtRSI[shift+1]>=levelTop)
               ExtShortHArrow[shift+1]=ExtRSI[shift+1];
            if(ExtRSI[shift+1]<=levelBottom)
               ExtLongHArrow[shift+1]=ExtRSI[shift+1];

            bool isLong=false,isShort=false;
            if(tfRSI0>considerationHighLevel)
               isLong=true;
            else if(tfRSI0<considerationLowLevel)
               isShort=true;

            for(int r=1; r<5; r++)
              {
               //tfRSI0=iRSI(instrument,enumHTFPeriod,periodRSI,0,phtfShift+r);
               if((tfRSI0>considerationLowLevel) && !isShort && isLong)
                 {
                  isLong=true;
                  isShort=false;
                  continue;
                 }
               else if((tfRSI0<considerationHighLevel) && !isLong && isShort)
                 {
                  isShort=true;
                  isLong =false;
                  continue;
                 }
               else
                 {
                  isLong=false;
                  isShort=false;
                  break;
                 }
              }
            //   double tfRSI0=iRSI(instrument,enumHTFPeriod,periodRSI,0,phtfShift);
            //    double tfRSIP=iRSI(instrument,enumHTFPeriod,periodRSI,0,phtfShift+1);
            if((isLong) && (tfRSI0>considerationHighLevel))// && (tfRSI0 > tfRSIP))//(tfRSIPrev<levelBottom) && (tfRSI>levelBottom))
              {
               ExtStatus[shift+1]=0;
               ExtShortArrow[shift+1]=tfRSI0;//+MathAbs(tfRSI-tfRSIPrev);
              }
            //RSI turning over at the top     
            else if((isShort) && (tfRSI0<considerationLowLevel))// && (tfRSI0 < tfRSIP))//(tfRSIPrev>levelTop) && (tfRSI<levelTop))
              {
               ExtStatus[shift+1]=1;
               ExtLongArrow[shift+1]=tfRSI0;//-MathAbs(tfRSI-tfRSIPrev);
              }
           }//new bar
        }
      //  ExtRSI[shift+1]=tfRSI;
      //ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
      //ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
      //    ExtStatus[shift+1]=ExtStatus[shift+2];      
     }//for
   //if(limit<=0)
   //  {
   //   double tfRSI=iRSI(instrument,enumHTFPeriod,periodRSI,0,0);
   //   ExtRSI[shift+1]=tfRSI;
   //  }
   return(rates_total);
  }
//+------------------------------------------------------------------+
