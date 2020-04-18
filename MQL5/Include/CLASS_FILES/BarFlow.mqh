// +------------------------------------------------------------------+
// |                                                    simObject.mqh |
// |                                               Robert Baptie 2019 |
// |                                             https:// www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Robert Baptie 2018"
#property link      "https:// www.mql5.com"
#property version   "1.00"
#property strict
#include <Arrays\List.mqh>
#include <Trade\Trade.mqh> // --- CTrade
#include <Trade\PositionInfo.mqh>      // --- CPositionInfo
#include <Trade\AccountInfo.mqh>       // --- CAccountInfo
#include <Trade\OrderInfo.mqh>         // --- OrderInfo
#include <Trade\SymbolInfo.mqh>        // --- CSymbolInfo
#include <Expert\Expert.mqh>           // --- OrderInfo
#include <errordescription.mqh>
#include <CLASS_FILES\Instrument.mqh>
#include <CLASS_FILES\TFData.mqh>
#include <CLASS_FILES\ColorsTF.mqh>
#include <\\CLASS_FILES\\ContainerDiagonalTip.mqh>
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <errordescription.mqh>
// +-------------------------------------------------------------------+
// | Class BarFlow - Control Flow of Bars                              |
// +-------------------------------------------------------------------+
class BarFlow:public CList
  {
public:
   int               BarFlow::uniqueID;
   //MqlRates          ratesChartBars[];
   // MqlRates          ratesHTF[];
   bool              symbolIsShown;
   CTrade            myTrade;
   CPositionInfo     myPosition;
   CAccountInfo      myAccount;
   COrderInfo        myOrder;
   CHistoryOrderInfo myHistOrder;
   Instrument        *instrumentPointers[];
   TFTrendDataObj    *tfDataTrend;
   TFLevelDataObj    *tfDataLevel;
   TFVolumeDataObj   *tfDataVolume;
   TFAllDataObj      *tfDataAll;
   ColorsTF          *colorsTF;
   waveCalcSizeType  wCalcSizeType;      // -1: ATR, 0: array, other: set value; in Pts
   int               atrRange;
   int               atrTrendPeriod;
   int               atrTrendAppliedPrice;
   int               atrVolPeriod;
   int               atrVolAppliedPrice;
   double            waveHeightPts;
   int               numDefineWave; // number of wave points to consider when defining a trend
   double            percentPullBack;      // Max Wave Pull Back / Retrace
   double            scaleATR;       // Wave Size Flexing ATR (for TipObj)
   double            fracThreshHold;     // % Candle Cause Print AD Arrow
   double            cciTriggerLevel;
   double            cciExitLevel;
   int               cciAppliedPrice;
   int               cciPeriod;
   int               emaTrendPeriod;
   int               emaTrendShift;
   ENUM_MA_METHOD    emaTrendMethod;
   ENUM_APPLIED_PRICE emaTrendAppliedPrice;
   int               datumCandlesToExpire; // datum Candles
   double            atrMultiplier;
   bool              showPanel;    // show Panel History
   int               onScreenVarLimit;      // Panel History Limit
   int               percentileValue;      // 10Sensitivity of S/R
   int               nBins;
   int               numVolBeforeDeletionStarts;
   int               nATRsFromHLCalcDisplay;
   int               nHipLop;
   ulong             dev;
   int               tradePercent;
   bool              verboseDataInfo;
   int               magicNumber;
   double            riskPerTrade;
   int               sl;
   int               tp;
   double            deltaFireRoom;
   // **  CONSTRUCTOR  ** //
   bool              BarFlow::initBarFlow(
      int                  _magicNumber,
      int                  _tradePercent,
      double               _riskPerTrade,
      int                  _sl,
      int                  _tp,
      int                  _deltaFireRoom,
      int                  _numDefineWave,
      waveCalcSizeType     _wCalcSizeType,
      int                  _atrRange,
      int                  _atrTrendPeriod,
      int                  _atrTrendAppliedPrice,
      int                  _atrVolPeriod,
      int                  _atrVolAppliedPrice,
      int                  _emaTrendPeriod,
      int                  _emaTrendShift,
      ENUM_MA_METHOD       _emaTrendMethod,
      ENUM_APPLIED_PRICE   _emaTrendAppliedPrice,
      ulong                _dev,
      bool                 _verboseDataInfo,
      double               _percentPullBack,
      double               _scaleATR,
      double               _cciTriggerLevel,
      double               _cciExitLevel,
      int                  _cciAppliedPrice,
      int                  _cciPeriod,
      double               _atrMultiplier,
      bool                 _showPanel,
      int                  _onScreenVarLimit,
      int                  _percentileValue,
      int                  _nBins,
      int                  _nHipLop,
      int                  _numVolBeforeDeletionStarts,
      bool                 _verboseOutputDetail);
   // increment the class variable
   void              BarFlow::incUniqueID(int _byInc);
   bool              createInstruments(string &_symbolsList[]);
   //Detailed info on startup conditions
   void              outputAccountSettings(bool _vDetail);
   color             findColor(ENUM_TIMEFRAMES tf);
   // create trend Tfs and set colors
   bool              BarFlow::createTrendObjects(bool _isSingleSymbol,int  _totalTrendsConsidered, ENUM_TIMEFRAMES _trendTF1, ENUM_TIMEFRAMES _trendTF2, ENUM_TIMEFRAMES _trendTF3, bool _showTrendTF1, bool _showTrendTF2, bool _showTrendTF3);
   // create level tfs and set colors
   bool              BarFlow::createLevelTFs(bool _isSingleSymbol, int _numHTFs,ENUM_TIMEFRAMES _HTF0,ENUM_TIMEFRAMES _HTF1,ENUM_TIMEFRAMES _HTF2,ENUM_TIMEFRAMES _HTF3,ENUM_TIMEFRAMES _HTF4, bool blackedHTF0);
   // create level tfs and set colors
   bool              BarFlow::createVolumeTFs(bool _isSingleSymbol, int _numHTFs,ENUM_TIMEFRAMES _HTF0,ENUM_TIMEFRAMES _HTF1,ENUM_TIMEFRAMES _HTF2,ENUM_TIMEFRAMES _HTF3,ENUM_TIMEFRAMES _HTF4, bool blackedHTF0);
   int               BarFlow::hasTFIndex(ENUM_TIMEFRAMES _tfInterested, string trndLvl);
   void              BarFlow::createColors();
   bool              BarFlow::createAllTFs();
   void              BarFlow::createTFObj(bool _tM1,bool _tM5,bool _tM15,bool _tM30,bool _tH1,bool _tH4,bool _tD1,bool _tW1,bool _tMN1,bool &includeTF[]);
   // Check for a valid new bar for HTF
   bool              BarFlow::isNewHTF(Tip  *_trend,int _shift);
   // Check for a valid new bar for HTF
   bool              BarFlow::isNewHTF(Lip  *_sr);
   // Check for a valid new bar for HTF
   bool              BarFlow::isNewHTF(Vip  *_volume);
   //   Checks if our Expert Advisor can go ahead and perform trading
   bool              BarFlow::checkTrading(int ins);
   // update instrument chart indicators (ATR)
   //bool              BarFlow::updateIndicators(int _ins, ENUM_TIMEFRAMES _period);
   // hide sub windows
   void              BarFlow::hideTrendSubWindows(int _calculatedSubWindows);
   void              BarFlow::hideVolumeSubWindows(int _calculatedSubWindows);
   void              BarFlow::deInit();
  };
// +------------------------------------------------------------------+
// | BarFlow::init                                                    |
// +------------------------------------------------------------------+
bool BarFlow::initBarFlow(
   int               _magicNumber,
   int               _tradePercent,
   double            _riskPerTrade,
   int               _sl,
   int               _tp,
   int               _deltaFireRoom,
   int               _numDefineWave,
   waveCalcSizeType  _wCalcSizeType,
   int               _atrRange,
   int               _atrTrendPeriod,
   int               _atrTrendAppliedPrice,
   int               _atrVolPeriod,
   int               _atrVolAppliedPrice,
   int               _emaTrendPeriod,
   int               _emaTrendShift,
   ENUM_MA_METHOD    _emaTrendMethod,
   ENUM_APPLIED_PRICE _emaTrendAppliedPrice,
   ulong             _dev,
   bool              _verboseDataInfo,
   double            _percentPullBack,
   double            _scaleATR,
   double            _cciTriggerLevel,
   double            _cciExitLevel,
   int               _cciAppliedPrice,
   int               _cciPeriod,
   double            _atrMultiplier,
   bool              _showPanel,
   int               _onScreenVarLimit,
   int               _percentileValue,
   int               _nBins,
   int               _nHipLop,
   int               _numVolBeforeDeletionStarts,
   bool              _verboseOutputDetail)
  {
   magicNumber    =  _magicNumber;
   tradePercent   =  _tradePercent;
   riskPerTrade   =  _riskPerTrade;
   sl             =  _sl;
   tp             =  _tp;
   dev = _dev;
   deltaFireRoom =_deltaFireRoom;
   showPanel=_showPanel;
// how many waves make a trend calculation(4)
   numDefineWave=_numDefineWave;
// hold the information on the time frames per trend level and Ad in a tfDataObj
   wCalcSizeType  =  _wCalcSizeType;
   onScreenVarLimit=_onScreenVarLimit;      // Panel History Limit
   percentileValue=_percentileValue;      // 10Sensitivity of S/R
   nBins=_nBins;
   nHipLop =_nHipLop;
   numVolBeforeDeletionStarts =_numVolBeforeDeletionStarts;
// To Log - output of Account Settings
   verboseDataInfo=_verboseDataInfo;
   outputAccountSettings(_verboseOutputDetail);
// inidcator parameters
   atrRange       =  _atrRange;
   atrTrendPeriod=   _atrTrendPeriod;
   atrTrendAppliedPrice  = _atrTrendAppliedPrice;
   atrVolPeriod=   _atrVolPeriod;
   atrVolAppliedPrice  = _atrVolAppliedPrice;
   percentPullBack=_percentPullBack;      // Max Wave Pull Back / Retrace
   scaleATR=_scaleATR;       // Wave Size Flexing ATR (for TipObj)
   wCalcSizeType=_wCalcSizeType;      // -1: ATR, 0: array, other: set value; in Pts
   atrRange = _atrRange; //Period of ATR
   cciTriggerLevel = _cciTriggerLevel;
   cciExitLevel = _cciExitLevel;
   cciAppliedPrice=_cciAppliedPrice;
   cciPeriod=_cciPeriod;
   emaTrendPeriod=_emaTrendPeriod;
   emaTrendShift=_emaTrendShift;
   emaTrendMethod=_emaTrendMethod;
   emaTrendAppliedPrice =_emaTrendAppliedPrice;
   atrMultiplier=_atrMultiplier;
// set MagicNumber for your orders identification
// set MagicNumber for your orders identification
   myTrade.SetExpertMagicNumber(_magicNumber);
// set available slippage in points when buying/selling
   myTrade.SetDeviationInPoints(_dev);
// order filling mode, the mode allowed by the server should be used
   myTrade.SetTypeFilling(ORDER_FILLING_RETURN);
// logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
//trade.LogLevel(1);
// what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
   myTrade.SetAsyncMode(true);
   return true;
  }
