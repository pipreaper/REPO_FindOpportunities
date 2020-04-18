// +------------------------------------------------------------------+
// |                                                  conghistObj.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                            https:// www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https:// www.mql5.com"
#property version   "1.01"
#property strict
#include <Arrays\List.mqh>
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include <\\INCLUDE_FILES\\drawing.mqh>
#include    <INCLUDE_FILES\\GetBrokerSymbolTFData.mqh>
// +------------------------------------------------------------------+
// |adHistObj:List containing ADipElement's                           |
// |contains elements with information on arrow and object for        |
// |Accumulation Distribution Candles                                 |
// +------------------------------------------------------------------+
// forward declarations
class ADipElement;
class ADip;
// +------------------------------------------------------------------+
// |adContainerPeriodsObj                                             |
// +------------------------------------------------------------------+
class ContainerADip : public CList
  {
public:
   direcxion         adSuStateLong;
   direcxion         adSuStateShort;
   void              ContainerADip(direcxion tsSuLong,direcxion tsSuShort);
   bool              setCumulativeAdSuStates();
   void              setAdSuStateLong(direcxion _dir);
   void              setAdSuStateShort(direcxion _dir);
   void              setAdSuStateNull();
   direcxion         getAdSuStateLong();
   direcxion         getAdSuStateShort();
   // +--------------------------------------------------------------+
   // |To Log                                                        |
   // +--------------------------------------------------------------+
   void              ToLog()
     {
      for(ADip *i=GetFirstNode(); i!=NULL; i=i.Next())
         // Print(i.waveHTFPeriod," ");
         Print("// -----------------------------------------------------// ");
     }
  };
