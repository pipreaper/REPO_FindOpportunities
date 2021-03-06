//+------------------------------------------------------------------+
//|                                                  WaveLibrary.mqh |
//|                                    Copyright 2017, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "2.15"
#property strict
//#include <stderror.mqh>
#include <errordescription.mqh>
//#include <status.mqh>
#include <INCLUDE_FILES\SymbolsInfo.mqh>
//#include <SymbolsInfo.mqh>
#define INF 0x6FFFFFFF//Large Number
// general up down congesstion arrows
uchar uArrow = 228;
uchar dArrow = 230;
uchar cArrow = 224;//232;
uchar nullArrow=62;
//ad stuff
uchar absoluteDownArrow=234;
uchar absoluteUpArrow=233;
const ENUM_ARROW_ANCHOR arrowAnchor=ANCHOR_BOTTOM;
enum highLowAddType {highType,lowType};
enum ENUM_CAT_ID {TRD,VOL};
// **Testing halt
#import "user32.dll"
void keybd_event(int bVk, int bScan, int dwFlags,int dwExtraInfo);
#import
#define VK_SPACE 0x20 //Space
//#define VK_RETURN 0x0D //Return - Enter Key
#define KEYEVENTF_KEYUP 0x0002  //Key up
// **Testing Halt
//+------------------------------------------------------------------+
//|Press space bar to continue visal run                             |
//|https://www.mql5.com/en/forum/270837                              |
//+------------------------------------------------------------------+
void pauseDuringTesting(bool _pauseMe)
  {
   if(_pauseMe && MQLInfoInteger(MQL_TESTER) && MQLInfoInteger(MQL_VISUAL_MODE))
     {
      keybd_event(VK_SPACE, 0, 0, 0);
      keybd_event(VK_SPACE, 0, KEYEVENTF_KEYUP, 0);
     }
  }
