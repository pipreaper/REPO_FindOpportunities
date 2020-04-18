//+------------------------------------------------------------------+
//|                                            ENUM_ARROW_ANCHOR.mq4 |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Auxiliary arrays
   double Ups[],Downs[];
   datetime Times[];
//--- Set the arrays as timeseries
   ArraySetAsSeries(Ups,true);
   ArraySetAsSeries(Downs,true);
   ArraySetAsSeries(Times,true);
//--- Set Last error value to Zero
   ResetLastError();
//--- Copy timeseries containing the opening bars of the last 1000 ones
   int copied=CopyTime(NULL,0,0,1000,Times);
   if(copied<=0)
     {
      Print("Unable to copy the Open Time of the last 1000 bars");
      return;
     }
//--- prepare the Ups[] and Downs[] arrays
   ArrayResize(Ups,copied);
   ArrayResize(Downs,copied);
//--- copy the values of iFractals indicator
   for(int i=0;i<copied;i++)
   {
      Ups[i]=iFractals(NULL,0,MODE_UPPER,i);
    Downs[i]=iFractals(NULL,0,MODE_LOWER,i);
   }
//---
   int upcounter=0,downcounter=0; // count there the number of arrows
   bool created;// the result of attempts to create an object
   for(int i=2;i<copied;i++)// Run through the values of the indicator iFractals
     {
      if(Ups[i]!=0)// Found the upper fractal
        {
         if(upcounter<10)// Create no more than 10 "Up" arrows
           {
            //--- Try to create an "Up" object
            created=ObjectCreate(0,string(Times[i]),OBJ_ARROW_THUMB_UP,0,Times[i],Ups[i]);
            if(created)// If set up - let's make tuning for it
              {
               //--- Point anchor is below in order not to cover bar
               ObjectSetInteger(0,string(Times[i]),OBJPROP_ANCHOR,ANCHOR_BOTTOM);
               //--- Final touch - painted
               ObjectSetInteger(0,string(Times[i]),OBJPROP_COLOR,clrBlue);
               upcounter++;
              }
           }
        }
      if(Downs[i]!=0)// Found a lower fractal
        {
         if(downcounter<10)// Create no more than 10 arrows "Down"
           {
            //--- Try to create an object "Down"
            created=ObjectCreate(0,string(Times[i]),OBJ_ARROW_THUMB_DOWN,0,Times[i],Ups[i]);
            if(created)// If set up - let's make tuning for it
              {
               //--- Point anchor is above in order not to cover bar
               ObjectSetInteger(0,string(Times[i]),OBJPROP_ANCHOR,ANCHOR_BOTTOM);
               //--- Final touch - painted
               ObjectSetInteger(0,string(Times[i]),OBJPROP_COLOR,clrRed);
               downcounter++;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
