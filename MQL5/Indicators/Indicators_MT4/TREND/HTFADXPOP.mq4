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
#property description "At enumHTFPeriod if above true then pre wtf Set"

#property indicator_separate_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 5
//+------------------------------------------------------------------+
//| Global variablesADX                                              |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H4;//enumHTFPeriod
extern int adxPeriod=14;//adx Period
extern int priceField=0;//Close of Bar
extern int maxBarsDraw=5000;//Max indicator draw
int htfIndex=findIndexPeriod(enumHTFPeriod);
int wtfIndex= NULL;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int debug=-1;
double IntADX[];
double ExtDIPlus[];
double ExtDIMinus[];
double ExtShortArrow[];
double ExtLongArrow[];
double ExtCloseArrow[];
string instrument=Symbol();
int wtf=Period();
int shift=NULL;
int limit= NULL;
int drawBegin=maxBarsDraw;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()>enumHTFPeriod)
     {
      Print(enumHTFPeriod);
      if(!(enumHTFPeriod==0))
        {
         s("***** enumHTFPeriod: "+string(enumHTFPeriod)+" Indicator only shows higher timeframes of Period(): "+string(Period()),true);
         s("***** SETTING PERIOD TO DEFAULT CHART PERIOD: "+string(Period()),true);
        }
      else
         Print("used current");
      enumHTFPeriod=ENUM_TIMEFRAMES(Period());
      htfIndex=findIndexPeriod(enumHTFPeriod);
     }
   color clrLine=clrNONE;
   int bars=Bars(Symbol(),wtf);
   if(drawBegin>=(bars-adxPeriod-1))
      drawBegin=0;

   IndicatorBuffers(5);
   IndicatorShortName("HTFADXPOP "+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_NONE,STYLE_DASH,1,clrNONE);
   string adxLabel="A DIPlus_"+string(enumHTFPeriod);
   SetIndexLabel(0,adxLabel);
   SetIndexBuffer(0,ExtDIPlus);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(1,DRAW_NONE,STYLE_DOT,1,clrNONE);
   adxLabel="A DIMinus_"+string(enumHTFPeriod);
   SetIndexLabel(1,adxLabel);
   SetIndexBuffer(1,ExtDIMinus);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexDrawBegin(1,drawBegin);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(2,233);
   SetIndexLabel(2,"A ADX Long_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExtLongArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexDrawBegin(2,drawBegin);

   SetIndexStyle(3,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(3,234);
   SetIndexLabel(3,"A ADX Short_"+string(enumHTFPeriod));
   SetIndexBuffer(3,ExtShortArrow);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexDrawBegin(3,drawBegin);

   SetIndexStyle(4,DRAW_ARROW,0,1,clrOrangeRed);
   SetIndexArrow(4,181);
   SetIndexLabel(4,"A ADX Close_"+string(enumHTFPeriod));
   SetIndexBuffer(4,ExtCloseArrow);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexDrawBegin(4,drawBegin);

//SetIndexEmptyValue(3,EMPTY_VALUE);

//SetIndexStyle(3,DRAW_NONE,0,2,clrNONE);
//string adxLabel="A ADX_"+string(enumHTFPeriod);
//SetIndexLabel(3,adxLabel);
//SetIndexBuffer(3,IntADX);
//SetIndexEmptyValue(3,EMPTY_VALUE);
//SetIndexDrawBegin(3,drawBegin);
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

   ArraySetAsSeries(ExtDIPlus,true);
   ArraySetAsSeries(ExtDIMinus,true);
   ArraySetAsSeries(ExtLongArrow,true);
   ArraySetAsSeries(ExtShortArrow,true);
   ArraySetAsSeries(ExtCloseArrow,true);


   ArrayResize(IntADX,rates_total);
   ArrayFill(IntADX,0,rates_total,EMPTY_VALUE);
   ArraySetAsSeries(IntADX,true);   

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);
         if((htfShift==phtfShift) && (shift<(rates_total-2)))
           {
            ExtDIMinus[shift+1]=ExtDIMinus[shift+2];
            ExtDIPlus[shift+1]=ExtDIPlus[shift+2];
            ExtLongArrow[shift+1]=ExtLongArrow[shift+2];
            ExtShortArrow[shift+1]=ExtShortArrow[shift+2];
            ExtCloseArrow[shift+1]=ExtCloseArrow[shift+2];
            continue;
           }
         if(shift>(rates_total-adxPeriod-1))
            continue;

         double tfADX=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_MAIN,phtfShift);
         double tfDIPlus=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_PLUSDI,phtfShift);
         double tfDIMinus=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_MINUSDI,phtfShift);
         double tfADXPrevious=iADX(instrument,enumHTFPeriod,adxPeriod,priceField,MODE_MAIN,phtfShift+1);

         // if(shift==1)
         //   Print(__FUNCTION__," ",Time[0]," Shift, +, -, ADX, P ",shift," ",tfDIPlus," ",tfDIMinus," ",tfADX," ",tfADXPrevious);

         ExtDIPlus[shift]=tfDIPlus;  // set and show line for middle MA 
         ExtDIMinus[shift]=tfDIMinus;  // set and show line for middle MA 
         IntADX[shift+1]=tfADX;  // set and show line for middle MA 

         if((tfDIPlus>tfDIMinus) && (tfADX>20))
            ExtLongArrow[shift+1]=tfADX-MathAbs(tfADX-tfDIPlus);
         else if((tfDIMinus>tfDIPlus) && (tfADX>20))
            ExtShortArrow[shift+1]=tfADX-MathAbs(tfADX-tfDIMinus);
         else if(tfADX<=20)// || () || ())tfADX < tfADXPrevious || (
            ExtCloseArrow[shift+1]=tfADX-MathAbs(tfADX-tfDIPlus);
        }//for
     }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
