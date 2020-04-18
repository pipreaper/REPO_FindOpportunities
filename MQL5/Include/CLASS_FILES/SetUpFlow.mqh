//+------------------------------------------------------------------+
//|                                                     BigBar.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CLASS_FILES\StopLimitFlow.mqh>
#include <CLASS_FILES\ContainerSetUpQ.mqh>
class BarFlow;
class SetUpFlow  : public StopLimitFlow
  {
private:
   setUpState           suState;
   int                  targetZone;
   double               stopTargetsArray[];
public:
   dataLoadState        dls;
   void                 SetUpFlow::SetUpFlow();
   setUpState           SetUpFlow::checkEntryTrigger(int _ins,int _shift);
   void                 SetUpFlow::checkMoveDiagLine(int _ins,int _shift);
   setUpState           SetUpFlow::getSetUpState();
   void                 SetUpFlow::haveSetup(int _ins);
   //bool                 SetUpFlow::isThird();
   //bool                 SetUpFlow::isInRange();
   // check extreme candle
   bool                 SetUpFlow::isExtremum(ENUM_POSITION_TYPE _posType);
   void                 SetUpFlow::initSetUpFlow();
   // Initialise all selected Trend instrument period
   bool                 SetUpFlow::startStrategyComponents(int _ins, int _iTF);
   void                 SetUpFlow::outTipStates(int _ins, string _action, int _shift, int _count);

   bool                 SetUpFlow::processInitBar(int _ins, int _TF)
   ;
   bool                 SetUpFlow::process(simState _catThis, int _ins);
   // run the new bar on all instruments runtime-Get the new trend and all cyclically set strategy values for a new chart Bar
   void                 SetUpFlow::runNewBarInstruments(int _ins);
   // set stop target by atr
   void                 SetUpFlow::setStopTargetsByATR(int _ins, double _marketBidPrice,ENUM_ORDER_TYPE _bs);
   void                 SetUpFlow::setSetUpState(setUpState _suState);
   void SetUpFlow::     ~SetUpFlow();
  };
