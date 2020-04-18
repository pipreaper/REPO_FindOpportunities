//+------------------------------------------------------------------+
//|                                                     BigBar.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CLASS_FILES\CatalystMatch.mqh>
class BarFlow;
class CatalystKangaroo  : public CatalystMatch
  {
private:

public:
                     CatalystKangaroo();
                    ~CatalystKangaroo();
   catalystState     CatalystKangaroo::isKangaroo();
   bool              CatalystKangaroo::isThird();
   bool              CatalystKangaroo::isInRange();
   // Move stop
   bool              CatalystKangaroo::checkMoveStop(int _ins, ulong _ticket);
   // check extreme candle
   bool              CatalystKangaroo::isExtremum(ENUM_POSITION_TYPE _posType);
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
void              CatalystKangaroo::CatalystKangaroo()
  {
   catType ="Kangaroo";
  }
//+------------------------------------------------------------------+
//|Desructor                                                         |
//+------------------------------------------------------------------+
void CatalystKangaroo::~CatalystKangaroo() {}
//+------------------------------------------------------------------+
//| iskangaroo: is this a Big belt bar                               |
//+------------------------------------------------------------------+
catalystState     CatalystKangaroo::isKangaroo()
  {
   if(rttlThis == rttlHigh)
     {
      // BEARISH
      // red candle body in range
      if(!isInRange())
         return catalystNone;
      // body bottom third of wick
      if(!isThird())
         return catalystNone;
      if(isBigRange())
         return catalystShort;
     }
   else
      if(rttlThis == rttlLow)
        {
         // BULLISH
         // green candle body in range
         if(!isInRange())
            return catalystNone;
         // body top third of wick
         if(!isThird())
            return catalystNone;
         if(isBigRange())
            return catalystLong;
        }
   return catalystNone;
  }
//+------------------------------------------------------------------+
//| Body is in top/bottom third of wick                              |
//+------------------------------------------------------------------+
bool       CatalystKangaroo::isThird()
  {
   double o = this.bFlow.ratesChartBars[1].open;
   double c = this.bFlow.ratesChartBars[1].close;
   double h = this.bFlow.ratesChartBars[1].high;
   double l = this.bFlow.ratesChartBars[1].low;
   double wick = h-l;
   double lThreshold = l + wick*0.33;
   double hThreshold = h - wick*0.33;
   if(rttlThis == rttlHigh)
     {
      // check for bearish characteristics
      if((o < lThreshold) && (c < lThreshold))
         return true;
     }
   else
      if(rttlThis == rttlLow)
         // check for bullish characteristics
        {
         if((o > hThreshold) && (c > hThreshold))
            return true;
        }
   return false;
  }
//+------------------------------------------------------------------+
//| candle in range of previous and green or red                     |
//+------------------------------------------------------------------+
bool       CatalystKangaroo::isInRange()
  {
// check for bearish characteristics
// red candle
   if(rttlThis == rttlHigh)
     {
      if(this.bFlow.ratesChartBars[1].open < this.bFlow.ratesChartBars[1].close)
         return false;
     }
//  green candle
   else
      if(rttlThis == rttlLow)
         // check for bullish characteristics
        {
         if(this.bFlow.ratesChartBars[1].open > this.bFlow.ratesChartBars[1].close)
            return false;
        }
// Check bar[1] open and close is nested in the previous range
   double ocMin = MathMin(this.bFlow.ratesChartBars[1].open,this.bFlow.ratesChartBars[1].close);
   double ocMax = MathMax(this.bFlow.ratesChartBars[1].open,this.bFlow.ratesChartBars[1].close);
   if((ocMin  < this.bFlow.ratesChartBars[2].low) || (ocMax  > this.bFlow.ratesChartBars[2].high))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//+------------------------------------------------------------------+
bool              CatalystKangaroo::checkMoveStop(int _ins, ulong _ticket)
  {
   bFlow.myPosition.SelectByTicket(_ticket);
   ENUM_POSITION_TYPE posType = bFlow.myPosition.PositionType();
   if(isExtremum(posType))
     {
      tFlow.moveStop(_ins,_ticket);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Establish is extremum price pattern has occured according to the |
//| following logic                                                  |
//+------------------------------------------------------------------+
bool       CatalystKangaroo::isExtremum(ENUM_POSITION_TYPE _posType)
  {
   double o = this.bFlow.ratesChartBars[1].open;
   double c = this.bFlow.ratesChartBars[1].close;
   double h = this.bFlow.ratesChartBars[1].high;
   double l = this.bFlow.ratesChartBars[1].low;
   double wick = h-l;
   double lThreshold = l + wick*0.5;
   double hThreshold = h - wick*0.5;
   if(_posType == POSITION_TYPE_BUY)
     {
      if((o < lThreshold) && (c < lThreshold))
         return true;
     }
   else
      if(_posType == POSITION_TYPE_SELL)
        {
           {
            if((o > hThreshold) && (c > hThreshold))
               return true;
           }
        }
   return false;
  }
//+------------------------------------------------------------------+
