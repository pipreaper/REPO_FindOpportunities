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
   bool              createInstruments(string &_symbolsList[],int _atrLimitPeriod,ENUM_TIMEFRAMES _htfATR);
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
bool  BarFlow::createInstruments(string &_symbolsList[],int _atrLimitPeriod,ENUM_TIMEFRAMES _htfATR)
  {
   bool condition =false;
   ArrayResize(instrumentPointers,ArraySize(_symbolsList));
   for(int p=0; p<=ArraySize(_symbolsList)-1; p++)
     {
      Instrument *insPntr=new Instrument();
      if(GetPointer(insPntr)!=NULL)
        {
         instrumentPointers[p]=insPntr;
         insPntr.initInstrument(_symbolsList[p],_atrLimitPeriod, _htfATR);
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
//+------------------------------------------------------------------+
