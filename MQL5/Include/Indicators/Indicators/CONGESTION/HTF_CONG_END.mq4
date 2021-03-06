//+------------------------------------------------------------------+
//|HTF_CONG.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description" Find S/R on HTF according to keltner and bollinger squeeze"
#property description" HTF_CONG_END: Lines show Trend Ending Point"
#property description" HTF_CONG: Lines show Congestion Ending Point"
#property description" Show high Probability S/R according to extreme deviations:"
#property description" ... upperMiddlePercentile = 98%"
// according to keltner and bollinger squeeze
// "HTF_CONG is master"
// "if edit HTF_CONG also save as HTF_CONG_END and "
// description "set congVersion=END in the saved module"
#include <WaveLibrary.mqh>//additional extern parameter
#include <status.mqh>
#include<supportResistance.mqh>
#property  indicator_buffers 5
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
//SQUEEZE AND KELTNER
extern color clrLine=clrNONE;
extern congestion_NORM_END congVersion=END;//CONGESTION OR CONGESTION END
extern congestionType typeOfCongestion=INSIDE;//BOTH KELTNER INSIDE BOLLINGER
extern bool drawSR=true;//Draw future projection lines from end of trend box
extern int historyLevels=5;//Number of back S/R to conside
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_H4;//HTF
                                               //ENVELOPES
extern int envPeriod= 14;
extern int lineMode = MODE_SMA;
extern int shifteBy = 0;
extern int closeMode= PRICE_CLOSE;
extern double percentDeviation=0.1;

extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=1.5;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=2.0; // Bands Deviations

extern double lowerPercentile=5;//low percent
extern double lowerMiddlePercentile=20;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=95;//upper Middle Percentile
extern double upperPercentile=98;//upper percentile 

extern int lowHighOffset=20;
extern double retrace=50;
extern bool bMajor=true;
extern bool bInter= false;
extern bool bMinor= false;
extern bool bExtreme=true;
extern bool bPinBar = false;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
bool drawPercLines=false;//show percentile 80 on squeeze plot 
double ExtEndPoint[];//-- ExtEndPoint  (maxCongestion high)
double ExtStartPoint[];//-- ExtStartPoint (minCongestion low)
                       //double ExtEndCongVal[];
//double ExtStartCongVal[];
double intSetUpStatus[];
double ExtStop[];
double ExtUpthrust[];
double ExtSpring[];
//double ExtSupport[];
//double ExtResistance[];
//rectangle
long chartID=0;
int subWindow=0;
int rectangleWidth=1;
const bool  rectangleFill=true;
ENUM_LINE_STYLE rectangleStyle=STYLE_SOLID;
const bool  rectangleSelection=false;
const bool  rectangleHidden=false;
const long  rectangleZOrder=10;//Z-index
const bool  rectangleBack=true;
//LINE stuff
int widthLine=1;
//-- CONGESTION ALGORITHM
bool isCongested=false;
datetime startShift;//Date of the start of Congestion
int candleIndex=-1;
double maxCongestion=0,minCongestion=INF;
string label_1 = NULL;
string label_2 = NULL;
string label_3 = NULL;
srList *support=NULL;
srList *resistance=NULL;
srList *combined=NULL;
string mql4Routine=NULL;
string infoString=NULL;
//LOOP
int htfIndex=NULL;
string instrument=Symbol();
ENUM_TIMEFRAMES startEnum=NULL;
int wtfIndex=findWTFIndex(enumHTFPeriod,startEnum);
int wtf=Period();
int shift=NULL;
int limit= NULL;

