//+------------------------------------------------------------------+
//|                                                      profits.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <CSIBuildingBlocks.mqh>

bool   drawTrades=false;
double stopFactor=3;
double targetFactor=6;
int     maxBarsDraw=5000;
color   clrLong=clrBlue;
color   clrShort=clrYellow;
//+-------------------------------------------------------------------+
//| Global variables HTFs                                            |
//+-------------------------------------------------------------------+
int     fEMA=9;
int     mEMA=18;
int     sEMA=38;

//+-------------------------------------------------------------------+
//| Global variables Mileage                                          |
//+-------------------------------------------------------------------+
int     ATRPeriod=14;
//+-------------------------------------------------------------------+
//| Global variables Stochastic                                       |
//+-------------------------------------------------------- ----------+
int    kPeriod=5;          // K line period
int    dPeriod=3;         // D line period
int    slowing=3;         // slowing
int    method=MODE_EMA;           // averaging method
int    price_field=0;
int    lowStochLevel=20;
int    highStochLevel=80;
//+-------------------------------------------------------------------+
//| Global variables ADX                                              |
//+-------------------------------------------------------------------+
int     adxPeriod=14;
int     priceFieldADX=0;

ENUM_TIMEFRAMES local_tfEnum[]={PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4};
string watchSymbols[1000];
double cumProfit=NULL;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(FileIsExist("profit.csv",FILE_COMMON))
      FileDelete("profit.csv");
   int handle=FileOpen("profit.csv",FILE_WRITE|FILE_CSV);
   if(handle<0)
     {
      Print(" file Open Error ");
      return;
     }
   FileWrite(handle,"symbol","tf","cumProfit");
   int sizePeriods=ArraySize(local_tfEnum);
   int howManySymbols=-1;
   bool isTesting=false;
   int TotalSymbols=NULL;
   TotalSymbols=FindSymbols();
   fillMarketWatch(TotalSymbols,isTesting);
   do
     {
      howManySymbols=SymbolsTotal(true);
      s("Status: "+"Waiting for Watch Symbol Population"+" TotalSymbols: "+string(TotalSymbols)+" soFar: "+string(howManySymbols)+".....",showStatusTerminal);
      // Sleep(2000);
     }
   while(TotalSymbols!=howManySymbols);

   int s=0;
   for(int j=0; j<=TotalSymbols-1; j++)//Around all Instruments
     {
      if(!IsSymbolInMarketWatch(Symbols[j]))
         continue;
      //     Print(Symbols[j]," ",j);
      watchSymbols[s]=Symbols[j];
      s++;
     }
   ArrayResize(watchSymbols,s);
   TotalSymbols=ArraySize(watchSymbols);

   Print("* TOTAL SYMBOLS *:  ",TotalSymbols);
// Print Profits
   string symbol=NULL;//"GBPUSDSB";
   int tf=NULL;//PERIOD_M15;

   for(int i=0; i<=sizePeriods-1; i++)//Around all periods from 5 mins to 4 hrly    
     {
      tf=tfEnum[i];
      for(int j=0; j<=TotalSymbols-1; j++)//Around all Instruments
        {
         symbol=watchSymbols[j];
         cumProfit=iCustom(symbol,tf,"trendIndicator",drawTrades,stopFactor,targetFactor,maxBarsDraw,clrLong,clrShort,fEMA,mEMA,sEMA,ATRPeriod,kPeriod,dPeriod,slowing,method,price_field,lowStochLevel,highStochLevel,adxPeriod,priceFieldADX,6,1);
         FileWrite(handle,symbol,tf,cumProfit);
         Print(symbol," ",tf," Cumulative Profit: ",cumProfit);
        }
     }
   FileClose(handle);
  }
//+------------------------------------------------------------------+
