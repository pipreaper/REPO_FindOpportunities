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
#property indicator_buffers 2
#define INF 0x6FFFFFFF//Large Number

bool fileIt=false;//Write ONY ONE!! or Last TF
extern bool EA=false;

extern int numLevelsArraySize =4999;
extern int hipLopDepthThis=10;//10Sensitivity of S/R This
extern int hipLopDepthPlusOne=10;//6Sensitivity Plus One
extern int hipLopDepthPlusTwo=10;//4Sensitivity Plus Two

extern bool TFThis=false;//current TF
extern bool TFPlusOne=true;//PlusOne TF
extern bool TFPlusTwo=true;//PlusTwo TF

extern double lowerBound;// = 125.058;//lower band only used if EA is calling
extern double upperBound;// = 125.346;//upperband only used if EA is calling
extern bool isOffline=true;
int hipLopDepth[3];
color clrSupport[3];
double thickness[3];
bool displayTF[3];

double levelThiscknessThis=1;
double levelThicknessPlusOne=1;
double levelThicknessPlusTwo=1;

color clrThis=clrGreen;
color clrPlusOne = clrBlue;
color clrPlusTwo = clrRed;
color clrLabel=clrRed;

int fontSize=10;
string fontType="mono";//"Times New Roman";//"Windings";

static int uniqueLineID=0;
long chart_id=0;
int maxBars=1000;

