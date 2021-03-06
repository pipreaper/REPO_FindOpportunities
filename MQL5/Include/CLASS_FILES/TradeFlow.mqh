//+------------------------------------------------------------------+
//|                                                     TradeFlow.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#include <Arrays\List.mqh>
#include <CLASS_FILES\RatesFlow.mqh>
#include <INCLUDE_FILES\waveLibrary.mqh>
class TradeFlow : public RatesFlow
  {
private:

public:
   double            pBuyStop;
   void              TradeFlow::TradeFlow();
   //  void              TradeFlow::initTradeFlow(BarFlow &_barFlow, double _riskPerTrade);
   //  bool              TradeFlow::setChartInsBars(int _ins, int _reqBars);
   // get lots for long
   double            TradeFlow::CheckOpenLong(int _ins, double _price,double _sl);
   // get lots for short
   double            TradeFlow::CheckOpenShort(int _ins, double _price,double _sl);
   // Cancel All Symbols for magic
   void              TradeFlow::cancelAllSymbolOrders(string _sym, long _magic);
   //  Cancel orders not in trend direction
   void              TradeFlow::cancelAllDirectionSymbolOrders(string _sym, long _magic, trendState _ts);
   //void              TradeFlow::updateCCIStates(int _ins, int _index);
   cciClicked        TradeFlow::cciGetState(int _ins, int _index);
   // Count Total Positions for this expertSymbol
   int               TradeFlow::countPositions(int eaMagic,string symbol);
   // Count Total Orders for this expert/symbol
   int               TradeFlow::countOrders(int eaMagic,string symbol);
   bool              TradeFlow::deleteStopBuyOrders(int _eaMagic,string _symbol)   ;
   datetime          TradeFlow::expireTime(int numCandles, int _ins,datetime _baseTime);
   // return ticket for first found position for instrument  order or NULL
   ulong             TradeFlow::findFirstPositon(string insName);
   // return ticket for existing instrument entry order or NULL
   int               TradeFlow::findEntryOrder(string insName);
   // check for engulfing stop signal
   bool              TradeFlow::isEngulfing();
   bool              TradeFlow::moveStop(int _ins, ulong _ticket);
   bool              TradeFlow::moveAllStops(int _ins);
   bool              TradeFlow::openBuyStopOrder(int _ins,double prevBidHigh, double _vol, double _sl, double _tp, datetime _expiration, string _catType);
   bool              TradeFlow::openSellStopOrder(int _ins,double prevBidHigh, double _vol, double _sl, double _tp, datetime _expiration, string _catType);
   bool              TradeFlow::openBuyPosition(int _ins,double _marketBid, double _vol, double _stopBid, double _targetBid, string _catType);
   bool              TradeFlow::openSellPosition(int _ins,double _marketBid, double _vol, double _stopBid, double _targetBid, string _catType);
   bool              TradeFlow::orderSetupFailed(string _sym, int _eaMagic);
   bool              TradeFlow::profitProgressInsufficientPoints(int _ins, int _sufficientTargetPercent);
   bool              TradeFlow::profitProgressExcessTime(int _ins);
   double            TradeFlow::cciGetValue(int _ins, int _index,int _candleIndex);
   // open Buy limit order
   // bool              TradeFlow::openBuyOrder(int _ins, double _sl, double _tp, double _atrValue);
   // open Sell limit order
   // bool              TradeFlow::openSellOrder(int _ins, double _sl, double _tp, double _atrValue);
   // wave @ index is congested up leg formed
   // bool              TradeFlow::isCongestedUpWave(int _ins, int index);
   // wave @ index is congested down leg formed
   //bool              TradeFlow::isCongestedDownWave(int _ins, int index);
   void              TradeFlow::~TradeFlow();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
TradeFlow::TradeFlow()
  {
   pBuyStop = -1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
TradeFlow::~TradeFlow()
  {
   Clear();
  }
// +------------------------------------------------------------------+
// | get CCI value                                                    |
// +------------------------------------------------------------------+
double  TradeFlow::cciGetValue(int _ins, int _index,int _candleIndex)
  {
   Tip *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
   if(CheckPointer(tip)!=POINTER_INVALID)
      return tip.cciWaveInfo.getCCIValue(_candleIndex);
   return -INF;
  }
// +------------------------------------------------------------------+
// | get CCI state                                                    |
// +------------------------------------------------------------------+
cciClicked  TradeFlow::cciGetState(int _ins, int _index)
  {
   Tip *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
   if(CheckPointer(tip)!=POINTER_INVALID)
      return tip.cciWaveInfo.getCCIState();
   return cciNone;
  }
//+------------------------------------------------------------------+
//| expire time of Trend2 Position or Order                          |
//| based on Trend1 that may be same as_Period/or not!               |
//+------------------------------------------------------------------+
datetime TradeFlow::expireTime(int numCandles, int _ins, datetime _baseTime)
  {
   DiagTip *minorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
   return(_baseTime + (numCandles * (PeriodSeconds(minorTrend.waveHTFPeriod)/PeriodSeconds(_Period)) * _Period * 60)) ;
  }
//+------------------------------------------------------------------+
//close trade on too long time exposure                              |
//+------------------------------------------------------------------+
bool              TradeFlow::profitProgressExcessTime(int _ins)
  {
   bool condition = false;
// have a Ticket Open?
ulong ticket = findFirstPositon(instrumentPointers[_ins].symbol);
   if(int(ticket) >= 0)
     {
 //     ulong ticket = findFirstPositon(instrumentPointers[_ins].symbol);
      myPosition.SelectByTicket(findFirstPositon(instrumentPointers[_ins].symbol));
      if(expireTime(candlesToExpire, _ins, myPosition.Time()) < TimeTradeServer())
         // time to check if the profit is sufficient at this advanced time
         condition = true;
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| close Position on too little profit/time                         |
//+------------------------------------------------------------------+
bool              TradeFlow::profitProgressInsufficientPoints(int _ins, int _sufficientTargetPercent)
  {
   bool   condition = false;
// have a Ticket Open?
ulong ticket = findFirstPositon(instrumentPointers[_ins].symbol);
   if(int(ticket) >= 0)
     {
  //    ulong ticket = findFirstPositon(instrumentPointers[_ins].symbol);
      myPosition.SelectByTicket(findFirstPositon(instrumentPointers[_ins].symbol));
      if((MathMod(myPosition.PriceCurrent(), myPosition.PriceOpen()) / MathMod(myPosition.TakeProfit(),myPosition.PriceOpen()))*100 < _sufficientTargetPercent)
         condition = true;
     }
   return condition;
  }
//// +------------------------------------------------------------------+
//// |closePositions if second trend or higher is gone                 |
//// |returns true if trade closed otherwise false trend intact up/down |
//// +------------------------------------------------------------------+
//bool  TradeFlow::closeOneTradeOnTrendFailure(int _ins, int _index)
//  {
//   trendState thisTrendState = mFlow.trendGetState(_ins,_index);
//   bool condition = false;
//// trendState tsBuy = isValidBuyTrend(_ins, index);
//// trendState tsSell = isValidSellTrend(_ins, index);
//// get the first by symbol and magic
//   ulong ticket = findFirstPositon(instrumentPointers[_ins].Name());
//   if(ticket<=0)
//     {
//      Alert(__FUNCTION__," have no trades open for instrument: ",instrumentPointers[_ins].Name(), " but cannot find it in positions table");
//      return true;
//     }
//   myPosition.SelectByTicket(ticket);
//   if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) && (thisTrendState == congested))
//      // needs closed
//      condition=true;
//   else
//      if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) && (thisTrendState == congested))
//         condition=true;
//// trend is congested so close it
//   if(!condition)
//      return false;
//   Print(__FUNCTION__," Attempting to close on Trend failure trades for: ",instrumentPointers[_ins].Name());
//// allow 10 deletion attempts before reporting a failure
//   int counter = 10;
//// target position is already selected above .Select first symbol by magic?
//   do
//     {
//      if(myTrade.PositionClose(ticket, dev))
//        {
//         Sleep(100);
//         return true;
//        }
//      else
//         if(counter > 0)
//            counter -=1;
//         else
//           {
//            Alert(__FUNCTION__," Not closing out position: ",myTrade.PositionClose(instrumentPointers[_ins].Name()));
//            //  return cancel entry orders but failed to close open position
//            return true;
//           }
//     }
//   while(counter > 0);
//   return condition;
//  }
// +------------------------------------------------------------------+
// | openBuyStopOrder                                                 |
// +------------------------------------------------------------------+
bool TradeFlow::openBuyStopOrder(int _ins,double _entryAsk, double _vol, double _stopAsk, double _targetAsk, datetime _expiration, string _catType)
  {
// uses ask (offer,Buy) price for entry stop and target
// prices passed in are bid
// CSymbolInfo instrumentPointers[_ins]=instrumentPointers[_ins].mySymbol;
   string insName=instrumentPointers[_ins].Name();
   double norEntryAsk      = NormalizeDouble(_entryAsk,instrumentPointers[_ins].Digits());
   double norStopAsk       = NormalizeDouble(_stopAsk, instrumentPointers[_ins].Digits()); // --- Stop Loss
   double norTargetAsk     = NormalizeDouble(_targetAsk, instrumentPointers[_ins].Digits()); // --- Take Profit
   string comment=StringFormat("Buy Stop %s %s %G lots at %s, SL=%s TP=%s",
                               _catType,
                               instrumentPointers[_ins].Name(),_vol,
                               DoubleToString(norEntryAsk, instrumentPointers[_ins].Digits()),
                               DoubleToString(norStopAsk, instrumentPointers[_ins].Digits()),
                               DoubleToString(norTargetAsk, instrumentPointers[_ins].Digits()));
//// --- open BuyStop order
   if(myTrade.OrderOpen(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY_STOP,_vol,0.0,norEntryAsk,norStopAsk,norTargetAsk,ORDER_TIME_SPECIFIED,_expiration,comment))
     {
      // --- Request is completed or order placed
      Alert("A BuyStop order has been successfully placed with Ticket#:",myTrade.ResultOrder(),"!!");
      // instrumentPointers[_ins].pContainerLip.pSumLipElements.ToLog(__FUNCTION__, true);
      return true;
     }
   else
     {
      string rcDesc = myTrade.ResultRetcodeDescription();
      Alert("The BuyStop order request at vol:",myTrade.RequestVolume(),
            ", sl:",myTrade.RequestSL(),", tp:",myTrade.RequestTP(),
            ", price:",myTrade.RequestPrice(),
            " could not be completed -error:",rcDesc);
      return false;
     }
   return false;
  }
// +------------------------------------------------------------------+
// | openSellStopOrder                                                |
// +------------------------------------------------------------------+
bool TradeFlow::openSellStopOrder(int _ins,double _entryBid, double _vol, double _stopBid, double _targetBid, datetime _expiration, string _catType)
  {
// uses bid (Sell) price for entry stop and target
// prices passed in are bid
//   CSymbolInfo instrumentPointers[_ins]=instrumentPointers[_ins].mySymbol;
   string insName=instrumentPointers[_ins].Name();
   double norEntryBid   =NormalizeDouble(_entryBid, instrumentPointers[_ins].Digits());               // --- Sell price
   double norStopBid    = NormalizeDouble(_stopBid, instrumentPointers[_ins].Digits()); // --- Stop Loss
   double norTargetBid  = NormalizeDouble(_targetBid, instrumentPointers[_ins].Digits()); // --- Take Profit
   string comment=StringFormat("Sell Stop %s %s %G lots at %s, SL=%s TP=%s",
                               _catType,
                               instrumentPointers[_ins].Name(),_vol,
                               DoubleToString(norEntryBid,instrumentPointers[_ins].Digits()),
                               DoubleToString(norStopBid,instrumentPointers[_ins].Digits()),
                               DoubleToString(norTargetBid,instrumentPointers[_ins].Digits()));
// --- Open SellStop Order
   if(myTrade.OrderOpen(instrumentPointers[_ins].Name(),ORDER_TYPE_SELL_STOP,_vol,0.0,norEntryBid,norStopBid,norTargetBid,ORDER_TIME_SPECIFIED,_expiration,comment))
     {
      // Request is completed or order placed
      Alert("A SellStop order has been successfully placed with Ticket#:",myTrade.ResultOrder(),"!!");
      // instrumentPointers[_ins].pContainerLip.pSumLipElements.ToLog(__FUNCTION__, true);
      //Print(__FUNCTION__," ** ADDED ENTRY ORDER SELL STOP, trend: ",tipEnumToString(_ts));
      return true;
     }
   else
     {
      string rcDesc = myTrade.ResultRetcodeDescription();
      Alert("The SellStop order request at vol:",myTrade.RequestVolume(),
            ", sl:",myTrade.RequestSL(),", tp:",myTrade.RequestTP(),
            ", price:",myTrade.RequestPrice(),
            " could not be completed -error:",rcDesc);
      return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Getting lot size for open long position.                         |
//+------------------------------------------------------------------+
double TradeFlow::CheckOpenLong(int _ins, double _price,double _sl)
  {
//uses bid prices
   if(instrumentPointers[_ins].Name()==NULL)
      return(0.0);
   double allowedLots=0, lots=0,  idealLots=0, marginPerLot=0, lossPerLot=0, stepVol=0;
   double minvol=instrumentPointers[_ins].LotsMin();
   if(_sl==0.0)
      lots=0.0;
   else
     {
      double usedMargin              =  myAccount.Margin();
      // max margin per commodity allowed is 15% of equity
      double allowedMarginPerCommodity    =  myAccount.Balance()*0.15;
      // max total margin allowed is 60% of equity
      double availableToThisCommodity     = (myAccount.Balance() * 0.6) - usedMargin;
      // double maxLossPerCommodity       =  AccountInfoDouble(ACCOUNT_EQUITY)*0.10;
      if(_price==0.0)
         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY,1.0,instrumentPointers[_ins].Bid(),_sl);
      else
         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY,1.0,_price,_sl);
      stepVol=instrumentPointers[_ins].LotsStep();
      double allowedRisk = myAccount.Balance()*riskPerTrade/100.0;
      // calculate ideal sought lots without margin constraints
      idealLots = MathFloor((allowedRisk/lossPerLot)/stepVol)*stepVol;
      ResetLastError();
      if(OrderCalcMargin(ORDER_TYPE_BUY,instrumentPointers[_ins].Name(),1,_price,marginPerLot))
        {
         // check allowed margin
         allowedLots = MathMin(allowedMarginPerCommodity,availableToThisCommodity)/marginPerLot;
         allowedLots = MathFloor(allowedLots/stepVol)*stepVol;
         // check allowed margin with ideal sought lots
         lots = MathMin(idealLots,allowedLots);
        }
      else
        {
         Print(__FUNCTION__," Failed to get (1) lot margin required @ price: ",_price," ", ErrorDescription(GetLastError()));
         lots = 0;
         return lots;
        }
     }
   if(lots<minvol)
     {
      lots=0;
      return lots;
     }
   double maxvol=instrumentPointers[_ins].LotsMax();
   if(lots>maxvol)
     {
      lots=maxvol;
      return lots;
     }
   return lots;
  }
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//+------------------------------------------------------------------+
double TradeFlow::CheckOpenShort(int _ins, double _price,double _sl)
  {
   if(instrumentPointers[_ins].Name()==NULL)
      return(0.0);
   double allowedLots=0, lots=0,  idealLots=0, marginPerLot=0, lossPerLot=0, stepVol=0;
   double minvol=instrumentPointers[_ins].LotsMin();
   if(_sl==0.0)
      lots=0.0;
   else
     {
      double usedMargin              =  myAccount.Margin();
      // max margin per commodity allowed is 15% of equity
      double allowedMarginPerCommodity    =  myAccount.Balance()*0.15;
      // max total margin allowed is 60% of equity
      double availableToThisCommodity     = (myAccount.Balance() * 0.6) - usedMargin;
      // double maxLossPerCommodity       =  AccountInfoDouble(ACCOUNT_EQUITY)*0.10;
      if(_price==0.0)
         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_SELL,1.0,instrumentPointers[_ins].Bid(),_sl);
      else
         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_SELL,1.0,_price,_sl);
      stepVol=instrumentPointers[_ins].LotsStep();
      double allowedRisk = myAccount.Balance()*riskPerTrade/100.0;
      // calculate ideal sought lots without margin constraints
      idealLots = MathFloor((allowedRisk/lossPerLot)/stepVol)*stepVol;
      ResetLastError();
      if(OrderCalcMargin(ORDER_TYPE_BUY,instrumentPointers[_ins].Name(),1,_price,marginPerLot))
        {
         // check allowed margin
         allowedLots = MathMin(allowedMarginPerCommodity,availableToThisCommodity)/marginPerLot;
         allowedLots = MathFloor(allowedLots/stepVol)*stepVol;
         // check allowed margin with ideal sought lots
         lots = MathMin(idealLots,allowedLots);
        }
      else
        {
         Print(__FUNCTION__," Failed to get (1) lot margin required @ price: ",_price," ", ErrorDescription(GetLastError()));
         lots = 0;
         return lots;
        }
     }
   if(lots<minvol)
     {
      lots=0;
      return lots;
     }
   double maxvol=instrumentPointers[_ins].LotsMax();
   if(lots>maxvol)
     {
      lots=maxvol;
      return lots;
     }
   return lots;
  }
//+------------------------------------------------------------------+
//| iterate trades tabel and move stops for _ins                     |
//+------------------------------------------------------------------+
bool              TradeFlow::moveAllStops(int _ins)
  {
   bool condition = true;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myPosition.Select(instrumentPointers[_ins].symbol))
        {
         if((myPosition.Magic()==myTrade.RequestMagic()) && (myPosition.Symbol()==instrumentPointers[_ins].symbol))
           {
            if(myPosition.Ticket())
              {
               if(!moveStop(_ins,myPosition.Ticket()))
                  // one false moveStop is sufficient to return false
                  condition = false;
              }
            else
               DebugBreak();
           }
        }
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| move a single candle stop                                        |
//| operates on trend (trend1) that may be same as _Period/or not!   |
//+------------------------------------------------------------------+
bool              TradeFlow::moveStop(int _ins, ulong _ticket)
  {
   bool condition = true;
// 2nd trend minorTrend Pointer -> The trend you are trading not the mircro trend
   DiagTip *minorTrend = this.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
   double SL=0;
   double TP = 0;
   string insName=instrumentPointers[_ins].Name();
   double sprd=instrumentPointers[_ins].Spread()*instrumentPointers[_ins].Point();
   myPosition.SelectByTicket(_ticket);
   ENUM_POSITION_TYPE posType = myPosition.PositionType();
   if(posType == POSITION_TYPE_BUY)
     {
      double buyStop = MathMin(minorTrend.ratesThisTF[1].low,minorTrend.ratesThisTF[2].low);
      buyStop = buyStop - deltaFireRoom * instrumentPointers[_ins].Point();
      buyStop = NormalizeDouble(buyStop,instrumentPointers[_ins].Digits());
      if((buyStop != pBuyStop) && (buyStop > myPosition.StopLoss()))
        {
         pBuyStop = buyStop;
         if(myTrade.PositionModify(_ticket, buyStop, myPosition.TakeProfit()))
           {
            // Request is completed or order placed
            Alert("Success: The Buy order MOVE STOP order request at vol:",myTrade.RequestVolume(),
                  ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                  ", price:",myTrade.RequestPrice());
            //Alert("A buy order STOP has been succesfully moved with Ticket#:",myTrade.ResultOrder(),"!!");
            return true;
           }
         else
           {
            // stopped out already (due to system catch  up incomplete at this time), or genuine failure?
            double serverStopLoss = myPosition.StopLoss();
            if(buyStop <= myPosition.StopLoss())
              {
               string rcDesc = myTrade.ResultRetcodeDescription();
               //Was trying to move up stop and failed - reason: not enough min stop distance?
               Alert("*Failed: *Buy order *MOVE STOP order request at vol:",myTrade.RequestVolume(),
                     ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                     //", price:",myTrade.RequestPrice(),
                     " could not be completed -error:",rcDesc);
              }
            else
               // so close the thing out
               if(myTrade.PositionClose(_ticket))
                 {
                  Alert("Success: *The Buy order *Close order request at vol:",myTrade.RequestVolume(),
                        ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                        ", price:",myTrade.RequestPrice());
                  return true;
                 }
               else
                 {
                  string rcDesc = myTrade.ResultRetcodeDescription();
                  Alert("Failed: The Close order *CLOSE order request at vol:",myTrade.RequestVolume(),
                        ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                        ", price:",myTrade.RequestPrice(),
                        " could not be completed -error:",rcDesc);
                  return false;
                 }
            return true;
           }
        }
     }
   else
      if(posType == POSITION_TYPE_SELL)
        {
         double sellStop = MathMax(minorTrend.ratesThisTF[1].high,minorTrend.ratesThisTF[2].high);
         sellStop +=  instrumentPointers[_ins].Spread()* instrumentPointers[_ins].Point();
         sellStop += deltaFireRoom * instrumentPointers[_ins].Point();
         sellStop= NormalizeDouble(sellStop,instrumentPointers[_ins].Digits());
         if((sellStop != pBuyStop) && (sellStop < myPosition.StopLoss()))
           {
            pBuyStop = sellStop;
            if(myTrade.PositionModify(_ticket, sellStop, myPosition.TakeProfit()))
              {
               // Request is completed or order placed
               Alert("Successs: The SELL order MOVE STOP order request at vol:",myTrade.RequestVolume(),
                     ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                     ", price:",myTrade.RequestPrice());
               //Alert("A SELL order STOP has been succesfully MOVED with Ticket#:",myTrade.ResultOrder(),"!!");
               return true;
              }
            else
              {
               // stopped out already (due to system catch  up incomplete at this time), or genuine failure?
               double serverStopLoss = myPosition.StopLoss();
               if(sellStop >= myPosition.StopLoss())
                 {
                  //Was trying to move down stop and failed - reason: not enough min stop distance?
                  string rcDesc = myTrade.ResultRetcodeDescription();
                  Alert("Failed: *The SELL order *MOVE STOP order request at vol:",myTrade.RequestVolume(),
                        ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                        ", price:",myTrade.RequestPrice(),
                        " could not be completed -error:",rcDesc);
                 }
               else                   // so close the thing out
                  if(myTrade.PositionClose(_ticket))
                    {
                     Alert("Success: *The SELL order *Close order request at vol:",myTrade.RequestVolume(),
                           ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                           ", price:",myTrade.RequestPrice());
                     return true;
                    }
                  else
                    {
                     string rcDesc = myTrade.ResultRetcodeDescription();
                     Alert("Failed: The Close order *CLOSE order request at vol:",myTrade.RequestVolume(),
                           ", SL:",myTrade.RequestSL(),", TP:",myTrade.RequestTP(),
                           ", price:",myTrade.RequestPrice(),
                           " could not be completed -error:",rcDesc);
                     return false;
                    }
               return true;
              }
           }
        }
//stop loss does not need changing
   return condition;
  }
//// +------------------------------------------------------------------+
//// | openBuyPosiion                                                   |
//// +------------------------------------------------------------------+
//bool TradeFlow::openBuyPosition(int _ins,double _marketAsk, double _vol, double _stopAsk, double _targetAsk, string _catType)
//  {
//// uses ask (offer,Buy) price for entry stop and target
//// prices passed in are bid
//   CSymbolInfo instrumentPointers[_ins]=instrumentPointers[_ins].mySymbol;
//   string insName=instrumentPointers[_ins].Name();
//   double norMarketAsk      = NormalizeDouble(_marketAsk,instrumentPointers[_ins].Digits());
//   double norStopAsk       = NormalizeDouble(_stopAsk, instrumentPointers[_ins].Digits()); // --- Stop Loss
//   double norTargetAsk     = NormalizeDouble(_targetAsk, instrumentPointers[_ins].Digits()); // --- Take Profit
//   string comment=StringFormat("Buy Stop %s %s %G lots at %s, SL=%s TP=%s",
//                               _catType,
//                               instrumentPointers[_ins].Name(),_vol,
//                               DoubleToString(norMarketAsk, instrumentPointers[_ins].Digits()),
//                               DoubleToString(norStopAsk, instrumentPointers[_ins].Digits()),
//                               DoubleToString(norTargetAsk, instrumentPointers[_ins].Digits()));
////// --- open BuyStop order
//   if(myTrade.Buy(_vol,instrumentPointers[_ins].Name(),norMarketAsk,norStopAsk,norTargetAsk,comment))
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
//// +------------------------------------------------------------------+
//// | openSellPosition                                                 |
//// +------------------------------------------------------------------+
//bool TradeFlow::openSellPosition(int _ins,double _marketBid, double _vol, double _stopBid, double _targetBid, string _catType)
//  {
//// uses bid (Sell) price for entry stop and target
//// prices passed in are bid
//   CSymbolInfo instrumentPointers[_ins]=instrumentPointers[_ins].mySymbol;
//   string insName=instrumentPointers[_ins].Name();
//   double norMarketBid   =NormalizeDouble(_marketBid, instrumentPointers[_ins].Digits());               // --- Sell price
//   double norStopBid    = NormalizeDouble(_stopBid, instrumentPointers[_ins].Digits()); // --- Stop Loss
//   double norTargetBid  = NormalizeDouble(_targetBid, instrumentPointers[_ins].Digits()); // --- Take Profit
//   string comment=StringFormat("Sell Stop %s %s %G lots at %s, SL=%s TP=%s",
//                               _catType,
//                               instrumentPointers[_ins].Name(),_vol,
//                               DoubleToString(norMarketBid,instrumentPointers[_ins].Digits()),
//                               DoubleToString(norStopBid,instrumentPointers[_ins].Digits()),
//                               DoubleToString(norTargetBid,instrumentPointers[_ins].Digits()));
//// --- Open Sell Market Order
//   if(myTrade.Sell(_vol,instrumentPointers[_ins].Name(),norMarketBid,norStopBid,norTargetBid,comment))
//     {
//      // Request is completed or order placed
//      Alert("A SellStop order has been successfully placed with Ticket#:",myTrade.ResultOrder(),"!!");
//      // instrumentPointers[_ins].pContainerLip.pSumLipElements.ToLog(__FUNCTION__, true);
//      //Print(__FUNCTION__," ** ADDED ENTRY ORDER SELL STOP, trend: ",tipEnumToString(_ts));
//      return true;
//     }
//   else
//     {
//      string rcDesc = myTrade.ResultRetcodeDescription();
//      Alert("The SellStop order request at vol:",myTrade.RequestVolume(),
//            ", sl:",myTrade.RequestSL(),", tp:",myTrade.RequestTP(),
//            ", price:",myTrade.RequestPrice(),
//            " could not be completed -error:",rcDesc);
//      return false;
//     }
//   return false;
//  }
//+------------------------------------------------------------------+
//| findFirstPosition                                                |
//| return ticket for existing instrument entry order or NULL        |
//+------------------------------------------------------------------+
ulong  TradeFlow::findFirstPositon(string insName)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myPosition.Select(PositionGetSymbol(i)))
        {
         if((myPosition.Magic()==myTrade.RequestMagic()) && (myPosition.Symbol()==insName))
            return ulong(myPosition.Ticket());
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//| findEntryOrders                                                  |
//| return ticket for existing instrument sntry order or NULL        |
//+------------------------------------------------------------------+
int  TradeFlow::findEntryOrder(string insName)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(myOrder.Select(OrderGetTicket(i)))
        {
         string sym= myOrder.Symbol();
         if(myOrder.Magic()==myTrade.RequestMagic() && sym ==insName)
            return int(myOrder.Ticket());
        }
     }
   return -1;
  }