// +------------------------------------------------------------------+
// |drawDiagLines                                                     |
// +------------------------------------------------------------------+
void  SetUpFlow::checkMoveDiagLine(int _ins,int _shift)
  {
   DiagTip *diagTip=NULL;
   for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
     {
      if(CheckPointer(instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend))!= POINTER_INVALID)
        {
         diagTip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
         //tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
         // Only call if its a new chart Bar for HTF under containeration
         //*****************************************8 !!! NO because its against checking for congestion on a htf bar (new bar in Tip) only for chart bar ****************
         //    if(isNewHTF(diagTip,_shift))
         //     {
         //  if(            isDate(0,45,3,2,1,2019))
         //  Print(index);
         if((diagTip.getTipState() == up) && (diagTip.getPrevTipState() != up))
           {
            // draw support or resistance
            //      Print(__FUNCTION__," before setUpState: ",EnumToString(getSetUpState()));
            //    Print(__FUNCTION__," ",index," before  Diagtip get tip / get prev tip: ",EnumToString(diagTip.getTipState())," ",EnumToString(diagTip.getPrevTipState()));
            //     Print(__FUNCTION__," ","before x[0]: ",diagTip.tipePntrs[0].rightPrice," y[0]: ",diagTip.tipePntrs[2].rightPrice,"x[1]: ",diagTip.tipePntrs[1].rightTime," y[1]: ",diagTip.tipePntrs[2].rightTime);
            diagTip.moveDiagLine(diagTip.tipePntrs[0].rightPrice,diagTip.tipePntrs[2].rightPrice,diagTip.tipePntrs[0].rightTime,diagTip.tipePntrs[2].rightTime);
            diagTip.setPrevTipState(diagTip.getTipState());
            //       Print(__FUNCTION__," ","after x[0]: ",diagTip.tipePntrs[0].rightPrice," y[0]: ",diagTip.tipePntrs[2].rightPrice,"x[1]: ",diagTip.tipePntrs[1].rightTime," y[1]: ",diagTip.tipePntrs[2].rightTime);
            //      Print(__FUNCTION__," ",index," after  Diagtip get tip / get prev tip: ",EnumToString(diagTip.getTipState())," ",EnumToString(diagTip.getPrevTipState()));
            //       Print(__FUNCTION__," after setUpState: ",EnumToString(getSetUpState()));
            //        Print(" ");
           }
         else
            if((diagTip.getTipState() == down) && (diagTip.getPrevTipState() != down))
              {
               //       Print(__FUNCTION__," before setUpState: ",EnumToString(getSetUpState()));
               //        Print(__FUNCTION__," ",index," before  Diagtip get tip / get prev tip: ",EnumToString(diagTip.getTipState())," ",EnumToString(diagTip.getPrevTipState()));
               //       Print(__FUNCTION__," ","before x[0]: ",diagTip.tipePntrs[0].rightPrice," y[0]: ",diagTip.tipePntrs[2].rightPrice,"x[1]: ",diagTip.tipePntrs[1].rightTime," y[1]: ",diagTip.tipePntrs[2].rightTime);
               diagTip.moveDiagLine(diagTip.tipePntrs[0].rightPrice,diagTip.tipePntrs[2].rightPrice,diagTip.tipePntrs[0].rightTime,diagTip.tipePntrs[2].rightTime);
               diagTip.setPrevTipState(diagTip.getTipState());
               //        Print(__FUNCTION__," ","after x[0]: ",diagTip.tipePntrs[0].rightPrice," y[0]: ",diagTip.tipePntrs[2].rightPrice,"x[1]: ",diagTip.tipePntrs[1].rightTime," y[1]: ",diagTip.tipePntrs[2].rightTime);
               //        Print(__FUNCTION__," ",index," after  Diagtip get tip / get prev tip: ",EnumToString(diagTip.getTipState())," ",EnumToString(diagTip.getPrevTipState()));
               //       Print(__FUNCTION__," after setUpState: ",EnumToString(getSetUpState()));
               //       Print(" ");
              }
            else
               if((diagTip.getTipState() == congested) && (diagTip.getPrevTipState() != congested))
                 {
                  //        Print(__FUNCTION__," before setUpState: ",EnumToString(getSetUpState()));
                  //       Print(__FUNCTION__," ",index," before  Diagtip get tip / get prev tip: ",EnumToString(diagTip.getTipState())," ",EnumToString(diagTip.getPrevTipState()));
                  //       Print(__FUNCTION__," ","before x[0]: ",diagTip.tipePntrs[0].rightPrice," y[0]: ",diagTip.tipePntrs[2].rightPrice,"x[1]: ",diagTip.tipePntrs[1].rightTime," y[1]: ",diagTip.tipePntrs[2].rightTime);
                  diagTip.moveDiagLine(diagTip.tipePntrs[3].rightPrice,diagTip.tipePntrs[3].rightPrice,diagTip.tipePntrs[0].rightTime,diagTip.tipePntrs[2].rightTime);
                  diagTip.setPrevTipState(diagTip.getTipState());
                  //       Print(__FUNCTION__," ","after x[0]: ",diagTip.tipePntrs[0].rightPrice," y[0]: ",diagTip.tipePntrs[2].rightPrice,"x[1]: ",diagTip.tipePntrs[1].rightTime," y[1]: ",diagTip.tipePntrs[2].rightTime);
                  //       Print(__FUNCTION__," ",index," after  Diagtip get tip / get prev tip: ",EnumToString(diagTip.getTipState())," ",EnumToString(diagTip.getPrevTipState()));
                  //       Print(__FUNCTION__," after setUpState: ",EnumToString(getSetUpState()));
                  //       Print(" ");
                 }
         //    }
        }
     }
  }
