//+------------------------------------------------------------------+
//| congestion.mq4                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.04"
#property description "Does not record candle 0 (far right), for boxes. Draws boxes on analysis of start and finish of SqueezeBreak congestion zones." 
#property description "Arrays are set as series:  true"
#property description "Main body iteration from rates_total to candle zero(0)"
#property description "Candle 0 (where we update start and end of congestion zones) => shift+1 is candle 1 shift+2 is candle 2 "
#property strict
#property indicator_chart_window
#include <WaveLibrary.mqh>
#property  indicator_buffers 2
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
extern congestionType typeOfCongestion  = ALL;
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=1.5;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=2.0; // Bands Deviations
extern int    maxBarsDraw=5000;
extern color  clrArrow=clrWhite;//color of congestion arrows
extern color  clrRectangle=clrGray;// color of congestion zone
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtEndPoint[];//-- ExtEndPoint  (maxCongestion high)
double ExtStartPoint[];//-- ExtStartPoint (minCongestion low)
bool isCongested=false;
datetime startShift;//Date of the start of Congestion
int candleIndex=-1;
double maxCongestion=0,minCongestion=INF;
//-- rectangle
long chartID=0;
string rectangleName="rectangle";
int subWindow=0;
int rectangleWidth=1;
const bool  rectangleFill=false;
ENUM_LINE_STYLE rectangleStyle=STYLE_SOLID;
const bool  rectangleBack=true;
const bool  rectangleSelection=false;
const bool  rectangleHidden=false;
const long  rectangleZOrder=10;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName("Congestion: "+string(typeOfCongestion));
   IndicatorBuffers(2);
   string textName1="rectangle";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {//Tidy old congestion
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,9)==textName1)
        {
         ObjectDelete(ObjectName(i));
        }
     }
   int drawBegin=0;
   if(Bars>maxBarsDraw)
      drawBegin=Bars-maxBarsDraw;
   else
      drawBegin=Keltner_Period+Boll_Period;
   IndicatorBuffers(2);
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
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   double posStart=-1,negStart=-1,posEnd=-1,negEnd=-1;
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ExtEndPoint,true);
   ArraySetAsSeries(ExtStartPoint,true);

   int limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
   bool tripped=false;
//-- shift is candle 0 (where we update) => shift+1 is candle 1 shift+2 is candle 2   
   for(int shift=limit-2; shift>=0; shift--)//start from 1 or if initialisation start or 1
     {
      if(isNewBar)
        {
         posStart=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,shift+2);
         negStart=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,1,shift+1);
         posEnd=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,shift+1);
         negEnd=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,1,shift+2);
         //-- NEW START          
         if((!isCongested) && (posStart!=EMPTY_VALUE) && (negStart<0))
           {
            maxCongestion=MathMax(maxCongestion,high[shift+1]);
            minCongestion=MathMin(minCongestion,low[shift+1]);
            ExtStartPoint[shift+1]=minCongestion;
            startShift=iTime(Symbol(),Period(),shift+1);
            isCongested=true;
           }
         //-- NEW END           
         else if((isCongested) && (negEnd<0) && (posEnd!=EMPTY_VALUE))
           {
            ExtEndPoint[shift+2]=maxCongestion;
            maxCongestion=0;
            minCongestion=INF;
            isCongested=false;
            //draw it
            string rName=rectangleName+string(time[shift+1]);
            candleIndex=iBarShift(Symbol(),Period(),startShift,true);
            bool isDrawn=RectangleCreate(chartID=0,rName,subWindow,time[candleIndex],ExtStartPoint[candleIndex],time[shift+2],ExtEndPoint[shift+2],clrRectangle,rectangleStyle,rectangleWidth,rectangleFill,rectangleBack,rectangleSelection,rectangleHidden,rectangleZOrder);
           }
         //-- UPDATE THE RANGE OF THE CONSGESTION INLINE WITH NEW DATA
         if(isCongested)
           {
            maxCongestion=MathMax(maxCongestion,high[shift+1]);
            minCongestion=MathMin(minCongestion,low[shift+1]);
            candleIndex=iBarShift(Symbol(),Period(),startShift,true);
            ExtStartPoint[candleIndex]=minCongestion;
           }
        }//new bar
      posStart=-1;negStart=-1;posEnd=-1;negEnd=-1;
     }//for
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string textName1="rectangle";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {//Tidy old congestion
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,9)==textName1)
        {
         ObjectDelete(ObjectName(i));
        }
     }
  }
//+------------------------------------------------------------------+
