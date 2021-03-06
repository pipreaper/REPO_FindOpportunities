//+------------------------------------------------------------------+
//                                           batchGenSymbolsData.mq4 |
//|                                    Copyright 2018, Robert Baptie |
//| used to close terminal in batch run                              | 
//| processes one Symbol and one period from batch request ONLY      | 
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
#property strict 
#property script_show_inputs
//--NOTES:
//--(1) Constant spread
//--(2) No allowance for increase decrease in available margin
#include <WaveLibrary.mqh>
#include <SymbolsInfo.mqh> 
#include <instrument.mqh> 
//#include <ROB_CLASS_FILES\SimObject.mqh> //link to e_globals.mqh
//int TotalSymbols=NULL;
string fileName=NULL;
string fgName=NULL;
int handle2=NULL;
//+------------------------------------------------------------------+
//| Extern Global Variables Timer Aspect                             |
//+------------------------------------------------------------------+
//simObject *sObj=NULL;
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
extern int                    e_drawTrades=-3;//-2;//e_drawTrades=-2;//(0) nothing,(1) Arrows,(2) 1+Lines (-1) Profit Script 
extern int                    e_signature=0;//<0 adjust margins by factor,  or ignore factor (use wanted if can or minimum if cannot!)
extern int                    e_maxBars=2000; //limit shift operations to speed up run time
extern bool                   e_useMaxBars=false; //plot (trendIndicatorI),and analysis is false, since want to see all data
extern bool                   e_isTesting=false;//-- true for batch gen results and overriden in call to trendIndicator below, will open a BUY at market at shift=0: assumption being  shift=1 was set to buy: Used to inspect trade opens
extern bool                   e_isBuyTest=true;//-- if e_isTesting then is it a B/S test?
extern ENUM_TIMEFRAMES        e_enumHTFWTFFilter=PERIOD_CURRENT;//WTF
extern ENUM_TIMEFRAMES        e_enumHTFTrendFilter=PERIOD_D1;//HTF trend filter
extern ENUM_TIMEFRAMES        e_enumHTFContraWaveFilter=PERIOD_H1;//e_enumHTFContraWaveFilter: wave pullback filter
extern ENUM_TIMEFRAMES        e_enumHTFATRWaveFilter=PERIOD_H1;//e_enumHTFATRWaveFilter: ATRTF: Stop, Target, Open Trade, trendIndicator & Expert
extern ENUM_TIMEFRAMES        e_enumHTFTerminateFilter=PERIOD_H1;//e_enumHTFTerminateFilter: HTF exit filter change trend
extern double                 e_betPoundThreshold=0.1; //e_betPoundThreshold: cannot open if calculated betNumPounds below this proportion   
extern double                 e_wtfSpreadPercent=0.15;//e_wtfSpreadPercent: fraction of spread money for the bet that cannot be exceded if setInstrumentsInWTF passes in simObject
extern int                    e_ATRPeriod=14;//e_ATRPeriod:ATR period
extern double                 e_stopFactor=3;//e_stopFactor: flex ATR Stop
extern double                 e_targetFactor=40;//e_targetFactor: flex ATR Target;
extern int                    e_ADXPeriod=14;//e_ADXPeriod
extern int                    e_ADXRAGO=14;//e_ADXRAGO
//+------------------------------------------------------------------+
//| Variables Timer Aspect                                           |
//+------------------------------------------------------------------+
extern double                 e_equityRisk=2;//e_equityRisk: % Equity Risk / Trade % / ----for stop
extern double                 e_numberPairsTrade=10;//e_numberPairsTrade: Used to set the acceptible margin
extern double                 e_marginPercentTotal=75;//e_marginPercentTotal: % Total Acceptable Equity Margin    
//+-------------------------------------------------------------------+
//|HTF_ALL_SEP_VOL_PERCENTILE_WAVE                                    |
//+-------------------------------------------------------------------+
extern volume_price           e_vp=PINCH;//e_vp: type of volume to draw
extern double                 e_lowerPercentile=5;//e_lowerPercentile: low percent
extern double                 e_lowerMiddlePercentile=20;//e_lowerMiddlePercentile: lower middle Percentile
extern double                 e_middlePercentile=50;//e_middlePercentile: middle percentile
extern double                 e_upperMiddlePercentile=90;//e_upperMiddlePercentile: ****** should be 90 upper Middle Percentile
extern double                 e_upperPercentile=98;//e_upperPercentile: upper percentile 98
extern double                 e_wavePts=0;//e_wavePts: 0.5 points is 50 on SP500 / zero auto scale
extern bool                   e_drawLines=false;//e_drawLines: percentile vol lines
extern bool                   e_showData=false;//e_showData: show volume data on indicator 
//+------------------------------------------------------------------+
//|OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   e_enumHTFWTFFilter=ENUM_TIMEFRAMES(Period());
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
         Print(__FUNCTION__," FAILED e_enumHTFWTFFilter>=enumHTFTrendFilter: ",(e_enumHTFWTFFilter>e_enumHTFTrendFilter)," e_enumHTFWTFFilter: ",e_enumHTFWTFFilter," enumHTFTrendFilter: ",e_enumHTFTrendFilter," enumHTFContraWaveFilter: ",e_enumHTFContraWaveFilter," enumHTFTerminateFilter: ",e_enumHTFTerminateFilter);
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
//  int handle=-1;
   string descr="A Symbol";
   double cumProfit=NULL;

   instrument *p=NULL;
   double retValue=-1;
   bool canCreate=true;
//   handle=openSymbolFile(Symbol(),e_enumHTFWTFFilter,fileName,fgName);
//p=new instrument(e_enumHTFWTFFilter,e_enumHTFTrendFilter,e_enumHTFContraWaveFilter,e_enumHTFATRWaveFilter,e_enumHTFTerminateFilter,
//                 // e_signature  set to 1 so can  ignore margin limits
//                 Symbol(),descr,"WTF",e_ADXPeriod,e_ADXRAGO,e_equityRisk,acceptableMargin,1,canCreate,e_signature,e_betPoundThreshold);
   if(canCreate)
     {
      cumProfit=iCustom(Symbol(),e_enumHTFWTFFilter,"\\TREND\\trendIndicator",
                        e_drawTrades,
                        e_signature,
                        e_maxBars,
                        e_useMaxBars,
                        e_isTesting,
                        e_isBuyTest,
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
                        e_showData,
                        6,1);

      //    delete(p);
      Print(" CUMPROFIT ",cumProfit);
      //Print(Symbol()," wtf: ",Period()," ATRTF: ",e_ATRPeriod," ttf: ",e_enumHTFTrendFilter," fileGroup ",fgName," Cumulative Profit: ",DoubleToStr(cumProfit,int(MarketInfo(Symbol(),MODE_DIGITS))));
      //used to close terminal in batch run: calculation can move on to next instrument in python call
      if(!FileIsExist("dummy.txt"))
        {
         handle2=FileOpen("dummy.txt",FILE_WRITE|FILE_CSV);
         FileClose(handle2);
        }
      Print("**** DONE ***** ",__FUNCTION__);
     }
   else
     {
      //  delete(p);
      Print("**** Cannot Create this File:");
     }
  }
//+------------------------------------------------------------------+
