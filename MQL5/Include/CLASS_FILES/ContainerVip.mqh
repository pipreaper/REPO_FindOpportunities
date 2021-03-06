// +------------------------------------------------------------------+
// |                                                       EXPERT.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                                                  |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      ""
#property strict
#include <Arrays\List.mqh>
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <INCLUDE_FILES\\GetBrokerSymbolTFData.mqh>
#include <CLASS_FILES\\ATRInfo.mqh>
#include <CLASS_FILES\\Global.mqh>
#include <INCLUDE_FILES\\drawText.mqh>
#include <INCLUDE_FILES\\drawRectangle.mqh>
#include <errordescription.mqh>
class Vip;
class VipElement;
Global gVip;
// +------------------------------------------------------------------+
// |ContainerVip:container for Vip                                 |
// +------------------------------------------------------------------+
class ContainerVip : public CList
  {
public:
   void              ContainerVip::ContainerVip();
   void              ContainerVip::~ContainerVip();
   void              ContainerVip::ToLog();
  };
// +------------------------------------------------------------------+
// |Constructor                                                       |
// +------------------------------------------------------------------+
void              ContainerVip::ContainerVip()
  {
  }
// +------------------------------------------------------------------+
// |Destructor                                                        |
// +------------------------------------------------------------------+
void              ContainerVip::~ContainerVip()
  {
  }
// +------------------------------------------------------------------+
// |To Log                                                            |
// +------------------------------------------------------------------+
void              ContainerVip::ToLog()
  {
   for(Vip *i=GetFirstNode(); i!=NULL; i=i.Next())
      Print(i.waveHTFPeriod," ");
   Print("// -----------------------------------------------------// ");
  }
// +------------------------------------------------------------------+
// |Percentile:number of times a price is crossed in history         |
// +------------------------------------------------------------------+
class Percentile : public CObject
  {
public:
   // bucket by step
   double            cumulativeStep[];
   // bucket by count
   int               bucketCount[];
   // passed eg 0.95 is 95th percentile
   double            percentileOfInterest;
   //volume value of percentileOfInterst - calculated when setting percentiles
   double            percentileThreshhold;
   // rates for Vip holder of this Object
   MqlRates          ratesHTF[];
   // new percentile Object
   void              Percentile::Percentile(int _numBins, double _percentileOfInterest);
  };
// +----------------------------------------------------------------+
// |Constructor                                                          |
// +----------------------------------------------------------------+
void              Percentile::Percentile(int _numBins, double _percentileOfInterest)
  {
   ArrayResize(cumulativeStep,_numBins);
   ArrayResize(bucketCount,_numBins);
   percentileOfInterest = double(_percentileOfInterest/100);
   percentileThreshhold=-1;
  }
