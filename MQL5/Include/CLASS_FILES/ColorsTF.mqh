//+------------------------------------------------------------------+
//|                                                     ColorsTF.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include    <Arrays\List.mqh>
class ColorsTFEle;
//+------------------------------------------------------------------+
//| ColorsTF                                                         |
//+------------------------------------------------------------------+
class ColorsTF:CList
  {
public:
                     ColorsTF();
                    ~ColorsTF();
   color             ColorsTF::findColors(ENUM_TIMEFRAMES _tf);
   void              ColorsTF::ToLog(string desc,bool show);
  };
ColorsTF::ColorsTF()
  {
   color allColors[22] =
     {
      clrPink,
      clrPaleTurquoise,
      clrDarkOrange,
      clrAliceBlue,
      clrLightBlue,
      clrCrimson,
      clrDeepPink,
      clrOliveDrab,
      clrLightGreen,
      clrChocolate,
   clrRed,      
      clrWhite,
      clrWhiteSmoke,
      clrCoral,
      clrBurlyWood,
      clrGreen,
      clrDarkSeaGreen,
      clrDarkKhaki,
      clrCornflowerBlue,
      clrLightSlateGray,
      clrChartreuse,
      clrOlive
     };   
   string allColorsNames[22] =
     {
      "clrPink",
      "clrPaleTurquoise",
      "clrDarkOrange",
      "clrAliceBlue",
      "clrLightBlue",
      "clrCrimson",
      "clrDeepPink",
      "clrOliveDrab",
      "clrLightGreen",
      "clrChocolate",
      "clrRed",      
      "clrWhite",
      "clrWhiteSmoke",
      "clrCoral",
      "clrBurlyWood",
      "clrGreen",
      "clrDarkSeaGreen",
      "clrDarkKhaki",
      "CornflowerBlue",
      "clrLightSlateGray",
      "clrChartreuse",
      "clrOlive"
     };
   ENUM_TIMEFRAMES allTimeFrames[22] =
     {
      PERIOD_M1,
      PERIOD_M2,
      PERIOD_M3,
      PERIOD_M4,
      PERIOD_M5,
      PERIOD_M6,
      PERIOD_M10,
      PERIOD_M12,
      PERIOD_M15,
      PERIOD_M20,
      PERIOD_M30,
      PERIOD_H1,
      PERIOD_H2,
      PERIOD_H3,
      PERIOD_H4,
      PERIOD_H6,
      PERIOD_H8,
      PERIOD_H12,
      PERIOD_D1,
      PERIOD_W1,
      PERIOD_MN1,
      PERIOD_CURRENT
     };
   string allTimeFramesNames[22] =
     {
      "PERIOD_M1",
      "PERIOD_M2",
      "PERIOD_M3",
      "PERIOD_M4",
      "PERIOD_M5",
      "PERIOD_M6",
      "PERIOD_M10",
      "PERIOD_M12",
      "PERIOD_M15",
      "PERIOD_M20",
      "PERIOD_M30",
      "PERIOD_H1",
      "PERIOD_H2",
      "PERIOD_H3",
      "PERIOD_H4",
      "PERIOD_H6",
      "PERIOD_H8",
      "PERIOD_H12",
      "PERIOD_D1",
      "PERIOD_W1",
      "PERIOD_MN1",
      "PERIOD_CURRENT"
     };
   ColorTFEle *tfColEle = NULL;
   for(int i = 0; (i < ArraySize(allTimeFrames)); i++)
     {
      tfColEle = new ColorTFEle();
      this.Add(tfColEle);
      tfColEle.TFEle = allTimeFrames[i];
      tfColEle.colorEle = allColors[i];
      tfColEle.colorEleName=allColorsNames[i];
      tfColEle.TFEleName=allTimeFramesNames[i];
     }
  }
ColorsTF::~ColorsTF()
  {
   Clear();
  }
color ColorsTF::findColors(ENUM_TIMEFRAMES _tf)
  {
   ColorTFEle *tfColEle = NULL;
   for(int i = 0; (i < Total()); i++)
     {
      tfColEle = GetNodeAtIndex(i);
      if(tfColEle.TFEle==_tf)
         return tfColEle.colorEle;
     }
   return clrNONE;
  }
// +------------------------------------------------------------------+
// |To Log: last node to print is most current                        |
// +------------------------------------------------------------------+
void              ColorsTF::ToLog(string desc,bool show)
  {
   if(show)
     {
      ColorTFEle *_ctfe=NULL;
      Print(desc+" in Q: ",this.Total());
      for(int i=0; i<Total(); i++)
        {
         _ctfe=GetNodeAtIndex(i);
         if(GetPointer(_ctfe)!=NULL)
            Print(" color: ",_ctfe.colorEleName," TFName: ",_ctfe.TFEleName," TF: ",_ctfe.TFEle," real Colr: ",_ctfe.colorEle);
         else
            Print(__FUNCTION__," NULL POINTER ColorTFEle");
        }
      Print("-------------------------------------------------------------------------------------------------------");
     }
  }
//+------------------------------------------------------------------+
//| ColorTFEle                                                       |
//+------------------------------------------------------------------+
class ColorTFEle:public CObject
  {
public:
   color             colorEle;
   string            colorEleName;
   ENUM_TIMEFRAMES   TFEle;
   string            TFEleName;
                     ColorTFEle() {};
                    ~ColorTFEle() {};
   void              ColorTFEle::setcolorTF(color _clr, ENUM_TIMEFRAMES _TF, string  _clrName, string _tfName);
  };
void ColorTFEle::setcolorTF(color _clr, ENUM_TIMEFRAMES _TF, string  _clrName, string _tfName)
  {
   colorEle = _clr;
   colorEleName =_clrName;
   TFEle = _TF;
   TFEleName = _tfName;
  }
//+------------------------------------------------------------------+
