// +------------------------------------------------------------------+
// |                                            findOpportunities.mq4 |
// |                                   Copyright 2019, Robert Baptie. |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https:// www."
#property version   "1.01"
#property strict
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <CLASS_FILES\SetUpFlow.mqh>
#include <CLASS_FILES\ReadStringFile.mqh>
SetUpFlow setUpFlow();
// +------------------------------------------------------------------+
// |** INPUT PARAMETERS **                                            |
// +------------------------------------------------------------------+
input bool              pdt                     =  false;//Pause During Visual Testing
int                     stpLoss                 =  3;//used in calc' stop @ x current ATR Value
input int               takeProfit              =  3;//takeProfit ((x)*ATR
input int               sufficientTargetPercent =  20;// Percent Of Target Profit In (X) Bars
input bool              closeOnPositions        =  false;//Close Failed *POSITIONS  : Excess Time or Insufficient Profit
input bool              closeOnOrders           =  false;//Close Failed *ORDERS     : Excess Time
input bool              closeOnEntryTimes       =  false;//Close on session times !Good
int                     deltaFireRoom           =  10;// Points clearance Above Below firing AD
input int               candlesToExpire         =  5;// candles to Expire (Order and Position Processing)
ulong                   dev                     =  100;// Deviation
long                    Trail_point             =  32;// Points to increase TP/SL
double                  riskPerTrade            =  4;// *Risk per trade
int                     tradePercent            =  60;// * Total % Account Free Margin to trade
input ENUM_MY_FILES     fileSymbolsSelected     =  mixed;  // Symbols To Run
input bool              isSingleSymbol          =  true;// ** Only Chart Instrument
int                     magicNumber             =  20050333;// Magic Number
bool                    verboseDataInfo         =  true;//Detailed Output
bool                    verboseOutputDetail     =  false;/* Show SystemRun time info*/
// +------------------------------------------------------------------+
// |** USE TREND **                                                   |
// +------------------------------------------------------------------+
bool              shwPanel                =  true;// Show Panel Progression
int                     totalTrendsConsidered   =  2;//trends only !not _Period chart
input ENUM_TIMEFRAMES   trendTF1                =  PERIOD_M30;//First HTF: first least TF in selected TF range
input ENUM_TIMEFRAMES   trendTF2                =  PERIOD_H4;//Second HTF: second least TF in selected TF range
ENUM_TIMEFRAMES   trendTF3                =  PERIOD_H8;//Third TF Not used
input bool              showFirst               =  true;// show (1) Trend Lines
input bool              showSecond              =  true;// show (2) Trend Lines
input bool              showThird               =  true;// show (3) Trend Lines
// +------------------------------------------------------------------+
// |** USE LEVEL **                                                   |
// +------------------------------------------------------------------+
input int               totalLevelsConsidered   =  0;
ENUM_TIMEFRAMES   levelTF1                =  PERIOD_D1;//HTF1
ENUM_TIMEFRAMES   levelTF2                =  PERIOD_W1;//HTF2
ENUM_TIMEFRAMES   levelTF3                =  PERIOD_H4;//HTF3
ENUM_TIMEFRAMES         levelTF4                =  PERIOD_H1;//HTF4
ENUM_TIMEFRAMES         levelTF5                =  PERIOD_H4;/* HTF5 */
// +------------------------------------------------------------------+
// |** USE VOLUME **                                                  |
// +------------------------------------------------------------------+
int               totalVolsConsidered     =  0;
ENUM_TIMEFRAMES   volTF1                  =  PERIOD_D1;//HTF1
ENUM_TIMEFRAMES   volTF2                  =  PERIOD_W1;//HTF2
ENUM_TIMEFRAMES         volTF3                  =  PERIOD_MN1;//HTF3
ENUM_TIMEFRAMES         volTF4                  =  PERIOD_M10;//HTF4
ENUM_TIMEFRAMES         volTF5                  =  PERIOD_M30;/* HTF5 */
// +------------------------------------------------------------------+
// |** LEVELS **                                                      |
// +------------------------------------------------------------------+
bool              showLevels              =  true;// Show level Ranges selected on chart
int                     percentileValue         =  90;// percentile of last nBins of volume to create support/resistance
int                     nBins                   =  40;// number of percentile bins
int                     nHipLop                 =  3;// hiplop minima search
int                     numVolBeforeDeletionStarts =  3000;// number candles before start deleting old volume blocks
int                     minBarsDegugRunTrend    =  50;// Trend min bars
int                     maxBarsDegugRunTrend    =  1000;//  Trend max bars
int                     minBarsDegugRunLevel    =  50;//  level min bars
int                     maxBarsDegugRunLevel    =  1000;// level max bars
int                     minBarsDegugRunVolume   =  50;//  volume min bars
int                     maxBarsDegugRunVolume   =  1000;//  volume max bars
double                  fracThreshold           =  0.2; /* area big belt must occupy of wick */
// +------------------------------------------------------------------+
// |** Trend CCI **                                                   |
// +------------------------------------------------------------------+
int                     cciTrendPeriod         =  20;
int                     cciTrendAppliedPrice   =  PRICE_CLOSE;
double                  cciTrendTriggerLevel   =  100;// CCI Trigger Level
double                  cciTrendExitLevel      =  60;//CCI Exit Level
// +------------------------------------------------------------------+
// |** Trend ATR **                                                   |
// +------------------------------------------------------------------+
input double            scaleATR             =  1.5;// Wave Size nATR - Flexing ATR (for Tip)
input waveCalcSizeType  wCalcSizeType        =  waveCalcATR;// -1: ATR, 0: array, other: set value; in Pts
input int               atrRange             =  50;//  large range to set wave cycled depth
input int               systemPollingSeconds =  5;// time secs for polling system
int                     onScreenVarLimit     =  10;/*Panel History Limit*/
double                  percentPullBack      =  25;// Max Wave Pull Back / Retrace
double                  atrMultiplier        =  1.5;// How many atr's to check pullback(not implemented yet)
int                     atrTrendPeriod       =  5;
int                     atrTrendAppliedPrice =  PRICE_CLOSE;
// +------------------------------------------------------------------+
// |** Trend EMA **                                                   |
// +------------------------------------------------------------------+
int                     emaTrendPeriod       =  50 ;
int                     emaTrendShift        =  0;
ENUM_MA_METHOD          emaTrendMethod       =  MODE_EMA;
ENUM_APPLIED_PRICE      emaTrendAppliedPrice =  PRICE_CLOSE;
// +------------------------------------------------------------------+
// |** VOL ATR **                                                     |
// +------------------------------------------------------------------+
bool                    showVolumes         =  true;// Show Volumes Ranges selected on chart
int                     atrVolPeriod        =  110;
int                     atrVolAppliedPrice  =  PRICE_CLOSE;//wrong entry here
// +------------------------------------------------------------------+
// |** Limit ATR **                                                   |
// +------------------------------------------------------------------+
input int               atrLimitPeriod      =  14;
// +------------------------------------------------------------------+
// | ** MISCELLANEOUS GLOBAL INIT **                                  |
// +------------------------------------------------------------------+
bool                    showPanel         =  shwPanel;
int                     unique_ID         =  0;
string                  symbolsList[];
static datetime         time0             =  NULL;
int                     numDefineWave     =  4;// number of elements to define a wave trend
int                     attemptsToReadBars=  0;
datetime                ptt;/*previous transaction time*/
static datetime         startTime         = TimeCurrent();
// +------------------------------------------------------------------+
// | Expert initialization function                                   |
// +------------------------------------------------------------------+
int OnInit()
  {
   if(trendTF1 < _Period)
     {
      Print(__FUNCTION__," First TF: ",EnumToString(trendTF1), " Must Be Greater Or Equal To Chart Period: ",EnumToString(_Period));
      return INIT_FAILED;
     }
   if(!setRunData())
      return(INIT_FAILED);
   ptt=NULL;
// no auto scroll
   ChartSetInteger(ChartID(),CHART_AUTOSCROLL,true);
   ChartSetInteger(ChartID(),CHART_CROSSHAIR_TOOL,true);
   ChartSetInteger(ChartID(),CHART_SHOW_VOLUMES,true);
   ChartShowGridSet(false,ChartID());
// ** Init *USE levels and trends info
   setUpFlow.createColors();
   if(!setUpFlow.createTrendObjects(isSingleSymbol, totalTrendsConsidered, trendTF1, trendTF2, trendTF3, showFirst, showSecond, showThird))
      return(INIT_PARAMETERS_INCORRECT);
   setUpFlow.createLevelTFs(isSingleSymbol,totalLevelsConsidered, levelTF1, levelTF2, levelTF3, levelTF4, levelTF5,showLevels);
   setUpFlow.createVolumeTFs(isSingleSymbol,totalVolsConsidered, volTF1, volTF2, volTF3, volTF4, volTF5,showVolumes);
   if(!setUpFlow.createAllTFs())
     {
      Print(__FUNCTION__," All Data set failed to produce a parameter for progression!");
      return(INIT_FAILED);
     }
   outPutProgramDetails(verboseOutputDetail);
// Dont consider levels  and volumes in historical data requirements
   if(totalLevelsConsidered==0)
      minBarsDegugRunLevel=0;
   if(totalVolsConsidered==0)
      minBarsDegugRunVolume=0;
   if(totalTrendsConsidered != 2)
     {
      Alert(__FUNCTION__," Trends must be 2: ",totalTrendsConsidered);
      return INIT_FAILED;
     }
   setUpFlow.initRatesFlow(minBarsDegugRunTrend,maxBarsDegugRunTrend,minBarsDegugRunLevel,maxBarsDegugRunLevel,minBarsDegugRunVolume,maxBarsDegugRunVolume);
   setUpFlow.initBarFlow(magicNumber,tradePercent,riskPerTrade,stpLoss,takeProfit,deltaFireRoom,candlesToExpire,numDefineWave,wCalcSizeType,
                         atrRange,atrTrendPeriod,atrTrendAppliedPrice,atrVolPeriod,atrVolAppliedPrice,
                         emaTrendPeriod,emaTrendShift,emaTrendMethod,emaTrendAppliedPrice,
                         dev,verboseDataInfo,percentPullBack,scaleATR,
                         cciTrendTriggerLevel,cciTrendExitLevel,cciTrendAppliedPrice,cciTrendPeriod,
                         atrMultiplier,showPanel,onScreenVarLimit,percentileValue,nBins,nHipLop,numVolBeforeDeletionStarts,verboseOutputDetail);
   if(!setUpFlow.addTips())
     {
      Print(__FUNCTION__, "*** ERROR *** InitFailed on addTips");
      return(INIT_FAILED);
     }
   setDebugAndBackTestVisuals();
   Print("Init succeeded");
   EventSetTimer(2);
   return(INIT_SUCCEEDED);
  }
