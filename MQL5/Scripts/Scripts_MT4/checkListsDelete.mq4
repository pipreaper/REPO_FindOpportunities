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
#include <tradelogic.mqh>
#include <instrument.mqh>
#include <setUp.mqh>
//+------------------------------------------------------------------+
//| instrument stub                                                  |
//+------------------------------------------------------------------+
//class instrument : public CObject
//  {
//public:
//   string            symbol;
//public:
//                     instrument(string sym)
//     {
//      symbol=sym;
//     }
//                    ~instrument()
//     {
//      //Print(__FUNCTION__," Destructor instrument");
//     }
//  };
//+------------------------------------------------------------------+
//| Element of setUpList - polls these elements checking for setUps  |
//+------------------------------------------------------------------+
//class setUpListElement : public CObject
//  {
//public:
//   instrument       *ins;
//public:
//                     setUpListElement(instrument *sym)
//     {
//      ins=sym;
//     }
//                    ~setUpListElement()
//     {
//      delete(ins);
//      //Print(__FUNCTION__," Destructor setUpListElement");
//     }
//  };
//+------------------------------------------------------------------+
//| List of instruments currently set up & awaiting trigger          |
//+------------------------------------------------------------------+
class dsetUpList : public setUpList
  {
public:
   //+------------------------------------------------------------------+
   //|Constructor                                                       |
   //+------------------------------------------------------------------+   
                     dsetUpList()
     {
     };
                    ~dsetUpList()
     {
      //Print(__FUNCTION__," Destructor setUpList");
     };
   void ee()
     {}
   ////+------------------------------------------------------------------+
   ////|To Log                                                            |
   ////+------------------------------------------------------------------+
   //void  ToLog(string txt)
   //  {
   //   Print(txt," Total: ",this.Total());
   //   for(setUpListElement *i=GetFirstNode();i!=NULL;i=i.Next())
   //      Print(i.ins.symbol," is: ",i);
   //  }
   //+-------------------------------------------------------------------+
   //|xfer - xfer instruments from one list to another                   |
   //+-------------------------------------------------------------------+    
   void removeElements()
     {
      setUpListElement *j=GetFirstNode(),*temp=NULL,*curr=NULL;//     
                                                    //for(setUpListElement *j=GetFirstNode();j!=NULL;j=j.Next())
      //setUpListElement *j=GetFirstNode(),*temp=NULL;
      while(CheckPointer(j)!=POINTER_INVALID)
        {
         temp=j;
         j=j.Next();
         if(temp.ins.symbol=="MYSYMBOL2" || temp.ins.symbol=="WS30_SB")
           {
            m_curr_node=temp;
            DeleteCurrent();            
           }
        }

     }   
   //+-------------------------------------------------------------------+
   //|xfer - xfer instruments from one list to another                   |
   //+-------------------------------------------------------------------+    
   void xferElements()
     {
      setUpListElement *j=GetFirstNode(),*temp=NULL,*curr=NULL;//     
                                                    //for(setUpListElement *j=GetFirstNode();j!=NULL;j=j.Next())
      //setUpListElement *j=GetFirstNode(),*temp=NULL;
      while(CheckPointer(j)!=POINTER_INVALID)
        {
         temp=j;
         j=j.Next();
         if(temp.ins.symbol=="MYSYMBOL2" || temp.ins.symbol=="WS30_SB")
           {
            m_curr_node=temp;
            curr = DetachCurrent();
            trade.Add(curr);
           }
        }

     }
  };
dsetUpList *suListx=new dsetUpList();
string symbolsArray[5]={"GBPUSDSB","EURUSDSB","WS30_SB","MYSYMBOL","MYSYMBOL2"};
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   trade=new tradeObj(12345);
   suListx.ToLog("BEFORE add instruments",true);
   for(int i=0; i<ArraySize(symbolsArray); i++)
     {
      suListx.Add(new setUpListElement(new instrument(symbolsArray[i])));
     }
   suListx.ToLog("AFTER add instruments",true);
   suListx.xferElements();   
   //suListx.removeElements();
   suListx.ToLog("AFTER ACTION instruments",true);
   trade.ToLog("trade xfered");
  }
//+------------------------------------------------------------------+
//|OnDeInit                                                          |
//+------------------------------------------------------------------+  
void OnDeinit(const int reason)
  {
   delete(suListx);
   delete(trade);
//delete(suList);    
  }
//+------------------------------------------------------------------+
