//+------------------------------------------------------------------+
//|                                                  WeisWave v6.mq4 |
//|                                    Copyright 2014 Robert Baptie. |
//|                               http://rgb-web-developer.comli.com |
//+------------------------------------------------------------------+
#property copyright   "2014 Robert Baptie"
#property link        "http://rgb-web-developer.comli.com"
#property description "weisWave"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <waveLibrary.mqh>
#property indicator_separate_window

#property indicator_buffers 9;
//---cumulative wave volumes
#property indicator_color1 clrGreen
#property indicator_width1 4
#property indicator_color2 clrRed
#property indicator_width2 4
#property indicator_color3 clrGreen
#property indicator_width3 4
#property indicator_color4 clrRed
#property indicator_width4 4
//#property indicator_color3 clrOrangeRed
//#property indicator_width3 2

//--- indicator parameters
//extern int   volPeriod=100;//SMA of Volume
                           //extern int     maxBars=500;//1 min 5 min only TF num Vol bars Displayed
extern double  wavePts=50;//0.5 points is 50 on SP500 / zero auto scale
extern int     numToDrawBox=200;//time bricks to draw
extern bool    showBricks=false;//show time Bricks
extern bool    showCurrencyInfo=false;//Display Basic info
extern bool    showWavesInfo=true;//Display Wave Index
extern bool    showPrice=false;
extern bool    showVolume=true;
extern bool    showTime=false;
extern double  ADRDivisor=30;
extern double waveThickness=0.5;
extern color clrUpBox=clrLightBlue;
extern color clrDownBox=clrLightPink;
extern bool visible=true;
extern bool drawWave =false;
int fontSize=10;
string fontType="mono";//"Times New Roman";//"Windings";

//--- buffers
double closeWaveBuffer[];
double deltaPrice[];
double deltaVolume[];
double deltaTime[];
double volumeUp[];
double volumeDown[];
double volUndecidedDown[];
double volUndecidedUp[];
double residualVolume[];
double holdOffSet[];

//---GLOBALS
//---general
long uniqueIDRect=0;
long uniqueLineID=0;
string shortName;
int prevShift=0;
int anchorLeft=-1; //lhs line
double cumulativeVolume=0;
double cumWaveHeight=0;
int ExtBegin=0;
long chart_id=0;
string lastWaveDirection="";
string lastWaveText="";
string cumIndexName="";
string cumPriceName="";
double tickSize  = MarketInfo(NULL,MODE_TICKSIZE);
double tickValue = MarketInfo(NULL,MODE_TICKSIZE);
double dspread=MarketInfo(NULL,MODE_SPREAD);
double minLotSize=MarketInfo(NULL,MODE_MINLOT);

//---wave height
int BarsToCalculateADR=1000;
double waveHeightPts=-1;

//---text display
color clrIndexUp=clrDarkGreen;
color clrIndexDown=clrRed;

double dPartVol;
string sPartVol;
int pwInt=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorBuffers(10);
   IndicatorDigits(Digits);

//UP and Down && Undecided Wave Volume
   SetIndexBuffer(0,volumeUp);
   SetIndexLabel(0,"volUp");
   if(visible)
      SetIndexStyle(0,DRAW_HISTOGRAM);
   else
      SetIndexStyle(0,DRAW_NONE);

   SetIndexBuffer(1,volumeDown);
   SetIndexLabel(1,"volDown");
   if(visible)
      SetIndexStyle(1,DRAW_HISTOGRAM);
   else
      SetIndexStyle(1,DRAW_NONE);

   SetIndexBuffer(2,volUndecidedUp);
   SetIndexLabel(2,"volUndecidedUp");

   if(visible)
     {
      SetIndexStyle(2,DRAW_ARROW);
      SetIndexArrow(2,159);
     }
   else
      SetIndexStyle(2,DRAW_NONE);

   SetIndexBuffer(3,volUndecidedDown);
   SetIndexLabel(3,"volUndecidedDown");
   if(visible)
     {
      SetIndexStyle(3,DRAW_ARROW);
      SetIndexArrow(3,159);
     }
   else
      SetIndexStyle(3,DRAW_NONE);

//Price Value of Wave
   SetIndexBuffer(4,closeWaveBuffer);
   SetIndexLabel(4,"closeWaveBuffer");
   SetIndexStyle(4,DRAW_NONE);

