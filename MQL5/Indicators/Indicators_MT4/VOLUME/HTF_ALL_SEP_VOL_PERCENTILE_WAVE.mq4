//+------------------------------------------------------------------+
//|                                                  WeisWave v6.mq4 |
//|                                    Copyright 2014 Robert Baptie. |
//|                               http://rgb-web-developer.comli.com |
//+------------------------------------------------------------------+
#property copyright   "2018 Robert Baptie"
#property link        ""
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>

#include <HTF_ALL_VOL_PERCENTILE.mqh>
#property indicator_separate_window
//#property indicator_chart_window
#property description" Find WAVE VOLUME on HTF according to "
#property description" ... PRICE,TIME,VOLUME,VOLUME/TIME, Price/TIME"
#property description" ... SHOW PERCENTILES"
#property indicator_buffers 11;


//extern bool             testing = true;
extern bool             eDrawLines=true;
extern volume_price     eVP=WAVE_PRICE;
extern ENUM_TIMEFRAMES  eEnumHTFPeriod=PERIOD_H1;
extern double           ewavePts=0;//0.5 points is 50 on SP500 / zero auto scale
extern bool             eShowData=true;
extern double           lowerPercentile=5;//low percent
extern double           lowerMiddlePercentile=20;//lower middle Percentile
extern double           middlePercentile=50;//middle percentile
extern double           upperMiddlePercentile=51;//****** should be 90 upper Middle Percentile
extern double           upperPercentile=98;//upper percentile 98
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  // Print(__FUNCTION__," ***upperMiddlePercentile: ", upperMiddlePercentile);
   //Print(__FUNCTION__,"**************** ",eVP);  
   eInit(eDrawLines,eVP,eEnumHTFPeriod,ewavePts,eShowData,lowerPercentile, lowerMiddlePercentile, middlePercentile, upperMiddlePercentile, upperPercentile);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| On Calculate                                                     |
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
   eOnCalculate(eEnumHTFPeriod,rates_total,prev_calculated,tick_volume,high,low,close,time,eShowData,eVP);
   return (rates_total);
  }
//+------------------------------------------------------------------+
