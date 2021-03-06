//+------------------------------------------------------------------+
//|                                                 writeSymbolsData |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Select deltaTime: This is used to update the values in trending TF and thus wtf...." 
#property description "Select ttf: This is used for overall Symbol Selection trend and ATR..." 
#property description "Select wtf: This is used for population of the symbols monitored for activation of trading..." 
#property description "...could every 5 minutes could be daily" 
#property description "Makes sense to run the EA on EURUSD (always ticking)" 
#property description "Run the EA on 15 minute time frame then a new bar tick will be processed every 15 Minutes..." 
//"for each instrument in the n list." 
// "Makes no sense to have chart new bars < update interval."  
//"EURUSD will only appear in the top n list if it is in the top n!" 
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
//#include <CSITFLists.mqh>
#include <setUp.mqh>
//#include <tradelogic.mqh>
#include <status.mqh>
//+------------------------------------------------------------------+
//| Set Up indicator                                                 |
//+------------------------------------------------------------------+
extern bool                   drawTrades=false;
extern double                 stopFactor=3;
extern double                 targetFactor=6;//20;
//+------------------------------------------------------------------+
//| Global Variables Timer Aspect                                    |
//+------------------------------------------------------------------+
extern bool                   isTesting=false;//true for test data array in waveLibrary
extern double                 equityRisk=4;// % Equity Risk / Trade % / ----for stop
extern double                 numberPairsTrade=4;//Used to set the acceptible margin
extern double                 marginPercentTotal=60;//% Total Acceptable Equity Margin                                   
extern sortBy                 ttfSort=CSI;// variable to sort trending tf. DEFAULT CSI
extern sortBy                 wtfSort=CSI;//sort the wtf by CSI
extern int                    watchFill=25;//#prime instruments to consider
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

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
double acceptableMargin=(marginPerInstrument/100)*AccountEquity();//The margin to allocate per instrument                                                       
int indPeriod=                14;//Period
int adxAgo=                   14;//Period
int maxBars=10;
int TotalSymbols;
int tfApplies[2];
int wtfIndex =                0;//index in list of working time frame
int ttfIndex =                1;//index in list of trending time frame
ENUM_TIMEFRAMES tfEnumWTFs[8]={PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
int sizePeriods=ArraySize(tfEnumWTFs);
string fName=NULL;
int fileHandle=-1;
int numBars=-1;
//int minBars=60;

//double cumProfit=NULL;
//string Symbols[1000];
string watchSymbols[1000];
//string Descr[1000];
//datetime currTimeCandles[1][8]; //    <<<<<<<<<  <<<<<<<< <<<<<<<<<  <<<<<<<<  ****************   (((( 9 ))))
//+------------------------------------------------------------------+
//|OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Start: ",TimeGMT());
   fName="CSIs_"+string(wtf);
   if(FileIsExist(fName,FILE_BIN))
      bool hasDeleted=FileDelete(fName);
   fileHandle=FileOpen(fName,FILE_WRITE|FILE_CSV,';');
   if(fileHandle<0)
     {
      Print(" file Open Error ");
      return INIT_FAILED;
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
   symbolLists=new tfList();   
   symbolLists.setTFInList(wtf,ttf);  
   TotalSymbols=ArraySize(watchSymbols);   
   setUpTFArray(tfEnumFull,tfApplies,wtf,ttf);      
   //Need to put in some instruments to go around
   symbolLists.setInstrumentsInTTF(TotalSymbols,Symbols,Descr,tfApplies,indPeriod,adxAgo,maxBarsDraw,equityRisk,acceptableMargin,isTesting,1,tempSymbolsArray);    
   symbolLists.ToLog(1);
   
   Print("Done load watch Symbols: ",TimeGMT());

   bool hasWritten=FileWrite(fileHandle,"Period","Symbol","CSI");

// symbolLists.sort(wtfSort,wtfIndex);
//*** Now get the History data
   numBars=20;//Bars-adxPeriod;
   Print("numBars: ",TimeGMT());
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| OnStart                                                                 |
//+------------------------------------------------------------------+
void OnStart()
  {
//GET THE INSTRUMENTS HARD COPY TO WORK WITH ... PROBLEM FUTURES!!
   instrumentList *i=symbolLists.GetNodeAtIndex(ttfIndex);
      Print("TOTAL SYMBOLS TTF: ",i.Total()); 
// GET ALL RATES THAT YOUU WANT TO INVESTIGATE
   MqlRates rates[];
   int copied=CopyRates(NULL,wtf,0,numBars,rates);
   if(copied<=0)
      Print("Error copying price data ",GetLastError());
   else Print("Copied ",ArraySize(rates)," bars ",TimeGMT());
   for(int r = 0; r < numBars;  r++)
     {
      datetime t=rates[r].time;
      Print("time[r]: ",rates[r].time, " r: ",r);
      for(instrument *j=i.GetFirstNode();j!=NULL;j=j.Next())
        {
         Print("symbol: ",j.symbol);
         datetime timeHist=TimeGMT();
         //        symbolLists.setInstrumentsInTTF(TotalSymbols,Symbols,Descr,tfApplies,indPeriod,adxAgo,maxBarsDraw,equityRisk,acceptableMargin,isTesting,ttfIndex,tempSymbolsArray);
         // sort the trending time frame list
         //--Put the symbols selected by required margin in the ttf list

         //symbolLists.setInstrumentsInTTF(TotalSymbols,Symbols,Descr,tfApplies,indPeriod,adxAgo,maxBarsDraw,equityRisk,acceptableMargin,isTesting,r,tempSymbolsArray);         
         j.setVariableData(ttf,adxPeriod,adxAgo,equityRisk,acceptableMargin,r);
         symbolLists.sort(ttfSort,ttfIndex);
         //reduce to sensible amount to process
         //symbolLists.shorten(watchFill,ttfIndex);
         //--xfer the prospects to the wtf
         //+-----------------------------------------------------------------------------------+
         //| createWTF: add instruments to wtf from ttf checking for:                          |
         //| *** THESE ARE SYSTEM TRADING DECISIONS                                            |      
         //| (1). Capped Spread < cappedATRMoney                                               |
         //| (2). £ Bet is < cappedATRMoney                                                    |
         //| (3). £ The margin required for the pounds bet < margin wanted                     |   
         //|      if its not then make it so at a cost of reducing the profit per point        |
         //|  NO! Do in Expert (4). Check that the instruments that you add are not correlated |
         //+-----------------------------------------------------------------------------------+          
         symbolLists.setInstrumentsInWTF(Symbols,Descr,tfApplies,indPeriod,adxAgo,equityRisk,acceptableMargin,wtfIndex,ttfIndex,refusalTradeTimeHours);
         j.setVariableData(wtf,adxPeriod,adxAgo,equityRisk,acceptableMargin,r);         
         //sort wtf by csi, miniumum spread or other variable as required
         symbolLists.sort(wtfSort,wtfIndex);
         //UPDATE CSI
        // j.setVariableData(wtf,adxPeriod,adxAgo,maxBars,equityRisk,acceptableMargin,r);
         double secs=getElapsedTimeSecs(TimeGMT(),timeHist);
         Print("Calc Elapsed Time, seconds: ",ND(secs,0));
        }
      int count=0;
      //for(instrument *j=i.GetFirstNode();j!=NULL;j=j.Next())
      for(instrument *j=i.GetLastNode();j!=NULL;j=j.Prev())
        {
         j.countOccurance++;
         Print("Date: ",rates[r].time," Symbol: ",j.symbol," CSI: ",ND(j.csi,0));
         bool hasWritten=FileWrite(fileHandle,rates[r].time,j.symbol,ND(j.csi,0));
         if(count>watchFill)
            break;
         count++;
        }
     }
   Print("Done set Instruments: ",TimeGMT());
   Print(" ");
   for(instrument *j=i.GetFirstNode();j!=NULL;j=j.Next())
      Print(j.symbol," ",j.countOccurance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete(symbolLists);
   FileClose(fileHandle);
   Print("**** DONE *****");
  }
//+------------------------------------------------------------------+