// +------------------------------------------------------------------+
// |Vip( Level Instrument Period  ): Information about levels (S/R)   |
// +------------------------------------------------------------------+
class Vip : public CList
  {
public:
   string            symbol;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   int               countIndicatorPulls;
   int               htfShift;
   int               phtfShift;
   int               shift;
   int               percentileValue;
   int               nBins;
   int               numVolBeforeDeletionStarts;
   int               nATRsFromHLCalcDisplay;
   //Vip needs own copy of ATR because tip ATR may not exist
   ATRInfo           *atrInfo;
   bool              drawLevels;
   bool              useLevel;
   int               barSelected;
   // global
   int               uniqueLineID;
   color             clrLine;
   long              chart_id;

   // -set in genVolumesPeriod()
   int               thickness;
   int               startBar;// number of bars to process - 2200 on average for all of them ... so all are used.
   int               barsHTFChart;// Chart Bars
   //   int               barsBackLimitMinute;// exception for minute bars has 12200 bars in total history. minute is not importatnt unless scalping
   int               minBarsDebugRun;
   int               maxBarsDebugRun; // if 0 use Maximum history to calculate levels or use backBarLimit number of bars
   MqlRates          ratesHTF[];// contains all ratesHTF (startBar - 1) ->
   int               FontSize;
   string            FontType;
   double            uHighestVol;
   double            uLowestVol;
   double            step;
   int               numRates;// Chart Bars
   Percentile        *percentile;
   // Constructor
   void              Vip::Vip(

      string _symbol,
      ENUM_TIMEFRAMES  _enumHTFPeriod,
      color _clrLine,
      int   _atrVolAppliedPrice,
      int _atrVolPeriod,
      int _minBars,
      int _maxBars,
      int _percentileValue,
      int _nBins,
      int _numVolBeforeDeletionStarts,
      int _nATRsFromHLCalcDisplay,
      bool _useLevel,
      bool _drawLevels,
      bool _condition);
   // Destructor
   void Vip::                ~Vip();
   // updateLevelsPeriod: set parms and gen levels
   // void              Vip::updateLevelsPeriod();
   // gen levels
   void              Vip::genLevelsPeriodInit(int _shift);   ;
   // gen levels
   void              Vip::genVolumesPeriod();
   //extend most recent (2) zone areas
   void              Vip::extendLastBoxZone(int _shift);
   // means of deciding to create new S/R block - thisS/R not contained in last SR
   bool              Vip::notContained();
   // record the levels if find a new zone
   void              Vip::haveNewZone();
   // limit number of historical Zones to operate on
   bool              Vip::reduceNumHistoryZones();
   // drawLine: Draw a S/R zone
   void              Vip::drawZone(const ENUM_TIMEFRAMES tf,double p1,datetime t1, double p2, datetime t2,color clr,long lineWidth,string zoneName);
   // output to terminal
   void              Vip::ToLog(string desc,bool show);
   // delete all element rectangles in this then empty this
   void              Vip::clearElements();
   // check a bar crosses a S/R line - spring
   //setupState        Vip::checkSpring(Tip *_tip, VipElement *_vipe);
   // check a bar crosses a S/R line - upthrust
   //setupState        Vip::checkUpThrust(Tip *_tip, VipElement *_vipe);
   // find percentile bucket belongs
   double            Vip::findBucket();
   // Debug
   void              Vip::printBuckets();
   // get initial rates for init
   bool              Vip::setInitialRatesSequence();
   // process initialisation of levels
   bool              Vip::processLevelBarInit(void);
  };
// +------------------------------------------------------------------+
// | Constructor                                                      |
// +------------------------------------------------------------------+
void              Vip::Vip(

   string _symbol,
   ENUM_TIMEFRAMES _enumHTFPeriod,
   color _clrLine,
   int   _atrVolAppliedPrice,
   int _atrVolPeriod,
   int _minBars,
   int _maxBars,
   int _percentileValue,
   int _nBins,
   int _numVolBeforeDeletionStarts,
   int _nATRsFromHLCalcDisplay,
   bool _useLevel,
   bool _drawLevels,
   bool _condition)
  {
   uniqueLineID=0;
   countIndicatorPulls=0;
   htfShift=-1;
   phtfShift=-1;
   percentile=new Percentile(_nBins,_percentileValue);
   numVolBeforeDeletionStarts=_numVolBeforeDeletionStarts;
   nATRsFromHLCalcDisplay=_nATRsFromHLCalcDisplay;
   FontSize=8;
   FontType="mono";
   symbol=_symbol;
   waveHTFPeriod=_enumHTFPeriod;// time frame of levels being generated
   clrLine=_clrLine;
// percentileValue=_percentileValue;// number of bars surrounding object bar in question to find a minima of crosses: 10,6,5,3, *2* ,4,5,6,7
   drawLevels=_drawLevels;// visually see levells
   useLevel=_useLevel;// Use this Tf for this instrument in calculations
// barsBackLimitMinute=_barsBackLimitMinute;// hard wired for minute period because possible 12288 bars representing One Week of information
   minBarsDebugRun = _minBars;
   maxBarsDebugRun = _maxBars;
// level visual thickness value
   thickness=2;

// -CHART set enum for TF and colour value
   int htfIndex=NULL;
   ENUM_TIMEFRAMES startEnum=NULL;
   if(waveHTFPeriod==PERIOD_CURRENT)
      waveHTFPeriod=ENUM_TIMEFRAMES(Period());
   if(waveHTFPeriod<Period())
     {
      Print("Chart Period: ",Period()," HTFPeriod: ",waveHTFPeriod);
      waveHTFPeriod=ENUM_TIMEFRAMES(Period());
      Print(" HTF Period Set to: ",ENUM_TIMEFRAMES(Period()));
     }
   atrInfo  = new ATRInfo(symbol,waveHTFPeriod,_atrVolPeriod,VOL);
   if(!MQLInfoInteger(MQL_TESTER))
      numRates=CopyRates(symbol,waveHTFPeriod,0,_maxBars,ratesHTF);
   else
     {
      //***** Testing parmameters from ST fed to ratesHTFArray *****
      //Will Auto Download the History Data it needs to do a run
      //According to the parameters you give it in CopyRates - dates or counts
      int maxBarsRun = 10000;
      numRates=CopyRates(symbol,waveHTFPeriod,0,maxBarsRun,ratesHTF);
     }
   ArraySetAsSeries(ratesHTF,true);
  }
