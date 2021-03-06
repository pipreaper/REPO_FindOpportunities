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
extern int                    drawTrades=-1;//(0) nothing,(1) Arrows,(2) 1+Lines (-1) Profit Script
extern double                 stopFactor=10;//flex ATR Stop
extern double                 targetFactor=30;//flex ATR Target;
//+------------------------------------------------------------------+
//| Global Variables Timer Aspect                                    |
//+------------------------------------------------------------------+
extern double                 equityRisk=4;// % Equity Risk / Trade % / ----for stop
extern double                 numberPairsTrade=4;//Used to set the acceptible margin
extern double                 marginPercentTotal=60;//% Total Acceptable Equity Margin                                   
                                                    //extern ENUM_TIMEFRAMES        ttf=PERIOD_H4;//The time frame used for capturing the trend && used in ATR calculations Daily
//extern ENUM_TIMEFRAMES        ATRTF=PERIOD_H1;//ATRTF: Stop, Target, Open Trade, trendIndicator
//+------------------------------------------------------------------+
//| External Variables SETUP                                         |
//+------------------------------------------------------------------+
extern int                    maxBarsDraw=5000;//max bars to draw                                              
extern color                  clrLong=clrAqua;//color of buy setup arrows
extern color                  clrShort=clrRed;//color of sell set up arrows
extern int                    fEMA=9;//params iMA
extern int                    mEMA=18;
extern int                    sEMA=38;
extern int                    ATRPeriod=14;

extern  int                   kPeriod=5;// K line period
extern  int                   dPeriod=3;// D line period
extern  int                   slowing=3;// slowing
extern  int                   method=MODE_SMA;// averaging method
extern  int                   price_field=0;//
extern  int                   lowStochLevel=20;//level cross
extern  int                   highStochLevel=80;//level cross
extern int                    adxPeriod=14;
extern int                    priceFieldADX=0;

extern int                    periodRSI=5;//RSI PARAMS
extern int                    levelRSIBottom=30;
extern int                    levelRSITop=70;
extern int                    considerationRSIHighLevel=50;
extern int                    considerationRSILowLevel = 50;
extern int                    fileHandle = 1;
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
   if(FileIsExist("profit.csv",FILE_COMMON))
      FileDelete("profit.csv");
   int handle=FileOpen("profit.csv",FILE_WRITE|FILE_CSV);
   if(handle<0)
     {
      Print(" file Open Error ");
      return;
     }
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
   TotalSymbols=ArraySize(watchSymbols);
  // ArrayResize(currTimeCandles,TotalSymbols);
   string symbol=NULL;
   int wtf=NULL;
   FileWrite(handle,"symbol","wtf","ATRTF","ttf","cumProfit");
//********* NOT YET INCLUDING GO AROUND ATRTF,TTF **************** /
   for(int i=0; i< sizePeriods-3; i++)//Around all periods from 5 mins to 4 hrly    
     {
      wtf=PERIOD_M15;//tfEnumWTFs[i];
      ENUM_TIMEFRAMES enum0=tfEnumFull[findIndexPeriod(wtf)],enum1=tfEnumFull[findIndexPeriod(wtf)+1],enum2=tfEnumFull[findIndexPeriod(wtf)+2],enum3=tfEnumFull[findIndexPeriod(wtf)+3];
      ENUM_TIMEFRAMES ATRTF=enum2;
      ENUM_TIMEFRAMES ttf=enum3;
    //  Print("ATRTF ",ATRTF," ttf ",ttf);
     for(int j=0; j<=TotalSymbols-1; j++)//Around all Instruments
        {
         symbol=watchSymbols[j];//"NZDUSDSB";//
         cumProfit=0;
         cumProfit=iCustom(symbol,wtf,"trendIndicator",drawTrades,stopFactor,targetFactor,equityRisk,numberPairsTrade,marginPercentTotal,ttf,ATRTF,maxBarsDraw,clrLong,clrShort,fEMA,mEMA,sEMA,ATRPeriod,kPeriod,dPeriod,slowing,method,price_field,lowStochLevel,highStochLevel,adxPeriod,priceFieldADX,periodRSI,levelRSIBottom,levelRSITop,considerationRSIHighLevel,considerationRSILowLevel,fileHandle,6,0);
         FileWrite(handle,symbol,wtf,ATRTF,ttf,cumProfit);
         Print(symbol," wtf: ",wtf," ATRTF: ",ATRTF," ttf: ",ttf," Cumulative Profit: ",cumProfit);
        }
     }
   FileClose(handle);
   Print("**** DONE *****");
  }
//+------------------------------------------------------------------+
