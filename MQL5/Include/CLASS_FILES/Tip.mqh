//+------------------------------------------------------------------+
//|                                                          Tip.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#include    <Arrays\List.mqh>
#include    <\\INCLUDE_FILES\\WaveLibrary.mqh>
#include    <\\CLASS_FILES\\TFData.mqh>
#include    <\\CLASS_FILES\\TipElement.mqh>
#include    <\\CLASS_FILES\\ATRWaveInfo.mqh>
#include    <\\CLASS_FILES\\CCIWaveInfo.mqh>
#include    <\\CLASS_FILES\\EMAInfo.mqh>
#include    <\\CLASS_FILES\\ContainerTip.mqh>
#include    <\\INCLUDE_FILES\\drawing.mqh>
class TipElement;
// +------------------------------------------------------------------------+
// | Tip: Trend / Instrument / Period                                       |
// | TipElement   *tipePntrs[]; ->// Pointers to wave elements              |
// | ContainerPanel       *tiph;          -> PanelElement                   |
// | ContainerCongestion  *congestionQ;     ->CongestionElement             |
// +------------------------------------------------------------------------+
class Tip : public CList
  {
public:
   string            symbol;
   // store price values
   double            YVals[2];
   // store time values
   datetime          XTimes[2];
   // initialisation status of thisTip
   bool              initialisationCondition;
   int               countIndicatorPulls;
   bool              hasInitialised;
   // on screen trend display
   string            onScreenSymbol;
   string            onScreenDesc;
   string            onScreenWaveHeight;
   string            onScreenArrowLabel;
   uchar             arrowCode;
   int               fontSizeArrow;
   string            fontTypeArrow;
   int               fontSize;
   // number of elements defining a wave
   int               numDefineWave;
   // int               shift;
   int               startCTFShift;
   //  int               startHTFShift;
   static int        uniqueID;
   int               digits;
   double            tickValue;
   // NOT currently used = spare
   double            atrMultiplier;
   // flex atr for wave size 100 average
   double            scaleATR;
   double            cciTriggerLevel;
   double            cciExitLevel;
   int               cciAppliedPrice;
   int               cciPeriod;
   int               emaTrendPeriod;
   int               emaTrendShift;
   ENUM_MA_METHOD    emaTrendMethod;
   ENUM_APPLIED_PRICE emaTrendAppliedPrice;
   double            fracCandle;
   TFTrendDataObj    *tfDataTrend;
   int               t;
   bool              showTrendWave;
   // must be either trend data or volumes data
   //  showWaveLabels    showWaveArmLabels;
   bool              showCongestion;
   bool              showPanel;
   bool              hasCycled;
   color             clrLine;
   string            fontType;
   trendState        tipState;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   // both set in ratesFlow
   //chart tfs
   ContainerTip      *parent;
 //  MqlRates          parent.ratesCTF[];
   // start and stop dates compatible with all HTFs used
   MqlRates          ratesThisTF[];
   int               numratesThisTF;
   int               numRatesCTF;
   int               minBarsDegugRun;
   int               maxBarsDegugRun;
   ATRWaveInfo       *atrWaveInfo;
   CCIWaveInfo       *cciWaveInfo;
   EMAInfo           *emaInfo;
   waveCalcSizeType  wCalcSizeType;
   int               atrRange;
   int               maPeriod;
   int               maAppliedPrice;
   // Available for close price if needed
   int               htfShift;
   int               phtfShift;
   // wave volume
   long              cumVolume;
   // bar volume
   long              oCumVolume;
   TipElement        *tipePntrs[];
   //   ContainerCongestion *congestionQ;
   int               onScreenVarLimit;
   // offset for onScreen trend variables
   int               xInc;
   // Analyse the trend for init, congested, up, or down
   void              Tip::analyseTipState(int _shift);
   // Chart Bars are needed for evey Tip with a HTF on each
   bool              Tip::checkRateBarsAreSynced();
   //clearTrend() remove trend line element
   void              Tip::cleanTrend();
   // item last is most recent value create a new wave arm Up or Down
   void              Tip::cycleing(int _shift, TipElement *_tipe, trendElementState _tes);
   // temp debugger
   void              Tip::debugStates(int _ins, string _action,int _shift,int _count);
   // drawWave created waveLine
   bool              Tip::drawNewWaveLine(TipElement *_tipe);
   //  extend the wave UP/DOWN
   void              Tip::extending(int _shift, TipElement *_tipe, trendElementState _tes);
   // get value of current Tip
   trendState        Tip::getTipState();
   // find line style
   ENUM_LINE_STYLE   Tip::getLineStyle(trendState _trend);
   // get arrowStyle
   uchar             Tip::getArrowStyle(trendState _trend);
   void              Tip::setParent(ContainerTip *p);
   // check rates Bars are created
   bool              Tip::initTip(string _symbol,int _numDefineWave,int _chartPeriod,ENUM_TIMEFRAMES _waveHTFPeriod,color _clrLine,waveCalcSizeType _wCalcSizeType,int _atrRange,
                                  int _maPeriod,int _maAppliedPrice,int _minBars,int _maxBars,double _percentPullBack,double _atrMultiplier,double _scaleATR,
                                  double _cciTriggerLevel,double _cciExitLevel,int    _cciAppliedPrice,int    _cciPeriod,
                                  int _emaTrendPeriod,int _emaTrendShift,ENUM_MA_METHOD _emaTrendMethod,ENUM_APPLIED_PRICE _emaTrendAppliedPrice,
                                  double _fracCandle,TFTrendDataObj &_tfDataTrend,int _t,
                                  bool _showPanel,
                                  string _arrowMax,string _arrowMin,int _onScreenVarLimit);
   // initialise Indicators
   bool              Tip::addIndicators();
   // set new on screen symbol variable
   bool              Tip::initPanelScreenSymbol(int &_panelX,int _panelY);
   // create and display default values for all onscreen trend arrows
   bool              Tip::initPanelScreenVar(int &_panelX,int _panelY);
   // whats the current bar done to the status of the wave arm cycle extend nothing?
   void              Tip::interrogateWaveArm(int _shift);
   // Initialising history Bars OnInit()
   bool              Tip::processTrendBarInit(int _shift);
   // new chart Bar post processTrendBarInit
   void              Tip::processHTFTrendBar();
   // reduceNumTipElements:reduct the size of the held tipe elements - not required for calculations
   void              Tip::reduceNumTipElements(int acceptibleNumTip = 20);
   // establish up to date ratesThisTF array
   //  bool              Tip::runTimeTrendUpdate();
   // update trend line style to dash/dot or solid depending on congestion status
   void              Tip::updateTrendLineStyles();;
   // update the panel arrows with appropriate trend status
   void              Tip::updateArrowStyles();
   //  updateTrendPointers:  Set array of object Tip pointer, for ease of access, Order: highest array member is most recent pointer
   void              Tip::updateTrendPointers();
   // tipState = current value of this Tip's state
   void              Tip::setTipState(trendState _updateCurrTrend);
   // set a trend line flavour
   void              Tip::setTrendLineStyle(TipElement *_tipe,ENUM_LINE_STYLE _lineStyle);
   // last node to print is most current
   void              Tip::ToLog(string desc,bool show);
   // Destructor
   void              Tip::~Tip();
  };
