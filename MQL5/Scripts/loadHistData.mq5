//+------------------------------------------------------------------+
//|                                                 loadHistData.mq4 |
//|                                    Copyright 2016, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <INCLUDE_FILES\\GetBrokerSymbolTFData.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
string ins="GBPZAR";
ENUM_TIMEFRAMES period=PERIOD_H4;
//+------------------------------------------------------------------+
//|OnStart                                                           |
//+------------------------------------------------------------------+
void OnStart()
  {
//override the above settings to be current chart
   ins=_Symbol;
   period=_Period;
   getUpdatedHistory(ins,period);
  }
//+------------------------------------------------------------------+
