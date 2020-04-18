//+------------------------------------------------------------------+
//|                                                     BigBar.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <CLASS_FILES\CatalystMatch.mqh>
class CatalystBigBelt  : public CatalystMatch
  {
private:

public:
   catalystState     CatalystBigBelt::isBigBelt();
                     CatalystBigBelt();
                    ~CatalystBigBelt();
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
void              CatalystBigBelt::CatalystBigBelt()
  {
    catType ="Big Belt";
  }
//+------------------------------------------------------------------+
//|Desructor                                                         |
//+------------------------------------------------------------------+
void              CatalystBigBelt::~CatalystBigBelt()
  {
  }
//+------------------------------------------------------------------+
//| isbigBelt: is this a Big belt bar                                |
//+------------------------------------------------------------------+
catalystState      CatalystBigBelt::isBigBelt()
  {
   if(rttlThis == rttlHigh)
     {
      // check for bearish characteristics
      if(!(bFlow.ratesChartBars[1].open > bFlow.ratesChartBars[2].close))
         return catalystNone;
      if(isNear())
         return catalystShort;
     }
   else
      if(rttlThis == rttlLow)
        {
         // check for bullish characteristics
         if(!(bFlow.ratesChartBars[1].open < bFlow.ratesChartBars[2].close))
            return catalystNone;
         if(isNear())
            return catalystLong;
        }
   return catalystNone;
  }
//+------------------------------------------------------------------+