// +------------------------------------------------------------------+
// |tipInit                                                           |
// +------------------------------------------------------------------+
bool              Tip::initTip(string _symbol,int _numDefineWave,int _chartPeriod,
                               ENUM_TIMEFRAMES _waveHTFPeriod,color _clrLine,
                               waveCalcSizeType _wCalcSizeType,int _atrRange,
                               int _maPeriod,int _maAppliedPrice,int _minBars,int _maxBars,double _percentPullBack,double _atrMultiplier,double _scaleATR,
                               double _cciTriggerLevel,double _cciExitLevel,int    _cciAppliedPrice,int    _cciPeriod,
                               int _emaTrendPeriod,int _emaTrendShift,ENUM_MA_METHOD _emaTrendMethod,ENUM_APPLIED_PRICE _emaTrendAppliedPrice,
                               double _fracCandle,TFTrendDataObj &_tfDataTrend,
                               int _t,
                               bool _showPanel,
                               string _arrowMax,string _arrowMin,int _onScreenVarLimit)
  {
   t=_t;
   countIndicatorPulls = 0;
   hasInitialised=false;
   showPanel = _showPanel;
   tfDataTrend = GetPointer(_tfDataTrend);
   cciTriggerLevel = _cciTriggerLevel;
   cciExitLevel =_cciExitLevel;
   cciAppliedPrice =_cciAppliedPrice;
   cciPeriod = _cciPeriod;
   emaTrendPeriod=_emaTrendPeriod;
   emaTrendShift=_emaTrendShift;
   emaTrendMethod=_emaTrendMethod;
   emaTrendAppliedPrice =_emaTrendAppliedPrice;
   clrLine = _clrLine;
// Need handles to ATR's for all trend using TF's
   wCalcSizeType  =  _wCalcSizeType;
   atrRange       =  _atrRange;
   maPeriod = _maPeriod;
   maAppliedPrice = _maAppliedPrice;
// PASSED
   symbol=_symbol;
   numDefineWave=_numDefineWave;
   onScreenVarLimit=_onScreenVarLimit;
   xInc=20;
   digits = int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE,tickValue);
   onScreenSymbol = symbol;
   showTrendWave=tfDataTrend.showTrendWave[t];
   onScreenDesc = StringSubstr(this.symbol,0,10)+"_"+IntegerToString(uniqueID)+"_"+EnumToString(waveHTFPeriod)+"_DescLabel";
   uniqueID+=1;
   onScreenWaveHeight=StringSubstr(this.symbol,0,10)+"_"+IntegerToString(uniqueID)+"_"+EnumToString(waveHTFPeriod)+"_WaveHeightLabel";
// set up trend arrows for panel
   uniqueID+=1;
   arrowCode=nullArrow;
   onScreenArrowLabel=StringSubstr(this.symbol,0,10)+"_"+IntegerToString(uniqueID)+"_"+EnumToString(waveHTFPeriod)+"_trendLabel";
   fontSizeArrow =10;
   fontTypeArrow="Wingdings";
   waveHTFPeriod=_waveHTFPeriod;
   scaleATR=_scaleATR;
   fracCandle =_fracCandle;
   minBarsDegugRun=_minBars;
   maxBarsDegugRun=_maxBars;
   cumVolume=0;
   oCumVolume=0;
