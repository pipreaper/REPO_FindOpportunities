//+------------------------------------------------------------------+
//|                                                    simObject.mqh |
//|                                               Robert Baptie 2018 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Robert Baptie 2018"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <correlation.mqh>
#include <Arrays\List.mqh>
#include <stderror.mqh>
#include <instrument.mqh>
#include <waveLibrary.mqh>
#include <SymbolsInfo.mqh>
//+------------------------------------------------------------------+
//| Class SimObject - All Instrument from file                       |
//+------------------------------------------------------------------+
class XsimObject : public CList
  {
public:
   int               balkHours;
   correlationList *_corrList;
   int               _totalSymbols;
   //passed externs
   instrumentList   *_wtfPointer;
   instrumentList   *_ttfPointer;
   //passed externs
   int               _wtfIndex;
   int               _ttfIndex;
   bool              _isTesting;
   bool              _isBuyTesting;
   int               _drawTrades;
   int               _signature;
   ENUM_TIMEFRAMES   _enumHTFWTFFilter;
   ENUM_TIMEFRAMES   _enumHTFTrendFilter;
   ENUM_TIMEFRAMES   _enumHTFContraWaveFilter;
   ENUM_TIMEFRAMES   _enumHTFATRWaveFilter;
   ENUM_TIMEFRAMES   _enumHTFTerminateFilter;
   double            _betPoundThreshold;
   double            _wtfSpreadPercent;
   int               _ATRPeriod;
   double            _stopFactor;
   double            _targetFactor;
   int               _ADXPeriod;
   int               _ADXRAGO;
   double            _equityRisk;
   double            _numberPairsTrade;
   double            _marginPercentTotal;
   volume_price      _vp;
   double            _lowerPercentile;
   double            _lowerMiddlePercentile;
   double            _middlePercentile;
   double            _upperMiddlePercentile;
   double            _upperPercentile;
   double            _wavePts;
   int               _maxBars;
   bool              _useMaxBars;
   bool              _drawLines;
   bool              _showData;
   double            _marginPerSym;
   double            _acceptableMargin;

   simObject
   (
    int  __drawTrades,
    int  __signature,
    int __maxBars,
    bool __useMaxBars,
    bool __isTesting,
    bool __isBuyTesting,
    int __wtfIndex,
    int __ttfIndex,
    ENUM_TIMEFRAMES  __enumHTFWTFFilter,
    ENUM_TIMEFRAMES  __enumHTFTrendFilter,
    ENUM_TIMEFRAMES  __enumHTFContraWaveFilter,
    ENUM_TIMEFRAMES  __enumHTFATRWaveFilter,
    ENUM_TIMEFRAMES  __enumHTFTerminateFilter,
    double  __betPoundThreshold,
    double  __wtfSpreadPercent,
    int  __ATRPeriod,
    double  __stopFactor,
    double  __targetFactor,
    int  __ADXPeriod,
    int  __ADXRAGO,
    double  __equityRisk,
    double  __numberPairsTrade,
    double  __marginPercentTotal
    )
     {
      _corrList=new correlationList();
      _wtfIndex=__wtfIndex;
      _ttfIndex= __ttfIndex;
      _wtfPointer = new instrumentList(_wtfIndex,_enumHTFWTFFilter);
      _ttfPointer = new instrumentList(_ttfIndex,_enumHTFTrendFilter);
      _maxBars=__maxBars;
      _useMaxBars= __useMaxBars;
      _isTesting = __isTesting;
      _isBuyTesting=__isBuyTesting;
      _drawTrades=__drawTrades;
      _signature=__signature;
      _enumHTFWTFFilter=__enumHTFWTFFilter;
      _enumHTFTrendFilter=__enumHTFTrendFilter;
      _enumHTFContraWaveFilter=__enumHTFContraWaveFilter;
      _enumHTFATRWaveFilter=__enumHTFATRWaveFilter;
      _enumHTFTerminateFilter=__enumHTFTerminateFilter;
      _betPoundThreshold=__betPoundThreshold;
      _wtfSpreadPercent=__wtfSpreadPercent;
      _ATRPeriod=__ATRPeriod;
      _stopFactor=__stopFactor;
      _targetFactor=__targetFactor;
      _ADXPeriod=  __ADXPeriod;
      _ADXRAGO  =  __ADXRAGO;
      _equityRisk=__equityRisk;
      _numberPairsTrade=__numberPairsTrade;
      _marginPercentTotal=__marginPercentTotal;
      _totalSymbols=FindSymbols();
      _marginPerSym=__marginPercentTotal/__numberPairsTrade;
      _acceptableMargin=(_marginPerSym/100)*AccountEquity();//The margin to allocate per Sym    

     };
                    ~simObject()
     {
      delete(_corrList);
      delete(_wtfPointer);
      delete(_ttfPointer);
     };
   double getStop(string symbol,int shift,string indType)
     {
      double stop=iCustom(symbol,ENUM_TIMEFRAMES(_enumHTFWTFFilter),indType,
                          _drawTrades,
                          _signature,
                          _maxBars,
                          _useMaxBars,
                          _isTesting,
                          _isBuyTesting,
                          _enumHTFWTFFilter,
                          _enumHTFTrendFilter,
                          _enumHTFContraWaveFilter,
                          _enumHTFATRWaveFilter,
                          _enumHTFTerminateFilter,
                          _betPoundThreshold,
                          _wtfSpreadPercent,
                          _ATRPeriod,
                          _stopFactor,
                          _targetFactor,
                          _ADXPeriod,
                          _ADXRAGO,
                          _equityRisk,
                          _numberPairsTrade,
                          _marginPercentTotal,
                          _vp,
                          _lowerPercentile,
                          _lowerMiddlePercentile,
                          _middlePercentile,
                          _upperMiddlePercentile,
                          _upperPercentile,
                          _wavePts,
                          _drawLines,
                          _showData,
                          2,shift);
      return stop;
     }
   double getTarget(string symbol,int shift,string indType)
     {
      double target=iCustom(symbol,ENUM_TIMEFRAMES(_enumHTFWTFFilter),indType,
                            _drawTrades,
                            _signature,
                            _maxBars,
                            _useMaxBars,
                            _isTesting,
                            _isBuyTesting,
                            _enumHTFWTFFilter,
                            _enumHTFTrendFilter,
                            _enumHTFContraWaveFilter,
                            _enumHTFATRWaveFilter,
                            _enumHTFTerminateFilter,
                            _betPoundThreshold,
                            _wtfSpreadPercent,
                            _ATRPeriod,
                            _stopFactor,
                            _targetFactor,
                            _ADXPeriod,
                            _ADXRAGO,
                            _equityRisk,
                            _numberPairsTrade,
                            _marginPercentTotal,
                            _vp,
                            _lowerPercentile,
                            _lowerMiddlePercentile,
                            _middlePercentile,
                            _upperMiddlePercentile,
                            _upperPercentile,
                            _wavePts,
                            _drawLines,
                            _showData,
                            3,shift);
      return target;
     }
   //+-------------------------------------------------------------------------------------------------+
   //|printProspects: print list and enabled  |
   //+-------------------------------------------------------------------------------------------------+        
   void printProspects(bool isEnabled,bool isRuntimeAllowed)
     {
      for(int i=0; i<_totalSymbols;i++)
        {
         if(isEnabled && isRuntimeAllowed)
           {
            if(prospectArray[i].isEnabled && prospectArray[i].runtimeAllowed)
               Print(prospectArray[i].symbol," enabled? ",prospectArray[i].isEnabled," runtimeAllowed? ",prospectArray[i].runtimeAllowed);
           }
         else if(isEnabled && prospectArray[i].isEnabled)
            Print(prospectArray[i].symbol," enabled? ",prospectArray[i].isEnabled);
         else if(isRuntimeAllowed && prospectArray[i].runtimeAllowed)
            Print(prospectArray[i].symbol," runtimeAllowed? ",prospectArray[i].runtimeAllowed);
         else if(!isEnabled && !isRuntimeAllowed)
            Print(prospectArray[i].symbol," enabled? ",prospectArray[i].isEnabled);
        }
     }
   //+-------------------------------------------------------------------------------------------------+
   //|initEnabled: calculated margin / desired margin: effectivness to be close to ideal stopQuids/100 |
   //+-------------------------------------------------------------------------------------------------+        
   void initEnabled(bool isTest)
     {
      double acceptableMargin=NULL;
      instrument *instanceSymbolE=NULL;
      double marginPerSym=_marginPercentTotal/_numberPairsTrade;
      acceptableMargin=(marginPerSym/100)*AccountEquity();

      if(!isTest)
        {
         for(int i=0; i<_totalSymbols;i++)
           {
            //default to be overriden
            prospectArray[i].isEnabled=true;
            for(int exclude=ArraySize(excludeTypeArray)-1; exclude>=0; exclude--)
              {
               string type=symbolType(prospectArray[i].symbol);
               if(excludeTypeArray[exclude]==symbolType(prospectArray[i].symbol))
                 {
                  s("INIT EXCLUDED: "+prospectArray[i].symbol+excludeTypeArray[exclude]+" "+(prospectArray[i].symbol),showStatusTerminal);
                  prospectArray[i].isEnabled=false;
                  break;
                 }
              }
           }
        }
      if(isTest)
        {
         for(int i=(ArraySize(tempSymbolsArray)-1); i>=0; i--)
           {
            int ind=findAddProspect(tempSymbolsArray[i]);
            if(ind>=0)
               prospectArray[ind].isEnabled=true;
            else
               s(tempSymbolsArray[i]+" INIT NOT AVAILABLE ",showStatusTerminal);
            //            bool canCreate=false;
            //
            //            instanceSymbolE=new instrument(enumHTFTerminateFilter, _enumHTFTrendFilter , _enumHTFContraWaveFilter , _enumHTFATRWaveFilter , _enumHTFTerminateFilter ,
            //                                                 prospectArray[ind].symbol,"A Symbol","WTF",ADXPeriod,ADXPeriod,equityRisk,acceptableMargin,1,canCreate);
            //            if((instanceSymbolE.wantedMargin>0) && ((instanceSymbolE.acceptableMargin/instanceSymbolE.wantedMargin)>0.7))
            //              {
            //               s("INCLUDED: enabled: "+DoubleToStr((instanceSymbolE.acceptableMargin/instanceSymbolE.wantedMargin),2)+" "+type+" : "+prospectArray[ind].symbol,showStatusTerminal);
            //               prospectArray[ind].isEnabled=true;
            //              }
            //            else if(instanceSymbolE.wantedMargin>0)
            //              {
            //               s("EXCLUDED: disabled: "+DoubleToStr((instanceSymbolE.acceptableMargin/instanceSymbolE.wantedMargin),2)+" "+type+" : "+prospectArray[ind].symbol,showStatusTerminal);
            //               prospectArray[ind].isEnabled=false;
            //              }
            //            else
            //               s("EXCLUDED: disabled: Acceptable margin Zero: "+prospectArray[i].symbol,showStatusTerminal);
            //            delete(instanceSymbolE);
           }
        }
     }
   //+-----------------------------------------------------------------------------------+
   //|runtimeEnabled - at run time (spread++ data changes)                               |
   //+-----------------------------------------------------------------------------------+        
   void runtimeAllowed(bool isTest,bool isOfflineTestingRealSystem)
     {
      if(!isTest)
        {
         for(int i=0; i<_totalSymbols;i++)
           {
            if(prospectArray[i].isEnabled==false)
               continue;
            prospectArray[i].runtimeAllowed=true;
            double allowed=MarketInfo(prospectArray[i].symbol,MODE_TRADEALLOWED);
            if((MarketInfo(prospectArray[i].symbol,MODE_BID)==0) || (allowed==0))
              {

               s("RUN EXCLUDED: "+prospectArray[i].symbol,showStatusTerminal);
               prospectArray[i].runtimeAllowed=false;
               if(isOfflineTestingRealSystem)
                  prospectArray[i].runtimeAllowed=true;
               continue;
              }
           }
        }
      if(isTest)
        {
         for(int i=(ArraySize(tempSymbolsArray)-1); i>=0; i--)
           {
            int ind=findAddProspect(tempSymbolsArray[i]);
            //   Print(ind);
            if(ind>=0)
               prospectArray[i].runtimeAllowed=true;
            else
               s(tempSymbolsArray[i]+" RT NOT AVAILABLE ",showStatusTerminal);
           }
        }
     }
   //+------------------------------------------------------------------+
   //|Populate HTF with Only setups                                     |
   //+------------------------------------------------------------------+     
   void filterWTFSetUps(int indicatorPeriod,int ADXAgo,double EquityRisk,bool isTESTING,string &tSymbolsArray[])
     {
      int shift=1;//always want position 1
      instrument *p=NULL;
      double retValue=-1;
      for(int i=0; i<_wtfPointer.Total();i++)
        {
         p=_wtfPointer.GetNodeAtIndex(i);
         retValue=-1;
         if(!isTESTING)
           {
            //bool canCreate=false;
            //p=new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
            //                 prospectArray[i].symbol,prospectArray[i].desc,"WTF",indicatorPeriod,ADXAgo,EquityRisk,_acceptableMargin,shift,canCreate,_signature,_betPoundThreshold);
            //if(canCreate)
            //  {
            retValue=iCustom(p.symbol,ENUM_TIMEFRAMES(_enumHTFWTFFilter),"\\TREND\\trendIndicatorNew",
                             _drawTrades,
                             _signature,
                             _maxBars,
                             _useMaxBars,
                             _isTesting,
                             _isBuyTesting,
                             _enumHTFWTFFilter,
                             _enumHTFTrendFilter,
                             _enumHTFContraWaveFilter,
                             _enumHTFATRWaveFilter,
                             _enumHTFTerminateFilter,
                             _betPoundThreshold,
                             _wtfSpreadPercent,
                             _ATRPeriod,
                             _stopFactor,
                             _targetFactor,
                             _ADXPeriod,
                             _ADXRAGO,
                             _equityRisk,
                             _numberPairsTrade,
                             _marginPercentTotal,
                             _wavePts,
                             _drawLines,
                             _showData,
                             5,1);

            //s("** ALL GOOD "+prospectArray[i].symbol+" CHECKED VOLUME: "
            //  +" retValue: "+string(retValue)
            //  +" canCreate: "+string(canCreate)
            //  +" Acceptable Margin Factor:  "+string( _betPoundThreshold )
            //  //--what margin is desired for this trade divided by what margin is desired for the same profit/risk ratio across all trades.
            //  +" Allowed Margin Factor: "+string(DoubleToStr(p.factor,2))+" betNumPounds: "+string(p.betNumPounds)+" Lot Min: "+string(p.lotMin)
            //  +" passes Money "+string(DoubleToStr( _wtfSpreadPercent *100,0))
            //  +" % spread criteria: "+string(( _wtfSpreadPercent *p.stopQuids/100)>(p.totalSpreadQuidPoints)),showStatusTerminal);
            //--Currently Only want to act on: 0 buy, 1 sell, 2 change of trend
            if(!((CheckPointer(p)==POINTER_INVALID)) && (retValue!=EMPTY_VALUE) && (retValue<=2) && (retValue>=0))
              {
               s("ADDING INSTRUMENT: "+"fraction of wanted Margin: "+string(p.factor)+" betNumPounds: "+string(p.betNumPounds)+" Lot Min: "+string(p.lotMin)+" ** IN LIST *::* "+string(i)+" : "+prospectArray[i].symbol+" trendIndicator return: "+string(retValue)+" isEnabled: "+string(prospectArray[i].isEnabled),showStatusTerminal);
               Add(p);
               p.goLSC=retValue;
               p.stop=getStop(p.symbol,1,"\\TREND\\trendIndicator");
               p.target=getTarget(p.symbol,1,"\\TREND\\trendIndicator");
               int pos = findAddProspect(p.symbol);
               //       Print("*** INSIDE ****:0 ",getStop(p.symbol,1,"\\TREND\\trendIndicator")," 1 ",getStop(p.symbol,1,"\\TREND\\trendIndicator")," 2 ",getStop(p.symbol,1,"\\TREND\\trendIndicator"));
               s(__FUNCTION__+" ADDED: "+"stop: "+string(p.stop)+" target: "+string(p.target)+"fraction of wanted Margin: "+string(p.factor)+" betNumPounds: "+string(p.betNumPounds)+" Lot Min: "+string(p.lotMin)+" ** IN LIST *::* "+string(i)+" : "+prospectArray[pos].symbol+" trendIndicator return: "+string(retValue)+" isEnabled: "+string(prospectArray[pos].isEnabled),showStatusTerminal);

              }
            else
               s(__FUNCTION__+" No SETUP: "+p.symbol,showStatusTerminal);

            //   delete(p);
            // }
            //else
            //  {
            //   //s("FAILED PRE CHECKS: "+prospectArray[i].symbol+" NOT CHECKED VOLUME: "
            //   //  +" canCreate: "+string(canCreate)
            //   //  +" Acceptable Margin Factor:  "+string( _betPoundThreshold )
            //   //  //--what margin is desired for this trade divided by what margin is desired for the same profit/risk ratio across all trades.
            //   //  +" Allowed Margin Factor: "+string(DoubleToStr(p.factor,2))+" betNumPounds: "+string(p.betNumPounds)+" Lot Min: "+string(p.lotMin)
            //   //  +" passes Money "+string(DoubleToStr( _wtfSpreadPercent *100,0))
            //   //  +" % spread criteria: "+string(( _wtfSpreadPercent *p.stopQuids/100)>(p.totalSpreadQuidPoints)),showStatusTerminal);
            // //  delete(p);
            //  }

           }
         //else if(!isTESTING && !prospectArray[i].isEnabled)
         //   s("FILTERED OUT: NOT AVAILABLE OR TESTING "+string(i)+" : "+prospectArray[i].symbol+" isEnabled: "+string(prospectArray[i].isEnabled),showStatusTerminal);
         else if(isTESTING && (prospectArray[i].isEnabled))
           {
            //trade.testing(goLong,goShort,goClose);
            bool canCreate=true;
            p=new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
                             // _signature  set to 1 so can  ignore margin limits
                             prospectArray[i].symbol,prospectArray[i].desc,"WTF",indicatorPeriod,ADXAgo,EquityRisk,_acceptableMargin,shift,canCreate,_signature,_betPoundThreshold);
            //-want this here to return the values not to open the trade -> see retValue below for that
            retValue=iCustom(prospectArray[i].symbol,ENUM_TIMEFRAMES(_enumHTFWTFFilter),"\\TREND\\trendIndicatorNew",
                             _drawTrades,
                             _signature,
                             _maxBars,
                             _useMaxBars,
                             _isTesting,
                             _isBuyTesting,
                             _enumHTFWTFFilter,
                             _enumHTFTrendFilter,
                             _enumHTFContraWaveFilter,
                             _enumHTFATRWaveFilter,
                             _enumHTFTerminateFilter,
                             _betPoundThreshold,
                             _wtfSpreadPercent,
                             _ATRPeriod,
                             _stopFactor,
                             _targetFactor,
                             _ADXPeriod,
                             _ADXRAGO,
                             _equityRisk,
                             _numberPairsTrade,
                             _marginPercentTotal,
                             _wavePts,
                             _drawLines,
                             _showData,
                             5,1);
            //Print(__FUNCTION__" * ",enumHTFWTFFilter," trend:", _enumHTFTrendFilter ," contrawave: ", _enumHTFContraWaveFilter ," ATR: ", _enumHTFATRWaveFilter ," terminate: ", _enumHTFTerminateFilter );
            s("XXX TESTING ALL GOOD, canCreate: "+string(canCreate)+" "+prospectArray[i].symbol+" CHECKED VOLUME: retValue: "+string(retValue)+" fraction accepted:  "+string(_betPoundThreshold)+" fraction of wanted Margin: "+string(DoubleToStr(p.factor,2))+" betNumPounds: "+string(p.betNumPounds)+" Lot Min: "+string(p.lotMin)+" passes £"+string(DoubleToStr(_wtfSpreadPercent *100,0))+"% spread criteria: "+string(( _wtfSpreadPercent *p.stopQuids/100)>(p.totalSpreadQuidPoints)),showStatusTerminal);
            Add(p);
            p.goLSC=retValue;
            p.stop=getStop(prospectArray[i].symbol,1,"\\TREND\\trendIndicator");
            p.target=getTarget(prospectArray[i].symbol,1,"\\TREND\\trendIndicator");
            //            s("XXX TESTING: IN LIST *::* "+string(i)+" : "+prospectArray[i].symbol+" trendIndicator return: "+string(retValue)+" isEnabled: "+string(prospectArray[i].isEnabled),showStatusTerminal);
           }
        }
     }
   //+-----------------------------------------------------------------------------------+
   //|setInstrumentsInTTF: Set the filtered elements into TTF list                       |
   //+-----------------------------------------------------------------------------------+               
   void setInstrumentsInTTF(int tSyms,int indicatorPeriod,int ADXAgo,double EquityRisk,bool isTESTING,string &tSymbolsArray[])
     {
      int shift=1;//always want position 1
                  //  instrumentList *indexPos=ttfPointer.GetNodeAtIndex(1);
      bool canCreate=true;
      instrument *p=NULL;
      double retValue=-1;
      for(int i=0; i<_totalSymbols;i++)
        {
         retValue=-1;
         if(!isTESTING && prospectArray[i].isEnabled && prospectArray[i].runtimeAllowed)
           {
            p=new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
                             prospectArray[i].symbol,prospectArray[i].desc,"TTF",indicatorPeriod,ADXAgo,EquityRisk,_acceptableMargin,shift,canCreate,_signature,_betPoundThreshold);
            if(canCreate)
              {
               // ttfPointer.GetNodeAtIndex(1);
               _ttfPointer.Add(p);
               //copy trade status from WTF back to TTF
               //p.goLSC=i.goLSC;
               //p.stop=i.stop;
               //p.target=i.target;
              }
            else
              {
               s("** deleting: "+prospectArray[i].symbol+", from *TTF list: failed creation",showStatusTerminal);
               delete (p);
               continue;
              }
           }
        }
     }
   //+-----------------------------------------------------------------------------------+
   //|setInstrumentsInWTF: put filtered into WTF if match criterion                      |
   //+-----------------------------------------------------------------------------------+        
   void setInstrumentsInWTF(int indicatorPeriod,int ADXAgo,double EquityRisk,int refusalTimeHours,bool ISTESTING)
     {
      int shift=1;
      for(int i=_ttfPointer.Total() -1; i>=0; i--)
        {
         instrument *inswtf=NULL;
         instrument *ins=_ttfPointer.GetNodeAtIndex(i);
         //***********Temporarily removed ACTIVE IN THE LAST 8 HOURS this is to increase the output while testing         
         //-- Check that the trade has not been active in the last 8 Hours
         //if(wasActive(ins.symbol,refusalTimeHours))
         //  {
         //   s(__FUNCTION__+"REFUSED TO LIST: "+ins.symbol+": HAS TRADED IN THE LAST "+string(refusalTimeHours)+" Hours",showStatusTerminal);
         //   continue;
         //  }
         //Print("setinstrument:::::: ",ins.symbol," ",ins.descr," ",indexwtf.period," ",indicatorPeriod," ",ADXAgo," ",mBars," ",EquityRisk," ",AcceptableMargin," ",WTF," ",tFrame[TTF]);   
         bool canCreate=true;
         // inswtf=new instrument(ins.symbol,ins.descr,"WTF",indicatorPeriod,ADXAgo,EquityRisk,AcceptableMargin,shift,canCreate);
         inswtf=new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
                               ins.symbol,ins.descr,"WTF",indicatorPeriod,ADXAgo,EquityRisk,_acceptableMargin,shift,canCreate,_signature,_betPoundThreshold);
         if(!canCreate)
           {
            s("*** deleting: "+inswtf.symbol+", from *WTF list: failed creation ",showStatusTerminal);
            delete (inswtf);
            continue;
           }
         //--Check its not VIX or other silly trade ie/. spread is not more than the movement in ATR Money for wtf
         //--Check spread cost is less than 15 % of stop risk
         if((inswtf.spreadPts<inswtf.atrPoints) && (inswtf.betNumPounds<inswtf.totalATRQuids) && (( _wtfSpreadPercent*inswtf.stopQuids/100)>(inswtf.totalSpreadQuidPoints)))
           {
            //inswtf.goLSC=ins.goLSC;
            //inswtf.stop=ins.stop;
            //inswtf.target=ins.target;
            _wtfPointer.Add(inswtf);
            inswtf.MTrend=ins.trend;
            //       Print("Success, passed test added: ",inswtf.symbol," inswtf.goLSC ",inswtf.goLSC);
           }
         else
           {
            if(!(inswtf.spreadPts<inswtf.atrPoints))
               Print(__FUNCTION__+" :REJECTED NO VOLATILITY LEVERAGE: "+inswtf.symbol+" (inswtf.spreadPts<inswtf.atrPoints) : "+string(inswtf.spreadPts<inswtf.atrPoints));
            else if(!(inswtf.betNumPounds<inswtf.totalATRQuids))
               Print(__FUNCTION__+" :REJECTED"+inswtf.symbol+"(inswtf.betNumPounds< total cost smallest move )"+string(inswtf.betNumPounds<inswtf.totalATRQuids));
            else
               Print(__FUNCTION__+" :REJECTED: RIDUCULOUS SPREAD: "+inswtf.symbol+" "+string(_wtfSpreadPercent)+"% of £Bet Risk:"+string(inswtf.stopQuids/100)+"  > spread £: "+string(inswtf.spreadPts*inswtf.betNumPounds));
            delete(inswtf);
           }
        }
     }
   //+-----------------------------------------------------------------------------------+
   //| set already trading:                                                              |
   //+-----------------------------------------------------------------------------------+        
   void addToSetUpsAlreadyTrading(int indicatorPeriod,int ADXAgo,double EquityRisk,int refusalTimeHours)
     {
      int tempIndexArr[];
      //Set the symbols at index pos
      int total=OrdersTotal();
      int item=0;
      bool isIncluded;
      for(item=total; item>=0; item--)//all orders      
        {
         if(OrderSelect(item,SELECT_BY_POS,MODE_TRADES)==true)
            if((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
              {
               isIncluded=false;
               for(int i=_wtfPointer.Total()-1; i>=0; i--)
                  //+------------------------------------------------------------------+
                  //|                                                                  |
                  //+------------------------------------------------------------------+
                 {
                  instrument *ins=_wtfPointer.GetNodeAtIndex(i);
                  if(OrderSymbol()==ins.symbol)
                    {
                     isIncluded=true;
                     break;//In list already
                    }//order select      
                 }
               //+------------------------------------------------------------------+
               //|                                                                  |
               //+------------------------------------------------------------------+
               if(!isIncluded)
                 {
                  int s=ArraySize(tempIndexArr);
                  ArrayResize(tempIndexArr,s+1);
                  tempIndexArr[s]=findAddProspect(OrderSymbol());
                 }
              }
        }
      bool canCreate=true;
      for(int n=ArraySize(tempIndexArr)-1; n>=0; n--)
        {
         int pairIndex=tempIndexArr[n];
         _wtfPointer.Add(new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
                         prospectArray[pairIndex].symbol,prospectArray[pairIndex].desc,"WTF",indicatorPeriod,ADXAgo,EquityRisk,_acceptableMargin,_wtfPointer.pil,canCreate,_signature,_betPoundThreshold));
        }
     }
   //+-----------------------------------------------------------------------------------+
   //| findAddProspect:                                                                  |
   //+-----------------------------------------------------------------------------------+       
   int findAddProspect(string sym)
     {
      for(int i=(ArraySize(prospectArray)-1); i>=0; i--)
         if(prospectArray[i].symbol==sym)
            return i;
      return-1;
     }
   //+------------------------------------------------------------------+
   //| Find Symbols                                                     |
   //+------------------------------------------------------------------+ 
   int  FindSymbols()
     {
      int    handle,i,TotalRecords;
      string fname,Sy,descr;
      //----->
      fname = "symbols.raw";
      handle=FileOpenHistory(fname, FILE_BIN | FILE_READ);
      if(handle<1)
        {
         Print("HTML Report generator - Unable to open file"+fname+", the last error is: ",GetLastError());
         return(false);
        }
      TotalRecords=(int)FileSize(handle)/1936;
      ArrayResize(prospectArray,TotalRecords);
      //ArrayResize(Descr,TotalRecords);

      for(i=0; i<TotalRecords; i++)
        {
         Sy=FileReadString(handle,12);
         descr=FileReadString(handle,75);
         FileSeek(handle,1849,SEEK_CUR); // goto the next record
         prospectArray[i].symbol=Sy;
         prospectArray[i].desc=descr;
         prospectArray[i].symbolIndex=i;
        }
      FileClose(handle);
      return(TotalRecords);
     }
   //+------------------------------------------------------------------+
   //|Populate the Market watch with test or realtime data              |
   //+------------------------------------------------------------------+
   void fillMarketWatch(bool isTESTING)
     {
      for(int w=0; w<_totalSymbols;w++)
        {
         if(!isTESTING && prospectArray[w].isEnabled)
           {
            if(!SymbolSelect(prospectArray[w].symbol,true))
               Print(__FUNCTION__,": **** failed to add: "+prospectArray[w].symbol+" to Market Watch ");
           }
         else if(isTESTING)
           {
            bool isIn=isIntempArray(prospectArray[w].symbol,tempSymbolsArray);
            if(isIn)
              {
               bool succesInWatchList=SymbolSelect(prospectArray[w].symbol,true);
               //---Dont know why but interface if not running through debug needs this or it does not get added to the watch.           
               Sleep(10);
               if(!succesInWatchList)
                  Print(__FUNCTION__,": failed to add: "+prospectArray[w].symbol+" to Market Watch ");
               //   else
               //      prospectArray[w].isEnabled=true;
               //  }
               //else
               //  {
               //   // mark as not to be considered
               //   prospectArray[w].isEnabled=false;
              }
           }
         int debug=-1;
        }
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void testBuy(string sym,string descr,int shift)
     {
      instrument *p=NULL;
      double retValue=-1;
      double marginPerSym=_marginPercentTotal/_numberPairsTrade;
      double acceptableMargin=(marginPerSym/100)*AccountEquity();//The margin to allocate per Sym 
      bool canCreate=true;
      p=new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
                       // _signature  set to 1 so can  ignore margin limits
                       sym,descr,"WTF",_ADXPeriod,_ADXRAGO,_equityRisk,acceptableMargin,shift,canCreate,_signature,_betPoundThreshold);

      //-want this here to return the values not to open the trade -> see retValue below for that
      retValue=iCustom(sym,ENUM_TIMEFRAMES(_enumHTFWTFFilter),"\\TREND\\xtrendIndicatorT",
                       _drawTrades,
                       _signature,
                       _maxBars,
                       _useMaxBars,
                       _isTesting,
                       _isBuyTesting,
                       _enumHTFWTFFilter,
                       _enumHTFTrendFilter,
                       _enumHTFContraWaveFilter,
                       _enumHTFATRWaveFilter,
                       _enumHTFTerminateFilter,
                       _betPoundThreshold,
                       _wtfSpreadPercent,
                       _ATRPeriod,
                       _stopFactor,
                       _targetFactor,
                       _ADXPeriod,
                       _ADXRAGO,
                       _equityRisk,
                       _numberPairsTrade,
                       _marginPercentTotal,
                       _vp,
                       _lowerPercentile,
                       _lowerMiddlePercentile,
                       _middlePercentile,
                       _upperMiddlePercentile,
                       _upperPercentile,
                       _wavePts,
                       _drawLines,
                       _showData,
                       6,shift);
      double stop=getStop(p.symbol,0,"\\TREND\\xtrendIndicatorT");
      double target=getTarget(p.symbol,0,"\\TREND\\xtrendIndicatorT");
      delete(p);
     }
   //   double calcProfit(string sym,string descr, int _shift)
   //     {
   //      instrument *p=NULL;
   //      double retValue=-1;
   //      double marginPerSym=_marginPercentTotal/_numberPairsTrade;
   //      double acceptableMargin=(marginPerSym/100)*AccountEquity();//The margin to allocate per Sym 
   //      bool canCreate=true;
   //      _isTesting=false;//-- require results for all times
   //      p=new instrument(_enumHTFWTFFilter,_enumHTFTrendFilter,_enumHTFContraWaveFilter,_enumHTFATRWaveFilter,_enumHTFTerminateFilter,
   //                       // _signature  set to 1 so can  ignore margin limits
   //                       sym,descr,"WTF",_ADXPeriod,_ADXRAGO,_equityRisk,acceptableMargin,_shift,canCreate,_signature,_betPoundThreshold);
   //
   //      //-want this here to return the values not to open the trade -> see retValue below for that
   //      retValue=iCustom(sym,ENUM_TIMEFRAMES(_enumHTFWTFFilter),"\\TREND\\trendIndicatorS",
   //                       _drawTrades,
   //                       _signature,
   //                       _maxBars,
   //                       _useMaxBars,
   //                       _isTesting,
   //                       _isBuyTesting,
   //                       _enumHTFWTFFilter,
   //                       _enumHTFTrendFilter,
   //                       _enumHTFContraWaveFilter,
   //                       _enumHTFATRWaveFilter,
   //                       _enumHTFTerminateFilter,
   //                       _betPoundThreshold,
   //                       _wtfSpreadPercent,
   //                       _ATRPeriod,
   //                       _stopFactor,
   //                       _targetFactor,
   //                       _ADXPeriod,
   //                       _ADXRAGO,
   //                       _equityRisk,
   //                       _numberPairsTrade,
   //                       _marginPercentTotal,
   //                       _vp,
   //                       _lowerPercentile,
   //                       _lowerMiddlePercentile,
   //                       _middlePercentile,
   //                       _upperMiddlePercentile,
   //                       _upperPercentile,
   //                       _wavePts,
   //                       _drawLines,
   //                       _showData,
   //                       6,_shift);
   //      delete(p);
   //      return retValue;
   //     }
   //+------------------------------------------------------------------------+
   //| Check that symbol has not been active in the last (x) Hours            |
   //+------------------------------------------------------------------------+     
   //bool wasActive(string ins,int hrs)
   //  {
   //   int total=OrdersHistoryTotal();
   //   int item=0;
   //   for(item=total; item>=0; item--)//all orders      
   //     {
   //      if(OrderSelect(item,SELECT_BY_POS,MODE_HISTORY)==true)
   //         if(ins==OrderSymbol())
   //           {
   //            datetime timeCurrent=TimeCurrent();
   //            datetime orderCloseTime=OrderCloseTime();
   //            if(checkDatesDifferenceHours(timeCurrent,orderCloseTime,hrs))
   //               return true;
   //           }
   //     }//order select  
   //   return false;
   //  }
   //void clearList()
   //  {
   //   for(instrumentList *j=GetFirstNode();j!=NULL;j=j.Next())
   //     {
   //      j.Clear();
   //     }
   //   this.Clear();
   //  }
   void sort(int sVar,int pos)
     {
      instrumentList *indexPos=GetNodeAtIndex(pos);
      indexPos.Sort(sVar);
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void shorten(int mInstruments,int pos)
     {
      instrumentList *j=GetNodeAtIndex(pos);
      j.shortenList(mInstruments);
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void  ToLog()
     {
      //print filtered WTFs
      for(instrument *j=GetFirstNode();j!=NULL;j=j.Next())
         Print(j.symbol," ",j.csi);
     }
   //+------------------------------------------------------------------+
   //|  deleteVariables                                                 |
   //+------------------------------------------------------------------+
   void deleteVariables()
     {
      string textName1="var";
      int objectTotal = ObjectsTotal();
      for(int i=ObjectsTotal() -1; i>=0; i--)
        {//Tidy old congestion
         string objName=ObjectName(i);
         if(StringSubstr(objName,0,3)==textName1)
            ObjectDelete(ObjectName(i));
        }
     }
   //bool  readInstruments()
   //  {
   //   ResetLastError();
   //   int file_handle=FileOpen(dString+"//"+fString,FILE_READ|FILE_WRITE|FILE_IS_TEXT);
   //   if(file_handle!=INVALID_HANDLE)
   //     {
   //      PrintFormat("%s file is available for reading",fString);
   //      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
   //     }
   //   else
   //     {
   //      PrintFormat("Failed to open %s file, Error code = %d",fString,GetLastError());
   //      return false;
   //     }
   //   //--- additional variables
   //   int str_size=-1;
   //   string str="";
   //   int count=0;
   //   while(!FileIsEnding(file_handle))
   //     {
   //      //--- read the string
   //      str=FileReadString(file_handle,str_size);
   //      PrintFormat(str);
   //     // Print("read "+str);
   //      count++;
   //     }
   //   //  ArrayResize(rSymbols,count+1);
   //   //--- close the file
   //   FileClose(file_handle);
   //   PrintFormat("Data is read, %s file is closed",fString);
   //   return true;
   //  }
   //+------------------------------------------------------------------+
   //|Write Instruments - used testing confirmation                     |
   //+------------------------------------------------------------------+
   //void writeInstruments(string inpFileName)
   //  {
   //   ResetLastError();
   //   if(FileIsExist(inpDirectoryName+"//"+inpFileName))
   //      FileDelete(inpDirectoryName+"//"+inpFileName);
   //   int file_handle=FileOpen(inpDirectoryName+"//"+inpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
   //   if(file_handle!=INVALID_HANDLE)
   //     {
   //      PrintFormat("%s file is available for writing",inpFileName);
   //      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
   //     }
   //   else
   //     {
   //      PrintFormat("Failed to open %s file, Error code = %d",inpFileName,GetLastError());
   //      return;
   //     }
   //   //for(instrument *j=GetFirstNode();j!=NULL;j=j.Next())
   //   //  {
   //   //   FileWrite(file_handle,j.symbol+" CSI "+string(j.csi)+" ADX  "+string(j.adx));
   //   //   Print("Write ",j.symbol);
   //   //  }
   //   //--- close the file
   //   FileClose(file_handle);
   //   PrintFormat("Data is written, %s file is closed",inpFileName);
   //  }
  };//end class simObject
////+------------------------------------------------------------------+
