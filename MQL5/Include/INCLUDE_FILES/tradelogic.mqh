//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property description "calcStopTarget returns stop and target according to a multiplicative factor of ATR"
#property description "Currently returns the minimum stop if ATR factor is less than the minimum stop"
#property description " Will warn if minimum stop and target are less than SPREAD" 
#property description "Since the system is based on ATR volatility it should not have selected this instrument"
#property copyright "Copyright 2016, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "2.09"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WaveLibrary.mqh>
#include <setUp.mqh>
//#include <ROB_CLASS_FILES\SimObject.mqh>

color BuyColor=clrCornflowerBlue;
color SellColor=clrSalmon;
color defaultColor=clrWhite;//just a default color  
int slippage=0;
double limitPoints=0;//pair.lotSize 
//+------------------------------------------------------------------+
//| Trade Object                                                     |
//+------------------------------------------------------------------+
class tradeObj : public setUpList //CList
  {
public:
   int               magicNumber;
                     tradeObj(simObject *&i_pointer,int mn): setUpList(i_pointer)

     {
      magicNumber=mn;
      //    tlSimObj = pointer;
     }
                    ~tradeObj()
     {
      this.Clear();
      //this.clearList();
      Print(__FUNCTION__,"destructor");
     }
   //+-----------------------------------------------------------------------------------------+
   //|testing: open and close trades randomly                                                  |
   //+-----------------------------------------------------------------------------------------+
   void  testing(double &gl,double &gs,double &gc)
     {
      double stretch=32767;
      double rnd=MathRand();
      double percent=(rnd/stretch)*100;
      if(percent<10)
         gl=1;
      else if(percent<66)
         gs=EMPTY_VALUE;
      else
         gc=EMPTY_VALUE;
      Print("percent: ",percent,"  L:  ",gl,"  S:  ",gs,"  C:  ",gc);
     }
   //+-----------------------------------------------------------------------------------------+
   //|inMQL4TradesList: remove trades that are trading in the trades list but not in trades table |
   //+-----------------------------------------------------------------------------------------+
   bool  inMQL4TradesList(setUpListElement &TRADE)
     {
      for(int c=OrdersTotal()-1; c>=0; c--)
        {
         if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES) && (TRADE.ins.symbol==OrderSymbol()))
            return true;
        }
      return false;
     }
   //+-----------------------------------------------------------------------------------------+
   //|isTriggered: check trigger list to see if fired                                            |
   //+-----------------------------------------------------------------------------------------+
   bool  trigger(setUpListElement &j,MqlRates &rates[],int category,ENUM_TIMEFRAMES workingtf)
     {
      j.ins.triggerTime=Time[0];
      return true;
     }
   //+-----------------------------------------------------------------------------------------+
   //|isTriggered: check trigger list to see if fired                                            |
   //+-----------------------------------------------------------------------------------------+
   bool  isTriggered(setUpListElement &j,MqlRates &rates[],int &category,string &sComment,ENUM_TIMEFRAMES workingtf)
     {
      ArraySetAsSeries(rates,true);
      int copiedRates=CopyRates(j.ins.symbol,workingtf,0,100,rates);
      string sCommentID=findCauseTrade(j.ins.symbol,workingtf,category,j.ins.csi);// record for analysis latet - need write to file on open      

      if((copiedRates>0) && (j.state=="wait trigger") && trigger(j,rates,category,workingtf))
        {
         Print(__FUNCTION__+"**** Valid Open ***** ",j.ins.symbol);
         category=int(j.ins.goLSC);
         return true;
        }
      else
        {
         Print(__FUNCTION__+"**** NOT Valid Open ***** ",j.ins.symbol," j.ins.state: ",j.state);
        }
      return false;
     }
   //+------------------------------------------------------------------+
   //|findCauseTrade - what cataalyst made this trade happen            |
   //+------------------------------------------------------------------+   
   string findCauseTrade(string sym,ENUM_TIMEFRAMES workingTF,int BS,double csi)
     {
      double bid=MarketInfo(sym,MODE_BID);
      double ask=MarketInfo(sym,MODE_ASK);
      string sCommentID=NULL;
      if(BS==OP_BUY)
         sCommentID=sym+" CSI: "+string(csi)+" "+string(Time[0])+" Long "+"wtf: "+string(workingTF)+" ASK: "+string(ask);
      else if(BS==OP_SELL)
         sCommentID=sym+" CSI: "+string(csi)+" "+string(Time[0])+" Short "+" wtf: "+string(workingTF)+" BID: "+string(bid);
      return sCommentID;
     }
   //+--------------------------------------------------------------------------------------+
   //|removeManualDeletionFromMQL4Q - remove instrument that has been manually closed                    |
   //+--------------------------------------------------------------------------------------+        
   void removeManualDeletionFromMQL4TradesQ()
     {
      bool noMatch=true;
      setUpListElement *jReal=GetFirstNode(),*j=NULL,*temp=NULL;
      while((CheckPointer(jReal)!=POINTER_INVALID) && (jReal!=NULL))
        {
         j=jReal;
         jReal=jReal.Next();
         if(j.state=="trading")
           {
            noMatch=false;
            for(int c=OrdersTotal()-1; c>=0; c--)
              {
               if(OrderSelect(c,SELECT_BY_POS) && OrderSymbol()==j.ins.symbol)
                 {
                  //string thisOrderSymbol=OrderSymbol();                 
                  noMatch=true;// is matched so dont delete it
                  break;
                 }
              }
           }
         if(!noMatch)
           {
            s(" deleted: "+j.ins.symbol+" from MQL4TradeQ: was manually deleted, Open or failed to Open",showStatusTerminal);
            this.setCurrent(j);
            this.DeleteCurrent();
           }
        }
     }
   //+--------------------------------------------------------------------------------------+
   //|closeFromTradesQ - remove instrument that has been successfully closed                |
   //+--------------------------------------------------------------------------------------+    
   bool removedMQL4TradesQ(setUpListElement &i)
     {
      setUpListElement *jReal=GetFirstNode(),*j=NULL,*temp=NULL;
      while((CheckPointer(jReal)!=POINTER_INVALID) && (jReal!=NULL))
        {
         j=jReal;
         jReal=jReal.Next();
         if(j.ins.symbol==i.ins.symbol)
           {
            s(" deleted: "+j.ins.symbol+" creation time ",showStatusTerminal);
            this.setCurrent(j);
            //this.m_curr_node=j;
            this.DeleteCurrent();
            return true;
           }
        }
      return false;
     }
   //+--------------------------------------------------------------------------------------+
   //|setCurrent - set the current pointer of                |
   //+--------------------------------------------------------------------------------------+        
   bool setCurrent(setUpListElement *c)
     {
      this.m_curr_node=c;
      if(CheckPointer(m_curr_node)!=POINTER_INVALID)
         return true;
      else
         return false;
     }
   //+--------------------------------------------------------------------------------------+
   //|balkSetUps - remove instruments that have been in set up list more than balkTime      |
   //+--------------------------------------------------------------------------------------+    
   void balkTradeMQL4(int BALKSETUP,int BALKTRIGGERED)
     {
      setUpListElement *jReal=GetFirstNode(),*j=NULL,*temp=NULL;
      while((CheckPointer(jReal)!=POINTER_INVALID) && (jReal!=NULL))
        {
         j=jReal;
         jReal=jReal.Next();
         //j=trade.GetCurrentNode();              
         if((j.state!="wait triggered") && !checkDatesDifferenceHours(Time[0],j.ins.creationTime,BALKSETUP) && !inMQL4TradesList(j))
           {
            s(" BALKING SETUP on: "+j.ins.symbol+" creation time: "+string(j.ins.creationTime),showStatusTerminal);
            this.m_curr_node=j;
            this.DeleteCurrent();
           }
         else if((j.state=="triggered") && !checkDatesDifferenceHours(Time[0],j.ins.triggerTime,BALKTRIGGERED) && !inMQL4TradesList(j))
           {
            s(" **************  BALKING TRIGGER on: "+j.ins.symbol+" Trigger Time: "+string(j.ins.triggerTime),showStatusTerminal);
            this.m_curr_node=j;
            this.DeleteCurrent();
           }
         else
           {
            //   this.m_curr_node=j;                    
            s("NOT BALKED: EITHER TRADING ALREADY OR HAS TIME LEFT: "+string(j.ins.symbol),showStatusTerminal);
           }
        }
     }
   //+---------------------------------------------------------+
   //|isSetUp: Add a setUpListElement to the trade queue       |
   //+---------------------------------------------------------+
   bool inTradesObjList(setUpListElement *i)
     {
      for(setUpListElement *tradeItem=GetFirstNode();tradeItem!=NULL;tradeItem=tradeItem.Next())
        {
         if(tradeItem.ins.symbol==i.ins.symbol)
            return true;//already in the Queue of triggers           
        }
      return false;
     }
   //+-----------------------------------------------------------------------------------------+
   //|checkValidity: remove trades that are trading in the trades list but not in trades table |
   //+-----------------------------------------------------------------------------------------+
   //bool  ticketInHistory(setUpListElement *sule)
   //  {
   //   m_curr_node=sule;
   //   for(int c=OrdersHistoryTotal()-1; c>=0; c--)
   //     {
   //      if((OrderSelect(c,SELECT_BY_POS,MODE_HISTORY)) && (sule.ticket==OrderTicket()))
   //        {
   //         Print(__FUNCTION__," Being removed from the trade list: ",IndexOf(sule));
   //         DeleteCurrent();
   //         //ToLog(__FUNCTION__+" after Deleted");
   //         return false;
   //        }
   //     }
   //   return true;
   //  }
   //+--------------------------------------------------------------------------+
   //|initTradesData: fill tradeObj with current trades open so can close trade |
   //+--------------------------------------------------------------------------+
   void  initTradesData()
     {
      //double acceptableMargin=NULL;
      //instrument *instanceSymbolE=NULL;
      //double marginPerSym=marginPercentTotal/numberPairsTrade;
      //acceptableMargin=(marginPerSym/100)*AccountEquity();     
      for(int c=OrdersTotal()-1; c>=0; c--)
        {
         if(OrderSelect(c,SELECT_BY_POS))
           {
            //just to trigger close!!
            // void instrument(string Sy,string des,string whoAmI,int period,int adxBefore,double r,double acceptableM, int shift)   
            bool canCreate=true;
            instrument *ins=new instrument(simObj._enumHTFWTFFilter,simObj._enumHTFTrendFilter,simObj._enumHTFContraWaveFilter,simObj._enumHTFATRWaveFilter,simObj._enumHTFTerminateFilter,
                                           OrderSymbol(),"FOR_TRADE_TABLE","INIT",14,14,4,0,0,canCreate,0,simObj._betPoundThreshold);
            setUpListElement *ele=new setUpListElement(ins);
            ele.category=OrderType();
            ele.ticket=OrderTicket();
            ele.state="trading";
            //           ele.
            //Print(__FUNCTION__," Is it a real instrument spreadPence:",ins.spreadPts);
            this.Add(ele);
           }
        }
     }
   //+------------------------------------------------------------------+
   //|To Log                                                            |
   //+------------------------------------------------------------------+
   void  ToLog(string txt)
     {
      int count=0;
      Print(txt," : ",this.Total());
      for(setUpListElement *i=GetFirstNode();i!=NULL;i=i.Next())
        {
         if(CheckPointer(i.ins)!=POINTER_INVALID)
            Print("Symbol: ",i.ins.symbol," ticket: ",i.ticket," csi: ",i.ins.csi,"trigger Time: ",i.ins.triggerTime);
         else
            Print("Failure at position: ",count," i ",i," i.ins  ",i.ins);
         count++;
        }
     }
   //+------------------------------------------------------------------+
   //|Close the trade if No furtherment                                 |
   //+------------------------------------------------------------------+     
   bool closeIndicator(string sym)
     {
      Print("gonna try to close: ",sym);
      double price=-1;int digits=-1;
      //   double goClose0=EMPTY_VALUE,goClose1=EMPTY_VALUE,goStatus0=EMPTY_VALUE,goStatus1=EMPTY_VALUE,goStatus2=EMPTY_VALUE;
      for(int c=OrdersTotal()-1; c>=0; c--)
        {
         if
         (
          OrderSelect(c,SELECT_BY_POS)
          && (sym==OrderSymbol())
          // my magic number or zero for a trade you opened          
          && ((OrderMagicNumber()==magicNumber) || (OrderMagicNumber()==0))
          && ((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
          )
           {
            if(OrderType()==OP_BUY)
               price=MarketInfo(OrderSymbol(),MODE_ASK);
            else
               price=MarketInfo(OrderSymbol(),MODE_BID);
            digits=int(MarketInfo(OrderSymbol(),MODE_DIGITS));
            if(OrderClose(OrderTicket(),OrderLots(),price,250,Violet))
              {
               s(__FUNCTION__+" Success Closed "+sym+DoubleToStr(price,digits)+" TIME: "+TimeToStr(Time[0]),true);
               SendNotification("Success Closed: "+OrderSymbol()+" @: "+DoubleToStr(price,digits));

               //****** delete instrument from trades list its no longer trading!               

               return true;
              }
            else
              {
               Print(__FUNCTION__+" ***** FAILURE TO CLOSE *****: "+OrderSymbol());
               SendNotification("***** FAILURE TO CLOSE *****: "+OrderSymbol()+" @: "+DoubleToStr(price,digits));
               return false;
              }
           }
        }
      return false;
     }
   //+------------------------------------------------------------------+
   //|Order more?                                                       |
   //+------------------------------------------------------------------+
   bool orderMore(instrument &pair,int WTF,double &SP,double &TT,string &information)
     {
      for(int i=OrdersTotal(); i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            //  com = OrderComment();
            if(OrderSymbol()==pair.symbol) //&& (com==sCommID))
              {
               //if(checkTradeStatus(WTF))
               //  {
               //   s(__FUNCTION__+" **** ATTEMPT TO ORDER MORE **** "+OrderSymbol(),true);
               //   SP=OrderStopLoss();
               //   TT=OrderTakeProfit();
               //   information="ADD";
               //   return true;
               //  }
               //else
               //  {
               information="DECISION NOT TO ORDER MORE: "+OrderSymbol()+" checkTradeStatus: "+string(checkTradeStatus(WTF));
               return false;
               //  }
              }
           }
        }
      information="continue";
      return true;
     }
   //+------------------------------------------------------------------+
   //|Place an Order subject to conditions being algorithmically met    |
   //+------------------------------------------------------------------+
   string placeEntryOrder(

                          instrument &pair,
                          double atr,
                          int tFrame,
                          string sCommID,
                          MqlRates &r[],
                          int category,
                          double eRisk,
                          double &marginInitReq,
                          double stop,
                          double target,
                          int    &ticket
                          )
     {
      string information="init";
      //double STOP=-1;double TARGET=-1;

      // currently returns false for pairs already open true if not yet open
      //if(!orderMore(pair,tFrame,STOP,TARGET,information))
      //   return information;

      //will currently open only one instance of an instrument being set to:
      //continue: open the trade 0r
      //DESICION NOT TO ORDER MORE.... dont open          
      // Print("stop target conditions: ",information, "STOP ",STOP," TARGET ",TARGET);
      double openPrice;
      string res;
      int tradeTries=0;
      string message="";

      do
        {
         //         openPrice=-1;
         //         message="";
         //         res="";
         //         int      idigits=int(MarketInfo(pair.symbol,MODE_DIGITS));
         //         double   BID         =  MarketInfo(pair.symbol,MODE_BID);
         //         double   ASK         =  MarketInfo(pair.symbol,MODE_ASK);
         double   freeMargin=AccountFreeMargin();
         //         double stop=-1,target=-1;
         //         if(category==OP_BUY)
         //           {//BUY
         //            //category=OP_SELL;
         //            defaultColor=BuyColor;
         //            openPrice=ASK-limitPoints;//same format as BID - screen values!
         //            if(information!="ADD")
         //               calcStopTarget(pair,atr,category,BID,ASK,ASK-BID,stop,target,sFactor,tFactor);//Stop and target are in same format as BID - screen values!
         //            else
         //              {
         //               stop=STOP;
         //               target=TARGET;
         //              }
         //
         //            int debug=-1;
         //           }
         //         else if(category==OP_SELL)
         //           {
         //            //category=OP_BUY;
         //            defaultColor=SellColor;
         //            openPrice=BID+limitPoints;
         //            if(information!="ADD")
         //               calcStopTarget(pair,atr,category,BID,ASK,ASK-BID,stop,target,sFactor,tFactor);//Stop and target are in same format as BID - screen values!
         //            else
         //              {
         //               stop=STOP;
         //               target=TARGET;
         //              }
         //           }
         //         else
         //            return "No Buy  No Sell";

         marginInitReq=(pair.betNumPounds*MarketInfo(pair.symbol,MODE_MARGINREQUIRED));

         if(marginInitReq>freeMargin)
           {
            datetime timeNow=TimeCurrent();
            MqlDateTime str1;
            TimeToStruct(timeNow,str1);
            string day = string(str1.day);
            string min =string(str1.min);
            string hour= string(str1.hour);
            return pair.symbol+" *** NOT ENOUGH MARGIN:Needed "+string(DoubleToStr(marginInitReq,2))+" Free Margin "+string(DoubleToStr(freeMargin,2))+ " pair.betNumPounds "+string(DoubleToStr(pair.betNumPounds,2))+" stop  "+(string)stop+" target "+(string)target+" Server: day "+day+" hour "+hour+" min "+min;
           }

         //place trade
         int timeToAdd=10*int(tFrame)*60;

         datetime expireTime=r[1].time+timeToAdd;//minutes
                                                 //Print(pair.betNumPounds);
         string comment="fac: "+DoubleToStr(pair.factor,2)+" csi:"+DoubleToStr(pair.csi,2)+" CT: "+string(pair.creationTime);
         res=WHCOrderSend(pair.symbol,category,pair.betNumPounds,openPrice,slippage,stop,target,comment,magicNumber,expireTime,defaultColor,ticket);
         if(res=="Order Placed")
            return res;
         //Sleep(5000);" TF: ",sCommID,
         //     Print("Attempt Place Order: ",tradeTries," ... ",res);
         tradeTries++;
        }
      while(tradeTries<10);

      SendNotification("Order Placement Error "+res);
      return res;
     }//end
   //+-------------------------------------------------------------------+
   //| Opens positions in Market Execution mode                          |
   //+-------------------------------------------------------------------+
   string WHCOrderSend(string    symbol,
                       int       cmd,
                       double    volume,
                       double    &price,
                       int       slip,
                       double    stoploss,
                       double    takeprofit,
                       string    comment,
                       int       magic,
                       datetime  expiration,
                       color     arrow_color,
                       int       &ticket
                       )
     {
      int      digits=int(MarketInfo(symbol,MODE_DIGITS));
      if(cmd==0)
        {
         price=MarketInfo(symbol,MODE_ASK);
        }
      else if(cmd==1)
        {
         price=MarketInfo(symbol,MODE_BID);
        }
      int check =-1;
      string res="";

      price       = ND(price,digits);
      stoploss    = ND(stoploss,digits);
      takeprofit  = ND(takeprofit,digits);
      Print(" ******* sl ",stoploss," tp  ",takeprofit);
      //--Check that stop / Limit Set
      double orderStop=-1,orderLimit=-1;

      ticket=OrderSend(symbol,cmd,volume,price,slip,stoploss,takeprofit,comment,magic,expiration,arrow_color);
      if(ticket<0)
        {
         check=GetLastError();
         if(check!=ERR_NO_ERROR)
            res="Failed Entry Order: "+ErrorDescription(check)
                +" symbol "+symbol
                +" cmd "+string(cmd)
                +" vol "+string(volume)
                //+" BID "+string(BID)
                //+" ASK "+string(ASK)
                //+" SPREAD "+string(SPREAD)
                +" open "+string(price)
                +" stop "+(string)stoploss
                +" target "+(string)takeprofit
                +" expire "+string(expiration)
                +" comment "+string(comment)
                +" slippage "+(string)slip
                ;
         return res;
        }
      else
        {
         res="Order Placed";
         for(int i=OrdersTotal(); i>=0; i--)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET)==true)
              {
               orderStop  = OrderStopLoss();
               orderLimit = OrderTakeProfit();
               if(orderStop!=stoploss || orderLimit!=takeprofit)
                 {
                  int stopLossSetAttempts=0;
                  do
                    {
                     check=-1;
                     if(!OrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color))
                       {
                        check=GetLastError();
                        if(check!=ERR_NO_ERROR)
                          {
                           stopLossSetAttempts++;
                           res=" Failed To Set Stop Limits "+ErrorDescription(check);
                          }
                       }
                     else
                       {
                        res="Order Placed";
                        break;
                       }
                    }
                  while(( res!="Order Placed") && (stopLossSetAttempts<10));
                 }
              }
           }
        }
      if(res!="Order Placed")
         SendNotification("FAILED TO SET STOPS: "+string(orderStop)+" TARGET: "+string(orderLimit)+" "+symbol);
      return res;
     }
   //+------------------------------------------------------------------+
   //|calculate stop and target                                         |
   //+------------------------------------------------------------------+
   void calcStopTarget(instrument &pair,double atr,int category,double BID,double ASK,double SPREAD,double &stop,double&target,double sFactor,double tFactor)
     {
      double minStop=0,minTarget=0;
      //double atr3= sFactor * atr;
      //Print(atr ," ",pair.symbol);
      if(category==OP_BUY)
        {
         //open at ASK is Set
         stop=ASK -(sFactor*atr);
         target=ASK+(tFactor*atr);
         //calc minimum stop,target & set if need to use it !
         minStop=(((ASK*MathPow(10,pair.digits))-pair.stopLevel)/MathPow(10,pair.digits));
         minTarget=(((ASK*MathPow(10,pair.digits))+pair.stopLevel)/MathPow(10,pair.digits));
         //BUY STOP
         if(stop>minStop)//buy so if stop higher than minStop
           {
            stop=minStop;
            Print("using MIN STOP: ",ASK-minStop," stop:  ",stop);
            if(MathAbs(ASK-minStop)<SPREAD)
               Print("*** MIN STOP < SPREAD ***");
           }
         else
           {
            //        s("using ATR STOP: "+string(stop)+" sFactor*ATR  "+string(sFactor*atr)+" ASK?: "+string((stop+(sFactor*atr)))+" SPREAD: "+string(SPREAD),showStatusTerminal);
            if(MathAbs(ASK-stop)<SPREAD)
               s("*** ATR STOP < SPREAD *** BID-stop: "+string(ASK-stop)+" SPREAD "+string(SPREAD),showStatusTerminal);
           }
         //BUY TARGET
         if(target<minTarget)
           {
            target=minTarget;
            Print("using MIN TARGET: ",ASK-minTarget," target:  ",target);
            if(MathAbs(ASK-minTarget)<SPREAD)
               Print("*** MIN TARGET < SPREAD ***");
           }
         else
           {
            //     s("using ATR TARGET: "+string(target)+" tFactor * ATR  "+string(tFactor*atr)+" ASK?: "+string(target-(tFactor*atr))+" SPREAD: "+string(SPREAD),showStatusTerminal);
            if(MathAbs(ASK-target)<SPREAD)
               s("*** ATR TARGET < SPREAD *** BID-target: "+string((ASK-target))+" SPREAD "+string(SPREAD),showStatusTerminal);
           }
        }
      else if(category==OP_SELL)
        {
         //Open at BID is Set
         stop=BID+(sFactor *atr);
         target=BID -(tFactor*atr);
         //calc minimum stop,target & set if need to use it !
         minStop=(((BID*MathPow(10,pair.digits))+pair.stopLevel)/MathPow(10,pair.digits));
         minTarget=(((BID*MathPow(10,pair.digits))-pair.stopLevel)/MathPow(10,pair.digits));
         //--SELL STOP        
         if(stop<minStop)
           {
            stop=minStop;
            Print("using MIN STOP: ",BID-minStop," stop:  ",stop);
            if(MathAbs(BID-minStop)<SPREAD)
               Print("*** MINSTOP < SPREAD ***");
           }
         else
           {
            //          s("using ATR STOP: "+string(stop)+" atr3  "+string(sFactor*atr)+" BID?: "+string((stop-(sFactor*atr)))+" SPREAD: "+string(SPREAD),showStatusTerminal);
            if(MathAbs(BID-stop)<SPREAD)
               s("*** ATR STOP < SPREAD *** ASK-stop: "+string(BID-stop)+" SPREAD "+string(SPREAD),showStatusTerminal);
           }
         //--SELL TARGET        
         if(target>minTarget)
           {
            target=minTarget;
            Print("using MIN TARGET: ",BID-minTarget," target:  ",target);
            if(MathAbs(BID-minTarget)<SPREAD)
               Print("*** MIN TARGET < SPREAD ***");
           }
         else
           {
            //        s("using ATR TARGET: "+string(target)+" atr  "+string(atr)+" BID?: "+string(target+(tFactor*atr))+" SPREAD: "+string(SPREAD),showStatusTerminal);
            if(MathAbs(BID-target)<SPREAD)
               s("*** ATR TARGET < SPREAD *** ASK-target: "+string(BID-target)+" SPREAD "+string(SPREAD),showStatusTerminal);
           }
        }
     }
   //+------------------------------------------------------------------+
   //| select trade out breach level according to distance from target   |
   //+------------------------------------------------------------------+
   int  findDistanceToTarget(int WTF)
     {
      int selected=NULL;
      double maxTrade = -1;
      double minTrade = INF;
      double percent=-1;
      double OrderOpenP = OrderOpenPrice();
      double OrderTakeP = OrderTakeProfit();
      string OrderS=OrderSymbol();
      int  barGoTo=iBarShift(OrderSymbol(),WTF,OrderOpenTime(),true);
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copiedRates=CopyRates(OrderS,WTF,0,300,rates);
      if(copiedRates>0)
        {
         //start at position (1) not the zero bar
         for(int i=1; i<=barGoTo; i++)
           {
            if(OrderType()==OP_BUY && MqlRatesHasValue(rates,i))
               maxTrade=MathMax(maxTrade,rates[i].high);
            else if(OrderType()==OP_BUY && !MqlRatesHasValue(rates,i))
               s(__FUNCTION__+" OP_BUY index i: "+string(i),showStatusTerminal);
            else if(OrderType()==OP_SELL && MqlRatesHasValue(rates,i))
               minTrade=MathMin(minTrade,rates[i].low);
            else if(OrderType()==OP_SELL && !MqlRatesHasValue(rates,i))
               s(__FUNCTION__+" OP_SELL index i: "+string(i),showStatusTerminal);
            else
               s("Order type is not OP_BUY or OP_SELL ->Programming issue. ",true);
           }
        }
      else
        {
         s("RATES IS < ZERO: EXITING SET INSTRUMENT STOPS",true);
         return NULL;
        }
      double   BID         =  MarketInfo(OrderSymbol(),MODE_BID);
      double   ASK         =  MarketInfo(OrderSymbol(),MODE_ASK);
      //should be spread at open         
      double spread=ASK-BID;
      //Calculate the targets and return the indicator index fast, slow or middle
      if(OrderType()==OP_BUY)
        {
         percent=(( maxTrade-(OrderOpenP-spread))/(OrderTakeP-(OrderOpenP-spread)))*100;
         //Print("MAXTRADE PERCENT: ",OrderSymbol()+" % "+string(percent));
        }
      else if(OrderType()==OP_SELL)
        {
         percent=(((OrderOpenP+spread)-minTrade)/((OrderOpenP+spread)-OrderTakeP))*100;
         // Print("MINTRADE PERCENT: ",OrderSymbol()+" % "+string(percent));
        }
      if(percent<50)
         return -1;//3*ATR
      else if((percent>50) && (percent<65))//slow ema
      return 0;//SEMA
      else if((percent>65) && (percent<85))//middle ema
      return 1; //MEMA
      else // > 85 fast ema
      return 2; //FEMA        
     }
   //+--------------------------------------------------------------------+
   //|Check if Conditions are right for ordering more of this Instrument  |
   //+--------------------------------------------------------------------+
   bool checkTradeStatus(int WTF)
     {
      if(findDistanceToTarget(WTF)==0)
        {
         s("findDistanceToTarget: "+string(findDistanceToTarget(WTF)),showStatusTerminal);
         return true;
        }
      return false;
     }
   //+------------------------------------------------------------------+
   //|Check Open Trade Conditions                                       |
   //+------------------------------------------------------------------+     
   //   string checkTradeAction(int shift,instrument *INS,int WTF,
   //                           int FEMA=9,
   //                           int MEMA=18,
   //                           int SEMA=38,
   //                           int ATRPERIOD=14,
   //                           int KPeriod=5,
   //                           int DPeriod=3,
   //                           int Slowing=3,
   //                           int Method=MODE_EMA,
   //                           int PF=0,
   //                           int LowStochLevel=20,
   //                           int HighStochLevel=80,
   //                           int ADXPeriod=14,
   //                           int PriceFieldADX=0,
   //                           int PeriodRSI=5,
   //                           int LevelBottom=30,
   //                           int LevelTop=70,
   //                           int ConsiderationHighLevel=50,
   //                           int ConsiderationLowLevel = 50,
   //                           int MaxBarsDraw=5000,
   //                           bool DrawTrades= true)
   //     {
   //      string SYMBOL=INS.symbol;
   //      MqlRates rates[];
   //      ArraySetAsSeries(rates,true);
   //      int copied=CopyRates(SYMBOL,WTF,0,5,rates);
   //      if(copied>0)
   //        {
   //         ENUM_TIMEFRAMES enum0=tfEnumFull[findIndexPeriod(WTF)],enum1=tfEnumFull[findIndexPeriod(WTF)+1],enum2=tfEnumFull[findIndexPeriod(WTF)+2],enum3=tfEnumFull[findIndexPeriod(WTF)+3];
   //         double tf3HTFRSIStatus=NULL,tf2HTFMAStatus=NULL,tf3HTFADXLong=NULL,tf3HTFADXShort=NULL,tf3HTFADXClose=NULL;
   //         tf2HTFMAStatus=iCustom(SYMBOL,WTF,"HTFMA",enum2,FEMA,MEMA,SEMA,FEMA+MEMA,2,shift);
   //         //status RSI 0,1 EMPTY_VALUE
   //         tf3HTFRSIStatus=iCustom(SYMBOL,WTF,"HTFRSI",enum3,PeriodRSI,LevelBottom,LevelTop,ConsiderationHighLevel,ConsiderationLowLevel,MaxBarsDraw,1,shift);
   //         tf3HTFADXLong=iCustom(SYMBOL,WTF,"HTFADX",enum3,ADXPeriod,PriceFieldADX,MaxBarsDraw,0,shift);
   //         tf3HTFADXShort=iCustom(SYMBOL,WTF,"HTFADX",enum3,ADXPeriod,PriceFieldADX,MaxBarsDraw,1,shift);
   //         tf3HTFADXClose=iCustom(SYMBOL,WTF,"HTFADX",enum3,ADXPeriod,PriceFieldADX,MaxBarsDraw,2,shift);
   //         Print(SYMBOL,"   ","   tf3HTFRSIStatus: ",tf3HTFRSIStatus,"   tf3HTFRSIStatus: ",tf3HTFRSIStatus,"   tf3HTFADXLong: ",tf3HTFADXLong,"   tf3HTFADXShort: ",tf3HTFADXShort,"   tf3HTFADXClose: ",tf3HTFADXClose);
   //         Print("*** INS.tradeInfo.state: ****** ",INS.tradeInfo.state);
   //         // }
   //         double point=MarketInfo(SYMBOL,MODE_POINT);
   //         double digits=MarketInfo(SYMBOL,MODE_DIGITS);
   //         double bid=MarketInfo(SYMBOL,MODE_BID);
   //         double ask=MarketInfo(SYMBOL,MODE_ASK);
   //         //shift
   //
   //         if((tf3HTFADXLong!=EMPTY_VALUE) && (tf2HTFMAStatus==0) && (tf3HTFRSIStatus!=1))
   //            //BUY
   //           {
   //            // INS.tradeInfo.state="B";
   //            //  INS.tradeInfo.oPrice= rates[shift].close;
   //            // INS.tradeInfo.oTime = rates[shift].time;
   //            // if(DrawTrades)
   //            //  drawTrendStopTarget(SYMBOL,open[shift],shift,true,false);
   //            return "BUY";
   //           }
   //         else if((tf3HTFADXShort!=EMPTY_VALUE) && (tf2HTFMAStatus==1) && (tf3HTFRSIStatus!=0))
   //           {
   //            //Print("TIME: ",time0," SELL tf3HTFADXShort: ",tf3HTFADXShort," tf2HTFMAStatus: ",tf2HTFMAStatus," tf3HTFRSIStatus: ",tf3HTFRSIStatus);
   //
   //            // INS.tradeInfo.state="S";
   //            // INS.tradeInfo.oPrice= rates[shift].close;
   //            //  INS.tradeInfo.oTime = rates[shift].time;
   //            //if(DrawTrades)
   //            //   drawTrendStopTarget(SYMBOL,rates[shift].open,shift,false,true);
   //            return "SELL";
   //           }
   //         else if((tf3HTFADXClose!=EMPTY_VALUE) || (tf3HTFRSIStatus<=1))
   //           {
   //            double spd=(ask-bid);
   //            double openPrice=NULL;
   //            double closePrice = NULL;
   //            datetime openTime = INS.tradeInfo.oTime;
   //            datetime closeTime=rates[shift].time;
   //            double arrowLocation=NULL;
   //            double points=NULL;
   //            //Print("TIME: ",time0," CLOSE ",tInfo.state, " tf3HTFADXClose: ",tf3HTFADXClose," tf2HTFMAStatus: ",tf2HTFMAStatus," tf3HTFRSIStatus: ",tf3HTFRSIStatus," ExtArrowStatus[shift]: ",ExtArrowStatus[shift]);
   //            if(INS.tradeInfo.state=="B")
   //              {
   //               arrowLocation=rates[shift].low-point*100;
   //               //    openPrice = INS.tradeInfo.oPrice;
   //               //    closePrice=rates[shift].close-spd;
   //               //    points=closePrice-INS.tradeInfo.oPrice;
   //               //    INS.tradeInfo.state=NULL;
   //               //    INS.tradeInfo.oPrice= NULL;
   //               //     INS.tradeInfo.oTime = NULL;
   //               //if(DrawTrades)
   //               // drawCloseTrade(shift,openPrice,closePrice,openTime,closeTime,bid,ask,arrowLocation,points,digits);
   //               return "CLOSE";
   //              }
   //            else if(INS.tradeInfo.state=="S")
   //              {
   //               arrowLocation=rates[shift].high+point*100;
   //               //     openPrice = INS.tradeInfo.oPrice;
   //               //     closePrice=rates[shift].close+spd;
   //               //     points=INS.tradeInfo.oPrice-closePrice;
   //               //     INS.tradeInfo.state=NULL;
   //               //     INS.tradeInfo.oPrice= NULL;
   //               //     INS.tradeInfo.oTime = NULL;
   //               //if(DrawTrades)
   //               // drawCloseTrade(shift,openPrice,closePrice,openTime,closeTime,bid,ask,arrowLocation,points,digits);
   //               return "CLOSE";
   //              }
   //           }
   //        }
   //      return NULL; //No Action  
   //     }
   //+------------------------------------------------------------------+
   //|closeTrade                                                        |
   //+------------------------------------------------------------------+
   //   void drawCloseTrade(int shift,double openPrice, double closePrice,datetime openTime,datetime closeTime,double bid,double ask,double arrowLocation,double points,double digits)
   //     {
   //      tInfo.cProfit+=points;
   //      bool buySell=(points>=0);
   //
   //      drawTradeLine(openPrice,closePrice,openTime,closeTime,buySell);
   //      //Set TextBox Names
   //      string pName="pIndex "+TimeToStr(closeTime)+" "+string(shift)+" "+string(bid)+" "+instrument;
   //      //+------------------------------------------------------------------+
   //      //|                                                                  |
   //      //+------------------------------------------------------------------+
   //      if(ObjectFind(ChartID(),pName)<0)
   //        {
   //         if(!ObjectCreate(ChartID(),pName,OBJ_TEXT,0,closeTime,arrowLocation))
   //           {
   //            Print(__FUNCTION__,": failed to create a pName! Error = ",ErrorDescription(GetLastError()));
   //           }
   //        }
   //      string str=setDisplayTexts(points,tInfo.cProfit,int(digits));
   //      ObjectSetText(pName,str,fontSize,fontType,fontColorIndex);
   //
   //      ExtCumProfit[shift]=tInfo.cProfit;
   //     }
   //+------------------------------------------------------------------+
   //| drawTradeLine                                                    |
   //+------------------------------------------------------------------+
   //void drawTradeLine(double openPrice,double closePrice,datetime openTime,datetime closeTime,bool BS)
   //  {
   //   string tName="tIndex "+string(closeTime);
   //   //+------------------------------------------------------------------+
   //   //|                                                                  |
   //   //+------------------------------------------------------------------+
   //   if(ObjectFind(ChartID(),tName)<0)
   //     {
   //      if(!ObjectCreate(ChartID(),tName,OBJ_TREND,0,openTime,openPrice,closeTime,closePrice))
   //         Print(__FUNCTION__,": failed to create a trend Line! Error = ",ErrorDescription(GetLastError())+" closeTime "+string(closeTime)+" closePrice "+string(closePrice));
   //      else
   //        {
   //         color clr=clrNONE;
   //         if(BS == true )
   //            clr=fontColorProfit;
   //         else
   //            clr=fontColorLoss;
   //         ObjectSet(tName,OBJPROP_COLOR,clr);
   //         ObjectSet(tName,OBJPROP_STYLE,STYLE_SOLID);
   //         ObjectSet(tName,OBJPROP_WIDTH,2);
   //         ObjectSet(tName,OBJPROP_RAY_RIGHT,false);
   //        }
   //     }
   //  }
   ////+------------------------------------------------------------------+
   //| setDisplayTexts                                                  |
   //+------------------------------------------------------------------+  
   //string setDisplayTexts(double p,double cp,int dig)
   //  {
   //   string val1=DoubleToStr(p,dig);
   //   string val2=DoubleToStr(cp,dig);
   //   string str=NULL;
   //   str=StringConcatenate("P: ",val1);
   //   str=StringConcatenate(str,"  CP: ",val2);
   //   return str;
   //  }
   //+------------------------------------------------------------------+
   //|Close under SAR conditions                                        |
   //+------------------------------------------------------------------+     
   //   void moveStopZero()
   //     {
   //      double closePrice=-1;int digits=-1;
   //      for(int c=OrdersTotal()-1; c>=0; c--)
   //        {
   //         if
   //         (
   //          OrderSelect(c,SELECT_BY_POS) // Only my orders w/
   //          // my magic number or zero for a trade you opened          
   //          && ((OrderMagicNumber()==magicNumber) || (OrderMagicNumber()==0))
   //          && ((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
   //          )
   //           {
   //            double   vdigits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   //            double triggerMoveBuy=OrderTakeProfit()-OrderOpenPrice();
   //            triggerMoveBuy=triggerMoveBuy/2+OrderOpenPrice();
   //            double triggerMoveSell=OrderOpenPrice()-OrderTakeProfit();
   //            triggerMoveSell= OrderOpenPrice()-triggerMoveSell/2;
   //            if((OrderType()==OP_BUY) &&(OrderOpenPrice()!= OrderStopLoss()) &&(OrderClosePrice()>= triggerMoveBuy))
   //              {
   //               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),ND(OrderOpenPrice(),int(vdigits)),OrderTakeProfit(),0,BuyColor);
   //               Print(OrderSymbol()+" BUY moved: "+string(res)+" "+string(OrderStopLoss()));
   //               SendNotification(OrderSymbol()+" BUY moved: "+string(res)+" "+string(OrderStopLoss()));
   //              }
   //            else if((OrderType()==OP_SELL) && (OrderOpenPrice()!=OrderStopLoss()) && (OrderClosePrice()<=triggerMoveSell))
   //              {
   //               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),ND(OrderOpenPrice(),int(vdigits)),OrderTakeProfit(),0,SellColor);
   //               Print(OrderSymbol()+" SELL moved: "+string(res)+" "+string(OrderStopLoss()));
   //               SendNotification(OrderSymbol()+" SELL moved: "+string(res)+" "+string(OrderStopLoss()));
   //              }
   //           }
   //        }
   //     }
   //   //+------------------------------------------------------------------+
   //   //| checkStopMove Pass number of points to move stop                 |
   //   //+------------------------------------------------------------------+
   //   void  checkMoveStop(double updateGreaterPoints,double ifPointsGreater)
   //     {
   //      for(int c=OrdersTotal()-1; c>=0; c--)
   //         // my magic number or zero for a trade you opened          
   //         if(OrderSelect(c,SELECT_BY_POS) && ((OrderMagicNumber()==magicNumber) || (OrderMagicNumber()==0)) && ((OrderType()==OP_BUY) || (OrderType()==OP_SELL)))
   //            moveStop(OrderTicket(),OrderType(),OrderSymbol(),updateGreaterPoints,ifPointsGreater);
   //     }//order select
   //   //+------------------------------------------------------------------+
   //   //| move stop                                                        |
   //   //| nEED TO PUT IN SOMETHING LIKE PROFTIT > % orIF POINTS > 300 THEN.|
   //   //+------------------------------------------------------------------+
   //   void moveStop(int ticket,int type,string symbol,double stpMove,double pointsGreater)
   //     {
   //      //ifProfit < pointsGreater
   //      //return;
   //      double newStop =-1;
   //      double   vpoint=MarketInfo(symbol,MODE_POINT);
   //      double   vdigits=MarketInfo(symbol,MODE_DIGITS);
   //      //where is the price?
   //      if(type==OP_BUY)
   //        {
   //         double   ASK=MarketInfo(symbol,MODE_ASK);
   //         if((ASK-OrderStopLoss())>=(stpMove*vpoint))
   //           {//move the stop to trail by stopPoints
   //            newStop=ASK-stpMove*vpoint;
   //            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),ND(newStop,int(vdigits)),OrderTakeProfit(),0,BuyColor);
   //            Print("BUY moved: "+string(res)+" "+string(OrderStopLoss()));
   //            SendNotification("BUY moved: "+string(res)+" "+string(OrderStopLoss()));
   //           }
   //        }
   //      if(type==OP_SELL)
   //        {
   //         double   BID=MarketInfo(symbol,MODE_BID);
   //         if((OrderStopLoss()-BID)>=(stpMove*vpoint))
   //           {//move the stop to trail by stopPoints
   //            newStop=BID+stpMove*vpoint;
   //            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),ND(newStop,int(vdigits)),OrderTakeProfit(),0,BuyColor);
   //            Print("SELL moved: "+string(res)+" "+string(OrderStopLoss()));
   //            SendNotification("SELL moved: "+string(res)+" "+string(OrderStopLoss()));
   //           }
   //        }
   //     }
   //   //+------------------------------------------------------------------+
   //   //|Close under SAR conditions                                        |
   //   //+------------------------------------------------------------------+     
   //   void closeMoveSAR(int htf,int ADXPeriod,double SARStep,double SARMax,double MAXBars)
   //     {
   //      double closePrice=-1;int digits=-1;
   //      for(int c=OrdersTotal()-1; c>=0; c--)
   //        {
   //         if
   //         (
   //          OrderSelect(c,SELECT_BY_POS) // Only my orders w/
   //          // my magic number or zero for a trade you opened          
   //          && ((OrderMagicNumber()==magicNumber) || (OrderMagicNumber()==0))
   //          && ((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
   //          )
   //           {
   //            if(OrderType()==OP_BUY)
   //               closePrice=MarketInfo(OrderSymbol(),MODE_ASK);
   //            else
   //               closePrice=MarketInfo(OrderSymbol(),MODE_BID);
   //            digits=int(MarketInfo(OrderSymbol(),MODE_DIGITS));
   //            double SAR=iCustom(OrderSymbol(),htf,"HTFSAR",htf,ADXPeriod,0,MAXBars,SARStep,SARMax,0,1);
   //            //get stop
   //            if(OrderType()==OP_BUY)
   //              {
   //               if(closePrice<=SAR)
   //                  //close it
   //                  closeMe(closePrice,digits);
   //               else
   //                  moveStop(closePrice,digits,SAR);
   //              }
   //            else
   //              {
   //               if(closePrice>=SAR)
   //                  //close it
   //                  closeMe(closePrice,digits);
   //               else
   //                  moveStop(closePrice,digits,SAR);
   //              }
   //           }
   //        }
   //     }
   //   void closeMe(double closePrice,int digits)
   //     {
   //      if(OrderClose(OrderTicket(),OrderLots(),closePrice,250,Violet))
   //        {
   //         s(__FUNCTION__+" Success Closed ON SAR"+"+sym+"+DoubleToStr(closePrice,digits)+" TIME: "+TimeToStr(Time[0]),true);;
   //         //  SendNotification("Success Closed ON SAR: "+OrderSymbol()+" @: "+DoubleToStr(closePrice,digits));
   //        }
   //      else
   //        {
   //
   //         s(__FUNCTION__+" ***** FAILURE TO CLOSE ON SAR*****: "+OrderSymbol()+" "+ErrorDescription(GetLastError()),true);
   //         SendNotification("***** FAILURE TO CLOSE ON SAR*****: "+OrderSymbol()+" @: "+DoubleToStr(closePrice,digits)+" "+ErrorDescription(GetLastError()));
   //         ResetLastError();
   //        }
   //     }
   //   void moveStop(double closePrice,int digits,double sar)
   //     {
   //      if(OrderModify(OrderTicket(),closePrice,sar,OrderTakeProfit(),OrderExpiration(),clrViolet))
   //        {
   //         s(__FUNCTION__+" Success Modified SAR STOP: "+OrderSymbol()+" "+DoubleToStr(closePrice,digits)+" TIME: "+TimeToStr(Time[0]),true);;
   //         //    SendNotification("Success Modified SAR STOP: "+OrderSymbol()+" @: "+DoubleToStr(closePrice,digits));
   //        }
   //      else
   //        {
   //         s(__FUNCTION__+" ***** FAILED TO MOVE SAR STOP *****: "+OrderSymbol()+" "+ErrorDescription(GetLastError()),true);
   //         SendNotification("***** FAILED TO MOVE SAR STOP *****: "+OrderSymbol()+" @: "+DoubleToStr(closePrice,digits)+" "+ErrorDescription(GetLastError()));
   //         ResetLastError();
   //        }
   //     }
   //+------------------------------------------------------------------+
   //|Close the trade if No furtherment                                 |
   //   //+------------------------------------------------------------------+     
   //   void closeTrend(int TTF,int MaxBarsDraw,int ADXPeriod,int PriceFieldADX,int PeriodRSI=5,int LevelBottom=30,int LevelTop=70,int ConsiderationHighLevel=50,int ConsiderationLowLevel=50)
   //     {
   //      double price=-1;int digits=-1;
   //      //   double goClose0=EMPTY_VALUE,goClose1=EMPTY_VALUE,goStatus0=EMPTY_VALUE,goStatus1=EMPTY_VALUE,goStatus2=EMPTY_VALUE;
   //      for(int c=OrdersTotal()-1; c>=0; c--)
   //        {
   //         if
   //         (
   //          OrderSelect(c,SELECT_BY_POS) // Only my orders w/
   //          // my magic number or zero for a trade you opened          
   //          && ((OrderMagicNumber()==magicNumber) || (OrderMagicNumber()==0))
   //          && ((OrderType()==OP_BUY) || (OrderType()==OP_SELL))
   //          )
   //           {
   //
   //            //goClose1=iCustom(OrderSymbol(),WTF,"StrendIndicator",DrawTrades,StopFactor,TargetFactor,MaxBarsDraw,ClrLong,ClrShort,FEMA,MEMA,SEMA,atrPeriod,KPeriod,DPeriod,Slowing,Method,Price_Field,LowStochLevel,HighStochLevel,ADXPeriod,PriceFieldADX,4,1);
   //
   //            double tf3HTFADXClose=iCustom(OrderSymbol(),TTF,"HTFADX",TTF,ADXPeriod,PriceFieldADX,MaxBarsDraw,5,1);
   //            double tf3HTFRSIClose=iCustom(OrderSymbol(),TTF,"HTFRSI",TTF,PeriodRSI,LevelBottom,LevelTop,ConsiderationHighLevel,ConsiderationLowLevel,MaxBarsDraw,1,1);
   //            if((tf3HTFADXClose==EMPTY_VALUE) && (tf3HTFRSIClose==EMPTY_VALUE))
   //               continue;
   //            if(OrderType()==OP_BUY)
   //               price=MarketInfo(OrderSymbol(),MODE_ASK);
   //            else
   //               price=MarketInfo(OrderSymbol(),MODE_BID);
   //            digits=int(MarketInfo(OrderSymbol(),MODE_DIGITS));
   //            if(OrderClose(OrderTicket(),OrderLots(),price,250,Violet))
   //              {
   //               s(__FUNCTION__+" ADXCLOSE "+string(tf3HTFADXClose)+" RSICLOSE "+string(tf3HTFRSIClose)+" Success Closed "+"+sym+"+DoubleToStr(price,digits)+" TIME: "+TimeToStr(Time[0]),true);
   //               SendNotification("Success Closed: "+OrderSymbol()+" ADXCLOSE "+string(tf3HTFADXClose)+" RSICLOSE "+string(tf3HTFRSIClose)+" @: "+DoubleToStr(price,digits));
   //              }
   //            else
   //              {
   //               s(__FUNCTION__+" ***** FAILURE TO CLOSE *****: "+OrderSymbol()+" ADXCLOSE "+string(tf3HTFADXClose)+" RSICLOSE "+string(tf3HTFRSIClose),true);
   //               SendNotification("***** FAILURE TO CLOSE *****: "+OrderSymbol()+" ADXCLOSE "+string(tf3HTFADXClose)+" RSICLOSE "+string(tf3HTFRSIClose)+" @: "+DoubleToStr(price,digits));
   //              }
   //           }
   //        }
   //     }
   //+------------------------------------------------------------------+
   //|Stop out trades experiencing rapid volatility changes             |
   //+------------------------------------------------------------------+
   //void tradeMeOut(int p,int FEMA,int MEMA,int SEMA,datetime &pTime)
   //  {
   //   datetime timeGMT=TimeGMT();
   //   if(timeGMT-pTime>20)
   //     {
   //      pTime=timeGMT;
   //        {
   //         for(int pos=OrdersTotal()-1; pos>=0; pos--)
   //            if(OrderSelect(pos,SELECT_BY_POS) // Only my orders w/
   //               && OrderMagicNumber()==MAGICMA) // my magic number)
   //               trade.checkMinuteClose(p,FEMA,MEMA,SEMA);
   //        }
   //     }
   //  }
   //+------------------------------------------------------------------+
   //|check that the trade needs to close ticks                         |
   //+------------------------------------------------------------------+  
   //   void checkMinuteClose(int period,int FEMA,int MEMA,int SEMA)
   //     {
   //      //stop parameters
   //      int tries=7,pause=300;
   //      bool res = false;
   //      //test parameters
   //      double BID=0,ASK=0,SPREAD=0,bidHTF_1_100=0,price=-1;
   //      int mBarsDraw=5000,htfIndex=1,digits=0;//periods above 0,1,2;               
   //      bool closeIt=false;
   //      string symbol=OrderSymbol();
   //      digits=int(MarketInfo(symbol,MODE_DIGITS));
   //
   //      if(OrderType()==OP_BUY)
   //        {
   //         price=MarketInfo(symbol,MODE_ASK);
   //         BID=MarketInfo(symbol,MODE_BID);
   //         bidHTF_1_100=iCustom(symbol,period,"maHTFs",htfIndex,FEMA,MEMA,SEMA,mBarsDraw,2,1);
   //         closeIt=(BID<bidHTF_1_100);
   //         if(closeIt)
   //            s(__FUNCTION__+" BUY ORDER: "+symbol+"BID @: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits)+" closeIt: "+string(closeIt),true);
   //         else
   //            s(__FUNCTION__+" NO CLOSE BUY ORDER: "+symbol+"BID @: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits)+" closeIt: "+string(closeIt),false);
   //        }
   //      else if(OrderType()==OP_SELL)
   //        {
   //         price=MarketInfo(symbol,MODE_BID);
   //         BID=MarketInfo(symbol,MODE_BID);
   //         bidHTF_1_100=iCustom(symbol,period,"maHTFs",htfIndex,FEMA,MEMA,SEMA,mBarsDraw,2,1);
   //         closeIt=(BID>bidHTF_1_100);
   //         if(closeIt)
   //            s(__FUNCTION__+" SELL ORDER: "+symbol+"BID @: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits)+" closeIt: "+string(closeIt),true);
   //         else
   //            s(__FUNCTION__+"NO CLOSE SELL ORDER: "+symbol+"BID @: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits)+" closeIt: "+string(closeIt),false);
   //        }
   //      if(closeIt)
   //        {
   //         for(int pos=OrdersTotal()-1; pos>=0; pos--) if(
   //            OrderSelect(pos,SELECT_BY_POS) // Only my orders w/
   //            && OrderMagicNumber()==magicNumber    // my magic number
   //            && OrderSymbol()==Symbol())
   //              {
   //               if(OrderClose(OrderTicket(),OrderLots(),price,50,Violet))
   //                 {
   //                  s(__FUNCTION__+" Success Closed: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits),showStatusTerminal);
   //                  SendNotification(__FUNCTION__+" Success Closed: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits));
   //                  return;
   //                 }
   //               else
   //                 {
   //                  Sleep(pause);
   //                  continue;
   //                 }
   //              }
   //            s(__FUNCTION__+" ***** FAILURE TO CLOSE *****: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits),showStatusTerminal);
   //         //notify mobile phone
   //         SendNotification(__FUNCTION__+" ***** FAILURE TO CLOSE *****: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bidHTF_1_100,digits));
   //         return;
   //        }
   //      //s("ALL GOOD: "+symbol+"@BID: "+DoubleToStr(BID,digits)+" LEVEL TO BREACH: "+DoubleToStr(bidHTF_1_18,digits),showStatusTerminal);
   //      //SendNotification("ALL GOOD: "+symbol+"@: "+DoubleToStr(BID,digits)+" LEVEL TO BREACH: "+DoubleToStr(bidHTF_1_18,digits));
   //     }
   //+-----------------------------------------------------------------------------+
   //|End Trades for Instruments that have breached stop conditions                |
   //|extern int Method=0;  // 0 - 2NR, 1 - 3NR, 2 - 4NR, 3 - 8NR, 4 - Customizable|   
   //+-----------------------------------------------------------------------------+ 
   //   void  wideRangeBar(int tf,string MS,int Meth,int sample,int length,bool swr,bool snr,int db,int fema,int mema,int sema)
   //     {
   //      //int total=OrdersTotal();
   //      //int item=-1;
   //      ////loop around orders    
   //      //for(item=total; item>0; item--)//all orders         
   //
   //      for(int pos=OrdersTotal()-1; pos>=0; pos--) if(
   //         OrderSelect(pos,SELECT_BY_POS) // Only my orders w/
   //         && OrderMagicNumber()==MAGICMA    // my magic number
   //         && OrderSymbol()==Symbol())
   //           {
   //            double arrow=iCustom(OrderSymbol(),tf,"crabel",MS,Meth,sample,length,swr,snr,db,0,1);
   //            double slow=iCustom(OrderSymbol(),tf,"maHTFs",1,fema,mema,sema,fema+mema,2,1);
   //
   //            if(arrow!=EMPTY_VALUE)
   //              {
   //               Print("********* HAVE WIDE RANGE BAR -> Arrow: "+string(arrow));
   //               // Print(" BEFORE Open[1]: "+string(Open[1])+" close[1] "+string(Close[1]));            
   //               if(((Open[1]-Close[1])>0) && (OrderType()==OP_BUY) && (slow>Close[1]))//down candle
   //                  closeIt(OrderSymbol(),"Crabel WIDE BAR",MODE_BID,slow);
   //               else if(((Open[1]-Close[1])<0) && (OrderType()==OP_SELL) && (slow<Close[1]))////up candle              
   //               closeIt(OrderSymbol(),"Crabel WIDE BAR",MODE_ASK,slow);
   //               else
   //                  s("Nothing to do, Open[1]: "+string(Open[1])+" close[1] "+string(Close[1])+" mEMA: "+string(slow)+" OType: "+string(OrderType())+" OP_BUY: "+string(OP_BUY)+" OP_SELL: "+string(OP_SELL),true);
   //              }
   //           }
   //        } 
   //+------------------------------------------------------------------+
   //|End Trades for Instruments that have breached wide Bars           |
   //+------------------------------------------------------------------+     
   //void closeIt(string sym,string closeType,int mode,double medium)
   //  {
   //   //stop parameters
   //   int digits=int(MarketInfo(sym,MODE_DIGITS));
   //   int tries=7,pause=300;
   //   bool res = false;
   //   double price=-1;
   //   for(int c=OrdersTotal()-1; c>=0; c--) if(
   //      OrderSelect(c,SELECT_BY_POS) // Only my orders w/
   //      && OrderMagicNumber()==MAGICMA    // my magic number
   //      && OrderSymbol()==Symbol())
   //        {
   //         price=MarketInfo(sym,mode);
   //         if(OrderClose(OrderTicket(),OrderLots(),price,50,Violet))
   //           {
   //            s(__FUNCTION__+" Success Closed "+closeType+": "+sym+"@: "+DoubleToStr(price,digits)+" close[1] "+string(Close[1])+" mEMA: "+string(medium),showStatusTerminal);
   //            s(__FUNCTION__+" PROFIT £: "+string(OrderProfit()),showStatusTerminal);
   //            // SendNotification("Success Closed: "+sym+" @: "+DoubleToStr(price,digits));
   //            return;
   //           }
   //         else
   //           {
   //            Sleep(pause);
   //            continue;
   //           }
   //        }
   //      s(__FUNCTION__+" ***** FAILURE TO CLOSE *****: "+sym);
   //   //notify mobile phone       
   //   SendNotification("***** FAILURE TO CLOSE *****: "+sym+" @: "+DoubleToStr(price,digits));
   //   return;
   //  }
   //+------------------------------------------------------------------+
   //| Exit trade below acceptible risk                                 |
   //+------------------------------------------------------------------+
   //bool  stopOut(int id,double price)
   //  {
   //   bool result=OrderClose(OrderTicket(),OrderLots(),price,50,Violet);
   //   return result;
   //  }       
  };
