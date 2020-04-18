//+------------------------------------------------------------------+
//|                                                      EMAInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\List.mqh>
//#include <\\INCLUDE_FILES\\drawText.mqh>
#include <errordescription.mqh>
//+------------------------------------------------------------------+
//| EMAValue                                                         |
//+------------------------------------------------------------------+
class EMAWrapper
  {
public:
   double             emaValue[];
   //Constructor
                     EMAWrapper()
     {
     }
  };
//+------------------------------------------------------------------+
//| EMAValue                                                         |
//+------------------------------------------------------------------+
class EMAInfo : public CObject
  {
public:
   string               symbol;
   int                  emaHandle;
   EMAWrapper           *emaWrapper;
   int                  emaPeriod;
   int                  emaShift;
   ENUM_MA_METHOD       emaMethod;
   ENUM_APPLIED_PRICE   emaAppliedPrice;
   ENUM_TIMEFRAMES      waveHTFPeriod;
void EMAInfo::EMAInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod,int _emaPeriod,int _emaShift, ENUM_MA_METHOD _emaMethod, ENUM_APPLIED_PRICE _emaAppliedPrice, string _catalystID);
   void EMAInfo::   ~EMAInfo();
  };
// Constructor
void EMAInfo::EMAInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod,int _emaPeriod,int _emaShift, ENUM_MA_METHOD _emaMethod, ENUM_APPLIED_PRICE _emaAppliedPrice, string _catalystID)
  {
   symbol = _symbol;
   waveHTFPeriod = _waveHTFPeriod;
   emaWrapper=new EMAWrapper();
   emaPeriod = _emaPeriod;
   emaShift = _emaShift;
   emaMethod=_emaMethod;
   emaAppliedPrice = _emaAppliedPrice;
   ArrayResize(emaWrapper.emaValue,1);
   ArraySetAsSeries(emaWrapper.emaValue,true);
   emaWrapper.emaValue[0]=-1;
   ResetLastError();
   emaHandle = iCustom(_symbol,_Period,"HTFEMA",waveHTFPeriod,_emaPeriod,_emaAppliedPrice,_emaMethod, _catalystID,false);      // Timeframe 2 (TF2) period
//   emaHandle=iMA(_symbol,_waveHTFPeriod,_emaPeriod,_emaShift,_emaMethod,_emaAppliedPrice);
   if(emaHandle <=0)
     {
      Print(__FUNCTION__," emaHandle failed to initialise: ",_symbol," ",_waveHTFPeriod,  ErrorDescription(GetLastError()));
     }
  }
//Destructor
void EMAInfo::~EMAInfo()
  {
   IndicatorRelease(emaHandle);
   delete(emaWrapper);
  }


//+------------------------------------------------------------------+
