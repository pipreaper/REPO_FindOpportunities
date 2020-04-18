//+------------------------------------------------------------------+
//|                                                  correlation.mqh |
//|                                    Copyright 2017, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.02"
#property strict
#include <Arrays\List.mqh>
#include <WaveLibrary.mqh>
#include <status.mqh>
#include <symbolsInfo.mqh>
extern string ForexGroupID="FX";
//+------------------------------------------------------------------+
//|CLASS Correlation Group - groups of exceptions                    |
//+------------------------------------------------------------------+
class correlationGroup : public CList
  {
public:
   string            groupName;
   //+------------------------------------------------------------------+
   //|Constructor                                                       |
   //+------------------------------------------------------------------+ 
   void correlationGroup(string gName)
     {
      groupName=gName;
     }
   //+------------------------------------------------------------------+
   //|Constructor                                                       |
   //+------------------------------------------------------------------+      
   void ~correlationGroup()
     {
      //delete group elements
      //then delete group     
      this.Clear();
     }
  };
//+------------------------------------------------------------------+
//LIST OF CORRELATION GROUPS
//|tempory runtime list of Symbol[] groups                           |
//|Each Group Contains the list of exceptions                        |                                           
//+------------------------------------------------------------------+
class correlationList : public CList
  {
public:
public:
   string            groupName;
   //+------------------------------------------------------------------+
   //|Constructor                                                       |
   //+------------------------------------------------------------------+   
   void  correlationList()
     {
     }
   //+------------------------------------------------------------------+
   //|Destructor                                                        |
   //+------------------------------------------------------------------+                        
   void ~correlationList()
     {
      this.Clear();
     }
   //+------------------------------------------------------------------+
   //|Construct Groups to Hold correlations                             |
   //+------------------------------------------------------------------+                    
   void makeGroups(int tSymbols)
     {
      for(int s=0; s<tSymbols;s++)
        {
         if(prospectArray[s].isEnabled!=true)
            continue;
         string symbol=prospectArray[s].symbol;
         string gName=symbolType(symbol);
         if(StringFind(gName,ForexGroupID,0)!=-1)
            gName=ForexGroupID;
         bool match=false;
         for(correlationGroup *j=GetFirstNode();j!=NULL;j=j.Next())
           {
            if(j.groupName==gName)
              {
               match=true;
               break;
              }
           }
         if(!match)
            this.Add(new correlationGroup(gName));

        }
     }
   //+------------------------------------------------------------------+
   //|return correlation between this element and those already trading |
   //+------------------------------------------------------------------+        
   string isCorrelated(string symCheck)
     {
      //Check what need from instrument
      string gName=symbolType(symCheck);
      bool match=false;
      if(StringFind(gName,ForexGroupID,0)!=-1)
         gName=ForexGroupID;
      for(correlationGroup *j=GetFirstNode();j!=NULL;j=j.Next())
        {
         if((j.groupName==gName) && (gName==ForexGroupID))
           {
            //--Forex
            string sym=NULL;
            bool m1=false,m2=false;
            for(int i=OrdersTotal(); i>=0; i--)
              {
               if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                 {
                  sym=OrderSymbol();
                  if(sym==symCheck) //&& (com==sCommID))
                    {
                     //-Good can check to add to order
                     return "ADD TO ORDER";
                    }
                  else
                    {
                     searchForCorrelationFX(sym,symCheck,m1,m2);
                     if(m1 || m2)
                        return ("CORRELATED with: "+sym);
                    }
                 }
              }
            return ("CAN TRADE");
           }
         else if(j.groupName==gName)
           {
            //--Other 
            string sym=NULL;
            bool m1=false,m2=false;
            for(int i=OrdersTotal(); i>=0; i--)
              {
               if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                 {
                  //find group name of OrderSymol()
                  string tradedSymbolGroupName=symbolType(OrderSymbol());
                  // Print("tradedSymbolGroupName: "+tradedSymbolGroupName+" symbol group name: "+gName);
                  if(gName==tradedSymbolGroupName)
                     return ("CORRELATED, Group Name Symbol "+gName+" Correlated Symbol Name: "+OrderSymbol()+" Group Name Correlatd Symbol: "+tradedSymbolGroupName);
                  sym=StringSubstr(OrderSymbol(),0,3);
                  symCheck=StringSubstr(symCheck,0,3);
                  if(sym==symCheck) //&& (com==sCommID))
                     //-Good can check to add to order
                     return "ADD TO ORDER";
                  else   if(((sym=="Nym") || (sym=="Bre")) && ((symCheck=="Nym") || (symCheck=="Bre")))
                     return ("CORRELATED with: "+OrderSymbol());
                  else   if(((sym=="BOB") || (sym=="BUN")) && ((symCheck=="BOB") || (symCheck=="BUN")))
                     return ("CORRELATED with: "+OrderSymbol());
                  else   if(((sym=="UST") || (sym=="US1")) && ((symCheck=="UST") || (symCheck=="US1")))
                     return ("CORRELATED with: "+OrderSymbol());
                  else   if(((sym=="XAG") || (sym=="XAU")) && ((symCheck=="XAG") || (symCheck=="XAU")))
                     return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="BTC") && (sym=="BTC"))
                     return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Cof") && (symCheck=="Cof"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Coc") && (symCheck=="Coc"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Cop") && (symCheck=="Cop"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Cor") && (symCheck=="Cor"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="NGa") && (symCheck=="NGa"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Pla") && (symCheck=="Pla"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Cot") && (symCheck=="Cot"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Soy") && (symCheck=="Soy"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Sug") && (symCheck=="Sug"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else   if((sym=="Whe") && (symCheck=="Whe"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                  else if((sym=="Pal") && (symCheck=="Pal"))//different contract number
                  return ("CORRELATED with: "+OrderSymbol());
                 }
              }
            return ("CAN TRADE");
           }
        }
      return NULL;
     }
   void searchForCorrelationFX(string symbol,string symCheck,bool &matchFirst,bool &matchSecond)
     {
      string thisThree=NULL;
      string sym1=StringSubstr(symbol,0,3),sym2=StringSubstr(symbol,3,3);
      string symCheck1=StringSubstr(symCheck,0,3),symCheck2=StringSubstr(symCheck,3,3);
      if((sym1==symCheck1) || (sym1==symCheck2))
         matchFirst=true;
      else if((sym2==symCheck1) || (sym2==symCheck2))
         matchSecond=true;
     }
   //+------------------------------------------------------------------+
   //|Log the groups discovered                                         |
   //+------------------------------------------------------------------+        
   void  ToLog(string header,bool show=true)
     {
      if(show)
        {
         s(header);
         for(correlationGroup *i=GetFirstNode();i!=NULL;i=i.Next())
            Print(i.groupName);
        }
     }
  };//end class                              
