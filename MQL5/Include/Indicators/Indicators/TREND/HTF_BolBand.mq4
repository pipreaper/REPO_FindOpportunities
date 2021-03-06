//+------------------------------------------------------------------+
//| HTFADXs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 4
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_M15;
extern int    bollPeriod=20;      // Bands Period
extern double bollDeviations=2.0; // Bands Deviations  
extern int    bollShift=0;        // Bands Shift

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtStatus[];
double ExtTop[];
double ExtMiddle[];
double ExtBottom[];
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

   IndicatorBuffers(4);
   IndicatorShortName("HTF_Bol_Band"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_SECTION,0,1,clrLine);
   SetIndexLabel(0,"BB Long");
   SetIndexBuffer(0,ExtTop);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_SECTION,0,1,clrLine);
   SetIndexLabel(1,"BB Mid");
   SetIndexBuffer(1,ExtMiddle);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_SECTION,0,1,clrLine);
   SetIndexLabel(2,"BB Short");
   SetIndexBuffer(2,ExtBottom);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_ARROW,0,2,clrLine);
   SetIndexArrow(3,39);
   SetIndexLabel(3,"BB STATUS");
   SetIndexBuffer(3,ExtStatus);
   SetIndexEmptyValue(3,EMPTY_VALUE);

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

//   ArraySetAsSeries(high,true);
//   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ExtTop,true);
   ArraySetAsSeries(ExtMiddle,true);   
   ArraySetAsSeries(ExtBottom,true);
   ArraySetAsSeries(ExtStatus,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   if(isNewBar)
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         if(shift>(rates_total-bollPeriod-1))
            continue;
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);

         if(htfShift!=phtfShift)
           {
         ExtTop[shift+1]=iBands(instrument,enumHTFPeriod,bollPeriod,bollDeviations,bollShift,PRICE_CLOSE,MODE_UPPER,phtfShift);
         ExtMiddle[shift+1]=iBands(instrument,enumHTFPeriod,bollPeriod,bollDeviations,bollShift,PRICE_CLOSE,MODE_MAIN,phtfShift);         
         ExtBottom[shift+1]=iBands(instrument,enumHTFPeriod,bollPeriod,bollDeviations,bollShift,PRICE_CLOSE,MODE_LOWER,phtfShift);           
           }
        }//for
     }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//for(int i=ObjectsTotal() -1; i>=0; i--)
//  {
//   //    string nm=ObjectName(i);
//   //    Print("Deinit ",nm);
//   ObjectDelete(ObjectName(i));
//  }
  }
//+------------------------------------------------------------------+
