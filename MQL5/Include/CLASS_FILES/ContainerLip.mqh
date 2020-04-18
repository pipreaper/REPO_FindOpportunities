// +------------------------------------------------------------------+
// |                                                       EXPERT.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                                                  |
// |Cross counts not being incremented on addition of trend line need to look back over the tf of interest if you need this stat but lines are good                                                                  |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      ""
#property strict
#include <Arrays\List.mqh>
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <INCLUDE_FILES\\drawing.mqh>
#include <INCLUDE_FILES\\drawText.mqh>
#include <INCLUDE_FILES\\templateInfo.mqh>
#include <CLASS_FILES\\Global.mqh>
#include <errordescription.mqh>
class Lip;
class LipElement;
Global gLip;
class sumLipElements: public objvector<LipElement>
  {
public:
   void              sumLipElements::ToLog(string desc,bool show);
  };
//+------------------------------------------------------------------+
//|sumLipElements: All Tf Array of levels for instrument             |
//+------------------------------------------------------------------+
void              sumLipElements::ToLog(string desc,bool show)
  {
   if(show)
     {
      int tot = this.Total();
      Print(desc," In Q: ",tot);
      for(int i=0; (i<tot); i++)
        {
         LipElement *lipe=At(i);
         if(lipe!=NULL)
           {
            if(CheckPointer(lipe)!= NULL)
               Print(lipe.elementNameLevel," levelPrice: ",lipe.levelPrice," crossCount: ",lipe.crossCount," minimaFlag: ", lipe.isMinimaFlag);
            else
               Print(__FUNCTION__," NULL POINTER LipLevelElement");
           }
        }
      Print("-------------------------------------------------------------------------------------------------------");
     }
  }
// +------------------------------------------------------------------+
// |ContainerLip:container for Lip's of differing TFs                 |
// +------------------------------------------------------------------+
class ContainerLip : public CList
  {
public:
   sumLipElements    *pSumLipElements;
   void              ContainerLip::ContainerLip();
   void              ContainerLip::~ContainerLip();
   void              ContainerLip::ToLog();
  };
// +------------------------------------------------------------------+
// |Constructor                                                       |
// +------------------------------------------------------------------+
void              ContainerLip::ContainerLip()
  {
  }
// +------------------------------------------------------------------+
// |Destructor                                                        |
// +------------------------------------------------------------------+
void              ContainerLip::~ContainerLip()
  {
  }
// +------------------------------------------------------------------+
// |To Log                                                            |
// +------------------------------------------------------------------+
void              ContainerLip::ToLog()
  {
   for(Lip *i=GetFirstNode(); i!=NULL; i=i.Next())
      Print(i.waveHTFPeriod," ");
   Print("// -----------------------------------------------------// ");
  }
