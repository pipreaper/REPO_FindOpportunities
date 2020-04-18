//+------------------------------------------------------------------+
//|                                                  WeisWave v6.mq4 |
//|                                    Copyright 2014 Robert Baptie. |
//|                               http://rgb-web-developer.comli.com |
//+------------------------------------------------------------------+
#property copyright   "2018 Robert Baptie"
#property link        ""
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <trendVessel.mqh>
#include <WaveLibrary.mqh>
//#property indicator_separate_window
#property indicator_chart_window
#property description" Find WAVE VOLUME on HTF according to "
#property description" ... PRICE,TIME,VOLUME,VOLUME/TIME, Price/TIME"
#property description" ... SHOW PERCENTILES"
#property indicator_buffers 5;

extern ENUM_TIMEFRAMES  eEnumHTFPeriod=PERIOD_CURRENT;//WTF
extern double           ewavePts=0;//0.5 points is 50 on SP500 / zero auto scale
extern bool             eShowVolumes=false;//show volume data
extern bool             eShowWave=true;//show wave
extern bool             eShowArrows=false;//show arrows
//+------------------------------------------------------------------+
//| Global variables Wave                                            |
//+------------------------------------------------------------------+
//-- *font*
int fontSize=10;
string fontType="mono";//"Times New Roman";//"Windings";
                       //OnInit
