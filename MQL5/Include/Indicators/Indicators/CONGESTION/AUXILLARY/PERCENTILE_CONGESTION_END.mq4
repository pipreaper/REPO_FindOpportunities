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
#property indicator_buffers 2
#property indicator_color1 Red

const int sizePercentiles=100;

extern bool drawLines=false;
extern double lowerPercentile=5;//low percent
extern double lowerMiddlePercentile=20;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=95;//upper Middle Percentile
extern double upperPercentile=100;//upper percentile
                                  //Squeeze
extern congestionType typeOfCongestion=INSIDE;
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=1.5;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=2.0; // Bands Deviations
double percentiles[100,2];
string uniqueUpperLine="";
string uniqueUpperMiddleLine="";
string uniqueMiddleLine="";
string uniqueLowerMiddleLine="";
string uniqueLowerLine="";
double lPrice=0.1,hPrice=0.5;
int subWindow=-1;
double ExtValueBuffer[];
double ExtPercentBuffer[];

double    pLL=-1,pLML=-1,pML=-1,pUML=-1,pUL=-1;
//+------------------------------------------------------------------+
//|Initialise                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   pLL=-1;pLML=-1;pML=-1;pUML=-1;pUL=-1;

   IndicatorBuffers(2);
   subWindow=ChartWindowFind();
   uniqueUpperLine="ULine"+string(Period());
   uniqueUpperMiddleLine="UMLine"+string(Period());
   uniqueMiddleLine="MLine"+string(Period());
   uniqueLowerMiddleLine="LMLine"+string(Period());
   uniqueLowerLine="LLine"+string(Period());
   if(drawLines)
     {
      HLineCreate(ChartID(),uniqueUpperLine,subWindow,hPrice,clrGreen,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueUpperMiddleLine,subWindow,hPrice,clrLawnGreen,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueMiddleLine,subWindow,hPrice,clrBlue,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueLowerMiddleLine,subWindow,hPrice,clrAquamarine,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueLowerLine,subWindow,hPrice,clrRed,1,1,false,false,true,0);
     }
//--- indicator buffers mapping
   IndicatorShortName("get Levels SQU");
   SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrGreen);
   SetIndexBuffer(0,ExtValueBuffer);

   SetIndexBuffer(1,ExtPercentBuffer);
   SetIndexStyle(1,DRAW_NONE,0,1,clrRed);
   SetIndexLabel(1,"Perc Buffer");

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

   ArraySetAsSeries(ExtValueBuffer,true);
   ArraySetAsSeries(ExtPercentBuffer,true);

   int limit=rates_total-prev_calculated;
   if(rates_total<=0)
      return(0);
   if(prev_calculated>0)
      limit++;
   if(isNewBar)
     {
      for(int shift=0; shift<limit-1; shift++)
        {
         buffer=iCustom(Symbol(),Period(),"SqueezeBreak",typeOfCongestion,
                        Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,Boll_Period,Boll_Shift,Boll_Deviations,0,shift+1);
         if(buffer==EMPTY_VALUE)
            buffer=0;
         if(shift>=rates_total-1)
            ExtValueBuffer[shift+1]=0;
         else
            ExtValueBuffer[shift+1]=buffer;
        }
      pLL=lowerLine;pLML=lowerMiddleLine;pML=middleLine;pUML=upperMiddleLine;pUL=upperLine;
      calcPercentiles(rates_total,lowerLine,lowerMiddleLine,middleLine,upperMiddleLine,upperLine);
      if((pLL!=lowerLine) || (pLML!=lowerMiddleLine) || (pML!=middleLine) || (pUML!=upperMiddleLine) || (pUL!=upperLine))
         updatePercentilesSeries(rates_total,lowerLine,lowerMiddleLine,middleLine,upperMiddleLine,upperLine);
      //  Print("* BEFORE ERROR: ",uniqueUpperLine," ",uniqueUpperMiddleLine," ",uniqueMiddleLine," ",uniqueLowerMiddleLine," ",uniqueLowerLine);
      //  Print("* * LINES lowerLine: ",lowerLine," lowerMiddleLine: ",lowerMiddleLine," middleLine: ",middleLine," upperMiddleLine: ",upperMiddleLine," upperLine: ",upperLine);
      if(drawLines)
        {
         HLineMove(ChartID(),uniqueUpperLine,upperLine);
         HLineMove(ChartID(),uniqueUpperMiddleLine,upperMiddleLine);
         HLineMove(ChartID(),uniqueMiddleLine,middleLine);
         HLineMove(ChartID(),uniqueLowerMiddleLine,lowerMiddleLine);
         HLineMove(ChartID(),uniqueLowerLine,lowerLine);
        }
     }
   return(rates_total);
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
//void repaint(const double &c[],int pc,int rt)
//  {
//   int cnt=0;
//   int point1=-1,point2=-1,point3=-1;
////remove old leading value      
//   if(((thisIndicator=="WEI") || (thisIndicator=="TIM") || (thisIndicator=="PRI")) && pc!=0)
//     {
//      // Print("rates total ",rates_total);
//      for(int shift=0; shift<rt-1; shift++)
//        {
//         if(ExtValueBuffer[shift]!=EMPTY_VALUE && cnt==0)
//           {
//            point1=shift;
//            cnt++;
//            continue;
//           }
//         else if(ExtValueBuffer[shift]!=EMPTY_VALUE && cnt==1)
//           {
//            point2=shift;
//            cnt++;
//            continue;
//           }
//         else if(ExtValueBuffer[shift]!=EMPTY_VALUE && cnt==2)
//           {
//            point3=shift;
//            cnt++;
//            //determine if its additive wave or new direction
//            //check at zero because close array is set as series TRUE
//            if(((c[point3]<c[point2]) && (c[point2]<c[point1])) || ((c[point3]>c[point2]) && (c[point2]>c[point1])))
//              {
//               ExtValueBuffer[point2]=EMPTY_VALUE;
//               // Print("BINGO! ",thisIndicator," point3 ",point3, " close[point3] ",close[point3], " point2 ",point2, " close[point2] ",close[point2],  "point1 ",point1, " close[point1] ",close[point1] );
//              }
//            break;
//           }
//        }
//     }
//  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      // string nm=ObjectName(i);
      // Print("Deinit ",nm);
      //  ObjectDelete(ObjectName(i));
     }
//--- The first way to get the uninitialization reason code
//Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
//--- The second way to get the uninitialization reason code
//Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));
//  HLineDelete(chartid,"LSTD");?Not working
//  HLineDelete(chartid,"HSTD");
   if(drawLines)
     {
   if(drawLines)
     {
      ObjectDelete("ULine"+string(Period()));
      ObjectDelete("UMLine"+string(Period()));
      ObjectDelete("MLine"+string(Period()));
      ObjectDelete("LMLine"+string(Period()));
      ObjectDelete("LLine"+string(Period()));
     }
     }
  }
//+------------------------------------------------------------------+