// +------------------------------------------------------------------+
// |DataOnCrosses:number of times a price is crossed in history       |
// +------------------------------------------------------------------+
double  DataOnCrosses[1,1]; //price, #crosses at that price
// +------------------------------------------------------------------+
// |Lip( Level Instrument Period  ): Information about levels (S/R)|
// +------------------------------------------------------------------+
class Lip : public CList
  {
public:
   // -EXTERN VARS
   int               countIndicatorPulls;
   ContainerLip      lipContainer[];
   string            symbol;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   int               hipLopDepth;
   bool              drawLevels;
   double            pointValue;
   int               digits;
   CList;
   // -GLOBAL OBJECT
   int               uniqueLineID;
   color             clrLine;
   double            stepSize;
   int               thickness;
   int               numRates;// Chart Bars
   int               minBars;
   int               maxBars; // if 0 use Maximum history to calculate levels or use backBarLimit number of bars
   MqlRates          ratesHTF[];// contains all ratesHTF (startBar - 1) ->
   int               FontSize;
   string            FontType;
   double            uHighestHigh;
   double            uLowestLow;
   // Holder of shift value of time when calculated locally with CopyTime
   datetime          tda[];
   //Constructor
   void              Lip::Lip(
      ContainerLip *_cl,
      string _symbol,
      ENUM_TIMEFRAMES  _enumHTFPeriod,
      color _clrLine,
      int _minBars,
      int _maxBars,
      int _hipLopDepth,
      bool _drawLevels,
      double _pointValue,
      int   _digits,
      bool &_condition);
   // Destructor
   void              Lip::~Lip();
   // initial genLevelsPeriod: set parms and gen levels
   bool              Lip::genLevelsPeriod();
   // Add new levels if detected new hi / lo in rates progression
   bool              Lip::AddLevelsPeriod(highLowAddType hilo);
   // move a level from bottom to top of levels list
   void              Lip::moveLevelToTop(LipElement * _lipe);
   // calculate levels and display new information
   void              Lip::updateLevelsPeriod();
   //   void              Lip::repositionLevelsDisplay();
   // record the levels if a minima is found
   void              markCreateTrendMinima();
   //  Checking if this is a local minima of crosses around - say: 6 crosses
   bool              Lip::isLow(int thisLevel,int searchDepth);
   // Clean up and remove Display element
   void              Lip::removeLevel(LipElement *lipe);
   // delete all element display lines and zero minima flag
   void              Lip::removeAllDisplayElements();
   // cleanLevels: delete level Lines and indexes if drawn
   void              Lip::destroyAllLevels();
   // output to terminal
   void              Lip::ToLog(string desc,bool show);
   // ignore if level already recorded and its an update
   // bool              isInAlready(double _level);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void            Lip::Lip(
   ContainerLip *_cl,
   string _symbol,
   ENUM_TIMEFRAMES  _enumHTFPeriod,
   color _clrLine,
   int _minBars,
   int _maxBars,
   int _hipLopDepth,
   bool _drawLevels,
   double _pointValue,
   int   _digits,
   bool &_condition)
  {
   countIndicatorPulls=0;
   ArrayResize(lipContainer,1);
   lipContainer[0] = _cl;
   symbol=_symbol;
   waveHTFPeriod=_enumHTFPeriod;// time frame of levels being generated
   pointValue = _pointValue;
   stepSize = -1;
   digits = _digits;
// number of bars surrounding object bar in question to find a minima of crosses: 10,6,5,3, *2* ,4,5,6,7
   hipLopDepth=_hipLopDepth;
   drawLevels=_drawLevels;// visually see levells
   minBars = _minBars;
   maxBars = _maxBars;
   FontSize=8;
   FontType="mono";
   clrLine=_clrLine;
   thickness=2;
// -CHART set enum for TF and colour value
//   int htfIndex=NULL;
//   ENUM_TIMEFRAMES startEnum=NULL;
   if(waveHTFPeriod==PERIOD_CURRENT)
      waveHTFPeriod=ENUM_TIMEFRAMES(Period());
   if(waveHTFPeriod<Period())
     {
      Print("Chart Period: ",Period()," HTFPeriod: ",waveHTFPeriod);
      waveHTFPeriod=ENUM_TIMEFRAMES(Period());
      Print(" HTF Period Set to: ",ENUM_TIMEFRAMES(Period()));
     }
  }
//+------------------------------------------------------------------+
//| Desstructor                                                      |
//+------------------------------------------------------------------+
void Lip::~Lip()
  {
   destroyAllLevels();
  }
