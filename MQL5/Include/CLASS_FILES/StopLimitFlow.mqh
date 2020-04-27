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
   //bool              StopLimitFlow::isNear();
   //bool              StopLimitFlow::process(simState _catThis, int _ins);
   bool              StopLimitFlow::haveLimitATR();
   bool              StopLimitFlow::openBuySellMarketOrder(simState _catThis, int _ins);
   bool              StopLimitFlow::openBuySellStopOrder(simState _simThis,int _ins);
   double            StopLimitFlow::selectTarget(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs);
   double            StopLimitFlow::setByATR(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs);
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
//|Check atr limit has data                                          |
//+------------------------------------------------------------------+
bool              StopLimitFlow::haveLimitATR()
  {
   double tempGetAtrValues[];
   int startCandle = -1;
   for(int ins=0; (ins<ArraySize(this.instrumentPointers)); ins++)
     {
      if(instrumentPointers[ins].pContainerTip.Total()>0)
        {
         for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[ins].pContainerTip.Total()); instrumentTrend++)
           {
            Tip *tip = instrumentPointers[ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
            if((CheckPointer(tip)!=POINTER_INVALID) && (tip.waveHTFPeriod == instrumentPointers[ins].atrLimit.waveHTFPeriod))
              {
               startCandle = MathMin(ArraySize(tip.ratesThisTF)-1,this.maxBarsDegugRunTrend);
               if(CopyBuffer(instrumentPointers[ins].atrLimit.atrHandle,0,0,startCandle, tempGetAtrValues) < startCandle)
                 {
                  Print(__FUNCTION__," couldnt get atr values *ATRLIMIT -> want: ",startCandle, "  found: ",CopyBuffer(instrumentPointers[ins].atrLimit.atrHandle,0,0,startCandle, tempGetAtrValues)," ",instrumentPointers[ins].symbol," ",EnumToString(instrumentPointers[ins].atrLimit.waveHTFPeriod));
                  return false;
                 }
              }
           }
        }
     }
   return true;
  }
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
//| Market Order                                                     |
//+------------------------------------------------------------------+
bool StopLimitFlow::openBuySellMarketOrder(simState _simThis,int _ins)
  {
   bool condition = false;
   DiagTip *minorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
   if(_simThis == simLong)
     {
      double openAsk   = this.instrumentPointers[_ins].Ask();
      double buyStop =  MathMin(MathMin(minorTrend.ratesThisTF[1].low,minorTrend.ratesThisTF[2].low), minorTrend.ratesThisTF[0].low);
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
         double buyTarget = openAsk + this.tp*(MathMax(minorTrend.atrWaveInfo.atrWrapper.atrValue[0], (openAsk - buyStop)));
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
         double sellStop = MathMax(MathMax(minorTrend.ratesThisTF[1].high,minorTrend.ratesThisTF[2].high),minorTrend.ratesThisTF[0].high);
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
            double sellTarget = openBid - this.tp*(MathMax(minorTrend.atrWaveInfo.atrWrapper.atrValue[0],(sellStop-openBid)));
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

//+------------------------------------------------------------------+
//| open an Entry order                                              |
//+------------------------------------------------------------------+
bool StopLimitFlow::openBuySellStopOrder(simState _simThis,int _ins)
  {
   DiagTip *minorTrend=NULL;
   bool condition = false;
   if(_simThis == simLong)
     {
      double spread = instrumentPointers[_ins].Spread()*instrumentPointers[_ins].Point();
      double clearance  = deltaFireRoom * instrumentPointers[_ins].Point();
      minorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
      double entryAsk   = minorTrend.ratesThisTF[1].high + spread + clearance;
      double stopAsk    = spread + minorTrend.ratesThisTF[1].low - clearance;
      if(entryAsk<instrumentPointers[_ins].Bid())
        {
         Print(__FUNCTION__," entry price less than bid price");
         return condition;
        }
      // check lots to open big belt long
      double lots = CheckOpenLong(_ins,entryAsk,stopAsk);
      // open big belt long
      if(lots > 0)
        {
         double targetAsk = spread + selectTarget(_ins,entryAsk,stopAsk,ORDER_TYPE_BUY);
         if(targetAsk != 0.0)
           {
            // 3 candles because _Period in seconds ?
            datetime eTime = expireTime(candlesToExpire,_ins,TimeTradeServer());// = TimeTradeServer() + (candlesToExpire* (PeriodSeconds(minorTrend.waveHTFPeriod)/PeriodSeconds(_Period)) * _Period * 60);
            if(openBuyStopOrder(_ins,entryAsk,lots,stopAsk,targetAsk,eTime,catType))
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
         Print(__FUNCTION__, " lots <= zero: ", instrumentPointers[_ins].Name());
         return condition;
        }
     }
   else
      if(_simThis == simShort)
        {
         minorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
         double clearance = deltaFireRoom * instrumentPointers[_ins].Point();
         double entryBid = minorTrend.ratesThisTF[1].low - clearance;
         double stopBid = minorTrend.ratesThisTF[1].high + clearance;
         if(entryBid>instrumentPointers[_ins].Bid())
           {
            Print(__FUNCTION__," entry price less than bid price");
            return false;
           }
         // check lots to open big belt long
         double lots = CheckOpenShort(_ins,entryBid,stopBid);
         // open big belt long
         if(lots > 0)
           {
            double targetBid=selectTarget(_ins,entryBid,stopBid,ORDER_TYPE_SELL);//entryBid-100*instrumentPointers[_ins].Point();
            if(targetBid != 0.0)
              {
               // 3 candles because _Period in seconds ?
               datetime eTime = expireTime(candlesToExpire,_ins,TimeTradeServer());
               if(openSellStopOrder(_ins,entryBid,lots,stopBid,targetBid,eTime,catType))
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
            Print(__FUNCTION__, " lots <= zero: ", instrumentPointers[_ins].Name());
        }
   return condition;
  }
// +------------------------------------------------------------------+
// | openBuyStopOrder                                                 |
// +------------------------------------------------------------------+
//bool TradeFlow::openBuyStopOrder(int _ins,double _entryAsk, double _vol, double _stopAsk, double _targetAsk, datetime _expiration, string _catType)
//  {
//// uses ask (offer,Buy) price for entry stop and target
//// prices passed in are bid
//// CSymbolInfo instrumentPointers[_ins]=instrumentPointers[_ins].mySymbol;
//   string insName=instrumentPointers[_ins].Name();
//   double norEntryAsk      = NormalizeDouble(_entryAsk,instrumentPointers[_ins].Digits());
//   double norStopAsk       = NormalizeDouble(_stopAsk, instrumentPointers[_ins].Digits()); // --- Stop Loss
//   double norTargetAsk     = NormalizeDouble(_targetAsk, instrumentPointers[_ins].Digits()); // --- Take Profit
//   string comment=StringFormat("Buy Stop %s %s %G lots at %s, SL=%s TP=%s",
//                               _catType,
//                               instrumentPointers[_ins].Name(),_vol,
//                               DoubleToString(norEntryAsk, instrumentPointers[_ins].Digits()),
//                               DoubleToString(norStopAsk, instrumentPointers[_ins].Digits()),
//                               DoubleToString(norTargetAsk, instrumentPointers[_ins].Digits()));
////// --- open BuyStop order
//   if(myTrade.OrderOpen(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY_STOP,_vol,0.0,norEntryAsk,norStopAsk,norTargetAsk,ORDER_TIME_SPECIFIED,_expiration,comment))
//     {
//      // --- Request is completed or order placed
//      Alert("A BuyStop order has been successfully placed with Ticket#:",myTrade.ResultOrder(),"!!");
//      // instrumentPointers[_ins].pContainerLip.pSumLipElements.ToLog(__FUNCTION__, true);
//      return true;
//     }
//   else
//     {
//      string rcDesc = myTrade.ResultRetcodeDescription();
//      Alert("The BuyStop order request at vol:",myTrade.RequestVolume(),
//            ", sl:",myTrade.RequestSL(),", tp:",myTrade.RequestTP(),
//            ", price:",myTrade.RequestPrice(),
//            " could not be completed -error:",rcDesc);
//      return false;
//     }
//   return false;
//  }
//+------------------------------------------------------------------+
//| Stop Order                                                     |
//+------------------------------------------------------------------+
//bool StopLimitFlow::openBuySellStopOrder(simState _simThis,int _ins, datetime _expiration)
//  {
//   bool condition = false;
//   DiagTip *majorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(1);
//   if(_simThis == simLong)
//     {
//      double openAsk   = this.instrumentPointers[_ins].Ask();
//      double buyStop =  MathMin(MathMin(majorTrend.ratesThisTF[1].low,majorTrend.ratesThisTF[2].low), majorTrend.ratesThisTF[0].low);
//      buyStop = buyStop - deltaFireRoom * instrumentPointers[_ins].Point();
//      buyStop = NormalizeDouble(buyStop,instrumentPointers[_ins].Digits());
//      if(openAsk <= buyStop)
//        {
//         Print(__FUNCTION__," entry price less than bid price");
//         return condition;
//        }
//      double lots = CheckOpenLong(_ins,openAsk,buyStop);
//      if(lots > this.instrumentPointers[_ins].LotsMin())
//        {
//         double buyTarget = openAsk + this.tp*(MathMax(majorTrend.atrWaveInfo.atrWrapper.atrValue[0], (openAsk - buyStop)));
//         buyTarget = buyTarget+instrumentPointers[_ins].Spread()* instrumentPointers[_ins].Point();
//         // --- open BuyStop order
//         string comment=StringFormat("Buy Stop %s %s %G lots at %s, SL=%s TP=%s",
//                                     _simThis,
//                                     instrumentPointers[_ins].Name(),lots,
//                                     DoubleToString(openAsk, instrumentPointers[_ins].Digits()),
//                                     DoubleToString(buyStop, instrumentPointers[_ins].Digits()),
//                                     DoubleToString(buyTarget, instrumentPointers[_ins].Digits()));
//         if(this.myTrade.OrderOpen(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY_STOP,lots,0.0,openAsk,buyStop,buyTarget,ORDER_TIME_SPECIFIED,_expiration,comment))
//            condition = true;
//         else
//            condition = false;
//        }
//      else
//        {
//         Print(__FUNCTION__, "lots returned: ",lots," lots ", instrumentPointers[_ins].Name()," ",_simThis);
//         return condition;
//        }
//     }
//   else
//      if(_simThis == simShort)
//        {
//         double openBid    = this.instrumentPointers[_ins].Bid();
//         double sellStop = MathMax(MathMax(majorTrend.ratesThisTF[1].high,majorTrend.ratesThisTF[2].high),majorTrend.ratesThisTF[0].high);
//         sellStop = sellStop + this.instrumentPointers[_ins].Spread()* instrumentPointers[_ins].Point() + deltaFireRoom * instrumentPointers[_ins].Point();
//         sellStop = NormalizeDouble(sellStop,instrumentPointers[_ins].Digits());
//         if(openBid >= sellStop)
//           {
//            Print(__FUNCTION__," entry price less than bid price");
//            return false;
//           }
//         double lots = CheckOpenShort(_ins,openBid,sellStop);
//         if(lots > this.instrumentPointers[_ins].LotsMin())
//           {
//            double sellTarget = openBid - this.tp*(MathMax(majorTrend.atrWaveInfo.atrWrapper.atrValue[0],(sellStop-openBid)));
//            string comment=StringFormat("Buy Stop %s %s %G lots at %s, SL=%s TP=%s",
//                                        _simThis,
//                                        instrumentPointers[_ins].Name(),lots,
//                                        DoubleToString(openBid, instrumentPointers[_ins].Digits()),
//                                        DoubleToString(sellStop, instrumentPointers[_ins].Digits()),
//                                        DoubleToString(sellTarget, instrumentPointers[_ins].Digits()));
//            if(this.myTrade.OrderOpen(instrumentPointers[_ins].Name(),ORDER_TYPE_SELL_STOP,lots,0.0,openBid,sellStop,sellTarget,ORDER_TIME_SPECIFIED,_expiration,comment))
//               condition = true;
//            else
//               condition = false;
//           }
//         else
//           {
//            Print(__FUNCTION__, "lots returned: ",lots," lots ", instrumentPointers[_ins].Name()," ",_simThis);
//            return false;
//           }
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
//for(int x=1; (x<ArraySize(currLipe)); x++)
//  {
//   if(currLipe[x].levelPrice != 0)
//     {
//      // Check if @ least 1:1 ratio
//      if((MathAbs(_entryPrice-currLipe[x].levelPrice)/MathAbs(_entryPrice - _sl)) > 1)
//         return currLipe[x].levelPrice;
//     }
//   else
     {
      // Attempt setByATR
      double TP = setByATR(_ins,_entryPrice,_sl, _bs);
      // Check if @ least 1:1 ratio
      if((MathAbs(_entryPrice-tp)/MathAbs(_entryPrice - _sl)) > 1)
         return TP;
      else
        {
         Print(__FUNCTION__, " ATR value for tp: ",NormalizeDouble(tp,instrumentPointers[_ins].Digits()), " is less than 1:1 ratio ");
         return 0.0;
        }
     }
//  }
   Print(__FUNCTION__, "ArraySize(currLipe) <= 0: ",ArraySize(currLipe));
   return 0.0;
  }
//+------------------------------------------------------------------+
//|setByATR                                                          |
//+------------------------------------------------------------------+
double StopLimitFlow::setByATR(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs)
  {
   double atrVals[];
   if(CheckPointer(instrumentPointers[_ins].atrLimit)!=POINTER_INVALID)
     {
      ATRInfo *atr = instrumentPointers[_ins].atrLimit;
      if(CopyBuffer(atr.atrHandle, 0,1,1, atrVals) < 0)
         Print(__FUNCTION__, "Failed To Get Indicator Value: ",_ins," HTF2 Period ",atr.waveHTFPeriod);
      else
        {
         // set target
         if(_bs == ORDER_TYPE_BUY)
            return(_entryPrice + tp*atrVals[0]);
         else
            if(_bs == ORDER_TYPE_SELL)
               return(_entryPrice - tp*atrVals[0]);
        }
     }
   return 0.0;
  }
//+------------------------------------------------------------------+
