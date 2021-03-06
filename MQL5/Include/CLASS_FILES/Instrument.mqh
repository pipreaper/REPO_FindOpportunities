// +------------------------------------------------------------------+
// |                                                   instrument.mqh |
// |                                    Copyright 2017, Robert Baptie |
// |                                             https:// www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      "https:// www.mql5.com"
#property version   "2.12"
#property strict
#include <Arrays\List.mqh>
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <CLASS_FILES\ContainerLip.mqh>
#include <CLASS_FILES\ContainerDiagonalTip.mqh>
#include <CLASS_FILES\ContainerVip.mqh>
#include <Trade\SymbolInfo.mqh>
#include <CLASS_FILES\ATRInfo.mqh>
// +------------------------------------------------------------------+
// |instrument                                                        |
// |Pointers to Tip,Lip                                     |
// |Set the CSymbolInfo to _Symbol name and load the data for         |
// | initialisation                                                   |
// +------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Instrument                                                       |
//+------------------------------------------------------------------+
class Instrument : public CSymbolInfo
  {
public:
   string                  symbol;
   ATRInfo                 *atrLimit;
   ContainerDiagonalTip    *pContainerTip;
   ContainerLip            *pContainerLip;
   ContainerVip            *pContainerVip;
   void                    Instrument::Instrument();
   void                    Instrument::~Instrument();
   void                    Instrument::initInstrument(string _symbol, int _perATRLimit, ENUM_TIMEFRAMES _htfPeriod);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              Instrument::Instrument() {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void             Instrument::~Instrument()
  {
   if(CheckPointer(atrLimit)!=POINTER_INVALID)
      delete(atrLimit);
   if(CheckPointer(pContainerTip)!=POINTER_INVALID)
      delete(pContainerTip);
   if(CheckPointer(pContainerLip)!=POINTER_INVALID)
     {
      delete(pContainerLip.pSumLipElements);
      delete(pContainerLip);
     }
   if(CheckPointer(pContainerVip)!=POINTER_INVALID)
      delete(pContainerVip);
  }
//+------------------------------------------------------------------+
//|initialise Instrument                                             |
//+------------------------------------------------------------------+
void              Instrument::initInstrument(string _symbol, int _perATRLimit, ENUM_TIMEFRAMES _htfPeriod)
  {
   symbol=_symbol;
   if(this.Name(_symbol))
      Print(__FUNCTION__," ",this.Description(),this.Ask());
   else
      Print(__FUNCTION__," ",_symbol," Either No Rates or not in the watch ");
   atrLimit = new ATRInfo(_symbol,_htfPeriod,_perATRLimit,NULL);
   pContainerTip                 =  new ContainerDiagonalTip();
   pContainerLip                 =  new ContainerLip();
   pContainerLip.pSumLipElements =  new sumLipElements;
   pContainerVip                 =  new ContainerVip();
  }
// +------------------------------------------------------------------+