// +------------------------------------------------------------------+
// | genLevelsPeriod: set parms and gen levels                        |
// +------------------------------------------------------------------+
bool Lip::genLevelsPeriod()
  {
// need access to inital rates for this symbol TF retrieved successfully in BarFlow.setInitRatesSequence
   if(!MQLInfoInteger(MQL_TESTER))
      numRates=CopyRates(symbol,waveHTFPeriod,0,maxBars,ratesHTF);
   else
     {
      //***** Testing parmameters from ST fed to ratesHTFArray *****
      //Will Auto Download the History Data it needs to do a run
      //According to the parameters you give it in CopyRates - dates or counts
      int maxBarsRun = 10000;
      numRates=CopyRates(symbol,waveHTFPeriod,0,maxBarsRun,ratesHTF);
     }
   ArraySetAsSeries(ratesHTF,true);
   bool condition = true;
//  do whole calculation because new parameters for hi / lo or start of run
   uniqueLineID=0;
// delete all lines and empty the list
// destroyAllLevels();
// Old thinking:  why do the number of levels equal to the number of bars work?? fractions of it produce inferior results
// next calculation is crucial and underpins whole algorithm. maxLevels = numBars works but tryinhg to find better solution
   double lowestLow=INF;
   double highestHigh=0;
// levels in the data set
   double averageBarPoints = 0;
   double totalBarSize = 0;
   for(int i=numRates-1; i>=0; i--)
     {
      lowestLow=MathMin(lowestLow,ratesHTF[i].low);
      highestHigh=MathMax(highestHigh,ratesHTF[i].high);
      totalBarSize += (ratesHTF[i].high-ratesHTF[i].low);
     }
   double averageBarDiff = totalBarSize/(numRates-1);
   int numLevels = int((highestHigh-lowestLow)/averageBarDiff);
// record hi / lo for updates
   uLowestLow=lowestLow;
   uHighestHigh=highestHigh;
   stepSize = (highestHigh-lowestLow)/numLevels;
   double levelValue = lowestLow;
   LipElement *lipe = NULL;
   for(int level=numLevels; level>0; level--)
     {
      levelValue += stepSize;
      uniqueLineID++;
      string elementName="level_"+EnumToString(waveHTFPeriod)+"_"+string(uniqueLineID);
      // Add a new element to the list - needs to hold level value and crosses info
      lipe = new LipElement(elementName, levelValue, waveHTFPeriod);
      this.Add(lipe);
      lipe.startDate=0;
     }
// iterate all levels created(minimum first)
   for(int level=Total()-1; level>=0; level--)
     {
      lipe = GetNodeAtIndex(level);
      // ITERATE ALL BARS HISTORY (oldest first) FOR GIVEN RATE (PRICE LEVEL)
      for(int bar=(ArraySize(ratesHTF)-1); bar>=0; bar--)
        {
         if((lipe.levelPrice>ratesHTF[bar].low) && (lipe.levelPrice<ratesHTF[bar].high))
            lipe.crossCount+=1;
        }
     }
// Already sorted last is highest level @ bottom of Q
//   this.ToLog("Lip Elements",true);
// order list by level
   Sort(0);
// this.ToLog("Lip Elements",true);

//check for higher lower prices in the total levels list
   markCreateTrendMinima();
   ChartRedraw();
// createDisplayLevels();
   return condition;
  }
// +------------------------------------------------------------------+
// |  markCreateTrendMinima                                           |
// |  record the levels if a minima is found                          |
// |  ignore levels already entered into the Lip Q                    |
// +------------------------------------------------------------------+
void Lip::markCreateTrendMinima()
  {
//temp should have own setting passed in
   bool showAllLevels = true;//drawLevels;
   LipElement * lipe = NULL;
   for(int level=Total()-1; level>=0; level--)
     {
      lipe = GetNodeAtIndex(level);
      bool minima=isLow(level, hipLopDepth);
      if(minima)
        {
         int numBars = Bars(symbol,_Period);
         numBars = MathMin(numBars,100);
         int theNum = CopyTime(symbol,_Period,numBars-1,numBars-2,tda);
         lipe.startDate = tda[0];
         CopyTime(symbol,_Period,0,2,tda);
         datetime lastTime=tda[1];// ratesHTF[barSelected].time;
         if(!lipe.isMinimaFlag)
           {
            //  new and not yet realised minima
            if(drawLevels)
              {
               // new level drawn -> first time displayed
               TrendCreate(ChartID(),lipe.elementNameLevel,0,lipe.startDate,lipe.levelPrice,lastTime,lipe.levelPrice,this.clrLine,gLip.style,gLip.width,gLip.back,gLip.selection,gLip.rayRight,gLip.hidden,gLip.zOrder);
               TextCreate(ChartID(),lipe.elementNameText,gLip.subWindow,tda[0],lipe.levelPrice, DoubleToString(lipe.crossCount,0),gLip.fontType,gLip.fontSize,this.clrLine,gLip.angle);
              }
            // add to containerLipe.objectvector
            lipContainer[0].pSumLipElements.Add(lipe);
            lipContainer[0].pSumLipElements.Sort(0);
            lipe.isMinimaFlag=true;
            // ChartRedraw();
           }
         else
           {
            //  already realised minima
            if(drawLevels)
              {
               TrendPointChange(ChartID(),lipe.elementNameLevel,1,tda[1],lipe.levelPrice);
               TextMove(ChartID(),lipe.elementNameText,tda[0],lipe.levelPrice);
              }
           }
        }
      else
         if(showAllLevels)
           {
            // begining time of level
            int numBars = Bars(symbol,_Period);
            numBars = MathMin(numBars,100);
            int theNum = CopyTime(symbol,_Period,numBars-1,numBars-2,tda);
            lipe.startDate = tda[0];

            CopyTime(_Symbol,_Period,0,2,tda);
            datetime lastTime=tda[1];// ratesHTF[barSelected].time;
            if(ObjectFind(ChartID(),lipe.elementNameLevel) <= 0)
              {
               // new level drawn -> first time displayed
               TrendCreate(ChartID(),lipe.elementNameLevel,0,lipe.startDate,lipe.levelPrice,lastTime,lipe.levelPrice,clrMidnightBlue,STYLE_DOT,gLip.width,gLip.back,gLip.selection,gLip.rayRight,gLip.hidden,gLip.zOrder);
               // TextCreate(ChartID(),lipe.elementNameText,gLip.subWindow,tda[0],lipe.levelPrice, DoubleToString(lipe.crossCount,0),gLip.fontType,gLip.fontSize,this.clrLine,gLip.angle);
              }
            else
              {
               // update the level display
               TrendPointChange(ChartID(),lipe.elementNameLevel,1,tda[1],lipe.levelPrice);
               // TextMove(ChartID(),lipe.elementNameText,tda[0],lipe.levelPrice);
              }
           }
     }
//  lipContainer[0].pSumLipElements.Sort(0);
//  lipContainer[0].pSumLipElements.ToLog("sum:",true);
  }
