//+------------------------------------------------------------------+
//|                                                 sessionTimes.mq5 |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(SymbolInfoSessionTrade("EURUSD",WEDNESDAY,0,))
      Print("/"+TimeToString(datetimeDeb,TIME_MINUTES)+"/"+TimeToString(datetimeFin,TIME_MINUTES)+"/");
  }
//+------------------------------------------------------------------+
