//+------------------------------------------------------------------+
//|                                               Table of Web Colors|
//|                         Copyright 2011, MetaQuotes Software Corp |
//|                                        https://www.metaquotes.net |
//+------------------------------------------------------------------+
#include <INCLUDE_FILES\\WaveLibrary.mqh>
#include    <\\INCLUDE_FILES\\drawText.mqh>
#include    <\\INCLUDE_FILES\\drawing.mqh>
const string fontTypeArrow ="Wingdings";
string arrow1="arrow1";
string arrow2="arrow2";
string arrow3="arrow3";

string arrowName1="arrow1Up";
string arrowName2="arrow2Down";
string arrowName3="arrow3Congested";
//+------------------------------------------------------------------+
//| Creating and initializing an edit object                         |
//+------------------------------------------------------------------+
void CreateArrow(string _name,string _nameArrow, uchar _code,int _panelX,int _panelY,color c)
  {
  string labelName = _name;
  string arrowLabelName = _nameArrow;
  uchar arrowCode = _code;
   LabelCreate(0,labelName,0,_panelX,_panelY,CORNER_LEFT_UPPER,_name,"Verdana",8,c);
  // ArrowCreate(
   LabelCreate(0,arrowLabelName,0,_panelX+100,_panelY,CORNER_LEFT_UPPER,CharToString(arrowCode),fontTypeArrow,10,c);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- create 7x20 table of colored edit objects
      CreateArrow(arrow1,arrowName1,228, 10,10,clrPink);
      CreateArrow(arrow2,arrowName2,230, 20,20,clrBlue);
      CreateArrow(arrow3,arrowName3,224, 30,30,clrRed);            
      //for(int i = 100; i>=0; i--)
      //{
         //ArrowCodeChange(0,arrowName,this.getArrowStyle(this.getTipState()));  
  uchar arrowCode1 = getArrowStyle(congested);
  LabelTextChange(ChartID(),arrowName1,CharToString(arrowCode1));  
  uchar arrowCode2 = getArrowStyle(up);
  LabelTextChange(ChartID(),arrowName2,CharToString(arrowCode2));  
  uchar arrowCode3 = getArrowStyle(down);
  LabelTextChange(ChartID(),arrowName3,CharToString(arrowCode3));      
  Sleep(1000);
 //     }
  }
// +------------------------------------------------------------------+
// | getLineStyle                                                     |
// +------------------------------------------------------------------+
uchar getArrowStyle(trendState tState)
  {
   if(tState==up)
      return uArrow;
   else
      if(tState==down)
         return dArrow;
      else
         if(tState==congested)
            return cArrow;
         else
            return NULL;
  }  
//+------------------------------------------------------------------+
