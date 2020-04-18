//+------------------------------------------------------------------+
//| HTFADXs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      ""
#property version   "1.07"
#property strict
#property description "Three external buffers of interest"
#property description "ExtLongArrow: trending UP     -> HTF: (ADX > ADXPrev) and (DMI+ > DMIPrev+) and (DMI+ > DMI-) and (ADX and >limit(25))"
#property description "ExtDownArrow: trending DOWN   -> HTF: (ADX > ADXPrev) and (DMI- > DMIPrev-) and (DMI- > DMI+) and (ADX and >limit(25))"
#property description "ExtCloseArrow: ADX hooked over -> falling HTF: ADX < ADXPrev"
#property description "At enumHTFPeriod if above true then pre wtfIndex Set"

#property indicator_separate_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 4
//+------------------------------------------------------------------+
//| Global variablesADX                                              |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H4;//enumHTFPeriod
extern double adxThreshold=35;
extern int adxPeriod=5;//adx Period
extern int priceField=0;//Close of Bar

                        //int wtfIndex= NULL;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

double ExtShortArrow[];
double ExtLongArrow[];
double ExtCloseArrow[];
double ExtADX[];

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
   IndicatorBuffers(4);
   IndicatorShortName("HTFADX"+" "+instrument+" "+string(enumHTFPeriod));

   SetIndexStyle(0,DRAW_ARROW,0,1,clrLine);
   SetIndexArrow(0,233);
   SetIndexLabel(0,"A ADX Long_"+string(enumHTFPeriod));
   SetIndexBuffer(0,ExtLongArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);
//  SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(1,DRAW_ARROW,0,1,clrLine);
   SetIndexArrow(1,234);
   SetIndexLabel(1,"A ADX Short_"+string(enumHTFPeriod));
   SetIndexBuffer(1,ExtShortArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
// SetIndexDrawBegin(1,drawBegin);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrLine);
   SetIndexArrow(2,181);
   SetIndexLabel(2,"A ADX Close_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExtCloseArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_SECTION,0,1,clrLine);
   SetIndexArrow(3,181);
   SetIndexLabel(3,"A ADX_"+string(enumHTFPeriod));
   SetIndexBuffer(3,ExtADX);
   SetIndexEmptyValue(3,EMPTY_VALUE);

//SetIndexEmptyValue(3,EMPTY_VALUE);

//SetIndexStyle(3,DRAW_NONE,0,2,clrNONE);
//string adxLabel="A ADX_"+string(enumHTFPeriod);
//SetIndexLabel(3,adxLabel);
//SetIndexBuffer(3,IntADX);
//SetIndexEmptyValue(3,EMPTY_VALUE);
//SetIndexDrawBegin(3,drawBegin);
   SetLevelValue(0,adxThreshold);
   SetLevelStyle(STYLE_DASH,1,clrLine);
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

//  ArraySetAsSeries(ExtDIPlus,true);
//  ArraySetAsSeries(ExtDIMinus,true);
//   ArraySetAsSeries(IntADX,true);
   ArraySetAsSeries(ExtLongArrow,true);
   ArraySetAsSeries(ExtShortArrow,true);
   ArraySetAsSeries(ExtCloseArrow,true);
   ArraySetAsSeries(ExtADX,true);

//int tsSize = rates_total;
//ArrayResize(IntADX,rates_total);
//ArrayFill(IntADX,0,rates_total,EMPTY_VALUE);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
     {
      if(isNewBar)// ***** the chart tf the indicator is applied to
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);

         //if((htfShift==phtfShift) && (shift<(rates_total-2)))
         //  {
         //   //   if(shift==1)
         //   //      Print("limit: ",limit," Time[0] ",Time[0]," shift ",shift," SAME OR ZERO HTF: ",htfShift," Prev HTF: ",phtfShift);
         //   ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
         //   ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
         //   ExtCloseArrow[shift+1]=ExtCloseArrow[shift+2];
         //   continue;
         //  }

         if(shift>(rates_total-adxPeriod-1))
            continue;
         if(htfShift!=phtfShift)
           {
            double tfDIPlus=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_PLUSDI,phtfShift);
            double tfDIMinus=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_MINUSDI,phtfShift);
            double tfADX=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_MAIN,phtfShift);
//Print(" + ",tfDIPlus," - ",tfDIMinus);
            ExtADX[shift+1]=tfADX;  // set and show line for middle MA 

            if((tfDIPlus>=tfDIMinus) && (tfADX>adxThreshold))
               ExtLongArrow[shift+1]=tfADX;
            else if((tfDIMinus>tfDIPlus) && (tfADX>adxThreshold))//((tfADX>tfADXPrevious)
            ExtShortArrow[shift+1]=tfADX;//-MathAbs(tfADX-tfDIMinus);
            else //if(tfADX<tfADXPrevious)
            ExtCloseArrow[shift+1]=tfADX;//-MathAbs(tfADX-tfDIPlus);
           // Print("shift ",shift," ExtLongArrow[shift+1] ",ExtLongArrow[shift+1]," ExtShortArrow[shift+1] ",ExtShortArrow[shift+1]);
            
           }
        }//new bar
     }//for
//if(limit<=0)
//  {
//   double tfADX=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_MAIN,0);
//   ExtADX[shift+1]=tfADX;
//  }
   return(rates_total);
  }
//+------------------------------------------------------------------+
