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
#include <ROB_CLASS_FILES\trendVessel.mqh>
#include <WaveLibrary.mqh>
#property indicator_chart_window
#property description" Find WAVE VOLUME on HTF according to "
#property description" ... PRICE,TIME,VOLUME,VOLUME/TIME, Price/TIME"
#property description" ... SHOW PERCENTILES"
#property indicator_buffers 8;

extern ENUM_TIMEFRAMES  waveHTFPeriod=PERIOD_H1;//HHTF shown
extern int ewavePts=-1;///-1: ATR, 0: array, other: set value; in Pts
extern double percentPullBack=25;//Percentage wave pullback retrace
extern double atrMultiplier=1.5;
extern bool             eShowVolumesData=true;//show Volume Data
extern bool             eShowTrendData=false;//show Trend Data
extern bool             eShowTrendWave=true;//show Trend Wave
extern bool             eShowInterwaveArrow=true;//show intermediate advances
extern bool             eShowMinMax=false;//Show Min Max
#define checkDirectionUp "UP"
#define checkDirectionDown "DOWN"
#define continuationUp "CU"
#define continuationDown "CD"
#define reversalUp "RU"
#define reversalDown "RD"
//+------------------------------------------------------------------+
//| Global variables Wave                                            |
//+------------------------------------------------------------------+
//-- *font*
int fontSize=8;
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
double digits = -1;
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
double ExtTrendPrice[];
double ExtTrend[];
double ExtMax[];
double ExtMin[];
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
bool hasInitialised=false;
int trendDirection=0;//Buy
trendList *tList=NULL;
trendElement *ele=NULL;
double onePoint=NULL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
// onePoint=MarketInfo(instrument,MODE_POINT);
   digits=MarketInfo(instrument,MODE_DIGITS);
   if(waveHTFPeriod==PERIOD_CURRENT)
      waveHTFPeriod=ENUM_TIMEFRAMES(Period());

   tList=new trendList(4,Symbol(),waveHTFPeriod,percentPullBack,atrMultiplier);

   for(int i=0; i<=tList.Total()-1; i++)
     {
      ele=tList.GetNodeAtIndex(i);
      ele.setDateVal(EMPTY_VALUE,EMPTY_VALUE);
     }
   stdText="AUX_NEW_WAVE "+string(ChartWindowFind())+" "+Symbol()+" "+string(waveHTFPeriod);
   dtickValue=MarketInfo(NULL,MODE_TICKSIZE);

   IndicatorBuffers(8);
   IndicatorDigits(int(digits));

   htfIndex=findWTFIndex(waveHTFPeriod,startEnum);
   clrLine=TF_C_Colors[htfIndex];

   SetIndexBuffer(0,ExtVol);
   SetIndexLabel(0,"Wave Vol "+string(waveHTFPeriod));
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(0,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(1,ExtPriceClose);
   SetIndexLabel(1,"Wave Price Close "+string(waveHTFPeriod));
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_NONE,0,1,clrLine);

   SetIndexBuffer(2,ExtContUp);
   SetIndexLabel(2,"Cont Up "+string(waveHTFPeriod));
   SetIndexArrow(2,217);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   if(eShowInterwaveArrow)
      SetIndexStyle(2,DRAW_ARROW,0,0,clrLine);
   else
      SetIndexStyle(2,DRAW_NONE,0,0,clrLine);

   SetIndexBuffer(3,ExtContDown);
   SetIndexLabel(3,"Cont Down "+string(waveHTFPeriod));
   SetIndexArrow(3,218);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   if(eShowInterwaveArrow)
      SetIndexStyle(3,DRAW_ARROW,0,0,clrLine);
   else
      SetIndexStyle(3,DRAW_NONE,0,0,clrLine);

   SetIndexBuffer(4,ExtTrendPrice);
   SetIndexLabel(4,"TREND "+string(waveHTFPeriod));
   SetIndexEmptyValue(4,EMPTY_VALUE);
   if(eShowTrendWave)
      SetIndexStyle(4,DRAW_SECTION,0,0,clrLine);
   else
      SetIndexStyle(4,DRAW_NONE,0,0,clrLine);

   SetIndexBuffer(5,ExtMax);
   SetIndexArrow(5,166);
   SetIndexLabel(5,"Wave Max "+string(waveHTFPeriod));
   SetIndexEmptyValue(5,EMPTY_VALUE);
   if(eShowMinMax)
      SetIndexStyle(5,DRAW_ARROW,0,0,clrLine);
   else
      SetIndexStyle(5,DRAW_NONE,0,0,clrLine);

   SetIndexBuffer(6,ExtMin);
   SetIndexArrow(6,164);
   SetIndexLabel(6,"Wave Min "+string(waveHTFPeriod));
   SetIndexEmptyValue(6,EMPTY_VALUE);
   if(eShowMinMax)
      SetIndexStyle(6,DRAW_ARROW,0,0,clrLine);
   else
      SetIndexStyle(6,DRAW_NONE,0,0,clrLine);

   SetIndexBuffer(7,ExtTrend);
   SetIndexLabel(7,"TREND "+string(waveHTFPeriod));
   SetIndexEmptyValue(7,EMPTY_VALUE);
   SetIndexStyle(7,DRAW_NONE,0,0,clrNONE);

