//+------------------------------------------------------------------+
//|                                                  screenStuff.mqh |
//|                                                    Robert Baptie |
//|                           http://www.rgb-web-developer@comli.com |
//+------------------------------------------------------------------+
#property copyright "Robert Baptie"
#property link      "http://www.rgb-web-developer@comli.com"
#property strict
#include <errordescription.mqh>
//#include <INCLUDE_FILES\\drawTrend.mqh>
#include <INCLUDE_FILES\\chartUtilities.mqh>
datetime tda[];
//+------------------------------------------------------------------+
//|MultiFrame                                                        |
//+------------------------------------------------------------------+
void MultiFrame(const long tChart,const int id,const long &lparam,const double &dparam,const string &sparam)
{
   long prevChart,currChart;
   int x=(int)lparam; int y=(int)dparam; int window=0; datetime dt=0; double price=0;
      if((int)sparam==8)// Allow me to move chart to chart without moving displays
         return;
     // Comment("POINT: ",(int)lparam,",",(int)dparam,"\n",MouseState((uint)sparam));
      if(ChartXYToTimePrice(tChart,x,y,window,dt,price) && x>0)
        {     
         ObjectDelete(tChart,"V Line"+(string)tChart);
         ObjectCreate(tChart,"V Line"+(string)tChart,OBJ_VLINE,0,dt,dt);
         int FVB=ChartFirstVisibleBar(tChart);
         int i=0,limit=100;
         prevChart=ChartFirst();
         while(i<limit)
           {
            currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID             
            if((ObjectFind(prevChart,"V Line"+(string)prevChart)!=-1))
              {             
               bool isDeleted= ObjectDelete(prevChart,"V Line"+(string)prevChart);
               bool isCreated= ObjectCreate(prevChart,"V Line"+(string)prevChart,OBJ_VLINE,0,dt,dt);
               if(prevChart!=tChart)
                 {
                  FVB=ChartFirstVisibleBar(prevChart);;
                  bool res=centerVLine(prevChart,FVB,ChartSymbol(prevChart),ChartPeriod(prevChart),dt);
                 }
              }
            if(currChart<0)
               break;          // Have reached the end of the chart list
            prevChart=currChart;// let's save the current chart ID for the ChartNext()
            i++;
           }
        }
     }
//+------------------------------------------------------------------+
//|centerVLine                                                       |
//+------------------------------------------------------------------+ 
bool centerVLine(long tChart,int fvb,string chartSymbol,ENUM_TIMEFRAMES chartPeriod,datetime dt)
  {
   int index=-1;
   int numBars=(int)ChartVisibleBars(tChart);
   ResetLastError();
   if(iBarShift(chartSymbol,chartPeriod,dt)>0)
      index=iBarShift(chartSymbol,chartPeriod,dt);
   else
     {
      //--- display the error message in Experts journal bars shift
      //string error=ErrorDescription(GetLastError());
      //if(error!="no error")
      //   Print(__FUNCTION__+", Error = ",error);
      return false;
     }
   int diff=fvb-index;
   int center=(int)(numBars/2);
   int shift = diff-center;
   ResetLastError();
   if(!ChartNavigate(tChart,CHART_CURRENT_POS,shift))
     {
      //string error=ErrorDescription(GetLastError());
      //if(error!="no error")
      //   Print(__FUNCTION__+", Error = ",error);
      return false;
     }
//--- navigation ok
   return true;
  }   
//+------------------------------------------------------------------+
