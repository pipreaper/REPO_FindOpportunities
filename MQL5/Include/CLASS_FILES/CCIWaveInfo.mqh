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
   void              CCIWaveInfo::CCISetWaveInfo(double _cciTriggerLevel, double _cciExitLevel);
   void              CCIWaveInfo::setCCIState(void);
   cciClicked        CCIWaveInfo::getCCIState(void);
  };
//+------------------------------------------------------------------+
//| CCIWaveInfo                                                      |
//+------------------------------------------------------------------+
void CCIWaveInfo::CCIWaveInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciRange, int _cciAppliedPrice,string _cciCatalystID) : CCIInfo(_symbol,_waveHTFPeriod,_cciRange, _cciAppliedPrice,_cciCatalystID)
  {
  }
//+------------------------------------------------------------------+
//| CCISetWaveInfo                                                   |
//+------------------------------------------------------------------+
void              CCIWaveInfo::CCISetWaveInfo(double _cciTriggerLevel, double _cciExitLevel)
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
//| setWaveHeightPoints                                              |
//+------------------------------------------------------------------+
void              CCIWaveInfo::setCCIState()
  {
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
cciClicked              CCIWaveInfo::getCCIState()
  {
   return cciState;
  }
//+------------------------------------------------------------------+