//+------------------------------------------------------------------+
//| incUniqueId                                                      |
//+------------------------------------------------------------------+
void BarFlow::incUniqueID(int _byInc)
  {
   uniqueID+=1;
  }
//+------------------------------------------------------------------+
//| deInit                                                           |
//+------------------------------------------------------------------+
void BarFlow::deInit()
  {
   if(CheckPointer(tfDataLevel)!=NULL)
      delete(tfDataLevel);
   if(CheckPointer(tfDataTrend)!=NULL)
      delete(tfDataTrend);
   if(CheckPointer(tfDataVolume)!=NULL)
      delete(tfDataVolume);
   if(CheckPointer(tfDataAll)!=NULL)
      delete(tfDataAll);
   if(CheckPointer(colorsTF)!=NULL)
      delete(colorsTF);
//   Print("Removed BarFlow");
  }
//+------------------------------------------------------------------+
//| hideTrendSubWindows                                              |
//+------------------------------------------------------------------+
void              BarFlow::hideTrendSubWindows(int _calculatedSubWindows)
  {
   long numberOfSubWindows = 0;
   Sleep(1000);
   ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL,0,numberOfSubWindows);
   int num_windows = (int)numberOfSubWindows;
   for(int sub_window = (int) num_windows-1; sub_window>0; sub_window--)
     {
      string name = ChartIndicatorName(ChartID(),sub_window,0);
      if(name == "Volumes")
         continue;
      string timePart = splitWindowString("_",name);
      int stringLength = StringLen(timePart);
      timePart = StringSubstr(timePart,0,stringLength-1);
      for(int y = 0; y<ArraySize(tfDataTrend.useTF); y++)
        {
         string enumTF = EnumToString(tfDataTrend.useTF[y]);
         string timePart2 = splitWindowString("_",enumTF);
         timePart2 = StringSubstr(timePart2,0,stringLength);
         if(
            ((StringSubstr(name,0,7) == "CCI(TRD") && (!this.tfDataTrend.showCCI[y]) && (timePart2 == timePart))||
            // ((StringSubstr(name,0,7) == "EMA(TRD") && (!this.tfDataTrend.showEMA[y]) && (timePart2 == timePart))||
            ((StringSubstr(name,0,7) == "ATR(TRD") && (!this.tfDataTrend.showATR[y]) && (timePart2 == timePart))
         )
           {
            // reduce my size"
            do
              {
               ChartSetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,sub_window,1);
               Alert(__FUNCTION__," ******TRD: set Trend sub window:",name," id:", sub_window," to 1 pixel");
              }
            while(ChartGetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,sub_window)>1);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| hideVolumeSubWindows                                             |
//+------------------------------------------------------------------+
void              BarFlow::hideVolumeSubWindows(int _calculatedSubWindows)
  {
   long numberOfSubWindows = 0;
   Sleep(1000);
   ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL,0,numberOfSubWindows);
   int num_windows = (int)numberOfSubWindows;
   for(int sub_window = (int) num_windows-1; sub_window>0; sub_window--)
     {
      string name = ChartIndicatorName(ChartID(),sub_window,0);
      if(name == "Volumes")
         continue;
      string timePart = splitWindowString("_",name);
      int stringLength = StringLen(timePart);
      timePart = StringSubstr(timePart,0,stringLength-1);
      for(int y = 0; y<ArraySize(tfDataVolume.useTF); y++)
        {
         string enumTF = EnumToString(tfDataVolume.useTF[y]);
         string timePart2 = splitWindowString("_",enumTF);
         timePart2 = StringSubstr(timePart2,0,stringLength);
         if(
            ((StringSubstr(name,0,7) == "ATR(VOL") && (!this.tfDataVolume.showATR[y]) && (timePart2 == timePart))
         )
           {
            // reduce my size"
            do
              {
               ChartSetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,sub_window,1);
               Alert(__FUNCTION__," ******VOL: set Volume sub window:",name," id:", sub_window," to 1 pixel");
              }
            while(ChartGetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,sub_window)>1);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| hideTrendSubWindows                                              |
//+------------------------------------------------------------------+
string              splitWindowString(string _sep, string _stringToSplit)
  {
   ushort u_sep;                  // The code of the separator character
   string result[];               // An array to get strings
//--- Get the separator code
   u_sep=StringGetCharacter(_sep,0);
//--- Split the string to substrings
   int k=StringSplit(_stringToSplit,u_sep,result);
   return result[1];
  }
// +------------------------------------------------------------------+
// | createInstruments: return list of array pointers to instruments  |
// +------------------------------------------------------------------+
bool  BarFlow::createInstruments(string &_symbolsList[])
  {
   bool condition =false;
   ArrayResize(instrumentPointers,ArraySize(_symbolsList));
   for(int p=0; p<=ArraySize(_symbolsList)-1; p++)
     {
      Instrument *insPntr=new Instrument(_symbolsList[p]);
      if(GetPointer(insPntr)!=NULL)
        {
         instrumentPointers[p]=insPntr;
         condition = true;
        }
      else
        {
         Print(__FUNCTION__," Symbol: "+_symbolsList[p]+" Not Available");
         return false;
        }
     }
   return condition;
  }
// +------------------------------------------------------------------+
// |  outputAccountSettings                                           |
// +------------------------------------------------------------------+
void  BarFlow::outputAccountSettings(bool _vDetail)
  {
   if(!_vDetail)
      return;
   Print("************************ Account Settings *******************************");
   long accountno=myAccount.Login();
   Print("Login: ",accountno);
// --- returns "Demo trading account", "Real trading account" or "Contest trading account"
   string  acc_trading_mode=myAccount.TradeModeDescription();
   Print("Account trading mode: ",acc_trading_mode);

// --- returns leverage
   long acct_leverage=myAccount.Leverage();
   Print("Account leverage: ",acct_leverage);
   if(myAccount.TradeAllowed())
     {
      // --- trade allowed
      Print("Trade is allowed");
     }
   else
     {
      // --- trade not allowed
      Print("Trade is not allowed");
     }
   if(myAccount.TradeExpert())
     {
      // --- trade by Expert Advisors is allowed
      Print("Trade by Expert Advisors is allowed");
     }
   else
     {
      // --- trade by Expert Advisors is not allowed
      Print("Trade by Expert Advisors is not allowed");
     }

// --- get account balance in deposit currency
   double acc_balance=myAccount.Balance();
   Print("Account balance in deposit currency: ",acc_balance);

// --- get account profit in deposit currency
   double acc_profit=myAccount.Profit();
   Print("Account profit in deposit currency: ",acc_profit);

// --- get account free margin
   double acc_free_margin=myAccount.FreeMargin();
   Print("Account free margin:",acc_free_margin);

// --- get account currency
   string acc_currency=myAccount.Currency();
   Print("Account currency: ",acc_currency);

// --- get operation profit
   double operation_profit=myAccount.OrderProfitCheck(_Symbol,ORDER_TYPE_BUY,1.0,1.2950,1.3235);
   Print("Profit for buy of ",_Symbol," 1.2950/1.3235: ",operation_profit);

// --- get margin, required for trade operation
   double margin_req=myAccount.MarginCheck(_Symbol,ORDER_TYPE_BUY,1.0,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("Margin, required for trade operation:",margin_req);

// --- get free margin, left after trade operation
   double f_margin=myAccount.FreeMarginCheck(_Symbol,ORDER_TYPE_BUY,1.0,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("Free margin, left after trade operation: ",f_margin);

// --- get maximum trade volume
   double max_lot=myAccount.MaxLotCheck(_Symbol,ORDER_TYPE_BUY,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("Maximum trade volume: ",max_lot);
// Are we in hedging mode
   Print(EnumToString(myAccount.MarginMode()));
  }
// +------------------------------------------------------------------+
// |check this object array contains the TF we are interested in      |
// +------------------------------------------------------------------+
int BarFlow::hasTFIndex(ENUM_TIMEFRAMES _tfInterested, string trndLvl)
  {
   if(trndLvl =="trend")
     {
      if(CheckPointer(tfDataTrend)!= POINTER_INVALID)
        {
         for(int i = 0 ; i< ArraySize(this.tfDataTrend.useTF); i++)
           {
            if(_tfInterested == tfDataTrend.useTF[i])
               return i;
           }
        }
     }
   else
      if(trndLvl =="level")
        {
         if(CheckPointer(tfDataLevel)!= POINTER_INVALID)
           {
            for(int i = 0 ; i< ArraySize(this.tfDataLevel.useTF); i++)
              {
               if(_tfInterested == tfDataLevel.useTF[i])
                  return i;
              }
           }
        }
      else
         if(trndLvl =="volume")
           {
            if(CheckPointer(tfDataVolume)!= POINTER_INVALID)
              {
               for(int i = 0 ; i< ArraySize(this.tfDataVolume.useTF); i++)
                 {
                  if(_tfInterested == tfDataVolume.useTF[i])
                     return i;
                 }
              }
           }
   return -1;
  }
// +------------------------------------------------------------------+
// | Expert initialization function                                   |
// +------------------------------------------------------------------+
bool  BarFlow::isNewHTF(Tip  *_trend, int _shift)
  {
//datetime tdaLower[];
//CopyTime(_trend.symbol,_Period,0,1,tdaLower);
//datetime tdaHigher[];
//CopyTime(_trend.symbol,_trend.waveHTFPeriod,0,1,tdaHigher);
   datetime timePeriod = iTime(_Symbol,_Period,_shift);
   int htfShift = iBarShift(_Symbol, _trend.waveHTFPeriod, timePeriod, true);
   datetime timeHTF = iTime(_Symbol, _trend.waveHTFPeriod, htfShift);
   ResetLastError();
//--- move the anchor point
   if(timeHTF<0)
     {
      Print(__FUNCTION__,": Failed To retrieve HTF fromiBarShift = ",GetLastError());
      return(false);
     }
   if(timePeriod == timeHTF)
      return true;
   else
      return false;
  }
// +------------------------------------------------------------------+
// | Expert initialization function                                   |
// +------------------------------------------------------------------+
bool  BarFlow::isNewHTF(Lip  *_sr)
  {
   datetime tdaLower[];
   CopyTime(_sr.symbol,_Period,0,1,tdaLower);
   datetime tdaHigher[];
   CopyTime(_sr.symbol,_sr.waveHTFPeriod,0,1,tdaHigher);
   datetime timePeriod = iTime(_Symbol,_Period,0);
   datetime timeHTF = iTime(_Symbol,_sr.waveHTFPeriod,0);
   if(timePeriod == timeHTF)
      return true;
   else
      return false;
  }
// +------------------------------------------------------------------+
// | Expert initialization function                                   |
// +------------------------------------------------------------------+
bool  BarFlow::isNewHTF(Vip  *_volume)
  {
   datetime tdaLower[];
   CopyTime(_volume.symbol,_Period,0,1,tdaLower);
   datetime tdaHigher[];
   CopyTime(_volume.symbol,_volume.waveHTFPeriod,0,1,tdaHigher);
   datetime timePeriod = iTime(_Symbol,_Period,0);
   datetime timeHTF = iTime(_Symbol,_volume.waveHTFPeriod,0);
   if(timePeriod == timeHTF)
      return true;
   else
      return false;
  }
// +------------------------------------------------------------------+
// |  Checks if our Expert Advisor can go ahead and perform trading   |
// +------------------------------------------------------------------+
// This checks that the * chart period * has min bars- is this what you want?
bool  BarFlow::checkTrading(int ins)
  {
   bool canTrade=false;
// check if terminal is syncronized with server, etc
   if(myAccount.TradeAllowed() && myAccount.TradeExpert() && instrumentPointers[ins].IsSynchronized())
     {
      canTrade=true;
     }
   return(canTrade);
  }
// +------------------------------------------------------------------+
// | createTrendTFs                                                   |
// +------------------------------------------------------------------+
bool  BarFlow::createTrendObjects(bool _isSingleSymbol,int  _totalTrendsConsidered, ENUM_TIMEFRAMES _trendTF1, ENUM_TIMEFRAMES _trendTF2, ENUM_TIMEFRAMES _trendTF3, bool _showTrendTF1, bool _showTrendTF2, bool _showTrendTF3)
  {
   if((_totalTrendsConsidered <= 0) && (CheckPointer(tfDataTrend) != POINTER_INVALID))
     {
      delete(tfDataTrend);
      return false;
     }
//set up and initialise trend indicators array
//   ArrayResize(hideTrendIndicatorArray,2);
   tfDataTrend = new TFTrendDataObj();
//currently 2 per tf namely cci and atr. ema is on the chart window and isnt currently hidden
   tfDataTrend.numberWindows = 2 * _totalTrendsConsidered;
   ArrayResize(tfDataTrend.useTF,4);
   ArrayResize(tfDataTrend.tfColor,4);
// *_Period chart handle
   tfDataTrend.chartTF = _Period;
   if(_isSingleSymbol)
     {
      tfDataTrend.useTF[0]=_trendTF1;
      tfDataTrend.trendIndex[0]=0;
      tfDataTrend.showTrendWave[0]=_showTrendTF1;
      tfDataTrend.showDiaTrendLine[0] = _showTrendTF1;
      //     tfDataTrend.showCongestion[0] = false;
      tfDataTrend.showCCI[0] = false;
      tfDataTrend.showATR[0] = false;
      // main chart window doesnt work yet!
      tfDataTrend.showEMA[0] = true;
      // set second parameters
      tfDataTrend.useTF[1]=_trendTF2;
      tfDataTrend.trendIndex[1]=1;
      tfDataTrend.showTrendWave[1]=_showTrendTF2;
      tfDataTrend.showDiaTrendLine[1] = false;
      //    tfDataTrend.showCongestion[1] = false;
      tfDataTrend.showCCI[1] = false;
      tfDataTrend.showATR[1] = false;
      tfDataTrend.showEMA[1] = true;
      // set third parameters
      tfDataTrend.useTF[2]=_trendTF3;
      tfDataTrend.trendIndex[2]=2;
      tfDataTrend.showTrendWave[2]=_showTrendTF3;
      tfDataTrend.showDiaTrendLine[2] = false;
      //    tfDataTrend.showCongestion[2] = false;
      tfDataTrend.showCCI[2] = false;
      tfDataTrend.showATR[2] = false;
      tfDataTrend.showEMA[2] = false;
     }
   else
     {
      // Change Display for multiple instruments
      _showTrendTF1=false;
      _showTrendTF2=false;
      _showTrendTF3=false;
      // set first parameters
      tfDataTrend.useTF[0]=_trendTF1;
      tfDataTrend.trendIndex[0]=0;
      tfDataTrend.showTrendWave[0]=_showTrendTF1;
      tfDataTrend.showDiaTrendLine[0] = _showTrendTF1;
      //    tfDataTrend.showCongestion[0] = _showTrendTF1;
      // set second parameters
      tfDataTrend.useTF[1]=_trendTF2;
      tfDataTrend.trendIndex[1]=1;
      tfDataTrend.showTrendWave[1]=_showTrendTF2;
      tfDataTrend.showDiaTrendLine[1] = _showTrendTF2;
      //     tfDataTrend.showCongestion[1] = _showTrendTF2;
      // set third parameters
      tfDataTrend.useTF[2]=_trendTF3;
      tfDataTrend.trendIndex[2]=2;
      tfDataTrend.showTrendWave[2]=_showTrendTF3;
      tfDataTrend.showDiaTrendLine[2] = _showTrendTF3;
      //     tfDataTrend.showCongestion[2] = _showTrendTF3;
     }
// set colors
   tfDataTrend.tfColor[0]=findColor(_trendTF1);
   tfDataTrend.tfColor[1]=findColor(_trendTF2);
   tfDataTrend.tfColor[2]=findColor(_trendTF3);
// resize the array to take account of zero, second and the user selected number of trends to work with in establising overall trend
   ArrayResize(tfDataTrend.useTF, _totalTrendsConsidered);
   ArrayResize(tfDataTrend.tfColor, _totalTrendsConsidered);
// need loop for all instruments
   datetime tmeStart = iTime(NULL,_trendTF1, iBarShift(NULL,_trendTF1,iTime(NULL,_trendTF2,101)));
   if(tmeStart == 0)
     {
      Alert("Init Failed - Not Enough Data for HTF: Adjust The Start Run From Date");
      DebugBreak();
      return false;
     }
   return true;
  }
// +------------------------------------------------------------------+
// | createLevelTFs                                                   |
// +------------------------------------------------------------------+
bool              BarFlow::createLevelTFs(
   bool _isSingleSymbol,
   int _numHTFs,
   ENUM_TIMEFRAMES _HTF0,
   ENUM_TIMEFRAMES _HTF1,
   ENUM_TIMEFRAMES _HTF2,
   ENUM_TIMEFRAMES _HTF3,
   ENUM_TIMEFRAMES _HTF4,
   bool _showLevels)
  {
   if((_numHTFs <= 0) && (CheckPointer(tfDataLevel)  != POINTER_INVALID))
     {
      delete(tfDataLevel);
      return false;
     }
   tfDataLevel = new TFLevelDataObj();
   ArrayResize(tfDataLevel.useTF, 5);
   ArrayResize(tfDataLevel.tfColor,5);
// create array of tfs and colors for Level
   tfDataLevel.chartTF=_Period;
   tfDataLevel.useTF[0]=_HTF0;
// tfDataLevel.zeroIndex=0;
   tfDataLevel.useTF[1]=_HTF1;
//tfDataLevel.trendIndex2=0;
   tfDataLevel.useTF[2]=_HTF2;
   tfDataLevel.useTF[3]=_HTF3;
   tfDataLevel.useTF[4]=_HTF4;
// set the display of the levels true or false;
   if(_isSingleSymbol)
      tfDataLevel.initLevels(_showLevels);
   else
      tfDataLevel.initLevels(false);
   tfDataLevel.tfColor[0]=findColor(_HTF0);
   tfDataLevel.tfColor[1]=findColor(_HTF1);
   tfDataLevel.tfColor[2]=findColor(_HTF2);
   tfDataLevel.tfColor[3]=findColor(_HTF3);
   tfDataLevel.tfColor[4]=findColor(_HTF4);

   ArrayResize(tfDataLevel.useTF, _numHTFs);
   ArrayResize(tfDataLevel.tfColor, _numHTFs);
   return true;
  }
// +------------------------------------------------------------------+
// | createVolumeTFs                                                  |
// +------------------------------------------------------------------+
bool              BarFlow::createVolumeTFs(
   bool _isSingleSymbol,
   int _numHTFs,
   ENUM_TIMEFRAMES _HTF0,
   ENUM_TIMEFRAMES _HTF1,
   ENUM_TIMEFRAMES _HTF2,
   ENUM_TIMEFRAMES _HTF3,
   ENUM_TIMEFRAMES _HTF4,
   bool _showVolumes)
  {
   if((_numHTFs <= 0) && (CheckPointer(tfDataVolume)  != POINTER_INVALID))
     {
      delete(tfDataVolume);
      return false;
     }
//set up and initialise Volume indicators array
//  ArrayResize(hideVolumeIndicatorArray,1);
   tfDataVolume = new TFVolumeDataObj();
//currently 1 per tf namely atr
   tfDataVolume.numberWindows = 1 * _numHTFs;
   ArrayResize(tfDataVolume.useTF, 5);
   ArrayResize(tfDataVolume.tfColor,5);
// create array of tfs and colors for Volume
   tfDataVolume.chartTF=_Period;
   tfDataVolume.useTF[0]=_HTF0;
// tfDataVolume.zeroIndex=0;
   tfDataVolume.useTF[1]=_HTF1;
//tfDataVolume.trendIndex2=0;
   tfDataVolume.useTF[2]=_HTF2;
   tfDataVolume.useTF[3]=_HTF3;
   tfDataVolume.useTF[4]=_HTF4;
// set the display of the levels true or false;
   if(_isSingleSymbol)
      tfDataVolume.initVolumes(_showVolumes);
   else
      tfDataVolume.initVolumes(false);
   tfDataVolume.tfColor[0]=findColor(_HTF0);
   tfDataVolume.tfColor[1]=findColor(_HTF1);
   tfDataVolume.tfColor[2]=findColor(_HTF2);
   tfDataVolume.tfColor[3]=findColor(_HTF3);
   tfDataVolume.tfColor[4]=findColor(_HTF4);
   tfDataVolume.showATR[0] = true;
   tfDataVolume.showATR[1] = true;
   tfDataVolume.showATR[2] = false;
   tfDataVolume.showATR[3] = false;
   tfDataVolume.showATR[4] = false;
   ArrayResize(tfDataVolume.useTF, _numHTFs);
   ArrayResize(tfDataVolume.tfColor, _numHTFs);
   return true;
  }
// +------------------------------------------------------------------+
// | createDataObject                                                 |
// +------------------------------------------------------------------+
bool              BarFlow::createAllTFs()
  {
//  have to have a trend to cycle the system in runNewBarInstruments
   if((CheckPointer(tfDataLevel) == POINTER_INVALID) && (CheckPointer(tfDataTrend) == POINTER_INVALID))
      return false;
   tfDataAll = new TFAllDataObj();
// Add tip TFs
   if(CheckPointer(tfDataTrend)!=POINTER_INVALID)
     {
      for(int i = 0; i < ArraySize(tfDataTrend.useTF); i++)
        {
         ArrayResize(tfDataAll.useTF,ArraySize(tfDataAll.useTF)+1);
         tfDataAll.useTF[i]=tfDataTrend.useTF[i];
        }
     }
//  Add Level TFs
   if(CheckPointer(tfDataLevel)!=POINTER_INVALID)
     {
      for(int i = 0; i < ArraySize(tfDataLevel.useTF); i++)
        {
         if(!tfDataAll.alreadyInArray(tfDataLevel.useTF[i]))
           {
            //doesnt already contain it so add it
            ArrayResize(tfDataAll.useTF,ArraySize(tfDataAll.useTF)+1);
            tfDataAll.useTF[ArraySize(tfDataAll.useTF)-1]=tfDataLevel.useTF[i];
           }
        }
     }
//  Add Volume TFs
   if(CheckPointer(tfDataVolume)!=POINTER_INVALID)
     {
      for(int i = 0; i < ArraySize(tfDataVolume.useTF); i++)
        {
         if(!tfDataAll.alreadyInArray(tfDataVolume.useTF[i]))
           {
            //doesnt already contain it so add it
            ArrayResize(tfDataAll.useTF,ArraySize(tfDataAll.useTF)+1);
            tfDataAll.useTF[ArraySize(tfDataAll.useTF)-1]=tfDataVolume.useTF[i];
           }
        }
     }
//  tfDataLevel.ToLog("Level: ",true);
   tfDataTrend.ToLog("Trend: ",true);
   tfDataAll.ToLog("tfDataAll: ",true);
   if(ArraySize(tfDataAll.useTF)<=0)
      return false;
   return true;
  }
// +------------------------------------------------------------------+
// |    // create color object - 22 colors to match Tfs               |
// +------------------------------------------------------------------+
void              BarFlow::createColors()
  {
   colorsTF=new ColorsTF();
  }
// +------------------------------------------------------------------+
// | BarFlow: findColor                                               |
// +------------------------------------------------------------------+
color BarFlow::findColor(ENUM_TIMEFRAMES _tf)
  {
   return this.colorsTF.findColors(_tf);
  }
///////////////////////////////////////////////////// * MONITOR FLOW ** /////////////////////////////////////////////////////////////
////+------------------------------------------------------------------+
////| setChartBars                                                     |
////+------------------------------------------------------------------+
//bool              BarFlow::setChartInsBars(int _ins, int _reqBars)
//  {
////hold the current instrument against this
////   this.ins=_ins;
//   int numRates = CopyRates(instrumentPointers[_ins].symbol,_Period,0,_reqBars,ratesChartBars);
//   if(numRates < _reqBars)
//      return false;
//   ArraySetAsSeries(ratesChartBars,true);
//   return true;
//  }
//
////+------------------------------------------------------------------+
////| Check if _Period bar crosses an important level on All level HTF |
////| receives a instrument/Chart bar                                  |
////+------------------------------------------------------------------+
//bool  BarFlow::monitorLevelX(int _ins)
//  {
////   delete temporary using lipe from array holder but dont delete pointer
//   ArrayRemove(currLipe,0,WHOLE_ARRAY);
//   ArrayResize(currLipe,3);
//// **** Can speed checking of this by pointer reference back to isMinimaFlag bars in a queue **
//   if(instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()> 0)
//     {
//      for(int cntLipe=0; (cntLipe < instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()); cntLipe++)
//        {
//         LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//         if(CheckPointer(lipe)!=POINTER_INVALID)
//           {
//            //  check its a minima level and its  straddled by the candle
//            if(lipe.isMinimaFlag && (lipe.levelPrice <= ratesChartBars[1].high) && (lipe.levelPrice >= ratesChartBars[1].low))
//              {
//               //  set curr[0]
//               findLowerLevel(_ins, cntLipe);
//               currLipe[1] = lipe;
//               // set curr[2]
//               findHigherLevel(_ins, cntLipe);
//               return true;
//              }
//           }
//        }
//     }
//
//   return false;
//  }
////+------------------------------------------------------------------+
////| find a lower value level if it exists                            |
////+------------------------------------------------------------------+
//void  BarFlow::findLowerLevel(int _ins, int _start)
//  {
//   for(int cntLipe =_start; (cntLipe >= 0); cntLipe--)
//     {
//      LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//      if(CheckPointer(lipe)!=POINTER_INVALID)
//        {
//         if(lipe.isMinimaFlag && (lipe.levelPrice < ratesChartBars[1].low))
//           {
//            currLipe[0] = lipe;
//            return;
//           }
//        }
//     }
//  }
////+------------------------------------------------------------------+
////| find a higher value level if it exists                           |
////+------------------------------------------------------------------+
//void  BarFlow::findHigherLevel(int _ins, int _start)
//  {
//   for(int cntLipe =_start; (cntLipe < instrumentPointers[_ins].pContainerLip.pSumLipElements.Total()); cntLipe++)
//     {
//      LipElement *lipe = instrumentPointers[_ins].pContainerLip.pSumLipElements[cntLipe];
//      if(CheckPointer(lipe)!=POINTER_INVALID)
//        {
//         if(lipe.isMinimaFlag && (lipe.levelPrice > ratesChartBars[1].high))
//           {
//            currLipe[2]= lipe;
//            return;
//           }
//        }
//     }
//  }
////+------------------------------------------------------------------+
////| Establish found level has room to the left                       |
////| ALGO: Currently Operates on Chart TF for any level found         |
////+------------------------------------------------------------------+
//rttl       BarFlow:: monitorRoomLeft(int _ins, int _count, int _start)
//  {
//   int lowest = iLowest(instrumentPointers[_ins].symbol,_Period,MODE_LOW,_count,_start);
//   int highest =iHighest(instrumentPointers[_ins].symbol,_Period,MODE_HIGH,_count,_start);
////int digits = int(SymbolInfoInteger(instrumentPointers[_ins].symbol,SYMBOL_DIGITS));
////   double points = double(SymbolInfoDouble(instrumentPointers[_ins].symbol,SYMBOL_POINT));
//   if(lowest ==1)
//     {
//      double diffPoints = (ratesChartBars[highest].low-ratesChartBars[lowest].low)/instrumentPointers[_ins].Point();
//      //  have a low at position candle (1) -> where and what is the low of the highest point ?
//      ATRInfo *atr = NULL;
//      if(instrumentPointers[_ins].pContainerIndicator.Total()>0)
//        {
//         for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerIndicator.Total()); instrumentTrend++)
//           {
//            atr = instrumentPointers[_ins].pContainerIndicator.GetNodeAtIndex(instrumentTrend);
//            if(atr.waveHTFPeriod == _Period)
//              {
//               int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
//               //check if price difference is > (x) ATR;s of the Chart
//               double atrInPoints    =  atr.atrWrapper.atrValue[0] * MathPow(10,instrumentPointers[_ins].Digits());
//               if(diffPoints > (atrInPoints * atr.scaleATR))
//                  return rttlLow;
//               else
//                  break;
//              }
//           }
//         //   Print("LOW -> Room to left, belongs to: ", EnumToString(currLipe[0].waveHTFPeriod)," Level Price:  ",currLipe[0].levelPrice," lowest: ",ratesChartBars[1].high, " date: ", ratesChartBars[1].time);
//        }
//     }
//   else
//      if(highest == 1)
//        {
//         double diffPoints = (ratesChartBars[highest].high-ratesChartBars[lowest].high)/instrumentPointers[_ins].Point();
//         ATRInfo *atr = NULL;
//         if(instrumentPointers[_ins].pContainerIndicator.Total()>0)
//           {
//            for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerIndicator.Total()); instrumentTrend++)
//              {
//               atr = instrumentPointers[_ins].pContainerIndicator.GetNodeAtIndex(instrumentTrend);
//               if(atr.waveHTFPeriod == _Period)
//                 {
//                  int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
//                  double atrInPoints    =  atr.atrWrapper.atrValue[0] * MathPow(10,instrumentPointers[_ins].Digits());
//                  if(diffPoints > (atrInPoints * atr.scaleATR))
//                     return rttlHigh;
//                  else
//                     break;
//                 }
//              }
//           }
//         //   Print("HIGH -> Room to left, belongs to: ", EnumToString(currLipe[0].waveHTFPeriod)," Level Price:  ",currLipe[0].levelPrice," highest: ",ratesChartBars[1].high, " date: ", ratesChartBars[1].time);
//        }
//   return rttlNone;
//  }
///////////////////////////////////////////////////// * Trade Ops ** /////////////////////////////////////////////////////////////
//// +------------------------------------------------------------------+
//// | openBuyStopOrder                                                 |
//// +------------------------------------------------------------------+
//bool BarFlow::openBuyStopOrder(int _ins,double prevBidHigh, double _vol, double _sl, double _tp, datetime _expiration)
//  {
////  string sIns=instrumentPointers[_ins].symbol;
//   CSymbolInfo myIns=instrumentPointers[_ins].mySymbol;
//   string insName=myIns.Name();
//   int sprd=myIns.Spread();
//   double bprice = prevBidHigh + (myTrade.deltaFireRoom * myIns.Point()) + (sprd*myIns.Point());
//   double mprice= NormalizeDouble(bprice,myIns.Digits());
////  double stloss = NormalizeDouble((mprice - (_sl)), myIns.Digits()); // --- Stop Loss
////  double tprofit = NormalizeDouble((mprice + (_tp)), myIns.Digits()); // --- Take Profit
//   double stloss = NormalizeDouble(_sl, myIns.Digits()); // --- Stop Loss
//   double tprofit = NormalizeDouble(_tp, myIns.Digits()); // --- Take Profit
//   string comment=StringFormat("Buy Stop %s %G lots at %s, SL=%s TP=%s",
//                               myIns.Name(),_vol,
//                               DoubleToString(mprice, myIns.Digits()),
//                               DoubleToString(stloss, myIns.Digits()),
//                               DoubleToString(tprofit, myIns.Digits()));
////// --- open BuyStop order
////  if(myTrade.BuyStop(volLot, mprice, insName, stloss, tprofit))
//   if(myTrade.OrderOpen(myIns.Name(),ORDER_TYPE_BUY_STOP,_vol,0.0,bprice,stloss,tprofit,ORDER_TIME_SPECIFIED,_expiration,comment))
//     {
//      // --- Request is completed or order placed
//      Alert("A BuyStop order has been successfully placed with Ticket#:",myTrade.ResultOrder(),"!!");
//      instrumentPointers[_ins].pContainerLip.pSumLipElements.ToLog(__FUNCTION__, true);
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
//// | openSellStopOrder                                                |
//// +------------------------------------------------------------------+
//bool BarFlow::openSellStopOrder(int _ins,double prevBidLow, double _vol, double _sl, double _tp, datetime _expiration)
//  {
////string sIns=instrumentPointers[_ins].symbol;
//   CSymbolInfo myIns=instrumentPointers[_ins].mySymbol;
//   string insName=myIns.Name();
//   double sprice=prevBidLow - myTrade.deltaFireRoom * myIns.Point();
//   double mprice=NormalizeDouble(sprice, myIns.Digits());               // --- Sell price
////   double stloss=NormalizeDouble(mprice+_sl*_atrValue,myIns.Digits());   // --- Stop Loss
////   double tprofit=NormalizeDouble(mprice-_tp*_atrValue,myIns.Digits()); // --- Take Profit
//   double stloss = NormalizeDouble(_sl, myIns.Digits()); // --- Stop Loss
//   double tprofit = NormalizeDouble(_tp, myIns.Digits()); // --- Take Profit
//   string comment=StringFormat("Sell Stop %s %G lots at %s, SL=%s TP=%s",
//                               myIns.Name(),_vol,
//                               DoubleToString(mprice,myIns.Digits()),
//                               DoubleToString(stloss,myIns.Digits()),
//                               DoubleToString(tprofit,myIns.Digits()));
//// --- Open SellStop Order
//   if(myTrade.OrderOpen(myIns.Name(),ORDER_TYPE_SELL_STOP,_vol,0.0,sprice,stloss,tprofit,ORDER_TIME_SPECIFIED,_expiration,comment))
//     {
//      // Request is completed or order placed
//      Alert("A SellStop order has been successfully placed with Ticket#:",myTrade.ResultOrder(),"!!");
//      instrumentPointers[_ins].pContainerLip.pSumLipElements.ToLog(__FUNCTION__, true);
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
////+------------------------------------------------------------------+
////| Getting lot size for open long position.                         |
////+------------------------------------------------------------------+
//double BarFlow::CheckOpenLong(int _ins, double _price,double _sl)
//  {
//   if(instrumentPointers[_ins].Name()==NULL)
//      return(0.0);
//   double allowedLots=0, lots=0,  idealLots=0, marginPerLot=0, lossPerLot=0, stepVol=0;
//   double minvol=instrumentPointers[_ins].LotsMin();
//   if(_sl==0.0)
//      lots=0.0;
//   else
//     {
//      double usedMargin              =  myAccount.Margin();
//      // max margin per commodity allowed is 15% of equity
//      double allowedMarginPerCommodity    =  myAccount.Balance()*0.15;
//      // max total margin allowed is 60% of equity
//      double availableToThisCommodity     = (myAccount.Balance() * 0.6) - usedMargin;
//      // double maxLossPerCommodity       =  AccountInfoDouble(ACCOUNT_EQUITY)*0.10;
//      if(_price==0.0)
//         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY,1.0,instrumentPointers[_ins].Ask(),_sl);
//      else
//         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_BUY,1.0,_price,_sl);
//      stepVol=instrumentPointers[_ins].LotsStep();
//      double allowedRisk = myAccount.Balance()*riskPerTrade/100.0;
//      // calculate ideal sought lots without margin constraints
//      idealLots = MathFloor((allowedRisk/lossPerLot)/stepVol)*stepVol;
//      ResetLastError();
//      if(OrderCalcMargin(ORDER_TYPE_BUY,instrumentPointers[_ins].Name(),1,_price,marginPerLot))
//        {
//         // check allowed margin
//         allowedLots = MathMin(allowedMarginPerCommodity,availableToThisCommodity)/marginPerLot;
//         allowedLots = MathFloor(allowedLots/stepVol)*stepVol;
//         // check allowed margin with ideal sought lots
//         lots = MathMin(idealLots,allowedLots);
//        }
//      else
//        {
//         Print(__FUNCTION__," Failed to get (1) lot margin required @ price: ",_price," ", ErrorDescription(GetLastError()));
//         lots = 0;
//         return lots;
//        }
//     }
//   if(lots<minvol)
//     {
//      lots=0;
//      return lots;
//     }
//   double maxvol=instrumentPointers[_ins].LotsMax();
//   if(lots>maxvol)
//     {
//      lots=maxvol;
//      return lots;
//     }
//   return lots;
//  }
////+------------------------------------------------------------------+
////| Getting lot size for open short position.                        |
////+------------------------------------------------------------------+
//double BarFlow::CheckOpenShort(int _ins, double _price,double _sl)
//  {
//   if(instrumentPointers[_ins].Name()==NULL)
//      return(0.0);
//   double allowedLots=0, lots=0,  idealLots=0, marginPerLot=0, lossPerLot=0, stepVol=0;
//   double minvol=instrumentPointers[_ins].LotsMin();
//   if(_sl==0.0)
//      lots=0.0;
//   else
//     {
//      double usedMargin              =  myAccount.Margin();
//      // max margin per commodity allowed is 15% of equity
//      double allowedMarginPerCommodity    =  myAccount.Balance()*0.15;
//      // max total margin allowed is 60% of equity
//      double availableToThisCommodity     = (myAccount.Balance() * 0.6) - usedMargin;
//      // double maxLossPerCommodity       =  AccountInfoDouble(ACCOUNT_EQUITY)*0.10;
//      if(_price==0.0)
//         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_SELL,1.0,instrumentPointers[_ins].Bid(),_sl);
//      else
//         lossPerLot=-myAccount.OrderProfitCheck(instrumentPointers[_ins].Name(),ORDER_TYPE_SELL,1.0,_price,_sl);
//      stepVol=instrumentPointers[_ins].LotsStep();
//      double allowedRisk = myAccount.Balance()*riskPerTrade/100.0;
//      // calculate ideal sought lots without margin constraints
//      idealLots = MathFloor((allowedRisk/lossPerLot)/stepVol)*stepVol;
//      ResetLastError();
//      if(OrderCalcMargin(ORDER_TYPE_BUY,instrumentPointers[_ins].Name(),1,_price,marginPerLot))
//        {
//         // check allowed margin
//         allowedLots = MathMin(allowedMarginPerCommodity,availableToThisCommodity)/marginPerLot;
//         allowedLots = MathFloor(allowedLots/stepVol)*stepVol;
//         // check allowed margin with ideal sought lots
//         lots = MathMin(idealLots,allowedLots);
//        }
//      else
//        {
//         Print(__FUNCTION__," Failed to get (1) lot margin required @ price: ",_price," ", ErrorDescription(GetLastError()));
//         lots = 0;
//         return lots;
//        }
//     }
//   if(lots<minvol)
//     {
//      lots=0;
//      return lots;
//     }
//   double maxvol=instrumentPointers[_ins].LotsMax();
//   if(lots>maxvol)
//     {
//      lots=maxvol;
//      return lots;
//     }
//   return lots;
//  }
////+------------------------------------------------------------------+
////| Getting lot size for open short position.                        |
////+------------------------------------------------------------------+
//bool              BarFlow::checkMoveStop(int _ins, ENUM_POSITION_TYPE _posType)
//  {
//   if(!isEngulfing())
//      return false;
//   if(_posType == POSITION_TYPE_BUY)
//     {
//      //  move stop
//     }
//   else
//      if(_posType == POSITION_TYPE_SELL)
//        {
//         //  move stop
//        }
//   return true;
//  }
////+------------------------------------------------------------------+
////| Establish is engulfing pattern                                   |
////+------------------------------------------------------------------+
//bool       BarFlow::isEngulfing()
//  {
//   double o = this.ratesChartBars[1].open;
//   double c = this.ratesChartBars[1].close;
//   double h = this.ratesChartBars[1].high;
//   double l = this.ratesChartBars[1].low;
//   if((h >= this.ratesChartBars[2].high) && (l <= this.ratesChartBars[2].low))
//      return true;
//   return false;
//  }
// ** LUCKY BAG ** //


//// check wave volume anomalies long
//bool              BarFlow::checkSetUpLong(int _ins, int _index,int &_candleXPos, double &_level);
//// check wave volume anomalies short
//bool              BarFlow::checkSetUpShort(int _ins, int _index,int &_candleXPos, double &_level);
//// Initialise all indicaotrs have data
//bool              BarFlow::initIndicators();
// check all trend from index (second) and higher are buy
//   trendState        BarFlow::isValidBuyTrend(int _ins, int index);
// check HTF Trend is down/Up
//   bool              BarFlow::isBuyWave(int _ins,int _index);
// is buy wave down wave
//   bool              BarFlow::isBuyWaveDown(int _ins,int _index);
// level pentrated down
//   bool              BarFlow::thrustDownThroughSupport(Tip *_tip,LipElement *_tile);
//   bool              BarFlow::reXupThroughSupport(int candlePos, Tip *_tip, LipElement *_tile);
//level penetrated up
//   bool              BarFlow::thrustUpThroughResistance(int _ins, Tip *_tip);
//   bool              BarFlow::reXDownThroughResistance(int _candlePos, Tip *_tip,LipElement *_tile);
// check for spring in a buy situation
//   bool              BarFlow::checkSpring(int _ins, int _index);
// check wave volume anomalies long
//   bool              BarFlow::checkVolumeLong(Tip *_tip);
// check wave volume anomalies short
//   bool              BarFlow::checkVolumeShort(Tip *_tip);
// check HTF Trend is up/down
//   bool              BarFlow::isSellWave(int _ins,int _index);
// is sell wave up wave
//   bool              BarFlow::isSellWaveUp(int _ins,int _index);
// check possible open sell Limit order by checking condition on control (trigger) wave
// check for upThrust in a sell situation
// check its an up leg
//  trendState        BarFlow::isTrendsSellHTFsHigh(int _ins, int _index);
// check all trend from index (second) and higher are sell
//   trendState        BarFlow::isValidSellTrend(int _ins, int index);
// close on rsi first bounds
//  void              BarFlow::closeRSI(int _ins, int trendIndex1);
//cancel any Trade Open positions where trend no longer exists
//  void              BarFlow::closeOneTradeOnTrendFailure(int _ins, int index);
// check for a spring on price action
//   bool              BarFlow::checkForSpring(int _ins, int _index,int _candleXPos,double _levelX);
// check for a upthrust on price action
//   bool              BarFlow::checkForUpthrust(int _ins, int _index,int _candleXPos,double _levelX);
// check its a down leg
//  trendState        BarFlow::isTrendsBuyHTFsLow(int _ins, int _index);




// +------------------------------------------------------------------+
// |initIndicators                                                    |
// +------------------------------------------------------------------+
//bool              BarFlow::initIndicators()
//  {
//   CSymbolInfo       myIns;
//// ensure data integrity before run
//   MqlRates          ratesHTF[];
//   int numRates =-1;
//// ** LOOP ALL SYSMBOLS SELECTED
//   int aSize=ArraySize(instrumentPointers)-1;
//   if(CheckPointer(tfDataAll)!=POINTER_INVALID)
//     {
//      for(int ins=0; ins<=aSize; ins++)
//        {
//         //for(int TF=0; TF<ArraySize(tfDataAll.useTF); TF++)
//         //  {
//         //   if((tfDataTrend.useTF[t]) && (tfDataTrend.chartTF<=tfDataTrend.useTF[t]))
//         //     {
//         myIns=instrumentPointers[ins].mySymbol;
//         if(myIns.Refresh())
//            continue;
//         else
//            return false;
//         //     }
//         //  }
//        }
//     }
//   return true;
//  }
//// +------------------------------------------------------------------+
//// | trySetup                                                         |
//// | check have first and second trend and                          |
//// | check cataylst for zero                                           |
//// +------------------------------------------------------------------+
//setupState  BarFlow::checkTrend(int _ins,int _index)
//  {
//// each Tip has own ATR value ... get the atr value for secondTFindex
//   Tip *tip;//,*zeroTip;//, *secontip;
//   Lip *pLevel=NULL;
//   if(CheckPointer(tfDataTrend)!=POINTER_INVALID)
//     {
//      //***  GETTING THE TIP TO THE Sub INDEX HERE ***
//      // zeroTip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(tfDataTrend.zeroIndex);
//      tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//      //  secontip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(tfDataTrend.trendIndex2);
//      if((CheckPointer(tip)!=NULL))//CheckPointer(zeroTip)!=NULL &&  &&(CheckPointer(secontip)!=NULL))
//        {
//         CSymbolInfo myIns=instrumentPointers[_ins].mySymbol;
//         string insName=myIns.Name();
//         if(CheckPointer(instrumentPointers[_ins])!=POINTER_INVALID)
//           {
//            // loop around S/R lines
//            double matchedLevel = -1;
//            bool isSpring = false;
//            bool isUpthrust = false;
//            for(int instrumentLevel=0; (instrumentLevel<instrumentPointers[_ins].pContainerLip.Total()); instrumentLevel++)
//              {
//               //     pLevel=instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(instrumentLevel);
//               // setupState crossLevelValue = pLevel.checkCatalyst(zeroTip,matchedLevel);
//               // check if meets spring criteria
//               //    if(crossLevelValue == setupSpring)
//               //     {
//               //  check meets second wave trending requirements for buying
//               if(isBuyWaveDown(_ins,_index))// &&
//                  //  (tip.checkDemandExtremum()==demand))
//                  return csuLong;
//               //     }
//               else
//                  //      if(crossLevelValue == setupUpthrust)
//                  //       {
//                  // check meets second selling requirements
//                  if(isSellWaveUp(_ins,_index))// &&
//
//                     //     (tip.checkSupplyExtremum()== supply))
//                     return csuShort;
//                  //        }
//                  else
//                     return noSetup;
//              }//
//           }//
//        }//
//     }//
//   return noSetup;
//  }
//// +------------------------------------------------------------------+
//// | isValidBuyTrend                                                  |
//// | Has valid and higher trends in tact                              |
//// +------------------------------------------------------------------+
//trendState  BarFlow::isValidBuyTrend(int _ins, int index)
//  {
//   trendState trendNow = isVoidTrend;
//   Tip *tip=NULL;
//   for(int instrumentTrend=index; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
//     {
//      tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
//      // get last leg for all tip's
//      if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//         (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID) &&
//         // cumulative trend is up on a down arm
//         (tip.currTip==up))
//         trendNow = up;
//      else
//        {
//         // dont have a trend that is on a down swing - no open trade
//         trendNow = isVoidTrend;
//         // if trend leg is not down for this TF, for this instrument(looped in expert main), then no set up
//         break;
//        }
//     }
//   return trendNow;
//  }
//// +------------------------------------------------------------------+
//// | isValidSellTrend                                                 |
//// | Has valid and higher trends in tact                              |
//// +------------------------------------------------------------------+
//trendState  BarFlow::isValidSellTrend(int _ins,int index)
//  {
//   trendState trendNow = isVoidTrend;
//   Tip *tip=NULL;
//   for(int instrumentTrend=index; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
//     {
//      tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
//      // get last leg for all tip's
//      if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//         (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID) &&
//         // cumulative trend is up on a down arm
//         (tip.currTip==down))
//         trendNow = down;
//      else
//        {
//         // dont have a trend that is on a down swing - no open trade
//         trendNow = isVoidTrend;
//         // if trend leg is not down for this TF, for this instrument(looped in expert main), then no set up
//         break;
//        }
//     }
//   return trendNow;
//  }
//// +------------------------------------------------------------------+
//// | checkBuyPrimaryWaveWave                                          |
//// | check second trend component has down leg - buying off a trough |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//bool  BarFlow::isBuyWaveDown(int _ins, int _index)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//// get last leg for all tip's
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//      (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      // second trend is down on a down arm, lower volume in wave and lower price
//      if(
//         // up trend
//         (tip.currTip==up) &&
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
//// +------------------------------------------------------------------+
//// | checkSellPrimaryWaveWave                                         |
//// | check second trend component has up leg - selling off a peak    |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//bool  BarFlow::isSellWaveUp(int _ins,int _index)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//// get last leg for all tip's
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//      (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      // cumulative trend is !down on a up arm, lower volume in wave and higher price
//      if(
//         // down trend
//         (tip.currTip==down) &&
//         // up leg
//         (tip.tipePntrs[3].arrowValue > tip.tipePntrs[2].arrowValue)
//         // volume penultimate less than volume earlier back end wave start
//         //(MathAbs(tip.tipePntrs[2].vol) > MathAbs(tip.tipePntrs[0].vol)) &&
//         // newest low < first low
//         //(tip.tipePntrs[3].tLineCurrPrevValues.rightValue < tip.tipePntrs[1].tLineCurrPrevValues.rightValue)
//      )
//         condition = true;
//     }
//   else
//      Print(__FUNCTION__," INVALID POINTER");
//   return condition;
//
//  }
//// +------------------------------------------------------------------+
//// | checkVolumeLong                                                  |
//// | iterate levels to check spring formed                            |
//// +------------------------------------------------------------------+
//bool  BarFlow::checkSetUpLong(int _ins, int _index,int &_candleXPos, double &_level)
//  {
//   bool condition = false;
//Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//for(int r = 1; (r<=6); r++)
//  {
//   Lip *lip = NULL;
//   LipElement *lipEle = NULL;
//   int tot = instrumentPointers[_ins].pContainerLip.Total();
//   for(int thisLip = 0; (thisLip < tot); thisLip++)
//     {
//      lip =  instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(thisLip);
//      for(int nLipEle = 0; (nLipEle < lip.Total()); nLipEle++)
//        {
//         if(CheckPointer(lip)!=NULL)
//           {
//            lipEle =  lip.GetNodeAtIndex(nLipEle);
//            if(CheckPointer(lipEle)!=NULL)
//              {
//               if((tip.ratesHTF[r].open > lipEle.levelPrice) && (tip.ratesHTF[r].low< lipEle.levelPrice))
//                 {
//                  if(lipEle.levelPrice < _level)
//                    {
//                     _candleXPos = r;
//                     _level = lipEle.levelPrice;
//                     condition = true;
//                    }
//                 }
//              }
//           }
//        }
//     }
//  }
// return condition;
//}
//// +------------------------------------------------------------------+
//// | checkForSpring                                                   |
//// | find a price spring?                                             |
//// +------------------------------------------------------------------+
//bool  BarFlow::checkForSpring(int _ins, int _index,int _candleXPos,double _levelX)
//  {
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//   Print("CHECK FOR SPRING TIME: ",tip.ratesHTF[1].time);
//   if(tip.ratesHTF[1].close > tip.ratesHTF[_candleXPos].high)
//      return true;
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkVolumeLong                                                  |
//// | iterate levels to check spring formed                            |
//// +------------------------------------------------------------------+
//bool  BarFlow::checkSetUpShort(int _ins, int _index,int &_candleXPos, double &_level)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//   for(int r = 1; (r<=6); r++)
//     {
//      //      Lip *lip = NULL;
//      //      LipElementPair *lipElePair = NULL;
//      //      int tot = instrumentPointers[_ins].pContainerLip.Total();
//      //      for(int thisLip = 0; (thisLip < tot); thisLip++)
//      //        {
//      //         lip =  instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(thisLip);
//      //         for(int nLipEle = 0; (nLipEle < lip.Total()); nLipEle++)
//      //           {
//      //            if(CheckPointer(lip)!=NULL)
//      //              {
//      //
//      //
//      //
//      //
//      //               lipElePair =  lip.GetNodeAtIndex(nLipEle);
//      //               if(CheckPointer(lipElePair)!=NULL)
//      //                 {
//      //                  if((tip.ratesHTF[r].open < lipElePair.resistance.level) && (tip.ratesHTF[r].high > lipElePair.resistance.level))
//      //                    {
//      //                     if(lipElePair.resistance.level < _level)
//      //                       {
//      //                        _candleXPos = r;
//      //                        _level = lipElePair.resistance.level;
//      //                        condition = true;
//      //                       }
//      //                    }
//      //                 }
//      //              }
//      //           }
//      //        }
//     }
//   return condition;
//  }
//// +------------------------------------------------------------------+
//// | checkForUpthrust                                                 |
//// | find a price upThrust?                                           |
//// +------------------------------------------------------------------+
//bool  BarFlow::checkForUpthrust(int _ins, int _index,int _candleXPos,double _levelX)
//  {
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//   if(tip.ratesHTF[1].close < tip.ratesHTF[_candleXPos].low)
//      return true;
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkVolumeLong                                                  |
//// | check volume is < previousVolume on                              |
//// +------------------------------------------------------------------+
//bool              BarFlow::checkVolumeLong(Tip *_tip)
//  {
////volume profile
//   if((_tip.tipePntrs[2].vol > (3*_tip.tipePntrs[1].vol)) &&
//      ((3*_tip.tipePntrs[3].vol) > _tip.tipePntrs[2].vol) &&
//
////   (tip.currTip==up)// &&
//// down leg
//      (_tip.tipePntrs[3].arrowValue < _tip.tipePntrs[2].arrowValue))
//      // lower low in spring
//      //      (_tip.tipePntrs[3].tLineCurrPrevValues.tLow < _tip.tipePntrs[1].tLineCurrPrevValues.tLow))
//      return true;
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkVolumeShort                                                 |
//// | check volume is < previousVolume on                            |
//// +------------------------------------------------------------------+
//bool              BarFlow::checkVolumeShort(Tip *_tip)
//  {
////volume profile
//   if((_tip.tipePntrs[2].vol > (3*_tip.tipePntrs[1].vol)) &&
//      ((3*_tip.tipePntrs[3].vol) > _tip.tipePntrs[2].vol) &&
//
////   (tip.currTip==up)// &&
//// up leg
//      (_tip.tipePntrs[3].arrowValue > _tip.tipePntrs[2].arrowValue))
//      // lower low in upthrust
//      //  (_tip.tipePntrs[3].tLineCurrPrevValues.tHigh > _tip.tipePntrs[1].tLineCurrPrevValues.tHigh))
//      return true;
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkSpring                                                      |
//// | iterate levels to check spring formed                           |
//// +------------------------------------------------------------------+
//bool              BarFlow::checkSpring(int _ins, int _index)
//  {
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//
//   Lip *lip = NULL;
//   LipElement *lipEle = NULL;
//   int tot = instrumentPointers[_ins].pContainerLip.Total();
//   for(int thisLip = 0; (thisLip < tot); thisLip++)
//     {
//      lip =  instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(thisLip);
//      for(int nLipEle = 0; (nLipEle < lip.Total()); nLipEle++)
//        {
//         if(CheckPointer(lip)!=NULL)
//           {
//            lipEle =  lip.GetNodeAtIndex(nLipEle);
//            if(CheckPointer(lipEle)!=NULL)
//              {
//               //if(lip.checkSpring(tip,lipEle) == setupSpring1)
//               //   return true;
//              }
//           }
//        }
//     }
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkUpThrust                                                    |
//// | iterate levels to check Up Thrust formed                         |
//// +------------------------------------------------------------------+
//bool              BarFlow::checkUpThrust(int _ins,int _index)
//  {
////   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
////
////   Lip *lip = NULL;
////   LipElement *lipEle = NULL;
////   int tot = instrumentPointers[_ins].pContainerLip.Total();
////   for(int thisLip = 0; (thisLip < tot); thisLip++)
////     {
////      lip =  instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(thisLip);
////      for(int nLipEle = 0; (nLipEle < lip.Total()); nLipEle++)
////        {
////         if(CheckPointer(lip)!=NULL)
////           {
////            lipEle =  lip.GetNodeAtIndex(nLipEle);
////            if(CheckPointer(lipEle)!=NULL)
////              {
////               if(lip.checkUpThrust(tip,lipEle) == setupUpthrust1)
////                  return true;
////              }
////           }
////        }
////     }
//   return false;
//  }
//// +------------------------------------------------------------------+
//// | checkBuyPrimaryWaveWave                                          |
//// | check second trend component has down leg - buying off a trough |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//bool  BarFlow::isBuyWave(int _ins, int _index)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//// get last leg for all tip's
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//      (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      // second trend is down on a down arm, lower volume in wave and lower price
//      if(
//         // up trend
//         (tip.currTip==up)// &&
//         // down leg
//         //   (tip.tipePntrs[3].arrowValue < tip.tipePntrs[2].arrowValue)
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
//// | checkSellPrimaryWaveWave                                         |
//// | check second trend component has up leg - selling off a peak    |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//bool  BarFlow::isSellWave(int _ins,int _index)
//  {
//   bool condition = false;
//   Tip *tip =  instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(_index);
//// get last leg for all tip's
//   if((CheckPointer(tip.tipePntrs[3])!= POINTER_INVALID) &&
//      (CheckPointer(tip.tipePntrs[2])!= POINTER_INVALID))
//     {
//      // cumulative trend is !down on a up arm, lower volume in wave and higher price
//      if(
//         // down trend
//         (tip.currTip==down)// &&
//         // up leg
//         //  (tip.tipePntrs[3].arrowValue > tip.tipePntrs[2].arrowValue)
//         // volume penultimate less than volume earlier back end wave start
//         //(MathAbs(tip.tipePntrs[2].vol) > MathAbs(tip.tipePntrs[0].vol)) &&
//         // newest low < first low
//         //(tip.tipePntrs[3].tLineCurrPrevValues.rightValue < tip.tipePntrs[1].tLineCurrPrevValues.rightValue)
//      )
//         condition = true;
//     }
//   else
//      Print(__FUNCTION__," INVALID POINTER");
//   return condition;
//  }
////+------------------------------------------------------------------+
////| checkBuyTriggerWave                                              |
////| need to consider freeze for rejection of condition true          |
////+------------------------------------------------------------------+
//bool  BarFlow::isBuyTriggerWave(int _ins, double _sl,double _tp, int index)
//  {
//   double atrValue = -1;
//   bool condition = false;
//   Tip *tip=NULL,*tipATR=NULL;
//   TipElement *tipeLast=NULL, *tipePenultimate=NULL;
//   double bollValue = -1;
//   tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
//   tipATR=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(tfDataTrend.trendIndex1);
//   atrValue     = tipATR.atrInfo.atrWrapper.atrValue[0];
//   if(atrValue==-1)
//     {
//      Alert(__FUNCTION__, " Data Problem Tip wave: ",tipATR.waveHTFPeriod);
//      return false;
//     }
////if(tip.volInfo.volWrapper.volValue[0]<tip.volInfo.volWrapper.lowerBound)
//   condition = openBuyOrder(_ins,  _sl, _tp, atrValue);
////else
////   condition = false;
//   return condition;
//  }
////+------------------------------------------------------------------+
////| isSellTriggerWave                                             |
////| need to consider freeze for rejection of condition true          |
////+------------------------------------------------------------------+
//bool  BarFlow::isSellTriggerWave(int _ins, double _sl,double _tp, int index)
//  {
//   double atrValue = -1;
//   bool condition = false;
//   Tip *tip=NULL,*tipATR=NULL;
//   TipElement *tipeLast=NULL, *tipePenultimate=NULL;
//   double bollValue = -1;
//   tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
//   tipATR=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(tfDataTrend.trendIndex1);
//   atrValue     = tipATR.atrInfo.atrWrapper.atrValue[0];
//   if(atrValue==-1)
//     {
//      Alert(__FUNCTION__, " Data Problem Tip wave: ",tipATR.waveHTFPeriod);
//      return false;
//     }
////if(tip.volInfo.volWrapper.volValue[0]>tip.volInfo.volWrapper.upperBound)
//   condition = openSellOrder(_ins,  _sl, _tp, atrValue);
////else
////   condition = false;
//   return condition;
//  }
//// +------------------------------------------------------------------+
//// | checkBuyTrendWave                                                |
//// | check all trend components have down leg - buying off a trough   |
//// | checks HTF does not include second                              |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//trendState  BarFlow::isTrendsBuyHTFsLow(int _ins, int _index)
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
//         if((instrumentTrend == tfDataTrend.trendIndex2+1) && (tip.currTip==up) && (tip.tipePntrs[3].arrowValue < tip.tipePntrs[2].arrowValue))
//           {
//            // check down log for second trend+1
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
//// +------------------------------------------------------------------+
//// | checkSellTrendWave                                               |
//// | check up leg on chart bar trend - selling off a peak             |
//// | checks HTF does not include second                              |
//// | need to consider freeze for rejection of condition true          |
//// +------------------------------------------------------------------+
//trendState  BarFlow::isTrendsSellHTFsHigh(int _ins, int _index)
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
//         if((instrumentTrend == tfDataTrend.trendIndex2+1) && (tip.currTip==down) && (tip.tipePntrs[3].arrowValue > tip.tipePntrs[2].arrowValue))
//           {
//            // check down log for second trend+1
//            trendNow = down;
//           }
//         else
//            if(tip.currTip==down)
//               trendNow = down;
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
// +------------------------------------------------------------------+
// |closeRSI first rSI < / > 80/20                                   |
// +------------------------------------------------------------------+
//void BarFlow::closeRSI(int _ins, int index)
//  {
//   bool condition = false;
//// get the first by symbol and magic
//   ulong ticket = findFirstPositon(instrumentPointers[_ins].Name());
//   if(ticket<=0)
//     {
//      Alert(__FUNCTION__," have trades open for instrument: ",instrumentPointers[_ins].Name(), " but cannot find it in positions table");
//      return;
//     }
//   Tip       *tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(index);
//   myPosition.SelectByTicket(ticket);
//   if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) && (tip.volInfo.volWrapper.volValue[0] >= tip.volInfo.volWrapper.upperBound))
//      condition = true;
//   else
//      if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) && (tip.volInfo.volWrapper.volValue[0] <= tip.volInfo.volWrapper.lowerBound))
//         condition = true;
//
//// no target reached
//   if(!condition)
//      return;
//   Print(__FUNCTION__," Attempting to close on RSI trades for: ",instrumentPointers[_ins].Name());
//// allow 10 deletion attempts before reporting a failure
//   int counter = 10;
//// target position is already selected above .Select first symbol by magic?
//   do
//     {
//      if(myTrade.PositionClose(ticket, dev))
//        {
//         Sleep(100);
//         return;
//        }
//      else
//         if(counter > 0)
//            counter -=1;
//         else
//           {
//            Alert(__FUNCTION__," Not closing out position: ",myTrade.PositionClose(instrumentPointers[_ins].Name()));
//            //  return cancel entry orders but failed to close open position
//            return;
//           }
//     }
//   while(counter > 0);
//  }
//// +------------------------------------------------------------------+
//// |closePositions if second trend or higher is gone                 |
//// |returns true if trade closed otherwise false trend intact up/down |
//// +------------------------------------------------------------------+
//void  BarFlow::closeOneTradeOnTrendFailure(int _ins, int index)
//  {
//   bool condition = false;
//   trendState tsBuy = isValidBuyTrend(_ins, index);
//   trendState tsSell = isValidSellTrend(_ins, index);
//// get the first by symbol and magic
//   ulong ticket = findFirstPositon(instrumentPointers[_ins].Name());
//   if(ticket<=0)
//     {
//      Alert(__FUNCTION__," have trades open for instrument: ",instrumentPointers[_ins].Name(), " but cannot find it in positions table");
//      return;
//     }
//   myPosition.SelectByTicket(ticket);
//   if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) && (tsBuy == up))
//      condition=true;
//   else
//      if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) && (tsSell == down))
//         condition=true;
//// no divergence in trend and trend rquired intact
//   if(condition)
//      return;
//   Print(__FUNCTION__," Attempting to close on Trend failure trades for: ",instrumentPointers[_ins].Name());
//// allow 10 deletion attempts before reporting a failure
//   int counter = 10;
//// target position is already selected above .Select first symbol by magic?
//   do
//     {
//      if(myTrade.PositionClose(ticket, dev))
//        {
//         Sleep(100);
//         return;
//        }
//      else
//         if(counter > 0)
//            counter -=1;
//         else
//           {
//            Alert(__FUNCTION__," Not closing out position: ",myTrade.PositionClose(instrumentPointers[_ins].Name()));
//            //  return cancel entry orders but failed to close open position
//            return;
//           }
//     }
//   while(counter > 0);
//  }
//// +------------------------------------------------------------------+
//// |checkExtremeTopBottom                                             |
//// |returns true if closed on extremum                                |
//// +------------------------------------------------------------------+
//bool              BarFlow::checkExtremeTopBottom(int _ins, trendState _ts, ulong _ticket)
//  {
//   bool condition = false;
//   Tip *tip;
//// ** CHECK FOR NEW TREND DATA FOR EACH ACTIVE PERIOD
//   for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
//     {
//      tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(instrumentTrend);
//      // Only call if its a new chart Bar for HTF under containeration
//      if(isNewHTF(tip))
//        {
//         double open=tip.ratesHTF[1].open, high=tip.ratesHTF[1].high,low=tip.ratesHTF[1].low, close=tip.ratesHTF[1].close;
//         myPosition.SelectByTicket(_ticket);
//         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
//           {
//            double test = (high -(high-low)/2);
//            if((open<=test) && (close<=test))
//              {
//               condition=true;
//               // close it have extremum on this TF for these ratesHTF
//               break;
//              }
//           }
//         else
//            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
//              {
//               double test = (high -(high-low)/2);
//               if((open>=test) && (close>=test))
//                 {
//                  condition=true;
//                  // close it have extremum on this TF for these ratesHTF
//                  break;
//                 }
//              }
//        }
//     }
//   if(!condition)
//      // Trend intact
//      return false;
//// No reason to be in trade trend is not with us Close the Positions
//   do
//     {
//      if(myTrade.PositionClose(instrumentPointers[_ins].Name(),dev))
//        {
//         Sleep(100);
//         return true;
//        }
//      else
//        {
//         Alert(__FUNCTION__," Not closing out position: ",myTrade.PositionClose(instrumentPointers[_ins].Name()));
//         //  return cancel entry orders but failed to close open position
//         return true;
//        }
//     }
//   while(countPositions(int(myTrade.RequestMagic()), instrumentPointers[_ins].Name()) > 0);
//   return condition;
//  }
// +------------------------------------------------------------------+
// | Expert initialization function                                   |
// +------------------------------------------------------------------+
//bool  BarFlow::isNewHTF(ADip  *_ad)
//  {
//   datetime tdaLower[];
//   CopyTime(_ad.symbol,_Period,0,1,tdaLower);
//   datetime tdaHigher[];
//   CopyTime(_ad.symbol,_ad.waveHTFPeriod,1,1,tdaHigher);
//   if(iBarShift(_Symbol,_ad.waveHTFPeriod,tdaLower[0],true)!=iBarShift(_Symbol,_ad.waveHTFPeriod,tdaHigher[0],true))
//      return true;
//   return false;
//  }
//// +------------------------------------------------------------------+
//// |  Confirms if margin is enough to open an order
//// +------------------------------------------------------------------+
//bool  BarFlow::confirmMargin(string _symbol,ENUM_ORDER_TYPE _otype,double _price,double _lot,double _tradePct)
//  {
//   bool confirm=false;
//   double lotPrice=myAccount.MarginCheck(_symbol,_otype,_lot,_price); // Lot price/ Margin
//   double accountFreeMargin=myAccount.FreeMargin();                        // Account free margin
//// Check if margin required is okay based on setting
//   if(MathFloor(accountFreeMargin*_tradePct)>MathFloor(lotPrice))
//     {
//      confirm=true;
//     }
//   else
//      DebugBreak();
//   return(confirm);
//  }
// +------------------------------------------------------------------+
// | BarFlow: destructor                                              |
// +------------------------------------------------------------------+
//void barFlowDestructor()
//  {
//   delete(tfDataLevel);
//   delete(tfDataTrend);
//   delete(tfDataAd);
//  }
// +------------------------------------------------------------------+
//// | checkBuyPrimaryWaveWave                                          |
//// | check second wave (1) has changed Direction to buy side         |
//// +------------------------------------------------------------------+
//trendState  BarFlow::checkBuyPrimaryWave(int _ins)
//  {
//   trendState trendNow = isVoidTrend;
//   Tip *tip=NULL;
//   PanelElement *peC=NULL, *peP=NULL, *pePP = NULL;
//   double atrValue = -1;
//   tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(tfDataTrend.trendIndex2);
//   peC   =  tip.cp.GetNodeAtIndex(tip.cp.Total()-1);
//   peP   =  tip.cp.GetNodeAtIndex(tip.cp.Total()-2);
//   pePP  =  tip.cp.GetNodeAtIndex(tip.cp.Total()-3);
//   if((CheckPointer(peC) != POINTER_INVALID) && (CheckPointer(peP) != POINTER_INVALID) && (CheckPointer(pePP) != POINTER_INVALID))
//     {
//      if((peC.tiphe.getTrendState() == up) && (peP.tiphe.getTrendState() == down))
//         trendNow = up;
//     }
//   else
//      Print(__FUNCTION__, " INVALID POINTER");
//   return trendNow;
//  }
//// +------------------------------------------------------------------+
//// | checkSellPrimaryWaveWave                                         |
//// | check second wave (1) has changed Direction to sell side        |
//// +------------------------------------------------------------------+
//trendState  BarFlow::checkSellPrimaryWave(int _ins)
//  {
//   trendState trendNow = isVoidTrend;
//   Tip *tip=NULL;
//   PanelElement *peC=NULL, *peP=NULL, *pePP = NULL;
//   double atrValue = -1;
////  for(int instrumentTrend=secondTF; (instrumentTrend<instrumentPointers[_ins].pContainerTip.Total()); instrumentTrend++)
////     {
//   tip=instrumentPointers[_ins].pContainerTip.GetNodeAtIndex(tfDataTrend.trendIndex2);
//   peC   =  tip.cp.GetNodeAtIndex(tip.cp.Total()-1);
//   peP   =  tip.cp.GetNodeAtIndex(tip.cp.Total()-2);
//   pePP  =  tip.cp.GetNodeAtIndex(tip.cp.Total()-3);
////    }
//   if((CheckPointer(peC) != POINTER_INVALID) && (CheckPointer(peP) != POINTER_INVALID) && (CheckPointer(pePP) != POINTER_INVALID))
//     {
//      if((peC.tiphe.getTrendState() == down) && (peP.tiphe.getTrendState() == up))
//         trendNow = down;
//     }
//   else
//      Print(__FUNCTION__, " INVALID POINTER");
//   return trendNow;
//  }
//+------------------------------------------------------------------+
