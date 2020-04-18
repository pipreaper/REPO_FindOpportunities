//+------------------------------------------------------------------+
//|                                                    Catalysts.mqh |
//|                                    Copyright 2016, Robert Baptie |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.11"
#property strict
#include <WaveLibrary.mqh>
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| List of Support Resistance element                               |
//+------------------------------------------------------------------+
class srElement : public CObject
  {
public:
   double            level;
   datetime          time;
   string            lineName;
   void srElement(double lev=0.0,datetime t=NULL)
     {
      level=lev;
      time=t;
      lineName=NULL;
     }
  };
//+------------------------------------------------------------------+
//| support or resistance List                                       |
//+------------------------------------------------------------------+
class srList : public CList
  {
private:
   //int               fontSize;
   //string            fontType;
   //color             fontColorProfit;
   //color             fontColorLoss;
   //color             fontColorIndex;
   int               maxElements;
   string            sORr;
public:
                     srList(int mElements,string sr)
     {
      maxElements=mElements;
      sORr=sr;
     }
                    ~srList()
     {
      for(int i=0;(i<=this.Total()); i++)
         this.Delete(i);
     }
   void updateList(double lev,datetime t,bool dSR)
     {
      if(Total()<=maxElements-1)
        {
         Add(new srElement(lev,t));
         //       ToLog();
        }
      else
        {
         //DELETE LINE FROM CHART AND ELEMENT FROM LIST
         this.deleteOldCongestion(dSR);
         //        ToLog();
         Add(new srElement(lev,t));
         //       ToLog();
        }
     }
   //+------------------------------------------------------------------+
   //| drawSECongestion                                                 |
   //+------------------------------------------------------------------+  
   void drawSECongestion(ENUM_TIMEFRAMES eHTFPeriod,const datetime &t[],color cLine,bool dSR,string l1,string l2,string s)
     {
      if(dSR)
        {
         //GET LAST ELEMENT ADDED TO THE LIST
         srElement *thisElement=this.GetNodeAtIndex(this.Total()-1);
         double level = thisElement.level;
         datetime tim = thisElement.time;
         if(this.sORr==l1)//support
            drawLine(eHTFPeriod,level,tim,t[0],cLine,1,STYLE_DASH,thisElement,s);
         else if(this.sORr==l2)//resistance
         drawLine(eHTFPeriod,level,tim,t[0],cLine,1,STYLE_DASHDOTDOT,thisElement,s);
        }
     }
   //+------------------------------------------------------------------+
   //| deleteOldSECongestion                                            |
   //+------------------------------------------------------------------+  
   void deleteOldCongestion(bool dSR)
     {
      //GET OLDEST ELEMENT IN THE LIST    
      if(dSR)
        {
         srElement *thisElement=this.GetNodeAtIndex(0);
         ObjectDelete(thisElement.lineName);
        }
      //remove list element
      Delete(0);
     }
   //+------------------------------------------------------------------+
   //| drawLine                                                         |
   //+------------------------------------------------------------------+  
   void drawLine(const ENUM_TIMEFRAMES tf,double p,datetime t1,datetime t2,color clr,double lineWidth,int lineStyle,srElement *tElement,string s)
     {
      static int uLineID;
      uLineID++;
      //Print("uLINEID: ",uLineID);
      tElement.lineName=this.sORr+s+string(uLineID);
      int sw=ObjectFind(ChartID(),tElement.lineName);
      int window=0;
      if(sw<0)
        {
         if(!ObjectCreate(ChartID(),tElement.lineName,OBJ_TREND,0,t1,p,t2,p))
            Print(__FUNCTION__,": failed to create a support Line, Error code = ",ErrorDescription(GetLastError()));
         else
           {
            //--- set line color   
            ObjectSetInteger(ChartID(),tElement.lineName,OBJPROP_BACK,false);
            ObjectSetInteger(ChartID(),tElement.lineName,OBJPROP_SELECTABLE,false);
            //---enable (true) or disable (false) the mode of continuation of the line's display to the left
            ObjectSetInteger(ChartID(),tElement.lineName,OBJPROP_RAY_LEFT,false);
            //--- enable (true) or disable (false) the mode of continuation of the line's display to the right
            ObjectSetInteger(ChartID(),tElement.lineName,OBJPROP_RAY_RIGHT,true);
            ObjectSet(tElement.lineName,OBJPROP_WIDTH,lineWidth);
            ObjectSet(tElement.lineName,OBJPROP_STYLE,lineStyle);
            ObjectSetInteger(ChartID(),tElement.lineName,OBJPROP_COLOR,clr);
           }
        }
      else
         Print(__FUNCTION__," Duplicate Indicator Fix it!: "+this.sORr+" "+s);
     }
   //+------------------------------------------------------------------+
   //|List the Levels in the SR Object discovered                       |
   //+------------------------------------------------------------------+        
   void  ToLog()
     {
      for(srElement *i=GetFirstNode();i!=NULL;i=i.Next())
         Print(i.level);
     }
  };
