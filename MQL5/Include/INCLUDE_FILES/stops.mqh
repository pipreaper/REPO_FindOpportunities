//+------------------------------------------------------------------+
//|                                                   tradelogic.mqh |
//|                                    Copyright 2016, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Robert Baptie"
#property link      "https://www.mql5.com"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WaveLibrary.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string checkCloseTrades(int percent)
  {
   bool hasClosed=false;
   string SY=NULL;
   long ID=NULL;
   int BS = NULL;
   double SL = NULL;
   double TP = NULL;
   double CP = NULL;
   double OP =NULL;
   datetime OT=NULL;

   for(int i=OrdersTotal(); i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         SY = OrderSymbol();
         ID = OrderTicket();
         BS = OrderType();
         SL = OrderStopLoss();
         TP = OrderTakeProfit();
         CP = OrderClosePrice();
         OP =OrderOpenPrice();
         OT = OrderOpenTime();
         //In Profit Close out on change of direction
         hasClosed=testAndCloseTrade(SY,ID,BS,SL,TP,CP,OP,OT,percent);
         if(hasClosed)
           {
            hasClosed=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Violet);
            return SY;
           }
        }
     }
   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool testAndCloseTrade(string SY,long ID,int BS,double SL,double TP,double CP,double OP,datetime OT,int percent)
  {
   double fiftyPercent=0.0;
   double maxTradePrice=0.0;
   double minTradePrice=INF;
   bool hasClosed=false;
   if(BS==0)//BUY
     {
      fiftyPercent=OP+(TP-OP)/2.0;
      maxTradePrice=findTradeHighLow(SY,OT,BS);
      if(maxTradePrice>=fiftyPercent)
        {
         if(((( maxTradePrice-CP)/(TP-OP))*100)>percent)
           {
            return true;
           }
        }
     }
   else if(BS==1)
     {
      fiftyPercent=OP-(OP-TP)/2.0;
      minTradePrice=findTradeHighLow(SY,OT,BS);
      if(minTradePrice<=fiftyPercent)
        {
         if((((CP-minTradePrice)/(TP-OP))*100)>percent)
           {
            return true;
           }
        }
     }
   return false;
  }

double findTradeHighLow(string SY,datetime OT,int BS)
  {
   double tradeExtreme=NULL;
   bool isRefreshed=false;
   int sizeArray=-1;
   do
     {
      isRefreshed=RefreshRates(); //think just refreshing EURUSD chart???
     }
   while(!isRefreshed);
   MqlRates rat[];
   ArraySetAsSeries(rat,true);
   datetime startTime=Time[0];
   int copiedRates=CopyRates(SY,PERIOD_M5,startTime,OT,rat);//Period 5 is lowest common denominator
   if(copiedRates>0)
     {
      sizeArray=ArraySize(rat);
      if(BS==0)//Buy
        {
        tradeExtreme=-1;
         for(int r=0; r<=sizeArray-1; r++)
           {
               tradeExtreme = MathMax(rat[r].high,tradeExtreme);
           }
        }
      else
        {
        tradeExtreme=INF;
         for(int r=0; r<=sizeArray-1; r++)
           {
               tradeExtreme = MathMin(rat[r].low,tradeExtreme);
           }
        }
     }
   return tradeExtreme;
  }
//+------------------------------------------------------------------+