// +------------------------------------------------------------------+
// | Destructor                                                       |
// +------------------------------------------------------------------+
void Vip::                ~Vip()
  {
   delete(atrInfo);
   delete(percentile);
   Clear();
  }
// +------------------------------------------------------------------+
// | processLevelBarInit:                                             |
// +------------------------------------------------------------------+
bool              Vip::processLevelBarInit(void)
  {
   int sBar = -1;
// Number of Bars to operate on for this update
   int bHTFChart=Bars(symbol,waveHTFPeriod);
   if(maxBarsDebugRun!=0)
      sBar=MathMin(bHTFChart,maxBarsDebugRun);
   else
      sBar=bHTFChart;
   MqlRates localRates[];
   sBar=CopyRates(symbol,waveHTFPeriod,0,sBar,localRates);
   ArraySetAsSeries(localRates,true);
   if(sBar<=0)
     {
      Print(__FUNCTION__,"INFO: :********  NO DATA BARS COPIED INTO Rates Array ******************");
      return false;
     }
   for(shift=sBar-2; shift>=0; shift--)
     {
      htfShift=iBarShift(symbol,waveHTFPeriod,localRates[shift].time,true);
      phtfShift=iBarShift(symbol,waveHTFPeriod,localRates[shift+1].time,true);
      if((phtfShift!=-1) && (htfShift!=-1) && (shift+1!=-1))
         genLevelsPeriodInit(shift);
     }// for rates
   ChartRedraw();
   return true;
  }
// +------------------------------------------------------------------+
// | genVolumesPeriod:                                                |
// +------------------------------------------------------------------+
void Vip::genLevelsPeriodInit(int _shift)
  {
// Number of Bars to operate on for this update
   barsHTFChart=Bars(symbol,waveHTFPeriod);
   if(maxBarsDebugRun!=0)
      startBar=MathMin(barsHTFChart,maxBarsDebugRun);
   else
      startBar=barsHTFChart;
   startBar=CopyRates(symbol,waveHTFPeriod,_shift,startBar,percentile.ratesHTF);
   ArraySetAsSeries(percentile.ratesHTF,true);
   if(startBar<=0)
     {
      Print(__FUNCTION__,"INFO: :********  NO DATA BARS COPIED INTO Rates Array ******************");
      return;
     }
// Get latest ATR Value
   int numATRRates = CopyBuffer(atrInfo.atrHandle,0,0,1, atrInfo.atrWrapper.atrValue);
   if(numATRRates <= 0)
     {
      //Print(__FUNCTION__," No ATR value");
      return;
     }

//get lowest and highest tick volume for bars operated on
   double lowestVol=INF;
   double highestVol=0;
   string sName=NULL;
   for(int i=startBar-1; i>=0; i--)
     {
      double thisTickVolume = double(percentile.ratesHTF[i].tick_volume);
      lowestVol=double(MathMin(lowestVol,thisTickVolume));
      highestVol=double(MathMax(highestVol,thisTickVolume));
     }

// record hi / lo volume  for updates
   uLowestVol=lowestVol;
   uHighestVol=highestVol;

// set step increment
   step=(highestVol-lowestVol)/ArraySize(percentile.cumulativeStep);

   int barCount,volumeCount;
   double vol=lowestVol;

// set up the bucket step cumulative values
   for(int stepLevel=ArraySize(percentile.cumulativeStep)-1; stepLevel>=0; stepLevel--)
     {
      percentile.cumulativeStep[stepLevel]=vol;
      vol+=step;
     }
// build percentiles profile
   for(int stepLevel=ArraySize(percentile.cumulativeStep)-1; stepLevel>=0; stepLevel--)
     {
      volumeCount=0.0;
      // iterate ALL bars operated on for a step level)
      for(barCount=startBar-1; barCount>=0; barCount--)
        {
         //  special case
         if((stepLevel == 0) &&
            (percentile.ratesHTF[barCount].tick_volume >= percentile.cumulativeStep[stepLevel]))
            volumeCount+=1;
         else
            if((percentile.ratesHTF[barCount].tick_volume >= percentile.cumulativeStep[stepLevel]) &&
               (percentile.ratesHTF[barCount].tick_volume <= percentile.cumulativeStep[stepLevel-1]))
               volumeCount+=1;
        }
      // record the increse in number of volumes at that bucket
      percentile.bucketCount[stepLevel]=volumeCount;
     }
// check if new zone has to be recorded
   haveNewZone();
//   datetime t = this.percentile.ratesHTF[1].time;
   extendLastBoxZone(_shift);
  }
