//+------------------------------------------------------------------+
//|                                                          tbp.mq4 |
//|                                    Copyright 2016, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//---- indicator settings
//#property indicator_separate_window
#property  indicator_buffers 5
#property indicator_color1 clrPurple
//external Buffers
double TBP[];
//Internal Buffers
double MF[];
double TR[];
double ExtTBPStop[];
double ExtTBPLimit[];
double ExtTBPBuy[];
double ExtTBPSell[];
double XBAR =0;
int sizeArrow = 1;
double buy=true;
string thisIndicator="TBP";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string textName1=thisIndicator;
   string textName2="level";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {//Tidy old lines
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,3)==textName1 || StringSubstr(objName,0,5)==textName2)
        {
         ObjectDelete(ObjectName(i));
         // Print("deleted ",objName);
        }
     }

   buy=true;
//--- indicator buffers mapping
   IndicatorBuffers(8);
//---Internal Buffers
   SetIndexStyle(0,DRAW_ARROW,0,sizeArrow,clrBlueViolet);
   SetIndexArrow(0,241);
   SetIndexLabel(0,"TBP Long");
   SetIndexBuffer(0,ExtTBPBuy);
   SetIndexStyle(1,DRAW_ARROW,0,sizeArrow,clrRed);
   SetIndexArrow(1,242);
   SetIndexLabel(1,"TBP Short");
   SetIndexBuffer(1,ExtTBPSell);

// ATR stop Limits
   SetIndexStyle(2,DRAW_NONE,0,1,clrRed);
   SetIndexArrow(2,34);
   SetIndexLabel(2,"stop");
   SetIndexBuffer(2,ExtTBPStop);
   SetIndexStyle(3,DRAW_NONE,0,1,clrBlue);
   SetIndexArrow(3,67);
   SetIndexLabel(3,"Limit");
   SetIndexBuffer(3,ExtTBPLimit);

//--- Internal Buffers
   SetIndexStyle(4,DRAW_NONE,0,1,clrWhite);
   SetIndexArrow(4,39);
   SetIndexBuffer(4,TBP);
   SetIndexLabel(4,"TBP");
   SetIndexBuffer(5,MF);
   SetIndexBuffer(6,TR);
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
//---
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   ArraySetAsSeries(MF,false);
   ArraySetAsSeries(TR,false);
   ArraySetAsSeries(TBP,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(ExtTBPBuy,false);
   ArraySetAsSeries(ExtTBPSell,false);
   ArraySetAsSeries(ExtTBPLimit,false);
   ArraySetAsSeries(ExtTBPStop,false);

   int limit=rates_total-prev_calculated;

   if(prev_calculated>0)
      limit++;
   for(int shift=0; shift<limit-1; shift++)
     {
      if(isNewBar)
        {
           {
            if(shift<3) // MF
               continue;
            MF[shift]=close[shift]-close[shift-2];//close 2 peridods ago
            TR[shift]= MathMax(high[shift]-low[shift],MathAbs(high[shift]-close[shift-1]));
            TR[shift]= MathMax(TR[shift],MathAbs(low[shift]-close[shift-1]));
            XBAR=(high[shift]+low[shift]+close[shift])/3;
            if(shift<5) // TBP
               continue;
            if(buy)//set TBP for tomorrow
            {
               TBP[shift+1]=MathMin(MF[shift],MF[shift-1]);
               TBP[shift+1]=MathMin(TBP[shift+1],MF[shift-2])+close[shift-1];//+close[shift-2]+close[shift-3]+close[shift-4]+close[shift-5])/5);//Long               
               }
            else
            {
               TBP[shift+1]=MathMax(MF[shift],MF[shift-1]);
               TBP[shift+1]=MathMax(TBP[shift+1],MF[shift-2])+close[shift-1];//+close[shift-2]+close[shift-3]+close[shift-4]+close[shift-5])/5);//Short               
               }

            if(buy)
              {
               if(close[shift]<TBP[shift])
                 {//Change to Sell
                  ExtTBPBuy[shift]=EMPTY_VALUE;
                  ExtTBPSell[shift]=high[shift]+25*Point;
                  ExtTBPStop[shift+1]=XBAR+TR[shift];
                  ExtTBPLimit[shift+1]=(2*XBAR)-high[shift];
                  buy=false;
                 }
               else
                 {//no chnage still buying
                  ExtTBPBuy[shift]=EMPTY_VALUE;
                  ExtTBPSell[shift]=EMPTY_VALUE;
                  ExtTBPStop[shift+1]=XBAR-TR[shift];
                  ExtTBPLimit[shift+1]=(2*XBAR)-low[shift];
                 }
              }
            else if(!buy)
              {//Change to Buy
               if(close[shift]>TBP[shift])
                 {
                  ExtTBPBuy[shift]=low[shift]-25*Point;
                  ExtTBPSell[shift]=EMPTY_VALUE;
                  ExtTBPStop[shift+1]=XBAR-TR[shift];
                  ExtTBPLimit[shift+1]=(2*XBAR)-low[shift];
                  buy=true;
                 }
               else
                 {//no chnage still selling
                  ExtTBPBuy[shift]=EMPTY_VALUE;
                  ExtTBPSell[shift]=EMPTY_VALUE;
                  ExtTBPStop[shift+1]=XBAR+TR[shift];
                  ExtTBPLimit[shift+1]=(2*XBAR)-high[shift];
                 }
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
