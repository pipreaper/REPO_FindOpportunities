//+------------------------------------------------------------------+
//|                                                      readCSV.mq5 |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   bool status=false;
   string fileName=convertSymbolsFileText(symbolsFile);
   ReadStringFile symbolsFileObj;
//Read the file
   if(symbolsFileObj.fileInit(fileName))
     {
      if(symbolsFileObj.readSymbolsList(symbolsList))
         status=true;
      else
         status=false;
     }
   else
     {
      Print("*WARNING: ",__FUNCTION__," Failed to read Symbols");
      //failed to open dont need to close!      
      return false;
     }
   symbolsFileObj.fileClose();
   return status;
  }
//+------------------------------------------------------------------+
