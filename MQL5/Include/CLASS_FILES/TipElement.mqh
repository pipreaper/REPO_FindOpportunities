//+------------------------------------------------------------------+
//|                                                   TipElement.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#include    <Arrays\List.mqh>
#include    <\\INCLUDE_FILES\\WaveLibrary.mqh>
class TipElement : public CObject
  {
public:
   color             clrLine;
   string            name;
   string            waveLineName;
   int               fSize;
   string            font;
   ENUM_LINE_STYLE   lineStyle;
   datetime          leftTime;
   datetime          rightTime;
   double            leftPrice;
   double            rightPrice;
   double            high;
   double            low;
   trendElementState tipElementState;
   long              vol;
   //Constructor
void TipElement::TipElement(string _name, color _clrLine);
   // tipState = current value of this Tip Elemets State
   void              TipElement::setTipElementState(trendElementState _updateCurrElementTrend);
   // get value of current Tipe
   trendElementState TipElement::getTipElementState();
   // set element parameters
   void              TipElement::setElementParams();//trendElementState _state,datetime _date,double _value,uchar _arrowCode,ENUM_ARROW_ANCHOR _arrowTB,long _vol, double _arrowDrawOffSet);
   //Destructor
   void              TipElement::~TipElement();
   // TipElement::initWaveLineArrow: first arrow
   //  void              TipElement::initWaveLineArrow(int _digits,int _font,string _fontType,color _clrLine,uchar _arrowCode,showWaveLabels _showWaveArmLabels, double _arrowDrawOffSet);
   // TipElement::moveWaveLineArrow:  move an arrow that has been updated
   //  void              TipElement::moveWaveLineArrow(int _digits,int _font,string _fontType,color _clrLine,uchar _arrowCode,showWaveLabels _showWaveArmLabels, double _arrowDrawOffSet);
   // draw the wave line arrow
   //   void              TipElement::drawWaveLineArrow(int _digits,int _font,string _fontType,color _clrLine,uchar _arrowCode,showWaveLabels _showWaveArmLabels, double _arrowDrawOffSet);
   // offset the onscreen arrows to make legible and distinguishable on the screen
   //  void              TipElement::findTextOffSet(double &_offSet, bool &_upDown);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TipElement::TipElement(string _name, color _clrLine)
  {
clrLine = _clrLine;
   name = _name;
  }
// +------------------------------------------------------------------+
// |Set Element Params                                                |
// +------------------------------------------------------------------+
void TipElement::setElementParams()
  {
   fSize=8;
   font="WingDings";
   waveLineName=name+"_waveLine";
  }
// +------------------------------------------------------------------+
// | setTipElementState                                               |
// +------------------------------------------------------------------+
void              TipElement::setTipElementState(trendElementState _updateCurrElementTrend)
  {
   tipElementState = _updateCurrElementTrend;
  }
// +------------------------------------------------------------------+
// | getTipState                                                      |
// +------------------------------------------------------------------+
trendElementState        TipElement::getTipElementState()
  {
   return tipElementState;
  }
// +------------------------------------------------------------------+
// |~TipElement                                                       |
// +------------------------------------------------------------------+
void              TipElement::~TipElement()
  {
//   delete(tip);
  }
//+------------------------------------------------------------------+
