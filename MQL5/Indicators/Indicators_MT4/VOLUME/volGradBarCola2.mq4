//+------------------------------------------------------------------+
//|                                                volGradBarCola.mq4 |
//|                                    Copyright 2015, Robert Baptie |
//|                                                                  |
//+------------------------------------------------------------------+
//**************----------------  Display Bars as percentile width == effort    ---------*************************
//**************----------------  volume study is conducted over maxBars        ---------*************************
//**************----------------  percentiles are conducted over max bars       ---------*************************
//**************----------------  six color ranges ten percentile widths        ---------*************************
//**************----------------  Light volume 3 buckets                        ---------*************************
//**************----------------  Moderate volume 3 buckets                     ---------*************************
//**************----------------  Higher volume 3 buckets                       ---------*************************
#property copyright "Copyright 2015, Robert Baptie"
#property link      ""
#property version   "1.00"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#property indicator_chart_window

int ExtBegin=0;
const int sizePercentiles=10;
int maxCandleWidth=9;//Needs one less than percentiles @ least
double percentiles[10,2];// [bucket,incremental fraction] , [bucket, count of volume bars]
                         //{4hours, week, week, week, week ,month, month, 6months, 1year}
int numMaxValue[9]={240,1440,480,240,120,120,30,26,12};//#bars per time frame
int maxBars=numMaxValue[thisTFPosition()];

color upColor[10]={clrAquamarine,clrAquamarine,clrDodgerBlue,clrDodgerBlue,clrDodgerBlue,clrRoyalBlue,clrRoyalBlue,clrRoyalBlue,clrNavy,clrNavy};//{clrPowderBlue,clrPowderBlue,clrPowderBlue,clrPowderBlue,clrPowderBlue, clrSkyBlue,clrDeepSkyBlue,clrDodgerBlue,clrRoyalBlue,clrBlue};
color downColor[10]={clrPink,clrPink,clrMediumVioletRed,clrMediumVioletRed,clrMediumVioletRed,clrRed,clrRed,clrRed,clrDarkRed,clrDarkRed};//{clrChocolate,clrChocolate,clrChocolate,clrChocolate,clrChocolate,clrSalmon,clrOrange,clrDarkOrange,clrOrangeRed,clrRed};

long uniqueLineID=0;
long chart_id=ChartID();
         int count=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorShortName("Volume Candles");
//---
   ChartForegroundSet(true,chart_id);
   return(INIT_SUCCEEDED);
  }
