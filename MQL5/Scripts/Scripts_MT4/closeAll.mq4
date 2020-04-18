//+------------------------------------------------------------------+
//|                                                     CloseAll.mq4 |
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |
//+------------------------------------------------------------------+

#property copyright "Coders Guru"
#property link      "http://www.xpworx.com"
//#property show_inputs
//Last Modification = 2010.10.19 21:00
extern int option=0;
void Hook()
  {
   if(MessageBox("Are you sure want to close all the trades?","Close All Trades",1)==1)
      CloseAll();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void timer()
  {

   while(true)
     {
      Sleep(1000);
      if(IsStopped())
        {
         return;
        }
      start();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   Hook();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   int total=OrdersTotal();
   int cnt=0;
   for(cnt=total; cnt>=0; cnt--)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         CloseOrder(OrderTicket(),OrderType());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseOrder(int tick,int type)
  {
   bool result;
   int tries = 5;
   int pause = 500;
   if(OrderSelect(tick,SELECT_BY_TICKET,MODE_TRADES))
     {
      if(type==OP_BUY)
        {
         for(int c=0; c<=tries; c++)
           {
            //double bid=NormalizeDouble(Bid,Digits);
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),50000,Violet);
            if(result==true) break;
            else
              {
               Sleep(pause);
               continue;
              }
           }
        }
      if(type==OP_SELL)
        {
         for(c=0; c<=tries; c++)
           {
            //double ask=NormalizeDouble(Ask,Digits);
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),50000,Violet);
            if(result==true) break;
            else
              {
               Sleep(pause);
               continue;
              }
           }
        }
      if(OrderType()>OP_SELL)
        {
         for(c=0; c<=tries; c++)
           {
            result=OrderDelete(OrderTicket());
            if(result==true) break;
            else
              {
               Sleep(pause);
               continue;
              }
           }
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+