//-- Set Wave Height for continuation and reversal
   if(ewavePts==-1)//then auto set from 100 bars of atr
     {
      double range=100;
      double numBars=Bars(Symbol(),waveHTFPeriod);
      if(numBars<100)
         range=numBars;
      double atr=iATR(Symbol(),waveHTFPeriod,100,0);
      waveHeightPts=atr/MarketInfo(Symbol(),MODE_POINT);
     }
   else if(ewavePts==0)//then auto set from array
     {
      for(int i=0; i<ArraySize(tfEnumFull);i++)
         if(waveHTFPeriod==tfEnumFull[i] || (PERIOD_CURRENT==tfEnumFull[i]))
           {
            waveHeightPts=waveHeightsPts[i];
            break;
           }
     }
   else
      waveHeightPts=ewavePts;

   //ChartForegroundSet(false,ChartID());
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
   ArraySetAsSeries(ExtTrendPrice,true);
   ArraySetAsSeries(ExtMax,true);
   ArraySetAsSeries(ExtMin,true);
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
      if(isNewBar)
        {
         if(shift>rates_total-3)
            continue;
         tList.maxBar=MathMax(high[shift+1],tList.maxBar);
         tList.minBar=MathMin(low[shift+1],tList.minBar);
         ExtMax[shift+1]=tList.maxBar;
         ExtMin[shift+1]=tList.minBar;
         //ExtTrend[shift+1]=tList.checkTrend(tList.maxBar,tList.minBar);
         htfShift=iBarShift(instrument,waveHTFPeriod,time[shift],true);
         phtfShift=iBarShift(instrument,waveHTFPeriod,time[shift+1],true);
         if((htfShift!=-1) && (shift+1!=-1))
           {
            if(htfShift==phtfShift)
              {
               ExtContDown[shift+1]=ExtContDown[shift+2];
               ExtContUp[shift+1]=ExtContUp[shift+2];
               ExtTrend[shift+1]=ExtTrend[shift+2];
               cumVolume+=tick_volume[shift+1];
               deltaVolume+=tick_volume[shift+1];
               continue;
              }
            endTime=time[shift+1];
            //     if(shift < 50)
            //       Print("time[htfShift] ",time[shift], " shift ",shift," htfShift ",htfShift, "waveHTFPeriod ",waveHTFPeriod);
            newBar(shift+1,time,close,high,low,rates_total,tick_volume,eShowVolumesData);

           }//htfShift and shift check
         //   tList.ToLog("test: ",true);
        }//for
     }//newBar
   return (rates_total);
  }