//+------------------------------------------------------------------+
//|Element of tradeObj                                               |
//+------------------------------------------------------------------+
//class tradeInstrument : public CObject
//  {
//   double ticket;
//   string            whatLevel;
//public:
//   //+------------------------------------------------------------------+
//   //|Constructor                                                       |
//   //+------------------------------------------------------------------+    
//   void tradeInstrument(double TICKET)
//     {
//      whatLevel = NULL;
//      ticket = TICKET;
//     }
//   //+------------------------------------------------------------------+
//   //|Destructor                                                        |
//   //+------------------------------------------------------------------+      
//   void ~tradeInstrument()
//     {
//     //dont see this because trade object destroys them?
//     Print("Destroying tradeInstrument, ticket Number: ",ticket);
//     }
//  }; 
//+------------------------------------------------------------------+
//|End Trades for Instruments that have breached stop conditions     |
//+------------------------------------------------------------------+
//void  stopBreachTrades(int WTF,int FEMA=9,int MEMA=18,int SEMA=38,)
//  {
//   int total=OrdersTotal();
//   int item=0;
//   for(item=total; item>=0; item--)//all orders      
//     {
//      if(OrderSelect(item,SELECT_BY_POS,MODE_TRADES)==true)
//         checkClose(WTF,FEMA,MEMA,SEMA);
//     }//order select             
//  }
//+------------------------------------------------------------------+
//|check that the trade needs to close                               |
//+------------------------------------------------------------------+  
//   void checkClose(int WTF,int FEMA,int MEMA,int SEMA)
//     {
//      //stop parameters
//      int tries=7,pause=300;
//      bool res = false;
//      //test parameters
//      double BID=0,ASK=0,SPREAD=0,bid_HTF_SELECT=0;
//      int mBarsDraw=5000,htfIndex=1,digits=0;//periods above 0,1,2;               
//      bool closeIt=false;
//      string symbol=OrderSymbol();
//      digits=int(MarketInfo(symbol,MODE_DIGITS));
//
//      //findDistanceToTarget() 
//      int SELECT=findDistanceToTarget(WTF);
//      if(SELECT==-1)
//        {
//         s(symbol+" SELECT is < 20% so 3* ATR is in PLAY ",true);
//         return;
//        }
//      if(OrderType()==OP_BUY)
//        {
//         BID=MarketInfo(symbol,MODE_BID);
//         //penultimate argument is either 0,1 or 2 to reflect FEMA (9), MEMA (18) or SEMA (38)      
//         bid_HTF_SELECT=iCustom(symbol,WTF,"maHTFs",htfIndex,FEMA,MEMA,SEMA,mBarsDraw,SELECT,1);
//         closeIt=(BID<bid_HTF_SELECT);
//         s(__FUNCTION__+" BUY ORDER: "+symbol+"BID @: "+DoubleToStr(BID,digits)+" level breach (BID): "+DoubleToStr(bid_HTF_SELECT,digits)+" SELECT: "+string(SELECT)+" closeIt: "+string(closeIt),true);
//        }
//      else if(OrderType()==OP_SELL)
//        {
//         BID=MarketInfo(symbol,MODE_BID);
//         bid_HTF_SELECT=iCustom(symbol,WTF,"maHTFs",htfIndex,FEMA,MEMA,SEMA,mBarsDraw,SELECT,1);
//         closeIt=(BID>bid_HTF_SELECT);
//         s(__FUNCTION__+" SELL ORDER: "+symbol+"BID @: "+DoubleToStr(BID,digits)+" level breach (BID): "+DoubleToStr(bid_HTF_SELECT,digits)+" SELECT: "+string(SELECT)+" closeIt: "+string(closeIt),true);
//        }
//      if(closeIt)
//        {
//         for(int c=0; c<=tries; c++)
//           {
//            BID=MarketInfo(symbol,MODE_BID);
//            res= stopOut(OrderTicket(),BID);
//            if(res==true)
//              {
//               s("Success Closed: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bid_HTF_SELECT,digits),showStatusTerminal);
//               SendNotification("Success Closed: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bid_HTF_SELECT,digits));
//               return;
//              }
//            else
//              {
//               Sleep(pause);
//               continue;
//              }
//           }
//         s("***** FAILURE TO CLOSE *****: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bid_HTF_SELECT,digits)+" SELECT "+string(SELECT),showStatusTerminal);
//         //notify mobile phone
//         SendNotification("***** FAILURE TO CLOSE *****: "+symbol+"@: "+DoubleToStr(BID,digits)+" level breach: "+DoubleToStr(bid_HTF_SELECT,digits)+" SELECT "+string(SELECT));
//         return;
//        }
//      //s("ALL GOOD: "+symbol+"@BID: "+DoubleToStr(BID,digits)+" LEVEL TO BREACH: "+DoubleToStr(bid_HTF_1_SELECT,digits),showStatusTerminal);
//      //SendNotification("ALL GOOD: "+symbol+"@: "+DoubleToStr(BID,digits)+" LEVEL TO BREACH: "+DoubleToStr(bid_HTF_1_SELECT,digits));
//     }           
//+------------------------------------------------------------------+
//| Global                                                           |
//+------------------------------------------------------------------+
//tradeObj         *trade;
//+------------------------------------------------------------------+