// TREND
   ArrayResize(tipePntrs,numDefineWave);
   fontSize=8;
   fontType="Arial Bold";// "Times New Roman";// "Windings";
   htfShift=-1;
   phtfShift=-1;
// First pass set the state of this Tip
   setTipState(initialTipState);
//      // Most recent is at bottom of list position (n)
   uniqueID++;
   string name="waveLine"+string(uniqueID)+"_"+EnumToString(waveHTFPeriod);
   TipElement *tipe=new TipElement(name, this.clrLine);
   tipe.tipElementState=firstTipeTEState;
   this.Add(tipe);
   return true;
  }
//+------------------------------------------------------------------+
//|Get the container of this tip                                     |
//+------------------------------------------------------------------+
void Tip::setParent(ContainerTip *p)
  {
   parent = p;
  }
// +------------------------------------------------------------------+
// |Chart Bars are needed for evey Tip with a HTF on each             |
// |instrument/Tip                                                    |
// |Basically get the rates again that you could have                 |
// |passed in from barflow but you dont have a tip to do that         |
// +------------------------------------------------------------------+
bool Tip::checkRateBarsAreSynced()
  {
//   int maxBarsHTF = -1;
//   int maxBarsCTF=-1;
////Get Rates need access to inital ratesThisTF for this symbol TF retrieved successfully in BarFlow.setInitRatesSequence
//   if(!MQLInfoInteger(MQL_TESTER))
//     {
//      // attempt to override the past in params
//      maxBarsHTF = Bars(symbol,waveHTFPeriod);
//      maxBarsCTF = Bars(symbol,_Period);
//      numratesThisTF=CopyRates(symbol,waveHTFPeriod,0,maxBarsHTF,ratesThisTF);
//      numRatesCTF=CopyRates(symbol,_Period,0,maxBarsCTF,parent.parent.ratesCTF);
//     }
//   else
//     {
//      //***** Testing parmameters from ST fed to ratesThisTFArray *****
//      //Will Auto Download the History Data it needs to do a run
//      //According to the parameters you give it in CopyRates - dates or counts
//      maxBarsHTF = Bars(symbol,waveHTFPeriod);
//      maxBarsCTF = Bars(symbol,_Period);
//      numratesThisTF=CopyRates(symbol,waveHTFPeriod,0,maxBarsHTF,ratesThisTF);
//      numRatesCTF=CopyRates(symbol,_Period,0,maxBarsCTF,parent.ratesCTF);
//     }
// calculate start available for  HTF
// int periodSecondsTF=PeriodSeconds();
//  int periodSecondsHTF=PeriodSeconds(waveHTFPeriod);
//  int periodRatio=periodSecondsHTF/periodSecondsTF;
//  ArraySetAsSeries(parent.ratesCTF,true);
//  ArraySetAsSeries(ratesThisTF,true);
// CTF must start here to capture 1000 HTF bars -> 1000 Bars is considered enough to capture trend (if not fails to initialise)
//  startCTFShift = (periodRatio*maxBarsDegugRun) + 1;
// if we dont have a 1000 bars then whats the maximum
//  if((numRatesCTF-1) < startCTFShift)
//     startCTFShift = numRatesCTF-1;
//  CopyRates(symbol,_Period,0,startCTFShift,parent.ratesCTF);
// Calculate HTF rates Array
// get time of start CTF to satisfy HTF (calc above)
//  datetime startTimeCTF = parent.ratesCTF[startCTFShift-1].time;
// so find time HTF
//startHTFShift=iBarShift(symbol,waveHTFPeriod,startTimeCTF,true);
//CopyRates(symbol,waveHTFPeriod,0,startHTFShift,ratesThisTF);
// datetime startTimeHTF = ratesThisTF[startHTFShift-1].time;
   return true;
  }
// +------------------------------------------------------------------+
// |Destructor: Destroy Tip                                           |
// +------------------------------------------------------------------+
void Tip::~Tip()
  {
   if(CheckPointer(atrWaveInfo)!=POINTER_INVALID)
      delete(atrWaveInfo);
   if(CheckPointer(cciWaveInfo)!=POINTER_INVALID)
      delete(cciWaveInfo);
   if(CheckPointer(emaInfo)!=POINTER_INVALID)
      delete(emaInfo);
  }
// +------------------------------------------------------------------+
// |initIndicators                                                    |
// +------------------------------------------------------------------+
bool Tip::addIndicators(void)
  {
//initialise new clases of indicators -> each Tip has a copy
   atrWaveInfo  = new ATRWaveInfo(symbol,waveHTFPeriod,atrRange,TRD);
   atrWaveInfo.atrInit(scaleATR,this.showPanel);
//  cciWaveInfo  = new CCIWaveInfo(symbol,waveHTFPeriod,cciPeriod,cciAppliedPrice,"TRD");
//  cciWaveInfo.CCISetWaveInfo(cciTriggerLevel, cciExitLevel);
   emaInfo= new EMAInfo(symbol,waveHTFPeriod,emaTrendPeriod,emaTrendShift,emaTrendMethod,emaTrendAppliedPrice,"TRD");
//Keep doing init strategy(10) ... wait for indicator values on trend (ATR of atrWaveinfo) .... and others to be used later above?
//double atrArr[];
//if(CopyBuffer(atrWaveInfo.atrHandle,0,0,1,atrArr) <= 0)
//  {
//   Print(CopyBuffer(atrWaveInfo.atrHandle,0,0,1,atrArr));
//   return false;
//  }
//  else
//  Print("number of ATR elements: ",EnumToString(this.waveHTFPeriod)," : ",CopyBuffer(atrWaveInfo.atrHandle,0,0,1,atrArr));
   return true;
  }
