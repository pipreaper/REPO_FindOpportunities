// +------------------------------------------------------------------+
// |                                               Tip.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                             https:// www.mql5.com |
// |                         individual wave arms that make up a tiphe|
// +------------------------------------------------------------------+
#property   copyright "Copyright 2017, Robert Baptie"
#property   link      "https:// www.mql5.com"
#property   version   "1.01"
#property   strict
//#include    <\\CLASS_FILES\\Tip.mqh>
#include    <\\INCLUDE_FILES\\drawing.mqh>
#include    <Arrays\List.mqh>
// +------------------------------------------------------------------+
// |containerTrendPeriodsObj: Contains Tip's                          |
// +------------------------------------------------------------------+
class ContainerTip : public CList
  {
public:
   MqlRates          ratesCTF[];
   void              ContainerTip::ContainerTip();
   void              ContainerTip::~ContainerTip();
   void              ContainerTip::ToLog();
  };
// +------------------------------------------------------------------+
// | ContainerTip parametric constructor                              |
// +------------------------------------------------------------------+
void ContainerTip::ContainerTip()
  {
  }
// +------------------------------------------------------------------+
// | Destructor                                                       |
// +------------------------------------------------------------------+
void ContainerTip::~ContainerTip()
  {
  }
// +------------------------------------------------------------------+
// |ToLog                                                             |
// +------------------------------------------------------------------+
void             ContainerTip::ToLog()
  {
   //Tip *tip=NULL;
   //for(int i=0; i<Total(); i++)
   //  {
   //   tip=GetNodeAtIndex(i);
   //   if(GetPointer(tip)!=NULL)
   //     {
   //      Print("------> Total:  ",tip.Total());
   //     }
   //   else
   //      Print(__FUNCTION__," NULL POINTER Tip: ");
   //   Print("// -----------------------------------------------------// ");
   //  }
  }
//+------------------------------------------------------------------+