//+-------------------------------------------------------------------+
//| newbar                                                            |
//+-------------------------------------------------------------------+ 
void newBar(int pShift,const datetime &T[],const double &C[],const double &H[],const double &L[],int Rates_Total,const long &Tick_Volume[],bool showData)
  {
   anchorPoints=-100; datetime tAnchorTime=NULL; int tAnchorIndex=-1;
   pVarTrail=varTrail;
   isDate(pShift,0,19,4,6,2018);
//   isDate(pShift,45,8,9,1,2019);
   if(hasInitialised)
     {
      if(convertPoints(pShift,checkDirectionUp,H,L,T,anchorPoints,tAnchorTime,tAnchorIndex))
        {
         if(varTrail=="UP")
           {
            //continuation to the up side
            ExtPriceClose[oEndIndex]=EMPTY_VALUE;
            ExtVol[oEndIndex]=EMPTY_VALUE;
            ExtTrendPrice[oEndIndex]=EMPTY_VALUE;
            ExtPriceClose[endIndex]=C[endIndex];
            cumVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(cumVolume);
            deltaVolume=0;

            update(T[endIndex],tList.maxBar);
            setTrend(continuationUp);
       //     tList.isCrediblePullBack(continuationUp,phtfShift);
            ExtTrend[endIndex]=trend;
            ExtTrendPrice[endIndex]=ExtMax[endIndex];

            ExtContUp[endIndex]=tList.maxBar;
            ExtContDown[shift+1]=EMPTY_VALUE;

            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);

            setWaveStatus(oEndTime,endTime,"UP",H[endIndex],L[endIndex],ExtTrendPrice[endIndex],tList,clrLine,ExtVol[endIndex]);
            //else if(eShowVolumesData)
            //   setVolumeText(oEndTime,endTime,"UP",H[endIndex],L[endIndex],ExtVol[endIndex],clrLine,showData);
            tList.maxBar=0;
            tList.minBar= INF;
           }
         else if(varTrail=="DOWN")
           {
            // reversal to the up side
            varTrail="UP";
            anchorTime=tAnchorTime;
            anchorIndex=tAnchorIndex;
            ExtPriceClose[endIndex]=C[endIndex];
            deltaVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(deltaVolume);
            cumVolume=deltaVolume;
            deltaVolume=0;

            cycle(T[endIndex],tList.maxBar);
            setTrend(reversalUp);
       //     tList.isCrediblePullBack(reversalUp,phtfShift);
            ExtTrend[endIndex]=trend;

            ExtTrendPrice[endIndex]=ExtMax[endIndex];

            ExtContUp[shift+1]=EMPTY_VALUE;
            ExtContDown[shift+1]=EMPTY_VALUE;

            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            setWaveStatus(oEndTime,endTime,"UP",H[endIndex],L[endIndex],ExtTrendPrice[endIndex],tList,clrLine,ExtVol[endIndex]);
            //else if(eShowVolumesData)
            //   setVolumeText(oEndTime,endTime,"UP",H[endIndex],L[endIndex],ExtVol[endIndex],clrLine,showData);
            tList.maxBar=0;
            tList.minBar= INF;
           }
        }
      else if(convertPoints(pShift,checkDirectionDown,H,L,T,anchorPoints,tAnchorTime,tAnchorIndex))
        {
         if(varTrail=="DOWN")
           {
            //continuation to the down side
            ExtPriceClose[oEndIndex]=EMPTY_VALUE;
            ExtVol[oEndIndex]=EMPTY_VALUE;
            ExtTrendPrice[oEndIndex]=EMPTY_VALUE;
            ExtPriceClose[endIndex]=C[endIndex];
            cumVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(cumVolume);
            deltaVolume=0;

            tList.update(T[endIndex],tList.minBar);
            tList.setTrend(continuationDown);
           // tList.isCrediblePullBack(continuationDown,phtfShift);
            ExtTrend[endIndex]=trend;
            ExtTrendPrice[endIndex]=ExtMin[endIndex];

            ExtContUp[shift+1]=EMPTY_VALUE;
            ExtContDown[endIndex]=tList.minBar;

            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            setWaveStatus(oEndTime,endTime,"DOWN",H[endIndex],L[endIndex],ExtTrendPrice[endIndex],tList,clrLine,ExtVol[endIndex]);
            //else if(eShowVolumesData)
            //   setVolumeText(oEndTime,endTime,"DOWN",H[endIndex],L[endIndex],ExtVol[endIndex],clrLine,showData);
            tList.maxBar=0;
            tList.minBar= INF;
           }
         else if(varTrail=="UP")
           {
            //reversal to the down side
            varTrail="DOWN";
            anchorTime=tAnchorTime;
            anchorIndex=tAnchorIndex;
            ExtPriceClose[endIndex]=C[endIndex];
            deltaVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(deltaVolume);
            cumVolume=deltaVolume;
            deltaVolume=0;

            tList.cycle(T[endIndex],tList.minBar);
            tList.setTrend(reversalDown);
           // tList.isCrediblePullBack(reversalDown,phtfShift);
            ExtTrend[endIndex]=trend;
            ExtTrendPrice[endIndex]=ExtMin[endIndex];

            ExtContUp[shift+1]=EMPTY_VALUE;
            ExtContDown[shift+1]=EMPTY_VALUE;

            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            setWaveStatus(oEndTime,endTime,"DOWN",H[endIndex],L[endIndex],ExtTrendPrice[endIndex],tList,clrLine,ExtVol[endIndex]);
            //else if(eShowVolumesData)
            //   setVolumeText(oEndTime,endTime,"DOWN",H[endIndex],L[endIndex],ExtVol[endIndex],clrLine,showData);
            tList.maxBar=0;
            tList.minBar= INF;
           }
        }
      else
        {
         cumVolume+=Tick_Volume[pShift];
         deltaVolume+=Tick_Volume[pShift];
         ExtVol[shift+1]=double(cumVolume);
         ExtContDown[shift+1]=ExtContDown[shift+2];
         ExtContUp[shift+1]=ExtContUp[shift+2];
         ExtTrend[shift+1]=ExtTrend[shift+2];
        }
     }
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
      if(convertPoints(pShift,"UP",H,L,T,anchorPoints,tAnchorTime,tAnchorIndex))
        {//*UP   
         oEndTime=endTime;
         oEndIndex=iBarShift(Symbol(),Period(),oEndTime,false);
         endIndex=iBarShift(Symbol(),Period(),endTime,false);
         varTrail="UP";
         hasInitialised=true;
         return;
        }
      else if(convertPoints(pShift,"DOWN",H,L,T,anchorPoints,tAnchorTime,tAnchorIndex))
        {
         oEndTime=endTime;
         oEndIndex=iBarShift(Symbol(),Period(),oEndTime,false);
         endIndex=iBarShift(Symbol(),Period(),endTime,false);
         varTrail="DOWN";
         hasInitialised=true;
         return;
        }
     }//end hasInitialised           
  }
