//+------------------------------------------------------------------+
//|                                                          Atr.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <Indicators\Oscilators.mqh>
class CAtr : public CiATR
  {
private :
   //int               m_period;
   struct sAtrStruct
     {
      double         tr;
      double         sum;
     };
   sAtrStruct        m_array[];
   int               m_arraySize;
public :
   void              CAtr::CAtr();
   void              CAtr::~CAtr();
   //   template<typename T>
   //   double            calculate(T &high[], T &low[],T &close[], int i, int bars);
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
CAtr::CAtr()
  {
   return;
  }
//+------------------------------------------------------------------+
//| CAtr                                                             |
//+------------------------------------------------------------------+
//template<typename T>
//double            CAtr::calculate(T &high[], T &low[],T &close[], int i, int bars)
//  {
//   if(m_arraySize<bars)
//     {
//      m_arraySize = ArrayResize(m_array,bars+500);
//      if(m_arraySize<bars)
//         return(0);
//     }
//
//   double t_high = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) : high[i];
//   double t_low  = (i>0) ? (low[i] <close[i-1] ? low[i]  : close[i-1]) : low[i];
//
//   m_array[i].tr = t_high-t_low;
//   if(i>m_period)
//     { m_array[i].sum = m_array[i-1].sum-m_array[i-m_period].tr+m_array[i].tr; }
//   else
//     {
//      m_array[i].sum = m_array[i].tr;
//      for(int k=1; k<m_period && i>=k; k++)
//         m_array[i].sum += m_array[i-k].tr;
//     }
//   return (m_array[i].sum/(double)m_period);
//  }
//+------------------------------------------------------------------+
//|Destructor                                                        |
//+------------------------------------------------------------------+
CAtr::~CAtr()
  {
   return;
  }
//+------------------------------------------------------------------+
