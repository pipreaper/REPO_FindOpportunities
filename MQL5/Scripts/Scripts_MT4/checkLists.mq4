//+------------------------------------------------------------------+
//|                                                   checkLists.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Arrays\List.mqh>
#include <instrument.mqh>
#include <setUp.mqh>
#include <tradelogic.mqh>
////+------------------------------------------------------------------+
////| Element of setUpList - polls these elements checking for setUps  |
////+------------------------------------------------------------------+
//class setUpListElement : public CObject
//  {
//public:
//   instrument        *ins;
//   bool              isSetUp;
//   string            symbol;
//public:
//                     setUpListElement(string sym)
//     {
//      ins = new instrument(sym);
//     }
//                    ~setUpListElement()
//     {
//      Print(__FUNCTION__," Destructor setUpListElement");
//     }
//  };
////+------------------------------------------------------------------+
////| List of instruments currently set up & awaiting trigger          |
////+------------------------------------------------------------------+
//class setUpList : public CList
//  {
//public:
//   //+------------------------------------------------------------------+
//   //|Constructor                                                       |
//   //+------------------------------------------------------------------+   
//                     setUpList()
//     {
//     };
//                    ~setUpList()
//     {
//      this.clearList();
//      Print(__FUNCTION__," Destructor setUpList");
//     };
//   void clearList()
//     {
//      this.Clear();
//     };     
//   //+------------------------------------------------------------------+
//   //|To Log                                                            |
//   //+------------------------------------------------------------------+
//   void  ToLog(string txt)
//     {
//      Print(txt,"Total: ",this.Total());
//      for(setUpListElement *i=GetFirstNode();i!=NULL;i=i.Next())
//         Print(i.ins.symbol);
//     }
//  };




setUpList  *suList_B=new setUpList();
setUpList  *suList_A=new setUpList();
string symbolsArray[3]={"GBPUSDSB","EURUSDSB","WS30_SB"};
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   trade=new tradeObj(12345);
   MathSrand(0);
   double goLong=EMPTY_VALUE,goShort=EMPTY_VALUE,goClose=EMPTY_VALUE;
   for(int i=1;i<=10;i++)
      trade.testing(goLong,goShort,goClose);
   delete(trade);
//return;

//int count=0;
//do
//  {
//   suList_A.ToLog("Before List A",true);
//   suList_B.ToLog("Before List B",true);
//   for(int i=0; i<ArraySize(symbolsArray); i++)
//     {
//      suList_A.Add(new setUpListElement(new instrument(symbolsArray[i])));
//      //suList_B.Add(suList_A.DetachCurrent());
//     }
//   suList_A.ToLog("After List A",true);
//   suList_B.ToLog("After List B",true);
//   for(int i=0; i<ArraySize(symbolsArray); i++)
//     {
//      suList_A.GetNodeAtIndex(i);
//      suList_B.Add(suList_A.DetachCurrent());
//     }
//   suList_A.ToLog("After After List A",true);
//   suList_B.ToLog("After After List B",true);
//   //      delete(suList_A);
//   count+=1;
//  }
//while(count<3);
delete(suList_B);
delete(suList_A);
  }
//+------------------------------------------------------------------+
