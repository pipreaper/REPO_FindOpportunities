//+------------------------------------------------------------------+
//|                                                      CCIInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\List.mqh>
//#include <\\INCLUDE_FILES\\drawText.mqh>
#include <CLASS_FILES\CCIInfo.mqh>
#include <errordescription.mqh>

//+------------------------------------------------------------------+
//| CCIValue                                                         |
//+------------------------------------------------------------------+;
class CCIWaveInfo : public CCIInfo
  {
   cciClicked        cciState;
   double            cciTriggerLevel;
   double            cciExitLevel;
public:
   double            pointSize;
   int               digits;
   void              CCIWaveInfo::CCIWaveInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciRange, int _cciAppliedPrice, string _cciCatalystID);
   void              CCIWaveInfo::cciInit(double _cciTriggerLevel, double _cciExitLevel);
   bool              CCIWaveInfo::setCCIValues(int _shift);
   void              CCIWaveInfo::setCCIState(void);
   cciClicked        CCIWaveInfo::getCCIState(void);
   double            CCIWaveInfo::getCCIValue(void);
  };
//+------------------------------------------------------------------+
//| CCIWaveInfo                                                      |
//+------------------------------------------------------------------+
void CCIWaveInfo::CCIWaveInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciRange, int _cciAppliedPrice,string _cciCatalystID) : CCIInfo(_symbol,_waveHTFPeriod,_cciRange, _cciAppliedPrice,_cciCatalystID)
  {
  }
//+------------------------------------------------------------------+
//| set onscreen text and wave height for this bar variable by ATR   |
//| for this bar                                                     |
//+------------------------------------------------------------------+
bool              CCIWaveInfo::setCCIValues(int _shift)
  {
   bool condition = true;
   if(CopyBuffer(cciHandle,0,_shift,1, cciWrapper.cciValue) <= 0)
     {
      condition = false;
      Print(__FUNCTION__," shift: ",_shift," cciWrapper.cciValue[0] ",cciWrapper.cciValue[0]);
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| CCISetWaveInfo                                                   |
//+------------------------------------------------------------------+
void              CCIWaveInfo::cciInit(double _cciTriggerLevel, double _cciExitLevel)
  {
   cciTriggerLevel=_cciTriggerLevel;
   cciExitLevel=_cciExitLevel;
   cciState = cciNone;
   ArrayResize(cciWrapper.cciValue,1);
   ArraySetAsSeries(cciWrapper.cciValue,true);
   cciWrapper.cciValue[0]=-1;
   SymbolInfoDouble(symbol,SYMBOL_POINT,pointSize);
   digits = int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
  }
//+------------------------------------------------------------------+
//|                                               |
//+------------------------------------------------------------------+
void              CCIWaveInfo::setCCIState()
  {
//if(cciWrapper.cciValue[0]==-1 || cciWrapper.cciValue[0]==0)
//   DebugBreak();
   if(cciWrapper.cciValue[0] > cciTriggerLevel)
      cciState=cciAbove100;
   else
      if(cciWrapper.cciValue[0]<-cciTriggerLevel)
         cciState = cciBelow100;
      else
         if((cciState == cciAbove100) && (cciWrapper.cciValue[0] < cciExitLevel))
            cciState = cciNone;
         else
            if((cciState == cciBelow100) && (cciWrapper.cciValue[0] > -cciExitLevel))
               cciState = cciNone;
  }
//+------------------------------------------------------------------+
//| setWaveHeightPoints                                              |
//+------------------------------------------------------------------+
double              CCIWaveInfo::getCCIValue()
  {
   return this.cciWrapper.cciValue[0];
  }
//+------------------------------------------------------------------+
//| setWaveHeightPoints                                              |
//+------------------------------------------------------------------+
cciClicked              CCIWaveInfo::getCCIState()
  {
   return cciState;
  }
//+------------------------------------------------------------------+
