//+------------------------------------------------------------------+
//|                                       HTF_ALL_VOL_PERCENTILE.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <WaveLibrary.mqh>
#include <percentiles.mqh>
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
double ExtPrice[];
double ExtVol[];
double ExtSumVol[];
double ExtValueBuffer[];
double ExtPercentBuffer[];
double ExtTime[];
double ExtVolumeByTime[];
double ExtPriceByTime[];
double ExtPinch[];
double ExtSignedDeltaVolume[];
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
percentilesClass *pc;
//+------------------------------------------------------------------+
//|eInit                                                             |
//+------------------------------------------------------------------+
void eInit(bool drawLines,volume_price vp,ENUM_TIMEFRAMES enumHTFPeriod,double wavePts,bool showData,double LOWER_PERCENTILE,double LOWER_MIDDLE_PERCENTILE,double MIDDLE_PERCENTILE,double UPPER_MIDDLE_PERCENTILE,double UPPER_PERCENTILE)
  {
   stdText="AUX_NEW_WAVE "+string(ChartWindowFind())+" "+Symbol()+" "+string(enumHTFPeriod);
   pc=new percentilesClass(Symbol(),Period(),drawLines,stdText,LOWER_PERCENTILE,LOWER_MIDDLE_PERCENTILE,MIDDLE_PERCENTILE,UPPER_MIDDLE_PERCENTILE,UPPER_PERCENTILE);
   if(vp==WAVE_PRICE)
      drawLines=false;
   dtickValue=MarketInfo(NULL,MODE_TICKSIZE);

   IndicatorBuffers(11);
   IndicatorDigits(Digits);

   htfIndex=findWTFIndex(enumHTFPeriod,startEnum);
   clrLine=TF_C_Colors[htfIndex];
   initBuffers(vp);

//-- Set Wave Height for continuation and reversal
   if(wavePts==0)//then auto set from array
     {
      int thisTF=enumHTFPeriod;
      for(int i=0; i<ArraySize(tfEnumFull);i++)
         if(thisTF==tfEnumFull[i])
           {
            waveHeightPts=waveHeightsPts[i];
            break;
           }
     }
   else
      waveHeightPts=wavePts;
//Print("WAVE POINTS NEEDED: ",waveHeightPts);
   ChartForegroundSet(false,ChartID());

   shortName=stdText+" H: "+string(waveHeightPts)+" "+text_volume_price[vp];
   IndicatorShortName(shortName);
   if(vp!=WAVE_PRICE)
      pc.initPercentileLines(); //draw and create line if drawlines set true
  }
