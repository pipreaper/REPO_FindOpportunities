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
#property  indicator_buffers 2
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
//SQUEEZE AND KELTNER
extern bool drawLines=false;
extern ENUM_TIMEFRAMES enumHTFPeriod=0;
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=3;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=3.0; // Bands Deviations
extern int    maxBarsDraw=50000;
extern color  clrArrow=clrWhite;//color of congestion arrows
extern color  clrRectangle=clrGray;// color of congestion zone     
extern congestionType typeOfCongestion=INSIDE;
extern double lowerPercentile=5;//low percent
extern double lowerMiddlePercentile=20;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=80;//upper Middle Percentile
extern double upperPercentile=95;//upper percentile
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtEndPoint[];//-- ExtEndPoint  (maxCongestion high)
double ExtStartPoint[];//-- ExtStartPoint (minCongestion low)

                       //-- rectangle
long chartID=0;
string rectangleName="rectangle";
int subWindow=0;
int rectangleWidth=1;
const bool  rectangleFill=true;
ENUM_LINE_STYLE rectangleStyle=STYLE_SOLID;
const bool  rectangleSelection=false;
const bool  rectangleHidden=false;
const long  rectangleZOrder=10;//Z-index
const bool  rectangleBack=true;
//-- VARIOUS
bool isCongested=false;
datetime startShift;//Date of the start of Congestion
int candleIndex=-1;
double maxCongestion=0,minCongestion=INF;
int htfIndex=findIndexPeriod(enumHTFPeriod);
int wtfIndex= NULL;
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
   if(Period()== tfEnumFull[ArraySize(tfEnumFull)-1])
     {
      Print("Indicator user higher time frames: there are none! htfIndex "+string(htfIndex)+    " enumHTFPeriod "+string(enumHTFPeriod));
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
   color clrLine=clrNONE;
   int bars=Bars(Symbol(),wtf);
   if(drawBegin>=(bars-2-1))
      drawBegin=0;

   IndicatorBuffers(2);
   IndicatorShortName("Simple Congestion Close Values"+" "+instrument+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   SetIndexStyle(0,DRAW_ARROW,0,1,clrArrow);
   SetIndexArrow(0,196);
   SetIndexLabel(0,"Bottom Left");
   SetIndexBuffer(0,ExtStartPoint);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(1,DRAW_ARROW,0,1,clrArrow);
   SetIndexArrow(1,202);
   SetIndexLabel(1,"Top Right");
   SetIndexBuffer(1,ExtEndPoint);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexDrawBegin(1,drawBegin);
   
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

   bool direction=true;
   ArraySetAsSeries(time,direction);
   ArraySetAsSeries(close,direction);
   ArraySetAsSeries(high,direction);
   ArraySetAsSeries(low,direction);
   ArraySetAsSeries(ExtEndPoint,direction);
   ArraySetAsSeries(ExtStartPoint,direction);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-3; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,time[shift+1],false);
         if((htfShift==phtfShift) && (shift<(rates_total-2)))
            continue;
         if(shift>(rates_total-2))
            continue;
         //double SBTrend=iCustom(instrument,enumHTFPeriod,"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,phtfShift);
         double trend=  iCustom(instrument,enumHTFPeriod,"getLevelSQU",drawLines,typeOfCongestion,lowerPercentile,lowerMiddlePercentile,middlePercentile,upperMiddlePercentile,upperPercentile,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,phtfShift);//rates_total-(shift+1));
         double bin  =  iCustom(instrument,enumHTFPeriod,"getLevelSQU",drawLines,typeOfCongestion,lowerPercentile,lowerMiddlePercentile,middlePercentile,upperMiddlePercentile,upperPercentile,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,1,phtfShift);//rates_total-(shift+1));
                                                                                                                                                                                                                                                                                                                                 //Print(wtf," ",SBTrend," ",trend);                                                                                                                                                                                                                                                                                                                                //     if(bin>=upperMiddlePercentile)
         //       Print("TIME: ",time[shift+1]," close: ",close[shift+1]," trend: ",trend," bin: ",bin);
         //-- NEW START          
         if((!isCongested) && (bin>=upperMiddlePercentile))
           {
            //ExtSetUpStatus[shift+1]=EMPTY_VALUE;
            // ExtStop[shift+1]=EMPTY_VALUE;
            maxCongestion=MathMax(maxCongestion,close[shift+1]);
            minCongestion=MathMin(minCongestion,close[shift+1]);
            ExtStartPoint[shift+1]=minCongestion;
            startShift=iTime(instrument,wtf,shift+1);
            isCongested=true;
           }
         //-- NEW END           
         else if((isCongested) && (bin<upperMiddlePercentile))
           {
            // ExtSetUpStatus[shift+2]=EMPTY_VALUE;
            // ExtEndCongVal[shift+2]=maxCongestion;
            //  ExtStartCongVal[shift+2]=ExtStartPoint[candleIndex];
            ExtEndPoint[shift+2]=maxCongestion;
            maxCongestion=0;
            minCongestion=INF;
            isCongested=false;
            //draw it
            string rName=string(wtf)+string(enumHTFPeriod)+rectangleName+string(time[shift+1]);
            candleIndex=iBarShift(instrument,wtf,startShift,true);
            bool isDrawn=RectangleCreate(chartID=0,rName,subWindow,time[candleIndex],ExtStartPoint[candleIndex],time[shift+2],ExtEndPoint[shift+2],clrRectangle,rectangleStyle,rectangleWidth,rectangleFill,rectangleBack,rectangleSelection,rectangleHidden,rectangleZOrder);
           }
         //-- UPDATE THE RANGE OF THE CONSGESTION INLINE WITH NEW DATA
         if(isCongested)
           {
            maxCongestion=MathMax(maxCongestion,close[shift+1]);
            minCongestion=MathMin(minCongestion,close[shift+1]);
            candleIndex=iBarShift(instrument,wtf,startShift,true);
            ExtStartPoint[candleIndex]=minCongestion;
           }
         //if(shift>(rates_total-2-1))
         //   continue;
        }//for
      ChartRedraw(ChartID());
      Sleep(200);
     }//new bar
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
  //    string nm=ObjectName(i);
  //    Print("Deinit ",nm);
      ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+