// +------------------------------------------------------------------+
// | setTipState                                                      |
// +------------------------------------------------------------------+
void              Tip::setTipState(trendState _updateCurrTrend)
  {
// Print(__FUNCTION__,EnumToString(this.waveHTFPeriod)," time:  ",TimeCurrent()," state: ",EnumToString(_updateCurrTrend));
   tipState=_updateCurrTrend;
  }
// +------------------------------------------------------------------+
// | getTipState                                                      |
// +------------------------------------------------------------------+
trendState        Tip::getTipState()
  {
   return tipState;
  }
// +------------------------------------------------------------------+
// |updateTrendLineStyles                                             |
// +------------------------------------------------------------------+
void              Tip::updateTrendLineStyles()
  {
   if(!showTrendWave)
      return;
// update last three trend lines according to state
   for(int p = ArraySize(tipePntrs)-1; p>=1; p--)
      if(GetPointer(tipePntrs[p])!=NULL)
        {
         this.setTrendLineStyle(tipePntrs[p],getLineStyle(getTipState()));
         ObjectSetInteger(0,tipePntrs[p].waveLineName,OBJPROP_STYLE,tipePntrs[p].lineStyle);
        }
  }
// +-------------------------------------------------------------------------+
// | setTrendLineStyle                                                       |
// +-------------------------------------------------------------------------+
void              Tip::setTrendLineStyle(TipElement *_tipe,ENUM_LINE_STYLE _lineStyle)
  {
   _tipe.lineStyle = _lineStyle;
  }
// +------------------------------------------------------------------+
// | getLineStyle                                                     |
// +------------------------------------------------------------------+
ENUM_LINE_STYLE    Tip::getLineStyle(trendState _trend)
  {
   ENUM_LINE_STYLE ls;
   switch(_trend)
     {
      case congested:
         ls = STYLE_SOLID;
         break;
      case  up  :
         ls=STYLE_DASH;
         break;
      case down  :
         ls=STYLE_DOT;
         break;
      default  :
         ls=NULL;
     }
   return ls;
  }
// +------------------------------------------------------------------+
// | getArrowStyle                                                    |
// +------------------------------------------------------------------+
uchar Tip::getArrowStyle(trendState tState)
  {
   if(tState==up)
      return uArrow;
   else
      if(tState==down)
         return dArrow;
      else
         if(tState==congested)
            return cArrow;
         else
            return nullArrow;
  }
// +---------------------------------------------------------------------+
// |initProcessTrend()                                                   |
// |Initialising history Bars OnInit()                                   |
// +---------------------------------------------------------------------+
bool              Tip::processTrendBarInit(int _shift)
  {
   bool condition = false;
// Added in initTip
   TipElement *tipe =  this.GetLastNode();
   if(tipe.tipElementState == firstTipeTEState)
     {
      tipe.leftTime = parent.ratesCTF[_shift].time;
      tipe.rightTime=parent.ratesCTF[_shift].time;
      tipe.high =parent.ratesCTF[_shift].high;
      tipe.low =parent.ratesCTF[_shift].low;
      // nearest the close is left most point
      if(parent.ratesCTF[_shift].close > (parent.ratesCTF[_shift].low + (0.5*(parent.ratesCTF[_shift].high-parent.ratesCTF[_shift].low))))
        {
         tipe.leftPrice=tipe.low;
         tipe.rightPrice = tipe.high;
         tipe.tipElementState=upTEState;
        }
      else
        {
         tipe.leftPrice=tipe.high;
         tipe.rightPrice = tipe.low;
         tipe.tipElementState=downTEState;
        }
      tipe.vol=parent.ratesCTF[_shift].tick_volume;
      tipe.setElementParams();
      updateTrendPointers();
      drawNewWaveLine(tipe);
     }
   else
      interrogateWaveArm(_shift);
   analyseTipState(_shift);
   if(hasInitialised)
      condition = true;
   ChartRedraw();
// ArrayFree(ratesThisTF);
// ArrayFree(parent.ratesCTF);
   return condition;
  }
// +------------------------------------------------------------------+
// |outTipStates                                                      |
// +------------------------------------------------------------------+
void Tip::debugStates(int _ins, string _action,int _shift,int _count)
  {
   Print("shift: ",_shift);
// int htfShift = iBarShift(instrumentPointers[_ins].symbol,majorTrend.waveHTFPeriod,minorTrend.parent.ratesCTF[_shift].time,true);
   Print(_count," ",_action," ",__FUNCTION__," shift: ",_shift," **** ",parent.ratesCTF[_shift].time);
   Print(" ",symbol);
   Print(" XTimes[0] ",XTimes[0]," YVals[0] ",YVals[0]);
   Print(" XTimes[1] ",XTimes[1]," YVals[1] ",YVals[1]);
   Print(" TF:", EnumToString(waveHTFPeriod)," tipState: ",EnumToString(getTipState()));
  }
