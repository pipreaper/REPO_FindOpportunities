//+------------------------------------------------------------------+
//|                                                  MultiChart View |
//|                                    Copyright 2014, Robert Baptie |
//|                                http://rgb-web-designer.comli.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2014 Robert Baptie "
#property  link      "http://rgb-web-developer.comli.com"
#property  indicator_chart_window
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <screenStuff.mqh>
#property  indicator_buffers 1
//dummy buffer
double ExtBuffer[];
//Global Vars
//-----------------
long thisChart;
datetime prevTime;
int barsToProcess=2000;
int thisPrevIndex;
int thisCurrIndex=0;
string MSLeft="UP";
string prevMSLeft="UP";
//+------------------------------------------------------------------+
//| indicator initialization function                                   |
//+------------------------------------------------------------------+
void init()
  {
 // string textName1="V Line";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {//Tidy old congestion
      string objName=ObjectName(i);
      int objType=ObjectType(objName);
      if(objType == OBJ_VLINE)
        {
         ObjectDelete(ObjectName(i));
        }
     }      
   string short_name;
   short_name="timeFrame"+ChartSymbol()+string(ENUM_TIMEFRAMES(ChartPeriod()));
   IndicatorShortName(short_name);

   thisChart=ChartID();
//--- disable auto scroll
   ChartSetInteger(thisChart,CHART_AUTOSCROLL,false);
   ChartSetInteger(thisChart,CHART_MODE,CHART_CANDLES);
//--- Capture mouse Move Events
   ChartMouseScrollSet(true,thisChart);
   ChartSetInteger(thisChart,CHART_EVENT_MOUSE_MOVE,1);
//--- Put a vertical line on the chart at newest time
   ObjectCreate((string)thisChart,"V Line"+(string)thisChart,OBJ_VLINE,0,Time[0]);//window time price
   bool res=ChartNavigate(thisChart,CHART_END,0);
   int  FVB=ChartFirstVisibleBar(thisChart);//Get first visible bar (left most  of chart window)
   res=centerVLine(thisChart,FVB,ChartSymbol(),ChartPeriod(),Time[0]);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      MultiFrame(thisChart,id,lparam,dparam,sparam);
      //Print("Hi From timeframe");
     }
   else
     {
      //--- display the error message in Experts journal Mouse Moe
      //Print(__FUNCTION__+", Error = ","ChartXYToTimePrice return error code: x "+(string)x+" y "+TimeToStr(y));
     }
  }
//+------------------------------------------------------------------+
//|OnCalculate                                                       |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[]         // Spread
                 )
  {
   return(rates_total);
//   int counted_bars=IndicatorCounted(),
//   limit;
//
//   if(counted_bars>0)
//      counted_bars--;
//
//   limit=Bars-counted_bars;
//
//   if(limit>barsToProcess)
//      limit=barsToProcess;
//
//   for(int i=0;i<limit;i++)
//     {
//      ExtBuffer[i]=1;
//     }
//
//   return(rates_total);
  }
//+------------------------------------------------------------------+
//|deinit                                                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
 // string textName1="V Line";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {//Tidy old congestion
      string objName=ObjectName(i);
      int objType=ObjectType(objName);
      if(objType == OBJ_VLINE)
        {
         ObjectDelete(ObjectName(i));
        }
     }  
  // ObjectDelete(0,"V Line"+(string)ChartID());
  }
//+------------------------------------------------------------------+