// +------------------------------------------------------------------+
// |haveSetup                                                         |
// +------------------------------------------------------------------+
void  SetUpFlow::haveSetup(int _ins)
  {
   DiagTip *minorTrend=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
   DiagTip *majorTrend=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(1);
   if((majorTrend.getTipState() == up) && (minorTrend.getTipState() == down))
     {
      //    Print(__FUNCTION__," before setUpState: ",EnumToString(getSetUpState()));
      setSetUpState(waiting_trigger_break_resistance);
      //  Print(__FUNCTION__," UP/DOWN minor: ",EnumToString(minorTrend.getTipState()), " ",minorTrend.waveHTFPeriod," major: ",EnumToString(majorTrend.getTipState()), " ",majorTrend.waveHTFPeriod);
      //   Print(__FUNCTION__," after setUpState: ",EnumToString(getSetUpState()));
      //    Print(" ");
     }
   else
      if((majorTrend.getTipState() == down) && (minorTrend.getTipState() == up))
        {
         setSetUpState(waiting_trigger_break_support);
        }
      else
         if((majorTrend.getTipState() == up) && (minorTrend.getTipState() == up))
           {
            setSetUpState(trending);
            //    Print(__FUNCTION__," UP/UP minor: ",EnumToString(minorTrend.getTipState()), " ",minorTrend.waveHTFPeriod," major: ",EnumToString(majorTrend.getTipState()), " ",majorTrend.waveHTFPeriod);
            //  Print(" ");
           }
         else
            if((majorTrend.getTipState() == down) && (minorTrend.getTipState() == down))
               setSetUpState(trending);
            else
               setSetUpState(init_diag_line);
  }
// +------------------------------------------------------------------+
// |runNewBarAllInstruments                                           |
// +------------------------------------------------------------------+
void  SetUpFlow::runNewBarInstruments(int _ins)
  {
   Tip *tip=NULL;
   for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
     {
      if(CheckPointer(instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend))!= POINTER_INVALID)
        {
         tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
         // Always update Chart TF bars
         if(wCalcSizeType == waveCalcATR)
            tip.atrWaveInfo.setWaveHeightPointsATR(tip.onScreenWaveHeight,1);
         else
            tip.atrWaveInfo.setWaveHeightPointsFixed(tip.onScreenWaveHeight);
         // NOW ALWAYS DO CHART BAR TF STUFF
         // TipElement *tipe =  this.GetLastNode();
         // need rates for calculating flexible ATR maybe -> calcATR set to dynamic
         CopyRates(tip.symbol,_Period,0,101,tip.ratesCTF);
         ArraySetAsSeries(tip.ratesCTF,true);
         //    if(isNewHTF(tip,0))
         //      {
         // Have a new bar so old trend suState may change - Calculate trend for this waveHTFperiod
         //    {
         //  Print(__FUNCTION__" -> tip.processTrendBar: ",EnumToString(tip.waveHTFPeriod));
         tip.processHTFTrendBar();
         //  }
        }
     }
   Lip *level=NULL;
// ** CHECK FOR NEW LEVEL DATA FOR EACH ACTIVE PERIOD
//  if(instrumentPointers[_ins].pContainerLip.Total()> 0)
//  {
   for(int instrumentLevel=0; (instrumentLevel<instrumentPointers[_ins].pContainerLip.Total()); instrumentLevel++)
     {
      level=instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(instrumentLevel);
      if(isNewHTF(level))
        {
         //update the trend lines to reflect new bar arrival
         level.updateLevelsPeriod();
        }
     }
//   }
   Vip *volume=NULL;
// ** CHECK FOR NEW LEVEL DATA FOR EACH ACTIVE PERIOD
//   if(instrumentPointers[_ins].pContainerVip.Total()> 0)
//   {
   for(int instrumentVolume=0; (instrumentVolume<instrumentPointers[_ins].pContainerVip.Total()); instrumentVolume++)
     {
      volume=instrumentPointers[_ins].pContainerVip.GetNodeAtIndex(instrumentVolume);
      if(isNewHTF(volume))
        {
         // update the trend lines to reflect new bar arrival
         volume.genVolumesPeriod();
        }
      // volume.extendDisplayVolumes();
     } // Volumes are now up to date
// }
   ChartRedraw();
  }
// +------------------------------------------------------------------+
// | setState                                                         |
// +------------------------------------------------------------------+
void              SetUpFlow::setSetUpState(setUpState _suState)
  {
   suState=_suState;
  }
// +------------------------------------------------------------------+
// | getState                                                         |
// +------------------------------------------------------------------+
setUpState        SetUpFlow::getSetUpState()
  {
   return suState;
  }
