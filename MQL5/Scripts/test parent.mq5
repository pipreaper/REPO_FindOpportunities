//+------------------------------------------------------------------+
//|                                                  test parent.mq5 |
//|                                    Copyright 2019, Robert Baptie |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https://www.mql5.com"
#property version   "1.00"
class Parent;
class Child 
{
   Parent *parent;   
   public:
   void setParent(Parent *p) { parent = p; };      
};

class Parent
{
   Child *child;
   
   public:
      Parent()
      {
         child = new Child();
         child.setParent(GetPointer(this)); // << Can we do something like this?
      }
      ~Parent();
};
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
  }
//+------------------------------------------------------------------+
