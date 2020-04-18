//+------------------------------------------------------------------+
//| RSIHTFs.mq4                                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      ""
#property version   "1.02"
#property description "HTF is set -> (enumHTFPeriod=PERIOD_M15)"
#property description "Checks HTF and sets Arrow if crosses levels(high/low)"
#property description "Sets ExStatus buffer to 1/-1 if it has crossed and above the considerationHigh / considerationLow level"
#property description "Arrow on HTF is set to zero in other circumstances"
//--- set the maximum and minimum values for the indicator window
#property indicator_minimum 0
#property indicator_maximum 100
#property strict
#property indicator_separate_window
#include <WaveLibrary.mqh>
#include <status.mqh>
#property  indicator_buffers 3
//+------------------------------------------------------------------+
//| Global variables RSI                                             |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES enumHTFPeriod=PERIOD_M15;
extern int periodRSI=14;
extern int levelBottom=30;
extern int levelTop=70;
extern int considerationHighLevel=50;
extern int considerationLowLevel = 50;
extern int maxBarsDraw=50000;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int htfIndex=findIndexPeriod(enumHTFPeriod);
int wtfIndex= NULL;
int debug=-1;
//double ExRSI[];
double ExStatus[];
double ExShortArrow[];
double ExLongArrow[];
string instrument=Symbol();
int wtf=Period();
int shift=NULL;
int limit= NULL;
int drawBegin=maxBarsDraw;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()>enumHTFPeriod)
     {
      Print(enumHTFPeriod);
      if(!(enumHTFPeriod==0))
        {
         s("***** enumHTFPeriod: "+string(enumHTFPeriod)+" Indicator only shows higher timeframes of Period(): "+string(Period()),true);
         s("***** SETTING PERIOD TO DEFAULT CHART PERIOD: "+string(Period()),true);
        }
      else
         Print("used current");
      enumHTFPeriod=ENUM_TIMEFRAMES(Period());
      htfIndex=findIndexPeriod(enumHTFPeriod);
     }
   color clrLine=clrNONE;
   int bars=Bars(Symbol(),wtf);
   if(drawBegin>=(bars-periodRSI-1))
      drawBegin=0;
   IndicatorBuffers(3);
   IndicatorShortName("HTFRSIPOP"+" "+Symbol()+" "+string(enumHTFPeriod));
   clrLine=TF_C_Colors[htfIndex];

   //SetIndexStyle(0,DRAW_NONE,0,1,clrPink);
   //string RSILabel="RSI_"+string(enumHTFPeriod);
   //SetIndexArrow(0,159);   
   //SetIndexLabel(0,RSILabel);
   //SetIndexBuffer(0,ExRSI);
   //SetIndexEmptyValue(0,EMPTY_VALUE);
   //SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(0,DRAW_NONE,2,3,clrNONE);
   string statusLabel="Status_"+string(enumHTFPeriod);
   SetIndexLabel(0,statusLabel);
   SetIndexBuffer(0,ExStatus);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexDrawBegin(0,drawBegin);

   SetIndexStyle(1,DRAW_ARROW,0,1,clrGreen);
   SetIndexArrow(1,233);
   SetIndexLabel(1,"RSI Long_"+string(enumHTFPeriod));
   SetIndexBuffer(1,ExLongArrow);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexDrawBegin(1,drawBegin);

   SetIndexStyle(2,DRAW_ARROW,0,1,clrRed);
   SetIndexArrow(2,234);
   SetIndexLabel(2,"RSI Short_"+string(enumHTFPeriod));
   SetIndexBuffer(2,ExShortArrow);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexDrawBegin(2,drawBegin);

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
   static int htfShift=-1;
   static int phtfShift=-1;
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

  // ArraySetAsSeries(ExRSI,true);
   ArraySetAsSeries(ExStatus,true);
   ArraySetAsSeries(ExLongArrow,true);
   ArraySetAsSeries(ExShortArrow,true);

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit-1;

   if(isNewBar)// ***** the chart tf the indicator is applied to
     {
      for(shift=limit-1; shift>=0; shift--)//start rates_total down to zero
        {
         htfShift=iBarShift(instrument,enumHTFPeriod,Time[shift],false);
         phtfShift=iBarShift(instrument,enumHTFPeriod,Time[shift+1],false);
        if( (htfShift==phtfShift ) && (shift < (rates_total-2)) )
           {
            //   if(shift==1)
            //      Print("limit: ",limit," Time[0] ",Time[0]," shift ",shift," SAME OR ZERO HTF: ",htfShift," Prev HTF: ",phtfShift);
            ExLongArrow[shift+1]=ExLongArrow[shift+2];
            ExShortArrow[shift+1]=ExShortArrow[shift+2];
            ExStatus[shift+1]=ExStatus[shift+2];              
            //ExtCloseArrow[shift+1]=ExtCloseArrow[shift+2];            
            continue;
           }         


     //    if(shift==1)
       //     Print("limit: ",limit," Time[0] ",Time[0]," ",shift," NO SAME OR ZERO HTF:  ",htfShift," Prev HTF: ",phtfShift);

         if(shift>(rates_total-periodRSI-1))
            continue;
         double tfRSI=iRSI(instrument,enumHTFPeriod,periodRSI,0,phtfShift);
         double tfRSIPrev=iRSI(instrument,enumHTFPeriod,periodRSI,0,phtfShift+1);

         //ExRSI[shift+1]=tfRSI;  // set and show line for middle MA 
                              //RSI turning over at the bottom
         if((tfRSI>50))
           {
            ExStatus[shift+1]=0;
            ExLongArrow[shift+1]=tfRSI+MathAbs(tfRSI-tfRSIPrev);
           }
         //Buy gone from weak to strong across the 50    
         //else if((tfRSIPrev<considerationHighLevel) && (tfRSI>considerationHighLevel))
         //  {
         //   ExStatus[shift+1]=0;
         //   ExLongArrow[shift+1]=tfRSI+MathAbs(tfRSI-tfRSIPrev);
         //  }
         //RSI turning over at the top     
         else if(tfRSI<50)
           {
            ExStatus[shift+1]=1;
            ExShortArrow[shift+1]=tfRSI-MathAbs(tfRSI-tfRSIPrev);
           }
         //Sell gone from weak to strong across the 50
         //else if((tfRSIPrev>considerationLowLevel) && (tfRSI<considerationLowLevel))
         //  {
         //   ExStatus[shift+1]=1;
         //   ExShortArrow[shift+1]=tfRSI-MathAbs(tfRSI-tfRSIPrev);
         //  }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