// +------------------------------------------------------------------+
// | AddLevelsPeriod: exchange levels as get new Hi/Lo                |
// +------------------------------------------------------------------+
bool Lip::AddLevelsPeriod(highLowAddType hilo)
  {
// Rates already calculated in update
   int moveLevels = -1;
   double levelValue =-1;
   LipElement *lipe = NULL;
   if(hilo == highType)
     {
      moveLevels = int((ratesHTF[1].high-uHighestHigh)/stepSize)+1;
      if(moveLevels > 0)
        {
         levelValue = uHighestHigh;
         // Change the lowest level values at the top of the queue to new high values and move to bottom of queue through Sort(0)
         for(int level=0; level<moveLevels; level++)
           {
            //    this.ToLog("1 highType moreLevels: "+string(moveLevels),true);
            // remove node with lowest level value at top of Q
            lipe = GetFirstNode();
            // remove chart element if exists
            this.removeLevel(lipe);
            // find in containerQ and delete from that if it exists
            int isFound = lipContainer[0].pSumLipElements.Search(lipe);
            if(isFound>=0)
              {
               lipContainer[0].pSumLipElements.Detach(isFound);
               lipContainer[0].pSumLipElements.Sort(0);
              }
            this.Delete(0);
            //      this.ToLog("2 highType moreLevels: "+string(moveLevels),true);
            levelValue += stepSize;
            uniqueLineID++;
            string elementName="level_"+EnumToString(waveHTFPeriod)+"_"+string(uniqueLineID);
            // Add a new element to the list - needs to hold level value and crosses info
            this.Insert(new LipElement(elementName, levelValue, waveHTFPeriod),Total());
            //     this.ToLog("3 highType moreLevels: "+string(moveLevels),true);
            int dummy =1;
           }
         uHighestHigh = levelValue;
        }
      else
        {
         DebugBreak();
         return false;
        }
     }
   else
      if(hilo == lowType)
        {
         moveLevels = int((uLowestLow-ratesHTF[1].low)/stepSize)+1;
         if(moveLevels > 0)
           {
            levelValue = uLowestLow;
            for(int level=0; (level < moveLevels); level++)
              {
               //       this.ToLog("1 lowType moreLevels: "+string(moveLevels),true);
               // remove node with lowest level value at top of Q
               lipe = GetLastNode();
               // remove chart element if exists
               this.removeLevel(lipe);
               // find in containerQ and delete from that if it exists
               int isFound = lipContainer[0].pSumLipElements.Search(lipe);
               if(isFound>=0)
                 {
                  lipContainer[0].pSumLipElements.Detach(isFound);
                  lipContainer[0].pSumLipElements.Sort(0);
                 }
               // find in containerQ and delete from that if it exists
               this.Delete(Total()-1);
               //      this.ToLog("2 lowType moreLevels: "+string(moveLevels),true);
               levelValue -= stepSize;
               uniqueLineID++;
               string elementName="level_"+EnumToString(waveHTFPeriod)+"_"+string(uniqueLineID);
               this.Insert(new LipElement(elementName, levelValue, waveHTFPeriod),0);
               //     this.ToLog("3 lowType moreLevels: "+string(moveLevels),true);
               int dummy =1;
              }
            uLowestLow = levelValue;
           }
         else
           {
            DebugBreak();
            return false;
           }
        }
//  this.ToLog("end: "+EnumToString(hilo),true);
   return true;
  }
