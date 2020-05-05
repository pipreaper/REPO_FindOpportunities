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
   void              CCIWaveInfo::CCIWaveInfo();
   bool              CCIWaveInfo::cciInitialise(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciRange, int _cciAppliedPrice, string _cciCatalystID,int _numInitValues,double _cciTriggerLevel, double _cciExitLevel);
   bool              CCIWaveInfo::setCCIValues(int _shift);
   void              CCIWaveInfo::setCCIState(datetime _time);
   cciClicked        CCIWaveInfo::getCCIState(void);
   double            CCIWaveInfo::getCCIValue(datetime _time);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CCIWaveInfo::CCIWaveInfo() {}
//+------------------------------------------------------------------+
//| Set trigger and exit levels                                      |
//+------------------------------------------------------------------+
bool CCIWaveInfo::cciInitialise(string _symbol,  ENUM_TIMEFRAMES _waveHTFPeriod, int _cciPeriod, int _cciAppliedPrice, string _catalystID,int _numInitValues, double _cciTriggerLevel, double _cciExitLevel)
  {
   bool condition = false;
   if(CCIInfo::cciInitialise(_symbol,_waveHTFPeriod, _cciPeriod, _cciAppliedPrice, _catalystID, _numInitValues))
     {
      cciTriggerLevel   =  _cciTriggerLevel;
      cciExitLevel      =  _cciExitLevel;
      condition = true;
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| set values according to chart bar [1] of HTF                     |
//+------------------------------------------------------------------+
bool  CCIWaveInfo::setCCIValues(int _shift)
  {
   bool condition = true;
   if(CopyBuffer(cciHandle,0,_shift,numInitValues-1, cciValue) <= 0)
     {
      condition = false;
      Print(__FUNCTION__," shift: ",_shift," cciValue does not have enough values#: ", ArraySize(cciValue));
     }
   return condition;
  }
//+------------------------------------------------------------------+
//| Determine state from previous chart bar [1]                      |
//+------------------------------------------------------------------+
void              CCIWaveInfo::setCCIState(datetime _time)
  {
  //int shift = iBarShift(symbol,waveHTFPeriod,_time,true);
   if(getCCIValue(_time) > cciTriggerLevel)
      cciState=cciAbove100;
   else
      if(getCCIValue(_time)<-cciTriggerLevel)
         cciState = cciBelow100;
      else
         if((cciState == cciAbove100) && (getCCIValue(_time) < cciExitLevel))
            cciState = cciNone;
         else
            if((cciState == cciBelow100) && (getCCIValue(_time) > -cciExitLevel))
               cciState = cciNone;
  }
//+------------------------------------------------------------------+
//| get value                                                        |
//+------------------------------------------------------------------+
double              CCIWaveInfo::getCCIValue(datetime _time)
  {
   return cciValue[iBarShift(symbol,waveHTFPeriod,_time,true)];
  }
//+------------------------------------------------------------------+
//| get State                                                        |
//+------------------------------------------------------------------+
cciClicked              CCIWaveInfo::getCCIState()
  {
   return cciState;
  }
//+------------------------------------------------------------------+
