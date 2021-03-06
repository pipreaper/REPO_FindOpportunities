//+------------------------------------------------------------------+
//|                                                   instrument.mqh |
//|                                    Copyright 2017, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "2.12"
#property strict
#include <Arrays\List.mqh>
#include <WaveLibrary.mqh>
class instrument;
//+------------------------------------------------------------------+
//|Global Variables                                                  |
//+------------------------------------------------------------------+
double LIBOR=0.5;//%LIBOR stocks, commodities, Indices
double overNightPercent=3.0;//%Over Night Broker stocks, commodities, Indices
double adminCharge = 0.0054;//%Admin Charge Broker FX Thompson Inter bank Rate
int fontSize=8;
int fontSpacing=14;
string fontType="Windings";//Times New Roman";
color clrVar1=clrDarkGray;
color clrVar2=clrLemonChiffon;
color clrHeader=clrAzure;
int offSet=0;//the x spacing of the results table columns
int apart=50;
//+------------------------------------------------------------------+
//|instrument                                                        |
//+------------------------------------------------------------------+
class instrument : public CObject
  {
public:

private:
   double            spread;
   string            whoAmI;
   int               period;
   int               adxBefore;
   double            r;
   double            acceptableM;
   int               shift;
   bool              canCreate;
   int               signature;//Simply breaches margin constraints to show trades on indicator
public:
   string            descr;
   datetime          creationTime;
   datetime          triggerTime;
   double            betPoundsThreshold;
   double            stopQuids;
   info              tradeInfo;
   string            symbol;
   ENUM_TIMEFRAMES   enum_HTF_WTF_Filter;
   ENUM_TIMEFRAMES   enum_HTF_Trend_Filter;
   ENUM_TIMEFRAMES   enum_HTF_ContraWave_Filter;
   ENUM_TIMEFRAMES   enum_HTF_ATRWave_Filter;
   ENUM_TIMEFRAMES   enum_HTF_Terminate_Filter;
   double            goLSC;//returned from trend indicator LONG SHORT or CLOSE   
   double            stop;
   double            target;
   double            volitility;
   double            factor;
   double            atrStopMultiplier;
   double            acceptableMarginPerTrade;

   double            marginPerPoundBet;
   double            spreadPts;
   string            tradeAllowed;
   string            profitCalcMode;
   double            stopLevel;
   int               digits;
   double            bid;
   double            ask;
   double            pointSize;
   double            tickValue;
   double            tickSize;
   double            swapLong;
   double            swapShort;
   string            swopType;
   double            totalSwapLong;
   double            totalSwapShort;
   double            lotStep;
   double            lotMin;
   int               lotStepPlaces;//--set the number of places for rounding reduced lots  

   double            adx;
   double            adxr;
   double            adxDMIP;
   double            adxDMIM;
   double            csi;//Constructed following Wilder ADXR, ADX, Commision, MathSquareRoot(marginPerPoundBet)  
   string            trend;//trend of WTF either WTF(of chart) or TTF
   string            MTrend;//keeps major trend in WTF instrument

                            //values calculated for use in Robert Baptie CSI calculations
   double            betNumPounds;//multiple of pounds to bet   

   double            totalSpreadQuidPoints;//--£ @ betNumPounds
   double            volatility;
   double            atr;
   double            atrPoints;
   double            totalATRQuids;//Quids ATR @ betNumPounds

   double            tradeWantedMargin;//Quids margin requirements @ betNumPounds
                                       //  int               countOccurance;//used to count appearances of prospect

public:
   instrument
   (ENUM_TIMEFRAMES ienumHTFWTFFilter,ENUM_TIMEFRAMES ienumHTFTrendFilter,ENUM_TIMEFRAMES ienumHTFContraWaveFilter,ENUM_TIMEFRAMES ienumHTFATRWaveFilter,ENUM_TIMEFRAMES ienumHTFTerminateFilter,
    string isymbol,string idescr,string iwhoAmI,int iperiod,int iadxBefore,double ir,double iacceptableM,int ishift,bool &icanCreate,int isignature,double iBetPoundsThreshold):
    enum_HTF_WTF_Filter(ienumHTFWTFFilter),enum_HTF_Trend_Filter(ienumHTFTrendFilter),enum_HTF_ContraWave_Filter(ienumHTFContraWaveFilter),enum_HTF_ATRWave_Filter(ienumHTFATRWaveFilter),enum_HTF_Terminate_Filter(ienumHTFTerminateFilter),
    symbol(isymbol),descr(idescr),whoAmI(iwhoAmI),period(iperiod),adxBefore(iadxBefore),r(ir),acceptableM(iacceptableM),shift(ishift),canCreate(icanCreate),signature(isignature),betPoundsThreshold(iBetPoundsThreshold)
     {
      creationTime=Time[0];
      goLSC=EMPTY_VALUE;
      atrStopMultiplier=3;
      acceptableMarginPerTrade=acceptableM;
      marginPerPoundBet=MarketInfo(symbol,MODE_MARGINREQUIRED);
      pointSize=MarketInfo(symbol,MODE_POINT);
      tickValue= MarketInfo(symbol,MODE_TICKVALUE);
      tickSize = MarketInfo(symbol,MODE_TICKSIZE);
      digits=int(MarketInfo(symbol,MODE_DIGITS));
      stopLevel=MarketInfo(symbol,MODE_STOPLEVEL);
      lotStep=MarketInfo(symbol,MODE_LOTSTEP);
      lotMin=MarketInfo(symbol,MODE_MINLOT);
      swapLong=MarketInfo(symbol,MODE_SWAPLONG);
      swapShort=MarketInfo(symbol,MODE_SWAPSHORT);
      swopType = InfoToStr(MarketInfo(symbol,MODE_SWAPTYPE),MODE_SWAPTYPE);
      tradeAllowed=InfoToStr(MarketInfo(symbol,MODE_TRADEALLOWED),MODE_TRADEALLOWED);
      bid = MarketInfo(symbol,MODE_BID);
      ask = MarketInfo(symbol,MODE_ASK);
      //estimate when using pure indicator since bid and ask not available only available at Time[0] (as for use in Expert.
      spread=ask-bid;
      setHTF();
      if(whoAmI!="INIT")
        {
         setTrend();//always htf      
         icanCreate=setVariableData();
         //for pure Indicator code
         tradeInfo.state=NULL;//BUY, SELL, NOTHING 
         tradeInfo.oPrice=NULL;     // Open Price
         tradeInfo.oTime=NULL;   // Open Time
         tradeInfo.cPoints=NULL;
        }
      else
         icanCreate=false;
     };
   void ~instrument()
     {
      //Print(__FUNCTION__," destroying instrument");
     }
   //void setVariableData()     
   //+------------------------------------------------------------------+
   //|Set the instruments internal HTF for this WTF                     |
   //+------------------------------------------------------------------+      
   bool setHTF()
     {
      if(whoAmI=="WTF")
        {
         //enum_HTF_WTF_Filter=ienumHTFWTFFilter;//number of wtf  array   
         //enum_HTF_Trend_Filter=ienumHTFTrendFilter;//HTF trend filter
         //enum_HTF_ContraWave_Filter=ienumHTFContraWaveFilter;//wave pullback filter
         //enum_HTF_ATRWave_Filter=ienumHTFATRWaveFilter;//ATRTF: Stop, Target, Open Trade, trendIndicator & Expert
         //enum_HTF_Terminate_Filter=ienumHTFTerminateFilter;//HTF exit filter change trend  
        }
      else if(whoAmI=="TTF")
        {
         enum_HTF_WTF_Filter=enum_HTF_Trend_Filter;//number of wtf  array   
                                                   //     enum_HTF_Trend_Filter=ienumHTFTrendFilter;//HTF trend filter
         enum_HTF_ContraWave_Filter=enum_HTF_Trend_Filter;//wave pullback filter
         enum_HTF_ATRWave_Filter=enum_HTF_Trend_Filter;//ATRTF: Stop, Target, Open Trade, trendIndicator & Expert
         enum_HTF_Terminate_Filter=enum_HTF_Trend_Filter;//HTF exit filter change trend  
        }
      else if(whoAmI=="INIT")
         return false;
      else
         return false;
      return true;
     }
   //+------------------------------------------------------------------+
   //|Set the TREND for the direction of trade                          |
   //+------------------------------------------------------------------+      
   void setTrend()
     {
      // double adxt=iADX(symbol,ienumHTFWTFFilter,period,PRICE_CLOSE,MODE_MAIN,shift);
      adxDMIP=iADX(symbol,enum_HTF_WTF_Filter,period,PRICE_CLOSE,MODE_PLUSDI,shift);
      adxDMIM=iADX(symbol,enum_HTF_WTF_Filter,period,PRICE_CLOSE,MODE_MINUSDI,shift);
      if(adxDMIP>adxDMIM)
         trend="UP";
      else if(adxDMIP<adxDMIM)
         trend="DOWN";
      else
         trend="UNDFD";
     }
   //+------------------------------------------------------------------+
   //|set variable values                                               |
   //+------------------------------------------------------------------+
   bool setVariableData()
     {
      ResetLastError();
      if(shift>=0)
        {
         adx=iADX(symbol,enum_HTF_WTF_Filter,period,PRICE_CLOSE,MODE_MAIN,shift);
         adxr=iCustom(symbol,enum_HTF_WTF_Filter,"\\TREND\\ADXR",period,adxBefore,3,shift);
         int htfShift=iBarShift(symbol,enum_HTF_ATRWave_Filter,Time[shift],false);
         atr=iATR(symbol,enum_HTF_ATRWave_Filter,period,htfShift);
         //Print(__FUNCTION__" symbol ",symbol ," enum_HTF_WTF_Filter ",enum_HTF_WTF_Filter," shift ",shift," period ",period);         
         if((adxr==EMPTY_VALUE) || (marginPerPoundBet<=0) || (spread<=0) || (atr<=0))
           {
            descr="NOT ENOUGH DATA";
            adx=0;
            adxr=0;
            atr=0;
            csi=0;
            Print(__FUNCTION__" **** FAILURE: adxr ",adxr,"marginPerPoundBet: ",marginPerPoundBet,"spread: ",spread,"atr: ",atr);
            return false;
           }
         //        Print(__FUNCTION__" SUCCESS: adxr ",adxr,"marginPerPoundBet: ",marginPerPoundBet,"spread: ",spread,"atr: ",atr);           
         bool isSet=setCappedWTFData();
         if(!isSet)
            return false;
         else
            return true;
        }
      else
         Print(__FUNCTION__," ",symbol," ATRTF ",enum_HTF_ATRWave_Filter," timeFrame ",shift," ",ErrorDescription(GetLastError()));
      return false;
     }
   //+------------------------------------------------------------------+
   //|set variable values for bet size, margin and spreadPts to use        |
   //+------------------------------------------------------------------+     
   bool setCappedWTFData()
     {
      spreadPts=spread/pointSize;
      double accountEquity=AccountEquity();
      //     Print(__FUNCTION__," AccountEquity: ", accountEquity);
      stopQuids=((r/100)*accountEquity)*100;

      atrPoints=-1;
      double costSmallestMove=-1;

      if(pointSize!=0 && tickValue!=0)
        {
         costSmallestMove=(pointSize/tickSize)*(1/(tickValue));
         atrPoints=atr/pointSize;
         if((atrStopMultiplier*atrPoints*costSmallestMove)>0)
            betNumPounds=stopQuids/(atrStopMultiplier*atrPoints*(costSmallestMove));
         else
            betNumPounds=0;
        }
      else
         return false;

      if(betNumPounds>0)
         volitility=(atrPoints*(1/costSmallestMove));
      else
         return false;

      betNumPounds=ND(betNumPounds,digits);

      if(betNumPounds<=0)
         return false;
      bool acceptable=true;

      tradeWantedMargin=betNumPounds*marginPerPoundBet;
      if(tradeWantedMargin>0)
         acceptable=checkMeetsMargin();
      else
         return false;
      //      if(signature==0)//instrument
      //        {
      //--have a good open but its too heavy  on margin requirement
      if((whoAmI=="WTF") && (!acceptable))
        {
         //     Print("REPORT ALL GOOD BUT acceptableMarginPerTrade/tradeWantedMargin) < 0.7: ",symbol," factor: ",factor);
         return false;
        }

      //--less than min bet (=min lot size??)
      if(whoAmI=="WTF" && betNumPounds<lotMin && (signature<=0))
        {
         //      Print("REPORT ALL GOOD BUT LOT size MIN bigger than your trade size:"+symbol," betNumPounds: ",betNumPounds," lot Min: ",lotMin);
         return false;
        }
      //        }
      totalSpreadQuidPoints=betNumPounds*spreadPts*costSmallestMove/100;//convertpence to Pounds

      double atrQuidPoints=(atrPoints*(costSmallestMove/100));
      totalATRQuids=betNumPounds*atrQuidPoints;

      totalSwapLong=totalSwap(swopType,"LONG",bid);
      totalSwapShort=totalSwap(swopType,"SHORT",bid);

      double cost=(150+MathAbs(totalSwapLong)+totalSpreadQuidPoints);

      if((marginPerPoundBet>0) && (betNumPounds>0) && (cost>0))
         csi=100*volitility *adxr *(1/MathSqrt(marginPerPoundBet)) *(1/cost);
      else
         csi=0;
      return true;
     }
   //+------------------------------------------------------------------+
   //|checkMeetsMarginPercent set volume in line with lotstep         |
   //|and adjust the margin if higher than can accomodate               |   
   //|for betNumPounds                                                  |      
   //+------------------------------------------------------------------+ 
   bool checkMeetsMargin()
     {
      factor=1;
      if((tradeWantedMargin>acceptableMarginPerTrade) && (signature<=0))
        {
         factor=acceptableMarginPerTrade/tradeWantedMargin;
         // Print("factor ",factor, "acceptableMarginPerTradeargin ",acceptableMarginPerTrade, "tradeWantedMargin ",tradeWantedMargin);
         if((factor<betPoundsThreshold))// cannot trade real time because dont have the margin
            return false;
         tradeWantedMargin=factor*tradeWantedMargin;
        }
      else  if((tradeWantedMargin>acceptableMarginPerTrade) && (signature>0))
        {
         factor=acceptableMarginPerTrade/tradeWantedMargin;
         // Print("factor ",factor, "acceptableMarginPerTradeargin ",acceptableMarginPerTrade, "tradeWantedMargin ",tradeWantedMargin);
         tradeWantedMargin=factor*tradeWantedMargin;
         if((factor<lotMin))//use min lot because you dont have the margin even for that
           {
            //testing and using lot min insted of limit in margin
            factor=lotMin;
            betNumPounds=lotMin;
            tradeWantedMargin=factor*tradeWantedMargin;
            return true;
           }

        }
      double temprml=betNumPounds*factor;
      lotStepPlaces=calcDecimalPlaces(lotStep);
      temprml=roundDownDecimal(temprml,lotStepPlaces);
      betNumPounds=NormalizeDouble(temprml,lotStepPlaces);
      //      Print("BET POUNDS: ",betNumPounds," factor ", factor, "lot min ", lotMin);   
      return true;
     }
   //+------------------------------------------------------------------+
   //|checkSetUp                                                        |
   //+------------------------------------------------------------------+ 
   string getInstrument()
     {
      return this.symbol;
     }
   //+------------------------------------------------------------------+
   //|checkSetUp see if prospects are in setup                          |
   //+------------------------------------------------------------------+     
   void checkSetUp(int timeF)
     {
      //construct list of symbols set up
      //should it be in the list? add remove
      Print(__FUNCTION__,TimeGMT(),this.symbol+" "+string(timeF));
     }
   //+------------------------------------------------------------------+
   //|trigger a trade to open that is setup                             |
   //+------------------------------------------------------------------+     //////////////make integers///////////////////////////////////////////////////////////////////////////////////

   //   bool trigger(string sym,int Kper,int Dper,int Slowing,int Meth,int priceField,int MaxBarsDraw,int WTF,int category)
   //     {
   //      //previous to zero, ie/. 1
   //      double tf1Stochs=iCustom(sym,WTF,"StochsHTFs",0,Kper,Dper,Slowing,Meth,priceField,5000,0,1);
   //      double tf1Signal=iCustom(sym,WTF,"StochsHTFs",0,Kper,Dper,Slowing,Meth,priceField,5000,1,1);
   //      //previous to the one above, ie/. 2 
   //      double tf2Stochs=iCustom(sym,WTF,"StochsHTFs",0,Kper,Dper,Slowing,Meth,priceField,5000,0,2);
   //      double tf2Signal=iCustom(sym,WTF,"StochsHTFs",0,Kper,Dper,Slowing,Meth,priceField,5000,1,2);
   //
   //      //        
   //      if((category==0) && (tf2Signal<tf2Stochs) && (tf1Signal>tf1Stochs))
   //        {
   //         //want to trade the instrument
   //         s(__FUNCTION__+" WANT TO BUY: "+sym+" breakOut: "+string(category)+"stoch 1: "+string(tf1Stochs)+" sig 1: "+string(tf1Signal)+" stoch2 Prev: "+string(tf2Stochs)+" sig 2 Prev: "+string(tf2Signal),true);
   //         return true;
   //        }
   //      else if((category==1) && (tf2Signal>tf2Stochs) && (tf1Signal<tf1Stochs))
   //        {
   //         //want to trade the instrument
   //         s(__FUNCTION__+" WANT TO SELL: "+sym+" breakDown: "+string(category)+"stoch 1: "+string(tf1Stochs)+" sig 1: "+string(tf1Signal)+" stoch2 Prev: "+string(tf2Stochs)+" sig 2 Prev: "+string(tf2Signal),true);
   //         return true;
   //        }
   //      else
   //         s(__FUNCTION__+sym+": CEASE: "+string(category)+"stoch 1: "+string(tf1Stochs)+" sig 1: "+string(tf1Signal)+" stoch2 Prev: "+string(tf2Stochs)+" sig 2 Prev: "+string(tf2Signal),true);
   //      return false;
   //     }     
   //+------------------------------------------------------------------+
   //|zero the whichLevel variable if it is not in the treades list     |
   //+------------------------------------------------------------------+     
   //void setWhichLevel()
   //  {
   //   int total=OrdersTotal();
   //   int item=0;
   //   for(item=total; item>=0; item--)//all orders      
   //     {
   //      if(OrderSelect(item,SELECT_BY_POS,MODE_TRADES)==true)
   //        {
   //         if(OrderSymbol()==this.symbol)
   //            break;
   //        }
   //     }//order select        
   //   this.whichLevel=NULL;
   //  }
   //+------------------------------------------------------------------+
   //|Over Night Restricted Swap Calculation                            |   
   //+------------------------------------------------------------------+
   double totalSwap(string sType,string direction,double BID)
     {
      if(sType=="points")//FX using swap rates
        {
         //Bid * (+/-swapRate% + Admin Charge%
         if(direction=="LONG")
           {
            double exposure=betNumPounds*BID;
            double adminC=-exposure *(adminCharge/100);
            double swapCost=exposure *((swapLong/100)/365);
            return swapCost + adminC;
           }
         else if(direction=="SHORT")
           {
            double exposure=betNumPounds*BID;
            double adminC=-exposure *(adminCharge/100);
            double swapCost=exposure *((swapShort/100)/365);
            return swapCost + adminC;
           }
        }
      else if(sType=="percent")// shares or index or anything else?
        {
         //9591713 - GER_30
         //Exposure = stake x market price 
         //0.5 x 12991.5 = 6,495.75 
         //
         //Overnight financing = Exposure x Fee / 365 (+/- LIBOR) 
         //6,495.75 x 3.5% / 365 (+0.5) 
         //
         //6,495.75 x 3.5% = 227.35125
         //
         //227.35125 / 365 = 0.62288013698
         //
         //0.62288013698 + 0.5 = 0.62601018791
         //
         //0.62601018791 x  4 days = 2.50404075164 = (Rounded = £2.50)
         //
         //Cannot get an accurate figure as LIBOR is consistently fluctuating     
         double exposure=betNumPounds*BID;
         double overNight=exposure *(((overNightPercent+LIBOR)/100)/365);
         return -overNight;
        }
      else
         Print(__FUNCTION__,": failed to identify SWAP TYPE: "+symbol+" swapType "+sType);
      return -1;
     }
   //+--------------------------------------------------------------------------------------+
   //|Compare   //<= 8 SORT VALUE DESC, > 7 SET SORT VALUE IN DISPLAY DESC - see displayData|                                                      |
   //+--------------------------------------------------------------------------------------+
   int Compare(const CObject *node,const int mode=0)const override
     {
      instrument *other=(instrument*)node;
      //SORT BIG -> 0
      if(mode==0)
        {//Symbol: first must be symbol because of NAME
         if(this.symbol>other.symbol) return 1;
         if(this.symbol<other.symbol) return -1;
        }
      if(mode==1)
        {//csi
         if(this.csi>other.csi) return 1;
         if(this.csi<other.csi) return -1;
        }
      if(mode==2)
        {//atr/£ atr spead
         if(this.volatility>other.volatility) return 1;
         if(this.volatility<other.volatility) return -1;
        }
      if(mode==3)
        {//ADX
         if(this.adx>other.adx) return 1;
         if(this.adx<other.adx) return -1;
        }
      if(mode==4)
        {//ADXR
         if(this.adxr>other.adxr) return 1;
         if(this.adxr<other.adxr) return -1;
        }
      if(mode==5)
        {//totalSpreadQuidPoints
         if(this.totalSpreadQuidPoints>other.totalSpreadQuidPoints) return 1;
         if(this.totalSpreadQuidPoints<other.totalSpreadQuidPoints) return -1;
        }
      //if(mode==6)//ATR MONEY                             
      //  {
      //   if(this.atrPoints*costSmallestMove>other.atrPoints*costSmallestMove) return 1;
      //   if(this.atrPoints*costSmallestMove<other.atrPoints*costSmallestMove) return -1;
      //  }
      if(mode==6) //SET SORT VALUE IN DISPLAY
        {//ATR
         if(this.atr>other.atr) return 1;
         if(this.atr<other.atr) return -1;
        }
      if(mode==7)
        {//RESTRICTEDMAXLOTS
         if(this.totalATRQuids>other.totalATRQuids) return 1;
         if(this.totalATRQuids<other.totalATRQuids) return -1;
        }
      if(mode==8)
        {//spreadPts
         if(this.spreadPts>other.spreadPts) return 1;
         if(this.spreadPts<other.spreadPts) return -1;
        }
      return 0;//same or sorting not implemented.
     }
  };
