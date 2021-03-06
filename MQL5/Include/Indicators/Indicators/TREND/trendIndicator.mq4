//+--------------------------------------------------------------------------------------+
//|                                                                   trendIndicator.mq4 |
//|                                                        Copyright 2018, Robert Baptie |
//|                                                           http://www.companyname.net |
//| *** This is the working and changable indicator. change this and cut paste    *******|
//| *** for a graphical view                                                      *******|
//+--------------------------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.34"
#property description "Use PERIOD_M15 TF Chart, use PERIOD_H1 HTFMA, use PERIOD_H4 HTF"
#property description "HTFMA returns (1) golden cross, (2) Death cross, (NULL) Nothing trending" 
#property description "Has large target = 10 ATR, smaller stop 3 ATR these are hard stops and needed for both directions " 
#property description "The above statuses are set in arrow buffers ExtArrowLong, ExtArrowShort, ExtArrowClose only if its a new direction - so can close easy in expert" 
#property description "HTFADX return (1) trending up, (-1) trending down, (2) stop or NULL nothing happening" 
//Major drawback with system is that the spread is fixed and the slippage is zero  

#property strict
#property indicator_chart_window
#include <WaveLibrary.mqh>
#include <supportResistance.mqh>
#include <status.mqh>
#include <instrument.mqh>
#include <SymbolsInfo.mqh>
//-- *** Change this on copy and paste to e_globals / i_globals.mqh
//turn off for no local Print statements: DO NOT MAKE An Indicator Parameter - have to change simObject.mqh if do!
//+------------------------------------------------------------------+
//| Extern Global Variables simObject setup                          |
//+------------------------------------------------------------------+
extern int                    e_drawTrades=3;//-3 create (-2) + detail file for each simulation; -2 special key for run: batchGenSymbolsData; 0 draw Nothing; 1 show Trade lines; 2 show Trades lines and print statements
extern int                    e_signature=0;//e_signature: <0 adjust margins by factor,  or ignore factor (unlimed margin!)
extern int                    e_maxBars=2000; //e_maxBars: limit shift operations to speed up run time
extern bool                   e_useMaxBars=false; //e_useMaxBars: plot (trendIndicatorI),and analysis is false, since want to see all data
extern bool                   e_isTesting=false;//e_isTesting will open a BUY at market at shift=0: assumption being  shift=1 was set to buy: Used to inspect trade opens
extern bool                   e_isBuyTest=true;//e_isBuyTest
extern ENUM_TIMEFRAMES        e_enumHTFWTFFilter=PERIOD_CURRENT;//WTF
extern ENUM_TIMEFRAMES        e_enumHTFTrendFilter=PERIOD_D1;//HTF trend filter
extern ENUM_TIMEFRAMES        e_enumHTFContraWaveFilter=PERIOD_H1;//e_enumHTFContraWaveFilter: wave pullback filter
extern ENUM_TIMEFRAMES        e_enumHTFATRWaveFilter=PERIOD_H1;//e_enumHTFATRWaveFilter: ATRTF: Stop, Target, Open Trade, trendIndicator & Expert
extern ENUM_TIMEFRAMES        e_enumHTFTerminateFilter=PERIOD_H1;//e_enumHTFTerminateFilter: HTF exit filter change trend
extern double                 e_betPoundThreshold=0.1; //e_betPoundThreshold: cannot open if calculated betNumPounds below this proportion   
extern double                 e_wtfSpreadPercent=0.15;//e_wtfSpreadPercent: fraction of spread money for the bet that cannot be exceded if setInstrumentsInWTF passes in simObject
extern int                    e_ATRPeriod=14;//e_ATRPeriod:ATR period
extern double                 e_stopFactor=3;//e_stopFactor: flex ATR Stop
extern double                 e_targetFactor=3;//e_targetFactor: flex ATR Target;
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
extern double                 e_upperMiddlePercentile=51;//e_upperMiddlePercentile: ****** should be 90 upper Middle Percentile
extern double                 e_upperPercentile=98;//e_upperPercentile: upper percentile 98
extern double                 e_wavePts=0;//e_wavePts: 0.5 points is 50 on SP500 / zero auto scale
extern bool                   e_drawLines=false;//e_drawLines: percentile vol lines
extern bool                   e_showData=false;//e_showData: show volume data on indicator 
#include <ROB_CONFIG_FILES\auxillary.mqh>
#property  indicator_buffers 8