//int htfIndex=findIndexPeriod(enumHTFPeriod);
//int wtfIndex= NULL;
//string instrument=Symbol();
//int wtf=Period();
//int shift=NULL;
//int limit= NULL;
//+------------------------------------------------------------------+
//| update                                                           |
//+------------------------------------------------------------------+
void update(bool inCongestion,int Shift,const double &open[],const double &high[],const double &low[],const double &close[],const datetime &time[])
  {
//Update Indicators
//BUY
//ExtEndCongVal[i+1]=ExtEndCongVal[i+2];
//  ExtStartCongVal[i+1]=ExtStartCongVal[i+2];
//  srElement *recenrSR=combined.GetLastNode();

   if(!inCongestion)
     {
      //for(int sr=combined.Total()-1; sr>=0; sr--)
      for(srElement *sr=combined.GetLastNode();sr!=NULL;sr=sr.Prev())
        {

         //        if((open[Shift+1]<sr.level) && (close[Shift+1]>sr.level))// && (close[shift+1]>open[shift+1]))
         //        {
         //pinbar         
         double downBar=iCustom(instrument,wtf,"\\MAXIMA\\OHLC_EX",lowHighOffset,retrace,bMajor,bInter,bMinor,bExtreme,bPinBar,1,Shift);
         if(downBar!=EMPTY_VALUE)
           {
            //isDate(Shift,0,8,33,2018);              
            //            ExtSpring[Shift]=low[Shift+1];
            break;
           }
         //      }
         //  else if((open[Shift+1]>sr.level) && (close[Shift+1]<sr.level))// && (close[shift+1]<open[shift+1]))
         //   {
         double upBar=iCustom(instrument,wtf,"\\MAXIMA\\OHLC_EX",lowHighOffset,retrace,bMajor,bInter,bMinor,bExtreme,bPinBar,0,Shift);
         if(upBar!=EMPTY_VALUE)
           {
            //isDate(Shift+1,0,0,29,5,2018);               
            //             ExtUpthrust[Shift]=high[Shift+1];
            break;
           }
        }
      //   }//end for loop around S/R
      // double eUpper=iCustom(instrument,Period(),"HTFENV",enumHTFPeriod,14,MODE_SMA,0,PRICE_CLOSE,0.1,0,i+1);
      // double eLower=iCustom(instrument,Period(),"HTFENV",enumHTFPeriod,14,MODE_SMA,0,PRICE_CLOSE,0.1,1,i+1);
      //BUY
      //  if((low[i+1]<ExtStartCongVal[i+1]) && (low[i+1]<eLower) && (open[i+1]<eLower) && (close[i+1]>eLower))// && (intSetUpStatus[i+2]!=1))
        {//update the stop if crossed (dipped below support)
         //      intSetUpStatus[i+1]=2;
         //      ExtStop[i+1]=low[i+1];
         //       Print("BUY ",time[shift+1]," EUpper ",eUpper," ELower ",eLower);
         //       ExtUpthrustUpthrust[i+1]=low[i+1];
        }
      ////SELL     
      //  if((high[i+1]>ExtEndCongVal[i+1]) && (high[i+1]>eUpper) && (open[i+1]>eUpper) && (close[i+1]<eUpper))
      //   {
      //      intSetUpStatus[i+1]=4;
      //      ExtStop[i+1]=high[i+1];
      //        Print("SELL ",time[shift+1]," EUpper ",eUpper," ELower ",eLower);
      //        ExtUpthrustUpthrust[i+1]=high[i+1];
      //  }
     }
//  delete(s0);
//  delete(r0);
  }
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(congVersion==NORMAL)
     {
      mql4Routine="\\CONGESTION\\AUXILLARY\\PERCENTILE_CONGESTION";
      label_1 = "supportCongestion";
      label_2 = "resistanceCongestion";
      label_3 = "boxCongestion";
      //if(clrLine==clrNONE)
      //   clrLine=TF_C_Colors[htfIndex];
     }
   else
     {
      mql4Routine="\\CONGESTION\\AUXILLARY\\PERCENTILE_CONGESTION_END";
      label_1 = "supportCongestionEnd";
      label_2 = "resistanceCongestionEnd";
      label_3 = "boxCongestionEnd";
      //if(clrLine==clrNONE)
      //   clrLine=TF_CE_Colors[htfIndex];
     }
   support=new srList(historyLevels,label_1);
   resistance=new srList(historyLevels,label_2);
   combined=new srList((2*historyLevels),"combined");

   string sName="Congestion LINES"+" "+instrument+" "+string(enumHTFPeriod);
   if(!checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex))
      Print(__FUNCTION__," has checkedEnumDesied:  ",checkEnumDesired(wtfIndex,enumHTFPeriod,htfIndex)," enumHTFPERIOD: ",enumHTFPeriod);