// +------------------------------------------------------------------+
// | updateLevelsPeriod: set parms and gen levels                     |
// +------------------------------------------------------------------+
void Lip::updateLevelsPeriod()
  {
   numRates=CopyRates(symbol,waveHTFPeriod,0,maxBars,ratesHTF);
   if(numRates<minBars)
     {
      Print(__FUNCTION__," Error copying price data: Max bars Available from current date is: ",numRates," You state required minimum is: ",minBars, " ", ErrorDescription(GetLastError()));
      return;
     }
// Need to add another lower level?
   if(ratesHTF[1].low<uLowestLow)
     {
      CopyTime(_Symbol,_Period,0,1,tda);
      // Print(__FUNCTION__, " ** ADDING LEVELS: ",symbol," HTF Updated: ", waveHTFPeriod," On Chart: ",Period(), " High: ",uHighestHigh, " Low: ", uLowestLow," Time Now: ",tda[0]);
      if(!AddLevelsPeriod(lowType))
        {
         Print(__FUNCTION__," Failed to Add new lowType levels");
         return;
        }
     }
//  Need to add another higher level?
   else
      if(ratesHTF[1].high>uHighestHigh)
        {
         if(!AddLevelsPeriod(highType))
           {
            Print(__FUNCTION__," Failed to Add new highType levels");
            return;
           }
        }
   ArraySetAsSeries(ratesHTF,true);
// calculate minima and update display
   markCreateTrendMinima();
//  if(drawLevels)
//    repositionLevelsDisplay();
  }
// +------------------------------------------------------------------+
// | redraw levels at new time of rates[0]                            |
// +------------------------------------------------------------------+
//void Lip::repositionLevelsDisplay()
//  {
//   CopyTime(symbol,_Period,0,2,tda);
//   datetime lastTime=tda[1];// ratesHTF[barSelected].time;
//   for(int level=Total()-1; level>=0; level--)
//     {
//      LipElement *lipe = GetNodeAtIndex(level);
//      TrendPointChange(ChartID(),lipe.elementNameLevel,1,tda[1],lipe.levelPrice);
//      TextMove(ChartID(),lipe.elementNameText,tda[0],lipe.levelPrice);
//     }
//  }
// +----------------------------------------------------------------------------------------------------------------------+
// |  isLow                                                                                                               |
// |  Checking if this is a local minima of crosses around - say: 6 crosses                                               |
// +----------------------------------------------------------------------------------------------------------------------+
bool Lip::isLow(int level,int searchDepth)
  {
// need to set defaults for unfound levels at extremums?
   LipElement *lipe   =  GetNodeAtIndex(level);
   LipElement *plipe  =  NULL;
   LipElement *nlipe  =  NULL;
   for(int i=1; i<searchDepth-1; i++)
     {
      plipe  =  GetNodeAtIndex(level-i);
      nlipe  =  GetNodeAtIndex(level+i);
      if((CheckPointer(lipe)!=POINTER_INVALID)&&(CheckPointer(plipe)!=POINTER_INVALID)&&(CheckPointer(nlipe)!=POINTER_INVALID))
        {
         if((lipe.crossCount<plipe.crossCount) && (lipe.crossCount<nlipe.crossCount))
            continue;
         return false;
        }
      else
         return false;
     }
   return true;
  }