//+-------------------------------------------------------------------+
//| Buffers                                                           |
//+-------------------------------------------------------------------+   
double         ExtArrowLong[];
double         ExtArrowShort[];
double         ExtStop[];
double         ExtTarget[];
double         ExtArrowClose[];
double         ExtArrowStatus[];
double         ExtCumProfit[];
double         ExtImmidiatePrice[];
//+-------------------------------------------------------------------+
//| Global variables                                                  |
//+-------------------------------------------------------------------+ 
double         SPREAD=-1;//-- Flaw in indicator for simulation because it  currently uses current spread in all historical calculations
color          fontColorProfit=clrGreen;
color          fontColorLoss=clrRed;
color          fontColorIndex=clrWheat;
instrument     *instanceSymbol=NULL;
double         acceptableMargin=NULL;
int            noTradeFactor=7;
info tInfo;
double accountE=0;
int handle=NULL;
int handleFull=NULL;
datetime startDate=NULL;
double numberWins=0;
double numberTrades=0;
//+-------------------------------------------------------------------+
//| OnInit                                                            |
//+-------------------------------------------------------------------+
int OnInit()
  {
   if(e_drawTrades<=-2)
      accountE=10000;
   else
      accountE=AccountEquity();

//if(e_drawTrades<=-2)
//  {
//   handle=openSymbolFile(Symbol(),ENUM_TIMEFRAMES(Period()),fileName,fgName,NULL,accountE,e_upperMiddlePercentile);
//   FileWrite(handle,"symbol","_wtf","UMP","ATRTF","ttf","group","cumProfit");
//  }
   if(e_drawTrades<=-3)
      handleFull=openSymbolFile(Symbol(),ENUM_TIMEFRAMES(Period()),fileName,fgName,"Full_",accountE,e_upperMiddlePercentile);

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
         Print(__FUNCTION__," FAILED e_enumHTFWTFFilter>enumHTFTrendFilter: ",(e_enumHTFWTFFilter>e_enumHTFTrendFilter)," e_enumHTFWTFFilter: ",e_enumHTFWTFFilter," enumHTFTrendFilter: ",e_enumHTFTrendFilter," enumHTFContraWaveFilter: ",e_enumHTFContraWaveFilter," enumHTFTerminateFilter: ",e_enumHTFTerminateFilter);
         return (INIT_FAILED);
        }
     }
   tInfo.state=NULL;
   tInfo.csi=-1;
   tInfo.cCSI=0;
   tInfo.cBet=0;
   tInfo.stop=-1;
   tInfo.target=-1;
   tInfo.oPrice=-1;
   tInfo.oTime=NULL;
   tInfo.cPoints=0;
   tInfo.cGBP=0;
   tInfo.maxDrawDown=0;
   tInfo.numberTrades=0;
   tInfo.numberWins=0;
   tInfo.pointSize=-1;
   tInfo.tickValue=-1;
   tInfo.tickSize=-1;
   tInfo.startTime=NULL;

// Print("ALL GOOD: ",(e_enumHTFWTFFilter()<=enumHTFTerminateFilter)," ",(e_enumHTFWTFFilter()<=enumHTFContraWaveFilter)," ",(e_enumHTFWTFFilter()<=enumHTFTrendFilter));
   clrLine=TF_C_Colors[findIndex(e_enumHTFWTFFilter)];
   double marginPerSym=e_marginPercentTotal/e_numberPairsTrade;

   acceptableMargin=(marginPerSym/100)*accountE;//The margin to allocate per Sym    
   SPREAD=MarketInfo(Sym,MODE_SPREAD)*MarketInfo(Sym,MODE_POINT);

