//+------------------------------------------------------------------+
//| HTFs.mq4                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.03"
#property strict
#property indicator_separate_window
#include <WaveLibrary.mqh>
#include <status.mqh>
#property  indicator_buffers 4
#property description "HTF is set -> (enumHTFPeriod=PERIOD_M15)"
#property description "Checks HTF and sets Golden X or dead X continuance of X's is recorded (ExtStatus)"
#property description "Arrow on HTF set to (1/-1) if new trend is developing from zero status (ExtStatus)- see terminal"
#property description "Arrow on HTF set to (1/-1) if a trend is continuing"
#property description "Arrow on HTF is set to zero in other circumstances"
//+------------------------------------------------------------------+
//| fast and medium EMA periods                                      |
//+------------------------------------------------------------------+
//--EMA periods
//extern string instrument=NULL;
//extern int wtf=NULL;
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_D1;
extern int fEMA=100;
extern int sEMA=100;
extern int shiftsMA=1;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtShortArrow[];
double ExtLongArrow[];
double ExtCloseArrow[];
double ExtStatus[];
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
   IndicatorShortName("HTF2MA"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

//   SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
//   string fastLabel="MA Fast_"+IntegerToString(htfIndex);
//   SetIndexLabel(0,fastLabel);
//   SetIndexBuffer(0,ExtFast);
//   SetIndexEmptyValue(0,EMPTY_VALUE);
//   SetIndexDrawBegin(0,drawBegin);
//
//   SetIndexStyle(1,DRAW_NONE,1,2,clrNONE);
//   string mediumLabel="MA Medium_"+IntegerToString(htfIndex);
//   SetIndexLabel(1,mediumLabel);
//   SetIndexBuffer(1,ExtMedium);
//   SetIndexEmptyValue(1,EMPTY_VALUE);
//   SetIndexDrawBegin(1,drawBegin);
//
//   SetIndexStyle(2,DRAW_NONE,2,3,clrNONE);
//   string slowLabel="MA Slow_"+IntegerToString(htfIndex);
//   SetIndexLabel(2,slowLabel);
//   SetIndexBuffer(2,ExtSlow);
//   SetIndexEmptyValue(2,EMPTY_VALUE);
//   SetIndexDrawBegin(2,drawBegin);

   SetIndexStyle(0,DRAW_ARROW,0,1,clrBlueViolet);
   SetIndexArrow(0,233);
   SetIndexLabel(0,"HTF2MA Long"+string(enumHTFPeriod));
   SetIndexBuffer(0,ExtLongArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(1,234);
   SetIndexLabel(1,"HTF2MA Short"+string(enumHTFPeriod));
   SetIndexBuffer(1,ExtShortArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrOrangeRed);
   SetIndexArrow(2,181);
   SetIndexLabel(2,"HTF2MA Close_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExtCloseArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
//SetIndexArrow(2,234);
   SetIndexLabel(3,"HTF2MA Status"+string(enumHTFPeriod));
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

//ArraySetAsSeries(ExtFast,true);
//ArraySetAsSeries(ExtMedium,true);
//ArraySetAsSeries(ExtSlow,true);
   ArraySetAsSeries(ExtLongArrow,true);
   ArraySetAsSeries(ExtShortArrow,true);
   ArraySetAsSeries(ExtCloseArrow,true);
   ArraySetAsSeries(ExtStatus,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);//new date
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);//old date
         if(htfShift!=phtfShift)
           {
            //   Print(Time[0]," ",shift," HTF: ",htfShift," Prev HTF: ",phtfShift); 

            double tff=iMA(instrument,enumHTFPeriod,fEMA,0,MODE_EMA,PRICE_CLOSE,phtfShift);

            //    double tffp=iMA(instrument,enumHTFPeriod,fEMA,0,MODE_EMA,PRICE_CLOSE,phtfShift);
            //   ExtMedium[shift]=tfm;
            double tfs=iMA(instrument,enumHTFPeriod,sEMA,shiftsMA,MODE_EMA,PRICE_CLOSE,phtfShift);

            // Print("period: ",enumHTFPeriod," shift ",shift," phtfShift ",phtfShift," tff ",tff," tfs ",tfs);
            //        double tfsp=iMA(instrument,enumHTFPeriod,sEMA,0,MODE_EMA,PRICE_CLOSE,phtfShift+1);
            // ExtSlow[shift]=tfs;
            //      double  c = close[shift];

            //if (shift <2)
            //Print("tff ",tff," tfm,",tfm," tfs ",tfs);

            if(tff>tfs)// && (low[shift] > tff))//peg closes completely above fast SMA )// && (!(tffp>tfmp) || !(tfmp>tfsp) || !((tffp>tfmp) && (tfmp>tfsp))))
              {
               ExtLongArrow[shift+1]=high[shift+1];//-MathAbs(ExSLOW[shift]-ExMEDIUM[shift]);
               ExtStatus[shift+1]=0;
              }
            else if(tff<tfs)// && (high[shift] < tff))//peg closes completely below fast SMA
              {
               ExtShortArrow[shift+1]=low[shift+1];//+MathAbs(ExSLOW[shift]-ExMEDIUM[shift]);           
               ExtStatus[shift+1]=1;
              }
            else
              {
               ExtCloseArrow[shift+1]=EMPTY_VALUE;//high[shift+1];//+MathAbs(ExSLOW[shift]-ExMEDIUM[shift]);             
               ExtStatus[shift+1]=2;
              }
           }
         //if((phtfShift!=0) && (shift<(rates_total-sEMA-1)))
         //  {
         //  // same day
         //   ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
         //   ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
         //   ExtCloseArrow[shift+1]=ExtCloseArrow[shift+2];
         //   ExtStatus[shift+1]=ExtStatus[shift+2];
         //   continue;
         //  }

        }//for
     }//new bar
   return(rates_total);
  }//
//+------------------------------------------------------------------+
