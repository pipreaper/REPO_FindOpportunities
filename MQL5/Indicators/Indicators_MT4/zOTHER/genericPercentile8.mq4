//+------------------------------------------------------------------+
//|                                          generic percentiles.mq4 |
//|                                    Copyright 2017, Robert Baptie |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <WaveLibrary.mqh>
#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Red

int debug=0;

/////////////////////////////////******** WEIS WAVE ***********///////////////////////////////////
double  wavePoints=0;
bool    showWavesInfo=false;//Display Wave Index
bool    showPrice=false;
bool    showVolume=false;
bool    showTime=false;
bool    drawWave=false;
/////////////////////////////////*******************///////////////////////////////////

extern string thisIndicator="SQU";//WEI, VOL, TIM, STD, ATR, MOM, RSI, ADX CLO  VUP VDN
extern congestionType typeOfCongestion=INSIDE;
extern int maPeriod=14;//%k
extern int maShift = 0;
//----------stochs
extern int percentD=3;
extern int slowing =3;
//PRICE_CLOSE 0 Close price
//PRICE_OPEN 1 Open price
//PRICE_HIGH 2 The maximum price for the period
//PRICE_LOW 3 The minimum price for the period
//PRICE_MEDIAN 4 Median price, (high + low)/2
//PRICE_TYPICAL 5 Typical price, (high + low + close)/3
//PRICE_WEIGHTED 6 Weighted close price, (high + low + close + close)/4
extern int maMethod=0;

//MODE_SMA 0 Simple averaging
//MODE_EMA 1 Exponential averaging
//MODE_SMMA 2 Smoothed averaging 
//MODE_LWMA 3 Linear-weighted averaging
extern int maAvgMethod=0;

const int sizePercentiles=100;
extern double lowerPercentile=5;//low percent
extern double lowerMiddlePercentile=20;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=80;//upper Middle Percentile
extern double upperPercentile=95;//upper percentile
extern bool EA=false;
double percentiles[100,2];
string uniqueUpperLine="";
string uniqueUpperMiddleLine="";
string uniqueMiddleLine="";
string uniqueLowerMiddleLine="";
string uniqueLowerLine="";
double lPrice=0.1,hPrice=0.5;
int chartid=-1;
double ExtValueBuffer[];
double ExtPercentBuffer[];
double ExtPercentileLevels[];
double    pLL=-1,pLML=-1,pML=-1,pUML=-1,pUL=-1;
// ===================
// Squeeze
// ===================
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=3;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=3.0; // Bands Deviations
extern int    maxBarsDraw=1000;
//+------------------------------------------------------------------+
//|Initialise                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   IndicatorDigits(Digits);

   pLL=-1;pLML=-1;pML=-1;pUML=-1;pUL=-1;
   string textName1=thisIndicator;
   string textName2="level";
   if(!EA)
     {
      for(int i=ObjectsTotal() -1; i>=0; i--)
        {//Tidy old lines
         string objName=ObjectName(i);
         if(StringSubstr(objName,0,3)==textName1 || StringSubstr(objName,0,5)==textName2)
           {
            ObjectDelete(ObjectName(i));
            // Print("deleted ",objName);
           }
        }
     }
   IndicatorBuffers(3);

   chartid=ChartWindowFind();
   uniqueUpperLine=thisIndicator+Symbol()+" "+string(Period())+" "+string(chartid)+string(maPeriod)+"ULine ";
   uniqueUpperMiddleLine=thisIndicator+Symbol()+" "+string(Period())+" "+string(chartid)+string(maPeriod)+"UMLine ";
   uniqueMiddleLine=thisIndicator+Symbol()+" "+string(Period())+" "+string(chartid)+string(maPeriod)+"MLine ";
   uniqueLowerMiddleLine=thisIndicator+Symbol()+" "+string(Period())+" "+string(chartid)+string(maPeriod)+"LMLine ";
   uniqueLowerLine=thisIndicator+Symbol()+" "+string(Period())+" "+string(chartid)+string(maPeriod)+"LLine ";
   if(!EA)
     {
      HLineCreate(ChartID(),uniqueUpperLine,chartid,hPrice,clrGreen,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueUpperMiddleLine,chartid,hPrice,clrLawnGreen,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueMiddleLine,chartid,hPrice,clrBlue,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueLowerMiddleLine,chartid,hPrice,clrAquamarine,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueLowerLine,chartid,hPrice,clrRed,1,1,false,false,true,0);
     }