//   Print(" MMMM acceptableMargin ",acceptableMargin," AccountEquity() ",AccountInfoDouble(ACCOUNT_EQUITY)," marginPerSym ",marginPerSym," SPRESAD ",SPREAD);

   int statusDisplay=DRAW_ARROW;
   if(e_drawTrades<=0)
      statusDisplay=DRAW_NONE;

   IndicatorShortName("trendIndicator: ");
   IndicatorBuffers(8);
   IndicatorDigits(int(MarketInfo(Symbol(),MODE_DIGITS)));

   SetIndexStyle(0,statusDisplay,0,1,clrLine);
   SetIndexArrow(0,233);
   SetIndexLabel(0,"T Long Arrow");
   SetIndexBuffer(0,ExtArrowLong);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexStyle(1,statusDisplay,0,1,clrLine);
   SetIndexArrow(1,234);
   SetIndexLabel(1,"T Short Arrow");
   SetIndexBuffer(1,ExtArrowShort);
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,statusDisplay,0,3,clrLine);
   SetIndexArrow(2,158);
   SetIndexLabel(2,"T Stop");
   SetIndexBuffer(2,ExtStop);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,statusDisplay,0,3,clrLine);
   SetIndexArrow(3,160);
   SetIndexLabel(3,"T Target");
   SetIndexBuffer(3,ExtTarget);
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexStyle(4,statusDisplay,0,1,clrLine);
   SetIndexArrow(4,181);
   SetIndexLabel(4,"T Close");
   SetIndexBuffer(4,ExtArrowClose);
   SetIndexEmptyValue(4,EMPTY_VALUE);

   SetIndexStyle(5,DRAW_NONE,0,5,clrNONE);
   SetIndexArrow(5,160);
   SetIndexLabel(5,"T Indicator Status");
   SetIndexBuffer(5,ExtArrowStatus);
   SetIndexEmptyValue(5,EMPTY_VALUE);

   SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
   SetIndexLabel(6,"T Cumulative Profit");
   SetIndexBuffer(6,ExtCumProfit);
   SetIndexEmptyValue(6,0);

   SetIndexStyle(7,statusDisplay,0,3,clrOrange);
   SetIndexArrow(7,160);
   SetIndexLabel(7,"T Immidiate Price");
   SetIndexBuffer(7,ExtImmidiatePrice);
   SetIndexEmptyValue(7,0);

   do
     {
      for(int i=ObjectsTotal(); i>=0; i--)
         ObjectDelete(ObjectName(i));
     }
   while(ObjectsTotal()>0);
   ChartRedraw();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//-- Set up conditions for new bar
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];
   bool direction=true;
   ArraySetAsSeries(open,direction);
   ArraySetAsSeries(high,direction);
   ArraySetAsSeries(low,direction);
   ArraySetAsSeries(time,direction);
   ArraySetAsSeries(ExtStop,direction);
   ArraySetAsSeries(ExtTarget,direction);
   ArraySetAsSeries(ExtArrowLong,direction);
   ArraySetAsSeries(ExtArrowShort,direction);
   ArraySetAsSeries(ExtArrowClose,direction);
   ArraySetAsSeries(ExtArrowStatus,direction);
   ArraySetAsSeries(ExtCumProfit,direction);
   ArraySetAsSeries(ExtImmidiatePrice,direction);

   startDate=Time[rates_total-1];
   if(!e_useMaxBars)
      limit=rates_total-prev_calculated;
   else
      limit=e_maxBars-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;