//NEW CANDLE LOGIC
bool isNewCandle(int s,int rt,int pc,const datetime &t[],const long &tv[])
  {
   if(pc!=rt)//new candle
     {
      for(int shift=s;shift<rt;shift++)
        {
         //     if(shift==0) continue;
         for(int y=0; y<sizePercentiles; y++)
           {
            percentiles[y][0] = 0;
            percentiles[y][1] = 0;
           }

         //Find Max Volume
         double vol=0;
         for(shift=s; shift<rt; shift++)
            vol=MathMax(vol,tv[shift]);
         double step=vol/(double)sizePercentiles;

         //carve max volume into 10 pieces
         for(int y=0; y<sizePercentiles; y++)
           {
            percentiles[y][0]=(y+1)*step; //percentiles[0] dimension 0 - 9 buckets, filled with 1 -10 volume slice
           }
         // for each candle Volume     
         for(shift=s; shift<rt; shift++)
           {
            //find frequency
            for(int y=0; y<=sizePercentiles-1; y++)
              {
               if(y==0 && (tv[shift]<=percentiles[y][0]))
                 {
                  percentiles[y][1]+=1;
                  break;
                 }
               if((y==sizePercentiles-1) && (tv[shift]>=percentiles[y][0]))
                 {
                  percentiles[y][1]+=1;
                  break;
                 }
               if((tv[shift]<=percentiles[y][0]) && (tv[shift]>percentiles[y-1][0]))
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
               count += percentiles[y][1];
               continue;
              }
            percentiles[y][1]+=percentiles[y-1][1];
           count += percentiles[y-1][1];
           }
        }        
      return true;
     }
   return false;
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
//---
   ArraySetAsSeries(tick_volume,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(time,false);

   int st=-1;
   if(rates_total>maxBars) // just plot and calculate maxBars
      st=rates_total-maxBars-1;
   else if(rates_total==maxBars)
     {
      st=rates_total-maxBars-1; // have enough bars for max bars but need previous bar so 1 less
      maxBars-=1;
     }
   else
     {
      st=0; // rates_total < maxBars
      maxBars=rates_total-1;
     }
   for(int shift=st;shift<rates_total;shift++)
     {
      if(isNewCandle(st,rates_total,prev_calculated,time,tick_volume))
        {
         //       int x=1;
         if((close[shift]) > (low[shift]+((high[shift]-low[shift])/2)))
         //if(close[shift]-close[shift-1]>=0)         
           {drawLine(false,true,time[shift],open[shift],high[shift],low[shift],close[shift],tick_volume[shift]);}
         //else if(close[shift]-close[shift-1]<=0)
         else
           {drawLine(false,false,time[shift],open[shift],high[shift],low[shift],close[shift],tick_volume[shift]);}
        }
      else
        {
         //if(close[shift]-close[shift-1]>=0)
         if((close[shift]) > (low[shift]+((high[shift]-low[shift])/2)))         
           {drawLine(true,true,time[shift],open[shift],high[shift],low[shift],close[shift],tick_volume[shift]);}
        // else if(close[shift]-close[shift-1]<=0)
      else        
           {drawLine(true,false,time[shift],open[shift],high[shift],low[shift],close[shift],tick_volume[shift]);}
        }
      //   isTick(start,rates_total,prev_calculated,time,open,high,low,close,tick_volume);     
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| drawLine                                                         |
//+------------------------------------------------------------------+  
string drawLine(bool currentCandle,bool upDown,datetime t,double open,double h,double l,double close,long tv)
  {
   color colSelected=NULL;

   if(currentCandle)
     {
      int thisObj = ObjectFind(ChartID(),("vol"+string(uniqueLineID)));
      if(thisObj >=0)
        {
         ObjectSetDouble(chart_id,"vol"+string(uniqueLineID),OBJPROP_PRICE1,l);
         ObjectSetDouble(chart_id,"vol"+string(uniqueLineID),OBJPROP_PRICE2,h);
         //--- set line color   
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_BACK,false);
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_SELECTABLE,false);
         //---enable (true) or disable (false) the mode of continuation of the line's display to the left
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_RAY_LEFT,false);
         //--- enable (true) or disable (false) the mode of continuation of the line's display to the right
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_RAY_RIGHT,false);
         int width=1;
         colSelected=findCandleColor(upDown,tv,width);
         if(colSelected!=NULL)
           {
            ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_WIDTH,width);
            ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_COLOR,colSelected);
            return "Line Reset Good";
           }
         else
           {
            Print(__FUNCTION__,": failed to retrieve color code 1");
            return ": failed to retrieve color code 1";
           }
        }
      else
        {
         Print(__FUNCTION__,": failed to find current candle, Error code = ",ErrorDescription(GetLastError()));
         return "Cant find object that should have been created?";
        }

     }

   uniqueLineID++;
   int sw=ObjectFind(ChartID(),("vol"+string(uniqueLineID)));
   int window=0;
   if(sw<0)
     {
      if(!ObjectCreate(ChartID(),"vol"+string(uniqueLineID),OBJ_TREND,0,t,l,t,h))
        {
         Print(__FUNCTION__,": failed to create a volume line, Error code = ",ErrorDescription(GetLastError()));
         return "This Line Already Exists";
        }
      else
        {
         //--- set line color   
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_BACK,false);
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_SELECTABLE,false);
         //---enable (true) or disable (false) the mode of continuation of the line's display to the left
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_RAY_LEFT,false);
         //--- enable (true) or disable (false) the mode of continuation of the line's display to the right
         ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_RAY_RIGHT,false);
         int width=1;
         colSelected=findCandleColor(upDown,tv,width);
         if(colSelected!=NULL)
           {
            ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_WIDTH,width);
            ObjectSetInteger(chart_id,"vol"+string(uniqueLineID),OBJPROP_COLOR,colSelected);
            return ("vol"+string(uniqueLineID));
           }
         else
            Print(__FUNCTION__,": failed to retrieve color code 2");
         return (": failed to retrieve color code 2");
        }
     }
   else
     {
      Print(__FUNCTION__,"line already exists");
      return "line already exists";
     }
   return "never";
  }
