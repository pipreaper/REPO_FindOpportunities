// +------------------------------------------------------------------+
// |                                                  conghistObj.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                             https:// www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https:// www.mql5.com"
#property version   "1.01"
#property strict
#include <Arrays\List.mqh>
#include <\\INCLUDE_FILES\\WaveLibrary.mqh>
#include <\\INCLUDE_FILES\\drawRectangle.mqh>
#include <\\INCLUDE_FILES\\drawing.mqh>
// +------------------------------------------------------------------+
// |congHistObj:List containing congHistElementObj's                |
// +------------------------------------------------------------------+
class ContainerCongestion : public CList
  {
public:
   bool              showCongestion;
                     ContainerCongestion(bool _showCongestion)
     {
      showCongestion=_showCongestion;
     }
                    ~ContainerCongestion()
     {
      CongestionElement *cheo=NULL;
      for(int i=0; i<Total(); i++)
        {
         // Need to delete the arrows for AD
         // Need delete system objects too
         cheo=GetNodeAtIndex(i);
         if(showCongestion)
           {
            RectangleDelete(0,cheo.name);
            ObjectDelete(0,cheo.congestionArrowName);
           }
        }
      Clear();
     }
   // last node to print is most current
   void              ContainerCongestion::ToLog(string desc,bool show);
  };
// +------------------------------------------------------------------+
// |To Log: last node to print is most current                        |
// +------------------------------------------------------------------+
void  ContainerCongestion::ToLog(string desc,bool show)
  {
   if(show)
     {
      CongestionElement *ceo=NULL;
      // onScreenStageObj *stage = NULL;
      Print(desc+" Total in Q: ",this.Total());
      for(int i=0; i<Total(); i++)
        {
         ceo=this.GetNodeAtIndex(i);
         if(GetPointer(ceo)!=NULL)
            Print(i," price1: ",ceo.priceBoxHigh," time1: ",ceo.time1," price2:",ceo.priceBoxLow," time2: ",ceo.time2," color: ",ceo.clr);
         else
            Print(__FUNCTION__," NULL POINTER congHistEleObj");
        }
     }
  }
// +------------------------------------------------------------------+
// | CongestionElement: rectangle of congestion while not trending    |
// | time1, price1 are start and minimum values                       |
// | time2, price2 are end and max values                             |
// +------------------------------------------------------------------+
class CongestionElement : public CObject
  {
public:
   // Panel Arrow Values
   string            name;
   string            congestionArrowName;
   double            priceBoxHigh;
   double            priceBoxLow;
   datetime          time1;
   datetime          time2;
   color             clr;
   int               fSize;
   string            font;
   void              CongestionElement::CongestionElement(string _name,double _priceBoxHigh,datetime _time1,double _priceBoxLow,datetime _time2,color _clr,bool _showCongestion);
   void              CongestionElement::~CongestionElement() {}
   void              CongestionElement::createNewCongestionArrow(string _congestionArrowName,datetime _date,double _price,bool _showCongestion)     ;

  };
//+------------------------------------------------------------------+
//| CongestionElement                                                |
//+------------------------------------------------------------------+
void CongestionElement::CongestionElement(string _name,double _priceBoxHigh,datetime _time1,double _priceBoxLow,datetime _time2,color _clr,bool _showCongestion)
  {
   name=_name;
   congestionArrowName=NULL;
   time1=_time1;
   priceBoxHigh=_priceBoxHigh;
   time2=_time2;
   priceBoxLow=_priceBoxLow;
   clr=_clr;
   fSize=8;
   font="Verdana";
   ResetLastError();
   if(_showCongestion)
     {
      ENUM_LINE_STYLE style=STYLE_DOT;    // style of rectangle lines
      int             width=1;            // width of rectangle lines
      bool            fill=false;         // filling rectangle with color
      bool            back=true;         // in the background
      bool            selection=false;    // highlight to move
      bool            hidden=true;        // hidden in the object list
      long            z_order=0;          // priority for mouse click
      if(!RectangleCreate(0,name,0,time1,priceBoxHigh,time2,priceBoxLow,_clr,style,width,fill,back,selection,hidden,z_order))
         return;
     }
  }
//+------------------------------------------------------------------+
//|createNewCongestionArrow                                          |
//+------------------------------------------------------------------+
void              CongestionElement::createNewCongestionArrow(string _congestionArrowName,datetime _date,double _price,bool _showCongestion)
  {
// create congestion arrow
   congestionArrowName=_congestionArrowName;
   if(_showCongestion)
      ArrowCreate(0,congestionArrowName,0,_date,_price,220,ANCHOR_TOP,clr);
  }
// +------------------------------------------------------------------+
