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

#property indicator_chart_window
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#property  indicator_buffers 2
//+------------------------------------------------------------------+
//| Global variablesADX                                              |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_M15;//HTF for extremes
                                               //extern int tbOffset=50;// How many candles to check
extern int minPeakApart=3;//min candles of top formation
//extern int maxBarsTB=25;//max width in a top/bottom
extern int lowHighOffset=20;//min up/down candles to form top/bottom
extern double retrace=50;//percent retrace of wicks
extern bool bMajor=true;//major tops
extern bool bInter= true;//intermediae tops
extern bool bMinor= true;//minor tops
extern bool bExtreme=true;//include large wicks
int htfIndex=findIndexPeriod(enumHTFPeriod);
int wtfIndex= NULL;
double ExtState[];
double ExtShortArrow[];
double ExtLongArrow[];
double ExtStartTopArrow[];
string instrument=Symbol();
int wtf=Period();
int shift=NULL;
int limit= NULL;
color clrLine=clrNONE;

double top=NULL;
double bottom=NULL;
double tbState=NULL;
double TBE[3];
datetime startTime=NULL;
color  fontColorTop=clrGreen;
color  fontColorBottom=clrRed;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()==tfEnumFull[ArraySize(tfEnumFull)-1])
     {
      Print("Indicator user higher time frames: there are none! htfIndex "+string(htfIndex)+" enumHTFPeriod "+string(enumHTFPeriod));
      return(INIT_FAILED);
     }
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
   IndicatorBuffers(2);
   IndicatorShortName("HTFWM_"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_ARROW,0,3,clrBlueViolet);
   SetIndexArrow(0,233);
   SetIndexLabel(0,"WM_END _LONG"+string(enumHTFPeriod));
   SetIndexBuffer(0,ExtLongArrow);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,0,3,clrRed);
   SetIndexArrow(1,234);
   SetIndexLabel(1,"WM_END SHORT"+string(enumHTFPeriod));
   SetIndexBuffer(1,ExtShortArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);

//   SetIndexStyle(2,DRAW_NONE,0,2,clrRed);
//   SetIndexArrow(2,86);
//   SetIndexLabel(2,"WM_START_LONG"+string(enumHTFPeriod));
//   SetIndexBuffer(2,ExtStartTopArrow);
//   SetIndexEmptyValue(2,EMPTY_VALUE);
//
//   SetIndexStyle(3,DRAW_ARROW,0,1,clrLine);
//   SetIndexArrow(3,86);
//   SetIndexLabel(3,"WM_STATE"+string(enumHTFPeriod));
//   SetIndexBuffer(3,ExtState);
//   SetIndexEmptyValue(3,EMPTY_VALUE);
   for(int x=0;(x<ArraySize(TBE));x++)
      TBE[x]=EMPTY_VALUE;
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

   ArraySetAsSeries(ExtState,true);
   ArraySetAsSeries(ExtLongArrow,true);
   ArraySetAsSeries(ExtShortArrow,true);
   ArraySetAsSeries(ExtStartTopArrow,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,time[shift+1],false);
         if(shift>(rates_total-50))
            continue;
         //potential new EXTREME OR MAX MIN VALUE TO WORK ON
         if(htfShift!=phtfShift)
           {
            top=iCustom(instrument,enumHTFPeriod,"OHLC_EX",lowHighOffset,retrace,bMajor,bInter,bMinor,bExtreme,0,phtfShift);
            bottom=iCustom(instrument,enumHTFPeriod,"OHLC_EX",lowHighOffset,retrace,bMajor,bInter,bMinor,bExtreme,1,phtfShift);
            //tbState=iCustom(instrument,enumHTFPeriod,"EXTREME_OHLC",lowHighOffset,retrace,bMajor,bInter,bMinor,bExtreme,4,phtfShift);

            //Only want to update if have a major change
            if(top!=EMPTY_VALUE)
              {
               startTime=time[shift+1];
               TBE[0]=top;TBE[1]=EMPTY_VALUE;TBE[2]=tbState;
              }
            else if(bottom!=EMPTY_VALUE)
              {
               startTime=time[shift+1];
               TBE[0]=EMPTY_VALUE;TBE[1]=bottom;TBE[2]=tbState;
              }
           }
         if((TBE[0]!=EMPTY_VALUE))
           {
            if(checkW(shift,high,low))
              {
              Print("TOP"+string(shift));
               ExtShortArrow[shift+1]=high[shift+1];
               drawTradeLine(TBE[0],high[shift+1],startTime,time[shift+1],true);
               TBE[0]=EMPTY_VALUE;
               startTime=NULL;
              }
           }
         else if((TBE[1]!=EMPTY_VALUE))
           {
            if(checkW(shift,high,low))
              {
              Print("Bottom"+string(shift));              
               ExtLongArrow[shift+1]=low[shift+1];
               drawTradeLine(TBE[1],low[shift+1],startTime,time[shift+1],false);
               TBE[1]=EMPTY_VALUE;
               startTime=NULL;
              }
           }
        }//for
     }//new bar
   ChartRedraw(ChartID());
   Sleep(200);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| checkW                                                        |