// +---------------------------------------------------------------------+
// |processTrendbar()                                                    |
// |new HTF Bar in OnTick()                                              |
// |set values for indicators                                            |
// +---------------------------------------------------------------------+
void              Tip::processHTFTrendBar()
  {
   CopyRates(symbol,waveHTFPeriod,0,101,ratesThisTF);
   ArraySetAsSeries(ratesThisTF,true);
   interrogateWaveArm(1);
   analyseTipState(1);
  }
// +---------------------------------------------------------------------+
// |interrogateWaveArm()                                                 |
// |takes the pessimistic apporoach that if a wave is possible in        |
// |both up and down directions congestion will win and be               |
// |set in analyse next pass                                             |
// +---------------------------------------------------------------------+
void              Tip::interrogateWaveArm(int _shift)
  {
   TipElement *tipe = this.GetLastNode();
   if(CheckPointer(tipe)!=POINTER_INVALID)
     {
      // are you cycling or extending
      double high = parent.ratesCTF[_shift].high;
      double low = parent.ratesCTF[_shift].low;
      bool canCycleUp   =  NormalizeDouble((high - tipe.low),atrWaveInfo.digits)>=(atrWaveInfo.waveHeightPts*atrWaveInfo.pointSize);
      bool canCycleDown =  NormalizeDouble((tipe.high - low),atrWaveInfo.digits)>=(atrWaveInfo.waveHeightPts*atrWaveInfo.pointSize);
      //  Print(__FUNCTION__," ",_shift, canCycleUp, " ",canCycleDown);
      //  Print(__FUNCTION__," ", waveHeight ",atrWaveInfo.waveHeightPts, " pointSize ",atrWaveInfo.waveHeightPts*atrWaveInfo.pointSize, " digits ",atrWaveInfo.digits);
      //   Print(__FUNCTION__," ", tipe.low ",tipe.low, " tipe.high ",tipe.high);
      if(canCycleUp && canCycleDown)
        {
         double upMove = high-tipe.rightPrice;
         double downMove = tipe.rightPrice-low;
         if((tipe.getTipElementState()==upTEState) &&(upMove>downMove))
           {
            extending(_shift,tipe,upTEState);
            //         Print(__FUNCTION__," 1 extending ",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
           }
         else
            if((tipe.getTipElementState()==downTEState) &&(downMove>upMove))
              {
               extending(_shift,tipe,downTEState);
               //         Print(__FUNCTION__," 2 extending ",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
              }
            else
               if((tipe.getTipElementState()==upTEState) &&(downMove>upMove))
                 {
                  cycleing(_shift,tipe,downTEState);
                  //          Print(__FUNCTION__," 3 cycle",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
                 }
               else
                  if((tipe.getTipElementState()==downTEState) &&(upMove>downMove))
                    {
                     cycleing(_shift,tipe,upTEState);
                     //           Print(__FUNCTION__," 4 cycle ",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
                    }
        }
      else
         if((high>tipe.high) &&
            (tipe.getTipElementState() == upTEState))
            // extend up
           {
            extending(_shift,tipe,upTEState);
            //       Print(__FUNCTION__," 5 extending",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
           }
         else
            if((low<tipe.low) &&
               (tipe.getTipElementState() == downTEState))
               // extendDown
              {
               extending(_shift,tipe,downTEState);
               //       Print(__FUNCTION__," 6 extending ",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
              }
            else
               if((high>tipe.low) &&
                  (tipe.getTipElementState() == downTEState)&&
                  (canCycleUp))
                  // cycleUp
                 {
                  cycleing(_shift,tipe,upTEState);
                  //           Print(__FUNCTION__," 7 cycleing ",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
                 }
               else
                  if((low<tipe.high) &&
                     (tipe.getTipElementState() == upTEState)&&
                     (canCycleDown))
                     // cycleDown
                    {
                     cycleing(_shift,tipe,downTEState);
                     //            Print(__FUNCTION__," 8 cycleing ",tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
                    }
      // volume zeroed in cycled but always cumulated from that zero or its value here
      tipe.vol+=parent.ratesCTF[_shift].tick_volume;
     }
  }
// +---------------------------------------------------------------------+
// |updateArrowStyles                                                    |
// +---------------------------------------------------------------------+
void Tip:: updateArrowStyles()
  {
   trendState ts = this.getTipState();
   if(!showPanel)
      return;
   LabelTextChange(ChartID(),this.onScreenArrowLabel,CharToString(this.getArrowStyle(this.getTipState())));
//Print(__FUNCTION__," isChangingLabel: ",this.getArrowStyle(this.getTipState()));
  }