//+------------------------------------------------------------------+
//| List of Instrument and TimeFrame in list                         |
//+------------------------------------------------------------------+
//class instrumentList : public CList
//  {
//public:
//   ENUM_TIMEFRAMES   tf;//period for this instrument list 5 ,15 ,30 ....
//   int               pil;
//   void instrumentList(int positionInList,ENUM_TIMEFRAMES TF)
//     {
//      tf=TF;
//      pil=positionInList;
//     }
//   void displayInfo(double aMargin,int sVar,int &posY)
//     {
//      string var="var";
//      posY++;
//      string tfText=TFPosition(TimeString,tfEnumFull,tf);
//      displayHeaders(var,posY,aMargin,tfText);
//      posY++;
//      var+=string(tf);
//      displayData(var,posY,sVar);
//      posY++;
//     }
//   void sort(int sVar)
//     {
//      Sort(sVar);
//     }
//   void shorten(int mInstruments)
//     {
//      shortenList(mInstruments);
//     }
   //+--------------------------------------------------------------------+
   //|clearList: empty contents of setUpList and remove any object fields |
   //+--------------------------------------------------------------------+         
   void clearList()
     {
      this.Clear();
     }
   //+------------------------------------------------------------------+
   //|Put in watch                                                      |
   //+------------------------------------------------------------------+
   int createArray(string  &array[])
     {
      int count=0;
      for(instrument *j=GetFirstNode();j!=NULL;j=j.Next())
        {
         array[count]=j.symbol;
         count++;
        }
      return count;
     }
   //+------------------------------------------------------------------+
   //|Top opportunities                                                 |
   //+------------------------------------------------------------------+
   bool shortenList(int nFill)
     {
      int count=0;
      for(instrument *j=GetFirstNode();j!=NULL;j=j.Next())
        {
         count++;
         if(count>nFill)
            DeleteCurrent();
        }
      return false;
     }
   //+------------------------------------------------------------------+
   //|Read Instruments - Not Used                                       |
   //+------------------------------------------------------------------+
   //void readInstruments(string &rSymbols[],string inpFileName)
   //  {
   //   ResetLastError();
   //   int file_handle=FileOpen(inpDirectoryName+"//"+inpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
   //   if(file_handle!=INVALID_HANDLE)
   //     {
   //      PrintFormat("%s file is available for reading",inpFileName);
   //      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
   //     }
   //   else
   //     {
   //      PrintFormat("Failed to open %s file, Error code = %d",inpFileName,GetLastError());
   //      return;
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
   //      //  Print("read "+str);
   //      count++;
   //     }
   //   ArrayResize(rSymbols,count+1);
   //   //--- close the file
   //   FileClose(file_handle);
   //   PrintFormat("Data is read, %s file is closed",inpFileName);
   //  }
   ////+------------------------------------------------------------------+
   ////|Write Instruments - used testing confirmation                     |
   ////+------------------------------------------------------------------+
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
   //   for(instrument *j=GetFirstNode();j!=NULL;j=j.Next())
   //     {
   //      FileWrite(file_handle,j.symbol+" CSI "+string(j.csi)+" ADX  "+string(j.adx));
   //      Print("Write ",j.symbol);
   //     }
   //   //--- close the file
   //   FileClose(file_handle);
   //   PrintFormat("Data is written, %s file is closed",inpFileName);
   //  }
   //+------------------------------------------------------------------+
   //|display symbols data                                              |
   //+------------------------------------------------------------------+
   void displayData(string var,int &pY,int sVar)
     {
      int colorOdd=0;
      //--*******************************************************************     
      if(sVar<=8) //from Last to First
         //--****************************************************************
        {
         for(instrument *j=GetLastNode();j!=NULL;j=j.Prev())
           {
            setSymbols(colorOdd,var,pY,j);
            pY++;
           }
        }
      else
        { //from Last to First
         for(instrument *j=GetFirstNode();j!=NULL;j=j.Next())
           {
            setSymbols(colorOdd,var,pY,j);
            pY++;
           }
        }
     }
   //+------------------------------------------------------------------+
   //|setSymbols                                                        |
   //+------------------------------------------------------------------+
   void  setSymbols(int &colorOdd,string var,int &pY,instrument *j)
     {
      colorOdd++;
      color clrVar=clrNONE;
      color clrgreen= clrNONE;
      color clrblue = clrNONE;
      color clrorange=clrNONE;
      int m=int(MathMod(colorOdd,2));
      if(m==0)
        {
         clrVar=clrVar1;
         clrgreen= clrLightGreen;
         clrblue = clrLightBlue;
         clrorange=clrOrange;
        }
      else
        {
         clrVar=clrVar2;
         clrgreen= clrGreen;
         clrblue = clrRoyalBlue;
         clrorange=clrOrangeRed;
        }
      //SYMBOL   
      offSet=0;
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),j.symbol,fontSize,fontType,clrVar);
      offSet+=30;
      //-SPREAD   
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.spreadPts,0),fontSize,fontType,clrVar);
      offSet+=10;
      //-MARGINREQUIRED 
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.marginPerPoundBet,0),fontSize,fontType,clrblue);
      offSet+=10;
      // //-LOTMIN
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),string(j.lotMin),fontSize,fontType,clrVar);
      ////-STOPLEVEL
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),string(j.stopLevel),fontSize,fontType,clrVar);
      ////-LOTSTEP
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),string(j.lotStep),fontSize,fontType,clrVar);
      ////-DIGITS
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),string(j.digits),fontSize,fontType,clrVar);
      ////-TREND
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),j.trend,fontSize,fontType,clrVar);
      offSet+=10;
      ////-CSI             
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.csi,1),fontSize,fontType,clrblue);
      offSet+=20;
      ////-VOLITILITY             
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.volitility,0),fontSize,fontType,clrblue);
      offSet+=10;
      ////-FACTOR
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.factor,2),fontSize,fontType,clrblue);
      offSet+=20;
      ////-BET  NUM POUNDS
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.betNumPounds,j.lotStepPlaces),fontSize,fontType,clrorange);
      ////-Sd R Lot
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.totalSpreadQuidPoints,2),fontSize,fontType,clrorange);
      ////-THE REDUCED MARGIN PAYABLE
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToString(j.tradeWantedMargin,0),fontSize,fontType,clrorange);
      ////-rSWAP LONG
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.totalSwapLong,2),fontSize,fontType,clrgreen);
      ////-rSWAP SHORT
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.totalSwapShort,2),fontSize,fontType,clrgreen);
      ////-SWAPLONG
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.swapLong,2),fontSize,fontType,clrVar);
      ////-SWAPSHORT
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.swapShort,2),fontSize,fontType,clrVar);
      ////-ADX
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.adx,2),fontSize,fontType,clrVar);
      ////-ADXR
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.adxr,2),fontSize,fontType,clrVar);
      ////-ATR
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),DoubleToStr(j.atr,j.digits),fontSize,fontType,clrVar);
      ////DESCRIPTION
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),StringSubstr(j.descr,0,280),fontSize,fontType,clrVar);
      offSet+=300;
      ////-TRADEALLOWED
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),string(j.tradeAllowed),fontSize,fontType,clrVar);
     }
   //+------------------------------------------------------------------+
   //|To Log                                                            |
   //+------------------------------------------------------------------+
   void  ToLog()
     {
      for(instrument *i=GetFirstNode();i!=NULL;i=i.Next())
         Print(i.symbol," ",DoubleToStr(i.csi,1));
      Print("//-----------------------------------------------------//");
     }
   //+------------------------------------------------------------------+
   //| create Label                                                     |
   //+------------------------------------------------------------------+
   string createLabel(string obj,int x,int y)
     {
      string thisVar=obj+"y"+string(y)+"x"+string(x);
      if(!ObjectCreate(ChartID(),thisVar,OBJ_LABEL,0,0,0))
        {
         Print(__FUNCTION__,": failed to create object label: "+thisVar+" Error = ",ErrorDescription(GetLastError()));
         return "NOT SET";
        }
      ObjectSet(thisVar,OBJPROP_CORNER,CORNER_LEFT_UPPER);    // Reference corner
      ObjectSet(thisVar, OBJPROP_XDISTANCE, x);// X coordinate
      ObjectSet(thisVar, OBJPROP_YDISTANCE, y);// Y coordinate
      ObjectSetInteger(ChartID(),thisVar,OBJPROP_BACK,false);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
      ObjectSetInteger(ChartID(),thisVar,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(ChartID(),thisVar,OBJPROP_SELECTED,false);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(ChartID(),thisVar,OBJPROP_HIDDEN,false);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(ChartID(),thisVar,OBJPROP_ZORDER,1000);
      offSet+=apart;
      return thisVar;
     }
   //+------------------------------------------------------------------+
   //|create & set label                                                |
   //+------------------------------------------------------------------+
   void displayHeaders(string var,int &pY,double accMargin,string TF)
     {
      //TOP SPACER WITh INFORMATION ON ACCOUNT
      ObjectSetText(createLabel(var+"AL",240,pY*fontSpacing),"Account Leverage: "+string(AccountLeverage()),fontSize,fontType,clrCadetBlue);
      ObjectSetText(createLabel(var+"AC",390,pY*fontSpacing),"Currency: "+AccountCurrency(),fontSize,fontType,clrCadetBlue);
      ObjectSetText(createLabel(var+"AMSO",480,pY*fontSpacing),"Stop Out Mode: "+InfoToStr((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE),ACCOUNT_MARGIN_SO_MODE),fontSize,fontType,clrCadetBlue);
      ObjectSetText(createLabel(var+"AM",630,pY*fontSpacing),"Acceptible Margin: "+DoubleToStr(accMargin,0),fontSize,fontType,clrCadetBlue);

      ObjectSetText(createLabel(var+"TF",750,pY*fontSpacing),"Time Frame: "+TF,fontSize,fontType,clrRed);
      pY++;
      offSet=0;
      //SYMBOL   
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Symbol",fontSize,fontType,clrHeader);
      offSet+=30;
      //-SPREAD   
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Spd Pts",fontSize,fontType,clrHeader);
      offSet+=10;
      //-MARGINREQUIRED  
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"£Mgn/£Bet",fontSize,fontType,clrHeader);
      offSet+=10;
      //-LOT MIN            
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Lot Min",fontSize,fontType,clrHeader);
      ////-STOPLEVEL
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"StopL",fontSize,fontType,clrHeader);
      ////-LOTSTEP
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"LStep",fontSize,fontType,clrHeader);
      ////-LOTSTEP
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Digits",fontSize,fontType,clrHeader);
      ////-TREND
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Trend",fontSize,fontType,clrHeader);
      offSet+=10;
      // //-CSI
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"CSI",fontSize,fontType,clrHeader);
      offSet+=20;
      // //-VOLATILITY
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Volty",fontSize,fontType,clrHeader);
      offSet+=10;
      // //-Factor
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Factor",fontSize,fontType,clrHeader);
      offSet+=20;
      ////-BET NUM POUNDS betNumPounds
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"£/Vol",fontSize,fontType,clrHeader);
      ////-SPREAD REDUCED BY LOT SIZE £
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"£totSpd",fontSize,fontType,clrHeader);
      ////-ATR £ PROPORTIONAL TO MAXIMUM LOTS TRADABLE
      //      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"£totATR",fontSize,fontType,clrHeader);
      ////-THE REDUCED MARGIN PAYABLE
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"£totMgn £",fontSize,fontType,clrHeader);
      ////-r SWAP LONG
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"SWP L",fontSize,fontType,clrHeader);
      ////-rSWAP SHORT
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"SWP S",fontSize,fontType,clrHeader);
      ////-SWAPLONG
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"SLong",fontSize,fontType,clrHeader);
      ////-SWAPSHORT
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"SShort",fontSize,fontType,clrHeader);
      ////-ADX
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"ADX",fontSize,fontType,clrHeader);
      ////-ADXR
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"ADXR",fontSize,fontType,clrHeader);
      ////-ATR
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"ATR",fontSize,fontType,clrHeader);
      ////DESCRIPTION
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"DESCRIPTION",fontSize,fontType,clrHeader);
      ////-TRADEALLOWED
      offSet+=300;
      ObjectSetText(createLabel(var,offSet,pY*fontSpacing),"Trade",fontSize,fontType,clrHeader);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//class instrumentIndicator : public instrument
