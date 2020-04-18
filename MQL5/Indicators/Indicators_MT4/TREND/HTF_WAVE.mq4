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
#include <WaveLibrary.mqh>
//#property indicator_separate_window
#property indicator_chart_window
#property description" Find WAVE VOLUME on HTF according to "
#property description" ... PRICE,TIME,VOLUME,VOLUME/TIME, Price/TIME"
#property description" ... SHOW PERCENTILES"
#property indicator_buffers 4;

extern ENUM_TIMEFRAMES  eEnumHTFPeriod=PERIOD_CURRENT;//WTF
extern double           ewavePts=20;//0.5 points is 50 on SP500 / zero auto scale
extern bool             eShowData=false;
extern bool             eShowWave=false;
//+------------------------------------------------------------------+
//| Global variables Wave                                            |
//+------------------------------------------------------------------+
//-- *font*
int fontSize=10;
string fontType="mono";//"Times New Roman";//"Windings";

                       //-- *eInit*
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

//-- *eOnCalculate*
static bool hasInitialised=false;
//--- wave buffers
double ExtPriceClose[];
//double ExtPrice[];
double ExtVol[];
double ExtContUp[];
double ExtContDown[];
//-- Calculating the wave Prices
datetime endTime=NULL;
datetime oEndTime=NULL;
int endIndex=-1;
int oEndIndex=-1;
datetime anchorTime;
int anchorIndex;
double anchorPoints=-100;
string varTrail=NULL;
string pVarTrail=NULL;
//-- summing the waves
long cumVolume=0;
long deltaVolume=0;
double cumTime=0;
double deltaTime=0;
int state=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   stdText="AUX_NEW_WAVE "+string(ChartWindowFind())+" "+Symbol()+" "+string(eEnumHTFPeriod);
   dtickValue=MarketInfo(NULL,MODE_TICKSIZE);

   IndicatorBuffers(4);
   IndicatorDigits(Digits);

//if(eEnumHTFPeriod==PERIOD_CURRENT)
//{
//   htfIndex=findWTFIndex(ENUM_TIMEFRAMES(Period()),startEnum);
//}
//else
   htfIndex=findWTFIndex(eEnumHTFPeriod,startEnum);
   clrLine=TF_C_Colors[htfIndex];

   SetIndexBuffer(0,ExtVol);
   SetIndexLabel(0,"Wave Vol "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(0,DRAW_NONE,0,1,clrLine);

//SetIndexBuffer(1,ExtPrice);
//SetIndexLabel(1,"Wave Price");
//SetIndexEmptyValue(1,EMPTY_VALUE);
//SetIndexStyle(1,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(1,ExtPriceClose);
   SetIndexLabel(1,"Wave Price Close "+string(eEnumHTFPeriod));
   SetIndexEmptyValue(1,EMPTY_VALUE);
   if(eShowWave)
   SetIndexStyle(1,DRAW_SECTION,0,1,clrLine);
   else
     SetIndexStyle(1,DRAW_NONE,0,1,clrLine); 
//SetIndexArrow(1,160);   
//SetIndexStyle(1,DRAW_ARROW,1,9,clrLine);


   SetIndexBuffer(2,ExtContUp);
   SetIndexLabel(2,"Cont Up "+string(eEnumHTFPeriod));
   SetIndexArrow(2,233);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(3,ExtContDown);
   SetIndexLabel(3,"Cont Down "+string(eEnumHTFPeriod));
   SetIndexArrow(3,234);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_NONE,0,1,clrLine);

//SetIndexBuffer(5,ExtState);
//SetIndexLabel(5,"State "+string(eEnumHTFPeriod));
//SetIndexArrow(5,160);
//SetIndexEmptyValue(5,EMPTY_VALUE);
//SetIndexStyle(,DRAW_ARROW,5,1,clrLine);   

//-- Set Wave Height for continuation and reversal
   if(ewavePts==0)//then auto set from array
     {
      int thisTF=eEnumHTFPeriod;
      for(int i=0; i<ArraySize(tfEnumFull);i++)
         if(thisTF==tfEnumFull[i])
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
//ArraySetAsSeries(ExtPrice,true);
   ArraySetAsSeries(ExtVol,true);
   ArraySetAsSeries(ExtContUp,true);
   ArraySetAsSeries(ExtContDown,true);
   ArraySetAsSeries(tick_volume,true);
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
      if(isNewBar && (htfShift!=-1) && (shift+1!=-1))
        {
         if(htfShift==phtfShift)
           {
            ExtContDown[shift+1]=ExtContDown[shift+2];
            ExtContUp[shift+1]=ExtContUp[shift+2];
            cumVolume+=tick_volume[shift+1];
            deltaVolume+=tick_volume[shift+1];
            continue;
           }
         endTime=time[shift+1];
         newBar(shift+1,time,close,high,low,rates_total,tick_volume,eShowData);
        }//newBar
     }//for
   return (rates_total);
  }