// +---------------------------------------------------------------------+
// |analyseTipState                                                      |
// |set on new up legor down loeg only                                   |
// |If higher highs then up if lower lows then down else its congested   |
// +---------------------------------------------------------------------+
void              Tip::analyseTipState(int _shift)
  {
   if(!this.hasInitialised)
     {
      // Print(__FUNCTION__," 0 !hasInitialised ",EnumToString(this.waveHTFPeriod));
      setTipState(this.tipState);
     }
   else
      if(
         (this.getTipState() != up) &&
         (tipePntrs[3].rightPrice > tipePntrs[1].rightPrice) &&
         (tipePntrs[2].rightPrice > tipePntrs[0].rightPrice) &&
         (tipePntrs[3].rightPrice > tipePntrs[2].rightPrice))
        {
         this.setTipState(up);
         //     Print(__FUNCTION__," 1 up ",EnumToString(this.waveHTFPeriod));
        }
      else
         if(
            (this.getTipState() != down) &&
            (tipePntrs[3].rightPrice < tipePntrs[1].rightPrice) &&
            (tipePntrs[2].rightPrice < tipePntrs[0].rightPrice) &&
            (tipePntrs[3].rightPrice < tipePntrs[2].rightPrice))
           {
            this.setTipState(down);
            //      Print(__FUNCTION__," 2 down ",EnumToString(this.waveHTFPeriod));
           }
         else
            if((this.getTipState() == up)&&
               (tipePntrs[3].getTipElementState() == downTEState)&&
               ((parent.ratesCTF[_shift].low < tipePntrs[1].rightPrice)))
              {
               this.setTipState(congested);
               //       Print(__FUNCTION__," 3 congested",EnumToString(this.waveHTFPeriod));
              }
            else
               if((this.getTipState() == down)&&
                  (tipePntrs[3].getTipElementState() == upTEState)&&
                  ((parent.ratesCTF[_shift].high > tipePntrs[1].rightPrice)))
                 {
                  this.setTipState(congested);
                  //        Print(__FUNCTION__," 4 congested ",EnumToString(this.waveHTFPeriod));
                 }
   updateTrendLineStyles();
   updateArrowStyles();
  }
// +------------------------------------------------------------------+
// | extend                                                           |
// | extend the wave UP/DOWN                                          |
// +------------------------------------------------------------------+
void              Tip::extending(int _shift, TipElement *_tipe, trendElementState _tes)
  {
// extension so cumulate the volume
   _tipe.tipElementState=_tes;
   if(_tes == upTEState)
     {
      _tipe.high = parent.ratesCTF[_shift].high;
      _tipe.rightPrice=parent.ratesCTF[_shift].high;
      //   Print(__FUNCTION__," shift ",_shift," upTEState ",_tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
     }
   else
      if(_tes==downTEState)
        {
         _tipe.low =parent.ratesCTF[_shift].low;
         _tipe.rightPrice=parent.ratesCTF[_shift].low;
         //    Print(__FUNCTION__," shift ",_shift," downTEState ",_tipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
        }
   _tipe.rightTime=parent.ratesCTF[_shift].time;
   TrendPointChange(0,_tipe.waveLineName,1,_tipe.rightTime,_tipe.rightPrice);

   ChartRedraw();
  }
// +------------------------------------------------------------------+
// | cycle:item last is most recent value                             |
// | create a new wave arm Up or Down                                 |
// +------------------------------------------------------------------+
void              Tip::cycleing(int _shift, TipElement *_tipe, trendElementState _tes)
  {
// Manage the size of the nTipe queue - default 100 above
//reduceNumTipElements();
// new arm because cycle
   uniqueID++;
   string name="waveLine"+string(uniqueID)+"_"+EnumToString(waveHTFPeriod);
   TipElement *nTipe=new TipElement(name, this.clrLine);
   nTipe.tipElementState=_tes;
   nTipe.setElementParams();
// * new wave arm *
// cycle so zero the volume and start it with new bar
   nTipe.vol=0;

   if(_tes ==upTEState)
     {
      nTipe.rightPrice=parent.ratesCTF[_shift].high;
      nTipe.rightTime=parent.ratesCTF[_shift].time;
      nTipe.high = parent.ratesCTF[_shift].high;
      nTipe.low = _tipe.rightPrice;
      nTipe.leftPrice=_tipe.rightPrice;
      nTipe.leftTime=_tipe.rightTime;
      //   Print(__FUNCTION__," shift ",_shift," upTEState ",nTipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
     }
   else
      if(_tes==downTEState)
        {
         nTipe.rightPrice=parent.ratesCTF[_shift].low;
         nTipe.rightTime=parent.ratesCTF[_shift].time;
         nTipe.high = _tipe.rightPrice;
         nTipe.low = parent.ratesCTF[_shift].low;
         nTipe.leftPrice=_tipe.rightPrice;
         nTipe.leftTime=_tipe.rightTime;
         //   Print(__FUNCTION__," shift ",_shift," downTEState ",nTipe.rightPrice," tip wavHTF: ",EnumToString(this.waveHTFPeriod));
        }
   this.Add(nTipe);
// trend has a new element so update the pointer of trend elements array
   updateTrendPointers();
   uniqueID++;
// just update line style of tipElement to be drawn
   nTipe.lineStyle = getLineStyle(getTipState());
   drawNewWaveLine(nTipe);
   ChartRedraw();
  }