// +------------------------------------------------------------------+
// | genVolumesPeriod:                         |
// +------------------------------------------------------------------+
void Vip::genVolumesPeriod()
  {
// Number of Bars to operate on for this update
   barsHTFChart=Bars(symbol,waveHTFPeriod);
   if(maxBarsDebugRun!=0)
      startBar=MathMin(barsHTFChart,maxBarsDebugRun);
   else
      startBar=barsHTFChart;
   startBar=CopyRates(symbol,waveHTFPeriod,0,startBar,percentile.ratesHTF);
   ArraySetAsSeries(percentile.ratesHTF,true);
   if(startBar<=0)
     {
      Print(__FUNCTION__,"INFO: :********  NO DATA BARS COPIED INTO Rates Array ******************");
      return;
     }

// Get latest ATR Value
   int numATRRates = CopyBuffer(atrInfo.atrHandle,0,0,1, atrInfo.atrWrapper.atrValue);
   if(numATRRates <= 0)
     {
      Print(__FUNCTION__," No ATR value");
      return;
     }

//get lowest and highest tick volume for bars operated on
   double lowestVol=INF;
   double highestVol=0;
   string sName=NULL;
   for(int i=startBar-1; i>=0; i--)
     {
      double thisTickVolume = double(percentile.ratesHTF[i].tick_volume);
      lowestVol=double(MathMin(lowestVol,thisTickVolume));
      highestVol=double(MathMax(highestVol,thisTickVolume));
     }

// record hi / lo volume  for updates
   uLowestVol=lowestVol;
   uHighestVol=highestVol;

// set step increment
   step=(highestVol-lowestVol)/ArraySize(percentile.cumulativeStep);

   int barCount,volumeCount;
   double vol=lowestVol;

// set up the bucket step cumulative values
   for(int stepLevel=ArraySize(percentile.cumulativeStep)-1; stepLevel>=0; stepLevel--)
     {
      percentile.cumulativeStep[stepLevel]=vol;
      vol+=step;
     }
// build percentiles profile
   for(int stepLevel=ArraySize(percentile.cumulativeStep)-1; stepLevel>=0; stepLevel--)
     {
      volumeCount=0.0;
      // iterate ALL bars operated on for a step level)
      for(barCount=startBar-1; barCount>=0; barCount--)
        {
         //  special case
         if((stepLevel == 0) &&
            (percentile.ratesHTF[barCount].tick_volume >= percentile.cumulativeStep[stepLevel]))
            volumeCount+=1;
         else
            if((percentile.ratesHTF[barCount].tick_volume >= percentile.cumulativeStep[stepLevel]) &&
               (percentile.ratesHTF[barCount].tick_volume <= percentile.cumulativeStep[stepLevel-1]))
               volumeCount+=1;
        }
      // record the increse in number of volumes at that bucket
      percentile.bucketCount[stepLevel]=volumeCount;
     }
// check if new zone has to be recorded
   haveNewZone();
//   datetime t = this.percentile.ratesHTF[1].time;
   extendLastBoxZone(1);
  }
