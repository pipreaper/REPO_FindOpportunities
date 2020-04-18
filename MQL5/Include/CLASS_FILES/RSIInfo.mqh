//+------------------------------------------------------------------+
//|                                                      RSIInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include    <\\INCLUDE_FILES\\drawText.mqh>
//+------------------------------------------------------------------+
//| RSIValue                                                         |
//+------------------------------------------------------------------+
class RSIWrapper
  {
public:
   double             rsiValue[];
   double            lowerBound;
   double            upperBound;
   //Constructor
                     RSIWrapper()
     {
     }
  };
//+------------------------------------------------------------------+
//| RSIValue                                                         |
//+------------------------------------------------------------------+
class RSIInfo
  {
public:
   int               rsiHandle;
   RSIWrapper        *rsiWrapper;
   int               maPeriod;
   int               maAppliedPrice;


   // Constructor
                     RSIInfo(string _symbol, ENUM_TIMEFRAMES _waveHTFPeriod,int _maPeriod, int _maAppliedPrice, int _numStoredRSIInfo,string _catalystID)
     {
      rsiHandle=iCustom(_symbol,_waveHTFPeriod,"HTFEMA", _maPeriod, _maAppliedPrice,_catalystID,false);
      rsiWrapper=new RSIWrapper();
      ArrayResize(rsiWrapper.rsiValue,_numStoredRSIInfo);
      ArraySetAsSeries(rsiWrapper.rsiValue,true);
      for(int i = 0; (i < _numStoredRSIInfo); i++)
        {
         rsiWrapper.rsiValue[i]=-1;
        }
      rsiWrapper.lowerBound = 20;
      rsiWrapper.upperBound = 80;
     }
   //Destructor
                    ~RSIInfo()
     {
      IndicatorRelease(rsiHandle);
      delete(rsiWrapper);
     }
  };
//+------------------------------------------------------------------+