//--- indicator buffers mapping
   IndicatorShortName(thisIndicator+" Percentiles");
//--- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   if(thisIndicator=="WEI")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrRed);
   if(thisIndicator=="PRI")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrBlue);
   if(thisIndicator=="TIM")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrGreen);
   if(thisIndicator=="VOL")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrChocolate);
   if(thisIndicator=="STD")
      SetIndexStyle(0,DRAW_LINE,0,2,clrBlue);
   if(thisIndicator=="ATR")
      SetIndexStyle(0,DRAW_LINE,0,2,clrAquamarine);
   if(thisIndicator=="ADX")
      SetIndexStyle(0,DRAW_LINE,0,2,clrBrown);
   if(thisIndicator=="MOM")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrBlue);
   if(thisIndicator=="RSI")
      SetIndexStyle(0,DRAW_LINE,0,2,clrRed);
   if(thisIndicator=="CLO")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrBlueViolet);
   if(thisIndicator=="VUP")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrBlue);
   if(thisIndicator=="VDN")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrRed);
   if(thisIndicator=="STO")
      SetIndexStyle(0,DRAW_LINE,0,2,clrRosyBrown);
   if(thisIndicator=="SQU")
      SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrGreen);

   SetIndexBuffer(0,ExtValueBuffer);

   SetIndexBuffer(1,ExtPercentBuffer);
   SetIndexStyle(1,DRAW_NONE,0,1,clrRed);
   SetIndexLabel(1,"Perc Buffer");
//Holds percentile levels array
   SetIndexBuffer(2,ExtPercentileLevels);
   SetIndexStyle(2,DRAW_NONE,0,1,clrRed);
   SetIndexLabel(2,"Percent Levels");