// +------------------------------------------------------------------+
// |  notContained                                                    |
// |  means of  deciding on creation of S/R box                       |
// +------------------------------------------------------------------+
bool Vip::notContained()
  {
   double   checkLow    = percentile.ratesHTF[1].low;
   double   checkHigh   = percentile.ratesHTF[1].high;
   long     checkVol    = percentile.ratesHTF[1].tick_volume;
   VipElementPair *vipep = GetLastNode();
   if(CheckPointer(vipep) != POINTER_INVALID)
     {
      double lastSRLow = vipep.support.level;
      double lastSRHigh =  vipep.resistance.level;
      long   lastVol       =  vipep.tickVolume;
      if((checkLow >= lastSRLow) && (checkHigh <= lastSRHigh) &&(checkVol < lastVol))
         return false;
      return true;
     }
   return false;
  }
// +------------------------------------------------------------------+
// |  calculateZones                                                |
// |  record the levels if a minima is found                          |
// +------------------------------------------------------------------+
void Vip::haveNewZone()
  {
   percentile.percentileThreshhold = findBucket();
// printBuckets();
   if(percentile.percentileThreshhold == -1)
      Print(__FUNCTION__," error in return from find bucket");

//  double atrValue         = atrInfo.atrWrapper.atrValue[0];
//  double lowerPriceBound  = percentile.ratesHTF[1].low  - (nATRsFromHLCalcDisplay * atrValue);
//  double upperPriceBound  = percentile.ratesHTF[1].high + (nATRsFromHLCalcDisplay * atrValue);

// check initial conditions && draw high and low levels for this ratessHTF if greater than threshold value
   bool proceed = false;
   VipElementPair *vipep =GetLastNode();
   if(CheckPointer(vipep)== NULL)
      proceed = percentile.ratesHTF[1].tick_volume > percentile.percentileThreshhold;
   else
      proceed = (percentile.ratesHTF[1].tick_volume > percentile.percentileThreshhold) && notContained();
   if(proceed)
     {
      datetime priorTime = percentile.ratesHTF[1].time;
      datetime lastTime = percentile.ratesHTF[1].time;
      //draw and add support resistance
      uniqueLineID++;
      string zoneName="level_Zone"+EnumToString(waveHTFPeriod)+"_"+string(uniqueLineID);
      drawZone(waveHTFPeriod,percentile.ratesHTF[1].low,priorTime,percentile.ratesHTF[1].high,lastTime,clrLine,thickness,zoneName);
      //will be sorted by
      VipElementPair *vipePair = new VipElementPair(zoneName,zoneName+"TFText",percentile.ratesHTF[1].low, percentile.ratesHTF[1].high, percentile.ratesHTF[1].tick_volume);
      this.Add(vipePair);
     }
//reduceNumHistoryZones();
// (ASC: mode=0 passed to Sort: small at top of queue ASC)
// this.Sort(0);
// this.ToLog("After",true);
// this.Sort(1);
// this.ToLog("After",true);
  }
// +------------------------------------------------------------------+
// |  reduceNumHistoryZones                                           |
// |  nly operate on last ? 10 say                                    |
// +------------------------------------------------------------------+
bool Vip::reduceNumHistoryZones()
  {
   if(this.Total()>=numVolBeforeDeletionStarts)
     {
      //remove from head of queue a zone -> Delete least significant VipElementPair from Vip
      VipElementPair *vipep = GetFirstNode();
      // //Check its not in use at the back of the Tip trend queue before removing
      if(CheckPointer(vipep)!=POINTER_INVALID)
        {
         vipep = this.DetachCurrent();
         ObjectDelete(0,vipep.elementName);
         delete(vipep);
         return true;
        }
      else
         Print(__FUNCTION__," POINTER_INVALID");
     }
   return false;
  }
