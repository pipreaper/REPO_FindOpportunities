//+------------------------------------------------------------------+
//|                                                   Squeeze_Break3 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.02"
#include <WaveLibrary.mqh>
#include <status.mqh>
// ====================
// indicator properties
// ====================
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrForestGreen
#property indicator_color2 clrRed
// ===================
// User Inputs
// ===================
extern congestionType typeOfCongestion=INSIDE;
extern int    Keltner_Period=20;
extern int    Keltner_MaMode=MODE_EMA;
extern int    Keltner_ATR_Period=10;
extern double Keltner_ATR_Flex=1.5;
extern int    Boll_Period=20;      // Bands Period
extern int    Boll_Shift=0;        // Bands Shift
extern double Boll_Deviations=2.0; // Bands Deviations
int debug=1;
double Pos_Diff[];   // Pos Histogram
double Neg_Diff[];   // Neg Histogram//double indexBuffer[];//check in higher idicator values produced here        
//+------------------------------------------------------------------+
//| OnInit                                                                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//Print(__FUNCTION__,"Symbol: ",Symbol()," wtf: ",Period()," *SqueezeBreak* ");  
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY_VALUE,3);
   SetIndexBuffer(0,Pos_Diff);
   SetIndexLabel(0,"Trend");
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY_VALUE,3);
   SetIndexBuffer(1,Neg_Diff);
   SetIndexLabel(1,"Congestion");

   IndicatorShortName("SqueezeBreak");

   return(0);
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

   if(rates_total<=Keltner_Period || Keltner_Period<=0)
      return(0);
   bool isSameSeries=false;
   ArraySetAsSeries(Pos_Diff,isSameSeries);
   ArraySetAsSeries(Neg_Diff,isSameSeries);

   int pos=prev_calculated;
   if(pos<0)
      pos=0;
   for(int shift=pos; shift<rates_total; shift++)
     {
      double keltUpperBand=iCustom(Symbol(),Period(),"KeltnerChannels",Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,0,rates_total-shift-1);
      double keltnerMiddleBand=iCustom(Symbol(),Period(),"KeltnerChannels",Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,1,rates_total-shift-1);
      double keltnerLowerBand=iCustom(Symbol(),Period(),"KeltnerChannels",Keltner_Period,Keltner_MaMode,Keltner_ATR_Period,Keltner_ATR_Flex,2,rates_total-shift-1);
      double bollingerUpperBand =  iCustom(Symbol(),Period(),"Bands",Boll_Period,Boll_Shift,Boll_Deviations,1,rates_total-shift-1);
      double bollingerLowerBand = iCustom(Symbol(),Period(),"Bands",Boll_Period,Boll_Shift,Boll_Deviations,2,rates_total-shift-1);
      calculateCongestion(typeOfCongestion,shift,keltUpperBand,keltnerLowerBand,bollingerUpperBand,bollingerLowerBand);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom congestion according to congestion TYPE required          |
//+------------------------------------------------------------------+  
void calculateCongestion(int toc,int shift,double Kelt_Upper_Band,double Kelt_Lower_Band,double Boll_Upper_Band,double Boll_Lower_Band)
  {
   if(toc==ALL)
     {
      //-- ALL
      if(Boll_Upper_Band>Kelt_Upper_Band && Boll_Lower_Band<Kelt_Lower_Band)
        {
         //no congestion
         Neg_Diff[shift]=EMPTY_VALUE;
         Pos_Diff[shift]=(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
        }
      else if(Boll_Upper_Band<Kelt_Upper_Band && Boll_Lower_Band>Kelt_Lower_Band)
        {
         //full Congestion
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else if((Boll_Upper_Band<Kelt_Upper_Band) && (Boll_Lower_Band<Kelt_Lower_Band))
        {
         //top
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else if((Boll_Upper_Band>Kelt_Upper_Band) && (Boll_Lower_Band>Kelt_Lower_Band))
        {
         //bottom
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else
        {
         Neg_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
         Pos_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
        }
     }
//-- INSIDE - Bollinger inside Keltner
   else if(toc==INSIDE)
     {
      //-- INSIDE
      if(Boll_Upper_Band>Kelt_Upper_Band && Boll_Lower_Band<Kelt_Lower_Band)
        {
         //no congestion or trend
         Neg_Diff[shift]=EMPTY_VALUE;
         Pos_Diff[shift]=(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
        }
      else if(Boll_Upper_Band<Kelt_Upper_Band && Boll_Lower_Band>Kelt_Lower_Band)
        {
         //full Congestion
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else
      // non congestion no trend
        {
         Neg_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
         Pos_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
        }
     }
//-- TOPBOTTOM
   else if(toc==TOPBOTTOM)
     {
      if(Boll_Upper_Band>Kelt_Upper_Band && Boll_Lower_Band<Kelt_Lower_Band)
        {
         //no congestion
         Neg_Diff[shift]=EMPTY_VALUE;
         Pos_Diff[shift]=(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
        }
      else if((Boll_Upper_Band<Kelt_Upper_Band) && (Boll_Lower_Band<Kelt_Lower_Band))
        {
         //top
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else if((Boll_Upper_Band>Kelt_Upper_Band) && (Boll_Lower_Band>Kelt_Lower_Band))
        {
         //bottom
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else
        {
         Neg_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
         Pos_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
        }
     }
//- TOP
   else if(toc==TOP)
     {
      if(Boll_Upper_Band>Kelt_Upper_Band && Boll_Lower_Band<Kelt_Lower_Band)
        {
         //no congestion
         Neg_Diff[shift]=EMPTY_VALUE;
         Pos_Diff[shift]=(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
        }
      else if((Boll_Upper_Band<Kelt_Upper_Band) && (Boll_Lower_Band<Kelt_Lower_Band))
        {
         //top
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else
        {
         Neg_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
         Pos_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
        }
     }

//-- BOTTOM}
   else if(toc==BOTTOM)
     {
      if(Boll_Upper_Band>Kelt_Upper_Band && Boll_Lower_Band<Kelt_Lower_Band)
        {
         //no congestion
         Neg_Diff[shift]=EMPTY_VALUE;
         Pos_Diff[shift]=(MathAbs(Boll_Upper_Band-Kelt_Upper_Band)+MathAbs(Boll_Lower_Band-Kelt_Lower_Band));
        }
      else if((Boll_Upper_Band>Kelt_Upper_Band) && (Boll_Lower_Band>Kelt_Lower_Band))
        {
         //bottom
         Neg_Diff[shift]=-(MathAbs(Boll_Upper_Band-Kelt_Upper_Band));
         Pos_Diff[shift]=EMPTY_VALUE;
        }
      else
        {
         Neg_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
         Pos_Diff[shift]=0;//Neither congested or trending //EMPTY_VALUE;
        }
     }

  }
//+------------------------------------------------------------------+