// +------------------------------------------------------------------+
// |checkEntryTrigger                                                 |
// |curently only criteria is check minor trend                       |
// +------------------------------------------------------------------|
setUpState              SetUpFlow::checkEntryTrigger(int _ins, int _shift)
  {
   DiagTip *minorTrend=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
   DiagTip *majorTrend=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(1);
   if((this.getSetUpState() != waiting_trigger_break_resistance) && this.getSetUpState() != waiting_trigger_break_support)
      return getSetUpState();
   if(this.getSetUpState() == waiting_trigger_break_resistance)
     {
      // update the diagonal lines values
      minorTrend.updateTrendPriceTime(minorTrend.ratesCTF[_shift].time);
      //  int htfShift = iBarShift(instrumentPointers[_ins].symbol,majorTrend.waveHTFPeriod,minorTrend.ratesCTF[_shift].time,true);
      majorTrend.updateTrendPriceTime(majorTrend.ratesCTF[_shift].time);
      // and check support line has been breached
      if((minorTrend.ratesCTF[1].low > minorTrend.YVals[1])&&
         (minorTrend.ratesCTF[1].open > majorTrend.YVals[1]))
         //     (minorTrend.ratesCTF[1].low > MathMin(majorTrend.ratesHTF[1].low,majorTrend.ratesHTF[2].low)))
         this.setSetUpState(open_long);
     }
   else
      if(this.getSetUpState() == waiting_trigger_break_support)
        {
         // update the diagonal lines values
         minorTrend.updateTrendPriceTime(minorTrend.ratesCTF[_shift].time);
         //int htfShift = iBarShift(instrumentPointers[_ins].symbol,majorTrend.waveHTFPeriod,minorTrend.ratesCTF[_shift].time,true);
         majorTrend.updateTrendPriceTime(majorTrend.ratesCTF[_shift].time);
         // and check support line has been breached
         if((minorTrend.ratesCTF[1].high < minorTrend.YVals[1])&&
            (minorTrend.ratesCTF[1].open < majorTrend.YVals[1]))
            //      (minorTrend.ratesCTF[1].high < MathMax(majorTrend.ratesHTF[1].high,majorTrend.ratesHTF[2].high)))
            this.setSetUpState(open_short);
        }
   return this.getSetUpState();
  }
// +------------------------------------------------------------------+
// |outTipStates                                                      |
// +------------------------------------------------------------------+
void SetUpFlow::outTipStates(int _ins, string _action,int _shift,int _count)
  {
   DiagTip *minorTrend = instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
   DiagTip *majorTrend = instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(1);
   Print("shift: ",_shift);
// int htfShift = iBarShift(instrumentPointers[_ins].symbol,majorTrend.waveHTFPeriod,minorTrend.ratesCTF[_shift].time,true);
   Print(_count," ",_action," ",__FUNCTION__," shift: ",_shift," **** ",minorTrend.ratesCTF[_shift].time);
   Print(" ",instrumentPointers[_ins].symbol, " Major ",EnumToString(majorTrend.waveHTFPeriod)," Major ", EnumToString(majorTrend.getTipState()));
   Print(" majorTrend.XTimes[0] ",majorTrend.XTimes[0]," majorTrend.YVals[0] ",majorTrend.YVals[0]);
   Print(" majorTrend.XTimes[1] ",majorTrend.XTimes[1]," majorTrend.YVals[1] ",majorTrend.YVals[1]);
   Print(" minor ", EnumToString(minorTrend.waveHTFPeriod)," minor ",EnumToString(minorTrend.getTipState()));
   Print(" minorTrend.XTimes[0] ",minorTrend.XTimes[0]," minorTrend.YVals[0] ",minorTrend.YVals[0]);
   Print(" minorTrend.XTimes[1] ",minorTrend.XTimes[1]," minorTrend.YVals[1] ",minorTrend.YVals[1]);
  }
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
void              SetUpFlow::SetUpFlow()
  {
//catType ="Flow";
   dls               =  doInitBroker;
  }
