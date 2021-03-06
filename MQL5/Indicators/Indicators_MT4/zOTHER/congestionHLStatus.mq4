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
#property  indicator_buffers 6
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
extern congestionType typeOfCongestion=ALL;
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=1.5;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=2.0; // Bands Deviations
extern int    maxBarsDraw=50000;
extern color  clrArrow=clrWhite;//color of congestion arrows
extern color  clrRectangle=clrGray;// color of congestion zone
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double ExtEndPoint[];//-- ExtEndPoint  (maxCongestion high)
double ExtStartPoint[];//-- ExtStartPoint (minCongestion low)
double ExtEndCongVal[];
double ExtStartCongVal[];
double ExtSetUpStatus[];
double ExtStop[];
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
   IndicatorShortName("Congestion Status: "+string(typeOfCongestion));
   IndicatorBuffers(6);
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

   SetIndexStyle(2,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(2,158);
   SetIndexLabel(2,"start status");
   SetIndexBuffer(2,ExtStartCongVal);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexDrawBegin(2,drawBegin);

   SetIndexStyle(3,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(3,160);
   SetIndexLabel(3,"end status");
   SetIndexBuffer(3,ExtEndCongVal);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexDrawBegin(3,drawBegin);

   SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
   SetIndexArrow(4,160);
   SetIndexLabel(4,"SETUP status");
   SetIndexBuffer(4,ExtSetUpStatus);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexDrawBegin(4,drawBegin);

   SetIndexStyle(5,DRAW_ARROW,0,3,clrGoldenrod);
   SetIndexArrow(5,160);
   SetIndexLabel(5,"stop");
   SetIndexBuffer(5,ExtStop);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexDrawBegin(5,drawBegin);

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
   ArraySetAsSeries(ExtEndCongVal,true);
   ArraySetAsSeries(ExtStartCongVal,true);
   ArraySetAsSeries(ExtSetUpStatus,true);
   ArraySetAsSeries(ExtStop,true);

//Sort internal buffers
//int size=ArraySize(ExtEndPoint);
//ArrayResize(ExtStartCongVal,size);
//ArrayResize(ExtEndCongVal,size);
//ArrayFill(ExtStartCongVal,0,size-1,EMPTY_VALUE);
//ArrayFill(ExtEndCongVal,0,size-1,EMPTY_VALUE);
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
            ExtSetUpStatus[shift+1]=EMPTY_VALUE;
            ExtStop[shift+1]=EMPTY_VALUE;
            maxCongestion=MathMax(maxCongestion,high[shift+1]);
            minCongestion=MathMin(minCongestion,low[shift+1]);
            ExtStartPoint[shift+1]=minCongestion;
            startShift=iTime(Symbol(),Period(),shift+1);
            isCongested=true;
           }
         //-- NEW END           
         else if((isCongested) && (negEnd<0) && (posEnd!=EMPTY_VALUE))
           {
            ExtSetUpStatus[shift+2]=EMPTY_VALUE;
            ExtEndCongVal[shift+2]=maxCongestion;
            ExtStartCongVal[shift+2]=ExtStartPoint[candleIndex];
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
         else
           {
            //Update Indicators
            //BUY
            ExtEndCongVal[shift+1]=ExtEndCongVal[shift+2];
            ExtStartCongVal[shift+1]=ExtStartCongVal[shift+2];

            //BUY
            if( (low[shift+1]<ExtStartCongVal[shift+1]) && ((close[shift+1]>ExtStartCongVal[shift+1]) && (ExtSetUpStatus[shift+2] != 1 ) ))
              {
               ExtSetUpStatus[shift+1]=2;
               ExtStop[shift+1]=low[shift+1];          
              }            
            else if( (low[shift+1]<ExtStartCongVal[shift+1]) && (close[shift+1]>ExtStartCongVal[shift+1]) && (ExtSetUpStatus[shift+2] == 1 ) )
              {
               ExtSetUpStatus[shift+1]=2;
               ExtStop[shift+1]=MathMin(ExtStop[shift+2],low[shift+1]);         
              }
            else if(low[shift+1]<ExtStartCongVal[shift+1])
              {
               ExtSetUpStatus[shift+1]=1;
               ExtStop[shift+1]=MathMin(ExtStop[shift+2],low[shift+1]);
              }
              
            //SELL
            else if( (high[shift+1]>ExtEndCongVal[shift+1]) && (close[shift+1]<ExtEndCongVal[shift+1]) && (ExtSetUpStatus[shift+2] != 3 ) )
              {
               ExtSetUpStatus[shift+1]=4;
               ExtStop[shift+1]=high[shift+1];          
              }            
            else if( (high[shift+1]>ExtEndCongVal[shift+1]) && (close[shift+1]<ExtEndCongVal[shift+1]) && (ExtSetUpStatus[shift+2] == 3))
              {
               if(ExtStop[shift+1]==EMPTY_VALUE)
                  ExtStop[shift+1]=NULL;
               ExtSetUpStatus[shift+1]=4;
               ExtStop[shift+1]=MathMax(ExtStop[shift+2],high[shift+1]);         
              }
            else if(high[shift+1]>ExtEndCongVal[shift+1])
              {
               ExtSetUpStatus[shift+1]=3;
               if(ExtStop[shift+2]==EMPTY_VALUE)
                  ExtStop[shift+2]=NULL;
               ExtStop[shift+1]=MathMax(ExtStop[shift+2],high[shift+1]);
              }
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