//+------------------------------------------------------------------+
//|eOnCalculate                                                                  |
//+------------------------------------------------------------------+
void eOnCalculate(ENUM_TIMEFRAMES enumHTFPeriod,int Rates_Total,int prev_calculated,const long &tick_volume[],const double &high[],const double &low[],const double &close[],const datetime &time[],bool showData,volume_price vp)
  {
//---INITIALISE ARRAYS
   ArraySetAsSeries(ExtPriceClose,true);
   ArraySetAsSeries(ExtPrice,true);
   ArraySetAsSeries(ExtVol,true);
   ArraySetAsSeries(ExtSumVol,true);
   ArraySetAsSeries(ExtValueBuffer,true);
   ArraySetAsSeries(ExtPercentBuffer,true);
   ArraySetAsSeries(ExtTime,true);
   ArraySetAsSeries(ExtVolumeByTime,true);
   ArraySetAsSeries(ExtPriceByTime,true);
   ArraySetAsSeries(ExtPinch,true);
   ArraySetAsSeries(ExtSignedDeltaVolume,true);

   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   double buffer=-1;

   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];

   limit=Rates_Total-prev_calculated;
   if(prev_calculated<=0)
      limit=limit;
   for(shift=limit-1; shift>=0; shift--)//start Rates_Total down to zero
     {
      if(shift>Rates_Total-3)
         continue;
      htfShift=iBarShift(instrument,enumHTFPeriod,time[shift],false);
      //     Print(shift," RT: ", Rates_Total);
      phtfShift=iBarShift(instrument,enumHTFPeriod,time[shift+1],false);
      if(isNewBar && (htfShift!=-1) && (shift+1!=-1))
        {
         if(htfShift==phtfShift)
           {

            cumVolume+=tick_volume[shift+1];
            deltaVolume+=tick_volume[shift+1];
            //ExtSumVol[shift+1]=double(cumVolume); 
            // showWave(pVarTrail,varTrail); 

            cumTime+=1;
            deltaTime+=1;
            //Print("inside: ",time[shift+1]," cumulativeVolume: ",cumVolume," deltaVolume: ",deltaVolume);
            continue;
           }
         endTime=time[shift+1];
         //Print(shift+1);
         newBar(shift+1,time,close,Rates_Total,tick_volume,showData,vp);
         //setSumVol(pVarTrail,varTrail,Rates_Total);
         if(vp!=WAVE_PRICE)
           {
            pc.calcDisplayPercentileLines(ExtPercentBuffer,ExtValueBuffer);
            pc.moveLines();
           }
         //     Print(" shift+1: ",shift+1," ExValueBuffer[shift+1]: ", ExtValueBuffer[shift+1], " ExtPercentBuffer[shift+1]: ",ExtValueBuffer[shift+1]);
        }//newBar
      // ExtSumVol[shift+1]=double(cumVolume);         
      //       showWave(pVarTrail,varTrail); 
     }//for
//draw percentile Lines
//if(isNewBar && (vp!=WAVE_PRICE))
//  {
//   pc.calcDisplayPercentileLines(ExtPercentBuffer,ExtValueBuffer);
//   pc.moveLines();
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setSumVol(string PVARTRAIL,string VARTRAIL,int rt)
  {
//if((shift+1)<0) 
//return;
//
//            double a=double(cumVolume);
//            double b=cumTime;
//if(b==0) 
//return;    
//    ExtSumVol[shift+1] = a/b; 
//    ExtValueBuffer[shift+1]=a/b;       
//if((PVARTRAIL==VARTRAIL) && (VARTRAIL=="DOWN"))
//  {
//   //--DOWN
//   if(ExtSignedDeltaVolume[shift+1]<0)
//      ExtSumVol[shift+1] = -1*a/b;
//   else
//      ExtSumVol[shift+1] = a/b;
//  }
//if((PVARTRAIL==VARTRAIL) && (VARTRAIL=="UP"))
//   //DOWN
//  {
//   if(ExtSignedDeltaVolume[shift+1]<0)
//      ExtSumVol[shift+1]=-1*a/b;
//   else
//      ExtSumVol[shift+1]=a/b;
//  }
//if((PVARTRAIL!=VARTRAIL) && (VARTRAIL=="UP"))
//  {
//   //DOWN
//   if(ExtSignedDeltaVolume[shift+1]<0)
//      ExtSumVol[shift+1]=-1*a/b;
//   else
//      ExtSumVol[shift+1]=a/b;
//  }
//if((PVARTRAIL!=VARTRAIL) && (VARTRAIL=="DOWN"))
//  {
//   //DOWN
//   if(ExtSignedDeltaVolume[shift+1]<0)
//      ExtSumVol[shift+1] = -1*a/b;
//   else
//      ExtSumVol[shift+1]=a/b;
//  }
  }