//---
   ChartForegroundSet(true,ChartID());
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
   double buffer=-1;
   double lowerLine=0,upperLine=0,lowerMiddleLine=0,middleLine=0,upperMiddleLine=0;
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);//need for check where curr3ent wave is in this GENERIC indicator ....Not the ones it calls!
   ArraySetAsSeries(open,true);

   int limit=rates_total-prev_calculated;
   if(rates_total<=maPeriod || rates_total<=maPeriod)
      return(0);
   if(prev_calculated>0)
      limit++;
   for(int shift=0; shift<limit; shift++)
     {
      if(thisIndicator=="STD")
         buffer=iStdDev(Symbol(),Period(),maPeriod,maShift,maMethod,maAvgMethod,shift);
      else if(thisIndicator=="ADX")
         buffer=iADX(Symbol(),Period(),maPeriod,maShift,maMethod,shift);
      else if(thisIndicator=="STO")
         buffer=iStochastic(Symbol(),Period(),maPeriod,percentD,slowing,MODE_SMA,0,MODE_MAIN,shift); //MODE_MAIN Buffer Zero     
      else if(thisIndicator=="RSI")
         buffer=iRSI(Symbol(),Period(),maPeriod,maShift,shift);
      else if(thisIndicator=="ATR")
         buffer=iATR(Symbol(),Period(),maPeriod,shift);
      //  else if(thisIndicator=="MOM")
      //    buffer=iMomentum(Symbol(),Period(),maPeriod,maMethod,shift);
      else if(thisIndicator=="VOL")
        {
         buffer=iCustom(Symbol(),Period(),"volMA",1,3,0,shift);//UP
         if(buffer== EMPTY_VALUE)
            buffer=iCustom(Symbol(),Period(),"volMA",1,3,1,shift);//DOWN
        }
      else if(thisIndicator=="TIM")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,7,shift);
      else if(thisIndicator=="PRI")
         buffer=MathAbs(iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,5,shift));
      else if(thisIndicator=="WEI")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,6,shift);
      else if(thisIndicator=="CLO")
        {
         buffer=iCustom(Symbol(),Period(),"closePrice",0,shift);//UP
         if(buffer== EMPTY_VALUE)
            buffer=iCustom(Symbol(),Period(),"closePrice",1,shift);//DOWN
        }
      else if(thisIndicator=="VUP")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,0,shift);
      else if(thisIndicator=="VDN")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,1,shift);
      else if(thisIndicator=="SQU")
        {
         buffer=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,shift);
         if(buffer==EMPTY_VALUE)
            buffer=0;
        }
      else
        {
         Print(__FUNCTION__,"_There is no facility for calculating: ",thisIndicator);
         return(rates_total);
        }
      ExtValueBuffer[0]=buffer;
      if(shift>=rates_total-maPeriod-1)
         ExtValueBuffer[shift]=EMPTY_VALUE;
      else
         ExtValueBuffer[shift]=buffer;
     }
   if(isNewBar)
     {
      repaint(close,rates_total,prev_calculated);
      pLL=lowerLine;pLML=lowerMiddleLine;pML=middleLine;pUML=upperMiddleLine;pUL=upperLine;
      calcPercentiles(rates_total,lowerLine,lowerMiddleLine,middleLine,upperMiddleLine,upperLine);
      if((pLL!=lowerLine) || (pLML!=lowerMiddleLine) || (pML!=middleLine) || (pUML!=upperMiddleLine) || (pUL!=upperLine))
        {
         updatePercentilesSeries(rates_total,lowerLine,lowerMiddleLine,middleLine,upperMiddleLine,upperLine);
         storeLevels(lowerLine,lowerMiddleLine,middleLine,upperMiddleLine,upperLine);
        }
      //  Print(thisIndicator," ",lowerLine," ",lowerMiddleLine," ",middleLine," ",upperMiddleLine," ",upperLine);
      if(!EA)
        {
         HLineMove(ChartID(),uniqueUpperLine,upperLine);
         HLineMove(ChartID(),uniqueUpperMiddleLine,upperMiddleLine);
         HLineMove(ChartID(),uniqueMiddleLine,middleLine);
         HLineMove(ChartID(),uniqueLowerMiddleLine,lowerMiddleLine);
         HLineMove(ChartID(),uniqueLowerLine,lowerLine);
        }
     }
   else
     {
      if(thisIndicator=="STD")
         buffer=iStdDev(Symbol(),Period(),maPeriod,maShift,maMethod,maAvgMethod,0);
      else if(thisIndicator=="ADX")
         buffer=iADX(Symbol(),Period(),maPeriod,maShift,maMethod,0);
      else if(thisIndicator=="STO")
         buffer=iStochastic(Symbol(),Period(),maPeriod,percentD,slowing,MODE_SMA,0,MODE_MAIN,0); //MODE_MAIN Buffer Zero                   
      else if(thisIndicator=="RSI")
         buffer=iRSI(Symbol(),Period(),maPeriod,maShift,0);
      else if(thisIndicator=="ATR")
         buffer=iATR(Symbol(),Period(),maPeriod,0);
      else if(thisIndicator=="VOL")
        {
         buffer=iCustom(Symbol(),Period(),"volMA",1,3,0,0);//UP
         if(buffer== EMPTY_VALUE)
            buffer=iCustom(Symbol(),Period(),"volMA",1,3,1,0);//DOWN
        }
      //     else if(thisIndicator=="MOM")
      //        buffer=iMomentum(Symbol(),Period(),maPeriod,maMethod,0);
      else if(thisIndicator=="TIM")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,7,0);
      else if(thisIndicator=="PRI")
         buffer=MathAbs(iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,5,0));
      else if(thisIndicator=="WEI")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,6,0);
      else if(thisIndicator=="VUP")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,0,0);
      else if(thisIndicator=="VDN")
         buffer=iCustom(Symbol(),Period(),"zzz4",wavePoints,showWavesInfo,showPrice,showVolume,showTime,drawWave,1,0);
      else if(thisIndicator=="SQU")
        {
         buffer=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,maxBarsDraw,0,0);
         if(buffer== EMPTY_VALUE)
         buffer=0;
        }
      ExtValueBuffer[0]=buffer;
     }
   return(rates_total);
  }
