//+------------------------------------------------------------------+
//|                                            FilterMarketWatch.mq4 |
//|                                      Copyright 2017, nicholishen |
//|                         https://www.forexfactory.com/nicholishen |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, nicholishen"
#property link      "https://www.forexfactory.com/nicholishen"
#property version   "1.00"
#property strict
#include <Arrays\ArrayString.mqh>

class ToggleWatchList
{
protected:
   bool              m_mode;
   CArrayString      m_default;
   CArrayString      m_desired;
public:
   ToggleWatchList():m_mode(false){}
  ~ToggleWatchList()
   {
      m_mode = true;
      Toggle();
   }
   void Init(string &symbol_array[])
   {
      for(int i=0;i<SymbolsTotal(true);i++)
         m_default.Add(SymbolName(i,true));
      m_desired.AddArray(symbol_array);
   }
   void Toggle()
   {
      if(!m_mode)
      {
         for(int i=SymbolsTotal(true)-1;i>=0;i--)
            SymbolSelect(SymbolName(i,true),false);
         for(int i=0;i<m_desired.Total();i++)
         {
            for(int j=SymbolsTotal(false)-1;j>=0;j--)
            {
               if(StringFind(SymbolName(j,false),m_desired[i])>=0)
               {
                  SymbolSelect(SymbolName(j,false),true);
                  break;
               }
            }
         }
      }
      else
      {
         for(int i=SymbolsTotal(true)-1;i>=0;i--)
            SymbolSelect(SymbolName(i,true),false);
         for(int i=0;i<m_default.Total();i++)
            SymbolSelect(m_default[i],true);
      }
      m_mode= !m_mode;
   }  
};
