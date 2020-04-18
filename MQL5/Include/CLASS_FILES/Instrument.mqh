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
#include <Trade\SymbolInfo.mqh>       // --- CSymbolInfo
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
  // CSymbolInfo             mySymbol;
   ContainerDiagonalTip    *pContainerTip;
   ContainerLip            *pContainerLip;
   ContainerVip            *pContainerVip;
   //   ContainerIndicator      *pContainerTipIndicator;
   //   ContainerIndicator      *pContainerLipIndicator;
   //  ContainerADip     *pContainerADip;
   void              Instrument(string _symbol)
     {
      symbol=_symbol;
      // set the name
      // load the history data
      // this checks its in the watch and refreshes the rates
      if(this.Name(_symbol))
         Print(this.Description(),this.Ask());
      else
         Print(__FUNCTION__," ",_symbol," Either No Rates or not in the watch ");
      // Create MISC
      //     pContainerLipIndicator           =  new ContainerIndicator;
      pContainerTip                 =  new ContainerDiagonalTip();
      pContainerLip                 =  new ContainerLip();
      pContainerLip.pSumLipElements =  new sumLipElements;
      pContainerVip                 =  new ContainerVip();
     }
   void             ~Instrument()
     {
      //      if(CheckPointer(pContainerLipIndicator)!=POINTER_INVALID)
      //        delete(pContainerLipIndicator);
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
  };
// +------------------------------------------------------------------+