clrLine=TF_C_Colors[htfIndex];      
   //if(Period()==tfEnumFull[ArraySize(tfEnumFull)-1])
   //  {
   //   Print("Indicator user higher time frames: there are none! htfIndex "+string(htfIndex)+" enumHTFPeriod "+string(enumHTFPeriod));
   //   return(INIT_FAILED);
   //  }
   //if(Period()>enumHTFPeriod)
   //  {
   //   Print(enumHTFPeriod);
   //   if(!(enumHTFPeriod==0))
   //     {
   //      s("***** enumHTFPeriod: "+string(enumHTFPeriod)+" Indicator only shows higher timeframes of Period(): "+string(Period()),true);
   //      s("***** SETTING PERIOD TO DEFAULT CHART PERIOD: "+string(Period()),true);
   //     }
   //   else
   //      Print("used current");
   //   enumHTFPeriod=ENUM_TIMEFRAMES(Period());
   //   htfIndex=findIndexPeriod(enumHTFPeriod);
   //  }

   IndicatorShortName(sName);
   infoString=instrument+" "+string(enumHTFPeriod);
   IndicatorBuffers(5);

   SetIndexStyle(0,DRAW_ARROW,0,10,clrLine);
   SetIndexArrow(0,196);
   SetIndexLabel(0,string(enumHTFPeriod)+" HTFCONG Bottom Left");
   SetIndexBuffer(0,ExtStartPoint);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,DRAW_ARROW,0,10,clrLine);
   SetIndexArrow(1,202);
   SetIndexLabel(1,string(enumHTFPeriod)+" HTFCONG_Top Right");
   SetIndexBuffer(1,ExtEndPoint);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_ARROW,0,4,clrBlueViolet);
   SetIndexArrow(2,89);
   SetIndexLabel(2,string(enumHTFPeriod)+" HTFCONG_Upthrust");
   SetIndexBuffer(2,ExtUpthrust);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_ARROW,0,4,clrGreen);
   SetIndexArrow(3,89);
   SetIndexLabel(3,string(enumHTFPeriod)+" HTFCONG_Spring");
   SetIndexBuffer(3,ExtSpring);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,DRAW_ARROW,0,3,clrLine);
   SetIndexArrow(4,160);
   SetIndexLabel(4,string(enumHTFPeriod)+" HTFCONG_stop");
   SetIndexBuffer(4,ExtStop);
   SetIndexEmptyValue(4,EMPTY_VALUE);

//SetIndexStyle(4,DRAW_NONE,0,3,clrNONE);
//SetIndexBuffer(4,ExtSupport);
//SetIndexLabel(4,"IGNORE "+string(enumHTFPeriod)+" HIST"+string(historyLevels));
//SetIndexEmptyValue(4,EMPTY_VALUE);
// ArrayResize(ExtSupport,historyLevels);

//SetIndexStyle(5,DRAW_NONE,0,3,clrNONE);
//SetIndexBuffer(5,ExtResistance);
//SetIndexLabel(5,"IGNORE "+string(enumHTFPeriod)+" HIST"+string(historyLevels));
//SetIndexEmptyValue(5,EMPTY_VALUE);
// ArrayResize(ExtResistance,historyLevels);

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

   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ExtEndPoint,true);
   ArraySetAsSeries(ExtStartPoint,true);
   ArraySetAsSeries(intSetUpStatus,true);
