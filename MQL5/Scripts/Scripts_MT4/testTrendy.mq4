//+------------------------------------------------------------------+
//|                                                   testTrendy.mq4 |
//|                                               Robert Baptie 2018 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Robert Baptie 2018"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <ROB_CLASS_FILES\trendy.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   CIndicator *eTrend = new trendE();
   CIndicator *iTrend = new trendI();   
   string symbol = iTrend.Symbol();
   delete(iTrend);
   delete(eTrend);   
  }
//+------------------------------------------------------------------+
