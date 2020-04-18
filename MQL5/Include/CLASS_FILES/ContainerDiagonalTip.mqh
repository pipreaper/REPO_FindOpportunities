//+------------------------------------------------------------------+
//|                                                    TrendLine.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//| state of the diagonal line is oblivious to the state of any trade|
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include    <Arrays\List.mqh>
#include    <\\INCLUDE_FILES\\WaveLibrary.mqh>
#include    <\\INCLUDE_FILES\\drawing.mqh>
#include    <\\CLASS_FILES\\ContainerTip.mqh>
#include    <\\CLASS_FILES\\DiagTip.mqh>
template<typename T>
class vectorContainerTip : public ContainerTip {};
class ContainerDiagonalTip: public vectorContainerTip<DiagTip*>
  {
private:
public:
   void              ContainerDiagonalTip::ContainerDiagonalTip();   
   void              ContainerDiagonalTip::ToLog(string desc,bool show);
   void              ContainerDiagonalTip::~ContainerDiagonalTip();
  };
// +------------------------------------------------------------------+
// |Constructor                                                       |
// +------------------------------------------------------------------+
void ContainerDiagonalTip::ContainerDiagonalTip() {}
// +------------------------------------------------------------------+
// |Destructor                                                        |
// |called emptyContiners and main empty of ContainerTipQs            |
// +------------------------------------------------------------------+
void ContainerDiagonalTip::~ContainerDiagonalTip()
  {
   //DiagTip *diagTip = NULL;
   //for(int i=0; i<Total(); i++)
   //  {
   //   diagTip = this.GetNodeAtIndex(i);
   //   if(CheckPointer(diagTip)!=POINTER_INVALID)
   //     {
   //      cleanDiagLine(diagTip);
   //     }
   //   else
   //      Print(__FUNCTION__," POINTER_INVALID ->Tip Number: ",i," pointer: ",diagTip);
   //  }
   //Clear();
  }
// +------------------------------------------------------------------+
// |To Log: last node to print is most current                        |
// +------------------------------------------------------------------+
void              ContainerDiagonalTip::ToLog(string desc,bool show)
  {
   if(show)
     {
      DiagTip *dle=NULL;
      Print(desc+" in Q: ",this.Total());
      for(int i=0; i<Total(); i++)
        {
         dle=GetNodeAtIndex(i);
         if(GetPointer(dle)!=NULL)
           {
            Print("Initial Conditions ------> ",dle.symbol," dle.diaTrendLineName: ",dle.diaTrendLineName);
            Print("Tip State: ",dle.getTipState()," prev Tip State: ",dle.getPrevTipState());
            Print("p0, t0: ",dle.YVals[0],"  ",dle.XTimes[0]);
            Print("p1, t1: ",dle.YVals[1],"  ",dle.XTimes[1]);
           }
         else
            Print(__FUNCTION__," NULL POINTER DiagTip");
        }
      Print("-------------------------------------------------------------------------------------------------------");
     }
  }
//+------------------------------------------------------------------+
