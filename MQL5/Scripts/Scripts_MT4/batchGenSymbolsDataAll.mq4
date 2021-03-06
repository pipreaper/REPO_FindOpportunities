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
string fileName=NULL;
string fgName=NULL;
//+------------------------------------------------------------------+
//| Extern Global Variables Timer Aspect                             |
//+------------------------------------------------------------------+
simObject *sObj=NULL;
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
extern int                    e_drawTrades=0;//-2;//e_drawTrades=-2;//(0) nothing,(1) Arrows,(2) 1+Lines (-1) Profit Script 
extern int                    e_signature=1;//<0 adjust margins by factor,  or ignore factor (unlimed margin!)
extern int                    e_maxBars=2000; //limit shift operations to speed up run time
extern bool                   e_useMaxBars=false; //plot (trendIndicatorI),and analysis is false, since want to see all data
extern bool                   e_isTesting=false;//-- true for batch gen results and overriden in call to trendIndicator below, will open a BUY at market at shift=0: assumption being  shift=1 was set to buy: Used to inspect trade opens
extern bool                   e_isBuyTest=true;//-- if e_isTesting then is it a B/S test?
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
         Print(__FUNCTION__," FAILED e_enumHTFWTFFilter<=enumHTFTrendFilter: ",(e_enumHTFWTFFilter>e_enumHTFTrendFilter)," e_enumHTFWTFFilter: ",e_enumHTFWTFFilter," enumHTFTrendFilter: ",e_enumHTFTrendFilter," enumHTFContraWaveFilter: ",e_enumHTFContraWaveFilter," enumHTFTerminateFilter: ",e_enumHTFTerminateFilter);
         return (INIT_FAILED);
        }
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int openSymbolFile(string _sym,ENUM_TIMEFRAMES _wtf,string &_fileName,string &_fgName)
  {
   string prefix=NULL;
   int g=0;
   do
     {
      g+=g;
      _fgName=symbolType(_sym);
      if((_fgName!=NULL) || (g>5))
         break;
      Sleep(2);
     }
   while(_fgName==NULL);
   if(_fgName==NULL)
     {
      prefix="BULL: "+_sym+" "+string(_wtf);
      Print(prefix);
     }
   _fileName=prefix+"cumulative Profit^"+_sym+"^"+_fgName+"^"+string(_wtf)+".csv";
   if(FileIsExist(_fileName,FILE_COMMON))
      FileDelete(_fileName);
   int _handle=FileOpen(_fileName,FILE_WRITE|FILE_CSV);
   if(_handle<0)
     {
      Print(" file Open Error ");
      return _handle;
     }
   string symbol=NULL;
   FileWrite(_handle,"symbol","_wtf","ATRTF","ttf","group","cumProfit");
   return _handle;
  }
//+------------------------------------------------------------------+
//| OnStart                                                          |
//+------------------------------------------------------------------+
void OnStart()
  {
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
 //  sObj.runtimeEnabled(e_isTesting);
   int handle=-1;
   double cumProfit=NULL;
   ENUM_TIMEFRAMES wtf=NULL;
   int lastTF=2;
   int firstTF=2;
   for(int i=0; i<sObj.totalSymbols;i++)
     {
      //***need to put loop here
      for(int tf=lastTF;(tf>=firstTF); tf--)
        {
         wtf=tfEnumFull[tf];
         if(prospectArray[i].isEnabled)
           {
            handle=openSymbolFile(prospectArray[i].symbol,wtf,fileName,fgName);
            cumProfit=sObj.calcProfit(prospectArray[i].symbol,prospectArray[i].desc,1);//always want position 1
            FileWrite(handle,prospectArray[i].symbol,wtf,e_ATRPeriod,e_enumHTFTrendFilter,fgName,cumProfit);
            Print(prospectArray[i].symbol," wtf: ",wtf," ATRTF: ",e_ATRPeriod," ttf: ",e_enumHTFTrendFilter," fileGroup ",fgName," Cumulative Profit: ",cumProfit);
            fileName=NULL; fgName=NULL; handle=-1;cumProfit=0;
           }
        FileClose(handle);//-- finished all time frames for this instrument
        }
     }
//used to close terminal in batch run
   handle=FileOpen("dummy.txt",FILE_WRITE|FILE_CSV);
   FileClose(handle);
   delete(sObj);
   Print("**** DONE ***** ",__FUNCTION__);
  }
//+------------------------------------------------------------------+
