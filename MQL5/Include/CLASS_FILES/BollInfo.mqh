//+------------------------------------------------------------------+
//|                                                      BOLLInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include    <\\INCLUDE_FILES\\drawText.mqh>
//+------------------------------------------------------------------+
//| BOLLValue                                                         |
//+------------------------------------------------------------------+
class BOLLWrapper
  {
public:
   double             bollValue[];
   double             bollUpper[];
   double             bollLower[];
   //Constructor
                     BOLLWrapper()
     {
     }
  };
//+------------------------------------------------------------------+
//| BOLLValue                                                         |
//+------------------------------------------------------------------+
class BOLLInfo
  {
public:
   int               bollHandle;
   BOLLWrapper       *bollWrapper;
   int               maPeriod;
   int               maShift;
   int               maDeviation;
   int               maAppliedPrice;

   // Constructor
                     BOLLInfo(string _symbol, ENUM_TIMEFRAMES _waveHTFPeriod,int _maPeriod, int _maShift,int _maDeviation,int _maAppliedPrice, int numStoredBollInfo)
     {
      bollHandle=iBands(_symbol,_waveHTFPeriod, _maPeriod, _maShift, _maDeviation, _maAppliedPrice);     
      bollWrapper=new BOLLWrapper();
      ArrayResize(bollWrapper.bollValue,numStoredBollInfo);
      ArraySetAsSeries(bollWrapper.bollValue,true);
      ArrayResize(bollWrapper.bollUpper,numStoredBollInfo);
      ArraySetAsSeries(bollWrapper.bollUpper,true);
      ArrayResize(bollWrapper.bollLower,numStoredBollInfo);
      ArraySetAsSeries(bollWrapper.bollLower,true);
      for(int i = 0; (i < numStoredBollInfo); i++)
        {
         bollWrapper.bollValue[i]=-1;
         bollWrapper.bollUpper[i]=-1;
         bollWrapper.bollLower[i]=-1;
        }
     }
   //Destructor
                    ~BOLLInfo()
     {
      IndicatorRelease(bollHandle);
      delete(bollWrapper);
     }
  };
//+------------------------------------------------------------------+
