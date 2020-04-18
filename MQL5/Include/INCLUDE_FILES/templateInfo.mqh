//+------------------------------------------------------------------+
//|                                              sorting objects.mq5 |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"

#define SORT_ASCENDING  1
#define SORT_DESCENDING 2
#include <Arrays\ArrayObj.mqh>
template<typename T>
class objvector : public CArrayObj
{
public:
   T  *operator[](const int index) const { return (T*)At(index);}
};