//+-------------------------------------------------------------------+
//| newbar                                                            |
//+-------------------------------------------------------------------+ 
void newBar(int pShift,const datetime &T[],const double &C[],int Rates_Total,const long &Tick_Volume[],bool showData,volume_price vp)
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
            ExtPrice[oEndIndex]=EMPTY_VALUE;

            ExtVol[oEndIndex]=EMPTY_VALUE;
            ExtSignedDeltaVolume[oEndIndex]=EMPTY_VALUE;

            ExtTime[oEndIndex]=EMPTY_VALUE;
            ExtValueBuffer[oEndIndex]=EMPTY_VALUE;
            ExtPercentBuffer[oEndIndex]=EMPTY_VALUE;
            ExtPriceByTime[oEndIndex]=EMPTY_VALUE;
            ExtVolumeByTime[oEndIndex]=EMPTY_VALUE;
            ExtPinch[oEndIndex]=EMPTY_VALUE;

            ExtSumVol[oEndIndex]=EMPTY_VALUE;
            ExtPriceClose[endIndex]=C[endIndex];
            ExtPrice[endIndex]=anchorPoints;

            cumVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(cumVolume);
            ExtSignedDeltaVolume[endIndex]=ExtVol[endIndex];

            deltaVolume=0;

            cumTime+=1;
            ExtTime[endIndex]=cumTime;
            deltaTime=0;

            ExtVolumeByTime[endIndex]=ExtVol[endIndex]/ExtTime[endIndex];
            ExtPriceByTime[endIndex]=anchorPoints/ExtTime[endIndex];
            ExtPinch[endIndex]=ExtVolumeByTime[endIndex]/ExtPriceByTime[endIndex];

            ExtSumVol[endIndex]=ExtPinch[endIndex];
            selector(vp);

            setText(oEndTime,endTime,ExtPriceClose[endIndex],ExtPrice[endIndex],ExtVol[endIndex],ExtTime[endIndex],ExtPriceByTime[endIndex],ExtVolumeByTime[endIndex],C[pShift],clrLine,showData,vp);
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
            ExtPrice[endIndex]=anchorPoints;

            deltaVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(deltaVolume);
            ExtSignedDeltaVolume[endIndex]=ExtVol[endIndex];

            cumVolume=deltaVolume;

            deltaVolume=0;

            deltaTime+=1;
            ExtTime[endIndex]=deltaTime;
            cumTime=deltaTime;
            deltaTime=0;

            ExtVolumeByTime[endIndex]=ExtVol[endIndex]/ExtTime[endIndex];
            ExtPriceByTime[endIndex]=anchorPoints/ExtTime[endIndex];
            ExtPinch[endIndex]=ExtVolumeByTime[endIndex]/ExtPriceByTime[endIndex];
            ExtSumVol[endIndex]=ExtPinch[endIndex];
            selector(vp);

            setText(NULL,endTime,ExtPriceClose[endIndex],ExtPrice[endIndex],ExtVol[endIndex],ExtTime[endIndex],ExtPriceByTime[endIndex],ExtVolumeByTime[endIndex],C[pShift],clrLine,showData,vp);
            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            //      printMe("2_UP",pShift,varTrail,oEndTime,oEndIndex,endTime,endIndex,anchorIndex,anchorTime);
           }
        }
      else if(convertPoints(pShift,"DOWN",C,anchorPoints,tAnchorTime,tAnchorIndex))
        {
         if(varTrail=="DOWN")
           {
            ExtPriceClose[oEndIndex]=EMPTY_VALUE;
            ExtPrice[oEndIndex]=EMPTY_VALUE;

            ExtVol[oEndIndex]=EMPTY_VALUE;
            ExtSignedDeltaVolume[oEndIndex]=EMPTY_VALUE;

            ExtTime[oEndIndex]=EMPTY_VALUE;
            ExtValueBuffer[oEndIndex]=EMPTY_VALUE;
            ExtPercentBuffer[oEndIndex]=EMPTY_VALUE;
            ExtPriceByTime[oEndIndex]=EMPTY_VALUE;
            ExtVolumeByTime[oEndIndex]=EMPTY_VALUE;
            ExtPinch[oEndIndex]=EMPTY_VALUE;
            ExtSumVol[oEndIndex]=EMPTY_VALUE;
            ExtPriceClose[endIndex]=C[endIndex];
            ExtPrice[endIndex]=anchorPoints;

            cumVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(cumVolume);
            ExtSignedDeltaVolume[endIndex]=-1*ExtVol[endIndex];

            deltaVolume=0;

            cumTime+=1;
            ExtTime[endIndex]=cumTime;
            deltaTime=0;

            ExtVolumeByTime[endIndex]=ExtVol[endIndex]/ExtTime[endIndex];
            ExtPriceByTime[endIndex]=anchorPoints/ExtTime[endIndex];
            ExtPinch[endIndex]=ExtVolumeByTime[endIndex]/ExtPriceByTime[endIndex];
            ExtSumVol[endIndex]=ExtPinch[endIndex];
            selector(vp);

            setText(oEndTime,endTime,ExtPriceClose[endIndex],ExtPrice[endIndex],-1*ExtVol[endIndex],-1*ExtTime[endIndex],ExtPriceByTime[endIndex],ExtVolumeByTime[endIndex],C[pShift],clrLine,showData,vp);
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
            ExtPrice[endIndex]=anchorPoints;

            deltaVolume+=Tick_Volume[pShift];
            ExtVol[endIndex]=double(deltaVolume);
            ExtSignedDeltaVolume[endIndex]=-1*ExtVol[endIndex];

            cumVolume=deltaVolume;
            deltaVolume=0;

            deltaTime+=1;
            ExtTime[endIndex]=deltaTime;
            cumTime=deltaTime;

            deltaTime=0;

            ExtVolumeByTime[endIndex]=ExtVol[endIndex]/ExtTime[endIndex];
            ExtPriceByTime[endIndex]=anchorPoints/ExtTime[endIndex];
            ExtPinch[endIndex]=ExtVolumeByTime[endIndex]/ExtPriceByTime[endIndex];
            ExtSumVol[endIndex]=ExtPinch[endIndex];
            selector(vp);

            setText(NULL,endTime,ExtPriceClose[endIndex],ExtPrice[endIndex],-1*ExtVol[endIndex],-1*ExtTime[endIndex],ExtPriceByTime[endIndex],ExtVolumeByTime[endIndex],C[pShift],clrLine,showData,vp);
            oEndTime=endTime;
            oEndIndex=iBarShift(instrument,Period(),oEndTime,true);
            //        printMe("4_DOWN",pShift,varTrail,oEndTime,oEndIndex,endTime,endIndex,anchorIndex,anchorTime);
           }
        }
      else
        {
         cumVolume+=Tick_Volume[pShift];
         deltaVolume+=Tick_Volume[pShift];

         cumTime+=1;
         deltaTime+=1;
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
      ExtPriceClose[oEndIndex]=C[oEndIndex];
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

   if(endIndex==-1)
     {
      Print(endIndex);
     }

  }
