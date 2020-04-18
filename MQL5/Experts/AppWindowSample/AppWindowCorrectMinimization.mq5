//+------------------------------------------------------------------+
//|                                 AppWindowCorrectMinimization.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.000"
#property description "Control Panels and Dialogs. Demonstration class CButton"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//---
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CAppWindowCorrectMinimization : public CAppDialog
  {
private:
   CButton           m_button1;                       // the button object
   CButton           m_button2;                       // the button object

public:
                     CAppWindowCorrectMinimization(void);
                    ~CAppWindowCorrectMinimization(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);

protected:
   //--- create dependent controls
   bool              CreateButton1(void);
   bool              CreateButton2(void);
   //--- override the parent method
   virtual void      Minimize(void);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAppWindowCorrectMinimization::CAppWindowCorrectMinimization(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAppWindowCorrectMinimization::~CAppWindowCorrectMinimization(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CAppWindowCorrectMinimization::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateButton1())
      return(false);
   if(!CreateButton2())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
CAppWindowCorrectMinimization ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog
   if(!ExtDialog.Create(0,"AppWindowClass with Two Buttons",0,40,40,380,344))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool CAppWindowCorrectMinimization::CreateButton1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;        // x1            = 11  pixels
   int y1=INDENT_TOP;         // y1            = 11  pixels
   int x2=x1+BUTTON_WIDTH;    // x2 = 11 + 100 = 111 pixels
   int y2=y1+BUTTON_HEIGHT;   // y2 = 11 + 20  = 32  pixels
//--- create
   if(!m_button1.Create(0,"Button1",0,x1,y1,x2,y2))
      return(false);
   if(!m_button1.Text("Button1"))
      return(false);
   if(!Add(m_button1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button2"                                             |
//+------------------------------------------------------------------+
bool CAppWindowCorrectMinimization::CreateButton2(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+2*(BUTTON_WIDTH+CONTROLS_GAP_X);   // x1 = 11  + 2 * (100 + 5) = 221 pixels
   int y1=INDENT_TOP;                                    // y1                       = 11  pixels
   int x2=x1+BUTTON_WIDTH;                               // x2 = 221 + 100           = 321 pixels
   int y2=y1+BUTTON_HEIGHT;                              // y2 = 11  + 20            = 31  pixels
//--- create
   if(!m_button2.Create(0,"Button2",0,x1,y1,x2,y2))
      return(false);
   if(!m_button2.Text("Button2"))
      return(false);
   if(!Add(m_button2))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAppWindowCorrectMinimization::Minimize(void)
  {
//--- a variable for checking the one-click trading panel
   long one_click_visible=-1;  // 0 - панели быстрой торговли нет 
   if(!ChartGetInteger(m_chart_id,CHART_SHOW_ONE_CLICK,0,one_click_visible))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- the minimum indent for a minimized panel
   int min_y_indent=28;
   if(one_click_visible)
      min_y_indent=100;  // отступ, если быстрая торговля показана на графике
//--- getting the current indent for the minimized panel
   int current_y_top=m_min_rect.top;
   int current_y_bottom=m_min_rect.bottom;
   int height=current_y_bottom-current_y_top;
//--- сalculating the minimum indent from top for a minimized panel of the application
   if(m_min_rect.top!=min_y_indent)
     {
      m_min_rect.top=min_y_indent;
      //--- shifting the lower border of the minimized icon
      m_min_rect.bottom=m_min_rect.top+height;
     }
//--- Now we can call the method of the base class
   CAppDialog::Minimize();
  }
//+------------------------------------------------------------------+