//+-------------------------------------------------------------------+
//| newbar                                                            |
//+-------------------------------------------------------------------+ 
void newBar(int pShift,const datetime &T[],const double &C[],const double &H[],const double &L[],int Rates_Total,const long &Tick_Volume[],bool showData)
  {
   if(hasInitialised)
     {
      anchorPoints=-100; datetime tAnchorTime=NULL; int tAnchorIndex=-1;
      pVarTrail=varTrail;
      if(convertPoints(pShift,"UP",C,anchorPoints,tAnchorTime,tAnchorIndex))
        {//*UP                     
         if(varTrail=="UP")
           {
            ExtPriceClose[oEndIndex]=EMPTY_VALUE;
            //ExtPrice[oEndIndex]=EMPTY_VALUE;
            ExtVol[oEndIndex]=EMPTY_VALUE;

            ExtPriceClose[endIndex]=C[endIndex];
            ExtContUp[endIndex]=L[endIndex];
            cumVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(cumVolume);
            deltaVolume=0;

            setText(oEndTime,endTime,ExtPriceClose[endIndex],ExtVol[endIndex],clrLine,showData);
            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            //     printMe("1_UP",pShift,varTrail,oEndTime,oEndIndex,endTime,endIndex,anchorIndex,anchorTime);
           }
         else if(varTrail=="DOWN")
           {
            varTrail="UP";

            anchorTime=tAnchorTime;
            anchorIndex=tAnchorIndex;

            ExtPriceClose[endIndex]=C[endIndex];
            //ExtContUp[endIndex]=L[endIndex];
            deltaVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(deltaVolume);
            cumVolume=deltaVolume;
            deltaVolume=0;

            setText(NULL,endTime,ExtPriceClose[endIndex],ExtVol[endIndex],clrLine,showData);
            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            ExtContDown[shift+1]=ExtContDown[shift+2];
            ExtContUp[shift+1]=ExtContUp[shift+2];              
            //      printMe("2_UP",pShift,varTrail,oEndTime,oEndIndex,endTime,endIndex,anchorIndex,anchorTime);
           }
        }
      else if(convertPoints(pShift,"DOWN",C,anchorPoints,tAnchorTime,tAnchorIndex))
        {
         if(varTrail=="DOWN")
           {
            ExtPriceClose[oEndIndex]=EMPTY_VALUE;
            //ExtPrice[oEndIndex]=EMPTY_VALUE;
            ExtVol[oEndIndex]=EMPTY_VALUE;

            ExtPriceClose[endIndex]=C[endIndex];
            ExtContDown[endIndex]=H[endIndex];
            cumVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(cumVolume);
            deltaVolume=0;

            setText(oEndTime,endTime,ExtPriceClose[endIndex],-1*ExtVol[endIndex],clrLine,showData);
            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            //      printMe("3_DOWN",pShift,varTrail,oEndTime,oEndIndex,endTime,endIndex,anchorIndex,anchorTime);
           }
         else if(varTrail=="UP")
           {

            anchorTime=tAnchorTime;
            anchorIndex=tAnchorIndex;

            varTrail="DOWN";
            ExtPriceClose[endIndex]=C[endIndex];
            //ExtContDown[endIndex]=H[endIndex];
            deltaVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(deltaVolume);

            cumVolume=deltaVolume;
            deltaVolume=0;

            setText(NULL,endTime,ExtPriceClose[endIndex],-1*ExtVol[endIndex],clrLine,showData);
            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            //        printMe("4_DOWN",pShift,varTrail,oEndTime,oEndIndex,endTime,endIndex,anchorIndex,anchorTime);
           }
        }
      else
        {
         cumVolume+=Tick_Volume[pShift];
         deltaVolume+=Tick_Volume[pShift];
            ExtContDown[shift+1]=ExtContDown[shift+2];
            ExtContUp[shift+1]=ExtContUp[shift+2];         
        }
     }//initialised  
   if(!hasInitialised)
     {
      double points=-100;
      oEndTime=T[Rates_Total-2];
      anchorTime=T[Rates_Total-2];
      anchorIndex=iBarShift(Symbol(),Period(),anchorTime,true);
      oEndIndex=iBarShift(Symbol(),Period(),oEndTime,true);
      endIndex=iBarShift(Symbol(),Period(),endTime,false);
      //   ExtPriceClose[oEndIndex]=C[oEndIndex];
      if(pShift+1>Rates_Total-3)
         return;
      if(convertPoints(pShift,"UP",C,points,anchorTime,anchorIndex))
        {//*UP   
         oEndTime=endTime;
         oEndIndex=iBarShift(Symbol(),Period(),oEndTime,false);
         endIndex=iBarShift(Symbol(),Period(),endTime,false);
         varTrail="UP"; hasInitialised=true;
         return;
        }
      else if(convertPoints(pShift,"DOWN",C,points,anchorTime,anchorIndex))
        {
         oEndTime=endTime;
         oEndIndex=iBarShift(Symbol(),Period(),oEndTime,false);
         endIndex=iBarShift(Symbol(),Period(),endTime,false);
         varTrail="DOWN"; hasInitialised=true;
         return;
        }
     }//end hasInitialised      
  }
//+------------------------------------------------------------------+
//| convPoints                                                       |
//+------------------------------------------------------------------+
bool convertPoints(int pShift,string UD,const double &Cl[],double &anchorDiff,datetime &tAnchorTime,int &tAnchorIndex)
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
      diff=Cl[oEndIndex]-Cl[pShift];
      anchorDiff=Cl[tAnchorIndex]-Cl[pShift];
     }
   else if(UD=="UP")
     {
      diff=Cl[pShift]-Cl[oEndIndex];
      anchorDiff=Cl[pShift]-Cl[tAnchorIndex];
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
   if(!eShowData)
      return;
   fontSize=10;
   fontType="mono";

   data=string(MathAbs(volVector));

   string sOldTime = stdText+string(oldTime);
   string sNewTime = stdText+string(newTime);

//   if(oldTime!=NULL && ObjectDelete(ChartID(),sOldTime))
//     {
//
//      // Print("Deleted OldTime: "+sOldTime);
//     }
//Should be YVal o or high depending on =/-
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
