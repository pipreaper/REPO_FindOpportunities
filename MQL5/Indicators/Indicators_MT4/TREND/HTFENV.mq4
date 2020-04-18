//+------------------------------------------------------------------+
//| HTFs.mq4                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.03"
#property strict
#property indicator_chart_window
#include <WaveLibrary.mqh>
#include <status.mqh>
#property  indicator_buffers 2
//+------------------------------------------------------------------+
//| fast and medium EMA periods                                      |
//+------------------------------------------------------------------+
//--EMA periods
//extern string instrument=NULL;
//extern int wtf=NULL;
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_M15;
extern int envPeriod= 14;
extern int lineMode = MODE_SMA;
extern int shifteBy = 0;
extern int closeMode= PRICE_CLOSE;
extern double percentDeviation=0.1;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtUpper[];
double ExtLower[];
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
   checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex);
   //   Print(__FUNCTION__," has checkedEnumDesied:  ",checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex)," enumHTFPERIOD: ",enumHTFPeriod);
   clrLine=TF_C_Colors[htfIndex];   
   IndicatorBuffers(2);
   IndicatorShortName("HTFENV"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];
   SetIndexStyle(0,DRAW_LINE,0,1,clrAntiqueWhite);
   string ULabel="Upper_"+IntegerToString(htfIndex);
   SetIndexLabel(0,ULabel);
   SetIndexBuffer(0,ExtUpper);
   SetIndexEmptyValue(0,EMPTY_VALUE);
//   SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(1,DRAW_LINE,0,1,clrAntiqueWhite);
   string LLabel="Lower_"+IntegerToString(htfIndex);
   SetIndexLabel(1,LLabel);
   SetIndexBuffer(1,ExtLower);
   SetIndexEmptyValue(1,EMPTY_VALUE);
//   SetIndexDrawBegin(1,drawBegin);

   //SetIndexStyle(2,DRAW_ARROW,0,1,clrLimeGreen);
   //SetIndexArrow(2,233);
   //SetIndexLabel(2,"ENV Long");
   //SetIndexBuffer(2,ExtLongArrow);
   //SetIndexEmptyValue(2,EMPTY_VALUE);
   //SetIndexDrawBegin(2,drawBegin);