double bufferCrosses[];
double bufferTF[];
int prevShift=0;
double drawLow =INF;
double drawHigh=-1;
ENUM_TIMEFRAMES tfEnum[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
static int numTF=9;

void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
  {
   if(!isOffline)
      return;
//--- the left mouse button has been pressed on the chart
   if(id==CHARTEVENT_CLICK)
     {
      OnDeinit(0);//dont need this for EA because no lines drawn
      int rates_total=Bars(Symbol(),PERIOD_CURRENT)-1;
      myInit(rates_total);
      Print("The coordinates of the mouse click on the chart are: x = ",lparam,"  y = ",dparam);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function            |
//+------------------------------------------------------------------+
void myInit(const int rt)
  {
//  Print(__FUNCTION__,"***** INDICATOR *****, TF: ",Period()," Pair ",Symbol());
   uniqueLineID=0;
   ENUM_TIMEFRAMES investigateTF=NULL;

   initConsts();

   IndicatorBuffers(2);
   SetIndexBuffer(0,bufferCrosses);
   SetIndexStyle(0,DRAW_NONE);
   ArraySetAsSeries(bufferCrosses,true);
   ArrayResize(bufferCrosses,rt);// guess!! should be number of levels in 3 time frames
   ArrayFill(bufferCrosses,0,rt,EMPTY_VALUE);

   SetIndexBuffer(1,bufferTF);
   SetIndexStyle(1,DRAW_NONE);
   ArraySetAsSeries(bufferTF,true);
   ArrayResize(bufferTF,rt);
   ArrayFill(bufferTF,0,rt,EMPTY_VALUE);
   int bufferIndex=0;

//DisplayTF CAN BE A MAX OF THREE AND REFLECTS THE BASE AND TWO HIGHER TIME FRAMES
   for(int x=0; x<=ArraySize(displayTF)-1; x++)
     {
      if(displayTF[x]==false)
         continue;
      investigateTF=whatTF(x);
      if(investigateTF==NULL)
         continue;
      double crossCounts[1][2];
      int    limit=MathMin(Bars(Symbol(),investigateTF),maxBars);
      MqlRates rates[];
      ArraySetAsSeries(rates,false);//series same as indexes count(most distant) -> 0(most recent)
      int copiedBars=CopyRates(Symbol(),investigateTF,0,limit,rates);
      if(copiedBars>0)
        {
         //     Print(__FUNCTION__,":INFO:  Data Bars  = "+DoubleToStr(copiedBars));
        }
      else
        {
        Print(__FUNCTION__,"INFO: :********  NO DATA BARS  ******************"+Symbol()+" TF: "+string(investigateTF)+" Limit: "+string(limit)+" MaxBars: "+string(maxBars));
    //     PlaySound("tick.wav");
         return;
        }
      double boundLow =  INF;
      double boundHigh=0;
      int barCount,priceLevel,crossCount;
      double l,h;
   //   if(!EA)
  //      {
         for(int i=0; i<copiedBars; i++)
           {
            //SHOW ALL LEVELS ON THE CHART
            boundLow = MathMin(boundLow,rates[i].low);
            boundHigh=MathMax(boundHigh,rates[i].high);
           }
 //       }
 //     else
 //       {
 //        boundHigh=upperBound;
 //        boundLow=lowerBound;
 //       }

      double price=boundLow;
      double pt= Point();
      double step=0;//Point()*10; //10Points         
          
      step = ((boundHigh-boundLow))/numLevelsArraySize;
      
      ArrayResize(crossCounts,numLevelsArraySize);//default changes first dimension only
                                                  //ITERATE ALL PRICE LEVELS CALCULATED
      for(priceLevel=0; priceLevel<=numLevelsArraySize-1;priceLevel++) //Iterate over all rates
        {
         crossCount=0.0;
         //ITERATE ALL BARS HISTORY FOR GIVEN RATE (PRICE)
         for(barCount=0; barCount<copiedBars; barCount++)
           {
            l=rates[barCount].low;
            h=rates[barCount].high;
            if(price>l && price<h)
               crossCount+=1;
           }
         //RECORD THE NUMBER OF CROSSES AT THAT PRICE
         crossCounts[priceLevel,0]=price;
         crossCounts[priceLevel,1]=crossCount;
         //       if(fileIt)
         //        FileWrite(handle,price,crossCount);
         //INCREASE THE PRICE TO CHECK
         price+=step;
        }
      for(int thisLevel = hipLopDepth[x]; thisLevel<=numLevelsArraySize-hipLopDepth[x]-1;thisLevel++)//five hip lop
        {
        bool minima = isLow(crossCounts,thisLevel,hipLopDepth[x]);
         if(minima)
           {
            if((!EA))// && (crossCounts[b,0] >= drawLow) && (crossCounts[b,0] <= drawHigh) )
              {
               drawLine(investigateTF,crossCounts[thisLevel,0],rates[0].time,rates[copiedBars-1].time,clrSupport[x],thickness[x]);
               datetime diffTime=(rates[0].time-rates[copiedBars-1].time)/copiedBars;
               diffTime=rates[copiedBars-1].time-diffTime*15;
               //0 is price 1 is number of crosses of that price
//drawLabel(investigateTF,crossCounts[b,0],diffTime,crossCounts[b,1]);
              }
            //Print(__FUNCTION__,":Level ",crossCounts[b,0]," index ",b," TF: ",investigateTF);
            //RECORDS THE PRICE AND THE TIMEFRAME THAT THE MINIMA WAS FOUND
            bufferCrosses[bufferIndex]=crossCounts[thisLevel,0];
            bufferTF[bufferIndex]=investigateTF;
            bufferIndex++;
            //      if(fileIt)
            //       FileWrite(handle2,crossCounts[b,0],crossCounts[b,1]);
           }
         // Print(__FUNCTION__,": item ",b," price ",crossCounts[b][0]," crosscount ",crossCounts[b][1]);
        }
      //    if(fileIt)
      //    {
      //   FileClose(handle);
      // FileClose(handle2);
      //    }
     }
// for(int t=0; t<=100; t++)
//    Print(__FUNCTION__,":Level: ",bufferCrosses[t]," TF  ",bufferTF[t]," index: ",t);
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
   if(!EA)
     {//called only on indicator new bar
      if((prev_calculated)!=prevShift)
        {
         OnDeinit(0);//dont need this for EA because no lines drawn
         myInit(rates_total);
         prevShift=prev_calculated;
        }
     }
   else
     {//called on EA (EA SR new bar
      myInit(rates_total);
     }
//---
////--- return value of prev_calculated for next call

//{

// prevShift=rates_total;//new candle is old candle       
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  initConsts                                                   |
//+------------------------------------------------------------------+  
void initConsts()
  {
   hipLopDepth[0]=hipLopDepthThis;
   hipLopDepth[1]=hipLopDepthPlusOne;
   hipLopDepth[2]=hipLopDepthPlusTwo;
   clrSupport[0]=clrThis;
   clrSupport[1]=clrPlusOne;
   clrSupport[2]=clrPlusTwo;
   thickness[0]=levelThiscknessThis;
   thickness[1]=levelThicknessPlusOne;
   thickness[2]=levelThicknessPlusTwo;
   displayTF[0]=TFThis;
   displayTF[1]=TFPlusOne;
   displayTF[2]=TFPlusTwo;
  }
//+------------------------------------------------------------------+
//|   whatTF                                                      |
//+------------------------------------------------------------------+  
ENUM_TIMEFRAMES whatTF(int thisTF)
  {
   for(int i=0; i<numTF; i++)
     {
      if(i+thisTF+1>numTF)
         break;
      if((PeriodSeconds()-PeriodSeconds(tfEnum[i]))==0)
         return tfEnum[i+thisTF];
     }
   return NULL;
  }
//+----------------------------------------------------------------------------------------------------------------------+
//|  isLow                                                                                                              |
//|  Checking if this is a local minima of crosses around 6 crosses                            | 
//+----------------------------------------------------------------------------------------------------------------------+
bool isLow(double &cc[][],int thisLevel,int searchDepth)
  {
   for(int i=1; i< searchDepth-1; i++)
     {
      if((cc[thisLevel][1]<cc[thisLevel-i][1]) && (cc[thisLevel][1]<cc[thisLevel+i][1]))
         continue;
      return false;
     }
   return true;
  }
//--------------------------------------------------------------+
//| drawLabel                                              |
//+------------------------------------------------------------+  
bool drawLabel(const ENUM_TIMEFRAMES tf,double p,datetime t0,double crosses)
  {
   uniqueLineID++;
   string labelName="label"+string(tf)+string(uniqueLineID);
   int sw=ObjectFind(ChartID(),labelName);
   int window=0;
   if(sw<0)
     {
      if(!ObjectCreate(ChartID(),labelName,OBJ_TEXT,0,t0,p))
        {
         Print(__FUNCTION__,": failed to create a Line Label, Error code = ",ErrorDescription(GetLastError()));
         return false;
        }
      else
        {
         ObjectSetInteger(chart_id,labelName,OBJPROP_BACK,false);
         ObjectSetText(labelName,string(crosses)+" "+DoubleToStr(NormalizeDouble(p,Digits)),fontSize,fontType,clrLabel);
         return true;
        }
     }
   return false;
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