//  {
//public:
//   string            descr;
//   //   int newint;
//   instrumentIndicator
//   (ENUM_TIMEFRAMES ienumHTFWTFFilter,ENUM_TIMEFRAMES ienumHTFTrendFilter,ENUM_TIMEFRAMES ienumHTFContraWaveFilter,ENUM_TIMEFRAMES ienumHTFATRWaveFilter,ENUM_TIMEFRAMES ienumHTFTerminateFilter,
//    string isymbol,string idesc,string iwhoAmI,int iperiod,int iadxBefore,double ir,double iacceptableM,int ishift,bool &icanCreate,int isignature,double iBetPoundsThreshold)//,int nn)
//   : instrument(ienumHTFWTFFilter,ienumHTFTrendFilter,ienumHTFContraWaveFilter,ienumHTFATRWaveFilter,ienumHTFTerminateFilter,
//                isymbol,idesc,iwhoAmI,iperiod,iadxBefore,ir,iacceptableM,ishift,icanCreate,isignature,iBetPoundsThreshold)
//     {
//      double testMarginRequired=marginPerPoundBet;
//      //    newint =nn;
//     }
//                    ~instrumentIndicator(){}
//   //   void instrument(string Sy,string des,string whoAmI,int period,int adxBefore,double r,double acceptableM,int shift)
//   //  void whoAmI_E_OR_I(string WHOAMI)
//   //   {
//   //if(WHOAMI=="WTF")
//   //   indexPointer=symbolLists.GetNodeAtIndex(0);
//   //else if(WHOAMI=="TTF")
//   //   indexPointer=symbolLists.GetNodeAtIndex(1);
//   //else if(WHOAMI=="NOBODY")
//   //   return;
//   //else
//   //   Print(__FUNCTION__," who are you???");
//   //     }
//
//  };
//+------------------------------------------------------------------+
//| instrument                                                 |
//+------------------------------------------------------------------+
//class instrument : public instrument
//  {
//public:
//   string            descr;
//   datetime          creationTime;
//   datetime          triggerTime;
//   int               signature;
//   instrument
//   (ENUM_TIMEFRAMES ienumHTFWTFFilter,ENUM_TIMEFRAMES ienumHTFTrendFilter,ENUM_TIMEFRAMES ienumHTFContraWaveFilter,ENUM_TIMEFRAMES ienumHTFATRWaveFilter,ENUM_TIMEFRAMES ienumHTFTerminateFilter,
//    string isymbol,string idesc,string iwhoAmI,int iperiod,int iadxBefore,double ir,double iacceptableM,int ishift,bool &icanCreate,int isignature,double iBetPoundsThreshold)
//   : instrument(ienumHTFWTFFilter,ienumHTFTrendFilter,ienumHTFContraWaveFilter,ienumHTFATRWaveFilter,ienumHTFTerminateFilter,
//                isymbol,idesc,iwhoAmI,iperiod,iadxBefore,ir,iacceptableM,ishift,icanCreate,isignature,iBetPoundsThreshold)
//     {
//      descr=idesc;
//      creationTime=Time[0];
//     }
//                    ~instrument()
//     {
//
//     }
//   //     void who()
//   //     {
//   //
//   //     Print("Expert");
//   //     }
//   //void whoAmI_E_OR_I(string WHOAMI)
//   //  {
//   //   if(WHOAMI=="INDICATOR")
//   //      Print(__FUNCTION__," who are you???");
//   //  }
//  };
//+------------------------------------------------------------------+