// +------------------------------------------------------------------+
// | polling and set up checks of system                              |
// +------------------------------------------------------------------+
void OnTimer()
  {
   if(setUpFlow.dls == doDataHasLoaded)
      intervalTick();
   else
      if(setUpFlow.dls == doInitBroker)
        {
         if(!setUpFlow.initInitialRatesSequence())
           {
            attemptsToReadBars+=1;
            if(attemptsToReadBars > 10)
              {
               //Unload the EA there is a problem with broker data
               EventKillTimer();
               DebugBreak();
               Print(TimeCurrent(),": ",__FUNCTION__,"*** Expert advisor will be unloaded");
               ExpertRemove();
               return;
              }
            Print(__FUNCTION__," *** Failed to retrieve data initInitialRatesSequence");
            return;
           }
         else
           {
            attemptsToReadBars = 0;
            setUpFlow.dls = doStratElement;
           }
        }
      else
         if(setUpFlow.dls == doStratElement)
           {
            if(!setUpFlow.initStratElements())
              {
               // empty the Container lists of any levels volumes and trends created - since it failed
               // make sure everything is zeroed including the indicators for all indicators and time frames
               emptyContainers();
               attemptsToReadBars+=1;
               if(attemptsToReadBars > 10)
                 {
                  //Unload the EA there is a problem initialisation
                  EventKillTimer();
                  DebugBreak();
                  Print(TimeCurrent(),": ",__FUNCTION__,"*** Fatal Error: initStrategyComponents or initIndicators: -> Expert advisor will be unloaded");
                  ExpertRemove();
                  return;
                 }
               Print(__FUNCTION__," *** Failed to retrieve data !setUpFlow.initStratElements() ");
              }
            else
              {
               attemptsToReadBars = 0;
               setUpFlow.dls=doInitIndicatorsTick;
              }
           }
         else
            if(setUpFlow.dls == doInitIndicatorsTick)
              {
               if(!setUpFlow.initIndicatorsTick() || !setUpFlow.haveLimitATR())
                 {
                  attemptsToReadBars+=1;
                  if(attemptsToReadBars > 10)
                    {
                     //Unload the EA there is a problem with broker data
                     EventKillTimer();
                     DebugBreak();
                     Print(TimeCurrent(),": ",__FUNCTION__,"*** Expert advisor will be unloaded");
                     ExpertRemove();
                     return;
                    }
                  Print(__FUNCTION__," *** Failed to retrieve data initInitIndicatorsTick");
                  return;
                 }
               else
                 {
                  attemptsToReadBars = 0;
                  setUpFlow.dls = doStartStrategy;
                 }
              }
            else
               if(setUpFlow.dls==doStartStrategy)
                 {
                  if(!strategyTick())
                    {
                     attemptsToReadBars+=1;
                     if(attemptsToReadBars > 10)
                       {
                        //Unload the EA there is a problem with broker data
                        EventKillTimer();
                        DebugBreak();
                        Print(TimeCurrent(),": ",__FUNCTION__,"*** Expert advisor will be unloaded");
                        ExpertRemove();
                        return;
                       }
                     Print(__FUNCTION__," *** Failed to retrieve data strategyTick");
                     return;
                    }
                  else
                    {
                     attemptsToReadBars = 0;
                     setUpFlow.dls = doDataHasLoaded;
                    }
                 }
  }
