//+------------------------------------------------------------------+
//|                                                StopLimitFlow.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CLASS_FILES\MonitorFlow.mqh>
class StopLimitFlow : public MonitorFlow
  {
private:

public:
   string            catType;
                     StopLimitFlow();
                    ~StopLimitFlow();
   bool              StopLimitFlow::isBigRange();
   bool              StopLimitFlow::isNear();
   //bool              StopLimitFlow::process(simState _catThis, int _ins);
   bool              StopLimitFlow::openBuySellMarketOrder(simState _catThis, int _ins);
   double            StopLimitFlow::selectTarget(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs);
   double            StopLimitFlow::setByATR(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs, ENUM_TIMEFRAMES _period);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StopLimitFlow::StopLimitFlow() {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StopLimitFlow::~StopLimitFlow() {}
//+------------------------------------------------------------------+
//| has bigger range than the previous (x) ~10 candles               |
//+------------------------------------------------------------------+
//bool       StopLimitFlow::isBigRange()
//  {
//   if(ArraySize(ratesChartBars)<10)
//      return false;
//   double h = ratesChartBars[1].high;
//   double l = ratesChartBars[1].low;
//   double wick = h-l;
//   for(int i = 2; i<11; i++)
//     {
//      if((ratesChartBars[i].high - ratesChartBars[i].low) >= 1.2* wick)
//         return false;
//     }
//   return true;
 // }
////+------------------------------------------------------------------+
////| Establish close near top or bottom 20%                           |
////+------------------------------------------------------------------+
//bool       StopLimitFlow::isNear()
//  {
//   double o = ratesChartBars[1].open;
//   double c = ratesChartBars[1].close;
//   double h = ratesChartBars[1].high;
//   double l = ratesChartBars[1].low;
//   double wick = h-l;
//   double lThreshold = l + wick*fracThreshHold ;
//   double hThreshold = h - wick*fracThreshHold ;
//   if(rttlThis == rttlHigh)
//     {
//      // check for bearish characteristics
//      if((o > hThreshold) && (c < lThreshold))
//         return true;
//     }
//   else
//      if(rttlThis == rttlLow)
//         // check for bullish characteristics
//        {
//         if((o < lThreshold) && (c > hThreshold))
//            return true;
//        }
//   return false;
//  }
//+------------------------------------------------------------------+
//| processBigShadow                                                 |
//| has cleared it for attempted open                                |
//| 3bar Low                                                         |
//+------------------------------------------------------------------+
bool StopLimitFlow::openBuySellMarketOrder(simState _simThis,int _ins)
  {
   bool condition = false;
   DiagTip *majorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(1);   
   if(_simThis == simLong)
     {
      double openAsk   = this.instrumentPointers[_ins].Ask();
      double buyStop =  MathMin(MathMin(majorTrend.ratesThisTF[1].low,majorTrend.ratesThisTF[2].low), majorTrend.ratesThisTF[0].low);
      buyStop = buyStop - deltaFireRoom * instrumentPointers[_ins].Point();
      buyStop = NormalizeDouble(buyStop,instrumentPointers[_ins].Digits());
      if(openAsk <= buyStop)
        {
         Print(__FUNCTION__," entry price less than bid price");
         return condition;
        }
      double lots = CheckOpenLong(_ins,openAsk,buyStop);
      if(lots > this.instrumentPointers[_ins].LotsMin())
        {
         double buyTarget = openAsk + this.tp*(MathMax(majorTrend.atrWaveInfo.atrWrapper.atrValue[0], (openAsk - buyStop)));
         buyTarget = buyTarget+instrumentPointers[_ins].Spread()* instrumentPointers[_ins].Point();
         if(this.myTrade.Buy(lots,instrumentPointers[_ins].symbol,openAsk,buyStop,buyTarget))
            condition = true;
         else
            condition = false;
        }
      else
        {
         Print(__FUNCTION__, "lots returned: ",lots," lots ", instrumentPointers[_ins].Name()," ",_simThis);
         return condition;
        }
     }
   else
      if(_simThis == simShort)
        {
         double openBid    = this.instrumentPointers[_ins].Bid();
         double sellStop = MathMax(MathMax(majorTrend.ratesThisTF[1].high,majorTrend.ratesThisTF[2].high),majorTrend.ratesThisTF[0].high);
         sellStop = sellStop + this.instrumentPointers[_ins].Spread()* instrumentPointers[_ins].Point() + deltaFireRoom * instrumentPointers[_ins].Point();
         sellStop = NormalizeDouble(sellStop,instrumentPointers[_ins].Digits());
         if(openBid >= sellStop)
           {
            Print(__FUNCTION__," entry price less than bid price");
            return false;
           }
         double lots = CheckOpenShort(_ins,openBid,sellStop);
         if(lots > this.instrumentPointers[_ins].LotsMin())
           {
            double sellTarget = openBid - this.tp*(MathMax(majorTrend.atrWaveInfo.atrWrapper.atrValue[0],(sellStop-openBid)));
            if(this.myTrade.Sell(lots,instrumentPointers[_ins].symbol,openBid,sellStop,sellTarget))
               condition = true;
            else
               condition = false;
           }
         else
           {
            Print(__FUNCTION__, "lots returned: ",lots," lots ", instrumentPointers[_ins].Name()," ",_simThis);
            return false;
           }
        }
   return condition;
  }
////+------------------------------------------------------------------+
////| processBigShadow                                                 |
////+------------------------------------------------------------------+
//bool StopLimitFlow::process(simState _simThis,int _ins)
//  {
//   bool condition = false;
//   if(_simThis == simLong)
//     {
//      double spread = instrumentPointers[_ins].Spread()*instrumentPointers[_ins].Point();
//      double clearance  = 0;//myTrade.deltaFireRoom * instrumentPointers[_ins].Point();
//      double entryAsk   = ratesChartBars[1].high + spread + clearance;
//      double stopAsk    = spread + ratesChartBars[1].low - clearance; // entryAsk - 100 * instrumentPointers[_ins].Point();
//      if(entryAsk<instrumentPointers[_ins].Bid())
//        {
//         Print(__FUNCTION__," entry price less than bid price");
//         return condition;
//        }
//      // check lots to open big belt long
//      double lots = CheckOpenLong(_ins,entryAsk,stopAsk);
//      // open big belt long
//      if(lots > 0)
//        {
//         double targetAsk= spread + selectTarget(_ins,entryAsk,stopAsk,ORDER_TYPE_BUY);//entryAsk + 100*instrumentPointers[_ins].Point();
//         if(targetAsk != 0.0)
//           {
//            // 3 candles because _Period in seconds ?
//            datetime expireTime = TimeTradeServer() + (datumCandlesToExpire * _Period * 60);
//            if(openBuyStopOrder(_ins,entryAsk,lots,stopAsk,targetAsk,expireTime,catType))
//               condition = true;
//            else
//               condition = false;
//           }
//         else
//           {
//            Print(__FUNCTION__, " targetAsk from selectTarget returned zero: ");
//            return false;
//           }
//        }
//      else
//        {
//         Print(__FUNCTION__, " lots <= zero: ", instrumentPointers[_ins].Name());
//         return condition;
//        }
//     }
//   else
//      if(_simThis == simShort)
//        {
//         double clearance = 0;// myTrade.deltaFireRoom * instrumentPointers[_ins].Point();
//         double entryBid = ratesChartBars[1].low - clearance;
//         double stopBid = ratesChartBars[1].high + clearance;//entryBid+100*instrumentPointers[_ins].Point();
//         if(entryBid>instrumentPointers[_ins].Bid())
//           {
//            Print(__FUNCTION__," entry price less than bid price");
//            return false;
//           }
//         // check lots to open big belt long
//         double lots = CheckOpenShort(_ins,entryBid,stopBid);
//         // open big belt long
//         if(lots > 0)
//           {
//            double targetBid=selectTarget(_ins,entryBid,stopBid,ORDER_TYPE_SELL);//entryBid-100*instrumentPointers[_ins].Point();
//            if(targetBid != 0.0)
//              {
//               // 3 candles because _Period in seconds ?
//               datetime expireTime = TimeTradeServer() + (datumCandlesToExpire * _Period * 60);
//               if(openSellStopOrder(_ins,entryBid,lots,stopBid,targetBid,expireTime,catType))
//                  condition = true;
//               else
//                  condition = false;
//              }
//            else
//              {
//               Print(__FUNCTION__, " targetBid from selectTarget returned zero: ");
//               return false;
//              }
//           }
//         else
//            Print(__FUNCTION__, " lots <= zero: ", instrumentPointers[_ins].Name());
//        }
//   return condition;
//  }
//+------------------------------------------------------------------+
//|selectTarget  Currently finds a@  least 1:1 ratio or sets by ATR  |
//+------------------------------------------------------------------+
double              StopLimitFlow::selectTarget(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs)
  {
//uses bids
// instrumentPointers[_ins].Name();
// iterate the (3) levels that are available from MonitorFlow module
   for(int x=1; (x<ArraySize(currLipe)); x++)
     {
      if(currLipe[x].levelPrice != 0)
        {
         // Check if @ least 1:1 ratio
         if((MathAbs(_entryPrice-currLipe[x].levelPrice)/MathAbs(_entryPrice - _sl)) > 1)
            return currLipe[x].levelPrice;
        }
      else
        {
         // Attempt setByATR
         double TP = setByATR(_ins,_entryPrice,_sl, _bs,_Period);
         // Check if @ least 1:1 ratio
         if((MathAbs(_entryPrice-tp)/MathAbs(_entryPrice - _sl)) > 1)
            return TP;
         else
           {
            Print(__FUNCTION__, " ATR value for tp: ",NormalizeDouble(tp,instrumentPointers[_ins].Digits()), " is less than 1:1 ratio ");
            return 0.0;
           }
        }
     }
   Print(__FUNCTION__, "ArraySize(currLipe) <= 0: ",ArraySize(currLipe));
   return 0.0;
  }
//+------------------------------------------------------------------+
//|setByATR                                                          |
//+------------------------------------------------------------------+
double StopLimitFlow::setByATR(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs, ENUM_TIMEFRAMES _period)
  {
//// 1. get the atr handle for the chart tf
//// 2. establish if have values and set if found
//// 3. else use values to calculate profit target 3*ATR
//   ATRInfo *atr = NULL;
//   if(instrumentPointers[_ins].pContainerLip.Total()>0)
//     {
//      // ** CHECK FOR NEW TREND DATA FOR EACH ACTIVE PERIOD
//      for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerLip.Total()); instrumentTrend++)
//        {
//         if(CheckPointer(instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(instrumentTrend))!=POINTER_INVALID)
//           {
//            atr = instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(instrumentTrend);
//            if(atr.waveHTFPeriod == _period)
//              {
//               int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
//               if(numValues < 0)
//                 {
//                  Print(__FUNCTION__, "failed to get indicator value: ",_ins," _Period ",_period);
//                  return 0.0;
//                 }
//               else
//                 {
//                  // set target
//                  if(_bs == ORDER_TYPE_BUY)
//                    {
//                     double TP = _entryPrice+3*atr.atrWrapper.atrValue[0];
//                     return TP;
//                    }
//                  else
//                     if(_bs == ORDER_TYPE_SELL)
//                       {
//                        double TP = _entryPrice-3*atr.atrWrapper.atrValue[0];
//                        return TP;
//                       }
//                 }
//              }
//           }
//        }
//     }
   return 0.0;
  }
//+------------------------------------------------------------------+