//Think you can limit sphere of calculation on real runs here
   for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
     {
      if(shift>(rates_total-(e_ADXPeriod+e_ADXRAGO)))
         //if(shift>(rates_total-(e_ADXPeriod+e_ADXRAGO)))
         continue;
      if(isNewBar)// ***** the chart tf the indicator is applied to
        {
         double htfPercent
         =iCustom(
                  Sym,
                  e_enumHTFWTFFilter,
                  "\\VOLUME\\HTF_ALL_SEP_VOL_PERCENTILE_WAVE",
                  e_drawLines,
                  e_vp,
                  e_enumHTFContraWaveFilter,
                  e_wavePts,
                  e_showData,
                  e_lowerPercentile,
                  e_lowerMiddlePercentile,
                  e_middlePercentile,
                  e_upperMiddlePercentile,
                  e_upperPercentile,
                  8,shift+1);

         double htfsignedDeltaVolume
         =iCustom(
                  Sym,
                  e_enumHTFWTFFilter,
                  "\\VOLUME\\HTF_ALL_SEP_VOL_PERCENTILE_WAVE",
                  e_drawLines,
                  e_vp,
                  e_enumHTFContraWaveFilter,
                  e_wavePts,
                  e_showData,
                  e_lowerPercentile,
                  e_lowerMiddlePercentile,
                  e_middlePercentile,
                  e_upperMiddlePercentile,
                  e_upperPercentile,
                  9,shift+1);

         //double htf2MAStatus
         //=iCustom(
         //         Sym,e_enumHTFWTFFilter,
         //         "\\TREND\\HTF_2MA",
         //         e_enumHTFTrendFilter,
         //         fEMA,sEMA,shiftMA,
         //         3,shift+1);
         //double htf2MAStatusF
         //=iCustom(
         //         Sym,e_enumHTFWTFFilter,
         //         "\\TREND\\HTF_2MA",
         //         e_enumHTFTrendFilter,
         //         3,3,shiftMA,
         //         3,shift+1);                  
         //double adxUp=iCustom(Sym,e_enumHTFWTFFilter,
         //                     "\\TREND\\HTF_ADX",
         //                     PERIOD_H1,
         //                     5,0,
         //                     0,shift+1);
         //double adxDown=iCustom(Sym,e_enumHTFWTFFilter,
         //                     "\\TREND\\HTF_ADX",
         //                     PERIOD_H1,
         //                     5,0,
         //                     1,shift+1);                              
         //if(shift>(limit-(e_ADXPeriod+e_ADXRAGO)))     
         //   continue;                  
         //Print(
         //      __FUNCTION__,
         //      " WTF: ",e_enumHTFWTFFilter,
         //      " trend:",e_enumHTFTrendFilter,
         //      " contrawave: ",e_enumHTFContraWaveFilter,
         //      " ATR: ",e_enumHTFATRWaveFilter,
         //      " terminate: ",e_enumHTFTerminateFilter);
         //       if(htfPercent!=EMPTY_VALUE && htfPercent>=75)
         //          Print(__FUNCTION__,"** "," htfPercent ",htfPercent," htfsignedDeltaVolume ",htfsignedDeltaVolume," htf2MAStatus ",htf2MAStatus);

         highVal= high[shift+1]+point*100;
         lowVal = low[shift+1]-100*point;
         tradeFactor=noTradeFactor;
         //      if(shift<20)
         //         Print(__FUNCTION__," ",Time[shift]," close[shift] ",close[shift]," passes shift+1 - shift: ",shift," htf2MAStatus ",htf2MAStatus," htfsignedDeltaVolume ",htfsignedDeltaVolume," htfPercent ",htfPercent);

         if(tInfo.state==NULL)
           {
            if(
               ((htfPercent!=EMPTY_VALUE) && (htfsignedDeltaVolume!=EMPTY_VALUE)  && (htfPercent<=100) && (htfPercent>=e_upperMiddlePercentile) && (htfsignedDeltaVolume<0) && (!e_isTesting))
               || ((e_isTesting && (shift==1)) && (e_isBuyTest))
               )
              {
           //   Print("BUY "," ADXUP ", adxDown," ADX DOWN ",adxUp);
               double atr=-1,stop=-1,target=-1;
               instanceSymbol=new instrument(e_enumHTFWTFFilter,e_enumHTFTrendFilter,e_enumHTFContraWaveFilter,e_enumHTFATRWaveFilter,e_enumHTFTerminateFilter,
                                             Sym,"A Symbol","WTF",e_ADXPeriod,e_ADXPeriod,e_equityRisk,acceptableMargin,shift+1,canCreate,e_signature,e_betPoundThreshold);
               // Print("from indicator ",acceptableMargin);
               if(!instanceSymbol.setVariableData())
                 {
                  //                 Print(__FUNCTION__," setVariableData Failed to return values "," Time ",Time[shift+1],Sym," e_enumHTFWTFFilter  ",e_enumHTFWTFFilter," ADXPeriod  ",ADXPeriod," ADXRAGO  ",ADXRAGO," acceptableMargin  ",acceptableMargin," shift+1 ",shift+1);
                  delete(instanceSymbol);
                  continue;
                 }
               //Print(__FUNCTION__," ",Time[shift+1]," BUY "," htf2MAStatus ",htf2MAStatus , " htfPercent ",htfPercent," e_upperMiddlePercentile ", e_upperMiddlePercentile," htfsignedDeltaVolume ",htfsignedDeltaVolume);
               ExtArrowStatus[shift+1]=0;
               ExtArrowLong[shift+1]=lowVal;
               tInfo.state="B";
               tInfo.oPrice=open[shift]+SPREAD;
               tInfo.oTime=time[shift];
               int phtfShift=iBarShift(Sym,e_enumHTFATRWaveFilter,time[shift+1],false);
               atr=iATR(Sym,e_enumHTFATRWaveFilter,e_ATRPeriod,phtfShift);
               //Used to set stop limit equidistant after absorbing spread cost             
               double immidiatePrice=tInfo.oPrice-SPREAD;
               tInfo.stop= immidiatePrice-atr*e_stopFactor;
               tInfo.stop= ND(tInfo.stop,instanceSymbol.digits);
               tInfo.target=immidiatePrice + atr*e_targetFactor;
               tInfo.target= ND(tInfo.target,instanceSymbol.digits);

               ExtImmidiatePrice[shift+1]=immidiatePrice;
               //if(isDate(shift,0,0,17,5,2018))

               //  instanceSymbol.setVariableData(e_enumHTFWTFFilter,ADXPeriod,ADXRAGO,equityRisk,acceptableMargin,shift+1);
               tInfo.csi=instanceSymbol.csi;
               tInfo.betNumPounds=instanceSymbol.betNumPounds;
               //if(e_drawTrades>0)
               //  {
               ExtStop[shift+1]=tInfo.stop;
               ExtTarget[shift+1]=tInfo.target;
               //                }
               tradeFactor=0;
               tInfo.pointSize=instanceSymbol.pointSize;
               tInfo.tickSize = instanceSymbol.tickSize;
               tInfo.tickValue=instanceSymbol.tickValue;
               tInfo.startTime=time[shift+1];
               delete(instanceSymbol);
               if(e_isTesting)
                 {
                  //Print(__FUNCTION__," shift ",shift," ",Sym," e_isTesting ",e_isTesting," ",Time[shift]," close[shift]: ",close[shift]," stop: ",tInfo.stop," target: ",tInfo.target);
                  //Print(__FUNCTION__," ",Time[shift]," close[shift] ",close[shift]," passes shift+1 - shift: ",shift," htf2MAStatus ",htf2MAStatus, " htfsignedDeltaVolume ", htfsignedDeltaVolume," htfPercent ",htfPercent);
                 }

              }
            else if(
               ((htfPercent!=EMPTY_VALUE) && (htfsignedDeltaVolume!=EMPTY_VALUE)  && (htfPercent<=100) && (htfPercent>=e_upperMiddlePercentile) && (htfsignedDeltaVolume>0) && (!e_isTesting))
                             || ((e_isTesting && (shift==1)) && (!e_isBuyTest))
                             )
                 {
        //      Print("SELL "," ADXUP ", adxDown," ADX DOWN ",adxUp);                 
                  double atr=-1,stop=-1,target=-1;
                  instanceSymbol=new instrument(e_enumHTFWTFFilter,e_enumHTFTrendFilter,e_enumHTFContraWaveFilter,e_enumHTFATRWaveFilter,e_enumHTFTerminateFilter,
                                                Sym,"A Symbol","WTF",e_ADXPeriod,e_ADXPeriod,e_equityRisk,acceptableMargin,shift+1,canCreate,e_signature,e_betPoundThreshold);
                  if(!instanceSymbol.setVariableData())
                    {
                     //                 Print(__FUNCTION__," setVariableData Failed to return values "," Time ",Time[shift+1],Sym," e_enumHTFWTFFilter  ",e_enumHTFWTFFilter," ADXPeriod  ",ADXPeriod," ADXRAGO  ",ADXRAGO," acceptableMargin  ",acceptableMargin," shift+1 ",shift+1);
                     delete(instanceSymbol);
                     continue;
                    }
                  //Print(__FUNCTION__," ",Time[shift+1]," SELL "," htf2MAStatus ",htf2MAStatus , " htfPercent ",htfPercent," e_upperMiddlePercentile ", e_upperMiddlePercentile," htfsignedDeltaVolume ",htfsignedDeltaVolume);                 
                  ExtArrowStatus[shift+1]=1;
                  ExtArrowShort[shift+1]=highVal;
                  tInfo.state="S";
                  tInfo.oPrice=open[shift];
                  tInfo.oTime=time[shift];
                  int phtfShift=iBarShift(Sym,e_enumHTFATRWaveFilter,time[shift+1],false);
                  atr=iATR(Sym,e_enumHTFATRWaveFilter,e_ATRPeriod,phtfShift);
                  //Used to set stop limit equidistant after absorbing spread cost             
                  double immidiatePrice=tInfo.oPrice+SPREAD;
                  tInfo.stop= immidiatePrice+atr*e_stopFactor;
                  tInfo.stop= ND(tInfo.stop,instanceSymbol.digits);
                  tInfo.target=immidiatePrice - atr*e_targetFactor;
                  tInfo.target= ND(tInfo.target,instanceSymbol.digits);

                  ExtImmidiatePrice[shift+1]=immidiatePrice;
                  //if(isDate(shift,0,0,17,5,2018))

                  //  instanceSymbol.setVariableData(e_enumHTFWTFFilter,ADXPeriod,ADXRAGO,equityRisk,acceptableMargin,shift+1);
                  tInfo.csi=instanceSymbol.csi;
                  tInfo.betNumPounds=instanceSymbol.betNumPounds;
                  //if(e_drawTrades>0)
                  //  {
                  ExtStop[shift+1]=tInfo.stop;
                  ExtTarget[shift+1]=tInfo.target;
                  //           }
                  tradeFactor=1;
                  // tInfo.factor = instanceSymbol.factor;
                  tInfo.pointSize=instanceSymbol.pointSize;
                  tInfo.tickSize = instanceSymbol.tickSize;
                  tInfo.tickValue=instanceSymbol.tickValue;
                  tInfo.startTime=time[shift+1];
                  delete(instanceSymbol);
                  //             Print(" Info.oTime: ",tInfo.oTime," Sym: ",Sym," tInfo.oPrice: ",tInfo.oPrice," atr: ",atr," stop: ",stop," target: ",target," tInfo.betNumPounds: ",tInfo.betNumPounds," tInfo.csi: ",tInfo.csi);
                 }
              }
            else if(!e_isTesting)
              {
               //--must be selling or buying
               if((tInfo.state=="B") && (low[shift+1]<=tInfo.stop))
                 {
                  closeTrade(3,open[shift],time[shift+1],digits,lowVal,highVal);
                  tradeFactor=3;
                 }
               else if((tInfo.state=="S") && ((high[shift+1]+SPREAD)>=tInfo.stop))
                 {
                  closeTrade(5,(open[shift]+SPREAD),time[shift+1],digits,lowVal,highVal);
                  tradeFactor=5;
                 }
               //TARGETS
               else if((tInfo.state=="B") && (high[shift+1]>=tInfo.target))
                 {
                  closeTrade(4,open[shift],time[shift+1],digits,lowVal,highVal);
                  tradeFactor=4;
                 }
               else if((tInfo.state=="S") && ((low[shift+1]+SPREAD)<=tInfo.target))
                 {
                  closeTrade(6,(open[shift]+SPREAD),time[shift+1],digits,lowVal,highVal);
                  tradeFactor=6;
                 }
               //INDICATOR STOPS 
               //if((htf2MAStatus==1) && (tInfo.state=="B"))
               //  {
               //   closeTrade(2,open[shift],time[shift+1],digits,lowVal,highVal);
               //   tradeFactor=2;
               //  }
               //else if((htf2MAStatus==0) && (tInfo.state=="S"))
               //  {
               //   closeTrade(2,(open[shift]+SPREAD),time[shift+1],digits,lowVal,highVal);
               //   tradeFactor=2;
               //  }
               //if((htf2MAStatusF==1) && (tInfo.state=="B"))
               //  {
               //   closeTrade(2,open[shift],time[shift+1],digits,lowVal,highVal);
               //   tradeFactor=2;
               //  }
               //else if((htf2MAStatusF==0) && (tInfo.state=="S"))
               //  {
               //   closeTrade(2,(open[shift]+SPREAD),time[shift+1],digits,lowVal,highVal);
               //   tradeFactor=2;
               //  }                 
               //else if((adxUp==EMPTY_VALUE) && (tInfo.state=="B"))
               //  {
               //   closeTrade(2,open[shift],time[shift+1],digits,lowVal,highVal);
               //   Print("ADX BUY KILLED");
               //   tradeFactor=2;
               //  }
               //else if((adxDown==EMPTY_VALUE) && (tInfo.state=="S"))
               //  {
               //   closeTrade(2,(open[shift]+SPREAD),time[shift+1],digits,lowVal,highVal);
               //                     Print("ADX SELL KILLED");
               //   tradeFactor=2;
               //  }                 
              }//must be selling or buying
            ExtArrowStatus[shift+1]=tradeFactor;
            ExtCumProfit[shift+1]=tInfo.cPoints;
            // if((e_drawTrades>=2) && (tradeFactor!=noTradeFactor) && (tradeFactor>1))
            //    Print("** ExtCumProfit[shift+1] ",ExtCumProfit[shift+1]);
            //if(e_drawTrades==2)
            //if((shift==0) && (e_drawTrades<=-2))
            //  {
            //   Print("indicator profit: ",DoubleToStr(tInfo.cPoints,int(MarketInfo(Symbol(),MODE_DIGITS))));             
            //   FileWrite(handle,Symbol(),Period(),e_upperMiddlePercentile,e_ATRPeriod,e_enumHTFTrendFilter,fgName,
            //   DoubleToStr(tInfo.cGBP,0));
            //             //DoubleToStr(tInfo.cPoints,int(MarketInfo(Symbol(),MODE_DIGITS))));
            //   FileClose(handle);
            //  }
            if((shift==0) && (e_drawTrades<=-3))
              {
               double durn=getElapsedTimeSecs(Time[0],startDate)/(3600*24);
               double cCSI=tInfo.cCSI/tInfo.numberTrades;
               double cBet= tInfo.cBet/tInfo.numberTrades;
               string row="something to write\n";
               FileSeek(handleFull,0,SEEK_END);
               FileWrite(handleFull,
                         Sym,
                         Period(),
                         fgName,
                         DoubleToStr(e_upperMiddlePercentile,0),
                         DoubleToStr(tInfo.cGBP,0),
                         DoubleToStr(tInfo.cPoints,int(MarketInfo(Symbol(),MODE_DIGITS))),
                         DoubleToStr(durn,0),
                         DoubleToStr(tInfo.numberTrades,0),
                         DoubleToStr(tInfo.numberWins,0),
                         DoubleToStr(tInfo.maxDrawDown,0),
                         DoubleToStr(cCSI,1),
                         DoubleToStr(cBet,2)

                         );
               //FileSeek(handleFull,0,SEEK_END);
               //FileWrite(handleFull,Symbol(),Period(),e_ATRPeriod,e_enumHTFTrendFilter,fgName,
               //          DoubleToStr(tInfo.cPoints,int(MarketInfo(Symbol(),MODE_DIGITS))),
               //          DoubleToStr(tInfo.maxDrawDown,2),
               //          tInfo.startTime,
               //          Time[0],
               //          DoubleToStr(durn,2),
               //          IntegerToString(tInfo.numberTrades));
               FileClose(handleFull);
              }
           }//new bar           
        }//for
      return(rates_total);
     }