//+------------------------------------------------------------------+
//| convPoints                                                       |
//+------------------------------------------------------------------+
bool convertPoints(int pShift,string checkIfMovedUD,const double &H1[],const double &L1[],const datetime &T[],double &anchorDiff,datetime &tAnchorTime,int &tAnchorIndex)
  {
   oEndIndex=iBarShift(instrument,Period(),oEndTime,false);
   endIndex=iBarShift(instrument,Period(),endTime,false);
   tAnchorTime=NULL;
   tAnchorIndex=-1;
//Check if need to update anchor
   if(checkIfMovedUD!=varTrail)
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
   if((checkIfMovedUD=="DOWN") && (varTrail=="UP"))
     {
      diff=ExtMax[oEndIndex]-ExtMin[pShift];
      anchorDiff=ExtMax[tAnchorIndex]-ExtMin[pShift];
     }
   else if((checkIfMovedUD=="DOWN") && (varTrail=="DOWN"))
     {
      diff=ExtMin[oEndIndex]-ExtMin[pShift];
      anchorDiff=ExtMin[tAnchorIndex]-ExtMin[pShift];
     }
   else if((checkIfMovedUD=="UP") && (varTrail=="UP"))
     {
      diff=ExtMax[pShift]-ExtMax[oEndIndex];
      anchorDiff=ExtMax[pShift]-ExtMax[tAnchorIndex];
     }
   else if((checkIfMovedUD=="UP") && (varTrail=="DOWN"))
     {
      diff=ExtMax[pShift]-ExtMin[oEndIndex];
      anchorDiff=ExtMax[pShift]-ExtMin[tAnchorIndex];
     }
   anchorDiff=anchorDiff/dtickValue;
   anchorDiff=ND(anchorDiff,int(digits));
   diff=diff/dtickValue;
   double pts=NormalizeDouble(diff,int(digits));
   if(pts>=waveHeightPts)
      return true;
   return false;
   Print(waveHeightPts," ",diff);
  }