// +------------------------------------------------------------------+
// |cleanOneDisplayElements                                           |
// +------------------------------------------------------------------+
void  Lip::removeLevel(LipElement *_lipe)
  {
   if(ObjectFind(ChartID(),_lipe.elementNameLevel)>=0)
     {
      ObjectDelete(ChartID(),_lipe.elementNameLevel);
      ObjectDelete(ChartID(),_lipe.elementNameText);
     }
  }
// +------------------------------------------------------------------+
// |removeAllDisplayElements                                          |
// +------------------------------------------------------------------+
void  Lip::removeAllDisplayElements()
  {
   LipElement *ele=NULL;
   int tot=Total();
   for(int ind=0; ind<tot; ind++)
     {
      ele=GetNodeAtIndex(ind);
      if(CheckPointer(ele)!=NULL)
        {
         ele.isMinimaFlag=false;
         if(drawLevels)
           {
            ObjectDelete(0,ele.elementNameLevel);
            ObjectDelete(0,ele.elementNameText);
           }
        }
     }
  }
// +------------------------------------------------------------------+
// | cleanLevels: delete level Lines and indexes if drawn             |
// | Called in deinit                                                 |
// +------------------------------------------------------------------+
void Lip::destroyAllLevels()
  {
   removeAllDisplayElements();
// empty the list after deleting the lines
   Clear();
  }
// +------------------------------------------------------------------+
// |To Log                                                            |
// +------------------------------------------------------------------+
void              Lip::ToLog(string desc,bool show)
  {
   if(show)
     {
      LipElement *lipe=NULL;
      Print(desc+" in Q: ",this.Total());
      for(int i=Total()-1; i >= 0; i--)
        {
         lipe=GetNodeAtIndex(i);
         if(GetPointer(lipe)!=NULL)
            Print(" HTF: ",this.waveHTFPeriod," levelPrice: ",lipe.levelPrice," crossCount: ",lipe.crossCount," minimaFlag: ", lipe.isMinimaFlag);
         else
            Print(__FUNCTION__," NULL POINTER LipLevelElement");
        }
      Print("-------------------------------------------------------------------------------------------------------");
     }
  }
// +------------------------------------------------------------------+
// |LipElement                                                        |
// +------------------------------------------------------------------+
class LipElement : public CObject
  {
public:
   bool              isMinimaFlag;
   string            elementNameLevel;
   string            elementNameText;
   double            levelPrice;
   double            crossCount;
   datetime          startDate;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   void              LipElement::LipElement(string _elementName, double _levelPrice, ENUM_TIMEFRAMES _waveHTFPeriod);
   void              LipElement::~LipElement();
   //  sort by level ASC
   virtual int               LipElement::Compare(const CObject *node,const int mode=0)const override;
  };
// +--------------------------------------------------------------------------------------+
// |Constructor                                                                           |
// +--------------------------------------------------------------------------------------+
void   LipElement::LipElement(string _elementName, double _levelPrice, ENUM_TIMEFRAMES _waveHTFPeriod)
  {
   startDate         =  0;
   isMinimaFlag      =  false;
   elementNameLevel  =  _elementName;
   waveHTFPeriod     =  _waveHTFPeriod;
   elementNameText   =  _elementName+"Text";
   levelPrice        =  _levelPrice;
   crossCount        =  0;
  }
// +--------------------------------------------------------------------------------------+
// |Destructor                                                                            |
// +--------------------------------------------------------------------------------------+
void             LipElement::~LipElement() {}
// +--------------------------------------------------------------------------------------+
// |Sort Reverse Order by panelXWave if mode = 0                                          |
// +--------------------------------------------------------------------------------------+
int LipElement::Compare(const CObject *node,const int mode=0)const override
  {
   if(mode == 0)
     {
      if(this.levelPrice > ((LipElement*)node).levelPrice)
         return(1);
      if(this.levelPrice < ((LipElement*)node).levelPrice)
         return(-1);
     }
   else
      if(mode == 1)
        {
         if(this.levelPrice < ((LipElement*)node).levelPrice)
            return(1);
         if(this.levelPrice > ((LipElement*)node).levelPrice)
            return(-1);
        }
   return(0);
  }
// Keep this its how to sort a linked list!
// Lip.ToLog("before",true);
// 1 has been designated the mode for this activity
// Lip.Sort(1);
// Lip.ToLog("After",true);
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