//+------------------------------------------------------------------+
//| Find Candle Color                                                |
//+------------------------------------------------------------------+ 
color findCandleColor(bool upDown,long tv,int &w)
  {
   int colorIndex=int(sizePercentiles/ArraySize(upColor));
   double width=-1;
//greater than zero bucket   
   if(upDown && (tv>=percentiles[sizePercentiles-1][0]))
     {
      width=percentiles[sizePercentiles-1][1]/double(maxBars)*double(maxCandleWidth);
      w=int(MathFloor(width));
      w=w/colorIndex;
      if(!intHasValue(upColor,w))
         Print("color array value: ",w);
      return upColor[w/colorIndex];
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!upDown && (tv>=percentiles[sizePercentiles-1][0]))
     {
      width=percentiles[sizePercentiles-1][1]/double(maxBars)*double(maxCandleWidth);
      w=int(MathFloor(width));
      w=w/colorIndex;
      if(!intHasValue(downColor,w))
         Print("color array value: ",w);
      return downColor[int(w/colorIndex)];
     }
//Less  than 0 bucket     
   if(upDown && (tv<=percentiles[0][0]))
     {
      width=percentiles[0][1]/double(maxBars)*double(maxCandleWidth);
      w=int(MathFloor(width));
      if(!intHasValue(upColor,w))
         Print("color array value: ",w);
      return upColor[int(w/colorIndex)];
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!upDown && (tv<=percentiles[0][0]))
     {
      width=percentiles[0][1]/double(maxBars)*double(maxCandleWidth);
      w=int(MathFloor(width));
      if(!intHasValue(downColor,w))
         Print("color array value: ",w);
      return downColor[int(w/colorIndex)];
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(upDown)//trend up
     {
      for(int y=0; y<sizePercentiles-1; y++)
        {
         if((tv>=percentiles[y][0]) && (tv<=percentiles[y+1][0]))
           {
            width=percentiles[y][1]/double(maxBars)*double(maxCandleWidth);
            w=int(MathFloor(width));
            if(!intHasValue(upColor,w))
               Print("color array value: ",w);
            return upColor[int(w/colorIndex)];
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      for(int y=0; y<sizePercentiles-1; y++)
        {
         if((tv>=percentiles[y][0]) && (tv<=percentiles[y+1][0]))
           {
            width=percentiles[y][1]/double(maxBars)*double(maxCandleWidth);
            w=int(MathFloor(width));
            if(!intHasValue(downColor,w))
               Print("color array value: ",w);
            return downColor[int(w/colorIndex)];
           }
        }
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string textName1="vol";
//string textName2="rect";
//string textName3="cumVol";
//string textName4="cumPrice";
   for(int i=ObjectsTotal() -1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,3)==textName1)// || StringSubstr(objName,0,4)==textName2 || StringSubstr(objName,0,6)==textName3 || StringSubstr(objName,0,8)==textName4)
        {
         ObjectDelete(ObjectName(i));
         //  Print("deleted ",objName);
        }
     }
//ObjectDelete("Label_Obj_Price");
//ObjectDelete("Label_Obj_Volume");
  }
//+------------------------------------------------------------------+
