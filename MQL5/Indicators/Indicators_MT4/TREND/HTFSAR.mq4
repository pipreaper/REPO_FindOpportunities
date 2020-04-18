//+------------------------------------------------------------------+
//| CCIHTFs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.06"
#property strict
#property description "ExStatus =  1: trending UP     -> HTF: (ADX > ADXPrev) and (DMI+ > DMIPrev+) and (DMI+ > DMI-) and (ADX and >limit(25))"
#property description "ExStatus = -1: trending DOWN   -> HTF: (ADX > ADXPrev) and (DMI- > DMIPrev-) and (DMI- > DMI+) and (ADX and >limit(25))"
#property description "ExStatus =  0: Ding nothing Interesting: ExStatus buffer = 0"
#property description "ExStatus =  2: ADX hooked over -> falling HTF: ADX < ADXPrev"
#property indicator_chart_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 1
//+------------------------------------------------------------------+
//| Global variablesADX                                              |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H1;
extern int adxPeriod=14;
extern int priceField=0;//CLOSE
extern int maxBarsDraw=5000;
extern double dStep= 0.02;
extern double dMax = 0.2;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int debug=-1;
double ExtSAR[];
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

   int drawBegin=0;
   if(Bars>maxBarsDraw)
      drawBegin=Bars-maxBarsDraw;
   else
      drawBegin=adxPeriod;
   IndicatorBuffers(1);
   IndicatorShortName("HTFSAR"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_ARROW,EMPTY_VALUE,2,clrLine);
   SetIndexArrow(0,160);
   string Label="SAR_"+string(enumHTFPeriod);
   SetIndexLabel(0,Label);
   SetIndexBuffer(0,ExtSAR);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexDrawBegin(0,drawBegin);

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
   ArraySetAsSeries(ExtSAR,true);

//-- Set up conditions for new bar
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   else
      limit++;
   static int preHTFShift=-1;
   for(shift=limit; shift>=0; shift--)//start rates_total down to zero
     {
      int htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
      bool isNewHTFBar=htfShift!=preHTFShift;

      if(isNewHTFBar)
        {
         //Print("prevHTFShift ",preHTFShift," htfShift ",htfShift," ",Time[shift]);
         preHTFShift=htfShift;
         // Print("NEW HTF: ",Time[shift]);
         ExtSAR[shift]=iSAR(instrument,enumHTFPeriod,dStep,dMax,htfShift);
        }
     }//newBar
return(rates_total);
}
//+------------------------------------------------------------------+