string shortName=NULL;
int htfIndex=NULL;
string instrument=Symbol();
ENUM_TIMEFRAMES startEnum=NULL;
int shift=NULL;
int limit= NULL;
color clrLine=clrNONE;
static int htfShift=-1;
static int phtfShift=-1;
string stdText=NULL;
//-- wave setup
double waveHeightPts=-1;
int waveHeightsPts[9]={20,50,70,90,110,150,200,400,500};//#bars per time frame
double dtickValue=-1;
//OnCalculate
//--- wave buffers
double ExtPriceClose[];
//double ExtPrice[];
double ExtVol[];
double ExtContUp[];
double ExtContDown[];
double ExtTrend[];
//-- Calculating the wave Prices
datetime endTime=NULL;
datetime oEndTime=NULL;
int endIndex=-1;
int oEndIndex=-1;
datetime anchorTime;
int anchorIndex;
double anchorPoints=-100;
string varTrail="DOWN";
string pVarTrail=NULL;
//-- summing the waves
long cumVolume=0;
long deltaVolume=0;
double cumTime=0;
double deltaTime=0;
int state=0;
//TREND
double maxBar=0;
double minBar = INF;
int trendDirection=0;//Buy
trendList *tList=NULL;
trendElement *ele=NULL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   tList=new trendList(5);

   for(int i=0; i<=tList.Total()-1; i++)
     {
      ele=tList.GetNodeAtIndex(i);
      ele.setDateVal(EMPTY_VALUE,EMPTY_VALUE);
     }
   stdText="AUX_NEW_WAVE "+string(ChartWindowFind())+" "+Symbol()+" "+string(eEnumHTFPeriod);
   dtickValue=MarketInfo(NULL,MODE_TICKSIZE);

   IndicatorBuffers(5);
   IndicatorDigits(Digits);

   htfIndex=findWTFIndex(eEnumHTFPeriod,startEnum);
   clrLine=TF_C_Colors[htfIndex];

   SetIndexBuffer(0,ExtVol);
   SetIndexLabel(0,"Wave Vol "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(0,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(1,ExtPriceClose);
   SetIndexLabel(1,"Wave Price Close "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(2,ExtContUp);
   SetIndexLabel(2,"Cont Up "+string(eEnumHTFPeriod));
   SetIndexArrow(2,233);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   if(eShowArrows)
      SetIndexStyle(2,DRAW_ARROW,0,1,clrLine);
   else
      SetIndexStyle(2,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(3,ExtContDown);
   SetIndexLabel(3,"Cont Down "+string(eEnumHTFPeriod));
   SetIndexArrow(3,234);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   if(eShowArrows)
      SetIndexStyle(3,DRAW_ARROW,0,1,clrLine);
   else
      SetIndexStyle(3,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(4,ExtTrend);
   SetIndexLabel(4,"TREND "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(4,EMPTY_VALUE);
   if(eShowWave)
      SetIndexStyle(4,DRAW_SECTION,0,1,clrLine);
   else
      SetIndexStyle(4,DRAW_NONE,0,1,clrLine);

//-- Set Wave Height for continuation and reversal
   if(ewavePts==0)//then auto set from array
     {
      for(int i=0; i<ArraySize(tfEnumFull);i++)
         if(eEnumHTFPeriod==tfEnumFull[i])
           {
            waveHeightPts=waveHeightsPts[i];
            break;
           }
     }
   else
      waveHeightPts=ewavePts;

   ChartForegroundSet(false,ChartID());
   shortName=stdText+" H: "+string(waveHeightPts);
   IndicatorShortName(shortName);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| On Calculate                                                     |
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
//---INITIALISE ARRAYS
   ArraySetAsSeries(ExtPriceClose,true);
   ArraySetAsSeries(ExtVol,true);
   ArraySetAsSeries(ExtContUp,true);
   ArraySetAsSeries(ExtContDown,true);
   ArraySetAsSeries(ExtTrend,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   double buffer=-1;

   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   limit=rates_total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit;
   for(shift=limit-1; shift>=0; shift--)
     {
      if(shift>rates_total-3)
         continue;
      htfShift=iBarShift(instrument,eEnumHTFPeriod,time[shift],false);
      phtfShift=iBarShift(instrument,eEnumHTFPeriod,time[shift+1],false);
      if(isNewBar && (htfShift != -1) && (shift+1 != -1))
        {
         if(htfShift==phtfShift)
           {
            ExtContDown[shift+1]=ExtContDown[shift+2];
            ExtContUp[shift+1]=ExtContUp[shift+2];
            cumVolume+=tick_volume[shift+1];
            deltaVolume+=tick_volume[shift+1];
            maxBar = MathMax(high[shift+1],maxBar);
            minBar = MathMin(low[shift+1],minBar);
            continue;
           }
         endTime=time[shift+1];
         newBar(shift+1,time,close,high,low,rates_total,tick_volume,eShowVolumes);
         maxBar=0;
         minBar = INF;         
        }//newBar
     }//for
   return (rates_total);
  }
//+-------------------------------------------------------------------+
//| newbar                                                            |
//+-------------------------------------------------------------------+ 
void newBar(int pShift,const datetime &T[],const double &C[],const double &H[],const double &L[],int Rates_Total,const long &Tick_Volume[],bool showData)
  {
   anchorPoints=-100; datetime tAnchorTime=NULL; int tAnchorIndex=-1;
   pVarTrail=varTrail;
   if(convertPoints(pShift,"UP",H,L,anchorPoints,tAnchorTime,tAnchorIndex))
     {//*UP                     
      if(varTrail=="UP")
        {
         ExtPriceClose[oEndIndex]=EMPTY_VALUE;
         ExtVol[oEndIndex]=EMPTY_VALUE;
         ExtTrend[oEndIndex]=EMPTY_VALUE;
         ExtPriceClose[endIndex]=C[endIndex];
         ExtContUp[endIndex]=L[endIndex];
         cumVolume+=Tick_Volume[pShift];
         ExtVol[endIndex]=double(cumVolume);
         deltaVolume=0;
         
         maxBar = MathMax(H[endIndex],maxBar);        
         ExtTrend[endIndex]=maxBar;
         tList.update(T[endIndex],maxBar);
         oEndTime=endTime;
         oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
        }
      else if(varTrail=="DOWN")
        {
         varTrail="UP";
         anchorTime=tAnchorTime;
         anchorIndex=tAnchorIndex;
         ExtPriceClose[endIndex]=C[endIndex];
         deltaVolume+=Tick_Volume[pShift];
         ExtVol[endIndex]=double(deltaVolume);
         cumVolume=deltaVolume;
         deltaVolume=0;
         
         maxBar = MathMax(H[endIndex],maxBar);
         tList.cycle(T[endIndex],maxBar);
         ExtTrend[endIndex]=maxBar;         
         
         oEndTime=endTime;
         oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
         ExtContDown[shift+1]=ExtContDown[shift+2];
         ExtContUp[shift+1]=ExtContUp[shift+2];
        }
     }
   else if(convertPoints(pShift,"DOWN",H,L,anchorPoints,tAnchorTime,tAnchorIndex))
     {
      if(varTrail=="DOWN")
        {
         ExtPriceClose[oEndIndex]=EMPTY_VALUE;
         ExtVol[oEndIndex]=EMPTY_VALUE;
         ExtTrend[oEndIndex]=EMPTY_VALUE;
         ExtPriceClose[endIndex]=C[endIndex];
         ExtContDown[endIndex]=H[endIndex];
         cumVolume+=Tick_Volume[pShift];
         ExtVol[endIndex]=double(cumVolume);
         deltaVolume=0;
         
         minBar = MathMin(L[endIndex],minBar);
         tList.update(T[endIndex],minBar);                
         ExtTrend[endIndex]=minBar;         

         oEndTime=endTime;
         oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
        }
      else if(varTrail=="UP")
        {
         varTrail="DOWN";
         anchorTime=tAnchorTime;
         anchorIndex=tAnchorIndex;
         ExtPriceClose[endIndex]=C[endIndex];
         deltaVolume+=Tick_Volume[pShift];
         ExtVol[endIndex]=double(deltaVolume);
         cumVolume=deltaVolume;
         deltaVolume=0;
         
         minBar = MathMin(L[endIndex],minBar);
         tList.cycle(T[endIndex],minBar);         
         ExtTrend[endIndex]=minBar;

         oEndTime=endTime;
         oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
         ExtContDown[shift+1]=ExtContDown[shift+2];
         ExtContUp[shift+1]=ExtContUp[shift+2];
        }
     }
   else
     {
      cumVolume+=Tick_Volume[pShift];
      deltaVolume+=Tick_Volume[pShift];
      ExtVol[shift+1]=double(cumVolume);
      ExtContDown[shift+1]=ExtContDown[shift+2];
      ExtContUp[shift+1]=ExtContUp[shift+2];
     }
   setText(oEndTime,endTime,ExtPriceClose[endIndex],-1*ExtVol[endIndex],clrLine,showData);
  }
//+------------------------------------------------------------------+
//| convPoints                                                       |
//+------------------------------------------------------------------+
bool convertPoints(int pShift,string UD,const double &H1[],const double &L1[],double &anchorDiff,datetime &tAnchorTime,int &tAnchorIndex)
  {
   oEndIndex=iBarShift(instrument,Period(),oEndTime,false);
   endIndex=iBarShift(instrument,Period(),endTime,false);
   tAnchorTime=NULL;
   tAnchorIndex=-1;
//Check if need to update anchor
   if(UD!=varTrail)
     {
      tAnchorTime=oEndTime;
      tAnchorIndex=iBarShift(instrument,Period(),tAnchorTime,false);
     }
   else
     {//further away in time at moment
      tAnchorTime=anchorTime;
      tAnchorIndex=iBarShift(instrument,Period(),tAnchorTime,false);
      //tAnchorIndex--;
     }
   double diff=-1;
   if(UD=="DOWN")
     {
      diff=L1[oEndIndex]-L1[pShift];
      anchorDiff=L1[tAnchorIndex]-L1[pShift];
     }
   else if(UD=="UP")
     {
      diff=H1[pShift]-H1[oEndIndex];
      anchorDiff=H1[pShift]-H1[tAnchorIndex];
     }
   anchorDiff=anchorDiff/dtickValue;
   anchorDiff=ND(anchorDiff,Digits);
   diff=diff/dtickValue;
   double pts=NormalizeDouble(diff,Digits);
   if(pts>=waveHeightPts)
      return true;
   return false;
  }
//-------------------------------------------------------------------+
//| setText                                                          |
//+------------------------------------------------------------------+  
void setText(datetime oldTime,datetime newTime,double wavePrice,double volVector,color indexColor,bool showDatap)
  {
   string data=NULL;
   if(!eShowVolumes)
      return;
   fontSize=10;
   fontType="mono";

   data=string(MathAbs(volVector));

   string sOldTime = stdText+string(oldTime);
   string sNewTime = stdText+string(newTime);
//   if(oldTime!=NULL && ObjectDelete(ChartID(),sOldTime))
//     {
//      // Print("Deleted OldTime: "+sOldTime);
//     }
   ObjectCreate(ChartID(),sNewTime,OBJ_TEXT,ChartWindowFind(),newTime,wavePrice);
   ObjectSetInteger(ChartID(),sNewTime,OBJPROP_BACK,false);
   ObjectSetText(sNewTime,data,fontSize,fontType,indexColor);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   tList.ToLog("trend ",true);
   delete(tList);
   int lVol=StringLen(stdText);
//   Print(" In OnDeInit: ",stdText," length stdText: ",lVol);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string objName=ObjectName(i);
      //  Print(objName);
      if(StringSubstr(objName,0,lVol)==stdText)
        {
         ObjectDelete(ObjectName(i));
         //     if(i<2)
         //   Print("deleted ",enumHTFPeriod," ",objName);
        }
     }
  }
//+------------------------------------------------------------------+

