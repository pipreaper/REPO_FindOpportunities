//+------------------------------------------------------------------+
//|                                                       arrows.mq4 |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include    <\\INCLUDE_FILES\\drawing.mqh>
//--- input parameters of the script
input string            InpName="Arrow";        // Arrow name
input int               InpDate=50;             // Anchor point date in %
input int               InpPrice=50;            // Anchor point price in %
input ENUM_ARROW_ANCHOR InpAnchor=ANCHOR_TOP;   // Anchor type
input color             InpColor=clrDodgerBlue; // Arrow color
input ENUM_LINE_STYLE   InpStyle=STYLE_SOLID;   // Border line style
input int               InpWidth=10;            // Arrow size
input bool              InpBack=false;          // Background arrow
input bool              InpSelection=false;     // Highlight to move
input bool              InpHidden=true;         // Hidden in the object list
input long              InpZOrder=0;            // Priority for mouse click
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!ArrowCreate(0,InpName,0,Time[3],High[3],232,InpAnchor,InpColor,
      InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      return;
     }
     ArrowMove(0,InpName,Time[21],Low[21]);
//--- redraw the chart
   ChartRedraw();  
//const long chart_ID=0,           // chart's ID
//                 const string            name="Arrow",         // arrow name
//                 const int               sub_window=0,         // subwindow index
//                 datetime                time=0,               // anchor point time
//                 double                  price=0,              // anchor point price
//                 const uchar             arrow_code=252,       // arrow code
//                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position
//                 const color             clr=clrRed,           // arrow color
//                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
//                 const int               width=3,              // arrow size
//                 const bool              back=false,           // in the background
//                 const bool              selection=true,       // highlight to move
//                 const bool              hidden=true,          // hidden in the object list
//                 const long              z_order=0)            // priority for mouse click
 
  }
//+------------------------------------------------------------------+
