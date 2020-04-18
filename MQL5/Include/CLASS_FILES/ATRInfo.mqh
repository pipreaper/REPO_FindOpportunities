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
#include <errordescription.mqh>
//+------------------------------------------------------------------+
//| ATRValue                                                         |
//+------------------------------------------------------------------+
class ATRWrapper
  {
public:
   double             atrValue[];
   //Constructor
                     ATRWrapper()
     {
     }
  };
//+------------------------------------------------------------------+
//| ATRValue                                                         |
//+------------------------------------------------------------------+
class ATRInfo : public CObject
  {
public:
   string            symbol;
   int               atrHandle;
   ATRWrapper        *atrWrapper;
   int               atrRange;
 //  double            scaleATR;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   void              ATRInfo::ATRInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _atrRange, ENUM_CAT_ID _catalystID);
   void ATRInfo::   ~ATRInfo();
  };
// Constructor
void ATRInfo::ATRInfo(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _atrRange, ENUM_CAT_ID _catalystID)
  {
   atrHandle=iCustom(_symbol,_Period,"HTFATR",_waveHTFPeriod,_atrRange,_catalystID,false,DRAW_LINE);  
   symbol = _symbol;
   waveHTFPeriod = _waveHTFPeriod;
   atrWrapper=new ATRWrapper();
   atrRange = _atrRange;
   ArrayResize(atrWrapper.atrValue,1);
   ArraySetAsSeries(atrWrapper.atrValue,true);
   atrWrapper.atrValue[0]=-1;
   ResetLastError();
   if(atrHandle <=0)
     {
      Print(__FUNCTION__," atrHandle failed to initialise: ",_symbol," ",_waveHTFPeriod,  ErrorDescription(GetLastError()));
     }
   double tempBuffer[];
   int bufferID =0;
  }
//Destructor
void ATRInfo::~ATRInfo()
  {
   IndicatorRelease(atrHandle);
   delete(atrWrapper);
  }


//+------------------------------------------------------------------+