//+------------------------------------------------------------------+
//|Desructor                                                         |
//+------------------------------------------------------------------+
void SetUpFlow::~SetUpFlow() {}
//+------------------------------------------------------------------+
//|initSim                                                           |
//+------------------------------------------------------------------+
void SetUpFlow::initSetUpFlow() {}
//+------------------------------------------------------------------+
//| processBigShadow                                                 |
//+------------------------------------------------------------------+
bool SetUpFlow::process(simState _simThis,int _ins)
  {
   bool condition = false;
   if(_simThis == simLong)
     {
      double spread = instrumentPointers[_ins].Spread()*instrumentPointers[_ins].Point();
      double marketAsk = instrumentPointers[_ins].Bid() + spread;

      // get atr stop target values
      ArrayResize(stopTargetsArray,0);
      setStopTargetsByATR(_ins,marketAsk,ORDER_TYPE_BUY);
      if(ArraySize(stopTargetsArray) < 4)
         return condition;
      // check lots to open big belt long
      double lots = CheckOpenLong(_ins, marketAsk, stopTargetsArray[0]);
      // open big belt long
      if(lots > 0)
        {
         //    double targetAsk= spread + selectTarget(_ins,instrumentPointers[_ins].Bid(),stopAsk,ORDER_TYPE_BUY);//entryAsk + 100*instrumentPointers[_ins].Point();
         if(stopTargetsArray[targetZone] != 0.0)
           {
            if(openBuyPosition(_ins,instrumentPointers[_ins].Bid(),lots,stopTargetsArray[0],stopTargetsArray[targetZone],catType))
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
         Print(__FUNCTION__, " lots <= zero: ", instrumentPointers[_ins].Name(), " marketAsk: ", marketAsk, " stopTargetsArray[0]: ",stopTargetsArray[0]);
         return condition;
        }
     }
   else
      if(_simThis == simShort)
        {
         double marketBid = instrumentPointers[_ins].Bid();
         // get atr stop target values
         ArrayResize(stopTargetsArray,0);
         setStopTargetsByATR(_ins,marketBid,ORDER_TYPE_SELL);
         if(ArraySize(stopTargetsArray) < 4)
            return condition;
         // check lots to open cci long
         double lots = CheckOpenShort(_ins,marketBid,stopTargetsArray[0]);
         // open big belt long
         if(lots > 0)
           {
            if(stopTargetsArray[targetZone] != 0.0)
              {
               if(openSellPosition(_ins,marketBid,lots,stopTargetsArray[0],stopTargetsArray[targetZone],catType))
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
//+------------------------------------------------------------------+
//|cciSetStopTargetsByATR                                            |
//| ** associated with TREND **                                      |
//|currently uses wiggle atr to set stops and targets                |
//+------------------------------------------------------------------+
void SetUpFlow::setStopTargetsByATR(int _ins, double _marketBidOrAsk,ENUM_ORDER_TYPE _bs)
  {
//  set to chart index if zero index = first trend index
   ENUM_TIMEFRAMES atrPeriod = tfDataTrend.useTF[tfDataTrend.trendIndex[0]];
   ATRInfo *atr = NULL;
   int tot = instrumentPointers[_ins].pContainerTip.Total();
   if(instrumentPointers[_ins].pContainerTip.Total()>0)
     {
      // ** CHECK FOR NEW TREND DATA FOR EACH ACTIVE PERIOD
      for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
        {

         if(CheckPointer(instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend))!=POINTER_INVALID)
           {
            Tip *tip = instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
            if(CheckPointer(instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend))!=POINTER_INVALID)
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
                        stopTargetsArray[0]= _marketBidOrAsk - sl*atr.atrWrapper.atrValue[0];
                        stopTargetsArray[1]= _marketBidOrAsk + tp*atr.atrWrapper.atrValue[0];
                        stopTargetsArray[2]= _marketBidOrAsk + 2*tp*atr.atrWrapper.atrValue[0];
                        stopTargetsArray[3]= _marketBidOrAsk + 3*tp*atr.atrWrapper.atrValue[0];
                        return;
                       }
                     else
                        if(_bs == ORDER_TYPE_SELL)
                          {
                           ArrayResize(stopTargetsArray,4);
                           stopTargetsArray[0]= _marketBidOrAsk + sl*atr.atrWrapper.atrValue[0];
                           stopTargetsArray[1]= _marketBidOrAsk - tp*atr.atrWrapper.atrValue[0];
                           stopTargetsArray[2]= _marketBidOrAsk - 2*tp*atr.atrWrapper.atrValue[0];
                           stopTargetsArray[3]= _marketBidOrAsk - 3*tp*atr.atrWrapper.atrValue[0];
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
////+------------------------------------------------------------------+
////| pull the indicatorValues until have the start time               |
////+------------------------------------------------------------------+
//bool              SetUpFlow::processInitBar(int _ins, int _TF)
//  {
//   bool condition = false;
//// check indicators have necessary values
//   if(!startStrategyComponents(_ins,_TF))
//     {
//      Print(__FUNCTION__" returning false to Timer in Initialisation: ",instrumentPointers[_ins].symbol);
//      //ExpertRemove();
//      condition = false;
//     }
//   else
//     {
//      condition = true;
//      //setUpFlow.dls=dataHasLoaded;
//      //EventKillTimer();
//      //EventSetTimer(5);
//      //continue;
//     }
//   return condition;
//  }

//+------------------------------------------------------------------+
//| pull the indicatorValues until have max period amount            |
//| ensure have valid Tip Elements (5) before releassing from here   |
//| ensure have valid Lip ATR values before releassing from here     |
//| ensure have valid Vol ATR values before releassing from here     |
//+------------------------------------------------------------------+
bool              SetUpFlow::startStrategyComponents(int _ins, int _iTF)
  {
   Tip *rTip=NULL;
   bool condition = false;
   if(CheckPointer(instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_iTF))!= POINTER_INVALID)
     {
      rTip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_iTF);
      int startCandle = MathMin(ArraySize(rTip.ratesThisTF)-1,rTip.maxBarsDegugRun);
      Print(__FUNCTION__," index ",_iTF," startCandle  ",ArraySize(rTip.ratesThisTF)-1," start time: ",rTip.ratesThisTF[ArraySize(rTip.ratesThisTF)-1].time);
      for(int shift = startCandle; shift>0; shift--)
        {
         rTip.countIndicatorPulls += 1;
         int initBars = int(MathRound(rTip.atrWaveInfo.atrRange*(PeriodSeconds(rTip.waveHTFPeriod)/PeriodSeconds(_Period))));
         if(rTip.countIndicatorPulls <= initBars)
            continue;
         if(wCalcSizeType == waveCalcATR)
           {
            if(!rTip.atrWaveInfo.setWaveHeightPointsATR(rTip.onScreenWaveHeight,shift))
               Print(__FUNCTION__," rTip.ratesCTF[shift].time: ",rTip.ratesCTF[shift].time, " rTip.ratesThisHTF[shift].time: ",rTip.ratesThisTF[shift].time," Error: waveHeightPts: ",rTip.atrWaveInfo.waveHeightPts, " pointSize ",rTip.atrWaveInfo.pointSize, " digits ",rTip.atrWaveInfo.digits);
            else
               Print(__FUNCTION__," rTip.ratesCTF[shift].time: ",rTip.ratesCTF[shift].time, " rTip.ratesThisHTF[shift].time: ",rTip.ratesThisTF[shift].time," Sucess: waveHeightPts: ",rTip.atrWaveInfo.waveHeightPts, " pointSize ",rTip.atrWaveInfo.pointSize, " digits ",rTip.atrWaveInfo.digits);
           }
         else
            rTip.atrWaveInfo.setWaveHeightPointsFixed(rTip.onScreenWaveHeight);
         // new bar info
         condition = rTip.processTrendBarInit(shift);
         checkMoveDiagLine(_ins,shift);
         haveSetup(_ins);
         checkEntryTrigger(_ins, shift);
        }
     }
// if this tip has not initialised then whole process fails
   if(!condition)
      return condition;
// condition is now true
// *** LEVELS ***
   for(int index = 0 ; index < instrumentPointers[_ins].pContainerLip.Total(); index++)
     {
      // levels needs done once on all bars it either passes or it fails tests in genLevelsPeriod
      Lip *rLip=instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(index);
      if((CheckPointer(rLip)!=NULL))
        {
         if(!rLip.genLevelsPeriod())
           {
            condition = false;
            Print(__FUNCTION__," ** Failed rLip.genLevelsPeriod() -> instrument: ",_ins," index: ",index);
            return condition;
           }
        }
      else
        {
         condition = false;
         Print(__FUNCTION__," ** POINTER_INVALID: instrument: ",_ins," index: ",index);
         return condition;
        }
     }
// condition is now true
// *** VOLUMES ***
   for(int index = 0 ; index < instrumentPointers[_ins].pContainerVip.Total(); index++)
     {
      // levels needs done once on all bars it either passes or it fails tests in genLevelsPeriod
      Vip *rVip=instrumentPointers[_ins].pContainerVip.GetNodeAtIndex(index);
      if((CheckPointer(rVip)!=NULL))
        {
         if(!rVip.processLevelBarInit())
           {
            condition = false;
            Print(__FUNCTION__," ** Failed rVip.processLevelBarInit() -> instrument: ",_ins," index: ",index);
            return condition;
           }
        }
      else
        {
         condition = false;
         Print(__FUNCTION__," ** POINTER_INVALID: instrument: ",_ins," index: ",index);
         return condition;
        }
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| Body is in top/bottom third of wick                              |
//+------------------------------------------------------------------+
//bool       SetUpFlow::isThird()
//  {
//   double o = this.ratesChartBars[1].open;
//   double c = this.ratesChartBars[1].close;
//   double h = this.ratesChartBars[1].high;
//   double l = this.ratesChartBars[1].low;
//   double wick = h-l;
//   double lThreshold = l + wick*0.33;
//   double hThreshold = h - wick*0.33;
//   if(rttlThis == rttlHigh)
//     {
//      // check for bearish characteristics
//      if((o < lThreshold) && (c < lThreshold))
//         return true;
//     }
//   else
//      if(rttlThis == rttlLow)
//         // check for bullish characteristics
//        {
//         if((o > hThreshold) && (c > hThreshold))
//            return true;
//        }
//   return false;
//  }
//+------------------------------------------------------------------+
//| candle in range of previous and green or red                     |
//+------------------------------------------------------------------+
//bool       SetUpFlow::isInRange()
//  {
//// check for bearish characteristics
//// red candle
//   if(rttlThis == rttlHigh)
//     {
//      if(this.ratesChartBars[1].open < this.ratesChartBars[1].close)
//         return false;
//     }
////  green candle
//   else
//      if(rttlThis == rttlLow)
//         // check for bullish characteristics
//        {
//         if(this.ratesChartBars[1].open > this.ratesChartBars[1].close)
//            return false;
//        }
//// Check bar[1] open and close is nested in the previous range
//   double ocMin = MathMin(this.ratesChartBars[1].open,this.ratesChartBars[1].close);
//   double ocMax = MathMax(this.ratesChartBars[1].open,this.ratesChartBars[1].close);
//   if((ocMin  < this.ratesChartBars[2].low) || (ocMax  > this.ratesChartBars[2].high))
//      return false;
//   return true;
//  }
//+------------------------------------------------------------------+
//| Establish is extremum price pattern has occured according to the |
//| following logic                                                  |
//+------------------------------------------------------------------+
//bool       SetUpFlow::isExtremum(ENUM_POSITION_TYPE _posType)
//  {
//   double o = this.ratesChartBars[1].open;
//   double c = this.ratesChartBars[1].close;
//   double h = this.ratesChartBars[1].high;
//   double l = this.ratesChartBars[1].low;
//   double wick = h-l;
//   double lThreshold = l + wick*0.5;
//   double hThreshold = h - wick*0.5;
//   if(_posType == POSITION_TYPE_BUY)
//     {
//      if((o < lThreshold) && (c < lThreshold))
//         return true;
//     }
//   else
//      if(_posType == POSITION_TYPE_SELL)
//        {
//           {
//            if((o > hThreshold) && (c > hThreshold))
//               return true;
//           }
//        }
//   return false;
//  }
//+------------------------------------------------------------------+
