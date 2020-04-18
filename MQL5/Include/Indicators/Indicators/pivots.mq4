//+------------------------------------------------------------------+
//|                                                       arrows.mq4 |
//|                                                    Robert Baptie |
//|                               http://rgb-web-designer.comli.com/ |
//+------------------------------------------------------------------+
#property copyright "Robert Baptie";
#property link      "http://rgb-web-designer.comli.com/";
#property version   "1.00";
#property strict;
#property indicator_chart_window;
#property indicator_buffers 2;
#property indicator_plots   2;
//--- plot Arrow
#property indicator_label1  "Arrow1";
#property indicator_type1   DRAW_ARROW;
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID;
#property indicator_width1  1;

#property indicator_label2  "Arrow2";
#property indicator_type2   DRAW_ARROW;
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID;
#property indicator_width2  1;

//--- input parameters
input int      barsToProcess=1000;

//--- indicator buffers
double         ArrowBuffer1[];
double         ArrowBuffer2[];
//double         statusBuffer[];
//double         statusBuffer1[];

datetime currentTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
   //--- indicator buffers mapping
   //IndicatorBuffers(2);   
   SetIndexBuffer(0, ArrowBuffer1);
   SetIndexBuffer(1, ArrowBuffer2);
   //---- drawing parameters setting
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159); //218  
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);  //217    
  
   //SetIndexBuffer(1, statusBuffer);    
   //SetIndexBuffer(2, statusBuffer);       
   //SetIndexStyle(1,0);
   
   //ChartSetSymbolPeriod(0,NULL,PERIOD_M3);
   
   return(INIT_SUCCEEDED);
  }

int start()
{
   int counted_bars=IndicatorCounted(), limit;
 
   if(counted_bars>0)
      counted_bars--;
   
   limit=Bars-counted_bars;
   
   if(limit>barsToProcess)
      limit=barsToProcess;
      
   for(int i=1;i<limit-1;i++)   
   {
      //  if(currentTime != Time[0]){
      double checkStatus = checkCandle(i);
      if( checkStatus==1.0 ){
         ArrowBuffer1[i]=High[i]+25*Point; //Red Down
         ArrowBuffer2[i]=0.0;        
      } else if ( checkStatus ==2.0) {
         ArrowBuffer2[i]=Low[i]- 25*Point; //Blue up
         ArrowBuffer1[i]=0.0;          
      }  else {
         ArrowBuffer1[i]= 0.0;  
         ArrowBuffer2[i]=0.0;                
      }          
   }  
   return(0);
}

double checkCandle(int i){
   if( ( High[i] > High[i+1] ) && ( High[i] > High[i-1])
   &&  ( Low[i] > Low[i+1] ) && ( Low[i] > Low[i-1]))
      return 1.0; //down
   else if( ( Low[i] < Low[i+1] ) && ( Low[i] < Low[i-1])
   &&  ( High[i] < High[i+1] ) && ( High[i] < High[i-1]))
      return 2.0; //down
   else
      return 0.0;   
}
//
//void Mark(string name, double po, color clr){  //      #define WINDOW_MAIN 0
//    if (!ObjectCreate( name, OBJ_ARROW_CHECK, 0, Time[1], po))
//        Alert("ObjectCreate(",name,",HLINE) failed: ", GetLastError() );
//}