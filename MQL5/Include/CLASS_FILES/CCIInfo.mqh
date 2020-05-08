//+------------------------------------------------------------------+
//|                                                      CCIInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\List.mqh>
#include <\\INCLUDE_FILES\\WaveLibrary.mqh>
#include <errordescription.mqh>
//+------------------------------------------------------------------+
//| CCIValue                                                         |
//+------------------------------------------------------------------+
class CCIInfo : public CObject
  {
public:
   string            symbol;
   int               cciHandle;
   double            cciValue[];
   int               cciPeriod;
   int               cciAppliedPrice;
   int               numInitValues;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   void              CCIInfo::CCIInfo();
   bool              cciInitialise(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciPeriod, int _cciAppliedPrice, string _catalystID, int _numInitValues);
   void CCIInfo::   ~CCIInfo();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCIInfo::CCIInfo() {}
// Initialise
bool CCIInfo::cciInitialise(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciPeriod, int _cciAppliedPrice, string _catalystID, int _numInitValues)
  {
   symbol = _symbol;
   waveHTFPeriod = _waveHTFPeriod;
   cciPeriod = _cciPeriod;
   cciAppliedPrice=_cciAppliedPrice;
   numInitValues = _numInitValues;
   ArrayResize(cciValue,_numInitValues);
   ArraySetAsSeries(cciValue,true);
   ResetLastError();
   cciHandle=iCCI(_symbol,_waveHTFPeriod,cciPeriod,cciAppliedPrice);
   if(cciHandle <=0)
     {
      Print(__FUNCTION__," cciHandle failed to initialise: ",_symbol," ",_waveHTFPeriod,  ErrorDescription(GetLastError()));
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCIInfo::~CCIInfo()
  {
   IndicatorRelease(cciHandle);
  }
//+------------------------------------------------------------------+