//+------------------------------------------------------------------+
//|Print Array                                                       |
//+------------------------------------------------------------------+
bool printRatesArray(MqlRates &tempArray[])
  {
//---Pertains to strategy testing
   for(int shft=ArraySize(tempArray)-1; shft>=0; shft--)
     {
      if(MqlRatesHasValue(tempArray,shft))
         Print(__FUNCTION__," shift", shft," time: ", tempArray[shft].time);
      else
         Print(__FUNCTION__" Has noValue, shift: ", shft);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|return index of tf passed in                                      |
//+------------------------------------------------------------------+
int findIndexPeriod(ENUM_TIMEFRAMES _TF)
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
color findColor(int _index)
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
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void CommentLab(string CommentText)
//  {
//   string CommentLabel;
//   int CommentIndex = 0;
//
//   if(CommentText == "")
//     {
//      //  delete all Comment texts
//StringConcatenate(CommentLabel, CommentIndex);      
//      while(ObjectFind(CommentLabel) >= 0)
//        {
//         ObjectDelete(StringConcatenate("CommentLabel", CommentIndex));
//         CommentIndex++;
//        }
//      return;
//     }
//
//   while(ObjectFind(StringConcatenate("CommentLabel", CommentIndex)) >= 0)
//     {
//      CommentIndex++;
//     }
//
//   CommentLabel = StringConcatenate("CommentLabel", CommentIndex);
//   ObjectCreate(CommentLabel, OBJ_LABEL, 0, 0, 0);
//   ObjectSet(CommentLabel, OBJPROP_CORNER, 0);
//   ObjectSet(CommentLabel, OBJPROP_XDISTANCE, 5);
//   ObjectSet(CommentLabel, OBJPROP_YDISTANCE, 15 + (CommentIndex * 15));
//   ObjectSetText(CommentLabel, CommentText, 10, "Tahoma", Status_Color);
//  }
//+------------------------------------------------------------------+
//|DLine state                                                       |
//+------------------------------------------------------------------+
enum setUpState
  {
   init_diag_line,
   waiting_trigger_break_resistance,
   waiting_trigger_break_support,
   open_long,
   open_short,
   trending,
  };
//+------------------------------------------------------------------+
//|CCI states                                                        |
//+------------------------------------------------------------------+
enum cciClicked
  {
   cciNone,
   cciAbove100,
   cciBelow100
  };
//+------------------------------------------------------------------+
//|big belt states                                                   |
//+------------------------------------------------------------------+
enum simState
  {
   simLong,
   simShort,
   simNone
  };
//+------------------------------------------------------------------+
//|room to the left                                                  |
//+------------------------------------------------------------------+
enum rttl
  {
   rttlHigh,
   rttlLow,
   rttlNone
  };
//+------------------------------------------------------------------+
//|which ATR calculation method                                      |
//+------------------------------------------------------------------+
enum dataLoadState
  {
   doInitBroker,
   doInitIndicatorsTick,
   doStratElement,
   doStartStrategy,
   doDataHasLoaded
  };
//+------------------------------------------------------------------+
//|which ATR calculation method                                      |
//+------------------------------------------------------------------+
enum waveCalcSizeType
  {
   waveCalcATR,
   waveCalcFixed
  };
//+------------------------------------------------------------------+
//|which symbols File to use                                         |
//+------------------------------------------------------------------+
enum ENUM_MY_FILES
  {
   Forex_Majors,
   Forex_Minors,
   Forex_Crosses,
   Forex_All,
   Major_Index,
   Minor_Index,
   Crypto,
   Dollar,
   Oil,
   _Gold,
   Silver_Precious_Metals,
   Hard_Commodities,
   Soft_Commodities,
   US_Stocks,
   mixed
  };
string fileSets[15]= {"forex.majors.SET","forex.minors.SET","forex.crosses.SET","forex.all.tradable.SET",
                      "major.index.SET","minor.index.SET",
                      "crypto.retail.SET",
                      "dollar.SET",
                      "oil.SET","gold.SET","silver.precious.metals.SET",
                      "hard.commodities.SET","soft.commodities",
                      "us.stocks.SET",
                      "mixed.SET"
                     };
//+------------------------------------------------------------------+
//| convertTriggerText                                               |
//+------------------------------------------------------------------+
string convertSymbolsFileText(int _choice)
  {
   string fileSet = NULL;
   fileSet = fileSets[_choice];
   return fileSet;
  }
//+------------------------------------------------------------------+
//|which trigger Set to use                                          |
//+------------------------------------------------------------------+
enum choiceTrigger
  {
   trendTrigger,
   AdTrigger,
   AdAndTrendTrigger
  };
////+------------------------------------------------------------------+
////|which set trend to use                                            |
////+------------------------------------------------------------------+
//enum isCycleExtendInterrupt
//  {
//   cycle,
//   extend
//  };
//+------------------------------------------------------------------+
//|showWaveLabels                                                    |
//+------------------------------------------------------------------+
enum showWaveLabels
  {
   showPrice=0,
   showVolumeLabels=1,
   showNone=2,
   showOnlyArrows
  };
//+------------------------------------------------------------------+
//|trendState                                                        |
//+------------------------------------------------------------------+
enum trendState
  {
   up,
   down,
   congested,
   initialTipState
  };
//+------------------------------------------------------------------+
//|trendElementState                                                 |
//+------------------------------------------------------------------+
enum trendElementState
  {
   firstTipeTEState,
   upTEState,
   downTEState
  };
//+------------------------------------------------------------------+
//|convert trend identifying integer to text                         |
//+------------------------------------------------------------------+
string tipEnumToString(trendState dir)
  {
   switch(dir)
     {
      case up:
         return "up";
         break;
      case down:
         return "down";
         break;
      case congested:
         return "congested";
         break;
      case initialTipState:
         return "initialtrendState";
         break;
     }
   return "NULL";
  }
//+------------------------------------------------------------------+
//| getArrowCode                                                     |
//+------------------------------------------------------------------+
//uchar getArrowCode(trendState tState)
//  {
//   if(tState==up)
//      return uArrow;
//   else
//      if(tState==down)
//         return dArrow;
//      else
//         if(tState==congested)
//            return cArrow;
//         else
//            return NULL;
//  }
//+------------------------------------------------------------------+
//| getState                                                         |
//+------------------------------------------------------------------+
//trendState getState(uchar arrowCode)
//  {
//   if(arrowCode==uArrow)
//      return up;
//   else
//      if(arrowCode==dArrow)
//         return down;
//   if(arrowCode==cArrow)
//      return congested;
//   else
//      return NULL;
//  }
//+------------------------------------------------------------------+
//| getStateString                                                   |
//+------------------------------------------------------------------+
//string getStateString(uchar arrowCode)
//  {
//   if(arrowCode==uArrow)
//      return "up";
//   else
//      if(arrowCode==dArrow)
//         return "down";
//   if(arrowCode==cArrow)
//      return "cong";
//   else
//      return NULL;
//  }
//+------------------------------------------------------------------+
//|direction of accumulation distribution arrows: ADPeriodObj        |
//+------------------------------------------------------------------+
enum direcxion
  {
   supply,
   demand,
   none,
   initialAdState,
   isVoidAd
  };
//+------------------------------------------------------------------+
//|string direction of accumulation distribution arrows: ADPeriodObj |
//+------------------------------------------------------------------+
string adEnumToString(direcxion dir)
  {
   switch(dir)
     {
      case supply:
         return "supply";
         break;
      case demand:
         return "demand";
         break;
      case none:
         return "none";
         break;
     }
   return "NULL";
  }
//+------------------------------------------------------------------+
//|direction of accumulation distribution arrows: setUp              |
//+------------------------------------------------------------------+
enum isSet
  {
   isUp=1,
   isDown=-1,
   isNone=0,
  };
//+------------------------------------------------------------------+
//| crash the system divide by zero                                  |
//+------------------------------------------------------------------+
void crash()
  {
   double two = 2;
   double nought = 0;
   double crashMe = two/nought;
  }
//+------------------------------------------------------------------+
//| return true if candle is date                                    |
//+------------------------------------------------------------------+
bool isDate(int shft=0, int min=0,int hour=0,int day=0,int mon=0,int year=0, string sym=NULL, ENUM_TIMEFRAMES tf=NULL, bool showDate=true, int _lastRates=3)
  {
   if(sym ==NULL)
      sym=_Symbol;
   if(tf == NULL)
      tf = _Period;
   datetime currentCandle=NULL;
   if(shft>=0)
     {
      datetime tda[];
      CopyTime(_Symbol,_Period,shft,1,tda);
      currentCandle=tda[0];
     }
   else
     {
      Print(__FUNCTION__, "Need to pass shift+1");
      DebugBreak();
     }
   MqlDateTime ccs;
   TimeToStruct(currentCandle,ccs);

   if(
      ccs.min==min &&
      ccs.hour==hour &&
      ccs.day==day &&
      ccs.mon==mon &&
      ccs.year==year)
     {
      if(showDate)
        {
         for(int r = shft; r <= (shft+_lastRates); r++);
         Print(__FUNCTION__," SYM: ", sym," tf: ",EnumToString(tf)," shft+1: ",shft," Hrs: ",ccs.hour," Mins: ",ccs.min," Day: ",ccs.day," Month: ",ccs.mon," Year: ",ccs.year);
        }
      DebugBreak();
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//|open file                                                         |
//+------------------------------------------------------------------+
int openSymbolFile(string _sym,ENUM_TIMEFRAMES _wtf,string &_fileName,string &_fgName,string fileNumber,double accountEquity)
  {
   int _handle=-1;
   string prefix=NULL;
   int g=0;
   do
     {
      g+=g;
      _fgName=symbolType(_sym);
      if((_fgName!=NULL) || (g>5))
         break;
      Sleep(2);
     }
   while(_fgName==NULL);
   if(_fgName==NULL)
     {
      prefix="BULL: "+_sym+" "+string(_wtf);
      // Print(prefix);
     }
   if(fileNumber==NULL)
     {
      _fileName=prefix+"cumulative Profit^"+_sym+"^"+_fgName+"^"+string(_wtf)+".csv";
      if(FileIsExist(_fileName))//FILE_COMMON
         FileDelete(_fileName);
      _handle=FileOpen(_fileName,FILE_WRITE|FILE_CSV);
      if(_handle<0)
        {
         Print(" file Open Error ");
         return _handle;
        }
     }
//open details file
   else
     {
      prefix+=fileNumber;
      _fileName=prefix+"Profits"+"^"+string(_wtf)+".csv";
      if(!FileIsExist(_fileName))//FILE_COMMON
        {
         _handle=FileOpen(_fileName,FILE_WRITE|FILE_READ|FILE_CSV);
         FileWrite(_handle,"Account Equity: ",accountEquity);
         FileWrite(_handle,"symbol","wtf","group","HMPercentile","Pounds","Points: ","Period","Num Trades:","Win:","MDD pounds","Avg CSI:","Avg Bet");
         //FileWrite(_handle,"symbol","_wtf","ATRTF","ttf","group","cumProfit"," MaxDrawdown"," Start Time"," End Time"," Duration "," #Trades");
        }
      else
         _handle=FileOpen(_fileName,FILE_WRITE|FILE_READ|FILE_CSV);
      if(_handle<0)
        {
         Print(" file Open Error: "+fileNumber);
         return _handle;
        }
     }
   string symbol=NULL;
   return _handle;
  }
//+------------------------------------------------------------------+
//|isIntempArray if testing use only symbols in tempArray main Expert|
//+------------------------------------------------------------------+
bool isIntempArray(string sym,string &tempArray[])
  {
//---Pertains to strategy testing
   for(int i=0; i<ArraySize(tempArray); i++)
     {
      string symMatch=tempArray[i];
      if(sym==symMatch)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|sortBy                                                            |
//+------------------------------------------------------------------+
enum sortBy
  {
   name=0,//sortName
   CSI=1,//csi
   ATRspreadMoney=2,//atrPerSpreadPence
   ADX=3,//adx
   ADXR=4,//adxr
   capMaxLotsSpreadMoney=5,//restrictedMaxLotsSpreadMoney
   ATR=6,//atr
   capMaxLotsATRMoney=7,//restrictedMaxLotsATRMoney
   spreadQuids=8,//spreadQuids
  };
//+------------------------------------------------------------------+
//|enumeration event timer                                           |
//+------------------------------------------------------------------+
enum eventTimer
  {
   S60=60,//60 Seconds
   S100=100,//100 seconds
   M5=300,//5 Minutes
   M15=900,//15 Minutes
   M30=1800,//30 Minutes
   H1=3600,//1 Hour
   H4=14400,//4 Hour
   D1=345600//1 Day
  };
//+------------------------------------------------------------------+
//| information for recording trades in indicator trendIndicator     |
//+------------------------------------------------------------------+
struct info
  {
   string            state;//BUY, SELL, NOTHING
   double            stop;
   double            target;
   double            oPrice;     // Open Price
   double            cPoints;    // Cumulative Time
   datetime          oTime;   // Open Time
   double            maxDrawDown;//max cumulative loss
   int               numberTrades;// number of trades
   int               numberWins;
   double            cGBP;
   double            csi;
   double            cCSI;
   double            betNumPounds;
   double            cBet;
   datetime          startTime;
   double            pointSize;
   double            tickValue;
   double            tickSize;
  };
//+------------------------------------------------------------------+
//|  //  convert datetime seconds since jan 1 1970                   |
//+------------------------------------------------------------------+
uint ConvertDateToSecs(datetime _d)
  {
   uint       secs=(uint)_d;
   Print(_d," is equal to ",secs," seconds after January 01, 1970");
   return secs;
  }
//+------------------------------------------------------------------+
//| find Index for determining higher time frame values              |
//+------------------------------------------------------------------+
int findWTFIndex(ENUM_TIMEFRAMES per,ENUM_TIMEFRAMES StartEnum)
  {
//string s = EnumToString(per);
//int i = StringToInteger(s);
//return i;
   if(per==PERIOD_CURRENT)
      per=ENUM_TIMEFRAMES(Period());
   int count=-1;
   for(ENUM_TIMEFRAMES enumTF=PERIOD_M1; enumTF<=PERIOD_MN1; enumTF++)
     {
      count+=1;
      if(per==enumTF)
        {
         StartEnum=enumTF;
         return count;
        }
     }
   return -1;
  }
//+-------------------------------------------------------------------------------------+
//| Period enum to minutes                                                              |
//+-------------------------------------------------------------------------------------+
int periodEnumToMinutes(ENUM_TIMEFRAMES period=PERIOD_CURRENT)
  {
   period=period==PERIOD_CURRENT?(ENUM_TIMEFRAMES)Period():period;
   return PeriodSeconds(period)/60;
  }
//+-------------------------------------------------------------------------------------+
//| Get Time elapsed in seconds                                                          |
//+-------------------------------------------------------------------------------------+
double getElapsedTimeSecs(datetime timeNow,datetime timeHist)
  {
   double diffHours=-1;
   MqlDateTime now,hist;
   TimeToStruct(timeNow,now);
   TimeToStruct(timeHist,hist);
   double nowSec=0.0;
   double histSec=0.0;
   double nowYears  = now.year  * 365.0 * 24.0 * 3600.0;
   double histYears = hist.year * 365.0 * 24.0 * 3600.0;
   nowSec+=nowYears;
   histSec+=histYears;
//Print(__FUNCTION__," nowYears :",nowSec);
//Print(__FUNCTION__," histYears :",histSec);
   double nowDays=now.day_of_year *24.0*3600.0;
   double histDays=hist.day_of_year*24.0*3600.0;
   nowSec+=nowDays;
   histSec+=histDays;
//Print(__FUNCTION__," nowDays :",nowSec);
//Print(__FUNCTION__," histDays :",histSec);
   double nowHours=now.hour*3600.0;
   double histHours=hist.hour*3600.0;
   nowSec+=nowHours;
   histSec+=histHours;
//Print(__FUNCTION__," nowHours :",nowSec);
//Print(__FUNCTION__," histHours :",histSec);
   double nowMinutes=now.min*60.0;
   double histMinutes=hist.min*60.0;
   nowSec+=nowMinutes;
   histSec+=histMinutes;
//Print(__FUNCTION__," nowMinutes :",nowSec);
//Print(__FUNCTION__," histMinutes :",histSec);
   double nowSeconds=now.sec;
   double histSeconds=hist.sec;
   nowSec+=nowSeconds;
   histSec+=histSeconds;
//Print(__FUNCTION__," nowSeconds :",nowSec);
//Print(__FUNCTION__," histSeconds :",histSec);

   double diffAllSecs=nowSec-histSec;
//Print(__FUNCTION__," diffAllSecs :",diffAllSecs);
   diffAllSecs=diffAllSecs;
//Print(__FUNCTION__," diffAllSecs :",diffAllSecs);
   return diffAllSecs;
  }
//+-------------------------------------------------------------------------------------+
//| Check to see if Time now is greater than (x) hours since instrument was last traded |
//+-------------------------------------------------------------------------------------+
bool checkDatesDifferenceHours(datetime timeNow,datetime timeHist,int hrs)
  {
   double diffHours=double(timeNow-timeHist)/3600;
//Print("Symbol: ", sym," N ",timeNow," H ",timeHist,"DIFF: ",diffHours);
   if(diffHours<hrs)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|VOLUME OR PRICE                                                   |
//+------------------------------------------------------------------+
enum volume_price
  {
   WAVE_PRICE,
   DELTA_VOLUME,
   DELTA_PRICE,
   DELTA_TIME,
   DELTA_V_BY_T,
   DELTA_P_BY_T,
   SPARE,
   PINCH
  };
string text_volume_price[8]= {"WAVE_PRICE","DELTA_VOLUME","DELTA_PRICE","DELTA_TIME","DELTA_V_BY_T","DELTA_P_BY_T","SPARE","PINCH"};
//+------------------------------------------------------------------+
//|CONG OR CONG END                                                  |
//+------------------------------------------------------------------+
enum congestion_NORM_END
  {
   NORMAL,
   END
  };
//+------------------------------------------------------------------+
//|congestionType                                                    |
//+------------------------------------------------------------------+
enum congestionType
  {
   ALL,
   INSIDE,
   TOPBOTTOM,
   TOP,
   BOTTOM
  };
//+------------------------------------------------------------------+
//|Find the enum text associated with enum value                     |
//+------------------------------------------------------------------+
string TFPosition(string &sArray[],ENUM_TIMEFRAMES &tfs[],int thisPeriod)
  {
   for(int i=0; i<ArraySize(tfs); i++)
     {
      if(tfs[i]==thisPeriod)
         return sArray[i];
     }
   return  NULL;
  }
//+------------------------------------------------------------------+
//|Find Index in Symbols List                                        |
//+------------------------------------------------------------------+
int findIndex(string symbol,int tSymbols)
  {
   for(int i=0; i<tSymbols; i++)
     {
      if(SymbolName(i,false)==symbol)
         return(i);
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//| Normalise double                                                 |
//+------------------------------------------------------------------+
double ND(double valx,int DIGITS)
  {
   return(NormalizeDouble(valx, DIGITS));
  }
//+------------------------------------------------------------------+
//|round Down Decimal to dig places                                  |
//+------------------------------------------------------------------+
double roundDownDecimal(double value,int dig)
  {
   double power=MathPow(10,dig);
   double v=value*power;
   v= MathFloor(v);
   v=v/power;
   return v;
  }
//+------------------------------------------------------------------+
//| Count decimal places in double                                   |
//+------------------------------------------------------------------+
int calcDecimalPlaces(double value)
  {
   string sValue=string(value);
   StringTrimLeft(sValue);
   StringTrimRight(sValue);
   int lenString=StringLen(sValue);
   int posPlace=StringFind(sValue,".",0)+1;
   int places=lenString-posPlace;
   return places;
  }
//+------------------------------------------------------------------+
//| Set Event Timer on interval real interval or testing             |
//+------------------------------------------------------------------+
int setEventTimer(bool test=true,int interEvent=300,int testInterEvent=10)
  {
   double minute=-1;
   double rem=-1;
   double mult=-1;
   double whole=-1;
   if(!test)
     {
      do
        {
         datetime timeNow=TimeGMT();//TimeCurrent();
         MqlDateTime str1;
         TimeToStruct(timeNow,str1);
         minute=double(str1.min);//double(TimeMinute(dt));
         mult=double(minute/5);
         whole=NormalizeDouble(MathFloor(mult),0);
         rem=mult-whole;
         Sleep(2000);//unload processor;
        }
      while(rem!=0);
      EventSetTimer(1);
      return interEvent;
     }
   else
     {
      EventSetTimer(testInterEvent);//seconds
      return testInterEvent;
     }
  }
//+------------------------------------------------------------------+
//|Default size of arrays for Symbols & Descr                        |
//+------------------------------------------------------------------+
//string Symbols[1000];
//string Descr[1000];
//int SymbolIndex[1000];
//+------------------------------------------------------------------+
//|prospects to consider in trading loop                             |
//+------------------------------------------------------------------+
struct prospect
  {
   string            symbol;
   string            desc;
   int               symbolIndex;
   bool              isEnabled;
   bool              runtimeAllowed;
                     prospect()
     {
      symbol=NULL;
      desc=NULL;
      symbolIndex=-1;
      isEnabled=false;
      runtimeAllowed=false;
     }
  };
//+------------------------------------------------------------------+
//| ProspectArray                                                    |
//+------------------------------------------------------------------+
prospect          prospectArray[1000];
//+------------------------------------------------------------------+
//| Find Symbols                                                     |
//+------------------------------------------------------------------+
//int  FindSymbols()
//  {
//   int    handle,i,TotalRecords;
//   string fname,Sy,descr;
////----->
//   fname = "symbols.raw";
//   handle=FileOpenHistory(fname, FILE_BIN | FILE_READ);
//   if(handle<1)
//     {
//      Print("HTML Report generator - Unable to open file"+fname+", the last error is: ",GetLastError());
//      return(false);
//     }
//   TotalRecords=(int)FileSize(handle)/1936;
//   ArrayResize(prospectArray,TotalRecords);
////ArrayResize(Descr,TotalRecords);
//
//   for(i=0; i<TotalRecords; i++)
//     {
//      Sy=FileReadString(handle,12);
//      descr=FileReadString(handle,75);
//      FileSeek(handle,1849,SEEK_CUR); // goto the next record
//      prospectArray[i].symbol=Sy;
//      prospectArray[i].desc=descr;
//      prospectArray[i].symbolIndex=i;
//     }
//   FileClose(handle);
//   return(TotalRecords);
//  }
//+------------------------------------------------------------------+
//| IsSymbolInMarketWatch                                            |
//+------------------------------------------------------------------+
bool IsSymbolInMarketWatch(string f_Symbol)
  {
   for(int s=0; s<SymbolsTotal(true); s++)
     {
      if(f_Symbol==SymbolName(s,true))
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| get text description                                             |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
//---
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";
         break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";
         break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";
         break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";
         break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";
         break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";
         break;
      case REASON_CLOSE:
         text="Program "+__FILE__+" terminal was closed";
         break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";
         break;
      default:
         text="Another reason";
     }
//---
   return text;
  }
//+------------------------------------------------------------------+
//|  Check if raTES ARRAY INDEX HAS VALUE                            |
//+------------------------------------------------------------------+
bool Time2HasValue(const datetime &t[],int index)
  {
   int size=ArraySize(t);
   if(index<size)
     {
      return(true);
     }
   else
     {
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//int thisTFPosition()
//  {
//   int thisPeriod=Period();
////  int size = ArraySize(tfEnum) - 1;
//   for(int i=0; i<ArraySize(tfEnumFull); i++)
//     {
//      if(tfEnumFull[i]==thisPeriod)
//         return i;
//     }
//   return  -1;
//  }
//+------------------------------------------------------------------+
//|  Check if Time[]ARRAY INDEX HAS VALUE                            |
//+------------------------------------------------------------------+
bool TimeHasValue(datetime t,int index)
  {
   ResetLastError();
   if(t>0)
      return true;
   else
     {
      //    Print(ErrorDescription(GetLastError()));
      return false; // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|  Check if raTES ARRAY INDEX HAS VALUE                            |
//+------------------------------------------------------------------+
bool TimeArrayHasValue(datetime &_time[],int index)
  {
   ResetLastError();
   int size=ArraySize(_time);
   if(index<size)
     {
      return(true);
     }
   else
     {
      //   Print(ErrorDescription(GetLastError()));
      return false; // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|  Check if raTES ARRAY INDEX HAS VALUE                            |
//+------------------------------------------------------------------+
bool MqlRatesHasValue(MqlRates &rates[],int index)
  {
   int size=ArraySize(rates);
   if(index<size)
     {
      return(true);
     }
   else
     {
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool longHasValue(const long &dArray[],int index)
  {
   int size=ArraySize(dArray);
   if(index<size && index>=0)
     {
      return(true);
     }
   else
     {
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool double2HasValue(const double &dArray[],int index)
  {
   int size=ArraySize(dArray);
   if(index<size)
     {
      return(true);
     }
   else
     {
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool doubleHasValue(double &dArray[],int index,bool printMe)
  {
   int size=ArraySize(dArray);
   if(index<size)
     {
      return(true);
     }
   else
     {
      //if(printMe)
      //       Print("size of Array: ",ArraySize(dArray)," index: ",index);
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool intHasValue(int &dArray[],int index)
  {
   int size=ArraySize(dArray);
   if(index<size && index>=0)
     {
      return(true);
     }
   else
     {
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|  Has Double array got a value                                    |
//+------------------------------------------------------------------+
bool constArrayDoubleHasValue(const double &dArray[],int index)
  {
   int size=ArraySize(dArray);

   if(index<size && index>=0)
     {
      return(true);
     }
   else
     {
      return(false); // False is the exception
     }
  }
//+------------------------------------------------------------------+
//|Calculate Pivot Points                                    |
//+------------------------------------------------------------------+
//void calcDailyPivots(string symbol,int period,double &piv,double &r1,double &r2,double &r3,double &s1,double &s2,double &s3)
//  {
//   double LastHigh= iHigh(symbol,period,1);
//   double LastLow = iLow(symbol,period,1);
//   double LastClose=iClose(symbol,period,1);
//   piv=(LastHigh+LastLow+LastClose)/3;
//   r1 = (2*piv)-LastLow;
//   s1 = (2*piv)-LastHigh;
//   r2 = piv+(LastHigh - LastLow);
//   s2 = piv-(LastHigh - LastLow);
//   r3 = (2*piv)+(LastHigh-(2*LastLow));
//   s3 = (2*piv)-((2* LastHigh)-LastLow);
//  }
//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(long            chart_ID=0,// chart's ID
                 const string          name="line",// line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           thisClr=clrRed,// line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,NULL,price))
     {
      Print(__FUNCTION__," "+name+": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,thisClr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
//bool HLineMove(long   chart_ID,// chart's ID
//               string NM,// line name
//               double       price) // line price
//  {
////--- reset the error value
//   ResetLastError();
////--- move a horizontal line
//   if(!ObjectMove(chart_ID,NM,0,Time[0],price))
//     {
//      Print(__FUNCTION__," price: ",string(price)," name: ",NM," failed to move the horizontal line! Error code = ",GetLastError());
//      return(false);
//     }
//   else
//     {
//      //--- forced chart redraw
//      ChartRedraw(chart_ID);
//      Sleep(100);
//     }
////--- successful execution
////Print(name);
//   return(true);
//  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool HLineDelete(const long   chart_ID=0,// chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| The function enables/disables the chart grid.                    |
//+------------------------------------------------------------------+
bool ChartShowGridSet(const bool value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set the property value
   if(!ChartSetInteger(chart_ID,CHART_SHOW_GRID,0,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+---------------------------------------------------------------------------+
//| The function enables/disables the mode of displaying a price chart on the |
//| foreground.                                                               |
//+---------------------------------------------------------------------------+
bool ChartForegroundSet(const bool value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property value
   if(!ChartSetInteger(chart_ID,CHART_FOREGROUND,0,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+--------------------------------------------------------------------------+
//| The function enables/disables the mode of displaying a price chart with  |
//| a shift from the right border.                                           |
//+--------------------------------------------------------------------------+
bool ChartShiftSet(const bool value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property value
   if(!ChartSetInteger(chart_ID,CHART_SHIFT,0,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Set chart display type (candlesticks, bars or                    |
//| line).                                                           |
//+------------------------------------------------------------------+
bool ChartModeSet(const long value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property value
   if(!ChartSetInteger(chart_ID,CHART_MODE,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Whroeder PauseTest                                               |
//+------------------------------------------------------------------+
// https://forum.mql4.com/35112 */
//#include<WinUser32.mqh>
#import "user32.dll"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int               GetAncestor(int,int);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void PauseTest()
//  {
//   datetime now=TimeCurrent();   static datetime oncePerTick;
//   if(IsTesting() && IsVisualMode() && IsDllsAllowed() && oncePerTick!=now)
//     {
//      oncePerTick=now;
//      for(int i=0; i<200000; i++)
//        {        // Delay required for speed=32 (max)
//         int main=GetAncestor(WindowHandle(Symbol(),Period()),2/*GA_ROOT*/);
//         if(i==0) PostMessageA(main,WM_COMMAND,0x57a,0); // 1402. Pause
//        }
//     }
//  }
//+------------------------------------------------------------------+
