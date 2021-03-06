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

const int sizePercentiles=100;

extern bool drawLines=true;
extern double lowerPercentile=4;//low percent
extern double lowerMiddlePercentile=14;//lower middle Percentile
extern double middlePercentile=50;//middle percentile
extern double upperMiddlePercentile=80;//upper Middle Percentile
extern double upperPercentile=95;//upper percentile
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=3.0; // Bands Deviations
                                   //extern int    maxBarsDraw=5000;
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
double ExtState[];
int shift=NULL;
int limit= NULL;
double    pLL=-1,pLML=-1,pML=-1,pUML=-1,pUL=-1;
//+------------------------------------------------------------------+
//|Initialise                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//  IndicatorDigits(Digits);
   pLL=-1;pLML=-1;pML=-1;pUML=-1;pUL=-1;

   IndicatorBuffers(3);
   subWindow=ChartWindowFind();
   uniqueUpperLine="ULine";
   uniqueUpperMiddleLine="UMLine";
   uniqueMiddleLine="MLine";
   uniqueLowerMiddleLine="LMLine";
   uniqueLowerLine="LLine";
   if(drawLines)
     {
      HLineCreate(ChartID(),uniqueUpperLine,subWindow,hPrice,clrGreen,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueUpperMiddleLine,subWindow,hPrice,clrLawnGreen,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueMiddleLine,subWindow,hPrice,clrBlue,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueLowerMiddleLine,subWindow,hPrice,clrAquamarine,1,1,false,false,true,0);
      HLineCreate(ChartID(),uniqueLowerLine,subWindow,hPrice,clrRed,1,1,false,false,true,0);
     }
// Print("* INIT: ",uniqueUpperLine," ",uniqueUpperMiddleLine," ",uniqueMiddleLine," ",uniqueLowerMiddleLine," ",uniqueLowerLine);
//--- indicator buffers mapping
   IndicatorShortName("get Levels BB");
   SetIndexStyle(0,DRAW_HISTOGRAM,0,2,clrGreen);
   SetIndexBuffer(0,ExtValueBuffer);

   SetIndexBuffer(1,ExtPercentBuffer);
   SetIndexStyle(1,DRAW_NONE,0,1,clrRed);
   SetIndexLabel(1,"Perc Buffer");

   SetIndexStyle(2,DRAW_ARROW,0,5,clrCornflowerBlue);
   SetIndexArrow(2,158);
   SetIndexLabel(2,"STATUS BB");
   SetIndexBuffer(2,ExtState);
   SetIndexEmptyValue(2,EMPTY_VALUE);
// SetIndexDrawBegin(3,drawBegin);

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
   double buffer=-1,bufferP=-1;
   double lowerLine=0,upperLine=0,lowerMiddleLine=0,middleLine=0,upperMiddleLine=0;
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];
   bool direction=true;
   ArraySetAsSeries(time,direction);
   ArraySetAsSeries(high,direction);
   ArraySetAsSeries(low,direction);
   ArraySetAsSeries(time,direction);
   ArraySetAsSeries(close,direction);//need for check where curr3ent wave is in this GENERIC indicator ....Not the ones it calls!
   ArraySetAsSeries(open,direction);

   ArraySetAsSeries(ExtValueBuffer,direction);
   ArraySetAsSeries(ExtPercentBuffer,direction);
   ArraySetAsSeries(ExtState,direction);

//int limit=rates_total-prev_calculated;
//if(rates_total<=0)
//   return(0);
//if(prev_calculated>0)
//   limit++;
//if(isNewBar)
//  {
//   for(int shift=0; shift<limit-1; shift++)
//     {
   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit; shift>=0; shift--)//start rates_total down to zero
        {
         if(shift>=rates_total-Boll_Period-1)
            continue;
         buffer=(iBands(Symbol(),Period(),Boll_Period,Boll_Deviations,0,PRICE_CLOSE,MODE_UPPER,shift+1)-iBands(NULL,0,Boll_Period,Boll_Deviations,0,PRICE_CLOSE,MODE_LOWER,shift+1))
                /iMA(NULL,0,Boll_Period,0,MODE_SMA,PRICE_CLOSE,shift+1);
      //   bufferP=(iBands(Symbol(),Period(),Boll_Period,Boll_Deviations,0,PRICE_CLOSE,MODE_UPPER,shift+2)-iBands(NULL,0,Boll_Period,Boll_Deviations,0,PRICE_CLOSE,MODE_LOWER,shift+2))
    //             /iMA(NULL,0,Boll_Period,0,MODE_SMA,PRICE_CLOSE,shift+2);
         //Print(" shift: ",shift,"time buffer: ",time[shift+1]," buffer: ",buffer,"time bufferP: ",time[shift+2]," bufferP:",bufferP," buffer>=bufferP: ",(buffer>=bufferP));
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
      for(shift=limit; shift>=0; shift--)//start rates_total down to zero
        {
         if(shift>=rates_total-Boll_Period-1)
            continue;             
         if((ExtValueBuffer[shift+2]<=lowerMiddleLine) && (ExtValueBuffer[shift+1]>=lowerMiddleLine))
            ExtState[shift+1]=ExtValueBuffer[shift+1];
        }
     }
   return(rates_total);
  }
//Put current percentiles into buffer
void updatePercentilesSeries(int rt,double LL,double LML,double ML,double UML,double UL)
  {
   for(shift=0; shift<rt; shift++)
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
   for(shift=0; shift<rt; shift++)
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
   for(shift=0; shift<rt; shift++)
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
      ObjectDelete(ObjectName(i));
     }
//--- The first way to get the uninitialization reason code
//Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
//--- The second way to get the uninitialization reason code
//Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));
//  HLineDelete(chartid,"LSTD");?Not working
//  HLineDelete(chartid,"HSTD");
  }
//+------------------------------------------------------------------+