//+------------------------------------------------------------------+
//| CloseTrade                                                       |
//+------------------------------------------------------------------+  
   void closeTrade(double arrowStatus,double OShift,datetime tShift,double DIGITS,double LOWVAL,double HIGHVAL)
     {
      ExtArrowStatus[shift+1]=arrowStatus;
      //This is a guestimate of spread
      //double spread=MarketInfo(Sym,MODE_SPREAD);
      //spread=spread/MathPow(10,DIGITS);
      double closePrice = NULL;
      datetime openTime = tInfo.oTime;
      datetime closeTime= tShift;
      double arrowLocation=NULL;
      double points=NULL;
      double GBP=NULL;
      //Print("TIME: ",time0," CLOSE ",tInfo.state, " tf3HTFADXClose: ",tf3HTFADXClose," tf2HTFMAStatus: ",tf2HTFMAStatus," tf3HTFRSIStatus: ",tf3HTFRSIStatus," ExtArrowStatus[shift]: ",ExtArrowStatus[shift]);
      if(tInfo.state=="B")
        {
         arrowLocation=LOWVAL;
         if(arrowStatus==2)
            closePrice=OShift;
         else if(arrowStatus==3)
            closePrice=tInfo.stop;
         else if(arrowStatus==4)
            closePrice=tInfo.target;
         //tinfo.oPrice is the real open price so SPREAD is included in the loss at close
         points=closePrice-tInfo.oPrice;
         ExtArrowClose[shift+1]=LOWVAL;
         //tInfo.state="BLOCKED_LONG";
        }
      else if(tInfo.state=="S")
        {
         arrowLocation=HIGHVAL;
         if(arrowStatus==2)
            closePrice=OShift;
         else if(arrowStatus==5)
            closePrice=tInfo.stop;
         else if(arrowStatus==6)
            closePrice=tInfo.target;
         points=tInfo.oPrice-closePrice;
         // Print("S: ",points);
         ExtArrowClose[shift+1]=HIGHVAL;
         //tInfo.state="BLOCKED_SHORT";
        }
      tInfo.state=NULL;
      tInfo.cPoints+=points;
      double pointValue=tInfo.tickValue *(tInfo.pointSize/tInfo.tickSize);//? last two parameters find one to check!
      GBP=tInfo.betNumPounds*(points/tInfo.pointSize)*pointValue;
      tInfo.cGBP+=GBP;
      tInfo.cCSI+=tInfo.csi;
      tInfo.cBet+=tInfo.betNumPounds;
      tInfo.numberTrades+=1;
      if(points>0)
         tInfo.numberWins+=1;
      tInfo.maxDrawDown=MathMin(tInfo.maxDrawDown,tInfo.cGBP);
      if(e_drawTrades>=1)
        {
         //   //         Print(Sym," ",e_enumHTFWTFFilter," ",enumHTFATRWaveFilter," ",CSIHTFTrend," tInfo.maxDrawDown: ",tInfo.maxDrawDown," tInfo.csi: ",tInfo.csi," points: ",points," tInfo.cPoints: ",tInfo.cPoints," tInfo.oTime: ",tInfo.oTime," arrowStatus: ",arrowStatus);
         drawCloseTrade(shift,closePrice,openTime,closeTime,arrowLocation,points,DIGITS,GBP);
        }
      if(e_drawTrades>=2)
        {
         double durn=getElapsedTimeSecs(Time[shift+1],tInfo.startTime)/3600;
         Print(Sym,":",Period()," £",DoubleToStr(tInfo.cGBP,0)," Points: ",DoubleToStr(tInfo.cPoints,int(DIGITS)),"  Period: ",DoubleToStr(durn,0),"  #Trade: ",DoubleToStr(tInfo.numberTrades,0),"  %Win: ",DoubleToStr(tInfo.numberWins,0)," MDD £: ",DoubleToStr(tInfo.maxDrawDown,0)," CSI: ",DoubleToStr(tInfo.csi,1)," BET £",tInfo.betNumPounds);
         //Print("** points: ",points," tInfo.cPoints: ",tInfo.cPoints," tInfo.oTime: ",tInfo.oTime," arrowStatus: ",arrowStatus);
         //         FileSeek(fileHandle,0,SEEK_END);
         //         bool hasWritten=FileWrite(fileHandle,Sym,e_enumHTFWTFFilter,e_enumHTFATRWaveFilter,e_enumHTFTrendFilter,ND(tInfo.maxDrawDown,5),ND(tInfo.csi,0),ND(points,5),fgName,ND(tInfo.cPoints,5),tInfo.oTime,arrowStatus);
         //         Print(hasWritten);
        }
      tInfo.oPrice=NULL;
      tInfo.csi=NULL;
      tInfo.oTime = NULL;
      tInfo.stop  = NULL;
      tInfo.target= NULL;
     }