// +------------------------------------------------------------------+
// | ADip                                                      |
// +------------------------------------------------------------------+
class ADip : public CList
  {
public:
   // PASSED
   string            symbol;
   ENUM_TIMEFRAMES   waveHTFPeriod;
   int               chartPeriod;
   double            fracADCandle;
   int               datumCandlesToExpire;
   bool              showAD;
   int               htfShift;
   int               phtfShift;
   // bar identifier
   int               shift;
   static int        uniqueID;
   color             clrLine;
   // INTERNAL
   MqlRates          rates[];
   int               minBarsDegugRun;
   int               maxBarsDegugRun;
   //  int               ratesSize;

                     ADip(
      string _symbol,
      ENUM_TIMEFRAMES _waveHTFPeriod,
      int _minBarsDegugRun,
      int _maxBarsDegugRun,
      int _chartPeriod,
      double _fracADCandle,
      int _datumCandlesToExpire,
      bool _showAD,
      bool &_condition)
     {
      // EXTERNAL
      symbol=_symbol;
      waveHTFPeriod=_waveHTFPeriod;
      chartPeriod=_chartPeriod;
      fracADCandle=_fracADCandle;
      datumCandlesToExpire=_datumCandlesToExpire;
      showAD=_showAD;
      // INTERNAL
      int htfIndex=findWTFIndex(waveHTFPeriod,NULL);
      // * Set up rates[] for this HTF Here we set to all bars or just the last 1000
      ArrayResize(rates,1);
      minBarsDegugRun = _minBarsDegugRun;
      maxBarsDegugRun=_maxBarsDegugRun;
      //Get Rates
      if(!setInitialRatesSequence())
        {
         _condition  = false;
         return;
        }
      // shift=ratesSize;
      // array numbered left large -> zero
      ArraySetAsSeries(rates,true);
      initAdBars();
     }
   // +------------------------------------------------------------------+
   // | ~ADip                                                     |
   // +------------------------------------------------------------------+
                    ~ADip()
     {
      ADipElement *adhe=NULL;
      for(int i=0; i<Total(); i++)
        {
         // Need to delete the arrows for AD
         // Need delete system objects too
         adhe=GetNodeAtIndex(i);
         if(showAD)
            ArrowDelete(0,adhe.arrowName);
         ObjectDelete(0,adhe.objName);
        }
      Clear();
     }
   // +------------------------------------------------------------------+
   // |setInitialRatesSequence                                           |
   // +------------------------------------------------------------------+
   bool              setInitialRatesSequence()
     {
      int copied=-1;
      if(!MQLInfoInteger(MQL_TESTER))
      //  {
      //   // Difference is that debug unlike a strategy tester run DOES NOT AUTO download the history
      //   // So you have to do it to get the program to run by navigate front and back of history data
      //   if(!getUpdatedHistory(symbol,waveHTFPeriod,minBarsDegugRun,maxBarsDegugRun))
      //     {
      //      Print("Failed to Navigate data from charts");
      //   //   DebugBreak();
      //      return false;
      //     }
      //   copied=CopyRates(symbol,waveHTFPeriod,0,maxBarsDegugRun,rates);
      //   if(copied<=minBarsDegugRun)
      //     {
      //      Print("Error copying price data: Max bars Available from current date is: ",copied," You want at least: ",minBarsDegugRun, " ", ErrorDescription(GetLastError()));
      ////      DebugBreak();
      //      return false;
      //     }
      //  }
      //else
      //  {
      //   //***** Testing parmameters from ST fed to ratesArray *****
      //   //Will Auto Download the History Data it needs to do a run
      //   //According to the parameters you give it in CopyRates - dates or counts
      //   int maxBarsTester = 10000;
      //   copied=CopyRates(symbol,waveHTFPeriod,0,maxBarsTester,rates);
      //   if(copied<=minBarsDegugRun)
      //     {
      //      Print("Error copying price data: Max bars Available from current date is: ",copied," You want at least: ",minBarsDegugRun, " ", ErrorDescription(GetLastError()));
      //      // DebugBreak();
      //      return false;
      //     }
      //  }
      Print("AD Copied ",ArraySize(rates)," bars");
      ArraySetAsSeries(rates,true);
      Print("AD Newest :",rates[0].time, "AD Oldest :", rates[copied-1].time);
      return true;
     }
   // +---------------------------------------------------------------------+
   // |processInitAdBar()                                                |
   // |1/. Initialising new Bars OnInit()                                   |
   // +---------------------------------------------------------------------+
   void              initAdBars()
     {
      for(shift=ArraySize(rates)-2; shift>=0; shift--)
        {
         htfShift=iBarShift(symbol,waveHTFPeriod,rates[shift].time,true);
         phtfShift=iBarShift(symbol,waveHTFPeriod,rates[shift+1].time,true);
         if((phtfShift!=-1) && (htfShift!=-1) && (shift+1!=-1) && (shift<=datumCandlesToExpire))
           {
            // checkAdStatus of new bar and add to list
            direcxion accDist=checkAddAD(rates[shift+1].high,rates[shift+1].low,rates[shift+1].open,rates[shift+1].close);
            if(accDist!=none)
               createNewAD(accDist,rates[shift+1].time,clrLine,rates[shift+1].low,rates[shift+1].high,showAD);
            // Always update the ADip list of elements
            updateAdElements();
           }
        }// for rates
      // Print(__FUNCTION__," symbol ",symbol," waveHTFPeriod ",waveHTFPeriod," ratesSize ",ratesSize," shift ",shift);
      // ArrayFree(rates);
     }
   // +--------------------------------------------------------------------------------------+
   // |runAdTick()                                                                        |
   // |1/. Its a new chart Bar for HTF under consideration                                   |
   // |2/. establish up to date rates array                                                  |
   // +--------------------------------------------------------------------------------------+
   bool              runAdTick()
     {
      int numRates=1;// MathMax(maxBackChartTFCheck,Bars(symbol,waveHTFPeriod));
      ArrayResize(rates,1);
      int localRateNum=NULL;
      int cnt=0;
      do
        {
         if(CopyRates(symbol,waveHTFPeriod,0,2,rates)==2)
            break;
         cnt+=1;
         if(cnt>30)
           {
            Print(__FUNCTION__," ",symbol," ",waveHTFPeriod," failed to get Rates");
            return false;
           }
         Sleep(1);
        }
      while(localRateNum<2);
      ArraySetAsSeries(rates,true);
      // Process Ad Bar called when HTF has a new bar
      shift=0;
      htfShift=iBarShift(symbol,waveHTFPeriod,rates[shift].time,true);
      phtfShift=iBarShift(symbol,waveHTFPeriod,rates[shift+1].time,true);
      if((phtfShift!=-1) && (htfShift!=-1) && (shift+1!=-1))
        {
         direcxion accDist=checkAddAD(rates[1].high,rates[1].low,rates[1].open,rates[1].close);
         if(accDist!=none)
            createNewAD(accDist,rates[1].time,clrLine,rates[1].low,rates[1].high,showAD);
         // Always update the ADip list of elements
         updateAdElements();
        }
      // Print(__FUNCTION__," ",symbol," ",waveHTFPeriod," Tickety Boo");
      return true;
     }
   // +------------------------------------------------------------------+
   // |updateAdPeriod: Update the status of old Ad arrows                |
   // |add any new ones                                                  |
   // +------------------------------------------------------------------+
   void              updateAdElements()
     {
      // Update the arrows that are current
      ADipElement *adEle=NULL;
      int tot=this.Total();
      for(int i=0; (i<tot); i++)
        {
         adEle=GetNodeAtIndex(i);
         if((GetPointer(adEle)!=NULL))
           {
            adEle=GetNodeAtIndex(i);
            // Always Decrement the time to live
            adEle.adTimeToLiveCandles=adEle.adTimeToLiveCandles-1;
            // Only report last 20 for init and production(ticks)
            if(adEle.adTimeToLiveCandles<=0)
               // remove all reference to this arrow it is spent
               removeADExpired(adEle);
           }// GetPointer
        }// for
     }
   // +------------------------------------------------------------------+
   // |                                                                  |
   // +------------------------------------------------------------------+
   bool              createNewAD(direcxion vector,datetime _time,color _clr,double _l,double _h,bool _showAD)
     {
      ENUM_ARROW_ANCHOR UDArrow=NULL;
      double price=NULL;
      uchar arrowCode=NULL;
      uniqueID++;
      if(vector==supply)
        {
         price=_l;
         UDArrow=ANCHOR_BOTTOM;
         arrowCode=absoluteDownArrow;
        }
      else
         if(vector==demand)
           {
            price=_h;
            UDArrow=ANCHOR_TOP;
            arrowCode=absoluteUpArrow;
           }
         else
            return false;
      string objName="AD_"+string(uniqueID);
      string arrowName="arrow_"+objName;
      ADipElement *adeo=new ADipElement(waveHTFPeriod,objName,arrowName,_time,price,_h,_l,vector,datumCandlesToExpire,_clr,arrowCode,UDArrow,_showAD);
      Add(adeo);
      return true;
     }
   // +------------------------------------------------------------------+
   // |removeADExpired: remove elements that are greater than            |
   // |adExpiredLength                                                   |
   // +------------------------------------------------------------------+
   void              removeADExpired(ADipElement *adhe)
     {
        {
         if(GetPointer(adhe)!=NULL)
           {
            // delete arrow
            if(showAD)
               ArrowDelete(0,adhe.arrowName);
            // delete Object in List ADipElement
            this.setADCurrent(adhe);
            this.DeleteCurrent();
            // ToLog("ad after: "+string(expiredTime),true);
           }
         else
            Print(__FUNCTION__," NULL POINTER ADipElement");
        }
     }
   // +------------------------------------------------------------------+
   // | checkAddAD                                                       |
   // +------------------------------------------------------------------+
   direcxion         checkAddAD(double _h,double _l,double _o,double _c)
     {
      if(_h==_l)
         return none;
      double minOC = MathMin(_o,_c);
      double maxOC = MathMax(_o,_c);
      // demand logic for candle
      if(((_h-minOC)/(_h -_l))<=fracADCandle)
         return demand;
      // supply logic for candle
      else
         if(((maxOC -_l)/(_h -_l))<=fracADCandle)
            return supply;
         else
            return none;
     }
   // +--------------------------------------------------------------------------------------+
   // |setADCurrent                                                                          |
   // +--------------------------------------------------------------------------------------+
   bool              setADCurrent(ADipElement *c)
     {
      this.m_curr_node=c;
      if(CheckPointer(m_curr_node)!=POINTER_INVALID)
         return true;
      else
         return false;
     }
   // +------------------------------------------------------------------+
   // |To Log: last node to print is most current                        |
   // +------------------------------------------------------------------+
   void              ToLog(string desc,bool show)
     {
      if(show)
        {
         ADipElement *ade=NULL;
         Print(desc+" Total in Q ",waveHTFPeriod," : ",this.Total());
         for(int i=0; i<Total(); i++)
           {
            ade=this.GetNodeAtIndex(i);
            if(GetPointer(ade)!=NULL)
               Print(__FUNCTION__," ",i," price: ",ade.price," time: ",ade.time," vector: ",ade.vector);
            else
               Print(__FUNCTION__," NULL POINTER adHistEleObj");
           }
        }
     }
  };
