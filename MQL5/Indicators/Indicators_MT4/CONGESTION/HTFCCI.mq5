//+------------------------------------------------------------------+
//| CCIHTFs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.02"
#property description "HTF is set -> (enumHTFPeriod=PERIOD_M15)"
#property description "Checks HTF and sets Arrow if crosses levels(high/low)"
#property description "Sets ExStatus buffer to 1/-1 if it has crossed and above the considerationHigh / considerationLow level"
#property description "Arrow on HTF is set to zero in other circumstances"
#property strict
#property indicator_separate_window
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#property  indicator_buffers 4
//+------------------------------------------------------------------+
//| Global variables CCI                                             |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES enumPassedPeriod=PERIOD_M15;
extern int periodCCI=14;
extern int appliedPrice=PRICE_CLOSE;
extern int levelTop=300;
extern int levelBottom=-300;
extern int considerationHighLevel=100;
extern int considerationLowLevel = -100;
extern int maxBarsDraw=5000;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES enumHTFPeriod;
int htfIndex=findIndexPeriod(enumPassedPeriod);
//int wtfIndex= NULL;
int debug=-1;
double ExtCCI[];
double ExtStatus[];
double ExtShortArrow[];
double ExtLongArrow[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string instrument=Symbol();
//int wtf=_Period;
int shift=NULL;
int limit= NULL;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
  enumHTFPeriod = enumPassedPeriod;
   if(_Period>enumHTFPeriod)
     {
      Print(enumHTFPeriod);
      if(!(enumHTFPeriod==0))
        {
         Print("***** enumHTFPeriod: "+string(enumHTFPeriod)+" Indicator only shows higher timeframes of _Period: "+string(_Period));
         Print("***** SETTING PERIOD TO DEFAULT CHART PERIOD: "+string(_Period));
        }
      else
         Print("used current");
      enumHTFPeriod=ENUM_TIMEFRAMES(_Period);
      htfIndex=findIndexPeriod(enumHTFPeriod);
     }
   color clrLine=clrNONE;
   int drawBegin=0;

   IndicatorBuffers(4);
   IndicatorShortName("CCIHTFs"+" "+Symbol()+" "+string(enumHTFPeriod));
   clrLine=findColorIndex(htfIndex);

   SetIndexStyle(0,DRAW_LINE,0,1,clrLine);
   string Label="CCI_"+string(enumHTFPeriod);
   SetIndexLabel(0,Label);
   SetIndexBuffer(0,ExtCCI);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(1,DRAW_NONE,2,3,clrNONE);
   string statusLabel="Status_"+string(enumHTFPeriod);
   SetIndexLabel(1,statusLabel);
   SetIndexBuffer(1,ExtStatus);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexDrawBegin(1,drawBegin);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(2,233);
   SetIndexLabel(2,"CCI Long_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExtLongArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexDrawBegin(2,drawBegin);

   SetIndexStyle(3,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(3,234);
   SetIndexLabel(3,"CCI Short_"+string(enumHTFPeriod));
   SetIndexBuffer(3,ExtShortArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexDrawBegin(3,drawBegin);

   SetLevelValue(0,levelTop);
   SetLevelValue(1,levelBottom);

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

   ArraySetAsSeries(ExtCCI,true);
   ArraySetAsSeries(ExtStatus,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);

         if((htfShift==phtfShift) && (shift<(rates_total-periodCCI-1)))
           {
            ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
            ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
            ExtStatus[shift+1]=ExtStatus[shift+2];
            ExtCCI[shift+1]=ExtCCI[shift+2];
            continue;
           }

         double tfCCI=iCCI(instrument,enumHTFPeriod,periodCCI,appliedPrice,phtfShift);
         double tfPrevCCI=iCCI(instrument,enumHTFPeriod,periodCCI,appliedPrice,phtfShift+1);
         double tfStatus=NULL;
         ExtCCI[shift+1]=tfCCI;
         if((tfPrevCCI<levelBottom) && (tfCCI>levelBottom))
           {
            ExtStatus[shift+1]=1;
            ExtLongArrow[shift+1]=ExtCCI[shift+1]-MathAbs(tfCCI-tfPrevCCI);
           }
         //CCI Turned and is above and within limits of recording;
         else
            if((ExtStatus[shift+1]==1) && (tfCCI>considerationHighLevel))
              {
               ExtStatus[shift+1]=1;
              }
            //CCI turning over at the top
            else
               if((tfPrevCCI>levelTop) && (tfCCI<levelTop))
                 {
                  ExtStatus[shift+1]=-1;
                  ExtShortArrow[shift+1]=ExtCCI[shift+1]+MathAbs(tfCCI-tfPrevCCI);
                 }
               //CCI Turned and is above and within limits of rec
               else
                  if((ExtStatus[shift+1]==-1) && (tfCCI<considerationLowLevel))
                    {
                     ExtStatus[shift+1]=-1;
                    }
                  else
                    {
                     ExtStatus[shift+1]=0;
                     ExtLongArrow[shift+1]=EMPTY_VALUE;
                     ExtShortArrow[shift+1]=EMPTY_VALUE;
                    }
        }
     }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