//-------------------------------------------------------------------+
//| setWaveStatus                                                    |
//+------------------------------------------------------------------+  
void setWaveStatus(datetime oldTime,datetime newTime,string direction,double H,double L,double Tr,trendList &p,color indexColor,double waveVolume)
  {
   string data=NULL;
   if(!eShowVolumesData && !eShowTrendData)
      return;
   string sOldTime= stdText+string(oldTime);
   string sNewTime=stdText+string(newTime);
   double wavePrice=Tr;
//if(oldTime!=NULL && ObjectDelete(ChartID(),sOldTime))
//  {
//   // Print("Deleted OldTime: "+sOldTime);
//  }
   ObjectCreate(ChartID(),sNewTime,OBJ_TEXT,ChartWindowFind(),newTime,wavePrice);
   ObjectSetInteger(ChartID(),sNewTime,OBJPROP_BACK,false);
   trendElement *element=p.GetLastNode();
   string tg=tag(element.waveProperty,element.waveStatus);
   if(eShowVolumesData && eShowTrendData && (tg != NULL))
      ObjectSetText(sNewTime,"("+tg+")_("+DoubleToStr(waveVolume,0)+")",fontSize,fontType,indexColor);
   if(eShowVolumesData && eShowTrendData  && (tg == NULL))
      ObjectSetText(sNewTime,"("+DoubleToStr(waveVolume,0)+")",fontSize,fontType,indexColor);      
   else if (eShowVolumesData && eShowTrendData  )
      ObjectSetText(sNewTime,"("+DoubleToStr(waveVolume,0)+")",fontSize,fontType,indexColor);   
   else if(eShowTrendData && !eShowVolumesData)
      ObjectSetText(sNewTime,tg,fontSize,fontType,indexColor);   
   else if(eShowVolumesData && !eShowTrendData)
         ObjectSetText(sNewTime,"("+DoubleToStr(waveVolume,0)+")",fontSize,fontType,indexColor);   
   ChartRedraw();
  }
//-------------------------------------------------------------------+
//| colorDisplayed                                                   |
//+------------------------------------------------------------------+  
string tag(string wp,string ws)
  {
   string s=NULL;
   if(ws=="B" && (wp=="RD" || wp=="CD"))
     {
      s=wp+"_("+ws+")";
      return "*_"+s;
     }
   else if(ws=="S" && (wp=="RU" ||(wp=="CU")))
     {
      s=wp+"_("+ws+")";
      return "*_"+s;
     }
   return s;
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//tList.ToLog("trend ",true);
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
