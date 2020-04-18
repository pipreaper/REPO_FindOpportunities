//+------------------------------------------------------------------+
//|                                                          Atr.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "lamar"
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <Indicators\Oscilators.mqh>
class CAtr : public CiATR
  {
private :
   //int               m_period;
   //struct sAtrStruct
   //  {
   //   double         tr;
   //   double         sum;
   //  };
   //sAtrStruct        m_array[];
   //int               m_arraySize;
public :
///  bool              firstPass;
   void              CAtr::CAtr();
   void              CAtr::~CAtr();
   color             CAtr::findColor(int _index);
   int               CAtr::findIndexPeriod(ENUM_TIMEFRAMES _TF);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int ma_period);
   //   template<typename T>
   //   double            calculate(T &high[], T &low[],T &close[], int i, int bars);
  };
//+------------------------------------------------------------------+
//|Constructor                                                       |
//+------------------------------------------------------------------+
CAtr::CAtr()
  {
 //  timedEvent=true;
  // firstPass = true;
   return;
  }
//+------------------------------------------------------------------+
//| Initialize                                                             |
//+------------------------------------------------------------------+
//bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int ma_period)
//  {
//
//  if()
//  return true;
//  else
//   return false;
//  }
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
//|return index of tf passed in                                      |
//+------------------------------------------------------------------+
int CAtr::findIndexPeriod(ENUM_TIMEFRAMES _TF)
  {
   ENUM_TIMEFRAMES allTimeFrames[22] =
     {
      PERIOD_M1,
      PERIOD_M2,
      PERIOD_M3,
      PERIOD_M4,
      PERIOD_M5,
      PERIOD_M6,
      PERIOD_M10,
      PERIOD_M12,
      PERIOD_M15,
      PERIOD_M20,
      PERIOD_M30,
      PERIOD_H1,
      PERIOD_H2,
      PERIOD_H3,
      PERIOD_H4,
      PERIOD_H6,
      PERIOD_H8,
      PERIOD_H12,
      PERIOD_D1,
      PERIOD_W1,
      PERIOD_MN1,
      PERIOD_CURRENT
     };
   for(int i=0; i<ArraySize(allTimeFrames); i++)
      if(_TF==allTimeFrames[i])
         return i;
   Print(__FUNCTION__," Error: TF Not Found");
   DebugBreak();
   return -1;
  }
//+------------------------------------------------------------------+
//|return color of index passed in                                   |
//+------------------------------------------------------------------+
color CAtr::findColor(int _index)
  {
   color allColors[22] =
     {
      clrPink,
      clrPaleTurquoise,
      clrGreen,
      clrAliceBlue,
      clrLightBlue,
      clrCrimson,
      clrDeepPink,
      clrOliveDrab,
      clrLightGreen,
      clrChocolate,
      clrWhite,
      clrRed,
      clrWhiteSmoke,
      clrCoral,
      clrBurlyWood,
      clrDarkOrange,
      clrDarkSeaGreen,
      clrDarkKhaki,
      clrCornflowerBlue,
      clrLightSlateGray,
      clrChartreuse,
      clrOlive
     };
   return allColors[_index];
   Print(__FUNCTION__," Error: colr from index Not Found");
   DebugBreak();
   return NULL;
  }
//+------------------------------------------------------------------+
//|Destructor                                                        |
//+------------------------------------------------------------------+
CAtr::~CAtr()
  {
   return;
  }
//+------------------------------------------------------------------+
