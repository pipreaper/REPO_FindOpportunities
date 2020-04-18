//+------------------------------------------------------------------+
//|                                                      VOLInfo.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include    <\\INCLUDE_FILES\\drawText.mqh>
//+------------------------------------------------------------------+
//| VOLValue                                                         |
//+------------------------------------------------------------------+
class VOLWrapper
  {
public:
   double            volValue[];
   //Constructor
                     VOLWrapper()
     {
     }
  };
//+------------------------------------------------------------------+
//| VOLValue                                                         |
//+------------------------------------------------------------------+
class VOLInfo
  {
public:
   int               volHandle;
   VOLWrapper        *volWrapper;
   ENUM_APPLIED_VOLUME               volIsTick;
   // Constructor
                     VOLInfo(string _symbol, ENUM_TIMEFRAMES _waveHTFPeriod, ENUM_APPLIED_VOLUME _volIsTick, int _numStoredVolInfo)
     {
      volHandle=iVolumes(_symbol,_waveHTFPeriod,_volIsTick);
      volWrapper=new VOLWrapper();

      ArrayResize(volWrapper.volValue,_numStoredVolInfo);
      ArraySetAsSeries(volWrapper.volValue,true);
      for(int i = 0; (i < _numStoredVolInfo); i++)
        {
         volWrapper.volValue[i]=-1;
        }
      volIsTick = _volIsTick;
      ArrayResize(volWrapper.volValue,1);
      ArraySetAsSeries(volWrapper.volValue,true);
      volWrapper.volValue[0]=-1;
     }
   //Destructor
                    ~VOLInfo()
     {
      IndicatorRelease(volHandle);
      delete(volWrapper);
     }
   //  set wave height according to VOL value of Tip
   void              VOLInfo::yy(string _symbol,string _onScreenWaveHeight);
   void              VOLInfo::yyy(string _symbol,string _onScreenWaveHeight,double whp) ;
  };
//+------------------------------------------------------------------+
//| setWaveHeightPoints                                              |
//+------------------------------------------------------------------+
void              VOLInfo::yy(string _symbol,string _onScreenWaveHeight)
  {

  }
//+------------------------------------------------------------------+
//| setWaveHeightPoints                                              |
//+------------------------------------------------------------------+
void              VOLInfo::yyy(string _symbol,string _onScreenWaveHeight,double whp)
  {

  }
//+------------------------------------------------------------------+
