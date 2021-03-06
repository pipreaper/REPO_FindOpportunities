//+------------------------------------------------------------------+
//|                                                marketdata1.mq4 |
//|                                 Copyright © 2011, MGAlgorithmics |
//|                                          http://www.mgaforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017 Robert Baptie Trading"
#property link      "http://www.RobertBaptieTrading.com"

#include <stderror.mqh>
#include <stdlib.mqh>
#include <waveLibrary.mqh>

//#define RISKPERCENT    1

#define LONG     0
#define SHORT    1
#define TYPE     2

#define SWAP     0
#define CURRENCY 1
#define DIR      2

#define SIZE     0   //Lot information
#define LOTSTEP  1
#define MIN      2
#define REQLOTS   3
#define SPREADCOST  4
#define POINTSIZE  5

#define VALUE    1  //Tick info

#define STARTING   0  //Timing info
#define EXPIRATION 1



#define CALC       0  //Margin
#define INIT       1
#define HEDGED     2
#define REQUIRED   3 
#define MARGIN_INIT = 0;

int ALLOWED =   0;  //Trade
int MODE=       1;  //profit calc mode

//string Symbols[1000];
//string Descr[1000];
double SyDigits[1000];
double Spread[1000];
double swap[1000][3];
double Stop[1000];
double Lot[1000][6];
double Tick[1000][2];
double Timing[1000][2];
double Trade[1000][2];
double Margin[1000][2];
double CurrentPrice[1000];

