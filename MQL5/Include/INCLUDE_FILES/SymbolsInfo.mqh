//+------------------------------------------------------------------+
//|                                                  SymbolsInfo.mqh |
//|                                    Copyright 2018, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      "https://www.mql5.com"
#include <INCLUDE_FILES\SymbolsInfo.mqh>
//+------------------------------------------------------------------+
//|Get the Brokers Group Name for the Symbol                         |
//+------------------------------------------------------------------+        
string symbolType(string symbol)
  {
   string path=NULL;
   if(SymbolInfoString(symbol,SYMBOL_PATH,path))
      return StringSubstr(path,0,StringLen(path)-(StringLen(symbol)+1));
   //else
   //  {
   //   ResetLastError();
   //   Alert("Cannot Find: ",symbol," Path, Error: "+ErrorDescription(GetLastError()));
   //  }
   return path;
  }
//+------------------------------------------------------------------+
