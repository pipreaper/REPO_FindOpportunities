//+------------------------------------------------------------------+
//|                                                    RatesFlow.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CLASS_FILES\BarFlow.mqh> // --- CTrade
class RatesFlow : public BarFlow
  {
private:
public:
   int               minBarsDegugRunTrend;
   int               maxBarsDegugRunTrend;
   int               minBarsDegugRunLevel;
   int               maxBarsDegugRunLevel;
   int               minBarsDegugRunVolume;
   int               maxBarsDegugRunVolume;
                     RatesFlow();
                    ~RatesFlow();
   // initialiser for RatesFlow
   void              RatesFlow::initRatesFlow(
      int _minBarsDegugRunTrend,
      int               _maxBarsDegugRunTrend,
      int               _minBarsDegugRunLevel,
      int               _maxBarsDegugRunLevel,
      int               _minBarsDegugRunVolume,
      int               _maxBarsDegugRunVolume);
   bool              RatesFlow::initTips();
   // ensure have inital ratesHTF to: strategy test/real data run system
   bool              RatesFlow::initInitialRatesSequence();
   // call chart period and all other broker data requests
   bool              RatesFlow::callGetBrokerDataTrend(int _ins, ENUM_TIMEFRAMES _TF, MqlRates  &_ratesHTF[]);
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
//|                                                                  |
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
// |setInitialRatesSequence                                           |
// |this is checking that you have all the                            |
// | data for levels volume and Trends                                |
// +------------------------------------------------------------------+
bool              RatesFlow::initInitialRatesSequence()
  {
   MqlRates ratesHTF[];
   MqlRates ratesChartBars[];
// ensure data integrity before run
// ** LOOP ALL SYSMBOLS SELECTED
   int aSize=ArraySize(instrumentPointers)-1;
   if(CheckPointer(tfDataAll)!=POINTER_INVALID)
     {
      for(int ins=0; ins<=aSize; ins++)
        {
         if(!callGetBrokerDataTrend(ins,_Period, ratesChartBars))
           {
            Print(__FUNCTION__," returned false from ins/period: ",ins," ",_Period);
            return false;
           }
         // calls period again if it uses it as a main lower Tf - so what!
         for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
           {
            if(!callGetBrokerDataTrend(ins, tfDataAll.useTF[TF],ratesHTF))
              {
               Print(__FUNCTION__," returned false from ins/period: ",ins," ",tfDataAll.useTF[TF]);
               return false;
              }
           }// TF
        }// instrument
     }
   return true;
  }
//+------------------------------------------------------------------+
//| initTips :Initialise all selected Trend instrument period        |
//| for all catalysts ... A/D Trend and Levels                       |
//+------------------------------------------------------------------+
bool  RatesFlow::initTips()
  {
// used When muldTiple trends shown for single Instrument
   int incPanel=14;
   int aSize=ArraySize(instrumentPointers)-1;
// ** LOOP ALL SYSMBOLS SELECTED
   int panelY=10;
   for(int ins=0; ins<=aSize; ins++)
     {
      int panelX=10;
      panelY+=12;
      //this.initPanelScreenSymbol(ins, panelX, panelY);
      // ignored in new Tip  below - if no panel to show
      double arrowDrawOffSet= -10;
      DiagTip      *dTip=NULL;
      Lip   *lip=NULL;
      Vip      *vip=NULL;
      symbolIsShown = false;
      // ** loop all time frames zero, second and trend
      if(CheckPointer(tfDataAll)!=POINTER_INVALID)
        {
         for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
           {
            Print(__FUNCTION__"ins: ",instrumentPointers[ins].symbol, " #this TF: ",TF," use: ",EnumToString(tfDataAll.useTF[TF]));
            bool conditionLevel  =  true;
            bool conditionTrend  =  true;
            bool conditionVolume =  true;
            int t = hasTFIndex(tfDataAll.useTF[TF],"trend");
            if(t >= 0)
              {
               arrowDrawOffSet+= 10;
               if((tfDataTrend.useTF[t]) && (tfDataTrend.chartTF<=tfDataTrend.useTF[t]))
                 {
                  incUniqueID(1);
                  dTip = new DiagTip(tfDataTrend.tfColor[t],"diag_Line_"+IntegerToString(uniqueID));
                  dTip.initTip(instrumentPointers[ins].symbol,numDefineWave,tfDataTrend.chartTF,tfDataTrend.useTF[t],tfDataTrend.tfColor[t],wCalcSizeType,atrRange,
                               atrTrendPeriod,atrTrendAppliedPrice,minBarsDegugRunTrend,maxBarsDegugRunTrend,percentPullBack,
                               atrMultiplier,scaleATR,
                               cciTriggerLevel,cciExitLevel,cciAppliedPrice,cciPeriod,
                               emaTrendPeriod,emaTrendShift,emaTrendMethod,emaTrendAppliedPrice,fracThreshHold,tfDataTrend,TF,showPanel,
                               "arrowMax_"+EnumToString(tfDataTrend.useTF[t]),"arrowMin_"+EnumToString(tfDataTrend.useTF[t]),onScreenVarLimit
                              );
                  if(!dTip.checkRateBarsAreSynced())
                     conditionTrend=false;
                  // check instrument has quotes data to proceed
                  if(instrumentPointers[ins].Refresh())
                    {
                     instrumentPointers[ins].pContainerTip.Add(dTip);
                     conditionTrend = true;
                    }
                  else
                     conditionTrend=false;
                  // initialise new classes of indicators -> each Tip has a copy
                  if(!dTip.initIndicators())
                     conditionTrend=false;
                  // enter only once
                  if(!symbolIsShown)
                     if(!dTip.initPanelScreenSymbol(panelX,panelY))
                        conditionTrend=false;
                  symbolIsShown=true;
                  if(!dTip.initPanelScreenVar(panelX,panelY))
                     conditionTrend=false;
                 }
               else
                  if(verboseDataInfo && (!(tfDataLevel.chartTF<=tfDataTrend.useTF[t])))
                     Print("*WARNING: ",__FUNCTION__,"  Allocation of waves !: Trying to put HTF, ",EnumToString(tfDataTrend.useTF[t])," onto ",tfDataLevel.chartTF);
              }
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
            if(!conditionTrend || !conditionLevel || !conditionVolume)
              {
               Print(__FUNCTION__," Symbol: ",instrumentPointers[ins].symbol," TF: ",TF," is problem: conditionTrend: ",conditionTrend, " conditionLevel: ",conditionLevel, " conditionVolume: ",conditionVolume);
        //       DebugBreak();
               return false;
              }
           }// for tfAllData
        }// check pointer
      else
         Print(__FUNCTION__," tfAllData is NULL");
      Print("Initialised Instrument: ",instrumentPointers[ins].symbol);
     }// done this instrument
   return true;
  }
// +------------------------------------------------------------------+
// |callGetBrokerDataTrend                                            |
// +------------------------------------------------------------------+
bool RatesFlow::callGetBrokerDataTrend(int _ins, ENUM_TIMEFRAMES _TF, MqlRates  &_ratesHTF[])
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
      numRates=CopyRates(instrumentPointers[_ins].symbol,_TF,0,barsFound,_ratesHTF);
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
      numRates=CopyRates(instrumentPointers[_ins].symbol,_TF,0,numBarsSought,_ratesHTF);
      if(numRates < MathMax(MathMax(minBarsDegugRunTrend,minBarsDegugRunLevel),minBarsDegugRunVolume))
        {
         Print(__FUNCTION__," Check Your ST Data Ranges: Max Bars Available from current date is: ",numRates," You want at least: ",minBarsDegugRunLevel, " ", ErrorDescription(GetLastError()));
         ArraySetAsSeries(_ratesHTF,true);
         Print(__FUNCTION__," ", EnumToString(_TF)," Oldest : ", _ratesHTF[numRates-1].time," Newest : ",_ratesHTF[0].time, " ");
         return false;
        }
     }
   Print(__FUNCTION__,"*** Copied ****",testerStatus,": ",ArraySize(_ratesHTF)," bars");
   ArraySetAsSeries(_ratesHTF,true);
   Print(__FUNCTION__," ", EnumToString(_TF)," Oldest : ", _ratesHTF[numRates-1].time," Newest : ",_ratesHTF[0].time, " ");
   Print(testerStatus);
   Print("* BrokerData Read*");
   Print("");
   return true;
  }
//+------------------------------------------------------------------+
