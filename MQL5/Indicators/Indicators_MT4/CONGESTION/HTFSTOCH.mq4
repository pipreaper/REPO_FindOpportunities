//+------------------------------------------------------------------+
//| STOCHHTFs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.02"
#property description "HTF is set -> (enumHTFPeriod=PERIOD_M15)"
#property description "Checks HTF and sets Arrow if crosses levels(high/low)"
#property description "Sets ExStatus buffer to 1/-1 if it has crossed and above the considerationHigh / considerationLow level"
#property description "Arrow on HTF is set to zero in other circumstances"
#property indicator_minimum 0
#property indicator_maximum 100
#property strict
#property indicator_separate_window
#include <WaveLibrary.mqh>
#include <status.mqh>
#property  indicator_buffers 5
//+------------------------------------------------------------------+
//| Global variables STOCH                                             |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H1;
extern  int  kPeriod=5;// K line period
extern  int  dPeriod=3;// D line period
extern  int  slowing=3;// slowing
extern  int  method=MODE_SMA;// averaging method
extern  int  price_field=0;// 0 - Low/High or 1 - Close/Close
//extern  int  considerationStochHighLevel=50;
//extern  int  considerationStochLowLevel = 50;
extern  int  lowStochLevel=20;//level cross
extern  int  highStochLevel=80;//level cross
extern  int  maxBarsDraw=5000;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExStatus[];
double ExShortArrow[];
double ExLongArrow[];
double ExtStochSignal[];
double ExtStochMain[];
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
   IndicatorBuffers(5);
   IndicatorShortName("HTFSTOCH"+" "+Symbol()+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_NONE,2,3,clrNONE);
   string statusLabel="Status_"+string(enumHTFPeriod);
   SetIndexLabel(0,statusLabel);
   SetIndexBuffer(0,ExStatus);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(1,233);
   SetIndexLabel(1,"STOCH Long_"+string(enumHTFPeriod));
   SetIndexBuffer(1,ExLongArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(2,234);
   SetIndexLabel(2,"STOCH Short_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExShortArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_LINE,0,1,clrGreen);
   SetIndexArrow(3,233);
   SetIndexLabel(3,"STOCH Main_"+string(enumHTFPeriod));
   SetIndexBuffer(3,ExtStochMain);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,DRAW_LINE,0,1,clrRed);
   SetIndexArrow(4,234);
   SetIndexLabel(4,"STOCH Signal_"+string(enumHTFPeriod));
   SetIndexBuffer(4,ExtStochSignal);
   SetIndexEmptyValue(4,EMPTY_VALUE);

   SetLevelValue(0,0);
   SetLevelValue(0,80);
   SetLevelValue(1,0);
   SetLevelValue(1,20);

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

   ArraySetAsSeries(ExStatus,true);
   ArraySetAsSeries(ExLongArrow,true);
   ArraySetAsSeries(ExShortArrow,true);
   ArraySetAsSeries(ExtStochSignal,true);
   ArraySetAsSeries(ExtStochMain,true);   
   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);
         if(htfShift==phtfShift || (shift>(rates_total-kPeriod-1)))
            continue;
         //enumeration value (0 - MODE_MAIN, 1 - MODE_SIGNAL)            
         double tfStochMain=iStochastic(instrument,enumHTFPeriod,kPeriod,dPeriod,slowing,method,price_field,MODE_MAIN,phtfShift);
         ExtStochMain[shift+1]=tfStochMain;
         double tfStochMainP=iStochastic(instrument,enumHTFPeriod,kPeriod,dPeriod,slowing,method,price_field,MODE_MAIN,phtfShift+1);         
         double tfStochSignal=iStochastic(instrument,enumHTFPeriod,kPeriod,dPeriod,slowing,method,price_field,MODE_SIGNAL,phtfShift);
         ExtStochSignal[shift+1]=tfStochSignal;         
         double tfStochSignalP=iStochastic(instrument,enumHTFPeriod,kPeriod,dPeriod,slowing,method,price_field,MODE_SIGNAL,phtfShift+1);         
      //   double tfPStochMain=iStochastic(instrument,enumHTFPeriod,kPeriod,dPeriod,slowing,method,price_field,MODE_MAIN,phtfShift+1);
      //   double tfPStochSignal=iStochastic(instrument,enumHTFPeriod,kPeriod,dPeriod,slowing,method,price_field,MODE_SIGNAL,phtfShift+1);

         //BUY STOCH turning over at the bottom
         if((tfStochMain>tfStochSignal) && !(tfStochMainP<tfStochSignalP) && (tfStochMain <= lowStochLevel))// && (tfStochMain<lowStochLevel) && (tfStochSignal<lowStochLevel))
           {
            ExStatus[shift+1]=0;
            ExLongArrow[shift+1]=tfStochMain;//+MathAbs(tfSTOCH-tfSTOCHPrev);
           }
         //BUY gone from weak to strong across the 50    
         //else if((tfStochMain>tfStochSignal) && (tfStochSignal>considerationStochHighLevel))
         //  {
         //   ExStatus[shift+1]=0;
         //   ExLongArrow[shift+1]=tfStochMain;//+MathAbs(tfSTOCH-tfSTOCHPrev);
         //  }
         ////SELL STOCH turning over at the top     
         else if(( tfStochMain<tfStochSignal) && !(tfStochMainP>tfStochSignalP) && (tfStochMain >= highStochLevel) )// && (tfStochMain>highStochLevel) && (tfStochSignal>highStochLevel))
           {
            ExStatus[shift+1]=1;
            ExShortArrow[shift+1]=tfStochMain;//+MathAbs(tfSTOCH-tfSTOCHPrev);
           }
         //SELL gone from weak to strong across the 50    
         // else if((tfStochMain<tfStochSignal) && (tfStochSignal<considerationStochHighLevel))
         //   {
         //    ExStatus[shift+1]=0;
         //    ExLongArrow[shift+1]=tfStochMain;//+MathAbs(tfSTOCH-tfSTOCHPrev);
         //   }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
