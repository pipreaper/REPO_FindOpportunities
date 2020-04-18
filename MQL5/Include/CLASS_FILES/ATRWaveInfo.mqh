//+------------------------------------------------------------------+
//|                                                      ATRInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\List.mqh>
#include <\\INCLUDE_FILES\\drawText.mqh>
#include <\\INCLUDE_FILES\\WaveLibrary.mqh>
#include <CLASS_FILES\ATRInfo.mqh>
#include <errordescription.mqh>

//+------------------------------------------------------------------+
//| ATRValue                                                         |
//+------------------------------------------------------------------+;
class ATRWaveInfo : public ATRInfo
  {
public:
   double            pointSize;
   int               digits;
   double            waveHeightPts;
   bool              showPanel;
   double            scaleATR;
   void              ATRWaveInfo::ATRWaveInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _atrRange,ENUM_CAT_ID _atrCatalystID);
   void              ATRWaveInfo::atrInit(double _scaleATR, bool _showPanel);
   //  set wave height according to ATR value of Tip
   bool              ATRWaveInfo::setWaveHeightPointsATR(string _onScreenWaveHeight, int _shift);
   void              ATRWaveInfo::setWaveHeightPointsFixed(string _onScreenWaveHeight);
   void              ATRWaveInfo::setFixedWaveHeight();
   double            ATRWaveInfo::calculateAverageWaveHeight(int _totalBarsWanted);
  };
//+------------------------------------------------------------------+
//| ATRWaveInfo                                                      |
//+------------------------------------------------------------------+
void ATRWaveInfo::ATRWaveInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _atrRange,ENUM_CAT_ID _atrCatalystID) : ATRInfo(_symbol,_waveHTFPeriod, _atrRange, _atrCatalystID)
  {
// calls underying Object Init function
  }
//+------------------------------------------------------------------+
//| ATRSetWaveInfo                                                   |
//+------------------------------------------------------------------+
void              ATRWaveInfo::atrInit(double _scaleATR, bool _showPanel)
  {
   scaleATR = _scaleATR;
   waveHeightPts=-1;
   showPanel = _showPanel;
   ArrayResize(atrWrapper.atrValue,1);
   ArraySetAsSeries(atrWrapper.atrValue,true);
   int bufferID =0;
   SymbolInfoDouble(symbol,SYMBOL_POINT,pointSize);
   digits = int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
  }
//+------------------------------------------------------------------+
//| set onscreen text and wave height for this bar variable by ATR   |
//| for this bar                                                     |
//+------------------------------------------------------------------+
bool              ATRWaveInfo::setWaveHeightPointsATR(string _onScreenWaveHeight,int _shift)
  {
   bool condition = true;
   if(CopyBuffer(atrHandle,0,_shift,1, atrWrapper.atrValue) <= 0 || atrWrapper.atrValue[0]<=0)
     {
      condition = false;
      Print(__FUNCTION__," shift: ",_shift," atrWrapper.atrValue[0] ",atrWrapper.atrValue[0]);
     }
   else
     {
      waveHeightPts=NormalizeDouble(((scaleATR * atrWrapper.atrValue[0])/pointSize),2);
      if(showPanel)
         TextChange(ChartID(), _onScreenWaveHeight, DoubleToString(waveHeightPts,0));
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| set onscreen text and wave height for this bar Fixed             |
//| for this bar                                                     |
//+------------------------------------------------------------------+
void              ATRWaveInfo::setWaveHeightPointsFixed(string _onScreenWaveHeight)
  {
   setFixedWaveHeight();
   if(showPanel)
     {
      // update the label for this timeframe
      TextChange(ChartID(), _onScreenWaveHeight, DoubleToString(waveHeightPts,0));
     }
  }
//+------------------------------------------------------------------+
//| setFixedWaveheight                                               |
//+------------------------------------------------------------------+
void              ATRWaveInfo::setFixedWaveHeight()
  {
   if(waveHeightPts == -1)
      waveHeightPts = scaleATR*calculateAverageWaveHeight(1000);
  }
//+-------------------------------------------------------------------+
//| calcuate average wave height in points for_totalbars              |
//+-------------------------------------------------------------------+
double ATRWaveInfo::calculateAverageWaveHeight(int _totalBarsWanted)
  {
   double   tempSum=0;
//int btc=(int(_totalBarsWanted));
   MqlRates rates[];
   int availableBars = Bars(symbol,waveHTFPeriod);
   int numBars = MathMin(availableBars,_totalBarsWanted);
   if(numBars < 50)
     {
      Print(__FUNCTION__," ********  WARNING Wave height - Not enough data points  ******************  "+DoubleToString(numBars), " Wanted: ",_totalBarsWanted);
      PlaySound("tick.wav");
      return -1; //hard failsafe
     }
   else
     {
      numBars=CopyRates(symbol, waveHTFPeriod,0,_totalBarsWanted, rates);
      if(numBars > 0)
        {
         double diff = 0;
         for(int i = 0 ; (i < numBars); i++)
            diff += rates[i].high-rates[i].low;
         // work out average bar size
         double calculatedPoints = diff/numBars;
         return (NormalizeDouble(calculatedPoints/pointSize,0));
        }
      else
        {
         Print(__FUNCTION__," ********  WARNING Wave height - Not enough data points failed to copy rates ******************  "+DoubleToString(numBars), " Wanted: ",_totalBarsWanted);
         PlaySound("tick.wav");
         return -1; //hard failsafe
        }
     }
  }
//+------------------------------------------------------------------+
