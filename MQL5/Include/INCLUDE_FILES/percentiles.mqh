//+------------------------------------------------------------------+
//|                                                  percentiles.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <WaveLibrary.mqh>
#include <Arrays\List.mqh>
//percentiles

//+------------------------------------------------------------------+
//|instrument                                                        |
//+------------------------------------------------------------------+
class percentilesClass : public CObject
  {
public:
   bool              drawlines;
   string            stdText;
   int               sizePercentiles;
   double            lPrice,hPrice;
 //  double            pLL,pLML,pML,pUML,pUL;
   double            percentiles[100,2];
   string            uniqueUpperLine;
   string            uniqueUpperMiddleLine;
   string            uniqueMiddleLine;
   string            uniqueLowerMiddleLine;
   string            uniqueLowerLine;
   double            lowerLine,upperLine,lowerMiddleLine,middleLine,upperMiddleLine;
   bool              drawLines;
   double            lowerPercentile;//low percent
   double            lowerMiddlePercentile;//lower middle Percentile
   double            middlePercentile;//middle percentile
   double            upperMiddlePercentile;//upper Middle Percentile
   double            upperPercentile;//upper percentile   
   int               rt;
                     percentilesClass(string sy,int tf,bool dl,string sText,double LOWER_PERCENTILE, double LOWER_MIDDLE_PERCENTILE, double MIDDLE_PERCENTILE, double UPPER_MIDDLE_PERCENTILE, double UPPER_PERCENTILE)
     {
      sizePercentiles=100;
      lPrice=0.1;hPrice=0.5;
   //   pLL=-1;pLML=-1;pML=-1;pUML=-1;pUL=-1;
      //    percentiles[100,2];
      uniqueUpperLine="";
      uniqueUpperMiddleLine="";
      uniqueMiddleLine="";
      uniqueLowerMiddleLine="";
      uniqueLowerLine="";
      lowerLine=0;upperLine=0;lowerMiddleLine=0;middleLine=0;upperMiddleLine=0;
      rt=Bars(sy,tf);
      drawLines=dl;
      stdText=sText;
      lowerPercentile=LOWER_PERCENTILE;//low percent
      lowerMiddlePercentile=LOWER_MIDDLE_PERCENTILE;//lower middle Percentile
      middlePercentile=MIDDLE_PERCENTILE;//middle percentile
      upperMiddlePercentile=UPPER_MIDDLE_PERCENTILE;//upper Middle Percentile
      upperPercentile=UPPER_PERCENTILE;//upper percentile      
     }
                    ~percentilesClass()
     {
      ObjectDelete("ULine"+stdText);
      ObjectDelete(uniqueUpperLine);
      ObjectDelete(uniqueUpperMiddleLine);
      ObjectDelete(uniqueMiddleLine);
      ObjectDelete(uniqueLowerMiddleLine);
      ObjectDelete(uniqueLowerLine);
     }
   //+------------------------------------------------------------------+
   //| moveLines                                                        |
   //+------------------------------------------------------------------+  
   void  moveLines()
     {
      if(drawLines)
        {
         HLineMove(ChartID(),uniqueUpperLine,upperLine);
         HLineMove(ChartID(),uniqueUpperMiddleLine,upperMiddleLine);
         HLineMove(ChartID(),uniqueMiddleLine,middleLine);
         HLineMove(ChartID(),uniqueLowerMiddleLine,lowerMiddleLine);
         HLineMove(ChartID(),uniqueLowerLine,lowerLine);
        }
     }
   //+------------------------------------------------------------------+
   //| initialise percentile variables                                  |
   //+------------------------------------------------------------------+  
   void  initPercentileLines()
     {
  //    pLL=-1;pLML=-1;pML=-1;pUML=-1;pUL=-1;
      uniqueUpperLine="ULine"+stdText;
      uniqueUpperMiddleLine="UMLine"+stdText;
      uniqueMiddleLine="MLine"+stdText;
      uniqueLowerMiddleLine="LMLine"+stdText;
      uniqueLowerLine="LLine"+stdText;
      if(drawLines)
        {
         int chartWin=ChartWindowFind();
         HLineCreate(ChartID(),uniqueUpperLine,chartWin,hPrice,clrGreen,1,1,false,false,true,0);
         HLineCreate(ChartID(),uniqueUpperMiddleLine,chartWin,hPrice,clrLawnGreen,1,1,false,false,true,0);
         HLineCreate(ChartID(),uniqueMiddleLine,chartWin,hPrice,clrBlue,1,1,false,false,true,0);
         HLineCreate(ChartID(),uniqueLowerMiddleLine,chartWin,hPrice,clrAquamarine,1,1,false,false,true,0);
         HLineCreate(ChartID(),uniqueLowerLine,chartWin,hPrice,clrRed,1,1,false,false,true,0);
        }
      //     pc.calcDisplayPercentileLines(ExtPercentBuffer,ExtValueBuffer);             
     }
   //+------------------------------------------------------------------+
   //| calculatePercentiles                                             |
   //+------------------------------------------------------------------+  
   void  calcDisplayPercentileLines(double &EPB[],double &EVB[])
     {
      double pLL=lowerLine,pLML=lowerMiddleLine,pML=middleLine,pUML=upperMiddleLine,pUL=upperLine;
      calcPercentiles(EVB);
  //    if((pLL!=lowerLine) || (pLML!=lowerMiddleLine) || (pML!=middleLine) || (pUML!=upperMiddleLine) || (pUL!=upperLine))
    //    {
         updatePercentilesSeries(EPB,EVB);
         if(drawLines)
            moveLines();
      //  }
     }
   //+------------------------------------------------------------------+
   //|Put current percentiles into buffer                               |
   //+------------------------------------------------------------------+  
   void updatePercentilesSeries(double &EPB[],double &EVB[])
     {
      for(int Shift=0; Shift<rt; Shift++)
        {
         if(EVB[Shift]==EMPTY_VALUE)
           {
            EPB[Shift]=EMPTY_VALUE;
            continue;
           }
         if(EVB[Shift]>=upperLine)
           {
            EPB[Shift]=upperPercentile;//greater than or equal 95 
            continue;
           }
         if(EVB[Shift]>=upperMiddleLine)
           {
            EPB[Shift]=upperMiddlePercentile;//greater than or equal 75 less than 95   
            continue;
           }
         if(EVB[Shift]>=middleLine)
           {
            EPB[Shift]=middlePercentile;///greater than or equal 50 less than 75
            continue;
           }
         if(EVB[Shift]>=lowerMiddleLine)
           {
            EPB[Shift]=lowerMiddlePercentile;//greater than or equal 25 less than 50      
            continue;
           }
         if(EVB[Shift]>=lowerLine)
           {
            EPB[Shift]=lowerPercentile;///greater than or equal 5
            continue;
           }
         else
            EPB[Shift]=0;//less than lowerPercentile             
        }
     }
   //+------------------------------------------------------------------+
   //|Build new percentile lines from new bar                           |
   //+------------------------------------------------------------------+   
   void calcPercentiles(double &EVB[])
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
      for(int Shift=0; Shift<rt; Shift++)
        {
         if(EVB[Shift]==EMPTY_VALUE)
            continue;// ignore no datapoint for purpose of calculation of percentiles
         countDataPoints++;
         double bs=EVB[Shift];
         dataMax=MathMax(dataMax,EVB[Shift]);
         dataMin= MathMin(dataMin,EVB[Shift]);
        }
      double step=(dataMax-dataMin)/(double)sizePercentiles;
      //carve max data into equal buckets
      for(int y=0; y<sizePercentiles; y++)
         percentiles[y][0]=dataMin+(y+1)*step; //percentiles[0] dimension 0 - 9 buckets, filled with 1 -10 data slice
      // for each data point     
      for(int Shift=0; Shift<rt; Shift++)
        {
         if(EVB[Shift]==EMPTY_VALUE)
            continue;
         //allocate to distribution bucket with relevantfrequency
         for(int y=0; y<=sizePercentiles-1; y++)
           {
            if(y==0 && (EVB[Shift]<=percentiles[y][0]))
              {//first bucket
               percentiles[y][1]+=1;
               break;
              }
            if((y==sizePercentiles-1) && (EVB[Shift]>=percentiles[y][0]))
              {//last bucket
               percentiles[y][1]+=1;
               break;
              }
            if((EVB[Shift]<=percentiles[y][0]) && (EVB[Shift]>percentiles[y-1][0]))//fails on y zero but handled in first constraint
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
      //for(int y=0; y<sizePercentiles; y++)
      //Print(percentiles[y][1]);
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
            lowerLine=percentiles[y][0];
            isLower=true;
           }
         if(percentiles[y][1]>=lowMiddleCount && !isLowMiddle)
           {
            lowerMiddleLine=percentiles[y][0];
            isLowMiddle=true;
           }
         if(percentiles[y][1]>=middleCount && !isMiddle)
           {
            middleLine=percentiles[y][0];
            isMiddle=true;
           }
         if(percentiles[y][1]>=highMiddleCount && !isHighMiddle)
           {
            upperMiddleLine=percentiles[y][0];
            isHighMiddle=true;
           }
         if(percentiles[y][1]>=highCount && !isUpper)
           {
            upperLine=percentiles[y][0];
            isUpper=true;
            break;
           }
        }
     }
  };//CLASS
//+------------------------------------------------------------------+
