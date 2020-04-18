//+------------------------------------------------------------------+
//|                                                    THROWAWAY.mq5 |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#property indicator_chart_window

#include <Indicators\Trend.mqh>
#include <errordescription.mqh>

CiMA ima;
int m_bufferSize = -1;
bool timedEvent = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int waitMS = 1;
   Print("-----------------------",TimeCurrent(),"--------------------------");

   ima.Create(_Symbol,PERIOD_H1,20,0,MODE_SMA,PRICE_CLOSE);
   EventSetMillisecondTimer(waitMS);
   Print("OnTimer set to ",waitMS," ms");

//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   ima.Refresh();
   EventKillTimer();
   timedEvent = true;

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

   static int tickCnt = 0;
   tickCnt++;

   if(!timedEvent)
      return rates_total;
//---
   if(rates_total != prev_calculated || m_bufferSize < 1)
     {
      ResetLastError();
      CIndicatorBuffer *buff = ima.At(0);
      m_bufferSize = buff.Total();
      if(m_bufferSize <=0)
         ima.Refresh();
      // try wait with looping

      if(m_bufferSize < 1)
        {
         Print(ErrorDescription(GetLastError()));

        }
      else
        {
         for(int i=0; i<m_bufferSize; i++)
           {
            if(i>2)
               break;
            else
              {
               Print(__LINE__," ",__FUNCTION__,buff.Name(),
                     " Buffer size = ",m_bufferSize,
                     " | ",ima.PeriodDescription()," iMA(",i,") value = ",
                     DoubleToString(ima.Main(i),_Digits),
                     " | Tick-count = ",tickCnt
                    );
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
