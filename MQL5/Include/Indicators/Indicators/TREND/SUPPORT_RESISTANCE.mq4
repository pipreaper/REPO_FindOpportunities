//+------------------------------------------------------------------+
//|                                             SR Zones.mq4 |
//|                       Copyright 2016, Robert Baptie |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Robert Baptie"
#property link      ""
#property version   "1.4"
#property strict
#property indicator_chart_window
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WaveLibrary.mqh>
#property indicator_buffers 2

//-EXTERNAL
extern ENUM_TIMEFRAMES  eEnumHTFPeriod=PERIOD_D1;//HTF shown
extern int hipLopDepth=10;//10Sensitivity of S/R
extern bool drawLevels=true;

//-BUFFERS
double ExtSpring[];
double ExtUpthrust[];

//-GLOBAL

//chart
int htfIndex=NULL;
ENUM_TIMEFRAMES startEnum=NULL;
int shift=NULL;
int limit= NULL;
color clrLine=clrNONE;
int thickness=2;
static int htfShift=-1;
static int phtfShift=-1;
string stdText=NULL;
double digits = -1;
static int uniqueLineID=0;
long chart_id=0;

//algorithm
int maxBars=5000;
int maxLevels=-1;//why do the muber of levels equal to the number of bars work?? fractions of it produce inferior results
double lowestLow=INF;
double highestHigh=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   stdText="SR "+string(ChartWindowFind())+" "+Symbol()+" "+string(eEnumHTFPeriod);
   IndicatorShortName(stdText);
   digits=MarketInfo(Symbol(),MODE_DIGITS);
   if(eEnumHTFPeriod==PERIOD_CURRENT)
      eEnumHTFPeriod=ENUM_TIMEFRAMES(Period());

   IndicatorBuffers(2);
   IndicatorDigits(int(digits));

   htfIndex=findWTFIndex(eEnumHTFPeriod,startEnum);
   clrLine=TF_C_Colors[htfIndex];

   SetIndexBuffer(0,ExtSpring);
   SetIndexLabel(0,"SPRING "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(0,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(1,ExtUpthrust);
   SetIndexLabel(1,"UPTHRUST "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_NONE,0,1,clrLine);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function            |
//+------------------------------------------------------------------+
void myInit(int index, const int rt,const double &H[],const double &L[],const datetime &T[],bool dLevels)
  {
//id of first line
   uniqueLineID=0;

   int barsChart=Bars(Symbol(),eEnumHTFPeriod);
//maxBars (1000) or chart bars available 
   maxBars=MathMin(barsChart,maxBars);
Print("shift :",shift," maxBars: ",maxBars);
//return;
   if(maxBars>0)
      Print(__FUNCTION__,":INFO OK: "+string(maxBars));
   else
     {
      Print(__FUNCTION__,"INFO: :********  NO DATA BARS COPIED INTO Rates Array ******************");//+Symbol()+" TF: "+string(eEnumHTFPeriod)+" Limit: "+string(lim)+" MaxBars: "+string(maxBars));
      return;
     }

   lowestLow=L[iLowest(Symbol(),eEnumHTFPeriod,MODE_LOW,maxBars-1,index)];
   highestHigh=H[iHighest(Symbol(),eEnumHTFPeriod,MODE_HIGH,maxBars-1,index)];

//SET LEVELS = MAXBARS BECAUSE I GIVES BEST SUPPORT RESISTANCE LINES ON CHART?
   maxLevels=maxBars;
   double price=lowestLow;
   double step=(highestHigh-lowestLow)/maxLevels;

//ITERATE ALL PRICE LEVELS CALCULATED
   double crossCounts[1][2];
   int barCount,crossCount;
   ArrayResize(crossCounts,maxLevels);
   price=lowestLow;
   for(int level=0; level<maxLevels-1; level++)
     {
      crossCount=0.0;
      //ITERATE ALL BARS HISTORY FOR GIVEN RATE (PRICE)
      for(barCount=0; barCount<maxBars; barCount++)
        {
         if((price>L[barCount]) && (price<H[barCount]))
            crossCount+=1;
        }
      //RECORD THE NUMBER OF CROSSES AT THAT PRICE
      crossCounts[level,0]=price;
      crossCounts[level,1]=crossCount;

      //INCREASE THE PRICE TO CHECK
      price+=step;
     }

   for(int thisLevel=hipLopDepth; thisLevel<=maxLevels-hipLopDepth-1;thisLevel++)
     {
      bool minima=isLow(crossCounts,thisLevel,hipLopDepth);
      if(minima && dLevels && (shift == 0))
         drawLine(eEnumHTFPeriod,crossCounts[thisLevel,0],T[0],T[maxBars-1],clrLine,thickness);
     }
  }
//+------------------------------------------------------------------+
//| On Calculate                                                     |
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
//---INITIALISE ARRAYS
   ArraySetAsSeries(ExtSpring,true);
   ArraySetAsSeries(ExtUpthrust,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit;
   for(shift=limit-1; shift>=0; shift--)
     {
      if(isNewBar)
        {
         if(shift>rates_total-2)
            continue;
         if(shift<maxBars)
            myInit(shift,rates_total,high,low,time,drawLevels);
         // ExtSpring[htfShift]=high[htfShift];
         // ExtUpthrust[htfShift]=low[htfShift];
         // }
        }
     }
   ChartRedraw();
   return(rates_total);
  }
//+----------------------------------------------------------------------------------------------------------------------+
//|  isLow                                                                                                              |
//|  Checking if this is a local minima of crosses around 6 crosses                            | 
//+----------------------------------------------------------------------------------------------------------------------+
bool isLow(double &cc[][],int thisLevel,int searchDepth)
  {
   for(int i=1; i<searchDepth-1; i++)
     {
      if((cc[thisLevel][1]<cc[thisLevel-i][1]) && (cc[thisLevel][1]<cc[thisLevel+i][1]))
         continue;
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| update:                                                          |
//+------------------------------------------------------------------+
void update(int rt)
  {

  }
//+------------------------------------------------------------------+
//| drawLine                                                      |
//+------------------------------------------------------------------+  
string drawLine(const ENUM_TIMEFRAMES tf,double p,datetime t1,datetime t2,color clr,double lineWidth)
  {
   uniqueLineID++;
   string lineName="level"+string(tf)+string(uniqueLineID);
   int sw=ObjectFind(ChartID(),lineName);
   int window=0;
   if(sw<0)
     {
      if(!ObjectCreate(ChartID(),lineName,OBJ_TREND,0,t1,p,t2,p))
        {
         Print(__FUNCTION__,": failed to create a support Line, Error code = ",ErrorDescription(GetLastError()));
         return "Line Already Exists";
        }
      else
        {
         //--- set line color   
         ObjectSetInteger(chart_id,lineName,OBJPROP_BACK,false);
         ObjectSetInteger(chart_id,lineName,OBJPROP_SELECTABLE,false);
         //---enable (true) or disable (false) the mode of continuation of the line's display to the left
         ObjectSetInteger(chart_id,lineName,OBJPROP_RAY_LEFT,false);
         //--- enable (true) or disable (false) the mode of continuation of the line's display to the right
         ObjectSetInteger(chart_id,lineName,OBJPROP_RAY_RIGHT,true);
         ObjectSet(lineName,OBJPROP_WIDTH,lineWidth);
         ObjectSetInteger(chart_id,lineName,OBJPROP_COLOR,clr);
        }
     }
   else
      Print(__FUNCTION__,"Line already exists");
   return lineName;
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string textName1="level";
   string textName2="label";
//   string textName3="cumIndex";
//// string textName4="cumPrice";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      string objName=ObjectName(i);
      if((StringSubstr(objName,0,5)==textName1) || (StringSubstr(objName,0,5)==textName2))// || StringSubstr(objName,0,8)==textName3)// || StringSubstr(objName,0,8)==textName4)
        {
         ObjectDelete(ObjectName(i));
         //  Print("deleted ",objName);
        }
     }
// ObjectDelete("Text_Obj_Index");
  }
//+------------------------------------------------------------------+