//--------------------------------------------------------
//+------------------------------------------------------------------+
//| SRObject                                                         |
//+------------------------------------------------------------------+
//class SRObject
//  {
//public:
//   //int               nLevels;
//   srList           *support;
//   srList           *resistance;
//                     SRObject(int mElements)
//     {
//      //levels=levels;
//      support=new srList(mElements);
//      resistance=new srList(mElements);
//     }
//                    ~SRObject()
//     {
//      delete(support);
//      delete(resistance);
//     }
////+------------------------------------------------------------------+
////| drawSECongestion                                                 |
////+------------------------------------------------------------------+  
//void drawSECongestion(int Shift,double startPoint,double endPoint,ENUM_TIMEFRAMES eHTFPeriod,const datetime &t[],color cLine,bool dSR,int &xuLineID)
//  {
//   static int uLineID;
//   if(dSR)
//     {
//      uLineID++;
//      drawLine(eHTFPeriod,startPoint,t[Shift+2],t[0],cLine,1,STYLE_DASH,uLineID);
//      uLineID++;
//      drawLine(eHTFPeriod,endPoint,t[Shift+2],t[0],cLine,1,STYLE_DASHDOTDOT,uLineID);
//     }
//  }
////+------------------------------------------------------------------+
////| deleteOldSECongestion                                            |
////+------------------------------------------------------------------+  
//void deleteOldSECongestion(string lineName)
//  {
//   ObjectDelete(lineName);
//  }
////+------------------------------------------------------------------+
////| drawLine                                                         |
////+------------------------------------------------------------------+  
//string drawLine(const ENUM_TIMEFRAMES tf,double p,datetime t1,datetime t2,color clr,double lineWidth,int lineStyle,int uLineID)
//  {
//   string lineName="levelc"+string(tf)+string(uLineID);
//   int sw=ObjectFind(ChartID(),lineName);
//   int window=0;
//   if(sw<0)
//     {
//      if(!ObjectCreate(ChartID(),lineName,OBJ_TREND,0,t1,p,t2,p))
//        {
//         Print(__FUNCTION__,": failed to create a support Line, Error code = ",ErrorDescription(GetLastError()));
//         return "Line Already Exists";
//        }
//      else
//        {
//         //--- set line color   
//         ObjectSetInteger(ChartID(),lineName,OBJPROP_BACK,false);
//         ObjectSetInteger(ChartID(),lineName,OBJPROP_SELECTABLE,false);
//         //---enable (true) or disable (false) the mode of continuation of the line's display to the left
//         ObjectSetInteger(ChartID(),lineName,OBJPROP_RAY_LEFT,false);
//         //--- enable (true) or disable (false) the mode of continuation of the line's display to the right
//         ObjectSetInteger(ChartID(),lineName,OBJPROP_RAY_RIGHT,true);
//         ObjectSet(lineName,OBJPROP_WIDTH,lineWidth);
//         ObjectSet(lineName,OBJPROP_STYLE,lineStyle);
//         ObjectSetInteger(ChartID(),lineName,OBJPROP_COLOR,clr);
//        }
//     }
//   else
//      Print(__FUNCTION__,"Line already exists");
//   return lineName;
//  }
//  };
