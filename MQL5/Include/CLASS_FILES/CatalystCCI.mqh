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
class CatalystCCI  : public CatalystMatch
  {
private:
   int               targetZone;
   double            stopTargetsArray[];
public:
                     CatalystCCI();
                    ~CatalystCCI();
   catalystState     CatalystCCI::isCCI();
   bool              CatalystCCI::isThird();
   bool              CatalystCCI::isInRange();
   // set stop target by atr
   void              CatalystCCI::cciSetStopTargetsByATR(int _ins, double _marketBidPrice,ENUM_ORDER_TYPE _bs);
   //
   bool              CatalystCCI::process(catalystState _catThis, int _ins);
   // Move stop
   bool              CatalystCCI::checkMoveStop(int _ins, ulong _ticket);
   // check extreme candle
   bool              CatalystCCI::isExtremum(ENUM_POSITION_TYPE _posType);
   void              CatalystCCI::initCatalyst(BarFlow &_bFlow, MonitorFlow &_mFlow, TradeOps &_tFlow, int targetZone);
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
void              CatalystCCI::CatalystCCI()
  {
   catType ="CCI";
  }
//+------------------------------------------------------------------+
//|Desructor                                                         |
//+------------------------------------------------------------------+
void CatalystCCI::~CatalystCCI() {}
//+------------------------------------------------------------------+
//|initCatalyst                                                      |
//+------------------------------------------------------------------+
void CatalystCCI::initCatalyst(BarFlow &_bFlow, MonitorFlow &_mFlow, TradeOps &_tFlow, int _targetZone)
  {
   targetZone = _targetZone;
   bFlow = GetPointer(_bFlow);
   mFlow = GetPointer(_mFlow);
   tFlow = GetPointer(_tFlow);
  }
////+------------------------------------------------------------------+
////| iskangaroo: is this a Big belt bar                               |
////+------------------------------------------------------------------+
//catalystState     CatalystCCI::isCCI()
//  {
//   if(rttlThis == rttlHigh)
//     {
//      // BEARISH
//      return catalystLong;
//     }
//   else
//      if(rttlThis == rttlLow)
//        {
//         // BULLISH
//         return catalystShort;
//        }
//   return catalystNone;
//  }
//+------------------------------------------------------------------+
//| processBigShadow                                                 |
//+------------------------------------------------------------------+
bool CatalystCCI::process(catalystState _catalystThis,int _ins)
  {
   bool condition = false;
   if(_catalystThis == catalystLong)
     {
      double spread = bFlow.instrumentPointers[_ins].mySymbol.Spread()*bFlow.instrumentPointers[_ins].mySymbol.Point();
      double marketAsk = bFlow.instrumentPointers[_ins].mySymbol.Bid() + spread;

      // get atr stop target values
      ArrayResize(stopTargetsArray,0);
      cciSetStopTargetsByATR(_ins,marketAsk,ORDER_TYPE_BUY);
      if(ArraySize(stopTargetsArray) < 4)
         return condition;
      // check lots to open big belt long
      double lots = tFlow.CheckOpenLong(_ins, marketAsk, stopTargetsArray[0]);
      // open big belt long
      if(lots > 0)
        {
         //    double targetAsk= spread + selectTarget(_ins,bFlow.instrumentPointers[_ins].mySymbol.Bid(),stopAsk,ORDER_TYPE_BUY);//entryAsk + 100*bFlow.instrumentPointers[_ins].mySymbol.Point();
         if(stopTargetsArray[targetZone] != 0.0)
           {
            if(tFlow.openBuyPosition(_ins,bFlow.instrumentPointers[_ins].mySymbol.Bid(),lots,stopTargetsArray[0],stopTargetsArray[targetZone],catType))
               condition = true;
            else
               condition = false;
           }
         else
           {
            Print(__FUNCTION__, " targetAsk from selectTarget returned zero: ");
            return false;
           }
        }
      else
        {
         Print(__FUNCTION__, " lots <= zero: ", bFlow.instrumentPointers[_ins].mySymbol.Name());
         return condition;
        }
     }
   else
      if(_catalystThis == catalystShort)
        {
         double marketBid = bFlow.instrumentPointers[_ins].mySymbol.Bid();
         // get atr stop target values
         ArrayResize(stopTargetsArray,0);
         cciSetStopTargetsByATR(_ins,marketBid,ORDER_TYPE_SELL);
         if(ArraySize(stopTargetsArray) < 4)
            return condition;
         // check lots to open cci long
         double lots = tFlow.CheckOpenShort(_ins,marketBid,stopTargetsArray[0]);
         // open big belt long
         if(lots > 0)
           {
            if(stopTargetsArray[targetZone] != 0.0)
              {
               if(tFlow.openSellPosition(_ins,marketBid,lots,stopTargetsArray[0],stopTargetsArray[targetZone],catType))
                  condition = true;
               else
                  condition = false;
              }
            else
              {
               Print(__FUNCTION__, " targetBid from selectTarget returned zero: ");
               return false;
              }
           }
         else
            Print(__FUNCTION__, " lots <= zero: ", bFlow.instrumentPointers[_ins].mySymbol.Name());
        }
   return condition;
  }
//+------------------------------------------------------------------+
//|cciSetStopTargetsByATR                                            |
//| ** associated with TREND **                                      |
//|currently uses wiggle atr to set stops and targets                |
//+------------------------------------------------------------------+
void CatalystCCI::cciSetStopTargetsByATR(int _ins, double _marketBidOrAsk,ENUM_ORDER_TYPE _bs)
  {
//  set to chart index if zero index = first trend index
   ENUM_TIMEFRAMES atrPeriod = bFlow.tfDataTrend.useTF[bFlow.tfDataTrend.trendIndex[0]];
   ATRInfo *atr = NULL;
   int tot = bFlow.instrumentPointers[_ins].pContainerTip.Total();
   if(bFlow.instrumentPointers[_ins].pContainerTip.Total()>0)
     {
      // ** CHECK FOR NEW TREND DATA FOR EACH ACTIVE PERIOD
      for(int instrumentTrend=0; (instrumentTrend<bFlow.instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
        {

         if(CheckPointer(bFlow.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend))!=POINTER_INVALID)
           {
            Tip *tip = bFlow.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
            if(CheckPointer(bFlow.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend))!=POINTER_INVALID)
              {
               atr = tip.atrWaveInfo;
               if(atr.waveHTFPeriod == atrPeriod)
                 {
                  int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
                  if(numValues < 0)
                    {
                     Print(__FUNCTION__, "failed to get indicator value: ",_ins," _Period ",atrPeriod);
                     return;
                    }
                  else
                    {
                     // set target
                     if(_bs == ORDER_TYPE_BUY)
                       {
                        ArrayResize(stopTargetsArray,4);
                        stopTargetsArray[0]= _marketBidOrAsk - bFlow.sl*atr.atrWrapper.atrValue[0];
                        stopTargetsArray[1]= _marketBidOrAsk + bFlow.tp*atr.atrWrapper.atrValue[0];
                        stopTargetsArray[2]= _marketBidOrAsk + 2*bFlow.tp*atr.atrWrapper.atrValue[0];
                        stopTargetsArray[3]= _marketBidOrAsk + 3*bFlow.tp*atr.atrWrapper.atrValue[0];
                        return;
                       }
                     else
                        if(_bs == ORDER_TYPE_SELL)
                          {
                           ArrayResize(stopTargetsArray,4);
                           stopTargetsArray[0]= _marketBidOrAsk + bFlow.sl*atr.atrWrapper.atrValue[0];
                           stopTargetsArray[1]= _marketBidOrAsk - bFlow.tp*atr.atrWrapper.atrValue[0];
                           stopTargetsArray[2]= _marketBidOrAsk - 2*bFlow.tp*atr.atrWrapper.atrValue[0];
                           stopTargetsArray[3]= _marketBidOrAsk - 3*bFlow.tp*atr.atrWrapper.atrValue[0];
                           return;
                          }
                    }
                 }
              }
            else
               Print(__FUNCTION__, "Failed to get atr null Pointer");
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Body is in top/bottom third of wick                              |
//+------------------------------------------------------------------+
bool       CatalystCCI::isThird()
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
bool       CatalystCCI::isInRange()
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
bool              CatalystCCI::checkMoveStop(int _ins, ulong _ticket)
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
bool       CatalystCCI::isExtremum(ENUM_POSITION_TYPE _posType)
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
