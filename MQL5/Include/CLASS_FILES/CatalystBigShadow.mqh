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
class CatalystBigShadow  : public CatalystMatch
  {
private:

public:
   catalystState     CatalystBigShadow::isBigShadow();
   bool              CatalystBigShadow::checkMoveStop(int _ins, ulong _ticket);
   bool              CatalystBigShadow::isEngulfing();   
                     CatalystBigShadow();
                    ~CatalystBigShadow();
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
void              CatalystBigShadow::CatalystBigShadow()
  {
  catType ="Big Shadow";
  }
//+------------------------------------------------------------------+
//|Desructor                                                         |
//+------------------------------------------------------------------+
void CatalystBigShadow::~CatalystBigShadow()
  {
  }
//+------------------------------------------------------------------+
//| isbigShadow: is this a Big belt bar                                |
//+------------------------------------------------------------------+
catalystState           CatalystBigShadow::isBigShadow()
  {
   if(rttlThis == rttlHigh)
     {
      // BEARISH
      // body bottom third of wick
      if(!isNear())
         return catalystNone;
      // biggest bar for some time
      if(!isBigRange())
         return catalystNone;
      // is a bearish engulfing candle
      if(isEngulfing())
         return catalystShort;
     }
   else
      if(rttlThis == rttlLow)
        {
         // BULLISH
         // body top third of wick
         if(!isNear())
            return catalystNone;
         // biggest bar for some time
         if(!isBigRange())
            return catalystNone;
         // is a bearish engulfing candle
         if(isEngulfing())
            return catalystLong;
        }
   return catalystNone;
  }
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//+------------------------------------------------------------------+
bool              CatalystBigShadow::checkMoveStop(int _ins, ulong _ticket)
  {
   bFlow.myPosition.SelectByTicket(_ticket);
   // ENUM_POSITION_TYPE posType = bFlow.myPosition.PositionType();
   if(isEngulfing())
     {
      tFlow.moveStop(_ins,_ticket);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Establish is engulfing pattern                                   |
//+------------------------------------------------------------------+
bool       CatalystBigShadow::isEngulfing()
  {
   double o = bFlow.ratesChartBars[1].open;
   double c = bFlow.ratesChartBars[1].close;
   double h = bFlow.ratesChartBars[1].high;
   double l = bFlow.ratesChartBars[1].low;
   if((h >= bFlow.ratesChartBars[2].high) && (l <= bFlow.ratesChartBars[2].low))
      return true;
   return false;
  }

//+------------------------------------------------------------------+