//+------------------------------------------------------------------+
//| selector                                                         |
//+------------------------------------------------------------------+
void selector(volume_price vp)
  {
   if(vp==WAVE_PRICE)
      ExtValueBuffer[endIndex]=MathAbs(ExtPriceClose[endIndex]);
   if(vp==DELTA_PRICE)
      ExtValueBuffer[endIndex]=MathAbs(ExtPrice[endIndex]);
   else if(vp==DELTA_VOLUME)
      ExtValueBuffer[endIndex]=ExtVol[endIndex];
   else if(vp==DELTA_TIME)
      ExtValueBuffer[endIndex]=ExtTime[endIndex];
   else if(vp==DELTA_P_BY_T)
      ExtValueBuffer[endIndex]=ExtPriceByTime[endIndex];
   else if(vp==DELTA_V_BY_T)
      ExtValueBuffer[endIndex]=ExtVolumeByTime[endIndex];
   else if(vp==SPARE)
      ExtValueBuffer[endIndex]=ExtVolumeByTime[endIndex]/ExtPriceByTime[endIndex];
   else if(vp==PINCH)
      ExtValueBuffer[endIndex]=ExtVolumeByTime[endIndex]/ExtPriceByTime[endIndex];
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
void setText(datetime oldTime,datetime newTime,double wavePrice,double deltaPoints,double vol,double dTime,double pByT,double vByT,double YVal,color indexColor,bool showData,volume_price vp)
  {
   string data=NULL;
   if(!showData)
      return;
   fontSize=10;
   fontType="mono";

   if(vp==WAVE_PRICE)
     {
      data=string(MathAbs(vol));
      YVal=wavePrice;
     }
   if(vp==DELTA_PRICE)
     {
      data=string(deltaPoints);
      YVal=deltaPoints;
      if(deltaPoints<0)
        {
         YVal=YVal*-1;
         data="M_"+string(MathAbs(deltaPoints));
        }
     }
   else if(vp==DELTA_VOLUME)
     {
      data=string(vol);
      YVal=vol;
      if(vol<0)
        {
         YVal=YVal*-1;
         data="M_"+string(MathAbs(vol));
        }
     }
   else if(vp==DELTA_TIME)
     {
      data=string(dTime);
      YVal=dTime;
      if(dTime<0)
        {
         YVal=YVal*-1;
         data="M_"+string(MathAbs(dTime));
        }
     }
   else if(vp==DELTA_P_BY_T)
     {
      data=DoubleToStr(pByT,0);
      YVal=MathAbs(pByT);
      if(dTime<0)
         data="M_"+DoubleToStr(MathAbs(pByT),0);
     }
   else if(vp==DELTA_V_BY_T)
     {
      data=DoubleToStr(vByT,0);
      YVal=MathAbs(vByT);
      if(dTime<0)
         data="M_"+DoubleToStr(MathAbs(vByT),0);
     }
   else if(vp==SPARE)
     {
      data=DoubleToStr(MathAbs(vByT/pByT),0);
      YVal=MathAbs(vByT/pByT);
      if(vol<0)
         data="M_"+DoubleToStr(MathAbs(vByT/pByT),0);
     }
   if(vp==PINCH)
     {
      data=DoubleToStr(MathAbs(vByT/pByT),0);
      YVal=MathAbs(vByT/pByT);
      if(vol<0)
         data="M_"+DoubleToStr(MathAbs(vByT/pByT),0);
     }
   string sOldTime = stdText+string(oldTime);
   string sNewTime = stdText+string(newTime);

if(oldTime!=NULL && ObjectDelete(ChartID(),sOldTime))
{
   // Print("Deleted OldTime: "+sOldTime);
}
//Should be YVal o or high depending on =/-
   ObjectCreate(ChartID(),sNewTime,OBJ_TEXT,ChartWindowFind(),newTime,YVal);
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
   delete(pc);
  }
//+------------------------------------------------------------------+
//| PrintMe                                                                 |
//+------------------------------------------------------------------+
void   printMe(string now,int s,string lagDirection,datetime oET,int oEI,datetime eT,int eI,int aI,datetime aT)
  {
   return;
   Print(" ***** ",Time[0],"1 Simulation Time[shift]: ");
   Print("2 shift: ",s);
   Print("3 time Now ",eT);
   Print("4 Index Now ",eI);
   Print("5 Up or Down Now: ",now);
   Print("6 old Trend ",lagDirection);
   Print("7 old Time ",oET);
   Print("8 old Index ",oEI);
   Print("9 anchorIndex ",aI);
   Print("10 anchorTime ",aT);
  }
//-+------------------------------------------------------------------+
//| CalculateAVG  from d'Orsey                                        |
//+-------------------------------------------------------------------+ 
//double CalculateAVG(double bt)
//  {
//   double   tempSum=0;
//   int btc=(int(bt));
//   double numBars=Bars(Symbol(),0);
//   if(btc>numBars)// && visible)
//     {
//      string sym=Symbol();
//      int tf=Period();
//
//      numBars=Bars(Symbol(),0);
//      if(numBars<=50)
//        {
//         Print(__FUNCTION__," ********  WARNING Wave height - Not enough data points  ******************  "+(string)numBars);
//         PlaySound("tick.wav");
//         return -1; //hard failsafe
//        }
//      btc=Bars(Symbol(),0);
//      PlaySound("tick.wav");
//      if(numBars<btc)
//         Print(__FUNCTION__," ********  WARNING Wave height - Not enough data points ... best estimate used  ******************  "+(string)numBars);
//     }
//   int   v;
//   for(v=1; v<btc; v++)
//      tempSum=tempSum+getRange(v);
//   tempSum=tempSum/(btc);
//   return (NormalizeDouble(tempSum,0));
//  }
//+------------------------------------------------------------------+
//| getRange from d'Orsey                                            |
//+------------------------------------------------------------------+
//double getRange(int bar)
//  {
//   double   range;
//   range=High[bar]-Low[bar];
//   return (NormalizeDouble(range/Point,0));
//  } 
//+------------------------------------------------------------------+
//|initBuffers                                                       |
//+------------------------------------------------------------------+
void initBuffers(volume_price vp)
  {
   SetLevelValue(0,50);
//SetLevelStyle();
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,clrAliceBlue);

   SetIndexBuffer(0,ExtPriceClose);
   SetIndexLabel(0,"Price Wave Close");
   SetIndexEmptyValue(0,EMPTY_VALUE);

   SetIndexBuffer(1,ExtPrice);
   SetIndexLabel(1,"Close Wave");
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexBuffer(2,ExtVol);
   SetIndexLabel(2,"Volume dVolume");
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexBuffer(3,ExtTime);
   SetIndexLabel(3,"Time dTime");
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexBuffer(4,ExtVolumeByTime);
   SetIndexLabel(4,"Vol By Time ");
   SetIndexEmptyValue(4,EMPTY_VALUE);

   SetIndexBuffer(5,ExtPriceByTime);
   SetIndexLabel(5,"Price By Time ");
   SetIndexEmptyValue(5,EMPTY_VALUE);

   SetIndexBuffer(6,ExtPinch);
   SetIndexLabel(6,"Price By Time ");
   SetIndexEmptyValue(6,EMPTY_VALUE);

// .
// .
// .
   SetIndexBuffer(10,ExtSumVol);
   SetIndexLabel(10,"Wave Vol Sum");
   SetIndexEmptyValue(10,EMPTY_VALUE);

   if(vp==WAVE_PRICE)
     {
      SetIndexStyle(0,DRAW_SECTION,0,1,clrLine);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
      // set the others up as auxillary buffers and move (0) into here.
     }
   if(vp==DELTA_PRICE)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_HISTOGRAM,0,1,clrLine);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
     }
   if(vp==DELTA_VOLUME)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_HISTOGRAM,0,1,clrLine);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetLevelStyle(STYLE_DASH,1,clrLine);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
      SetLevelValue(0,0);
     }
   else if(vp==DELTA_TIME)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_HISTOGRAM,0,1,clrLine);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
     }
   else if(vp==DELTA_V_BY_T)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_HISTOGRAM,0,1,clrLine);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
     }
   else if(vp==DELTA_P_BY_T)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_HISTOGRAM,0,1,clrLine);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
     }
   else if(vp==SPARE)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_HISTOGRAM,0,1,clrLine);
      SetIndexStyle(10,DRAW_NONE,0,1,clrNONE);
     }
   else if(vp==PINCH)
     {
      SetIndexStyle(0,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(1,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(2,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(3,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(4,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(5,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(6,DRAW_NONE,0,1,clrNONE);
      SetIndexStyle(10,DRAW_HISTOGRAM,0,1,clrLine);
     }

//- Always output
   SetIndexStyle(7,DRAW_NONE,0,2,clrNONE);
   SetIndexBuffer(7,ExtValueBuffer);
   SetIndexLabel(7,"value Buffer");
   SetIndexEmptyValue(7,EMPTY_VALUE);

   SetIndexBuffer(8,ExtPercentBuffer);
   SetIndexStyle(8,DRAW_NONE,0,1,clrNONE);
   SetIndexLabel(8,"Perc Buffer");
   SetIndexEmptyValue(8,EMPTY_VALUE);

   SetIndexBuffer(9,ExtSignedDeltaVolume);
   SetIndexStyle(9,DRAW_NONE,0,1,clrNONE);
   SetIndexLabel(9,"Signed Delta");
   SetIndexEmptyValue(9,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
