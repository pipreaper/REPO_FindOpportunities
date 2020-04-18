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
#include <instrument.mqh>

//+------------------------------------------------------------------+
//| Set Up indicator                                                 |
//+------------------------------------------------------------------+
extern bool drawTrades=false;
extern double stopFactor=3;
extern double targetFactor=6;//20;
//+------------------------------------------------------------------+
//| Global Variables Timer Aspect                                    |
//+------------------------------------------------------------------+
extern double                 equityRisk=4;// % Equity Risk / Trade % / ----for stop
extern double                 numberPairsTrade=4;//Used to set the acceptible margin
extern double                 marginPercentTotal=60;//% Total Acceptable Equity Margin                                   
extern sortBy                 ttfSort=CSI;// variable to sort trending tf. DEFAULT CSI
extern sortBy                 wtfSort=CSI;//sort the wtf by CSI
extern int                    watchFill=1;//#prime instruments to consider
extern ENUM_TIMEFRAMES        wtf=PERIOD_M15;//The time frame upon which trades wil be made
extern ENUM_TIMEFRAMES        ttf=PERIOD_H4;//The time frame used for capturing the trend && used in ATR calculations Daily
extern ENUM_TIMEFRAMES        ATRTF=PERIOD_H1;//Used SP,TT trendIndicator & open Trade
double marginPerInstrument=marginPercentTotal/numberPairsTrade;
extern int                    refusalTradeTimeHours=8;//History Back off after trade Refusal Hours
//+------------------------------------------------------------------+
//| External Variables SETUP                                         |
//+------------------------------------------------------------------+
extern int                    maxBarsDraw=5000;//max bars to draw                                              
extern color                  clrLong=clrAqua;//color of buy setup arrows
extern color                  clrShort=clrRed;//color of sell set up arrows
extern int                    fEMA=9;
extern int                    mEMA=18;
extern int                    sEMA=38;
extern int                    ATRPeriod=14;
extern  int                   kPeriod=5;          // K line period
extern  int                   dPeriod=3;         // D line period
extern  int                   slowing=3;         // slowing
extern  int                   method=MODE_EMA;           // averaging method
extern  int                   price_field=0;
extern  int                   lowStochLevel=20;
extern  int                   highStochLevel=80;
extern int                    adxPeriod=14;
extern int                    priceFieldADX=0;

extern int                    periodRSI=5;
extern int                    levelRSIBottom=30;
extern int                    levelRSITop=70;
extern int                    considerationRSIHighLevel=50;
extern int                    considerationRSILowLevel = 50;
double acceptableMargin=(marginPerInstrument/100)*AccountEquity();//The margin to allocate per instrument 
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

//remove after checking
//   FileClose(handle);



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

               // for(int i=0; i<=sizePeriods-1; i++)//Around all periods from 5 mins to 4 hrly    
// {
   tf=PERIOD_M15;//tfEnum[i];
                 //for(int j=0; j<=TotalSymbols-1; j++)//Around all Instruments
//{
   symbol="NAS100_SB";//watchSymbols[j];    
   cumProfit= 0;
  // for(int t=60; t>0; t--) // 20 Days   
    // {
      cumProfit+=iCustom(symbol,tf,"trendIndicator",drawTrades,stopFactor,targetFactor,equityRisk,numberPairsTrade,marginPercentTotal,ttf,ATRTF,maxBarsDraw,clrLong,clrShort,fEMA,mEMA,sEMA,ATRPeriod,kPeriod,dPeriod,slowing,method,price_field,lowStochLevel,highStochLevel,adxPeriod,priceFieldADX,periodRSI,levelRSIBottom,levelRSITop,considerationRSIHighLevel,considerationRSILowLevel,6,0);
      Print(" cumProfit ",cumProfit);
  //   }

   FileWrite(handle,symbol,tf,cumProfit);
   Print(symbol," ",tf," Cumulative Profit: ",cumProfit);
//   }
//  }
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|OnDeInit                                                |
//+------------------------------------------------------------------+  
//void OnDeinit(const int reason)
//{
//if(reason !=0)
// FileWrite(handle,symbol,tf,cumProfit);  
//}
//+------------------------------------------------------------------+