// +------------------------------------------------------------------+
// |cancelAllSymbolOrders                                             |
// +------------------------------------------------------------------+
//void  TradeFlow::cancelAllSymbolOrders(string _sym, long _magic)
//  {
//   int index=0;
//   do
//     {
//      if(myOrder.SelectByIndex(index))
//        {
//         if((myOrder.Symbol() == _sym) && (myOrder.Magic() == _magic))
//           {
//            //delete the Order
//            if(myTrade.OrderDelete(myOrder.Ticket()))
//              {
//               index = 0;
//               Sleep(100);
//              }
//           }
//         else
//            //need to check for multiple currencies and multiple trades same currency
//            index +=1;
//        }
//     }
//   while(countOrders(int(_magic), _sym) > 0);
//  }
//+------------------------------------------------------------------+
//| return: false if have order that is still valid                  |
//+------------------------------------------------------------------+
bool              TradeFlow::orderSetupFailed(string _sym, int _eaMagic)
  {
   return false;
  }
// +------------------------------------------------------------------+
// |cancelAllDirectionSymbolOrders                                    |
// +------------------------------------------------------------------+
//void  TradeFlow::cancelAllDirectionSymbolOrders(string _sym, long _magic, trendState _ts)
//  {
//   int index=0;
//   ENUM_ORDER_TYPE orderType = NULL;
//   if(_ts == up)
//      orderType = ORDER_TYPE_BUY_LIMIT;
//   else
//      if(_ts==down)
//         orderType = ORDER_TYPE_SELL_LIMIT;
//   do
//     {
//      if(myOrder.SelectByIndex(index))
//        {
//         //trend and entry order direction are intact
//         ENUM_ORDER_TYPE myOrderType = myOrder.OrderType();
//         if(orderType != myOrderType)
//           {
//            if((myOrder.Symbol() == _sym) && (myOrder.Magic() == _magic))
//              {
//               //delete the Order
//               if(myTrade.OrderDelete(myOrder.Ticket()))
//                 {
//                  index = 0;
//                  Sleep(100);
//                 }
//               else
//                  Alert(__FUNCTION__," failed to delete Order: ",myOrder.Symbol());
//              }
//            else
//               //need to check for multiple currencies and multiple trades same currency
//               index +=1;
//           }
//         else
//            // All good orders in same direction
//            return;
//        }
//     }
//   while(countOrders(int(_magic), _sym) > 0);
//  }
// +------------------------------------------------------------------+
// |  Count Total Trades for this expert/symbol                       |
// +------------------------------------------------------------------+
int TradeFlow::countPositions(int eaMagic,string symbol)
  {
   int mark=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      //string ticket = string( PositionGetTicket(i));
      if(myPosition.Select(symbol))
        {
         if(myPosition.Magic()==eaMagic)// && myPosition.Symbol()==symbol)
            mark++;
        }
     }
   return(mark);
  }
