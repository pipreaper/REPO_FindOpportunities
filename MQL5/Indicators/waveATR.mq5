//+------------------------------------------------------------------+
//|                                                    Demo_iATR.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "The indicator demonstrates how to obtain data"
#property description "of indicator buffers for the iATR technical indicator."
#property description "A instrument and timeframe used for calculation of the indicator,"
#property description "are set by the instrument and tf parameters."
#property description "The method of creation of the handle is set through the 'type' parameter (function type)."

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot iATR
#property indicator_label1  "iATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#include <Indicators\Oscilators.mqh>
#include <errordescription.mqh>

CiATR iatr;
//+------------------------------------------------------------------+
//| Enumeration of the methods of handle creation                    |
//+------------------------------------------------------------------+
//enum Creation
//  {
//   Call_iATR,// use iATR
//   Call_IndicatorCreate    // use IndicatorCreate
//  };
//--- input parameters
input int                  atr_period=14;          // tf of calculation
//input Creation             type=Call_iATR;         // type of the function
input string               instrument=" ";             // instrument
input ENUM_TIMEFRAMES      tf=PERIOD_CURRENT;  // timeframe
//--- indicator buffer
double         iATRBuffer[];
//--- variable for storing the handle of the iAC indicator
//int    handle;
//--- variable for storing
string insName=instrument;
//--- insName of the indicator on a chart
string short_name;
//--- we will keep the number of values in the Average True Range indicator
int    bars_calculated=0;
// wait for
bool timedEvent = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int waitMS = 1;
//--- assignment of array to indicator buffer
   SetIndexBuffer(0,iATRBuffer,INDICATOR_DATA);
//--- determine the instrument the indicator is drawn for
   insName=instrument;
//--- delete spaces to the right and to the left
   StringTrimRight(insName);
   StringTrimLeft(insName);
//--- if it results in zero length of the 'insName' string
   if(StringLen(insName)==0)
     {
      //--- take the instrument of the chart the indicator is attached to
      insName=_Symbol;
     }
//--- create handle of the indicator
   iatr.Create(insName,tf,atr_period);
//handle=IndicatorCreate(insName,tf,IND_ATR,1,pars);
   EventSetMillisecondTimer(waitMS);
   Print("OnTimer set to ",waitMS," ms");

//     }
//--- if the handle is not created
   if(iatr.Handle()==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iATR indicator for the instrument %s/%s, error code %d",
                  insName,
                  EnumToString(tf),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//--- show the instrument/timeframe the Average True Range indicator is calculated for
   short_name=StringFormat("iATR(%s/%s, tf=%d)",insName,EnumToString(tf),atr_period);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- normal initialization of the indicator
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Need timer to make data available to atr in OnInit of Expert     |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Assumption here is refresh in Timer ensures that the inidicator data are available???
   iatr.Refresh();
   double tempArray[];
   int countElements;

//--- reset error code
   ResetLastError();
//--- fill a part of the iATRBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(iatr.Handle(),0,0,1000,tempArray)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return;
     }


   for(int i=0; i<ArraySize(tempArray); i++)
      Print(instrument, " 1st: ", iATRBuffer[i]," 2nd: ", tempArray[i]);
   Print(__FUNCTION__,"numElements: ",countElements," Refreshed  Data: ", instrument," TF: ",tf);
   EventKillTimer();
   DebugBreak();
   timedEvent = true;
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
   if(!timedEvent)
      return rates_total;
//--- number of values copied from the iATR indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(iatr.Handle());
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iATR indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iATRBuffer array is greater than the number of values in the iATR indicator for instrument/tf, then we don't copy everything
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the iATRBuffer array with values of the Average True Range indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(iATRBuffer,iatr.Handle(),values_to_copy))
      return(0);
//--- form the message
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            short_name,
                            values_to_copy);
//--- display the service message on the chart
   Comment(comm);
//--- memorize the number of values in the Average True Range indicator
   bars_calculated=calculated;
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iATR indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],  // indicator buffer for ATR values
                         int ind_handle,    // handle of the iATR indicator
                         int amount         // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iATRBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- clear the chart after deleting the indicator
   Comment("");
  }
//+------------------------------------------------------------------+