//Wave Values
   SetIndexBuffer(5,deltaPrice);
   SetIndexLabel(5,"deltaPrice");
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(6,deltaVolume);
   SetIndexLabel(6,"deltaVolume");
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(7,deltaTime);
   SetIndexLabel(7,"deltaTime");
   SetIndexStyle(7,DRAW_NONE);

//bar[0] Last Non wave step volume
   SetIndexBuffer(8,residualVolume);//+/-volUndecidedDown / volUndecidedUp
   SetIndexLabel(8,"+/- Residual Volume");
   SetIndexStyle(8,DRAW_NONE);

//internal Hold Offset Value for backfill
   SetIndexBuffer(9,holdOffSet);
   SetIndexLabel(9,"holdOffSet");
   SetIndexStyle(9,DRAW_NONE);
   chart_id=ChartID();

//---General Information on chart
   if(wavePts==0)
     {
      waveHeightPts=MathRound(CalculateAVG(BarsToCalculateADR/ADRDivisor));
      if(waveHeightPts==-1)
         waveHeightPts=40;//Default
     }
   else
     {
      waveHeightPts=wavePts;
     }
   shortName="WeisVolume "+(string)waveHeightPts;
   IndicatorShortName(shortName);

 //  ChartSetInteger(chart_id,CHART_AUTOSCROLL,true);//no auto scroll
 //ChartModeSet(CHART_BARS,chart_id);//line of close
 //  ChartShiftSet(true,chart_id);//right offset from border
   bool res=ChartNavigate(chart_id,CHART_END,10);