// +------------------------------------------------------------------+
// |  Count Total Orders for this expert/symbol                       |
// +------------------------------------------------------------------+
int TradeFlow::countOrders(int eaMagic,string symbol)
  {
   int mark=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(myOrder.Select(OrderGetTicket(i)))
        {
         if(myOrder.Magic()==eaMagic && myOrder.Symbol()==symbol)
            mark++;
        }
     }
   return(mark);
  }
//+------------------------------------------------------------------+
//| Deletes limit orders                                             |
//+------------------------------------------------------------------+
bool  TradeFlow:: deleteStopBuyOrders(int _eaMagic,string _symbol)
  {
//--- go through the list of all orders
   int orders=OrdersTotal();
   for(int i=0; i<orders; i++)
     {
      if(!myOrder.SelectByIndex(i))
        {
         PrintFormat("OrderSelect() failed: Error=", GetLastError());
         return(false);
        }
      //--- get the name of the symbol and the position id (magic)
      string symbol=myOrder.Symbol();
      long   magic =myOrder.Magic();
      ulong  ticket=myOrder.Ticket();
      //--- if they correspond to our values
      if(symbol==_symbol && magic==_eaMagic)
        {
         if(myTrade.OrderDelete(ticket))
            Print(myTrade.ResultRetcodeDescription());
         else
           {
            Print("OrderDelete() failed! ", myTrade.ResultRetcodeDescription());
            return(false);
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Establish is engulfing pattern                                   |
//+------------------------------------------------------------------+
//bool       TradeFlow::isEngulfing()
//  {
//   double o = this.ratesChartBars[1].open;
//   double c = this.ratesChartBars[1].close;
//   double h = this.ratesChartBars[1].high;
//   double l = this.ratesChartBars[1].low;
//   if((h >= this.ratesChartBars[2].high) && (l <= this.ratesChartBars[2].low))
//      return true;
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkBuyPrimaryWaveWave                                          |
//// | check primary trend component has down leg - buying off a trough |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//bool  TradeFlow::isCongestedUpWave(int _ins, int index)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
//// get last leg for all tip's
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//      (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      // primary trend is down on a down arm, lower volume in wave and lower price
//      if(
//         // up trend
//         (tip.currTip==congested) &&
//         // up leg
//         (tip.tipePntrs[3].arrowValue > tip.tipePntrs[2].arrowValue)
//         //highrer volume on penultimate than volume earlier back end wave start
//         //(MathAbs(tip.tipePntrs[2].vol) > MathAbs(tip.tipePntrs[0].vol)) &&
//         // newest high > first high - think this is auto true if currtip up
//         //(tip.tipePntrs[3].tLineCurrPrevValues.rightValue > tip.tipePntrs[1].tLineCurrPrevValues.rightValue)
//      )
//         condition = true;
//     }
//   else
//      Print(__FUNCTION__," INVALID POINTER");
//   return condition;
//  }
//// +------------------------------------------------------------------+
//// | checkBuyPrimaryWaveWave                                          |
//// | check primary trend component has down leg - buying off a trough |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//bool  TradeFlow::isCongestedDownWave(int _ins, int index)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
//// get last leg for all tip's
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//      (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      // primary trend is down on a down arm, lower volume in wave and lower price
//      if(
//         // up trend
//         (tip.currTip==congested) &&
//         // down leg
//         (tip.tipePntrs[3].arrowValue < tip.tipePntrs[2].arrowValue)
//         //highrer volume on penultimate than volume earlier back end wave start
//         //(MathAbs(tip.tipePntrs[2].vol) > MathAbs(tip.tipePntrs[0].vol)) &&
//         // newest high > first high - think this is auto true if currtip up
//         //(tip.tipePntrs[3].tLineCurrPrevValues.rightValue > tip.tipePntrs[1].tLineCurrPrevValues.rightValue)
//      )
//         condition = true;
//     }
//   else
//      Print(__FUNCTION__," INVALID POINTER");
//   return condition;
//  }
//+------------------------------------------------------------------+
