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
//--NOTES:
//--(1) Constant spread
//--(2) No allowance for increase decreas in available margin
#include <WaveLibrary.mqh>
#include <SymbolsInfo.mqh> 
#include <ROB_CLASS_FILES\SimObject.mqh> //link to e_globals.mqh
int TotalSymbols=NULL;

simObject *sObj=NULL;
//static extern int                    watchFill=25;                     
//static extern sortBy                 ttfSort=CSI;// variable to sort trending tf. DEFAULT CSI
//static extern sortBy                 wtfSort=CSI;//sort the wtf by CSI
//static extern int                    refusalTradeTimeHours=8;//currently not used ->History Back off after MQL4TradeQ Refusal Hours
//static extern int                    magicNumber=20050333;
//static extern int                    wtfIndex=0;
//static extern int                    ttfIndex=1;
//static extern int                    balkSetupHours=20;
//static extern int                    balkTriggerHours=2;                      
//+------------------------------------------------------------------+
//| Extern Global Variables Timer Aspect                             |
//+------------------------------------------------------------------+
extern int                    e_watchFill=25;
extern sortBy                 e_ttfSort=CSI;// variable to sort trending tf. DEFAULT CSI
extern sortBy                 e_wtfSort=CSI;//sort the wtf by CSI
extern int                    e_refusalTradeTimeHours=8;//currently not used ->History Back off after MQL4TradeQ Refusal Hours
extern int                    e_magicNumber=20050333;
extern int                    e_wtfIndex=0;
extern int                    e_ttfIndex=1;
extern int                    e_balkSetupHours=20;
extern int                    e_balkTriggerHours=2;
//+------------------------------------------------------------------+
//| Extern Global Variables simObject setup                          |
//+------------------------------------------------------------------+
extern int                    e_drawTrades=2;//e_drawTrades=-2;//(0) nothing,(1) Arrows,(2) 1+Lines (-1) Profit Script 
extern int                    e_signature= 1;//<0 adjust margins by factor,  or ignore factor (unlimed margin!)
extern int                    e_maxBars=2000; //limit shift operations to speed up run time
extern bool                   e_useMaxBars=true; //plot (trendIndicatorI),and analysis is false, since want to see all data
extern bool                   e_isTesting=false;//-- will open a BUY at market at shift=0: assumption being  shift=1 was set to buy: Used to inspect trade opens
extern bool                   e_isBuyTest=true;
extern ENUM_TIMEFRAMES        e_enumHTFWTFFilter=PERIOD_CURRENT;
extern ENUM_TIMEFRAMES        e_enumHTFTrendFilter=PERIOD_D1;//HTF trend filter
extern ENUM_TIMEFRAMES        e_enumHTFContraWaveFilter=PERIOD_H1;//wave pullback filter
extern ENUM_TIMEFRAMES        e_enumHTFATRWaveFilter=PERIOD_H1;//ATRTF: Stop, Target, Open Trade, trendIndicator & Expert
extern ENUM_TIMEFRAMES        e_enumHTFTerminateFilter=PERIOD_H1;//HTF exit filter change trend
extern double                 e_betPoundThreshold=0.1; //cannot open if calculated betNumPounds below this proportion   
extern double                 e_wtfSpreadPercent=0.15;//fraction of spread money for the bet that cannot be exceded if setInstrumentsInWTF passes in simObject
extern int                    e_ATRPeriod=14;//ATR period
extern double                 e_stopFactor=3;//flex ATR Stop
extern double                 e_targetFactor=6;//flex ATR Target;
extern int                    e_ADXPeriod=14;
extern int                    e_ADXRAGO=14;
//+------------------------------------------------------------------+
//| Variables Timer Aspect                                           |
//+------------------------------------------------------------------+
extern double                 e_equityRisk=2;// % Equity Risk / Trade % / ----for stop
extern double                 e_numberPairsTrade=10;//Used to set the acceptible margin
extern double                 e_marginPercentTotal=75;//% Total Acceptable Equity Margin    
//+-------------------------------------------------------------------+
//|HTF_ALL_SEP_VOL_PERCENTILE_WAVE                                    |
//+-------------------------------------------------------------------+
extern volume_price           e_vp=PINCH;//type of volume to draw
extern double                 e_lowerPercentile=5;//low percent
extern double                 e_lowerMiddlePercentile=20;//lower middle Percentile
extern double                 e_middlePercentile=50;//middle percentile
extern double                 e_upperMiddlePercentile=90;//****** should be 90 upper Middle Percentile
extern double                 e_upperPercentile=98;//upper percentile 98
extern double                 e_wavePts=0;//0.5 points is 50 on SP500 / zero auto scale
extern bool                   e_drawLines=false;//percentile vol lines
extern bool                   e_showData=false;//show volume data on indicator 
double cumProfit=NULL;
//+------------------------------------------------------------------+
//|OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!((e_enumHTFWTFFilter>e_enumHTFTerminateFilter) && (e_enumHTFWTFFilter<=e_enumHTFContraWaveFilter) && (e_enumHTFWTFFilter<=e_enumHTFTrendFilter)))
     {
      if(e_enumHTFWTFFilter>e_enumHTFTerminateFilter)
        {
         Print(__FUNCTION__," FAILED e_enumHTFWTFFilter>enumHTFTerminateFilter: ",(e_enumHTFWTFFilter>e_enumHTFTerminateFilter)," e_enumHTFWTFFilter: ",e_enumHTFWTFFilter," enumHTFTrendFilter: ",e_enumHTFTrendFilter," enumHTFContraWaveFilter: ",e_enumHTFContraWaveFilter," enumHTFTerminateFilter: ",e_enumHTFTerminateFilter);
         return (INIT_FAILED);
        }
      else if(e_enumHTFWTFFilter>e_enumHTFContraWaveFilter)
        {
         Print(__FUNCTION__," FAILED e_enumHTFWTFFilter>enumHTFContraWaveFilter:",(e_enumHTFWTFFilter>e_enumHTFContraWaveFilter)," e_enumHTFWTFFilter: ",e_enumHTFWTFFilter," enumHTFTrendFilter: ",e_enumHTFTrendFilter," enumHTFContraWaveFilter: ",e_enumHTFContraWaveFilter," enumHTFTerminateFilter: ",e_enumHTFTerminateFilter);
         return (INIT_FAILED);
        }
      else if(e_enumHTFWTFFilter>e_enumHTFTrendFilter)
        {
         Print(__FUNCTION__," FAILED e_enumHTFWTFFilter<=enumHTFTrendFilter: ",(e_enumHTFWTFFilter>e_enumHTFTrendFilter)," e_enumHTFWTFFilter: ",e_enumHTFWTFFilter," enumHTFTrendFilter: ",e_enumHTFTrendFilter," enumHTFContraWaveFilter: ",e_enumHTFContraWaveFilter," enumHTFTerminateFilter: ",e_enumHTFTerminateFilter);
         return (INIT_FAILED);
        }
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| OnStart                                                          |
//+------------------------------------------------------------------+
void OnStart()
  {
   string fgName=symbolType(Symbol());
// string prefix=NULL;
// int g=0;
// do
//   {
//    g+=g;
//    fgName=symbolType(Symbol());
//    if((fgName!=NULL) || (g>5))
//       break;
//    Sleep(2);
//   }
// while(fgName==NULL);
// if(fgName==NULL)
//   {
//    prefix="BULL: "+Symbol()+" "+string(Period());
//    Print(prefix);
//   }
// string fileName=prefix+"cumulative Profit^"+Symbol()+"^"+fgName+"^"+string(Period())+".csv";
// if(FileIsExist(fileName,FILE_COMMON))
//    FileDelete(fileName);
// int handle=FileOpen(fileName,FILE_WRITE|FILE_CSV);
// if(handle<0)
//   {
//    Print(" file Open Error ");
//    return;
//   }
// string symbol=NULL;
// int wtf=NULL;
//FileWrite(handle,"symbol","wtf","ATRTF","ttf","group","cumProfit");

//set simulation Object to use e_ files to drive it
   sObj=new simObject(
                      e_drawTrades,
                      e_signature,
                      e_maxBars,
                      e_useMaxBars,
                      e_isTesting,
                      e_isBuyTest,
                      e_wtfIndex,
                      e_ttfIndex,
                      e_enumHTFWTFFilter,
                      e_enumHTFTrendFilter,
                      e_enumHTFContraWaveFilter,
                      e_enumHTFATRWaveFilter,
                      e_enumHTFTerminateFilter,
                      e_betPoundThreshold,
                      e_wtfSpreadPercent,
                      e_ATRPeriod,
                      e_stopFactor,
                      e_targetFactor,
                      e_ADXPeriod,
                      e_ADXRAGO,
                      e_equityRisk,
                      e_numberPairsTrade,
                      e_marginPercentTotal,
                      e_vp,
                      e_lowerPercentile,
                      e_lowerMiddlePercentile,
                      e_middlePercentile,
                      e_upperMiddlePercentile,
                      e_upperPercentile,
                      e_wavePts,
                      e_drawLines,
                      e_showData
                      );
   sObj.fillMarketWatch(e_isTesting);
   sObj.initEnabled(e_isTesting);
   sObj.runtimeEnabled(e_isTesting);

   for(int i=0; i<sObj.totalSymbols;i++)
     {
      if(prospectArray[i].isEnabled)
        {
         sObj.testBuy(prospectArray[i].symbol,prospectArray[i].desc,0);
         //   FileWrite(handle,symbol,enumHTFWTFFilter,ATRPeriod,enumHTFTrendFilter,fgName,cumProfit);
         Print(prospectArray[i].symbol," PERIOD_CURRENRT: ",e_enumHTFWTFFilter," ATRTF: ",e_ATRPeriod," ttf: ",e_enumHTFTrendFilter," fileGroup ",fgName," Cumulative Profit: ",cumProfit);
        }
     }
//   FileClose(handle);
////used to close terminal in batch run
//   handle=FileOpen("dummy.txt",FILE_WRITE|FILE_CSV);
//   FileClose(handle);
   delete(sObj);
   Print("**** DONE *****");
  }
//+------------------------------------------------------------------+
