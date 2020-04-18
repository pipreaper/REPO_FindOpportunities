//+------------------------------------------------------------------+
//|                                                    testWrite.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(FileIsExist("profit.csv",FILE_BIN ))
      bool hasDeleted =FileDelete("profit.csv");
   int handle=FileOpen("profit.csv",FILE_WRITE|FILE_CSV);
   if(handle<0)
     {
      Print(" file Open Error ");
      return;
     }
    FileWrite(handle,"symbol","wtf","ATRTF","ttf","cumProfit");
   FileClose(handle);      
  }
//+------------------------------------------------------------------+