// +------------------------------------------------------------------+
// |  extendDisplayBoxes                                              |
// |  extend boxes to right                                           |
// +------------------------------------------------------------------+
void Vip::extendLastBoxZone(int _shift)
  {
   if(this.Total() <= 0)
      return;
//  int boxIndex = totalBoxes-1;
   VipElementPair *vipePair = this.GetLastNode();
// update the box right time coordinate and redraw
   if(CheckPointer(vipePair)!=POINTER_INVALID)
     {
      int    point_index=1;    // anchor point index
      // end time
      datetime tda[1];
      CopyTime(this.symbol,this.waveHTFPeriod,_shift,1,tda);
      datetime     time=tda[0];           // anchor point time coordinate
      double       price=vipePair.resistance.level;  //anchor point price level value
      RectanglePointChange(ChartID(),vipePair.elementName,point_index,time,price);          // anchor point price coordinate
      ChartRedraw();
     }
   else
      Print(__FUNCTION__, " POINTER_INVALID");
  }
// +------------------------------------------------------------------+
// |  findBucket                                                      |
// |  find the percentile bucket that contains the                    |
// |  desired percentile of interest                                  |
// +------------------------------------------------------------------+
double Vip::findBucket()
  {
   double volCount = 0;
   double volLimit = percentile.percentileOfInterest * ArraySize(percentile.ratesHTF);
   for(int  bucket = ArraySize(percentile.cumulativeStep)-1; (bucket > 0); bucket--)
     {
      volCount+=percentile.bucketCount[bucket];
      if(volCount >= volLimit)
         return percentile.cumulativeStep[bucket];
     }
   return -1;
  }
// +------------------------------------------------------------------+
// | drawLine: Draw a S/R Line                                        |
// +------------------------------------------------------------------+
void Vip::drawZone(const ENUM_TIMEFRAMES tf,double p1,datetime t1,double p2, datetime t2,color clr,long lineWidth,string zoneName)
  {
   if(drawLevels)
      // create a graphical representation?
     {
      ENUM_LINE_STYLE style=STYLE_DASH; // style of rectangle lines
      RectangleCreate(0,zoneName,0,t1,p1,t2,p2,clr,style,gVip.width,true,gVip.back,gVip.selection,gVip.hidden,gVip.zOrder);
      //ToLog("Contents of Vip: ",true);
      ChartRedraw();
     }
  }
// +------------------------------------------------------------------+
// |clearElements rectangles Display                                                  |
// +------------------------------------------------------------------+
void  Vip::clearElements()
  {
   VipElementPair *ele=NULL;
   int tot=Total();
   for(int ind=0; ind<tot; ind++)
     {
      ele=GetNodeAtIndex(ind);
      ObjectDelete(0,ele.elementName);
     }
// empty the list after deleting the zones
   Clear();
  }
// +------------------------------------------------------------------+
// |To Log                                                            |
// +------------------------------------------------------------------+
void              Vip::ToLog(string desc,bool show)
  {
   if(show)
     {
      VipElementPair *vipep=NULL;
      Print(desc+" in Q: ",this.Total());
      for(int i=0; i<Total(); i++)
        {
         vipep=GetNodeAtIndex(i);
         if(GetPointer(vipep)!=NULL)
            Print(" HTF: ",this.waveHTFPeriod," element Name: ",vipep.elementName,"Support level: ",vipep.support.level,"Resistance level: ",vipep.resistance.level);
         else
            Print(__FUNCTION__," NULL POINTER");
        }
      if(this.Total()>0)
         Print("-------------------------------------------------------------------------------------------------------");
     }
  }
// +------------------------------------------------------------------+
// |  printBuckets                                                    |
// |  Debug Print buckets                                             |
// +------------------------------------------------------------------+
void Vip::printBuckets()
  {
   int countVolumesConsidered=0;
   for(int i = ArraySize(percentile.cumulativeStep)-1; i>=0; i--)
     {
      Print("percentile.cumulativeStep[",i,"]:", percentile.cumulativeStep[i],"count: ",percentile.bucketCount[i]);
      countVolumesConsidered += percentile.bucketCount[i];
     }
   Print("findBucket()@: ",percentile.percentileOfInterest," percentile = ", percentile.percentileThreshhold);
   Print("uLowest: ", uLowestVol, " uHighestVol: ", uHighestVol);
   Print("Total rates sum: ",countVolumesConsidered);
  }