//   ChartForegroundSet(true,chart_id);
   if(visible)
     {
      ObjectCreate("volPriceIndex",OBJ_LABEL,1,0,0);// Creating obj   
      ObjectSet("volPriceIndex",OBJPROP_CORNER,CORNER_RIGHT_UPPER);    // Reference corner
      ObjectSet("volPriceIndex", OBJPROP_XDISTANCE, 10);// X coordinate
      ObjectSet("volPriceIndex", OBJPROP_YDISTANCE, 15);// Y coordinate
      ObjectSetInteger(chart_id,"volPriceIndex",OBJPROP_BACK,false);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
      ObjectSetInteger(chart_id,"volPriceIndex",OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chart_id,"volPriceIndex",OBJPROP_SELECTED,false);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_id,"volPriceIndex",OBJPROP_HIDDEN,false);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_id,"volPriceIndex",OBJPROP_ZORDER,1000);
     }
   return (INIT_SUCCEEDED);
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
   ArraySetAsSeries(closeWaveBuffer,false);
   ArraySetAsSeries(holdOffSet,false);
   ArraySetAsSeries(volumeUp,false);
   ArraySetAsSeries(volumeDown,false);
   ArraySetAsSeries(volUndecidedDown,false);
   ArraySetAsSeries(volUndecidedUp,false);
   ArraySetAsSeries(deltaVolume,false);
   ArraySetAsSeries(deltaPrice,false);
   ArraySetAsSeries(deltaTime,false);
   ArraySetAsSeries(tick_volume,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(time,false);

   ArrayResize(residualVolume,1);
//  ArrayResize(volUndecidedUp,1);
//  ArrayResize(volUndecidedDown,1);

   int shift=-1,limit=0;
//--- if it is the first call 
   if(prev_calculated==0)
     {
      ArrayResize(residualVolume,1);
      ArrayResize(volUndecidedUp,1);
      ArrayResize(volUndecidedDown,1);
      ArrayResize(holdOffSet,1);
      anchorLeft=limit;
      for(int j=0; j<rates_total-1; j++)
        {
         cumulativeVolume+=double(tick_volume[j]);
         if(MathAbs(convertPoints(close[j]-close[anchorLeft]))>=waveHeightPts)
           {
            limit=j;
            closeWaveBuffer[j]=close[j];
            deltaPrice[j]=close[j]-close[anchorLeft];
            deltaVolume[j]=cumulativeVolume;
            string soFar=DoubleToStr(cumulativeVolume,0);
            string pw=string(StringLen(soFar));
            pwInt=int(pw);
            deltaTime[j]=NULL;//time[j]-time[anchorLeft];     
            cumulativeVolume=0;
            anchorLeft=limit;
            holdOffSet[0]=limit;
            break;
           }
        }
     }
   else
      limit=prev_calculated-1;

//--MAIN LOOP   
   for(shift=limit;shift<rates_total;shift++)
     {
      if(shift!=prevShift)//New Bar at runtime 
        {
         volUndecidedUp[rates_total-1]=EMPTY_VALUE;
         volUndecidedDown[rates_total-1]=EMPTY_VALUE;
         cumulativeVolume+=(double)tick_volume[shift-1];
         testWaveDone(shift-1,high,low,close,time,rates_total,tick_volume,int(holdOffSet[0]));
         prevShift=shift;//new candle is old candle
        }
      else
        {
         string priceLabel=string(convertPoints(close[shift]-close[anchorLeft]));
         if(visible)
            ObjectSetInteger(chart_id,"volPriceIndex",OBJPROP_BACK,false);
         dPartVol= cumulativeVolume+tick_volume[shift];
         sPartVol=chopForm(dPartVol,2);
         residualVolume[rates_total-1]=(double)sPartVol;
         sPartVol=StringConcatenate("V: ",sPartVol," P: ",priceLabel);
         if(visible)
            ObjectSetString(chart_id,"volPriceIndex",OBJPROP_TEXT,sPartVol);
         if((close[shift]-close[anchorLeft])<0)
           {
            residualVolume[rates_total-1]=-1*residualVolume[0];
            if(visible)
              {
               ObjectSetText("volPriceIndex",sPartVol,fontSize,fontType,clrIndexDown);
               double direction=0,value=0;
               findLastFullWave(direction,value,rates_total);
               if(direction<0)
                  volUndecidedDown[rates_total-1]=dPartVol+value;
               else
                  volUndecidedDown[rates_total-1]=dPartVol;

               volUndecidedUp[rates_total-2]=EMPTY_VALUE;
               volUndecidedDown[rates_total-2]=EMPTY_VALUE;
               volUndecidedUp[rates_total-1]=EMPTY_VALUE;
              }
           }
         else
           {
            if(visible)
              {
               ObjectSetText("volPriceIndex",sPartVol,fontSize,fontType,clrIndexUp);
               double direction=0,value=0;
               findLastFullWave(direction,value,rates_total);
               if(direction>0)
                  volUndecidedUp[rates_total-1]=dPartVol+value;
               else
                  volUndecidedUp[rates_total-1]=dPartVol;

               volUndecidedDown[rates_total-1]=EMPTY_VALUE;
               volUndecidedUp[rates_total-2]=EMPTY_VALUE;
               volUndecidedDown[rates_total-2]=EMPTY_VALUE;
              }
           }
        }
     }
   if(showCurrencyInfo)
      Comment(StringFormat("Show prices\nwaveheightPts = %G\nPoint = %G\nDigits = %G\ntickSize = %G\ntickValue = %G\ndspread = %G\nminLoSize = %G",waveHeightPts,Point,Digits,tickSize,tickValue,dspread,minLotSize));
   ChartRedraw(1);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findLastFullWave(double &direction,double  &value,int rt)
  {
   double down=EMPTY_VALUE,up=EMPTY_VALUE;
   for(int t=rt-1; t>0; t--)
     {
      up=volumeUp[t];
      down=volumeDown[t];
      if(up>down)
        {
         direction=1;
         value=up;
         return;
        }
      else if(down>up)
        {
         direction=-1;
         value=down;
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| testWaveDone                                                     |
//+------------------------------------------------------------------+  
bool testWaveDone(int shift,const double &h[],const double &l[],const double &c[],const datetime &t[],double rt,const long &tVol[],int heldOffset)
  {
   int drawAnchorLeft=-1;
//---If we have a new wave brick
   if((MathAbs(convertPoints(c[shift]-c[anchorLeft])))>=waveHeightPts)
     {//---WE HAVE A NEW PART OF THE CURRENT WAVE OR EXTENTION OF IT

      //1. ---draw equi price blocks (min 1 min candle)
      if(visible)
        {
         if((shift>=(rt-numToDrawBox)) && showBricks)
           {
            uniqueIDRect++;
            string rectangleName="rect"+string(uniqueIDRect);
            drawBox(anchorLeft,shift,rectangleName,t,c);
           }
        }
      //2. ---IT IS A WAVE EXTENSION
      if((((c[anchorLeft]-c[shift])<=0) && lastWaveDirection=="Up") || (((c[anchorLeft]-c[shift])>=0) && lastWaveDirection=="Down"))
        {//extension of up or down wave
         ResetLastError();
         if(visible)
           {
            bool isDeleted=checkDeletedPresentWave(t,shift);
           }
         //---Add previous brick         
         cumulativeVolume+=deltaVolume[anchorLeft]; //UpdateVolume to reflect additional brick
         drawAnchorLeft=findWaveStart(anchorLeft,1,1);//find last wave end
         //---destroy previous anchor & values           
         closeWaveBuffer[anchorLeft]=EMPTY_VALUE;
         deltaPrice[anchorLeft]=EMPTY_VALUE;
         deltaVolume[anchorLeft]=EMPTY_VALUE;
         deltaTime[anchorLeft]=EMPTY_VALUE;
        }
      else
        {//IT IS A CHANGE OF WAVE DIRECTION
         drawAnchorLeft=anchorLeft;
        }
      //3. ---UPDATE THE WAVE LINE BUFFERS AND PRICE / VOLUME / TIME DELTAS
      closeWaveBuffer[shift]=c[shift];
   //  int tempAnchorLeft=findWaveStart(AL,2,0);
      deltaPrice[shift]=c[shift]-c[drawAnchorLeft];      
      //closeWaveBuffer[shift]=c[shift];
      //int tempAnchorLeft=findWaveStart(anchorLeft,2,0);
      //deltaPrice[shift]=c[shift]-c[tempAnchorLeft];
      //---Display Volume
      deltaVolume[shift]=cumulativeVolume;
      deltaTime[shift]=shift+1-drawAnchorLeft;
      if(showWavesInfo)
        {
         setWaveTexts(shift,h,l,t,c[shift]-c[drawAnchorLeft],rt,c);
        }
      //--- draw wave line
      //--record last wave name for deletion under same direction wave occuring   
      if(drawWave)
      lastWaveText=drawLine(drawAnchorLeft,shift,t,c);
      //--record direction of wave
      if((c[anchorLeft]-c[shift])<0)
         lastWaveDirection="Up";
      else
         lastWaveDirection="Down";
      //update new brick volume  
      if(lastWaveDirection=="Up")
        {
         volumeUp[shift]   = cumulativeVolume;
         volumeDown[shift] = 0;
        }
      else
        {
         volumeUp[shift]   = 0;
         volumeDown[shift] = cumulativeVolume;
        }
      backFillVolume(lastWaveDirection,shift,tVol,heldOffset);
      cumulativeVolume=0;
      anchorLeft=shift; //reset left aspect of line for new brick      
     }
   else //No new brick
     {
      closeWaveBuffer[shift]=EMPTY_VALUE;
      deltaPrice[shift]=EMPTY_VALUE;
      deltaVolume[shift]=EMPTY_VALUE;
      deltaTime[shift]=EMPTY_VALUE;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| findWaveStart                                                    |
//+------------------------------------------------------------------+   
int findWaveStart(int aL,double backWaveNum,int end)
//---backwavnum - begining of first wave = 1
  {
   int count=1;
   int iterator;
   int drawAL=0;
   for(iterator=aL-end; iterator>=0; iterator--)
     {
      if(closeWaveBuffer[iterator]==EMPTY_VALUE)
         continue;
      else if(count<backWaveNum)
        {
         count+=count;
         continue;
        }
      else
         drawAL=iterator;
      return drawAL;
     }
   return drawAL;
  }
//+------------------------------------------------------------------+
//| setWaveTexts                                                     |
//+------------------------------------------------------------------+   
void setWaveTexts(int shift,const double &h[],const double &l[],const datetime&t[],double lwd,double rates_total,const double &c[])
  {
   double indexLocation=-1;
   double priceLocation=-1;
   color indexColor;
   datetime indexDateLocation;
//   double fontPixels=fontTextSize*pointToPixel;
   if(lwd<0)
     {
      indexLocation=l[shift];
      indexColor=clrIndexDown;
      if((shift-1)>0)
         indexDateLocation=t[shift-1];
      else
         indexDateLocation=t[shift];
     }
   else
     {
      indexLocation=h[shift];
      double offset= 0;
      int numBars=2;
      double prevHigh=indexLocation;
      if(((shift+numBars)<rates_total) && (shift-numBars>=0))
        {
         for(int n=shift+numBars; n>=shift-numBars; n--)
           {
            offset+=h[n]-c[n];
            if(h[n]>prevHigh)
              {
               indexLocation=h[n];
               prevHigh=h[n];
              }
           }
         offset/=numBars*2+1;
         indexLocation+=offset;
        }
      else
        {
         indexLocation=h[shift];
        }

      if((shift-1)>0)
         indexDateLocation=t[shift-1];
      else
         indexDateLocation=t[shift];
      indexColor=clrIndexUp;
     }
//Set TextBox Names
   cumIndexName="cumIndex"+TimeToString(t[shift]);
//-- #Points         
   double ptsPriceDiff=NormalizeDouble(convertPoints(deltaPrice[shift]),0);
   string priceString = DoubleToStr(ptsPriceDiff,0);
//   string priceString = chopForm(deltaPrice[shift],1);
//---Time   
// double timeDiff=NormalizeDouble(convertPoints(deltaTime[shift]),0);
   string timeString=DoubleToStr(deltaTime[shift],0);//chopForm(deltaTime[shift],1);
                                                     //Create TextBox Objects   
   if(visible)
     {
      if(ObjectFind(ChartID(),cumIndexName)<0)
        {
         if(!ObjectCreate(ChartID(),cumIndexName,OBJ_TEXT,0,indexDateLocation,indexLocation))
           {
            Print(__FUNCTION__,": failed to create a cumIndexName! Error = ",ErrorDescription(GetLastError()));
           }
        }
     }
//--- display in the foreground (false) or background (true)
   if(visible)
      ObjectSetInteger(chart_id,cumIndexName,OBJPROP_BACK,false);
   string volString=chopForm(deltaVolume[shift],1);
   string str=setDisplayTexts(volString,priceString,timeString);
   if(visible)
     {
      ObjectSetText(cumIndexName,str,fontSize,fontType,indexColor);
     }
  }
//+------------------------------------------------------------------+
//| setDisplayTexts                                                         |
//+------------------------------------------------------------------+  
string setDisplayTexts(string v,string p,string t)
  {
   string str="";
   if(showVolume)
      str=StringConcatenate("V: ",v);
   if(showPrice)
      str=StringConcatenate(str,"  P: ",p);
   if(showTime)
      str=StringConcatenate(str,"  T: ",t);
   return str;
  }
//+------------------------------------------------------------------+
//| chopForm                                                         |
//+------------------------------------------------------------------+  
string chopForm(double delta,int decPlaces)
  {
   double fin;
   if(pwInt>1)
      fin=delta/MathPow(10,(pwInt-1));
   else
      fin=0;
   string finalStr=DoubleToStr(fin,decPlaces);
   string str=StringConcatenate(finalStr);
   return str;
  }
//+------------------------------------------------------------------+
//| backFillVolume                                                   |
//+------------------------------------------------------------------+   
void backFillVolume(string lwd,int shift,const long &tv[],int heldOffset)
  {
   int pos=shift-1;
   if(pos<0) return;
   if(lwd=="Up")
     {
      while(volumeUp[pos]==EMPTY_VALUE && pos>heldOffset)
        {
         volumeUp[pos]=volumeUp[pos+1]-tv[pos+1];
         pos--;
         if(pos<0)
            return;
        }
     }
   else if(lwd=="Down")
     {
      while(volumeDown[pos]==EMPTY_VALUE && pos>heldOffset)
        {
         volumeDown[pos]=volumeDown[pos+1]-tv[pos+1];
         pos--;
         if(pos<0)
            return;
        }
     }
  }
//+------------------------------------------------------------------+
//| checkDeletedPresentWave                                          |
//+------------------------------------------------------------------+   
bool checkDeletedPresentWave(const datetime &t[],int shift)
  {
   bool isDeleted=ObjectDelete(chart_id,lastWaveText);
   if(!isDeleted && lastWaveText!="")
     {
      Print(__FUNCTION__,": delete line failed WaveNum: ",lastWaveText," ",ErrorDescription(GetLastError())+string(t[shift]));
      return(false);
     }
   if(showWavesInfo && !ObjectDelete(chart_id,cumIndexName))
     {
      Print(__FUNCTION__,": delete Vol failed ",ErrorDescription(GetLastError())+string(t[shift]));
      return(false);
     }
//if(!ObjectDelete(chart_id,cumPriceName))
//  {
//   Print(__FUNCTION__,": delete Price failed ",ErrorDescription(GetLastError())+string(t[shift]));
//   return(false);
//  }
   return true;
  }
//+------------------------------------------------------------------+
//| CalculateAVG  from d'Orsey                                        |
//+------------------------------------------------------------------+ 
double CalculateAVG(double bt)
  {
   double   tempSum=0;
   int btc=(int(bt));
   double numBars=Bars(Symbol(),0);
   if(btc>numBars)// && visible)
     {
      string sym=Symbol();
      int tf=Period();

      numBars=Bars(Symbol(),0);
      if(numBars<=50)
        {
         Print(__FUNCTION__," ********  WARNING Wave height - Not enough data points  ******************  "+(string)numBars);
         PlaySound("tick.wav");
         return -1; //hard failsafe
        }
      btc=Bars(Symbol(),0);
      PlaySound("tick.wav");
      if(numBars<btc)
         Print(__FUNCTION__," ********  WARNING Wave height - Not enough data points ... best estimate used  ******************  "+(string)numBars);
     }
   int   v;
   for(v=1; v<btc; v++)
      tempSum=tempSum+getRange(v);
   tempSum=tempSum/(btc);
   return (NormalizeDouble(tempSum,0));
  }
//+------------------------------------------------------------------+
//| getRange from d'Orsey                                                |
//+------------------------------------------------------------------+
double getRange(int bar)
  {
   double   range;
   range=High[bar]-Low[bar];
   return (NormalizeDouble(range/Point,0));
  }
//+------------------------------------------------------------------+
//| convPoints                                                   |
//+------------------------------------------------------------------+
double convertPoints(double diff)
  {
   double dtickValue=MarketInfo(NULL,MODE_TICKSIZE);
   double pts=NormalizeDouble(diff/dtickValue,Digits);
   return pts;
  }
//+------------------------------------------------------------------+
//| drawLine                                                         |
//+------------------------------------------------------------------+  
string drawLine(int leftAnchor,int lineEnd,const datetime &t[],const double &c[])
  {
   uniqueLineID++;
   if(uniqueLineID==1)
      return "";
   if(visible)
     {
      int sw=ObjectFind(ChartID(),("wave"+string(uniqueLineID)));
      int window=0;
      if(sw<0)
        {
         if(!ObjectCreate(ChartID(),"wave"+string(uniqueLineID),OBJ_TREND,0,t[leftAnchor],c[leftAnchor],t[lineEnd],c[lineEnd]))
           {
            Print(__FUNCTION__,": failed to create a wave line, Error code = ",ErrorDescription(GetLastError()));
            return "wave Already Exists";
           }
         else
           {
            //--- set line color   
            ObjectSetInteger(chart_id,"wave"+string(uniqueLineID),OBJPROP_BACK,false);
            ObjectSetInteger(chart_id,"wave"+string(uniqueLineID),OBJPROP_SELECTABLE,false);
            //---enable (true) or disable (false) the mode of continuation of the line's display to the left
            ObjectSetInteger(chart_id,"wave"+string(uniqueLineID),OBJPROP_RAY_LEFT,false);
            //--- enable (true) or disable (false) the mode of continuation of the line's display to the right
            ObjectSetInteger(chart_id,"wave"+string(uniqueLineID),OBJPROP_RAY_RIGHT,false);
            ObjectSet("wave"+string(uniqueLineID),OBJPROP_WIDTH,waveThickness);
            if((c[leftAnchor]-c[lineEnd])<0)
              {
               ObjectSetInteger(chart_id,"wave"+string(uniqueLineID),OBJPROP_COLOR,clrBlue);
              }
            else
              {
               ObjectSetInteger(chart_id,"wave"+string(uniqueLineID),OBJPROP_COLOR,clrRed);
              }
           }
        }
      // else
      // Print(__FUNCTION__," Wave already exists");
     }
   return "wave"+string(uniqueLineID);
  }
//+------------------------------------------------------------------+
//| drawBox                                                          |
//+------------------------------------------------------------------+   
void drawBox(int index1,int index2,string rectName,const datetime &t[],const double &c[])
  {
   datetime time1,time2;
   double price1,price2;
   color clr;
   price1=c[index1]; price2=c[index2]; time1=t[index1]; time2=t[index2];
   if(price2>=price1)
      clr=clrUpBox;
   else
      clr=clrDownBox;
   bool hasCreatedRectangle=RectangleCreate(
                                            chart_id,       // chart's ID
                                            rectName,       // rectangle name
                                            0,              // subwindow index 
                                            time1,          // first point time
                                            price1,         // first point price
                                            time2,          // second point time
                                            price2,         // second point price
                                            clr,            // rectangle color
                                            STYLE_SOLID,    // style of rectangle lines

                                            1,// width of rectangle lines
                                            false,// filling rectangle with color
                                            true,// in the background
                                            false,          // highlight to move
                                            false,          // hidden in the object list
                                            0);             // priority for mouse click                                            
  }

//+------------------------------------------------------------------+
//| Set chart display type (candlesticks, bars or                    |
//| line).                                                           |
//+------------------------------------------------------------------+
//bool ChartModeSet(const long value,const long chart_ID=0)
//  {
////--- reset the error value
//   ResetLastError();
////--- set property value
//   if(!ChartSetInteger(chart_ID,CHART_MODE,value))
//     {
//      //--- display the error message in Experts journal
//      Print(__FUNCTION__+", Error Code = ",GetLastError());
//      return(false);
//     }
////--- successful execution
//   return(true);
//  }
////+--------------------------------------------------------------------------+
////| The function enables/disables the mode of displaying a price chart with  |
////| a shift from the right border.                                           |
////+--------------------------------------------------------------------------+
//bool ChartShiftSet(const bool value,const long chart_ID=0)
//  {
////--- reset the error value
//   ResetLastError();
////--- set property value
//   if(!ChartSetInteger(chart_ID,CHART_SHIFT,0,value))
//     {
//      //--- display the error message in Experts journal
//      Print(__FUNCTION__+", Error Code = ",GetLastError());
//      return(false);
//     }
////--- successful execution
//   return(true);
//  }
////+---------------------------------------------------------------------------+
////| The function enables/disables the mode of displaying a price chart on the |
////| foreground.                                                               |
////+---------------------------------------------------------------------------+
//bool ChartForegroundSet(const bool value,const long chart_ID=0)
//  {
////--- reset the error value
//   ResetLastError();
////--- set property value
//   if(!ChartSetInteger(chart_ID,CHART_FOREGROUND,0,value))
//     {
//      //--- display the error message in Experts journal
//      Print(__FUNCTION__+", Error Code = ",GetLastError());
//      return(false);
//     }
////--- successful execution
//   return(true);
//  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string textName1="wave";
   string textName2="rect";
   string textName3="cumIndex";
// string textName4="cumPrice";
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,4)==textName1 || StringSubstr(objName,0,4)==textName2 || StringSubstr(objName,0,8)==textName3)// || StringSubstr(objName,0,8)==textName4)
        {
         ObjectDelete(ObjectName(i));
         //  Print("deleted ",objName);
        }
     }
   ObjectDelete("volPriceIndex");
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double iSMAVOL(const int position,const int period,const long &tick_price[])
  {
//---
   double result=0.0;
//--- check position
   if(position>=period-1 && period>0)
     {
      //--- calculate value
      //for(int i=0;i<period;i++) 
      for(int i=(period-1); i>=0; i--)
         result+=(double)tick_price[position-i];
      result/=period;
     }
   else
      result=-1;
//---
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void OnChartEvent(const int id,         // Event identifier  
//                  const long& lparam,   // Event parameter of long type
//                  const double& dparam, // Event parameter of double type
//                  const string& sparam) // Event parameter of string type
//  {
////--- the left mouse button has been pressed on the chart
//   if(id==CHARTEVENT_CLICK)
//     {
//      //   Print("The coordinates of the mouse click on the chart are: x = ",lparam,"  y = ",dparam);
//      ChartRedraw();
//     }
//  }
//+------------------------------------------------------------------+