// +------------------------------------------------------------------+
// | initialise the run                                               |
// +------------------------------------------------------------------+
bool strategyTick()
  {
   bool condition = true;
   datetime tda[];
// The instrument responsible for the tick is the chart the EA is attached to. Further newBar is whatever timeFrame EA is running on
   int copied = CopyTime(_Symbol,_Period,0,1,tda);
   time0 = tda[0];
   if(setUpFlow.dls == doStartStrategy)
     {
      for(int ins=0; (ins<ArraySize(setUpFlow.instrumentPointers)); ins++)
        {
         for(int iTF=0; iTF<ArraySize(setUpFlow.tfDataTrend.useTF); iTF++)
           {
            if(setUpFlow.startStrategyComponents(ins,iTF))
              {
               //   Print(__FUNCTION__," Success to initialise: ", setUpFlow.instrumentPointers[ins].symbol," ", EnumToString(setUpFlow.tfDataTrend.useTF[iTF]), " @timeZero: ",time0);
               continue;
              }
            else
              {
               Print(__FUNCTION__," *** Failed to initialise: ", setUpFlow.instrumentPointers[ins].symbol," ", EnumToString(setUpFlow.tfDataTrend.useTF[iTF]), " @timeZero: ",time0);
               return false;
              }
           }
         Print(__FUNCTION__," ",setUpFlow.instrumentPointers[ins].symbol," Initialised Instrument @timeZero: ",time0);
        }
     }
// update every five seconds
   EventKillTimer();
   EventSetTimer(systemPollingSeconds);
   setUpFlow.dls = doDataHasLoaded;
   return condition;
  }