// +------------------------------------------------------------------+
// | ContainerADip parametric constructor                              |
// +------------------------------------------------------------------+
ContainerADip::ContainerADip(direcxion _adSuStateLong,direcxion _adSuStateShort)
  {
// adSuStateLong=_adSuStateLong;
// adSuStateShort=_adSuStateShort;
  }
// // +------------------------------------------------------------------+
// // | setTrendSuState                                                  |
// // | Check the ads are all up/down ads. If any adperiodObj   |
// // | is false then the ad setup is false for the whole set up      |
// // +------------------------------------------------------------------+
// bool ContainerADip::setCumulativeAdSuStates()
// {
// // leave if found matches... only need to find one of each to  leave
// // or go through whole method to establish which ad are available demand and supply
// bool setLong=false,setShort=false;
// for(int thisAd=this.Total()-1;(thisAd>=0); thisAd--)
// {
// ADip *ad=this.GetNodeAtIndex(thisAd);
// for(int thisAde=this.Total()-1;(thisAde>=0); thisAde--)
// {
// ADipElement *ade=ad.GetNodeAtIndex(thisAde);
// direcxion _dir=ade.vector;
// if(_dir==supply)
//   {
//    this.setAdSuStateLong(_dir);
//    setLong=true;
//   }
// else if(_dir==demand)
//   {
//    this.setAdSuStateShort(_dir);
//    setShort=true;
//   }
// if(setShort && setLong)
//    return false;
// }
// }
// // After completion of loop
// // failure state - have no matches
// if(!setShort && !setLong)
// return true;
// else
// // found at least one match
// return false;
// }
// // +------------------------------------------------------------------+
// // | ContainerADip::setAdSuStateShort                                 |
// // +------------------------------------------------------------------+
// void ContainerADip::setAdSuStateShort(direcxion _dir)
// {
// adSuStateShort=_dir;
// }
// // +------------------------------------------------------------------+
// // | ContainerADip::setAdSuStateLong                                  |
// // +------------------------------------------------------------------+
// void ContainerADip::setAdSuStateLong(direcxion _dir)
// {
// adSuStateLong=_dir;
// }
// // +------------------------------------------------------------------+
// // | getTrendSuStateLong                                              |
// // +------------------------------------------------------------------+
// direcxion ContainerADip::getAdSuStateLong()
// {
// return adSuStateLong;
// }
// +------------------------------------------------------------------+
// | setTrendSuStateNull                                              |
// +------------------------------------------------------------------+
void ContainerADip::setAdSuStateNull()
  {
// reset the ad to have no held state
   adSuStateLong=initialAdState;
   adSuStateShort=initialAdState;
  }
