//+------------------------------------------------------------------+
//|                                                     Sim.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <CLASS_FILES\\BarFlow.mqh>
#include <CLASS_FILES\TradeFlow.mqh>
#include <CLASS_FILES\MonitorFlow.mqh>
class Sim: public MonitorFlow
  {
private:

public:
   rttl              rttlThis;
   double            Sim::selectTarget(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs);
   double            Sim::setByATR(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs, ENUM_TIMEFRAMES _period);
                     Sim();
                    ~Sim();
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
void              Sim::Sim() {}
//+------------------------------------------------------------------+
//|Desructor                                                         |
//+------------------------------------------------------------------+
void Sim::~Sim() {}

//+------------------------------------------------------------------+
//|selectTarget  Currently finds a@  least 1:1 ratio or sets by ATR  |
//+------------------------------------------------------------------+
double              Sim::selectTarget(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs)
  {
//uses bids
// instrumentPointers[_ins].mySymbol.Name();
// iterate the (3) levels that are available from MonitorFlow module
   for(int x=1; (x<ArraySize(currLipe)); x++)
     {
      if(currLipe[x].levelPrice != 0)
        {
         // Check if @ least 1:1 ratio
         if((MathAbs(_entryPrice-currLipe[x].levelPrice)/MathAbs(_entryPrice - _sl)) > 1)
            return currLipe[x].levelPrice;
        }
      else
        {
         // Attempt setByATR
         double TP = setByATR(_ins,_entryPrice,_sl, _bs,_Period);
         // Check if @ least 1:1 ratio
         if((MathAbs(_entryPrice-tp)/MathAbs(_entryPrice - _sl)) > 1)
            return TP;
         else
           {
            Print(__FUNCTION__, " ATR value for tp: ",NormalizeDouble(tp,instrumentPointers[_ins].mySymbol.Digits()), " is less than 1:1 ratio ");
            return 0.0;
           }
        }
     }
   Print(__FUNCTION__, "ArraySize(currLipe) <= 0: ",ArraySize(currLipe));
   return 0.0;
  }
//+------------------------------------------------------------------+
//|setByATR                                                          |
//+------------------------------------------------------------------+
double Sim::setByATR(int _ins, double _entryPrice,double _sl,ENUM_ORDER_TYPE _bs, ENUM_TIMEFRAMES _period)
  {
// 1. get the atr handle for the chart tf
// 2. establish if have values and set if found
// 3. else use values to calculate profit target 3*ATR
   ATRInfo *atr = NULL;
   if(instrumentPointers[_ins].pContainerLip.Total()>0)
     {
      // ** CHECK FOR NEW TREND DATA FOR EACH ACTIVE PERIOD
      for(int instrumentTrend=0; (instrumentTrend<instrumentPointers[_ins].pContainerLip.Total()); instrumentTrend++)
        {
         if(CheckPointer(instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(instrumentTrend))!=POINTER_INVALID)
           {
            atr = instrumentPointers[_ins].pContainerLip.GetNodeAtIndex(instrumentTrend);
            if(atr.waveHTFPeriod == _period)
              {
               int numValues = CopyBuffer(atr.atrHandle, 0,1,1, atr.atrWrapper.atrValue);
               if(numValues < 0)
                 {
                  Print(__FUNCTION__, "failed to get indicator value: ",_ins," _Period ",_period);
                  return 0.0;
                 }
               else
                 {
                  // set target
                  if(_bs == ORDER_TYPE_BUY)
                    {
                     double TP = _entryPrice+3*atr.atrWrapper.atrValue[0];
                     return TP;
                    }
                  else
                     if(_bs == ORDER_TYPE_SELL)
                       {
                        double TP = _entryPrice-3*atr.atrWrapper.atrValue[0];
                        return TP;
                       }
                 }
              }
           }
        }
     }
   return 0.0;
  }
//+------------------------------------------------------------------+