// +------------------------------------------------------------------+
// | system has initialised and is polling @ systemPollingSeconds     |
// +------------------------------------------------------------------+
void intervalTick()
  {
   datetime tda[];
// The instrument responsible for the tick is the chart the EA is attached to. Further newBar is whatever timeFrame EA is running on
   int copied = CopyTime(_Symbol,_Period,0,1,tda);
   bool isNewBar=time0!=tda[0];
   time0=tda[0];
   if(isNewBar)
     {
      // Print(__FUNCTION__," dataHasLoaded:  SETTING TIME @:       ",TimeCurrent());
      // init strategy per instrument
      for(int ins=0; (ins<ArraySize(setUpFlow.instrumentPointers)); ins++)
        {
         // check if EA can trade, data from timeframes are available to client and in sync with trade server
         if(!setUpFlow.checkTrading(ins))
           {
            Alert(__FUNCTION__," EA cannot *TRADE because certain trade requirements are not met ",setUpFlow.instrumentPointers[ins].symbol);
            return;
           }
         // Get the last price quote using the SymbolInfo class object function
         if(!setUpFlow.instrumentPointers[ins].RefreshRates())
           {
            Alert("Error getting the latest price quote - error: ",ErrorDescription(GetLastError()),"!! ",setUpFlow.instrumentPointers[ins].symbol);
            return;
           }
         bool havePosition = setUpFlow.countPositions(int(setUpFlow.myTrade.RequestMagic()), setUpFlow.instrumentPointers[ins].Name()) > 0;
         bool haveOrder    = setUpFlow.countOrders(int(setUpFlow.myTrade.RequestMagic()), setUpFlow.instrumentPointers[ins].Name()) > 0;
         // close POSTITIONS on excess time or insufficient profit
         if(closeOnPositions && havePosition)
           {
            if(setUpFlow.profitProgressExcessTime(ins) && setUpFlow.profitProgressInsufficientPoints(ins,sufficientTargetPercent))
               setUpFlow.myTrade.PositionClose(setUpFlow.instrumentPointers[ins].Name(),ulong(setUpFlow.dev*setUpFlow.instrumentPointers[ins].Point()));
           }
         // close orders on failed order
         if(closeOnOrders && haveOrder)
           {
            if(setUpFlow.orderSetupFailed(setUpFlow.instrumentPointers[ins].Name(), int(setUpFlow.myTrade.RequestMagic())))
               setUpFlow.deleteStopBuyOrders(int(setUpFlow.myTrade.RequestMagic()), setUpFlow.instrumentPointers[ins].Name());
           }
         // Set All New Bar Info && Trend Line Info && CCI info
         setUpFlow.runNewBarInstruments(ins);
         comment(ins);
         //currently only open one trend .... will need multiple entires up to say (3) flag or trades table
         if(!havePosition &&  !haveOrder)
           {
            if(setUpFlow.checkEntryTrigger(ins,1) == open_long)
              {
               if(setUpFlow.openBuySellStopOrder(simLong,ins))
                  printHiLoAtTrade(ins);
               else
                  Print(__FUNCTION__," failed to open LONG Trade");
              }
            else
               if(setUpFlow.checkEntryTrigger(ins,1) == open_short)
                 {
                  if(setUpFlow.openBuySellStopOrder(simShort,ins))
                     printHiLoAtTrade(ins);
                  else
                     Print(__FUNCTION__," failed to open SHORT Trade");
                 }
           }
         // setUpFlow.moveAllStops(ins);
         if(setUpFlow.closeOnStateFailure(ins,1))
            setUpFlow.myTrade.PositionClose(setUpFlow.instrumentPointers[ins].Name(),ulong(setUpFlow.dev*setUpFlow.instrumentPointers[ins].Point()));
        }
      //exit on HTF setup state not intact
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void comment(int _ins)
  {
   Comment("|MAJOR: ",
           EnumToString(setUpFlow.cciGetState(_ins,1)),
           ",[1] "+DoubleToString(setUpFlow.cciGetValue(_ins,1,1),1),
           ",[0] "+DoubleToString(setUpFlow.cciGetValue(_ins,1,0),1),
           " |MINOR: ",
           EnumToString(setUpFlow.cciGetState(_ins,0))+", ",
           ",[1] "+DoubleToString(setUpFlow.cciGetValue(_ins,0,1),1),
           ",[0] "+DoubleToString(setUpFlow.cciGetValue(_ins,0,0),1)," | ",
           EnumToString(setUpFlow.getSetUpState()));
  }
//+------------------------------------------------------------------+
//|printCCIsAtTrade print out cci values on entering a trade         |
//+------------------------------------------------------------------+
void printHiLoAtTrade(int _ins)
  {
   string printText ="opened for : "+IntegerToString(_ins)+" , "+setUpFlow.instrumentPointers[_ins].symbol;
//for(int index= 0; (index < setUpFlow.instrumentPointers[_ins].pContainerTip.Total()); index++)
//  {
//   Tip *tip=setUpFlow.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
//   printText+="CCI: "+EnumToString(tip.waveHTFPeriod)+" "+EnumToString(tip.cciWaveInfo.getCCIState())+" "+DoubleToString(tip.cciWaveInfo.cciWrapper.cciValue[0]);
//  }
   Print(__FUNCTION__," ",printText);
//Pause During Test
   pauseDuringTesting(pdt);
  }
//+------------------------------------------------------------------+
//|printCCIsAtTrade print out cci values on entering a trade         |
//+------------------------------------------------------------------+
void printCCIsAtTrade(int _ins)
  {
   string printText ="";
   for(int index= 0; (index < setUpFlow.instrumentPointers[_ins].pContainerTip.Total()); index++)
     {
      Tip *tip=setUpFlow.instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
      printText+="CCI: "+EnumToString(tip.waveHTFPeriod)+" "+EnumToString(tip.cciWaveInfo.getCCIState())+" "+DoubleToString(tip.cciWaveInfo.getCCIValue(0));
     }
   Print(__FUNCTION__," ",printText);
  }
// +------------------------------------------------------------------+
// | OnTick                                                           |
// +------------------------------------------------------------------+
//void OnTick()
// {
// // check close positions
// }
// +------------------------------------------------------------------+
// | called when a Trade event arrives                                |
// +------------------------------------------------------------------+
void OnTrade()
  {
   ulong    dealTicket;            // deal ticket
//ulong    orderTicket;           // ticket of the order the deal was executed on
   datetime tt;                    // time of a deal execution
   long     dealType ;             // type of a trade operation
   long     dealReason;            // reason for deal activation
//long     positionID;            // position ID
   string   dealDescription;       // operation description
//double   volume;                // operation volume
   string   symbol;                // symbol of the deal
   int      magic;                 // magic Number

//static datetime startTime = TimeCurrent();
//datetime startTime   = TimeCurrent()-(PeriodSeconds(_Period));

   datetime endTime     = TimeCurrent();
   HistorySelect(startTime, endTime);
   int totHist          = HistoryDealsTotal();
   if(!GetPointer(setUpFlow.myHistOrder) != NULL)
      return;
   if(totHist <= 0)
      return;
//get last Deal that was done (last order executed)
   dealTicket=               HistoryDealGetTicket(totHist-1);
   tt   = (datetime)HistoryDealGetInteger(dealTicket,DEAL_TIME);
// this transaction time == time of previously checked transaction
   if(tt == ptt)
      // Already processed this transaction
      return;
   dealType    =    HistoryDealGetInteger(dealTicket,DEAL_TYPE);
   dealReason  =  HistoryDealGetInteger(dealTicket,DEAL_REASON);
// have Buy or Sell since last Period?
   if(dealType==DEAL_TYPE_BUY)
     {
      symbol            =  HistoryDealGetString(dealTicket,DEAL_SYMBOL);
      magic             = (int)HistoryDealGetInteger(dealTicket,DEAL_MAGIC);
      // Cancel other Entry orders for this instrument as we have an open order
      //  setUpFlow.cancelAllSymbolOrders(symbol, magic);
      ptt=tt;
     }
   else
      if(dealType== DEAL_TYPE_SELL)
        {
         symbol            =  HistoryDealGetString(dealTicket,DEAL_SYMBOL);
         magic             = (int)HistoryDealGetInteger(dealTicket,DEAL_MAGIC);
         // Cancel other Entry orders for this instrument as we have an open order
         //   setUpFlow.cancelAllSymbolOrders(symbol, magic);
         ptt=tt;
        }
//Been stopped out cancelled or expired? ...
   if(dealReason == DEAL_REASON_SL)
     {
      ptt=tt;
      Print(__FUNCTION__," SL: ",Symbol(),": ",dealReason);
     }
   else
      if(dealReason == DEAL_REASON_TP)
        {
         ptt=tt;
         Print(__FUNCTION__," TP: ",Symbol()," : ",dealReason);
        }
      else
         if(dealReason == DEAL_REASON_EXPERT)
           {
            // The deal was executed as a result of activation of an order placed from an MQL5 program, i.e. an Expert Advisor or a script
            ptt=tt;
            Print(__FUNCTION__," Expert: ",Symbol()," : ",dealReason);
           }
         else
            if(dealReason == DEAL_REASON_SO)
              {
               ptt=tt;
               Print(__FUNCTION__," SO: ",Symbol()," : ",dealReason);
              }
            else
               if(dealReason == DEAL_REASON_CLIENT)
                 {
                  // The deal was executed as a result of activation of an order placed from a desktop terminal
                  ptt=tt;
                  Print(__FUNCTION__," Client: ",Symbol()," : ",dealReason);
                 }
               else
                 {
                  Print(dealReason);
                 }
  }
// +------------------------------------------------------------------+
// | Expert deinitialization function                                 |
// +------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print(__FUNCTION__," Start Deinit");
   EventKillTimer();
   time0=NULL;
//clear levels volumes and trends
   emptyContainers();
// Delete array of instrument Pointers
   Instrument *instrument=NULL;
   for(int p=0; p<ArraySize(setUpFlow.instrumentPointers); p++)
     {
      //.trends
      setUpFlow.instrumentPointers[p].pContainerTip.Clear();
      // lips
      setUpFlow.instrumentPointers[p].pContainerLip.Clear();
      delete(setUpFlow.instrumentPointers[p].pContainerLip.pSumLipElements);
      delete(setUpFlow.instrumentPointers[p].pContainerLip);
      instrument=setUpFlow.instrumentPointers[p];
      delete(instrument);
     }
// remove trendData pointers
   setUpFlow.deInit();
   Sleep(1000);
   Print("DeInit Complete");
  }
//+------------------------------------------------------------------+
//|  emptyContainers                                                 |
//+------------------------------------------------------------------+
void emptyContainers()
  {
// --Delete All Levels
   Lip *lList=NULL;
   for(int ins=0; (ins<ArraySize(setUpFlow.instrumentPointers)); ins++)
     {
      // Clean Levels
      int totLevel=setUpFlow.instrumentPointers[ins].pContainerLip.Total();
      for(int lst=0; lst<totLevel; lst++)
        {
         if((CheckPointer(setUpFlow.instrumentPointers[ins].pContainerLip.GetNodeAtIndex(lst))!=POINTER_INVALID))
           {
            lList=setUpFlow.instrumentPointers[ins].pContainerLip.GetNodeAtIndex(lst);
            // empty the list and delete the lines
            lList.destroyAllLevels();
           }
         else
            Print(__FUNCTION__,"Pointer Invalid LEVELS total instruments: ",totLevel);
        }
      //-- clean trends
      DiagTip *tip=NULL;
      for(int lst=0; lst<setUpFlow.instrumentPointers[ins].pContainerTip.Total(); lst++)
        {
         setUpFlow.symbolIsShown = false;
         if((CheckPointer(setUpFlow.instrumentPointers[ins].pContainerTip.GetNodeAtIndex(lst))!=POINTER_INVALID))
           {
            tip=setUpFlow.instrumentPointers[ins].pContainerTip.GetNodeAtIndex(lst);
            Print(__FUNCTION__," deleting:", EnumToString(tip.waveHTFPeriod));
            // empty the list of trendElementObjs and delete trend lines and arrows
            tip.cleanTrend();
            tip.cleanDiagLine();
            tip.Clear();
            if(showPanel)
              {
               if(!LabelDelete(0,tip.onScreenDesc))
                  Print(__FUNCTION__," failed to delete label: ",tip.onScreenDesc);
               Sleep(1);
               if(!LabelDelete(0,tip.onScreenWaveHeight))
                  Print(__FUNCTION__," failed to delete label: ",tip.onScreenWaveHeight);
               Sleep(1);
               if(!LabelDelete(0,tip.onScreenArrowLabel))
                  Print(__FUNCTION__," failed to delete label: ",tip.onScreenArrowLabel);
               Sleep(1);
               if(showPanel)
                  if(!setUpFlow.symbolIsShown)
                    {
                     if(!LabelDelete(0,tip.onScreenSymbol))
                        Print(__FUNCTION__," failed to delete label: ",tip.onScreenSymbol);
                     setUpFlow.symbolIsShown =true;
                    }
              }
           }
         else
            Print(__FUNCTION__,"Pointer Invalid TREND total instruments: ",setUpFlow.instrumentPointers[ins].pContainerTip.Total(),"instrument Number: ",lst," symbol: ",setUpFlow.instrumentPointers[ins].symbol);
        }
      // remove volume aspect
      Vip *vList=NULL;
      // Clean Volumes
      int totVols=setUpFlow.instrumentPointers[ins].pContainerVip.Total();
      for(int lst=0; lst<totVols; lst++)
        {
         if((CheckPointer(setUpFlow.instrumentPointers[ins].pContainerVip.GetNodeAtIndex(lst))!=POINTER_INVALID))
           {
            vList=setUpFlow.instrumentPointers[ins].pContainerVip.GetNodeAtIndex(lst);
            // empty the list and delete the lines
            vList.clearElements();
           }
         else
            Print(__FUNCTION__,"Pointer Invalid LEVELS total instruments: ",totLevel,"instrument Number: ",ins);
        }
      setUpFlow.instrumentPointers[ins].pContainerTip.Clear();
      setUpFlow.instrumentPointers[ins].pContainerLip.Clear();
      setUpFlow.instrumentPointers[ins].pContainerLip.pSumLipElements.Clear();
      setUpFlow.instrumentPointers[ins].pContainerVip.Clear();
     }
  }
//+------------------------------------------------------------------+
//|  outPutProgramDetails                                            |
//+------------------------------------------------------------------+
void outPutProgramDetails(bool _vod)
  {
   if(!_vod)
      return;
   Print("************************ MQL Program Details ****************************");
   ENUM_PROGRAM_TYPE mql_program=(ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE);
   switch(mql_program)
     {
      case PROGRAM_SCRIPT:
        {
         Print(__FILE__+" is script");
         break;
        }
      case PROGRAM_EXPERT:
        {
         Print(__FILE__+" is Expert Advisor");
         break;
        }
      case PROGRAM_INDICATOR:
        {
         Print(__FILE__+" is custom indicator");
         break;
        }
      default:
         Print("MQL5 program type value is ",mql_program);
     }
   printf("MQL_MEMORY_LIMIT (MB): "+string(MQLInfoInteger(MQL_MEMORY_LIMIT)));
   printf("MQL_MEMORY_USED (MB): "+string(MQLInfoInteger(MQL_MEMORY_USED)));
//printf("MQL5_PROGRAM_PATH: "+string(MQLInfoString(MQL5_PROGRAM_PATH)));
   if(MQLInfoInteger(MQL_TESTER))
      Print("MQL_TESTER MODE: TRUE");
   else
      Print("MQL_TESTER MODE: FALSE");
   if(MQLInfoInteger(MQL_DEBUG))
      Print("MQL_DEBUG: TRUE");
   else
      Print("MQL_DEBUG: FALSE");
   if(MQLInfoInteger(MQL_TRADE_ALLOWED))
      Print("MQL_TRADE_ALLOWED: TRUE");
   else
      Print("MQL_TRADE_ALLOWED: FALSE");
   if(MQLInfoInteger(MQL_SIGNALS_ALLOWED))
      Print("MQL_SIGNALS_ALLOWED: TRUE");
   else
      Print("MQL_SIGNALS_ALLOWED: FALSE");
   if(MQLInfoInteger(MQL_VISUAL_MODE))
      Print("MQL_VISUAL_MODE: TRUE");
   else
      Print("MQL_VISUAL_MODE: FALSE");
  }
// +--------------------------------------------------------------------+
// | Access Strategy Data - get the symbols to operate on for           |
// | Production or ST                                                   |
// +--------------------------------------------------------------------+
bool setRunData()
  {
//from common files area
   if(!readSymbolsToTrade())
     {
      Alert("Initialisation readSymbolsToTrade Failed");
      return(false);
     }
// Create array of pointers to instruments selected
   if(!setUpFlow.createInstruments(symbolsList,atrLimitPeriod,trendTF1))
     {
      Alert("Initialisation !setUpFlow.createInstruments Failed");
      return(false);
     }
// Print List of Instrument Pointers
   logInstrumentPointers();
// empty the watch List initially
   emptyWatch();
// Make sure selected instruments in the Terminal Watch
   if(!fillWatch(symbolsList))
      return(false);
//set the panel display to what was asked for in expert parameters
   showPanel=shwPanel;
// if multi run set to false
   setDisplayOptions(symbolsList);
   return true;
  }
// +------------------------------------------------------------------+
// | setDisplayOptions                                                |
// +------------------------------------------------------------------+
void setDisplayOptions(string &_symbolsList[])
  {
   if(ArraySize(_symbolsList)>1)
     {
      if(!showPanel)
         Comment(" ** GOING DARK: Multiple Instruments Selected -> No trend Lines");
     }
  }
// +------------------------------------------------------------------+
// |logInstrumentPointers                                             |
// +------------------------------------------------------------------+
void logInstrumentPointers()
  {
   Print(__FUNCTION__,"Logging Selected Instrument: ");
   for(int p=0; p<ArraySize(setUpFlow.instrumentPointers); p++)
     {
      Instrument *instrument=setUpFlow.instrumentPointers[p];
      if(GetPointer(instrument)!=NULL)
         Print(instrument.symbol);
      else
         Alert(__FUNCTION__," Symbol: "+symbolsList[p]+" Not Available in instrument Pointer List");
     }
  }
// +------------------------------------------------------------------+
// | listMarketWatch                                                  |
// +------------------------------------------------------------------+
//void listMarketWatch()
//  {
//   int HowManySymbols=SymbolsTotal(false);
//   for(int i=0; i<(HowManySymbols); i++)
//     {
//      Print(SymbolName(i,false));
//     }
//   Print(HowManySymbols);
//  }
// +------------------------------------------------------------------+
// | emptyWatch: Delete watch List Entries                            |
// +------------------------------------------------------------------+
void emptyWatch()
  {
   bool status=true;
   string symbol=NULL;
   int totalInWatch=SymbolsTotal(true);
   for(int i=0; i<totalInWatch; i++)
     {
      symbol=SymbolName(i,false);
      if(SymbolSelect(symbol,false))
        {
         Print(__FUNCTION__," included in the watch: ",symbol);
        }
     }
  }
// +------------------------------------------------------------------+
// | fillWatch: With instruments that you selected in file and        |
// | available now                                                    |
// +------------------------------------------------------------------+
bool fillWatch(string &_symbolsList[])
  {
   int numSymbols=ArraySize(setUpFlow.instrumentPointers);
   for(int p=0; p<numSymbols; p++)
     {
      Instrument *instrument=setUpFlow.instrumentPointers[p];
      if(!SymbolSelect(instrument.symbol,true))
        {
         Alert("*WARNING: "__FUNCTION__," Failed to add: "+instrument.symbol+" to Market Watch ");
         return false;
        }
     }
   return true;
  }
// +------------------------------------------------------------------+
// | readSymbolsToTrade                                               |
// +------------------------------------------------------------------+
bool readSymbolsToTrade()
  {
   bool status=false;
   string fileName=convertSymbolsFileText(int(fileSymbolsSelected));
   ReadStringFile symbolsFileObj;
// Read the file
   if(symbolsFileObj.fileInit(fileName))
     {
      if(symbolsFileObj.readSymbolsList(symbolsList,isSingleSymbol))
         status=true;
      else
         status=false;
     }
   else
     {
      Alert("*WARNING: ",__FUNCTION__," Failed to read Symbols");
      // failed to open dont need to close!
      return false;
     }
   symbolsFileObj.fileClose(symbolsList, isSingleSymbol);
   return status;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void    setDebugAndBackTestVisuals()
  {
//// Debugging on history data
//   if(IS_DEBUG_MODE && MQLInfoInteger(MQL_TESTER))
//     {
//      Print("********************* MQL_Debug");
//      TesterHideIndicators(true);
//     }
// Debugging on real data
   if(IS_DEBUG_MODE && !MQLInfoInteger(MQL_TESTER))
     {
      Print("********************* MQL_Debug");
      TesterHideIndicators(false);
     }
// Run on historical data
   if(!IS_DEBUG_MODE && MQLInfoInteger(MQL_TESTER))
     {
      Print("********************* MQL_Tester");
      TesterHideIndicators(false);
     }
//  // run time view of real data
//else
//  {
//   Print("********************* MQL_None");
//   TesterHideIndicators(false);
//  }
  }
//+------------------------------------------------------------------+