//store levels values
void storeLevels(double lowerLine,double lowerMiddleLine,double middleLine,double upperMiddleLine,double upperLine)
  {
   ExtPercentileLevels[0]=lowerLine;
   ExtPercentileLevels[1]=lowerMiddleLine;
   ExtPercentileLevels[2]=middleLine;
   ExtPercentileLevels[3]=upperMiddleLine;
   ExtPercentileLevels[4]=upperLine;

  }
//Put current percentiles into buffer
void updatePercentilesSeries(int rt,double LL,double LML,double ML,double UML,double UL)
  {
   for(int shift=0; shift<rt; shift++)
     {
      if(ExtValueBuffer[shift]==EMPTY_VALUE)
        {
         ExtPercentBuffer[shift]=EMPTY_VALUE;
         continue;
        }
      if(ExtValueBuffer[shift]>=UL)
        {
         ExtPercentBuffer[shift]=upperPercentile;//greater than or equal 95 
         continue;
        }
      if(ExtValueBuffer[shift]>=UML)
        {
         ExtPercentBuffer[shift]=upperMiddlePercentile;//greater than or equal 75 less than 95     
         continue;
        }
      if(ExtValueBuffer[shift]>=ML)
        {
         ExtPercentBuffer[shift]=middlePercentile;///greater than or equal 50 less than 75
         continue;
        }
      if(ExtValueBuffer[shift]>=LML)
        {
         ExtPercentBuffer[shift]=lowerMiddlePercentile;//greater than or equal 25 less than 50      
         continue;
        }
      if(ExtValueBuffer[shift]>=LL)
        {
         ExtPercentBuffer[shift]=lowerPercentile;///greater than or equal 5
         continue;
        }
      else
         ExtPercentBuffer[shift]=0;//less than lowerPercentile             
     }
  }
