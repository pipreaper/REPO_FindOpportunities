//+------------------------------------------------------------------+
//|                                                       VolSys.mq4 |
//|                                    Copyright 2017, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//---- indicator settings

#property  indicator_buffers 2

//---- input parameters
extern int       VIPeriod=14;
extern int       ATRPeriod=7;
extern double    ARCConstant=3;
extern int sizeCircle = 1;

//external Buffers
double ExtVIBuy[];
double ExtVISell[];
bool buy=true;
double SIC=-1;
double SAR= -1;

//double buy=true;
string thisIndicator="VolSys";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorDigits(Digits);
   IndicatorShortName(thisIndicator);
//--- indicator buffers mapping
   IndicatorBuffers(2);
//---Internal Buffers
   SetIndexStyle(0,DRAW_ARROW,0,sizeCircle,clrBlue);
   SetIndexArrow(0,159);
   SetIndexLabel(0,"VI Buy");
   SetIndexBuffer(0,ExtVIBuy);

   SetIndexStyle(1,DRAW_ARROW,0,sizeCircle,clrRed);
   SetIndexArrow(1,159);
   SetIndexLabel(1,"VI Sell");
   SetIndexBuffer(1,ExtVISell);

//---
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
   bool isSeries=false;
   ArraySetAsSeries(ExtVIBuy,isSeries);
   ArraySetAsSeries(ExtVISell,isSeries);
   ArraySetAsSeries(close,isSeries);
   ArraySetAsSeries(high,isSeries);
   ArraySetAsSeries(low,isSeries);

//--- starting calculation
   int limit=rates_total-prev_calculated;
//---
   if(rates_total<=VIPeriod)
      return(0);

   if(prev_calculated>0)
      limit++;
   for(int shift=0; shift<limit; shift++)
     {
      if(shift<=VIPeriod)
         continue;
      double ARC=ARCConstant*iATR(Symbol(),Period(),ATRPeriod,rates_total-shift-1);

      if(buy)
        {
         SIC=MathMax(SIC,close[shift]);
         SAR= SIC-ARC;
         if(close[shift]<=SAR)//go short
           {
            buy=false;
            ExtVIBuy[shift]=EMPTY_VALUE;
            ExtVISell[shift]=SAR;
           }
         else
           {
            ExtVIBuy[shift]=SAR;
            ExtVISell[shift]=EMPTY_VALUE;
           }

        }
      else if(!buy)
        {
         SIC=MathMin(SIC,close[shift]);
         SAR= SIC+ARC;
         if(close[shift]>=SAR)//go long
           {
            buy=true;
            ExtVIBuy[shift]=SAR;
            ExtVISell[shift]=EMPTY_VALUE;
           }
         else
           {
            ExtVIBuy[shift]=EMPTY_VALUE;
            ExtVISell[shift]=SAR;
           }
        }
  }//for
//--- return value of prev_calculated for next call
return(rates_total);
}
//+------------------------------------------------------------------+