//ArraySetAsSeries(ExtSupport,true);
//   ArraySetAsSeries(ExtResistance,true);
   ArraySetAsSeries(ExtStop,true);
   ArraySetAsSeries(ExtUpthrust,true);
   ArraySetAsSeries(ExtSpring,true);

   ArrayResize(intSetUpStatus,rates_total);
   ArrayFill(intSetUpStatus,0,rates_total,EMPTY_VALUE);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-4; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,time[shift+1],false);
         if(shift>(rates_total-2))
            continue;
         if(htfShift==phtfShift)
           {
            //update(isCongested,shift,open,high,low,close,time);
            continue;
           }
         double bin=iCustom(instrument,enumHTFPeriod,mql4Routine,drawPercLines,
                            lowerPercentile,lowerMiddlePercentile,middlePercentile,upperMiddlePercentile,upperPercentile,
                            typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,1,phtfShift);
         //-- NEW START          
         if((!isCongested) && (bin>=upperMiddlePercentile))
           {
            intSetUpStatus[shift+1]=EMPTY_VALUE;
            ExtStop[shift+1]=EMPTY_VALUE;
            maxCongestion=MathMax(maxCongestion,high[shift+1]);
            minCongestion=MathMin(minCongestion,low[shift+1]);
            ExtStartPoint[shift+1]=minCongestion;
            startShift=iTime(instrument,wtf,shift+1);
            isCongested=true;
           }
         //-- NEW END           
         else if((isCongested) && (bin<upperMiddlePercentile))
           {
            int  s=shift+2;
            intSetUpStatus[shift+2]=EMPTY_VALUE;
            ExtEndPoint[s]=maxCongestion;
            //Need list of levels start finish  
            support.updateList(minCongestion,time[candleIndex],drawSR);
            resistance.updateList(maxCongestion,time[s],drawSR);
            combined.updateList(minCongestion,time[candleIndex],false);
            combined.updateList(maxCongestion,time[s],false);
            maxCongestion=0;
            minCongestion=INF;
            isCongested=false;
            //draw it
            string rBox=label_3+string(wtf)+string(enumHTFPeriod)+string(time[shift+1]);
            candleIndex=iBarShift(instrument,wtf,startShift,true);
            bool isDrawn=RectangleCreate(chartID=0,rBox,subWindow,time[candleIndex],
                                         ExtStartPoint[candleIndex],time[s],ExtEndPoint[s],clrLine,rectangleStyle,rectangleWidth,
                                         rectangleFill,rectangleBack,rectangleSelection,rectangleHidden,rectangleZOrder);

            support.drawSECongestion(enumHTFPeriod,time,clrLine,drawSR,label_1,label_2,infoString);//have to wait until support start confirmed
            resistance.drawSECongestion(enumHTFPeriod,time,clrLine,drawSR,label_1,label_2,infoString);

            // updateTimeSeries();//upDate time series for support resistance
           }
         //-- UPDATE THE RANGE OF THE CONGESTION INLINE WITH NEW DATA
         if(isCongested)
           {
            maxCongestion=MathMax(maxCongestion,high[shift+1]);
            minCongestion=MathMin(minCongestion,low[shift+1]);
            candleIndex=iBarShift(instrument,wtf,startShift,true);
            ExtStartPoint[candleIndex]=minCongestion;
           }
         update(isCongested,shift,open,high,low,close,time);
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
   delete(support);
   delete(resistance);
   delete(combined);
   int nLabel_1=StringLen(label_1);
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      string objName=ObjectName(i);
      if((StringSubstr(objName,0,StringLen(label_1))==label_1) || (StringSubstr(objName,0,StringLen(label_2))==label_2) || (StringSubstr(objName,0,StringLen(label_3))==label_3))
         ObjectDelete(ObjectName(i));
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| updateTimeSeries                                                         |
//+------------------------------------------------------------------+
//void updateTimeSeries()
//  {
//   for(int r=0; r<support.Total();r++)
//     {
//      srElement *sup=support.GetNodeAtIndex(r);
//      ExtSupport[r]=sup.level;
//      srElement *res=resistance.GetNodeAtIndex(r);
//      ExtResistance[r]=res.level;
//     }
//  }