// +------------------------------------------------------------------+
// | reduceNumTipElements:reduct the size of the held                 |
// | tipe elements - not required for calculations                    |
// +------------------------------------------------------------------+
void             Tip:: reduceNumTipElements(int acceptibleNumTip = 20)
  {
   if(this.Total() >= acceptibleNumTip)
     {
      TipElement *tipe = this.GetFirstNode();
      // Check its not in use at the back of the Tip trend queue before removing
      if(CheckPointer(tipe)!=POINTER_INVALID)
        {
         tipe = this.DetachCurrent();
         ObjectDelete(0,tipe.waveLineName);
         delete(tipe);
        }
     }
  }
// +--------------------------------------------------------------------------------------+
// |runTrendTick()                                                                        |
// |1/. Its a new chart Bar for HTF under consideration                                   |
// |2/. establish up to date ratesThisTF array                                               |
// +--------------------------------------------------------------------------------------+
//bool             Tip::runTimeTrendUpdate()
//  {
////// make 30 rates available for all subsequent calculations on tip's
////   int xRates = 30;
////   ArrayResize(ratesThisTF,xRates);
////   int cnt=0;
////   do
////     {
////      cnt+=1;
////      if(cnt>30)
////        {
////         Print(__FUNCTION__," ",symbol," ",waveHTFPeriod," failed to get Rates");
////         return false;
////        }
////      Sleep(1);
////     }
////   while(CopyRates(symbol,waveHTFPeriod,0, xRates, ratesThisTF)!=xRates);
////   ArraySetAsSeries(ratesThisTF,true);// series same as indexes: 0 least recent
//   processTrendBar();
//   return true;
//  }
// +------------------------------------------------------------------+
// | setArrowCode                                                     |
// +------------------------------------------------------------------+
//uchar             Tip::setArrowCode(trendState _trend)
//  {
//   arrowCode=nullArrow;
//   switch(_trend)
//     {
//      case congested:
//         arrowCode = cArrow;
//         break;
//      case  up  :
//         arrowCode=uArrow;
//         break;
//      case down  :
//         arrowCode=dArrow;
//         break;
//      default  :
//         Alert(__FUNCTION__+" Failure");
//     }
//   return arrowCode;
//  }
// +------------------------------------------------------------------+
// | updateTrendPointers:  Set array of object Tip pointer |
// | for ease of access                                               |
// | Order: highest array member is most recent pointer               |                                                |
// +------------------------------------------------------------------+
void             Tip::updateTrendPointers()
  {
   int cnt=numDefineWave-1;
   for(int p=Total()-1; p>=Total()-(numDefineWave); p--)
     {
      TipElement *pntr=GetNodeAtIndex(p);
      if(GetPointer(pntr)!=NULL)
        {
         tipePntrs[cnt]=pntr;
         cnt--;
        }
     }
   if(Total() == numDefineWave)
     {
      this.hasInitialised = true;
      // Print(__FUNCTION__" ******** ",this.hasInitialised, " countInidicatorPulls ", this.countIndicatorPulls);

     }
  }
//// +------------------------------------------------------------------+
//// | caclTrendParams                                                  |
//// +------------------------------------------------------------------+
//void Tip::calcTrendParams(color _clr,int  _newestIndex,int _midIndex, int  _oldestIndex)
//  {
////   datetime dateArray[1];
////   int index = -1;
////// NEWEST:
////   datetime dNewest =tipePntrs[_newestIndex].tLineCurrPrevValues.extremeDate;
////   double pNewest = tipePntrs[_newestIndex].tLineCurrPrevValues.rightValue;
////// MIDWAY:
////   datetime dMidway =tipePntrs[_midIndex].tLineCurrPrevValues.extremeDate;
////   double pMidway = tipePntrs[_midIndex].tLineCurrPrevValues.rightValue;
////// OLDEST:
////   datetime dOldest =tipePntrs[_oldestIndex].tLineCurrPrevValues.extremeDate;
////   double pOldest = tipePntrs[_oldestIndex].tLineCurrPrevValues.rightValue;
////// create support resistance lines
////   uniqueID++;
//////isDate(_Symbol,_Period,shift+1,0,19,11,1,2019,false);
////   this.cdtl.AddLine(pNewest,pMidway,pOldest,dNewest,dMidway,dOldest,_clr,string(uniqueID)+"_"+EnumToString(waveHTFPeriod),this.getCurrTip());//tipePntrs[2].clr
////   ChartRedraw();
//  }
//+------------------------------------------------------------------+
//| initPanelScreenVar                                               |
//+------------------------------------------------------------------+
bool              Tip::initPanelScreenVar(int &_panelX,int _panelY)
  {
   if(!showPanel)
      return true;
// create Desc
   LabelCreate(0,onScreenDesc,0,_panelX,_panelY,CORNER_LEFT_UPPER,EnumToString(this.waveHTFPeriod),"Verdana",8,clrLine);
// create waveheightPts
   _panelX+=100;
   LabelCreate(0,onScreenWaveHeight,0,_panelX,_panelY,CORNER_LEFT_UPPER,DoubleToString(-1,0),"Verdana",8,clrOrange);
   _panelX+=100;
// create trend arrow
   LabelCreate(0,onScreenArrowLabel,0,_panelX,_panelY,CORNER_LEFT_UPPER,CharToString(arrowCode),fontTypeArrow,10,clrLine);
   _panelX+=100;
   return true;
  }
