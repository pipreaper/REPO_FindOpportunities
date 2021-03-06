//+------------------------------------------------------------------+
//                                             trendLoadHistData.mq4 |
//|                                    Copyright 2016, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
#property strict 
#include <WaveLibrary.mqh>
//+------------------------------------------------------------------+
//| Set Up indicator                                                 |
//+------------------------------------------------------------------+
extern int                    drawTrades=-2;//(0) nothing,(1) Arrows,(2) 1+Lines (-1) Profit Script
extern double                 stopFactor=1;//stop
extern double                 targetFactor=6;//target
//+------------------------------------------------------------------+
//| Global Variables Timer Aspect                                    |
//+------------------------------------------------------------------+
extern bool                   isTesting=true;//true for test data array in waveLibrary
extern double                 equityRisk=4;// % Equity Risk / Trade % / ----for stop
extern double                 numberPairsTrade=4;//Used to set the acceptible margin
extern double                 marginPercentTotal=60;//% Total Acceptable Equity Margin                                   
extern int                    watchFill=25;//#prime instruments to consider
extern ENUM_TIMEFRAMES        wtf=PERIOD_M15;//The time frame upon which trades wil be made
extern ENUM_TIMEFRAMES        ttf=PERIOD_H4;//The time frame used for capturing the trend && used in ATR calculations Daily
extern ENUM_TIMEFRAMES        ATRTF=PERIOD_H1;//ATRTF: Stop, Target, Open Trade, trendIndicator
double marginPerInstrument=marginPercentTotal/numberPairsTrade;
extern int                    refusalTradeTimeHours=8;//History Back off after trade Refusal Hours
//+------------------------------------------------------------------+
//| External Variables SETUP                                         |
//+------------------------------------------------------------------+
extern int                    maxBarsDraw=5000;//max bars to draw                                              
extern color                  clrLong=clrAqua;//color of buy setup arrows
extern color                  clrShort=clrRed;//color of sell set up arrows
                                              //MA
extern int                    fEMA=9;
extern int                    mEMA=18;
extern int                    sEMA=38;
extern int                    ATRPeriod=14;
//STK
extern int                    kPeriod=5;// K line period
extern int                    dPeriod=3;// D line period
extern int                    slowing=3;// slowing
extern int                    method=MODE_SMA;// averaging method
extern int                    price_field=0;
extern int                    lowStochLevel=20;
extern int                    highStochLevel=80;
extern int                    adxPeriod=14;
extern int                    priceFieldADX=0;
//RSI
extern int                    periodRSI=5;
extern int                    levelRSIBottom=30;
extern int                    levelRSITop=70;
extern int                    considerationRSIHighLevel=50;
extern int                    considerationRSILowLevel = 50;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES tfEnumWTFs[8]={PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
int sizePeriods=ArraySize(tfEnumWTFs);
int minBars=60;
int TotalSymbols;
double cumProfit=NULL;
//string Symbols[1000];
string watchSymbols[1000];
//string Descr[1000];
//datetime currTimeCandles[1][8]; //    <<<<<<<<<  <<<<<<<< <<<<<<<<<  <<<<<<<<  ****************   (((( 9 ))))
//+------------------------------------------------------------------+
//|OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| OnStart                                                                 |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(FileIsExist("profit.csv",FILE_BIN))
      bool hasDeleted=FileDelete("profit.csv");
   int fileHandle=FileOpen("profit.csv",FILE_WRITE|FILE_CSV,';');
   if(fileHandle<0)
     {
      Print(" file Open Error ");
      return;
     }
   if(!isTesting)
     {
      TotalSymbols=FindSymbols();
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
     }
   else
     {
      for(int j=0; j<=ArraySize(tempSymbolsArray)-1; j++)
         watchSymbols[j]=tempSymbolsArray[j];
      ArrayResize(watchSymbols,ArraySize(tempSymbolsArray));
     }

   TotalSymbols=ArraySize(watchSymbols);
// ArrayResize(currTimeCandles,TotalSymbols);
   string symbol=NULL;
   bool hasWritten=FileWrite(fileHandle,"symbol","wtf","ATRTF","ttf","MaxDrawDown","CSI","CUM PROFIT");
//********* NOT YET INCLUDING GO AROUND ATRTF,TTF **************** /
   for(int j=0; j<=TotalSymbols-1; j++)//Around all Instruments
     {
  //    int indicatorsTotal=-1; int res=-1; string shortName=NULL; bool isRemoved = false; int window = 0;string indicatorName=NULL;
      symbol=watchSymbols[j];//"NZDUSDSB";
      for(int i=0; i<sizePeriods-3; i++)//Around all periods from 5 mins to 4 hrly    
       {
         wtf=tfEnumWTFs[i];//PERIOD_M15;//
         ENUM_TIMEFRAMES enum0=tfEnumFull[findIndexPeriod(wtf)],enum1=tfEnumFull[findIndexPeriod(wtf)+1],enum2=tfEnumFull[findIndexPeriod(wtf)+2],enum3=tfEnumFull[findIndexPeriod(wtf)+3];
         ATRTF=enum2;
         ttf=enum3;
         cumProfit=0;

         cumProfit=iCustom(symbol,wtf,"trendIndicator",drawTrades,stopFactor,targetFactor,equityRisk,numberPairsTrade,marginPercentTotal,ttf,ATRTF,maxBarsDraw,clrLong,clrShort,fEMA,mEMA,sEMA,ATRPeriod,kPeriod,dPeriod,slowing,method,price_field,lowStochLevel,highStochLevel,adxPeriod,priceFieldADX,periodRSI,levelRSIBottom,levelRSITop,considerationRSIHighLevel,considerationRSILowLevel,6,0);
      //   shortName= "trendIndicator: ";
     //    window=ChartWindowFind();
      //   indicatorName=ChartIndicatorName(0,0,1);
      //   indicatorsTotal = ChartIndicatorsTotal(0,0);
      //   res=ChartIndicatorDelete(0,window,indicatorName);
         //--- Analyse the result of call of ChartIndicatorDelete()
         //if(!res)
         //  {
         //   Print(shortName," ",window," Indicator name",indicatorName," Indicators Total: ",indicatorsTotal, " Get Last Error ",GetLastError());
         //  }
         //Print("isRemoved ",isRemoved);
         bool hasWrittten=FileWrite(fileHandle,symbol,wtf,ATRTF,ttf,cumProfit);
         Print(hasWritten," ",symbol," wtf: ",wtf," ATRTF: ",ATRTF," ttf: ",ttf," Cumulative Profit: ",cumProfit);
        }
     }
   FileClose(fileHandle);
   Print("**** DONE *****");
  }
//+------------------------------------------------------------------+