//Build new percentile lines from new bar
void calcPercentiles(int rt,double &lp,double &lmp,double &mp,double &hmp,double &up)
  {
//Count Valid DataPoints
   int countDataPoints=0;
//Initialise percentile ExtSTDBuffers        
   for(int y=0; y<sizePercentiles; y++)
     {
      percentiles[y][0] = 0;
      percentiles[y][1] = 0;
     }
//Find data extremes  
   double dataMin=INF;
   double dataMax=-INF;
   for(int shift=0; shift<rt; shift++)
     {
      if(ExtValueBuffer[shift]==EMPTY_VALUE)
         continue;// ignore no datapoint for purpose of calculation of percentiles
      countDataPoints++;
      double bs=ExtValueBuffer[shift];
      dataMax=MathMax(dataMax,ExtValueBuffer[shift]);
      dataMin= MathMin(dataMin,ExtValueBuffer[shift]);
     }
   double step=(dataMax-dataMin)/(double)sizePercentiles;
//carve max data into equal buckets
   for(int y=0; y<sizePercentiles; y++)
      percentiles[y][0]=dataMin+(y+1)*step; //percentiles[0] dimension 0 - 9 buckets, filled with 1 -10 data slice
// for each data point     
   for(int shift=0; shift<rt; shift++)
     {
      if(ExtValueBuffer[shift]==EMPTY_VALUE)
         continue;
      //allocate to distribution bucket with relevantfrequency
      for(int y=0; y<=sizePercentiles-1; y++)
        {
         if(y==0 && (ExtValueBuffer[shift]<=percentiles[y][0]))
           {//first bucket
            percentiles[y][1]+=1;
            break;
           }
         if((y==sizePercentiles-1) && (ExtValueBuffer[shift]>=percentiles[y][0]))
           {//last bucket
            percentiles[y][1]+=1;
            break;
           }
         if((ExtValueBuffer[shift]<=percentiles[y][0]) && (ExtValueBuffer[shift]>percentiles[y-1][0]))//fails on y zero but handled in first constraint
           {
            percentiles[y][1]+=1;
            break;
           }
        }
     }
//Construct cumulative frequency counts
   for(int y=0; y<sizePercentiles; y++)
     {
      if(y==0)
        {
         percentiles[y][1]=percentiles[y][1];
         continue;
        }
      percentiles[y][1]+=percentiles[y-1][1];
     }

//Set Line percentile levels     
   double lowCount=countDataPoints*lowerPercentile/100;
   double lowMiddleCount=countDataPoints*lowerMiddlePercentile/100;
   double middleCount=countDataPoints*middlePercentile/100;
   double highMiddleCount=countDataPoints*upperMiddlePercentile/100;
   double highCount=countDataPoints*upperPercentile/100;
   bool isLower=false,isLowMiddle=false,isMiddle=false,isHighMiddle=false,isUpper=false;
   for(int y=0; y<sizePercentiles; y++)
     {
      if(percentiles[y][1]>=lowCount && !isLower) //>5%
        {
         lp=percentiles[y][0];
         isLower=true;
        }
      if(percentiles[y][1]>=lowMiddleCount && !isLowMiddle)
        {
         lmp=percentiles[y][0];
         isLowMiddle=true;
        }
      if(percentiles[y][1]>=middleCount && !isMiddle)
        {
         mp=percentiles[y][0];
         isMiddle=true;
        }
      if(percentiles[y][1]>=highMiddleCount && !isHighMiddle)
        {
         hmp=percentiles[y][0];
         isHighMiddle=true;
        }
      if(percentiles[y][1]>=highCount && !isUpper)
        {
         up=percentiles[y][0];
         isUpper=true;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void repaint(const double &c[],int pc,int rt)
  {
   int cnt=0;
   int point1=-1,point2=-1,point3=-1;
//remove old leading value      
   if(((thisIndicator=="WEI") || (thisIndicator=="TIM") || (thisIndicator=="PRI")) && pc!=0)
     {
      // Print("rates total ",rates_total);
      for(int shift=0; shift<rt-1; shift++)
        {
         if(ExtValueBuffer[shift]!=EMPTY_VALUE && cnt==0)
           {
            point1=shift;
            cnt++;
            continue;
           }
         else if(ExtValueBuffer[shift]!=EMPTY_VALUE && cnt==1)
           {
            point2=shift;
            cnt++;
            continue;
           }
         else if(ExtValueBuffer[shift]!=EMPTY_VALUE && cnt==2)
           {
            point3=shift;
            cnt++;
            //determine if its additive wave or new direction
            //check at zero because close array is set as series TRUE
            if(((c[point3]<c[point2]) && (c[point2]<c[point1])) || ((c[point3]>c[point2]) && (c[point2]>c[point1])))
              {
               ExtValueBuffer[point2]=EMPTY_VALUE;
               // Print("BINGO! ",thisIndicator," point3 ",point3, " close[point3] ",close[point3], " point2 ",point2, " close[point2] ",close[point2],  "point1 ",point1, " close[point1] ",close[point1] );
              }
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

//--- The first way to get the uninitialization reason code
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
//--- The second way to get the uninitialization reason code
   Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));
//  HLineDelete(chartid,"LSTD");?Not working
//  HLineDelete(chartid,"HSTD");
  }
//+------------------------------------------------------------------+
