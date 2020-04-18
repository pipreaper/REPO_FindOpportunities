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
class CCIWrapper
  {
public:
   double             cciValue[];
   //Constructor
                     CCIWrapper()
     {
     }
  };
//+------------------------------------------------------------------+
//| CCIValue                                                         |
//+------------------------------------------------------------------+
class CCIInfo : public CObject
  {
public:
   string            symbol;
   int               cciHandle;
   CCIWrapper        *cciWrapper;
   int               cciPeriod;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   void              CCIInfo::CCIInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciPeriod, int _cciAppliedPrice, string _catalystID);
   void CCIInfo::   ~CCIInfo();
  };
// Constructor
void CCIInfo::CCIInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciPeriod, int _cciAppliedPrice, string _catalystID)
  {
   symbol = _symbol;
   waveHTFPeriod = _waveHTFPeriod;
   cciWrapper=new CCIWrapper();
   cciPeriod = _cciPeriod;
   ArrayResize(cciWrapper.cciValue,1);
   ArraySetAsSeries(cciWrapper.cciValue,true);
   cciWrapper.cciValue[0]=-1;
   ResetLastError();
   cciHandle =iCustom(_symbol,_Period,"HTFCCI",waveHTFPeriod,_cciPeriod,_cciAppliedPrice,_catalystID,false);
//cciHandle=iCCI(_symbol,_waveHTFPeriod,_cciPeriod,_cciAppliedPrice);
   if(cciHandle <=0)
     {
      Print(__FUNCTION__," cciHandle failed to initialise: ",_symbol," ",_waveHTFPeriod,  ErrorDescription(GetLastError()));
     }
   double tempBuffer[];
   int bufferID =0;
  }
//Destructor
void CCIInfo::~CCIInfo()
  {
   IndicatorRelease(cciHandle);
   delete(cciWrapper);
  }


//+------------------------------------------------------------------+
