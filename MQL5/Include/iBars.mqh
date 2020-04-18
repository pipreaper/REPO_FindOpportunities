//+------------------------------------------------------------------+
//|                                                        iBars.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Nikolay Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"  
#property version   "1.02"
//iBarsShift: Full and fast analog of iBarShift function (MQL4) (https://docs.mql4.com/series/ibarshift)
//iBars:      Full and fast analog of Bars function (https://www.mql5.com/ru/docs/series/bars)

int iBarShift(const string symb,const ENUM_TIMEFRAMES TimeFrame,datetime time,bool exact=false)
  {
   int Res=iBars(symb,TimeFrame,time+1,UINT_MAX);
   if(exact) if((TimeFrame!=PERIOD_MN1 || time>TimeCurrent()) && Res==iBars(symb,TimeFrame,time-PeriodSeconds(TimeFrame)+1,UINT_MAX)) return(-1);
   return(Res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iBars(string symbol_name,ENUM_TIMEFRAMES  timeframe,datetime start_time,datetime stop_time) // stop_time > start_time
  {
   static string LastSymb=NULL;
   static ENUM_TIMEFRAMES LastTimeFrame=0;
   static datetime LastTime=0;
   static datetime LastTime0=0;
   static int PerSec=0;
   static int PreBars=0,PreBarsS=0,PreBarsF=0;
   static datetime LastBAR=0;
   static datetime LastTimeCur=0;
   static bool flag=true;
   static int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
   datetime TimeCur;
   if (timeframe==0) timeframe=_Period;
   const bool changeTF=LastTimeFrame!=timeframe;
   const bool changeSymb=LastSymb!=symbol_name;
   const bool change=changeTF || changeSymb || flag;

   LastTimeFrame=timeframe; LastSymb=symbol_name;
   if(changeTF) PerSec=::PeriodSeconds(timeframe); if(PerSec==0) { flag=true; return(0);}

   if(stop_time<start_time)
     {
      TimeCur=stop_time;
      stop_time=start_time;
      start_time=TimeCur;
     }
   if(changeSymb)
     {
      if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT))
        {
         SymbolSelect(symbol_name,true);
         ChartRedraw();
        }
     }
   TimeCur=TimeCurrent();
   if(timeframe==PERIOD_W1) TimeCur-=(TimeCur+345600)%PerSec; // 01.01.1970 - Thursday. Minus 4 days.
   if(timeframe<PERIOD_W1) TimeCur-=TimeCur%PerSec;
   if(start_time>TimeCur) { flag=true; return(0);}
   if(timeframe==PERIOD_MN1)
     {
      MqlDateTime dt;
      TimeToStruct(TimeCur,dt);
      TimeCur=dt.year*12+dt.mon;
     }

   if(changeTF || changeSymb || TimeCur!=LastTimeCur)
      LastBAR=(datetime)SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE);

   LastTimeCur=TimeCur;
   if(start_time>LastBAR) { flag=true; return(0);}

   datetime tS,tF=0;
   if(timeframe==PERIOD_W1) tS=start_time-(start_time+345599)%PerSec-1;
   else if(timeframe<PERIOD_MN1) tS=start_time-(start_time-1)%PerSec-1;
   else  //  PERIOD_MN1
     {
      MqlDateTime dt;
      TimeToStruct(start_time-1,dt);
      tS=dt.year*12+dt.mon;
     }
   if(change || tS!=LastTime) { PreBarsS=Bars(symbol_name,timeframe,start_time,UINT_MAX); LastTime=tS;}
   if(stop_time<=LastBAR)
     {
      if(PreBarsS>=max_bars) PreBars=Bars(symbol_name,timeframe,start_time,stop_time);
      else
        {
         if(timeframe<PERIOD_W1) tF=stop_time-(stop_time)%PerSec;
         else if(timeframe==PERIOD_W1) tF=stop_time-(stop_time+345600)%PerSec;
         else //  PERIOD_MN1
           {
            MqlDateTime dt0;
            TimeToStruct(stop_time-1,dt0);
            tF=dt0.year*12+dt0.mon;
           }
         if(change || tF!=LastTime0)
           { PreBarsF=Bars(symbol_name,timeframe,stop_time+1,UINT_MAX); LastTime0=tF; }
         PreBars=PreBarsS-PreBarsF;
        }
     }
   else PreBars=PreBarsS;
   flag=false;
   return(PreBars);
  }
//+------------------------------------------------------------------+
int iBars(string symbol_name,ENUM_TIMEFRAMES  timeframe) {return(Bars(symbol_name,timeframe));}
//+------------------------------------------------------------------+
