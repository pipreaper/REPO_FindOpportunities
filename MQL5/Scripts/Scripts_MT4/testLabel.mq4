#property strict
//--- description
#property description "Script creates \"Label\" graphical object."
//--- display window of the input parameters during the script's launch
#property script_show_inputs
//--- input parameters of the script
input string            InpName="Label";         // Label name
input int               InpX=150;                // X-axis distance
input int               InpY=150;                // Y-axis distance
input string            InpFont="Arial";         // Font
input int               InpFontSize=14;          // Font size
input color             InpColor=clrRed;         // Color
input double            InpAngle=0.0;            // Slope angle in degrees
input ENUM_ANCHOR_POINT InpAnchor=ANCHOR_CENTER; // Anchor type
input bool              InpBack=false;           // Background object
input bool              InpSelection=true;       // Highlight to move
input bool              InpHidden=true;          // Hidden in the object list
input long              InpZOrder=0;             // Priority for mouse click
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the text label                                              |
//+------------------------------------------------------------------+
bool LabelMove(const long   chart_ID=0,   // chart's ID
               const string name="Label", // label name
               const int    x=0,          // X coordinate
               const int    y=0)          // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--- move the text label
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change corner of the chart for binding the label                 |
//+------------------------------------------------------------------+
bool LabelChangeCorner(const long             chart_ID=0,               // chart's ID
                       const string           name="Label",             // label name
                       const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) // chart corner for anchoring
  {
//--- reset the error value
   ResetLastError();
//--- change anchor corner
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner))
     {
      Print(__FUNCTION__,
            ": failed to change the anchor corner! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool LabelTextChange(const long   chart_ID=0,   // chart's ID
                     const string name="Label", // object name
                     const string text="Text")  // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool LabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
  {
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- store the label's coordinates in the local variables
   int x=InpX;
   int y=InpY;
//--- chart window size
   long x_distance;
   long y_distance;
//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return;
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart height! Error code = ",GetLastError());
      return;
     }
//--- check correctness of the input parameters
   if(InpX<0 || InpX>x_distance-1 || InpY<0 || InpY>y_distance-1)
     {
      Print("Error! Incorrect values of input parameters!");
      return;
     }
//--- prepare initial text for the label
   string text;
   
   text=StringConcatenate("Upper left corner: ",x,",",y);
//--- create a text label on the chart
   if(!LabelCreate(0,InpName,0,InpX,InpY,CORNER_LEFT_UPPER,text,"WingDings",InpFontSize,
      InpColor))
     {
      return;
     }

//--- change the label text
 //  text=StringConcatenate("twat: ",x,",",y);
   LabelTextChange(0,InpName,CharToStr(234));   
   //if(!LabelTextChange(0,InpName,text))
   //   return;
//--- redraw the chart and wait for two seconds
   ChartRedraw();
      LabelTextChange(0,InpName,CharToStr(233)); 
      ChartRedraw();
   Sleep(2000);

//---
  }
//+------------------------------------------------------------------+
//| The function moves the object and changes its text               |
//+------------------------------------------------------------------+
bool MoveAndTextChange(const int x,const int y,string text)
  {
//--- move the label
   if(!LabelMove(0,InpName,x,y))
      return(false);
//--- change the label text
   text=StringConcatenate(text,x,",",y);
   if(!LabelTextChange(0,InpName,text))
      return(false);
//--- check if the script's operation has been forcefully disabled
   if(IsStopped())
      return(false);
//--- redraw the chart
   ChartRedraw();
// 0.01 seconds of delay
   Sleep(10);
//--- exit the function
   return(true);
  }
//+------------------------------------------------------------------+