//   SetIndexStyle(3,DRAW_ARROW,0,1,clrPink);
//   SetIndexArrow(3,234);
//   SetIndexLabel(3,"ENV Short");
//   SetIndexBuffer(3,ExtShortArrow);
//   SetIndexEmptyValue(3,EMPTY_VALUE);
//   SetIndexDrawBegin(3,drawBegin);
//
//   SetIndexStyle(4,DRAW_ARROW,0,3,clrOrangeRed);
//   SetIndexArrow(4,159);
//   SetIndexLabel(4,"ENV Close_"+string(enumHTFPeriod));
//   SetIndexBuffer(4,ExtCloseArrow);
//   SetIndexEmptyValue(4,EMPTY_VALUE);
//   SetIndexDrawBegin(4,drawBegin);
//
//   SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
////SetIndexArrow(2,234);
//   SetIndexLabel(5,"ENV Status");
//   SetIndexBuffer(5,ExtStatus);
//   SetIndexEmptyValue(5,EMPTY_VALUE);
//   SetIndexDrawBegin(5,drawBegin);

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

   ArraySetAsSeries(ExtLower,true);
   ArraySetAsSeries(ExtUpper,true);
   //ArraySetAsSeries(ExtLongArrow,true);
   //ArraySetAsSeries(ExtShortArrow,true);
   //ArraySetAsSeries(ExtCloseArrow,true);
   //ArraySetAsSeries(ExtStatus,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(time,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-5; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);

         if((htfShift==phtfShift) && (shift<(rates_total-envPeriod-1)))
           {
            ExtUpper[shift+1]=ExtUpper[shift+2];
            ExtLower[shift+1]=ExtLower[shift+2];
            //ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
            //ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
            ////  ExtCloseArrow[shift+1]=ExtCloseArrow[shift+2];
            //ExtStatus[shift+1]=ExtStatus[shift+2];
            continue;
           }
         if(shift>(rates_total-2))
            continue;           
         double eUpper=iEnvelopes(instrument,enumHTFPeriod,envPeriod,lineMode,shifteBy,closeMode,percentDeviation,MODE_UPPER,phtfShift);
         ExtUpper[shift+1]=eUpper;
         double eLower=iEnvelopes(instrument,enumHTFPeriod,envPeriod,lineMode,shifteBy,closeMode,percentDeviation,MODE_LOWER,phtfShift);
         ExtLower[shift+1]=eLower;

         //SELL
         //if(high[phtfShift+1] < eLower) //&& (high[phtfShift+2]>high[phtfShift+1]) && (high[phtfShift+2]>high[phtfShift+3]))
         //   {//HIGH  
         //    ExtShortArrow[phtfShift+1]=ExtLower[phtfShift]+((ExtUpper[phtfShift]-ExtLower[phtfShift])/2);
         //    ExtStatus[phtfShift+1]=1;
         //   }
         // //BUY
         // //(ExtStatus[phtfShift]==NULL) &&
         // else if(low[phtfShift+1] > eUpper)// && (low[phtfShift+2]<low[phtfShift+1]) && (low[phtfShift+2]<low[phtfShift+3]))
         //   {//LOW
         //    ExtLongArrow[phtfShift+1]=ExtLower[phtfShift]+((ExtUpper[phtfShift]-ExtLower[phtfShift])/2);
         //    ExtStatus[phtfShift+1]=0;
         //   }          

         //CLOSE CONDITIONS
         //if((ExtStatus[phtfShift]==0) && (high[phtfShift]>eUpper))
         //  {
         //   ExtStatus[phtfShift]=NULL;           
         //   ExtCloseArrow[phtfShift]=high[phtfShift];
         //  }
         //else if((ExtShortArrow[phtfShift==1]) && (low[phtfShift+1]<eLower))
         //  {
         //   ExtStatus[phtfShift]=NULL;            
         //   ExtCloseArrow[phtfShift]=low[phtfShift];
         //  } 
         //if(high[phtfShift+2]>eUpper)
         //  {//HIGH  
         //   ExtShortArrow[phtfShift+1]=ExtLower[phtfShift]+((ExtUpper[phtfShift]-ExtLower[phtfShift])/2);
         //   ExtStatus[phtfShift+1]=1;
         //  }
         ////BUY
         ////(ExtStatus[phtfShift]==NULL) &&
         //else if(low[phtfShift+2]< eLower)
         //  {//LOW
         //   ExtLongArrow[phtfShift+1]=ExtLower[phtfShift]+((ExtUpper[phtfShift]-ExtLower[phtfShift])/2);
         //   ExtStatus[phtfShift+1]=0;
         //  }           
         // OPEN CONDITIONS  
         //SELL 
         //BUY
         //if((low[phtfShift+2]<low[phtfShift+1]) && (low[phtfShift+2]<low[phtfShift+3]) && (close[phtfShift+1]< eLower))
         //  {//LOW
         //   ExtLongArrow[phtfShift+1]=ExtLower[phtfShift]+((ExtUpper[phtfShift]-ExtLower[phtfShift])/3);
         //   ExtStatus[phtfShift+1]=0;
         //  }
         //else if((high[phtfShift+2]>high[phtfShift+1]) && (high[phtfShift+2]>high[phtfShift+3])  && (close[phtfShift+1] > eUpper))
         //  {//HIGH  
         //   ExtShortArrow[phtfShift+1]=ExtUpper[phtfShift]-((ExtUpper[phtfShift]-ExtLower[phtfShift])/3);
         //   ExtStatus[phtfShift+1]=1;
         //  }

        }
     }//new bar
   return(rates_total);
  }//
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal() -1; i>=0; i--)
      ObjectDelete(ObjectName(i));
  }
//+------------------------------------------------------------------+