int p,n,TotalSymbols,MAX=0;
//+------------------------------------------------------------------+
void start()
  {
  //string ac = AccountCurrency();
   TotalSymbols=findAllSymbols();
   PrintResult("Market Data",TotalSymbols);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findAllSymbols()
  {
   int    handle,i,r,TotalRecords;
   string fname,Sy,descr;
//----->
   fname = "symbols.raw";
   handle=FileOpenHistory(fname, FILE_BIN | FILE_READ);
   if(handle<1)
     {
      Print("HTML Report generator - Unable to open file"+fname+", the last error is: ",GetLastError());
      return(false);
     }
   TotalRecords=FileSize(handle)/1936;
   ArrayResize(Symbols,TotalRecords);

   for(i=0; i<TotalRecords; i++)
     {
      Sy=FileReadString(handle,12);
      descr=FileReadString(handle,75);
      
      
    //int debug = 1;  
    //string dunno;
    //  for (int t = 532; t<=532;t++)
    //  {
    //     dunno = FileReadString(handle,t);
    //     if(dunno !="")
    //     debug = 1;
    //  }
      
      
      
      FileSeek(handle,1849,SEEK_CUR); // goto the next record

      Symbols[r]=Sy;
      Descr[r]=descr;
      SyDigits[r]=MarketInfo(Sy,MODE_DIGITS);

      Spread[r]=MarketInfo(Sy,MODE_SPREAD);

      swap[r][LONG]=MarketInfo(Sy,MODE_SWAPLONG);
      swap[r][SHORT]=MarketInfo(Sy,MODE_SWAPSHORT);
      swap[r][TYPE]=MarketInfo(Sy,MODE_SWAPTYPE);

      Stop[r]=MarketInfo(Sy,MODE_STOPLEVEL);

      Lot[r][SIZE]=MarketInfo(Sy,MODE_LOTSIZE);
      Lot[r][LOTSTEP]=MarketInfo(Sy,MODE_LOTSTEP);
      Lot[r][MIN]=MarketInfo(Sy,MODE_MINLOT);
      Lot[r][POINTSIZE]=MarketInfo(Sy,MODE_POINT);

      Tick[r][VALUE]=MarketInfo(Sy,MODE_TICKVALUE);
      Tick[r][SIZE]=MarketInfo(Sy,MODE_TICKSIZE);

      Timing[r][STARTING]=MarketInfo(Sy,MODE_STARTING);
      Timing[r][EXPIRATION]=MarketInfo(Sy,MODE_EXPIRATION);

      Trade[r][ALLOWED]=MarketInfo(Sy,MODE_TRADEALLOWED);    
      Trade[r][MODE]=InfoToStr(MarketInfo(Sy,MODE_PROFITCALCMODE),MODE_PROFITCALCMODE);
      //if(Trade[r][MODE]>MAX) MAX=Trade[r][MODE];

      Margin[r][0]=MarketInfo(Sy,MODE_MARGINREQUIRED);
      Margin[r][1]=AccountLeverage();
      CurrentPrice[r]=MarketInfo(Sy,MODE_BID);
      r++;
     }

   FileClose(handle);
   return(TotalRecords);
  }
//+------------------------------------------------------------------+
string Line(int i)
  {
   string fs1;

   fs1=StringConcatenate(
                         "<td>"+DoubleToStr(i,0)+"</td>",
                         "<td>"+Symbols[i]+"</td>",
                         "<td nowrap>"+Descr[i]+"</td>",
                         "<td>"+DoubleToStr(SyDigits[i],0)+"</td>",
                         "<td>"+DoubleToStr(Spread[i],0)+"</td>",
                         "<td>"+DoubleToStr(Margin[i][0],0)+"</td>",
                         "<td>"+DoubleToStr(Lot[i][MIN],3)+"</td>",
                         "<td>"+DoubleToStr(Stop[i],0)+"</td>",
                         "<td>"+DoubleToStr(Tick[i][VALUE],6)+"</td>",
                         "<td>"+DoubleToStr(Tick[i][SIZE],6)+"</td>",
                         "<td>"+DoubleToStr(Lot[i][POINTSIZE],8)+"</td>",
                         "<td>"+DoubleToStr(Margin[i][1],0)+"</td>",
                         "<td>"+DoubleToStr(Lot[i][SIZE],0)+"</td>",
                         "<td>"+DoubleToStr(Lot[i][LOTSTEP],3)+"</td>",
                         "<td bgcolor=\""+Highlight(swap[i][LONG])+"\">"+DoubleToStr(swap[i][LONG],4)+"</td>",
                         "<td bgcolor=\""+Highlight(swap[i][SHORT])+"\">"+DoubleToStr(swap[i][SHORT],4)+"</td>",
                         "<td>"+InfoToStr(swap[i][TYPE],MODE_SWAPTYPE)+"</td>",
                         "<td>"+DoubleToStr(CurrentPrice[i],MarketInfo(Symbols[i],MODE_DIGITS))+"</td>",
                         "<td>"+InfoToStr(Trade[i][ALLOWED],MODE_TRADEALLOWED)+"</td>",
                         "<td>"+InfoToStr(Trade[i][MODE],MODE_PROFITCALCMODE)+"</td>",
                         "<td>"+TimeToStr(Timing[i][STARTING])+"</td>",
                         "<td>"+TimeToStr(Timing[i][EXPIRATION])+"</td>"
                         );
   return(fs1);
  }
//+------------------------------------------------------------------+  
int PrintResult(string title,int symbols)
  {
   int i,h;
   string fname,col="#E0E0E0";
   string sl,s0,fs;
//----
   fname=title+".html";
   h=FileOpen(fname,FILE_WRITE|FILE_COMMON);
   if(h<1)
     {
      Print("HTML Report generator - Unable to open file"+fname+", the last error is: ",GetLastError());
      return(false);
     }

   s0="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">";FileWrite(h,s0);
   s0="<html><head><title>"+AccountCompany()+" "+title+"</title>";FileWrite(h,s0);
   s0="<meta name=\"generator\" content=\"Robert Baptie Trading.\">";FileWrite(h,s0);
   s0="<link rel=\"help\" href=\"http://Robert Baptie Trading\">";FileWrite(h,s0);

   s0="<style type=\"text/css\" media=\"screen\">";FileWrite(h,s0);
   s0="<!--td { font: 8pt mono,Arial; }//--></style>";FileWrite(h,s0);

   s0="</head>";FileWrite(h,s0);

   s0="<body topmargin=1 marginheight=1 style=\"background-color:#EEEEEE;\">";FileWrite(h,s0);

   s0="<div align=center><div style=\"font: 12pt Arial\">";FileWrite(h,s0);
   s0="<b>"+WindowExpertName()+".ex4 Generated Report</b>";FileWrite(h,s0);
   s0="</div>";FileWrite(h,s0);

   s0="<div align=center><div style=\"font: 12pt mono\">";FileWrite(h,s0);
   s0="<b>@2017 <a href=\"http://RobertBaptieTrading.com\">RobertBapteTrading.com</a></b>";FileWrite(h,s0);
   s0="</div>";FileWrite(h,s0);
   s0="<br>";FileWrite(h,s0);

   s0="<div style=\"width:1000px;\">";FileWrite(h,s0);

   s0="<span style=\"float:left; background-color:#CCCCCC; border:1px solid; border-color:#C0C0C0;\">";FileWrite(h,s0);
   s0="<table cellspacing=3 cellpadding=3 border=0>";FileWrite(h,s0);

   s0="<tr align=center bgcolor=\"#bc65a2\"><font color=\"#FFFFFF\">";FileWrite(h,s0); //6666CC
   FileWrite(h,Header());
   s0="</tr>";FileWrite(h,s0);
   double count=0;
   for(i=0; i<symbols; i++)
     {
      count++;
      if(count==25)
        {
         s0="<tr align=center bgcolor=\"#bc65a2\"><font color=\"#FFFFFF\">";FileWrite(h,s0);
         FileWrite(h,Header());
         s0="</tr>";FileWrite(h,s0);
         count=0;
        }
      fs=StringConcatenate("<tr align=center bgcolor=\""+col+"\">",Line(i),"</tr>");
      FileWrite(h,fs);
     }

   s0="</table>";FileWrite(h,s0);
   s0="</span>"; FileWrite(h,s0);
   s0="</span></div></body></html>"; FileWrite(h,s0);
   FileClose(h);

//----
   return(0);
  }
//+------------------------------------------------------------------+
string Header()
  {
   string s0;
   s0=StringConcatenate(
                        "<td>#</td>",
                        "<td>Symbol</td>",
                        "<td>Description</td>",
                        "<td>Digits</td>",
                        "<td>Spread</td>",
                        "<td>£ MARGIN REQ 1 LOT</td>",
                        "<td>LOT MIN</td>",
                        "<td>Stop Level</td>",
                        "<td>TICK VALUE</td>",
                        "<td>TICK SIZE</td>",
                        "<td>POINT SIZE</td>",
                        "<td>ACC LEV</td>",
                        "<td>Lot Size</td>",
                        "<td>Lot Step</td>",
                        "<td>Swap Long</td>",
                        "<td>Swap Short</td>",
                        "<td>Swap Type</td>",
                        "<td>Bid</td>",
                        "<td>Trade Allowed</td>",
                        "<td>Pr. Mode</td>"
                        "<td>Starting</td>",
                        "<td>Expiration</td>"
                        );
//----
   return(s0);
  }
//+------------------------------------------------------------------+ 
void tradable(string symbol,double accEquity,double spread,double risk,double &lots,double &spreadCost)
  {
   double  stopPounds=(accEquity*risk/100.0);
   double numberPoints=spread;//#number of points in stop distance
   double normaliseTickNotEqualPoint = MarketInfo(symbol, MODE_POINT) / MarketInfo(symbol, MODE_TICKSIZE);
   double priceOneLotThisStopDistance=numberPoints * MarketInfo(symbol,MODE_TICKVALUE) * normaliseTickNotEqualPoint;
   if(priceOneLotThisStopDistance!=0)
     {
      lots=stopPounds/priceOneLotThisStopDistance; //simple fraction of one lot (what want to risk GBP / Current Cost Per Lot for this stop distance
     }
   else
     {
      lots=0;
     }
   spreadCost=priceOneLotThisStopDistance;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Highlight(double sw)
  {
   string res;
   if(sw<0) res="#E0E0E0";
   if(sw>=0) res="#C0C0C0";
//----
   return(res);
  }
//+------------------------------------------------------------------+
//string InfoToStr(double info,int mode)
//  {
//   switch(mode)
//     {
//      case MODE_PROFITCALCMODE:
//         if(info==0) return ("Forex");
//         if(info==1) return ("CFD");
//         if(info==2) return ("Future");
//         break;
//      case MODE_TRADEALLOWED:
//         if(info==1) return ("yes");
//         if(info!=1) return ("no");
//         break;
//      case MODE_SWAPTYPE:
//         if(info==0) return ("points");
//         if(info==1) return ("dep ccy");
//         if(info==2) return ("percent");
//         break;
//     }
//   return "should not be here";
//  }
////+------------------------------------------------------------------+
