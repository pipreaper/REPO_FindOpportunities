//+------------------------------------------------------------------+
//|                                                        ExpertHTF |
//|                                     Copyright 2018 Robert Baptie |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "2.14"
#property description "Select CSIHTFTrend: This is used for overall Symbol Selection trend and ATR..." 
#property description "Select wtf: This is used for population of the symbols monitored for activation of trading..." 
#property description "...could every 5 minutes could be daily but no higher" 
#property description "Makes sense to run the EA on EURUSD (always ticking)" 
#property description "Run the EA on 15 minute time frame then a new bar tick will be processed every 15 Minutes..." 
#property strict

#include <stderror.mqh>
#include <stdlib.mqh>
#include <setUp.mqh>
#include <tradelogic.mqh>
#include <status.mqh>
#include <ROB_CLASS_FILES\SimObject.mqh>

//+------------------------------------------------------------------+
//| Extern Global Variables Timer Aspect                             |
//+------------------------------------------------------------------+ 
extern int                    watchFill=25;
extern sortBy                 ttfSort=CSI;// variable to sort trending tf. DEFAULT CSI
extern sortBy                 wtfSort=CSI;//sort the wtf by CSI
extern int                    refusalTradeTimeHours=8;//currently not used ->History Back off after MQL4TradeQ Refusal Hours
extern int                    magicNumber=20050333;
extern int                    wtfIndex=0;
extern int                    ttfIndex=1;
extern int                    balkSetupHours=20;
extern int                    balkTriggerHours=2;
//+------------------------------------------------------------------+
//| Extern Global Variables simObject setup                          |
//+------------------------------------------------------------------+
extern int                    drawTrades=0;//drawTrades=-2;//(0) nothing,(1) Arrows,(2) 1+Lines (-1) Profit Script 
extern int                    signature= 0;//<0 adjust margins by factor,  or ignore factor (unlimed margin!)
extern int                    maxBars=2000; //limit shift operations to speed up run time
extern bool                   useMaxBars=true; //plot (trendIndicatorI),and analysis is false, since want to see all data
extern bool                   isTesting=false;//-- will open a BUY at market at shift=0: assumption being  shift=1 was set to buy: Used to inspect trade opens
extern bool                   isBuyTest=true;
extern ENUM_TIMEFRAMES        enumHTFWTFFilter=PERIOD_CURRENT;
extern ENUM_TIMEFRAMES        enumHTFTrendFilter=PERIOD_D1;//HTF trend filter
extern ENUM_TIMEFRAMES        enumHTFContraWaveFilter=PERIOD_H1;//wave pullback filter
extern ENUM_TIMEFRAMES        enumHTFATRWaveFilter=PERIOD_H1;//ATRTF: Stop, Target, Open Trade, trendIndicator & Expert
extern ENUM_TIMEFRAMES        enumHTFTerminateFilter=PERIOD_H1;//HTF exit filter change trend
extern double                 betPoundThreshold=0.1; //cannot open if calculated betNumPounds below this proportion   
extern double                 wtfSpreadPercent=0.15;//fraction of spread money for the bet that cannot be exceded if setInstrumentsInWTF passes in simObject
extern int                    ATRPeriod=14;//ATR period
extern double                 stopFactor=3;//flex ATR Stop
extern double                 targetFactor=6;//flex ATR Target;
extern int                    ADXPeriod=14;
extern int                    ADXRAGO=14;
//+------------------------------------------------------------------+
//| Variables Timer Aspect                                           |
//+------------------------------------------------------------------+
extern double                 equityRisk=2;// % Equity Risk / Trade % / ----for stop
extern double                 numberPairsTrade=10;//Used to set the acceptible margin
extern double                 marginPercentTotal=75;//% Total Acceptable Equity Margin    
//+------------------------------------------------------------------+
//| Global Variables Instrument Selection Aspect                     |
//+------------------------------------------------------------------+                                                     
int TotalSymbols=NULL;
//--Used for testing algorithm when trading closed
bool testOffLineOnTick=false;
setUpList  *prospectMQL4Q=NULL;
tradeObj  *MQL4TradeQ=NULL;
simObject *sObj=NULL;
//+---------------------------------------------------------------------------+
//| OnInit                                                                    |
//| Set up MQL4TradeQ Object that handles everything Open/close/check Trades       |
//| Set up Two lists: CSIHTFTrend to hold trend prospects and wtf lists               |
//| Hold the two lists in * tfArray * ttfIndex(1), currentWTFIndex(0)         |
//+---------------------------------------------------------------------------+
int OnInit()
  {
   s("Start Init",showStatusTerminal);

   sObj=new simObject(
                      drawTrades,
                      signature,
                      maxBars,
                      useMaxBars,
                      isTesting,
                      isBuyTest,
                      wtfIndex,
                      ttfIndex,
                      enumHTFWTFFilter,
                      enumHTFTrendFilter,
                      enumHTFContraWaveFilter,
                      enumHTFATRWaveFilter,
                      enumHTFTerminateFilter,
                      betPoundThreshold,
                      wtfSpreadPercent,
                      ATRPeriod,
                      stopFactor,
                      targetFactor,
                      ADXPeriod,
                      ADXRAGO,
                      equityRisk,
                      numberPairsTrade,
                      marginPercentTotal
                      );
   MathSrand(0);//used in testing module

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      s("***** AUTO TRADING DISABLED *****",true);

   MQL4TradeQ=new tradeObj(sObj,magicNumber);
//--Add triggered trades to MQL4TradeQ. NOTE: does not currently store list of setUps waiting trigger
   MQL4TradeQ.initTradesData();

   prospectMQL4Q=new setUpList(sObj);

   s("TRADING ALLOWED?:  "+string(IsTradeAllowed())+" STOPFACTOR: "+string(stopFactor)+" TARGET FACTOR: "+string(targetFactor)+" IS TESTING?: "+string(isTesting),true);
   s("WORKING TIME FRAME (wtf): "+string(enumHTFWTFFilter),true);
//--set enabled for instruments you want
   sObj.initEnabled(isTesting);
   sObj.printProspects(true,false);

   sObj.fillMarketWatch(isTesting);
//***********Temporarily removed CORELLATION from main loop above to increase the output while testing         
// construct correlation Lists
   sObj._corrList.makeGroups(sObj._totalSymbols);

// Put the symbols selected by required margin in the CSIHTFTrend list
// Here is place to use correlation to limit the groups you want to consider
   s("End Init",showStatusTerminal);
   if(testOffLineOnTick)
      OnTick();

//return(INIT_FAILED);      
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|OnTick                                                            |                  
//+------------------------------------------------------------------+
void OnTick()
  {
// MQL4TradeQ.tradeMeOut(wtf,fEMA,sEMA,100,prevTime);
// MQL4TradeQ.moveStopZero();
   static datetime time0;
   bool isNewBar=time0!=Time[0];
   time0=Time[0];
//-- The instrument responsible for the tick is the chart the EA is attached to. Further newBar is whatever timeFrame EA is running on
   if(isNewBar)
     {
      s("//---------------------------------------------------------------------------------------------------//",showStatusTerminal);
      s("START Prospect Update: "+string(TimeGMT()),showStatusTerminal);
      prospectUpdate();
      
      
      
      ///NOT TESTED BELOW
      
      
      s("END  Prospect Update: "+string(TimeGMT()),showStatusTerminal);
      //MQL4TradeQ.closeTrend(CSIHTFTrend,maxBarsDraw,adxPeriod,priceFieldADX, periodRSI,levelBottom,levelTop,considerationHighLevel,considerationLowLevel);
      //MQL4TradeQ.checkMoveStop(300,500);//300 POINTS
      setUpListElement *iReal=prospectMQL4Q.GetFirstNode(),*i=NULL;
      while(CheckPointer(iReal)!=POINTER_INVALID)
        {
         //--Leave loop and clean up before it times out and leaves a mess all over the screen
         if(IsStopped())
            return;
         i=iReal;
         iReal=iReal.Next();
         double goClose=NULL;
         //***********Temporarily removed CORELLATION this is to increase the output while testing
         ///--Check if is is correlated?
         //string correlation=sObj.symbolLists.corrList.isCorrelated(i.ins.symbol);
         //if(StringSubstr(correlation,0,3)=="COR")
         //  {
         //   s(__FUNCTION__+" REFUSED TO CHECK: "+correlation+" : "+i.ins.symbol+" TIME: "+string(Time[0]),true);
         //   continue;
         //  }
         //         else
         //            s("CHECKING SETUP: "+i.ins.symbol+" ? "+" CORRELATION SAYS: "+correlation+" : "+" TIME: "+string(Time[0]),false);       

         if((i.ins.goLSC==0) || (i.ins.goLSC==1))
            //Its an open Long or short
           {
            s(__FUNCTION__+" Attempt to MQL4TradesQ goLSC: "+string(i.ins.goLSC)+" Symbol: "+i.ins.symbol,showStatusTerminal);
            if(!MQL4TradeQ.inTradesObjList(i))
              {
               //-- remove from prospectMQL4Q and ....
               prospectMQL4Q.removeAndSetToTriggered(i,i.ins.goLSC);
               //-- Add to MQL4TradeQ
               MQL4TradeQ.Add(i);
               s(__FUNCTION__+" **************** "+i.ins.symbol+" Added to MQL4TradeQ",showStatusTerminal);
              }
            else
               s("Already in Trade MQL4TradeQ Symbol: "+i.ins.symbol,showStatusTerminal);
           }
         //--must be a close
         else if(i.ins.goLSC<7)
           {
            if(MQL4TradeQ.closeIndicator(i.ins.symbol))
              {
               //-- Need to remove from MQL4TradeQ
               if(MQL4TradeQ.removedMQL4TradesQ(i))
                  s(__FUNCTION__+" closed MQL4TradeQ: "+i.ins.symbol,showStatusTerminal);
              }
            else
               s("no order to close or (failed to close: Notification sent) "+i.ins.symbol+" i.ins.goLSC ",i.ins.goLSC);
           }
         else
           {
            if(MQL4TradeQ.removedMQL4TradesQ(i))
               s("Removed from MQL4 TradesQ ~ No set up, No Close or Trading: "+i.ins.symbol,showStatusTerminal);
            //else
            //   s("No set Up: "+i.ins.symbol,showStatusTerminal);
           }
        }        
        
      //--remove over time from MQL4TradesQ
      MQL4TradeQ.balkTradeMQL4(balkSetupHours,balkTriggerHours);
      //--check MQL4TradeQ does not contain manual deletions
      MQL4TradeQ.removeManualDeletionFromMQL4TradesQ();
      MQL4TradeQ.Sort(wtfSort);
      MQL4TradeQ.ToLog("** Final Prospects MQL4TradeQ -> check trigger:");
      setUpListElement *jReal=MQL4TradeQ.GetFirstNode(),*j=NULL;
      while(CheckPointer(jReal)!=POINTER_INVALID)
        {
         j=jReal;
         jReal=jReal.Next();
         s("TRIGGERLIST Symbol: "+j.ins.symbol+" State: "+j.state,showStatusTerminal);
         int category=NULL; MqlRates rates[]; string sCommentID=NULL;
         if(MQL4TradeQ.isTriggered(j,rates,category,sCommentID,enumHTFWTFFilter))
           {
            if((category==OP_BUY) || (category==OP_SELL))
              {
               double marginInitReq=-1;
               //--Check Account Margin
               if(((AccountMargin()+(j.ins.totalSpreadQuidPoints))/AccountEquity())*100>marginPercentTotal)
                  s(__FUNCTION__+"sym:"+j.ins.symbol+" *** NOT ENOUGHT MARGIN *** WILL NOT ATTEMPT TO OPEN TRADE *** Margin Limited to: "+string(marginPercentTotal)+" Margin %Desired: "+DoubleToStr(((AccountMargin()+(j.ins.totalSpreadQuidPoints))/AccountEquity()*100),2)+" Account Equity: "+string(AccountEquity()),true);
               else
                 {
                  //--Opening trades currently depends on uptodate ATR value                   
                  double atr=iATR(j.ins.symbol, enumHTFATRWaveFilter, ATRPeriod,1);
                  int ticket=NULL;
                  Print(__FUNCTION__," ",j.ins.symbol," betNumPounds ",j.ins.betNumPounds," stop: ",j.ins.stop," target: ",j.ins.target);

                  string Status=MQL4TradeQ.placeEntryOrder(j.ins,atr,enumHTFWTFFilter,sCommentID,rates,category,equityRisk,marginInitReq,j.ins.stop,j.ins.target,ticket);
                  if(Status=="Order Placed")
                    {
                     j.category=category;
                     j.state="trading";
                     j.ticket=ticket;
                     SendNotification(Status);
                    }
                  else
                     s("failed to Open: "+j.ins.symbol+" "+Status,showStatusTerminal);
                 }
              }
           }
         //   else
         //      Print(__FUNCTION__," check Trigger Failed: Not waiting ... triggered already",j.ins.symbol);
        }
      //int posY =0;
      //sObj.wtfPointer.displayInfo(acceptableMargin,wtfSort,posY);
      //sObj.ttfPointer.displayInfo(acceptableMargin,ttfSort,posY);        
      s("Compleated New Bar, Prospects Waiting Close/Trigger: "+string(Time[0])+" #Instruments: "+string(prospectMQL4Q.Total()));
      s("Instruments trading now: "+string(OrdersTotal()));
      s("//---------------------------------------------------------------------------------------------------//",showStatusTerminal);
     }//--end new bar      
// MQL4TradeQ.wideRangeBar(wtf,Method_Str,Method,Sample,Length,Show_WidRangBar,Show_Narrow_RangBar,drawBegin,fEMA,mEMA,sEMA);
  }
//--+------------------------------------------------------------------+
//--|Objective is to Update prospects list before MQL4TradeQ decisions      |
//--|delete screen variables
//--+------------------------------------------------------------------+
void prospectUpdate()
  {

//-- if global lists exist delete them because making new   
   if(sObj!=NULL)
      sObj.Clear();
   if(sObj._wtfPointer!=NULL)
      sObj._wtfPointer.Clear();
   if(sObj._ttfPointer!=NULL)
      sObj._ttfPointer.Clear();

   if(prospectMQL4Q!=NULL)
      prospectMQL4Q.Clear();

//-- Find the instruments that have a valid wave setup
//sObj.marginPerSym=marginPercentTotal/numberPairsTrade;
//sObj.acceptableMargin=(marginPerSym/100)*AccountEquity();//The margin to allocate per Sym 
//Set the enabled state of the to be traded instruments
   sObj.runtimeAllowed(isTesting,testOffLineOnTick);
//-- print both wanted and allowed at runtime   
   sObj.printProspects(true,true);
//--create the instruments from the allowed Instruments and put into TTF list
   sObj.setInstrumentsInTTF(sObj._totalSymbols,ADXPeriod,ADXRAGO,equityRisk,isTesting,tempSymbolsArray);
//-- create instruments from filtered list put into ttf
//  sObj.ToLog();

   sObj._ttfPointer.ToLog();

   sObj._ttfPointer.sort(ttfSort);
//--reduce to sensible amount to process
   sObj._ttfPointer.shorten(watchFill);
   sObj._ttfPointer.ToLog();
//     MQL4TradeQ.ToLog("* MQL4TradeQ begin of prospect 4 :");
//--xfer the prospects to the wtf
//--+-----------------------------------------------------------------------------------+
//--| createWTF: add instruments to wtf from CSIHTFTrend checking for:                          |
//--| *** THESE ARE SYSTEM TRADING DECISIONS                                            |      
//--| (1). Capped Spread < totalATRMoney                                               |
//--| (2). £ Bet is < totalATRMoney                                                    |
//--| (3). £ The margin required for the pounds bet < margin wanted                     |   
//--|      if its not then make it so at a cost of reducing the profit per point        |
//--|  NO! Do in Expert (4). Check that the instruments that you add are not correlated |
//--+-----------------------------------------------------------------------------------+  
   sObj.setInstrumentsInWTF(ADXPeriod,ADXRAGO,equityRisk,refusalTradeTimeHours,isTesting);

//-- Add to SObj instruments already trading 
   sObj.addToSetUpsAlreadyTrading(ADXPeriod,ADXRAGO,equityRisk,refusalTradeTimeHours);
//--sort wtf by csi, miniumum spread or other variable as required
   sObj._wtfPointer.sort(wtfSort);
   sObj._wtfPointer.ToLog();
//--find the new setUps that satisfy conditions and put in sObj Q
   sObj.filterWTFSetUps(ADXPeriod,ADXRAGO,equityRisk,isTesting,tempSymbolsArray);
   sObj.ToLog();   
   int posY=0;
   
//--display both the htf list and the wtf list
//-- clean old screen variables   
   sObj.deleteVariables();
   sObj._wtfPointer.displayInfo(sObj._acceptableMargin,wtfSort,posY);
   sObj._ttfPointer.displayInfo(sObj._acceptableMargin,ttfSort,posY);

//-- message out the Groups found in this Broker
//sObj.symbolLists.corrList.ToLog("GROUPS FOUND :"+AccountCompany(),true);
//--Add Top Opportunities prospectMQL4Q prospectMQL4Q
//-- prospectMQL4Q has control fields that wtf does not so xfer from wtf to prospectMQL4Q
//  sObj.wtfPointer.ToLog();
   prospectMQL4Q.populateSetUpList();
   prospectMQL4Q.ToLog("** Final propectMQL4Q -> check volume: ",showStatusTerminal);
  }
//+------------------------------------------------------------------+
//|cleanAllObjects                                                          |
//+------------------------------------------------------------------+  
bool cleanAllObject()
  {
   for(int i=ObjectsTotal() -1; i>=0; i--)
     {
      string objName=ObjectName(i);
      ObjectDelete(ObjectName(i));
     }
   if(ObjectsTotal()==0)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
//|OnDeInit                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   bool isClean=false;
   int loopCount=0;
   do
     {
      loopCount++;
      isClean=cleanAllObject();
      Sleep(200);
     }
   while(isClean==false && loopCount<=5);
   if(!isClean)
      Print(__FUNCTION__," ***** Objects not cleaned up");
   if(sObj!=NULL)
      sObj.Clear();
   if(
      sObj._wtfPointer!=NULL)
      sObj._wtfPointer.Clear();
   if(sObj._ttfPointer!=NULL)
      sObj._ttfPointer.Clear();
   delete(prospectMQL4Q);
   delete(MQL4TradeQ);
   delete(sObj);
   Sleep(200);
  }
//+------------------------------------------------------------------+
