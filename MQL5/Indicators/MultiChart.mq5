//+------------------------------------------------------------------+
//|                                                  MultiChart View |
//|                                    Copyright 2014, Robert Baptie |
//|                                http://rgb-web-designer.comli.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2014 Robert Baptie "
#property  link      "http://rgb-web-developer.comli.com"
#property strict
//#include <errordescription.mqh>
#include <INCLUDE_FILES\\screenStuff.mqh>
long thisChart;
#property indicator_chart_window
#property indicator_plots 0;
//--- input parametr
//input string NameRECTANGLE="MultiChart";
//+------------------------------------------------------------------+
//| indicator initialization function                                |
//+------------------------------------------------------------------+
void OnInit()
  {
// string textName1="V Line";
   for(int i=ObjectsTotal(ChartID()) -1; i>=0; i--)
     {
      //Tidy old congestion
      string objName=ObjectName(ChartID(),i);
      long objType=ObjectGetInteger(ChartID(),objName,OBJPROP_TYPE);
      if(objType==OBJ_VLINE)
         ObjectDelete(ChartID(),ObjectName(ChartID(),i));
     }
   thisChart=ChartID();
//--- disable auto scroll
   ChartSetInteger(thisChart,CHART_AUTOSCROLL,false);
   ChartSetInteger(thisChart,CHART_MODE,CHART_CANDLES);
//--- Capture mouse Move Events
   ChartMouseScrollSet(true,thisChart);
   ChartSetInteger(thisChart,CHART_EVENT_MOUSE_MOVE,1);
//--- Put a vertical line on the chart at newest time
   CopyTime(_Symbol,_Period,0,1,tda);
//  string name = "V Line"+(string)thisChart;
   ObjectCreate(ChartID(),"V Line"+(string)thisChart,OBJ_VLINE,0,tda[0],0);//window time price
   bool res=ChartNavigate(thisChart,CHART_END,0);
   int  FVB=ChartFirstVisibleBar(thisChart);//Get first visible bar (left most  of chart window)
   res=centerVLine(thisChart,FVB,ChartSymbol(),ChartPeriod(),tda[0]);
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
//ArraySetAsSeries(time,true);
//ObjectSetInteger(0,NameRECTANGLE,OBJPROP_TIME,1,time[0]);
//--- return value of prev_calculated for next call
   return(rates_total);
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
  }
//+------------------------------------------------------------------+
//|deinit                                                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal(ChartID()) -1; i>=0; i--)
     {
      string objName=ObjectName(ChartID(),i);
      if(objName=="V Line"+(string)thisChart)
         ObjectDelete(ChartID(),ObjectName(ChartID(),i));
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