//+------------------------------------------------------------------+
//|initPanelScreenSymbol:Create symbol Label                         |
//+------------------------------------------------------------------+
bool              Tip::initPanelScreenSymbol(int &_panelX,int _panelY)
  {
   if(!showPanel)
      return true;
// create symbolLabel
   ResetLastError();
   if(!LabelCreate(0,onScreenSymbol,0,_panelX,_panelY,CORNER_LEFT_UPPER,this.symbol,"Verdana",8,clrRed))
     {
      Print(__FUNCTION__," Error creating symboll  label:  ",ErrorDescription(GetLastError()));
      return false;
     }
   _panelX+=200;
   return true;
  }
// +------------------------------------------------------------------+
// | drawWave                                                         |
// +------------------------------------------------------------------+
bool              Tip::drawNewWaveLine(TipElement *_tipe)
  {
   bool hasCreated=false;
//  if(!showTrendWave)
//     return hasCreated;
   int             width=1;           // line width
   bool            back=false;        // in the background
   bool            selection=false;// highlight to move
   bool            ray_right=false;   // line's continuation to the right
   bool            hidden=true;       // hidden in the object list
   long            z_order=0;         // priority for mouse click
   hasCreated=TrendCreate(
                 ChartID(),// chart's ID
                 _tipe.waveLineName,// line name
                 0,// subwindow index 0 is main window
                 _tipe.leftTime,// first point time
                 _tipe.leftPrice,// first point price
                 _tipe.rightTime,// second point time
                 _tipe.rightPrice,// second point price
                 _tipe.clrLine,// line color
                 _tipe.lineStyle, // trending or congested
                 width,back,selection,ray_right,hidden,z_order
              );
   return hasCreated;
  }
// +------------------------------------------------------------------+
// |clearTrend() remove trend line elements lines                     |
// |Empty the Tip                                                     |
// +------------------------------------------------------------------+
void              Tip::cleanTrend()
  {
//  if(!showTrendWave)
//   return;
   TipElement *tipe=NULL;
   for(int i=0; (i<this.Total()); i++)
     {
      tipe=GetNodeAtIndex(i);
      if(GetPointer(tipe)!=NULL)
        {
         ResetLastError();
         //  Sleep(1);
         //     if(ObjectFind(ChartID(),tipe.waveLineName) < 0)
         //     Print(__FUNCTION__,": failed to find tipe.waveLineName: = ",tipe.waveLineName," ",GetLastError()," Description: ",ErrorDescription(GetLastError()));
         //   else
         //      {
         ResetLastError();
         if(!ObjectDelete(ChartID(),tipe.waveLineName))
            Print(__FUNCTION__,": failed to delete tipe.waveLineName = ",tipe.waveLineName," ",GetLastError()," Description: ",ErrorDescription(GetLastError()));
         //     }
        }
      else
         Print(__FUNCTION__," NULL POINTER!");
     }
  }
// +------------------------------------------------------------------+
// |cleanLabels Remove a Tip Labels                                   |
// +------------------------------------------------------------------+
//void              Tip::cleanLabels()
//  {
//   if(GetPointer(this)!=NULL)
//     {
//      if(ObjectFind(0,this.onScreenArrowLabel)>=0)
//         ObjectDelete(0,this.onScreenArrowLabel);
//      if(ObjectFind(0,this.onScreenDesc)>=0)
//         ObjectDelete(0,this.onScreenDesc);
//      if(ObjectFind(0,this.onScreenWaveHeight)>=0)
//         ObjectDelete(0,this.onScreenWaveHeight);
//      if(ObjectFind(0,this.onScreenSymbol)>=0)
//         ObjectDelete(0,this.onScreenSymbol);
//     }
//   else
//      Print(__FUNCTION__," NULL Tip POINTER!");
//  }
// +------------------------------------------------------------------+
// |To Log: last node to print is most current                        |
// +------------------------------------------------------------------+
void              Tip::ToLog(string desc,bool show)
  {
//if(show)
//  {
//   TipElement *_tipe=NULL;
//   Print(desc+" in Q: ",this.Total());
//   for(int i=Total()-6; i<Total(); i++)
//     {
//      _tipe=GetNodeAtIndex(i);
//      if(GetPointer(_tipe)!=NULL)
//         Print("------>Trend Element: ",_tipe.waveLineName," Left Date: ",_tipe.tLineCurrPrevValues.pDate," Left Val: ",_tipe.tLineCurrPrevValues.prevRightValue," Right Date",_tipe.tLineCurrPrevValues.date," Right Val: ",_tipe.tLineCurrPrevValues.endFloat);
//      else
//         Print(__FUNCTION__," NULL POINTER TipElement");
//     }
//   Print("-------------------------------------------------------------------------------------------------------");
//  }
  }
// https:// docs.mql4.com/basis/oop/staticmembers
// --- Initialization of static members of the Parser class at the global level
int               Tip::uniqueID=0;
// +------------------------------------------------------------------+
//+------------------------------------------------------------------+