//+------------------------------------------------------------------+
//|drawCloseTrade                                                    |
//+------------------------------------------------------------------+
   void drawCloseTrade(int Shift,double closePrice,datetime openTime,datetime closeTime,double arrowLocation,double points,double DIGITS,double GBP)
     {
      bool isProfit=(points>=0);
      //  ExtCumProfit[shift]=tInfo.cPoints;
      drawTradeLine(tInfo.oPrice,closePrice,openTime,closeTime,isProfit);
      //Set TextBox Names
      string pName="pIndex "+TimeToStr(closeTime)+" "+string(shift)+" "+string(closePrice)+" "+Sym;
      if(ObjectFind(ChartID(),pName)<0)
        {
         if(!ObjectCreate(ChartID(),pName,OBJ_TEXT,0,closeTime,arrowLocation))
           {
            Print(__FUNCTION__,": failed to create a pName! Error = ",ErrorDescription(GetLastError()));
           }
        }
      string str=setDisplayTexts(points,tInfo.cPoints,GBP,tInfo.cGBP,int(DIGITS));
      ObjectSetText(pName,str,fontSize,fontType,fontColorIndex);

     }
//+------------------------------------------------------------------+
//| drawTradeLine                                                    |
//+------------------------------------------------------------------+
   void drawTradeLine(double openPrice,double closePrice,datetime openTime,datetime closeTime,bool ISProfit)
     {
      string tName="tIndex "+string(closeTime);
      if(ObjectFind(ChartID(),tName)<0)
        {
         if(!ObjectCreate(ChartID(),tName,OBJ_TREND,0,openTime,openPrice,closeTime,closePrice))
            Print(__FUNCTION__,": failed to create a trend Line! Error = ",ErrorDescription(GetLastError())+" closeTime "+string(closeTime)+" closePrice "+string(closePrice));
         else
           {
            color clr=clrNONE;
            if(ISProfit==true)
               clr=fontColorProfit;
            else
               clr=fontColorLoss;
            ObjectSet(tName,OBJPROP_COLOR,clr);
            ObjectSet(tName,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSet(tName,OBJPROP_WIDTH,2);
            ObjectSet(tName,OBJPROP_RAY_RIGHT,false);
           }
        }
     }
//+------------------------------------------------------------------+
//| setDisplayTexts                                                  |
//+------------------------------------------------------------------+  
   string setDisplayTexts(double p,double cp,double GBP,double cGBP,int dig)
     {
      string val1=DoubleToStr(p,dig);
      string val2=DoubleToStr(GBP,2);
      string val3=DoubleToStr(cp,dig);
      string val4=DoubleToStr(cGBP,2);
      string str=NULL;
      str=StringConcatenate("P: ",val1);
      str=StringConcatenate(str,", £:",val2);
      str=StringConcatenate(str,"  CP: ",val3);
      str=StringConcatenate(str,", £: ",val4);
      return str;
     }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
   void OnDeinit(const int reason)
     {
      if(e_drawTrades>=3)
        {
         Print("SUMMARY");
         double durn=getElapsedTimeSecs(Time[shift+1],startDate)/(3600*24);
         string pWin=NULL;
         if(tInfo.numberTrades>0)
            pWin=DoubleToStr((tInfo.numberWins*100)/tInfo.numberTrades,0);
         else
            pWin="0";
         //Print (pWin," trades ",tInfo.numberWins," wins ", tInfo.numberTrades);
         Print(Sym," ",DoubleToStr(durn,0)," DAYS: "," £",DoubleToStr(tInfo.cGBP,0)," MAX DD: £",DoubleToStr(tInfo.maxDrawDown,0)," #TRADES: ",DoubleToStr(tInfo.numberTrades,0)," WIN: ",pWin,"%");
        }
      if(e_drawTrades==-2)
        {
         ////Print(__FUNCTION__," ",tInfo.startTime);
         ////Print(__FUNCTION__," ",Time[0]);
         //double durn=getElapsedTimeSecs(Time[0],tInfo.startTime);
         //durn=durn/(60*60*24);
         ////Print(__FUNCTION__," DURATION: ",durn);
         //Print(Sym," ExtCumProfit[1]: ",ExtCumProfit[1]);
         //Print(Sym," tInfo.profits: ",tInfo.cPoints);
         //Print(Sym," From: ",tInfo.startTime," To: ",Time[0]," Days: ",DoubleToStr(durn,0));
         //Print(Sym," tInfo.numberTrades: ",tInfo.numberTrades);
         //Print(Sym," tInfo.maxDrawDown: ",tInfo.maxDrawDown);
         //Print(__FUNCTION__,"**** DONE Indicator***** ",e_enumHTFWTFFilter," ",Sym,"fileName ",fileName);
        }
      do
        {
         for(int i=ObjectsTotal(); i>=0; i--)
            ObjectDelete(ObjectName(i));
        }
      while(ObjectsTotal()>0);

      //for(int i=ObjectsTotal()-1; i>=0; i--)
      //   ObjectDelete(ObjectName(i));
      //ChartRedraw();
      //  Sleep(200);
     }
//+------------------------------------------------------------------+
