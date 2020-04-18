//+------------------------------------------------------------------+
//|                                                  MonitorFlow.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#include <Arrays\List.mqh>
#include <CLASS_FILES\TradeFlow.mqh>

//+------------------------------------------------------------------+
//| Access to barflow through *bFlow                                 |
//| ins is set set as current ins in main loop of findOpportunities  |
//| ratesChartBars is set in in main loop of findOpportunities       |
//| currLipe holds levels currLipe[0] -> lower,                      |
//| currLipe[1] -> X level,                                          |
//| currLipe[2] -> higher level.                                     |
//+------------------------------------------------------------------+
class MonitorFlow : public TradeFlow
  {
public:
   LipElement        currLipe[];
//   bool              MonitorFlow::setChartInsBars(int _ins, int _reqBars);
   void              MonitorFlow::MonitorFlow();
   void              MonitorFlow::~MonitorFlow();
   //  trendState        MonitorFlow::trendGetState(int _ins, int _index);
   //  trendState        MonitorFlow::getCongestionTrend(int _ins, int _smallBoxCongestion, int _bigBoxCongestion);
   bool              MonitorFlow::monitorLevelX(int _ins);
   bool              MonitorFlow::setTargets(int _ins, rttl _rttlhis);
   void              MonitorFlow::getLowerLevel(int _ins, int _start);
   void              MonitorFlow::getHigherLevel(int _ins, int _start);
   rttl              MonitorFlow:: monitorRoomLeft(int _ins, int _count, int _start);
   bool              MonitorFlow::isNear(rttl _rttlThis);
   void              MonitorFlow::cciSetState(int _ins, int _index);
   cciClicked        MonitorFlow::cciGetState(int _ins, int _index);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonitorFlow::MonitorFlow()
  {

  }
////+------------------------------------------------------------------+
////| Constructor                                                      |
////+------------------------------------------------------------------+
//void MonitorFlow::initMonitorFlow()
//  {
//
//  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void MonitorFlow::~MonitorFlow()
  {
//Clear();
  }
//+------------------------------------------------------------------+
//| Check if _Period bar crosses an important level on All level HTF |
//| receives a instrument/Chart bar                                  |
//+------------------------------------------------------------------+
//bool  MonitorFlow::monitorLevelX(int _ins)
//  {
//// **** Can speed checking of this by pointer reference back to isMinimaFlag bars in a queue **
//   if(instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()> 0)
//     {
//      for(int cntLipe=0; (cntLipe < instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()); cntLipe++)
//        {
//         LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//         if(CheckPointer(lipe)!=POINTER_INVALID)
//           {
//            //  check its a minima level and its  straddled by the candle
//            if(lipe.isMinimaFlag && (lipe.levelPrice <= ratesChartBars[1].high) && (lipe.levelPrice >= ratesChartBars[1].low))//lipe.isMinimaFlag &&
//               return true;
//           }
//        }
//     }
//   return false;
//  }
//+------------------------------------------------------------------+
//| Check if _Period bar crosses an important level on All level HTF |
//| receives a instrument/Chart bar                                  |
//+------------------------------------------------------------------+
//bool  MonitorFlow::setTargets(int _ins, rttl _rttlThis)
//  {
////   delete temporary using lipe from array holder but dont delete pointer
//   ArrayRemove(currLipe,0,WHOLE_ARRAY);
//   ArrayResize(currLipe,4);
//// **** Can speed checking of this by pointer reference back to isMinimaFlag bars in a queue **
//   if(instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()> 0)
//     {
//      for(int cntLipe=0; (cntLipe < instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()); cntLipe++)
//        {
//         LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//         if(CheckPointer(lipe)!=POINTER_INVALID)
//           {
//            //  check its a minima level and its  straddled by the candle
//            if(lipe.isMinimaFlag && (lipe.levelPrice <= ratesChartBars[1].high) && (lipe.levelPrice >= ratesChartBars[1].low))//lipe.isMinimaFlag &&
//              {
//               // set bar cross level curr[0]
//               currLipe[0] = lipe;
//               // is a buy opportunity
//               if(_rttlThis == rttlLow)
//                 {
//                  // set curr[1,2,3]
//                  getHigherLevel(_ins, cntLipe);
//                  return true;
//                 }
//               else
//                  if(_rttlThis == rttlHigh)
//                    {
//                     //  set curr[1,2,3]
//                     getLowerLevel(_ins, cntLipe);
//                     return true;
//                    }
//              }
//           }
//        }
//     }
//   return false;
//  }
//+------------------------------------------------------------------+
//| find  lower target levels if it exists                           |
//+------------------------------------------------------------------+
//void  MonitorFlow::getLowerLevel(int _ins, int _start)
//  {
////  index zero is level chart bar X's @
//   int index = 1;
//   for(int cntLipe =_start; (cntLipe >= 0); cntLipe--)
//     {
//      LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//      if(CheckPointer(lipe)!=POINTER_INVALID)
//        {
//         if(lipe.isMinimaFlag && (lipe.levelPrice < ratesChartBars[1].low))
//           {
//            currLipe[index] = lipe;
//            index+=1;
//            // obtained three levels
//            if(index == 3)
//               return;
//           }
//        }
//     }
//// failed to get three levels
//  }
//+------------------------------------------------------------------+
//| find higher target value levels if it exists                   |
//+------------------------------------------------------------------+
//void  MonitorFlow::getHigherLevel(int _ins, int _start)
//  {
////  index zero is level chart bar X's @
//   int index = 1;
//   for(int cntLipe =_start; (cntLipe < instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()); cntLipe++)
//     {
//      LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//      if(CheckPointer(lipe)!=POINTER_INVALID)
//        {
//         if(lipe.isMinimaFlag && (lipe.levelPrice > ratesChartBars[1].high))
//           {
//            currLipe[index] = lipe;
//            index+=1;
//            // obtained 3 levels
//            if(index == 3)
//               return;
//           }
//        }
//     }
////  failed to get three levels
//  }
//+------------------------------------------------------------------+
//| Establish found level has room to the left                       |
//| ALGO: Currently Operates on Chart TF for any level found         |
//+------------------------------------------------------------------+
rttl       MonitorFlow:: monitorRoomLeft(int _ins, int _count, int _start)
  {
//int lowest=-1;
//int highest = -1;
//int inc = 1;
//int limit = _count;
//do
//  {
//   lowest = iLowest(instrumentPointers[_ins].symbol,_Period,MODE_LOW,limit,_start);
//   highest =iHighest(instrumentPointers[_ins].symbol,_Period,MODE_HIGH,limit,_start);
//   inc+=1;
//   limit = _count*inc;
//   if(inc > 10)
//      return rttlNone;
//  }
//while((highest == 1) && (lowest == 1));
//if(limit > ArraySize(ratesChartBars))
//  {
//   Print(__FUNCTION__," Should Not be here-> rates asked for: "+IntegerToString(limit)," #Rates Pulled: ",IntegerToString(ArraySize(ratesChartBars)));
//   DebugBreak();
//  }
//if(lowest ==1)
//  {
//   //      return rttlLow;
//   double diffPoints = (ratesChartBars[highest].low-ratesChartBars[lowest].low)
//                       /instrumentPointers[_ins].mySymbol.Point();
//   //  have a low at position candle (1) -> where and what is the low of the highest point ?
//   ATRInfo *atr = NULL;
//   if(instrumentPointers[_ins].pContainerTipIndicator.Total()>0)
//     {
//      for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerTipIndicator.Total()); instrumentTrend++)
//        {
//         atr = instrumentPointers[_ins].pContainerTipIndicator.GetNodeAtIndex(instrumentTrend);
//         if(atr.waveHTFPeriod == _Period)
//           {
//            int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
//            //check if price difference is > (x) ATR;s of the Chart
//            double atrInPoints    =  atr.atrWrapper.atrValue[0] * MathPow(10,instrumentPointers[_ins].mySymbol.Digits());
//            if(diffPoints > (atrInPoints * atr.scaleATR))
//               return rttlLow;
//            else
//               break;
//           }
//        }
//      //   Print("LOW -> Room to left, belongs to: ", EnumToString(currLipe[0].waveHTFPeriod)," Level Price:  ",currLipe[0].levelPrice," lowest: ",ratesChartBars[1].high, " date: ", ratesChartBars[1].time);
//     }
//  }
//else
//   if(highest == 1)
//     {
//      double diffPoints = (ratesChartBars[highest].high-ratesChartBars[lowest].high)
//                          /instrumentPointers[_ins].mySymbol.Point();
//      ATRInfo *atr = NULL;
//      if(instrumentPointers[_ins].pContainerTipIndicator.Total()>0)
//        {
//         for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerTipIndicator.Total()); instrumentTrend++)
//           {
//            atr = instrumentPointers[_ins].pContainerTipIndicator.GetNodeAtIndex(instrumentTrend);
//            if(atr.waveHTFPeriod == _Period)
//              {
//               int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
//               double atrInPoints    =  atr.atrWrapper.atrValue[0] * MathPow(10,instrumentPointers[_ins].mySymbol.Digits());
//               if(diffPoints > (atrInPoints * atr.scaleATR))
//                  return rttlHigh;
//               else
//                  break;
//              }
//           }
//        }
//      //   Print("HIGH -> Room to left, belongs to: ", EnumToString(currLipe[0].waveHTFPeriod)," Level Price:  ",currLipe[0].levelPrice," highest: ",ratesChartBars[1].high, " date: ", ratesChartBars[1].time);
//     }
   return rttlNone;
  }
// +------------------------------------------------------------------+
// | set CCI Click State by calling get which sets first              |
// +------------------------------------------------------------------+
void  MonitorFlow::cciSetState(int _ins, int _index)
  {
   cciClicked cciNow = cciNone;
   Tip *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
   if(CheckPointer(tip)!=POINTER_INVALID)
      tip.cciWaveInfo.setCCIState();
  }
// +------------------------------------------------------------------+
// | get CCI state                                                    |
// +------------------------------------------------------------------+
cciClicked  MonitorFlow::cciGetState(int _ins, int _index)
  {
   Tip *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
   if(CheckPointer(tip)!=POINTER_INVALID)
      return tip.cciWaveInfo.getCCIState();
   return cciNone;
  }
//// |------------------------------------------------------------------+
//// | checkSellTrendWave                                               |
//// | check up leg on chart bar trend - selling off a peak             |
//// | checks HTF does not include primary                              |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//trendState  MonitorFlow::trendGetState(int _ins, int _index)
//  {
//   Tip *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//   if(CheckPointer(tip)!=POINTER_INVALID)
//     {
//      //if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) && (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//      //   return  tip.currTip;
//      //else
//      //  {
//      //   Print(__FUNCTION__, " bad tip pointer ", tip);
//      //   return isVoidTrend;
//      //  }
//     }
//   return isVoidTrend;
//  }
////+------------------------------------------------------------------+
////| ensure larger congestion is below small congestion -> long       |
////| ensure larger congestion is above small congestion -> short      |
////+------------------------------------------------------------------+
//trendState  MonitorFlow::getCongestionTrend(int _ins, int _smallBoxCongestion, int _bigBoxCongestion)
//  {
//   Tip                     *tipBigBox           =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_bigBoxCongestion);
//   CongestionElement       *ceBigBox            =  tipBigBox.congestionQ.GetLastNode();
//   Tip                     *tipSmallBox         =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_smallBoxCongestion);
//   CongestionElement       *ceSmallBox          =  tipSmallBox.congestionQ.GetLastNode();
//   double                  smallBoxHighPrice  =  ceSmallBox.priceBoxHigh;
//   double                  smallBoxLowPrice     =  ceSmallBox.priceBoxLow;
//   double                  bigBoxHighPrice    =  ceBigBox.priceBoxHigh;
//   double                  bigBoxLowPrice       =  ceBigBox.priceBoxLow;
//// smaller congestion above bigger congestion
//   if(
//      (smallBoxLowPrice > bigBoxHighPrice)&&
//      (ratesChartBars[1].close < smallBoxLowPrice)&&
//      (ratesChartBars[1].close > bigBoxHighPrice)
//
//   )
//      return up;
//
////smaller congestion below bigger congestion
//   if(
//      (smallBoxHighPrice < bigBoxLowPrice) &&
//      (ratesChartBars[1].close > smallBoxHighPrice)&&
//      (ratesChartBars[1].close < bigBoxLowPrice)
//
//   )
//      return down;
//// no match of congestion boxes
//   return isVoidTrend;
//  }
////+------------------------------------------------------------------+
////| Establish _index Tf is sell                                      |
////+------------------------------------------------------------------+
//trendState  MonitorFlow::isTrendSellHTF(int _ins, int _index)
//  {
//   Tip *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) && (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      if(tip.currTip == down)
//         return  tip.currTip;
//     }
//   else
//     {
//      Print(__FUNCTION__, " bad tip pointer ", tip);
//      return isVoidTrend;
//     }
//   return isVoidTrend;
//  }
//+------------------------------------------------------------------+
//| Establish found level has room to the left                       |
//+------------------------------------------------------------------+
//bool       MonitorFlow:: monitorTouchedLeft()
//  {
//   if(currLipe[0].diffTouched > 10)
//     {
//   //   Print("Room to left, belongs to: ", EnumToString(currLipe[0].waveHTFPeriod)," Level Price:  ",currLipe[0].levelPrice," Bars Difference: ", currLipe[0].diffTouched, " prev Date:  ", currLipe[0].prevTouched, " last date: ", currLipe[0].lastTouched);
//      return true;
//     }
//   return false;
//  }
//class MonitorFlowElement : public CList
//  {
//public:
//   void              MonitorFlowElement::MonitorFlowElement();
//   void              MonitorFlowElement::~MonitorFlowElement();
//  };
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void MonitorFlowElement::MonitorFlowElement() {}
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void MonitorFlowElement::~MonitorFlowElement() {}
//// +------------------------------------------------------------------+
//// | checkBuyTrendWave                                                |
//// | check all trend components have down leg - buying off a trough   |
//// | checks HTF does not include primary                              |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//trendState  MonitorFlow::isTrendsBuyHTFsLow(int _ins, int _index)
//  {
//   trendState trendNow = isVoidTrend;
//   Tip *tip=NULL;
//   for(int instrumentTrend=_index; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
//     {
//      tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
//      // get last leg for all tip's
//      if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) && (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//        {
//         // for lowest of trend tfs want to know its on a down leg
//         if((instrumentTrend == tfDataTrend.primaryIndex+1) && (tip.currTip==up) && (tip.tipePntrs[3].arrowValue < tip.tipePntrs[2].arrowValue))
//           {
//            // check down log for primary trend+1
//            trendNow = up;
//           }
//         else
//            if(tip.currTip==up)
//               trendNow = up;
//            else
//              {
//               // dont have a buy - no open trade
//               trendNow = isVoidTrend;
//               // if trend leg is not down for this TF, for this instrument(looped in expert main), then no set up
//               break;
//              }
//        }
//      else
//        {
//         Print(__FUNCTION__," bad pointer");
//         trendNow = isVoidTrend;
//         break;
//        }
//     }
//   return trendNow;
//  }
//+------------------------------------------------------------------+
