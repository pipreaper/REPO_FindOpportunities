//+------------------------------------------------------------------+
//|                                                    RatesFlow.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CLASS_FILES\BarFlow.mqh> // --- CTrade
#include <CLASS_FILES\Tip.mqh> // --- CTrade
class RatesFlow : public BarFlow
  {
private:
public:
   // MqlRates ratesHTF[];
   //  MqlRates ratesChartBars[];
   int               minBarsDegugRunTrend;
   int               maxBarsDegugRunTrend;
   int               minBarsDegugRunLevel;
   int               maxBarsDegugRunLevel;
   int               minBarsDegugRunVolume;
   int               maxBarsDegugRunVolume;
                     RatesFlow();
                    ~RatesFlow();
   bool              RatesFlow::addTips();
   void              RatesFlow::initRatesFlow(
      int _minBarsDegugRunTrend,
      int               _maxBarsDegugRunTrend,
      int               _minBarsDegugRunLevel,
      int               _maxBarsDegugRunLevel,
      int               _minBarsDegugRunVolume,
      int               _maxBarsDegugRunVolume);
   bool              RatesFlow::getTip(int _ins, ENUM_TIMEFRAMES _tf, Tip* &tip[]);
   bool              RatesFlow::initStratElements();
   bool              RatesFlow::initTips();
   bool              RatesFlow::initLevels();
   bool              RatesFlow::initVolumes();
   bool              RatesFlow::initIndicatorsTick();
   // ensure have inital ratesHTF to: strategy test/real data run system
   bool              RatesFlow::initInitialRatesSequence();
   bool              RatesFlow::initInitialRatesSequenceCTF();
   bool              RatesFlow::initInitialRatesSequenceHTF();
   // call chart period and all other broker data requests
   bool              RatesFlow::callGetBrokerDataTrend(int _ins, ENUM_TIMEFRAMES _TF, MqlRates &_tipRates[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RatesFlow::RatesFlow()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RatesFlow::~RatesFlow()
  {
  }
//+------------------------------------------------------------------+
//| Instantiate the Tips/tip indicators indicators for use           |
//+------------------------------------------------------------------+
bool RatesFlow::addTips()
  {
   bool conditionTrend = true;
   int aSize=ArraySize(instrumentPointers)-1;
// used When muldTiple trends shown for single Instrument
   int incPanel=14;
// ** LOOP ALL SYSMBOLS SELECTED
   int panelY=10;
   for(int _ins=0; _ins<=aSize; _ins++)
     {
      int panelX=10;
      panelY+=12;
      double arrowDrawOffSet= -10;
      symbolIsShown = false;
      DiagTip      *dTip=NULL;
      // ** loop all time frames zero, second and trend
      if(CheckPointer(tfDataAll)!=POINTER_INVALID)
        {
         for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
           {
            Print(__FUNCTION__"ins: ",instrumentPointers[_ins].symbol, " #this TF: ",TF," use: ",EnumToString(tfDataAll.useTF[TF]));
            bool conditionLevel  =  true;
            int t = hasTFIndex(tfDataAll.useTF[TF],"trend");
            if(t >= 0)
              {
               if((tfDataTrend.useTF[t]) && (tfDataTrend.chartTF<=tfDataTrend.useTF[t]))
                 {
                  incUniqueID(1);
                  dTip = new DiagTip(tfDataTrend.tfColor[t],"diag_Line_"+IntegerToString(uniqueID));
                  dTip.setParent(instrumentPointers[_ins].pContainerTip);
                  instrumentPointers[_ins].pContainerTip.Add(dTip);
                  arrowDrawOffSet+= 10;
                  dTip.initTip(instrumentPointers[_ins].symbol,numDefineWave,tfDataTrend.chartTF,tfDataTrend.useTF[t],tfDataTrend.tfColor[t],wCalcSizeType,atrRange,
                               atrTrendPeriod,atrTrendAppliedPrice,minBarsDegugRunTrend,maxBarsDegugRunTrend,percentPullBack,
                               atrMultiplier,scaleATR,
                               cciTriggerLevel,cciExitLevel,cciAppliedPrice,cciPeriod,
                               emaTrendPeriod,emaTrendShift,emaTrendMethod,emaTrendAppliedPrice,fracThreshHold,tfDataTrend,TF,showPanel,
                               "arrowMax_"+EnumToString(tfDataTrend.useTF[t]),"arrowMin_"+EnumToString(tfDataTrend.useTF[t]),onScreenVarLimit);
                  // initialise new classes of indicators -> each Tip has a copy
                  dTip.addIndicators();
                  // enter only once
                  if(!symbolIsShown)
                     if(!dTip.initPanelScreenSymbol(panelX,panelY))
                       {
                        conditionTrend=false;
                        break;
                       }
                  symbolIsShown=true;
                  if(!dTip.initPanelScreenVar(panelX,panelY))
                     conditionTrend=false;

                 }
              }
           }
        }
     }
   return conditionTrend;
  }
//+------------------------------------------------------------------+
//|initRatesFlow                                                     |
//+------------------------------------------------------------------+
void RatesFlow::initRatesFlow(
   int               _minBarsDegugRunTrend,
   int               _maxBarsDegugRunTrend,
   int               _minBarsDegugRunLevel,
   int               _maxBarsDegugRunLevel,
   int               _minBarsDegugRunVolume,
   int               _maxBarsDegugRunVolume)
  {
   minBarsDegugRunTrend=_minBarsDegugRunTrend;
   maxBarsDegugRunTrend=_maxBarsDegugRunTrend;
   minBarsDegugRunLevel=_minBarsDegugRunLevel;
   maxBarsDegugRunLevel=_maxBarsDegugRunLevel;
   minBarsDegugRunVolume=_minBarsDegugRunVolume;
   maxBarsDegugRunVolume=_maxBarsDegugRunVolume;
  }
// +------------------------------------------------------------------+
// |make sure indicator data is available                             |
// +------------------------------------------------------------------+
bool              RatesFlow::initIndicatorsTick()
  {
   Tip *rTip = NULL;
   for(int ins=0; (ins<ArraySize(this.instrumentPointers)); ins++)
     {
      for(int iTF=0; iTF<ArraySize(this.tfDataTrend.useTF); iTF++)
        {
         if(CheckPointer(instrumentPointers[ins].pContainerTip.GetNodeAtIndex(iTF))!= POINTER_INVALID)
           {
            rTip=instrumentPointers[ins].pContainerTip.GetNodeAtIndex(iTF);
            // int initBars = int(MathRound(rTip.atrWaveInfo.atrRange*(PeriodSeconds(rTip.waveHTFPeriod)/PeriodSeconds(_Period))));
            double tempGetAtrValues[];
            int startCandle = MathMin(ArraySize(rTip.ratesThisTF)-1,rTip.maxBarsDegugRun);
            if(CopyBuffer(rTip.atrWaveInfo.atrHandle,0,0,startCandle, tempGetAtrValues) < startCandle)
              {
               Print(__FUNCTION__," couldnt get atr values -> want: ",startCandle, "  found: ",CopyBuffer(rTip.atrWaveInfo.atrHandle,0,0,startCandle, tempGetAtrValues)," ",rTip.symbol," ",EnumToString(rTip.waveHTFPeriod));
               return false;
              }
            else
              {
               //for(int i = ArraySize(tempGetAtrValues)-1; i >0 ; i--)
               // Print(i," ",tempGetAtrValues[i]);
               Print(__FUNCTION__," found       atr values -> want: ",startCandle, "  found: ",CopyBuffer(rTip.atrWaveInfo.atrHandle,0,0,startCandle, tempGetAtrValues)," ",rTip.symbol," ",EnumToString(rTip.waveHTFPeriod));
              }
           }
        }
     }
   return true;
  }
// +------------------------------------------------------------------+
// |setInitialRatesSequence                                           |
// +------------------------------------------------------------------+
bool              RatesFlow::initInitialRatesSequence()
  {
   if(initInitialRatesSequenceCTF() && initInitialRatesSequenceHTF())
      return true;
   else
     {
      Print(__FUNCTION__," failed to find rates: "," initInitialRatesSequenceCTF() ",initInitialRatesSequenceCTF()," initInitialRatesSequenceHTF() ",initInitialRatesSequenceHTF());
      return false;
     }
  }
// +------------------------------------------------------------------+
// |setInitialRatesSequence                                           |
// |this is checking that you have all the                            |
// | data for levels volume and Trends                                |
// +------------------------------------------------------------------+
bool              RatesFlow::initInitialRatesSequenceCTF()
  {
   int aSize=ArraySize(instrumentPointers)-1;
   Tip* aTip[1];
   if(CheckPointer(tfDataAll)!=POINTER_INVALID)
     {
      for(int ins=0; ins<=aSize; ins++)
        {
         this.getTip(ins, _Period, aTip);
         Tip *tip = aTip[0];
         if(!callGetBrokerDataTrend(ins,_Period,tip.parent.ratesCTF))
           {
            Print(__FUNCTION__," returned false from ins/period: ",ins," ",_Period);
            return false;
           }
        }// instrument
     }
   return true;
  }
// +------------------------------------------------------------------+
// |setInitialRatesSequence                                           |
// |this is checking that you have all the                            |
// | data for levels volume and Trends                                |
// +------------------------------------------------------------------+
bool              RatesFlow::initInitialRatesSequenceHTF()
  {
   int aSize=ArraySize(instrumentPointers)-1;
   Tip* tip[1];
   if(CheckPointer(tfDataAll)!=POINTER_INVALID)
     {
      for(int ins=0; ins<=aSize; ins++)
        {
         this.getTip(ins, _Period, tip);
         for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
           {
            this.getTip(ins,tfDataAll.useTF[TF],tip);
            if(!callGetBrokerDataTrend(ins, tfDataAll.useTF[TF], tip[0].ratesThisTF))
              {
               Print(__FUNCTION__," returned false from ins/period: ",ins," ",tfDataAll.useTF[TF]);
               return false;
              }
            //   else
            //    Print(__FUNCTION__," symbol: ",this.instrumentPointers[ins].symbol," _Period ",EnumToString(tfDataAll.useTF[TF]), " firstTime: ", ratesChartBars[ArraySize(ratesChartBars)-1].time," last time: ",ratesChartBars[0].time);
           }// TF
        }// instrument
     }
   return true;
  }
//+------------------------------------------------------------------+
//| find a tip from ins and period                                   |
//+------------------------------------------------------------------+
bool  RatesFlow::getTip(int _ins, ENUM_TIMEFRAMES _tf, Tip* &tip[])
  {
   bool condition = false;
// special case for _Period
   if(_tf == _Period)
     {
      // its not zero but it will do!
      Tip *localTip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(0);
      tip[0] = GetPointer(localTip);
      condition = true;
     }
   if(!condition)
     {
      for(int index=0; (index<instrumentPointers[_ins].pContainerTip.Total()); index++)
        {
         Tip *localTip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
         if(localTip.waveHTFPeriod == _tf)
           {
            condition = true;
            tip[0] = GetPointer(localTip);
            break;
           }
        }
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| initTips :Initialise all selected Trend instrument period        |
//+------------------------------------------------------------------+
bool  RatesFlow::initStratElements()
  {
   if(!initTips())
      return false;
   if(!initLevels())
      return false;
   if(!initVolumes())
      return false;
   else
      return true;
  }
//+------------------------------------------------------------------+
//| initTips :Initialise all selected Trend instrument period        |
//+------------------------------------------------------------------+
bool  RatesFlow::initTips()
  {
   bool conditionTrend = true;
   int aSize=ArraySize(instrumentPointers)-1;
   DiagTip      *dTip=NULL;
   for(int _ins=0; _ins<=aSize; _ins++)
     {
      for(int index=0; (index<instrumentPointers[_ins].pContainerTip.Total()); index++)
        {
         if(CheckPointer(instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index))!= POINTER_INVALID)
           {
            dTip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
            if(!dTip.checkRateBarsAreSynced())
              {
               conditionTrend=false;
               break;
              }
            // check instrument has quotes data to proceed
            if(!instrumentPointers[_ins].Refresh())
              {
               conditionTrend=false;
               break;
              }
           }
        }// done this indeex
     }// done this instrument
   return conditionTrend;
  }
//+------------------------------------------------------------------+
//| initLevels :Initialise all selected Level instrument period      |
//+------------------------------------------------------------------+
bool  RatesFlow::initLevels()
  {
   bool conditionLevel  =  true;
   int aSize=ArraySize(instrumentPointers)-1;
   for(int ins=0; ins<=aSize; ins++)
     {
      Lip   *lip=NULL;
      // ** loop all time frames zero, second and trend
      if(CheckPointer(tfDataAll)!=POINTER_INVALID)
        {
         for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
           {
            Print(__FUNCTION__"ins: ",instrumentPointers[ins].symbol, " #this TF: ",TF," use: ",EnumToString(tfDataAll.useTF[TF]));
            int lev = hasTFIndex(tfDataAll.useTF[TF],"level");
            if(lev >= 0)
              {
               if((tfDataLevel.useTF[lev]) && (tfDataLevel.chartTF<=tfDataLevel.useTF[lev]))
                 {
                  // has to return Condition same as above before can say initialisation complete else return false not end function true
                  if(tfDataLevel.chartTF  <= tfDataLevel.useTF[lev])
                    {
                     lip = new Lip(instrumentPointers[ins].pContainerLip,instrumentPointers[ins].symbol,tfDataLevel.useTF[lev],tfDataLevel.tfColor[lev],
                                   minBarsDegugRunLevel,maxBarsDegugRunLevel,
                                   nHipLop,
                                   //percentileValue,nBins,numVolBeforeDeletionStarts,nATRsFromHLCalcDisplay,tfDataLevel.useTF[lev],
                                   tfDataLevel.showLevels,
                                   instrumentPointers[ins].Point(),
                                   instrumentPointers[ins].Digits(),
                                   conditionLevel);
                     instrumentPointers[ins].pContainerLip.Add(lip);
                    }
                 }
              }
            if(!conditionLevel)
              {
               Print(__FUNCTION__," Symbol: ",instrumentPointers[ins].symbol," TF: ",TF," is problem:  conditionLevel: ",conditionLevel);
               conditionLevel = false;
               break;
              }
           }// for tfAllData
        }// check pointer
      else
        {
         Print(__FUNCTION__," tfAllData is NULL");
         conditionLevel = false;
        }
      Print("Initialised Instrument: ",instrumentPointers[ins].symbol," status: ", conditionLevel);
     }// done this instrument
   return true;
  }
//+------------------------------------------------------------------+
//| initVolumes :Initialise all selected Volume instrument period    |
//+------------------------------------------------------------------+
bool  RatesFlow::initVolumes()
  {
   bool conditionVolume  =  true;
   int aSize=ArraySize(instrumentPointers)-1;
   for(int ins=0; ins<=aSize; ins++)
     {
      Vip      *vip=NULL;
      if(CheckPointer(tfDataAll)!=POINTER_INVALID)
        {
         for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
           {
            Print(__FUNCTION__"ins: ",instrumentPointers[ins].symbol, " #this TF: ",TF," use: ",EnumToString(tfDataAll.useTF[TF]));
            int vol = hasTFIndex(tfDataAll.useTF[TF],"volume");
            if(vol >= 0)
              {
               if((tfDataVolume.useTF[vol]) && (tfDataVolume.chartTF<=tfDataVolume.useTF[vol]))
                 {
                  // has to return Condition same as above before can say initialisation complete else return false not end function true
                  if(tfDataVolume.chartTF  <= tfDataVolume.useTF[vol])
                    {
                     vip = new Vip(instrumentPointers[ins].symbol,tfDataVolume.useTF[vol],tfDataVolume.tfColor[vol],
                                   atrVolAppliedPrice,atrVolPeriod,
                                   minBarsDegugRunVolume,maxBarsDegugRunVolume,
                                   percentileValue,nBins,numVolBeforeDeletionStarts,nATRsFromHLCalcDisplay,tfDataVolume.useTF[vol],
                                   tfDataVolume.showVolumes,
                                   conditionVolume);
                     instrumentPointers[ins].pContainerVip.Add(vip);
                    }
                 }
              }
            if(!conditionVolume)
              {
               Print(__FUNCTION__," Symbol: ",instrumentPointers[ins].symbol," TF: ",TF," is problem:  conditionVolume: ",conditionVolume);
               conditionVolume = false;
               break;
              }
           }// for tfAllData
        }// check pointer
      else
        {
         Print(__FUNCTION__," tfAllData is NULL");
         conditionVolume = false;
        }
      Print("Initialised Instrument: ",instrumentPointers[ins].symbol," status: ", conditionVolume);
     }// done this instrument
   return conditionVolume;
  }
// +------------------------------------------------------------------+
// |callGetBrokerDataTrend                                            |
// +------------------------------------------------------------------+
bool RatesFlow::callGetBrokerDataTrend(int _ins, ENUM_TIMEFRAMES _TF, MqlRates &_tipRates[])
  {
   string testerStatus = NULL;
   int startHTFShift=-1;
   int numRates =-1;
//loop around symbol and Period
   if(!MQLInfoInteger(MQL_TESTER))
     {
      testerStatus = "_Real Data_"     ;
      // Difference is that debug unlike a strategy tester run DOES NOT AUTO download the history
      // So you have to do it to get the program to run by navigate front and back of history data
      // maxLevels used because it has higher bar demand than trend
      int barsFound = -1;
      if(!getUpdatedHistory(instrumentPointers[_ins].symbol,_TF,minBarsDegugRunLevel,maxBarsDegugRunLevel,barsFound))
        {
         Print(__FUNCTION__," Failed to Navigate data from charts");
         return false;
        }


      numRates=CopyRates(instrumentPointers[_ins].symbol,_TF,0,barsFound,_tipRates);



      if(numRates < MathMax(MathMax(minBarsDegugRunTrend,minBarsDegugRunLevel),minBarsDegugRunVolume))
        {
         DebugBreak();
         Print(__FUNCTION__," Error copying price data: Max bars Available from current date is: ",numRates," You want at least: ",minBarsDegugRunLevel, " ", ErrorDescription(GetLastError()));
         // DebugBreak();
         return false;
        }
     }
   else
     {
      //***** Testing parmameters from ST fed to ratesH_TFArray *****
      //Will Auto Download the History Data it needs to do a run
      //According to the parameters you give it in CopyRates - dates or counts -> up to its own internal limits eg/. 286 bars of hisory for Daily NASDAQ
      testerStatus = "_ST_Tester_History";
      // will generally return less than 10000
      int numBarsSought = 10000;//minBarsDegugRunTrend * PeriodSeconds(_TF)/PeriodSeconds(_Period);
      numRates=CopyRates(instrumentPointers[_ins].symbol,_TF,0,numBarsSought,_tipRates);
      if(numRates < MathMax(MathMax(minBarsDegugRunTrend,minBarsDegugRunLevel),minBarsDegugRunVolume))
        {
         Print(__FUNCTION__," Check Your ST Data Ranges: Max Bars Available from current date is: ",numRates," You want at least: ",minBarsDegugRunLevel, " ", ErrorDescription(GetLastError()));
         ArraySetAsSeries(_tipRates,true);
         Print(__FUNCTION__," ", EnumToString(_TF)," Oldest : ", _tipRates[numRates-1].time," Newest : ",_tipRates[0].time, " ");
         return false;
        }
     }
   Print(__FUNCTION__,"*** Copied ****",testerStatus,": ",ArraySize(_tipRates)," bars");
   ArraySetAsSeries(_tipRates,true);
   Print(__FUNCTION__," ", EnumToString(_TF)," Oldest : ", _tipRates[numRates-1].time," Newest : ",_tipRates[0].time, " ");
   Print(testerStatus);
   Print("* BrokerData Read*");
   Print("");
   return true;
  }
//+------------------------------------------------------------------+
