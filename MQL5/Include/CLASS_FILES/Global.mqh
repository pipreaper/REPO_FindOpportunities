class Global
  {
public:
   // create new S/R line
   ENUM_LINE_STYLE   style; // line style
   int               width;           // line width
   bool              back;        // in the background
   bool              selection;// highlight to move
   bool              rayRight;   // line's continuation to the right
   bool              hidden;       // hidden in the object list
   long              zOrder;         // priority for mouse click
   int               subWindow;
   int               fontSize;
   string            fontType;// "Times New Roman";// "Windings";
   double            angle;
   ENUM_ANCHOR_POINT anchor;
   bool              fill;
   void              Global::Global();
  };
void   Global::Global()
  {
   style=STYLE_SOLID;// line style
   width=1;           // line width
   back=true;        // in the background
   selection=false;// highlight to move
   rayRight=false;   // line's continuation to the right
   hidden=true;       // hidden in the object list
   zOrder=0;         // priority for mouse click
   subWindow =0;
   fontSize=10;
   fontType="Arial Bold";// "Times New Roman";// "Windings";
   angle=0;
   anchor=ANCHOR_RIGHT;
   fill=false;
  }