//+------------------------------------------------------------------+
bool checkW(int Shift,const double &h[],const double &l[])
  {
   int indStart=iBarShift(instrument,wtf,startTime,true);
   if((indStart-(Shift+1))<minPeakApart)
      return false;
   double atr=iATR(instrument,wtf,14,Shift+1);
//is it top or bottom
   if(TBE[0]!=EMPTY_VALUE)
     {
      if((h[Shift+1]>TBE[0]))// || (indStart-(Shift+1))>maxBarsTB)
        {
         TBE[0]=EMPTY_VALUE;
         return false;
        }
      if((h[Shift+1]>(TBE[0]-atr)) && (h[Shift+1]<TBE[0]))
        {
         double   LTFTop=iCustom(instrument,wtf,"OHLC_EX",10,retrace,bMajor,bInter,bMinor,bExtreme,0,Shift+1);
         double lowV=l[iLowest(instrument,wtf,MODE_LOW,indStart-(Shift+1),Shift+1)];         
         if(LTFTop!=EMPTY_VALUE && (h[indStart]-lowV) > (atr))
            return true;
        }
     }
   else if(TBE[1]!=EMPTY_VALUE)
     {
      if((l[Shift+1]<TBE[1]))// || (indStart-(Shift+1))>maxBarsTB)
        {
         TBE[1]=EMPTY_VALUE;
         return false;
        }
      if((l[Shift+1]<(TBE[1]+atr)) && (l[Shift+1]>TBE[1]))
        {
         double  LTFBottom=iCustom(instrument,wtf,"OHLC_EX",10,retrace,bMajor,bInter,bMinor,bExtreme,1,Shift+1);
         double highV=h[iHighest(instrument,wtf,MODE_HIGH,indStart-(Shift+1),Shift+1)];           
         if(LTFBottom!=EMPTY_VALUE && (highV-l[indStart]) > (atr))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| drawTradeLine                                                    |
//+------------------------------------------------------------------+
void drawTradeLine(double openPrice,double closePrice,datetime openTime,datetime closeTime,bool ISProfit)
  {
   string tName="tWM_"+string(closeTime);
   if(ObjectFind(ChartID(),tName)<0)
     {
      if(!ObjectCreate(ChartID(),tName,OBJ_TREND,0,openTime,openPrice,closeTime,closePrice))
         Print(__FUNCTION__,": failed to create a trend Line! Error = ",ErrorDescription(GetLastError())+" closeTime "+string(closeTime)+" closePrice "+string(closePrice));
      else
        {
         color clr=clrNONE;
         if(ISProfit==true)
            clr=fontColorTop;
         else
            clr=fontColorBottom;
         ObjectSet(tName,OBJPROP_COLOR,clr);
         ObjectSet(tName,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet(tName,OBJPROP_WIDTH,2);
         ObjectSet(tName,OBJPROP_RAY_RIGHT,false);
        }
     }
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string textName1="tWM_";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,4)==textName1)
         ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+