// +------------------------------------------------------------------+
// | congestionHistObj: rectangle of congestion while not trending    |
// | time1, price1 are start and minimum values                       |
// | time2, price2 are end and max values                             |
// +------------------------------------------------------------------+
class ADipElement : public CObject
  {
public:
   ENUM_TIMEFRAMES   waveHTFPeriod;
   string            objName;
   string            arrowName;
   double            price;
   double            high;
   double            low;
   direcxion         vector;
   int               adTimeToLiveCandles;
   datetime          expiration;
   datetime          time;
   color             clr;
   ENUM_ARROW_ANCHOR UDArrow;
   uchar             arrowCode;
   int               fSize;
   string            font;
                     ADipElement(
      ENUM_TIMEFRAMES _waveHTFPeriod,
      string _objName,
      string _arrowName,
      datetime _time,
      double _price,
      double _high,
      double _low,
      direcxion _vector,
      int     _adMaxCandlesToLive,
      color _clr,
      uchar _arrowCode,
      ENUM_ARROW_ANCHOR _UDArrow,
      bool _showAD)
     {
      waveHTFPeriod=_waveHTFPeriod;
      objName=_objName;
      arrowName=_arrowName;
      price=_price;
      high = _high;
      low=_low;
      vector=_vector;
      adTimeToLiveCandles=_adMaxCandlesToLive;
      //time at candle reported
      time=_time;
      //set time of expiry for trade open
      expiration=time+(adTimeToLiveCandles)*PeriodSeconds(waveHTFPeriod);
      clr=_clr;
      arrowCode=NULL;
      fSize=8;
      font="Verdana";
      ResetLastError();
      // If dont want to display and have a negative response
      if(_showAD)
        {
         if(!ArrowCreate(0,arrowName,0,time,price,_arrowCode,_UDArrow,clr,STYLE_SOLID,1))
            // InpStyle,InpWidth,InpFill,InpBack,InpSelection,InpHidden,InpZOrder))
            return;
        }
     }
                    ~ADipElement()
     {
     }
  };
int               ADip::uniqueID=0;
// +------------------------------------------------------------------+