//// +------------------------------------------------------------------+
//// |  checkSpring                                                     |
//// +------------------------------------------------------------------+
//setupState Vip::checkSpring(Tip *_tip, VipElement *_vipe)
//  {
//   MqlRates r1=_tip.rates[1], r2=_tip.rates[2], r3=_tip.rates[3];
//// single candle spring
//   if((r1.low < _vipe.level) && (r1.close >= _vipe.level))
//     {
//      //  check if Demand extremum
//      if(_tip.checkDemandExtremum()==demand)
//        {
//         return setupSpring1;
//        }
//     }
//   return noSetup;
//  }
//// +------------------------------------------------------------------+
//// |  checkUpThrust                                                   |
//// +------------------------------------------------------------------+
//setupState Vip::checkUpThrust(Tip *_tip, VipElement *_vipe)
//  {
//   MqlRates r1=_tip.rates[1], r2=_tip.rates[2], r3=_tip.rates[3];
//// single candle up thrust
//   if((r1.high > _vipe.level) && (r1.close < _vipe.level))
//     {
//      //  check if Supply extremum
//      if(_tip.checkSupplyExtremum()==supply)
//        {
//         return setupUpthrust1;
//        }
//     }
//   return noSetup;
//  }
// +------------------------------------------------------------------+
// |VipElementPair                                                    |
// +------------------------------------------------------------------+
class VipElementPair : public CObject
  {
public:
   string            elementName;
   string            elementText;
   long              tickVolume;
   VipElement        *support;
   VipElement        *resistance;
   // Constructor
   void              VipElementPair::VipElementPair(string _elementName,string _elementText, double _levelSupport,double _levelResistance, long _tickVolume);
   // Destructor
   void              VipElementPair::~VipElementPair();
  };
// +------------------------------------------------------------------+
// |Constructor                                                       |
// +------------------------------------------------------------------+
void                VipElementPair::VipElementPair(string _elementName,string _elementText, double _levelSupport,double _levelResistance, long _tickVolume)
  {
   elementName       =  _elementName;
   elementText       =  _elementText;
   tickVolume        =  _tickVolume;
   support = new VipElement(_elementName,_elementName+"TFText",_levelSupport);
   resistance = new VipElement(_elementName,_elementName+"TFText",_levelResistance);
  }
// +------------------------------------------------------------------+
// |Destructor                                                        |
// +------------------------------------------------------------------+
void VipElementPair::  ~VipElementPair()
  {
   delete(support);
   delete(resistance);
  }
// +------------------------------------------------------------------+
// |VipElement                                                        |
// +------------------------------------------------------------------+
class VipElement : public CObject
  {
public:
   string            elementName;
   string            elementText;
   double            level;
   void              VipElement::VipElement(string _elementName,string _elementText, double _level);
   void              VipElement::~VipElement();
   //  sort by level ASC - not used but reference of sort inmplementation
   int               VipElement::Compare(const CObject *node,const int mode=0)const override;
  };
// +------------------------------------------------------------------+
// |Constructor                                                       |
// +------------------------------------------------------------------+
void VipElement::VipElement(string _elementName,string _elementText, double _level)
  {
   elementName=_elementName;
   elementText=_elementText;
   level=_level;
  }
// +------------------------------------------------------------------+
// |Destructor                                                        |
// +------------------------------------------------------------------+
void VipElement::~VipElement()
  {
  };
// +--------------------------------------------------------------------------------------+
// |Sort Reverse Order by panelXWave if mode = 0                                          |
// +--------------------------------------------------------------------------------------+
int VipElement::Compare(const CObject *node,const int mode=0)const override
  {
   if(mode == 0)
     {
      if(this.level > ((VipElement*)node).level)
         return(1);
      if(this.level < ((VipElement*)node).level)
         return(-1);
     }
   else
      if(mode == 1)
        {
         if(this.level < ((VipElement*)node).level)
            return(1);
         if(this.level > ((VipElement*)node).level)
            return(-1);
        }
   return(0);
  }
// Keep this its how to sort a linked list!
// Vip.ToLog("before",true);
// 1 has been designated the mode for this activity
// Vip.Sort(1);
// Vip.ToLog("After",true);
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
