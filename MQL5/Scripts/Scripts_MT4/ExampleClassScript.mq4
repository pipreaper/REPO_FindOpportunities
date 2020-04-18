//+------------------------------------------------------------------+
//| Script starting function                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Example class with a few access types                            |
//+------------------------------------------------------------------+
class CBaseMathClass
  {
private:             //--- The private member is not available from derived classes
   double            m_Pi;
public:              //--- Getting and setting a value for m_Pi
   void              SetPI(double v){m_Pi=v;return;};
   double            GetPI(){return m_Pi;};
public:              // The class constructor is available to all members
                     CBaseMathClass() {SetPI(3.14);  PrintFormat("%s",__FUNCTION__);};
  };
//+------------------------------------------------------------------+
//| A derived class, in which m_Pi cannot be modified                |
//+------------------------------------------------------------------+
class CProtectedChildClass: protected CBaseMathClass // Protected inheritance
  {
private:
   double            m_radius;
public:              //--- Public methods in the derived class
   void              SetRadius(double r){m_radius=r; return;};
   double            GetCircleLength(){return GetPI()*m_radius;};
  };
void OnStart()
  {
//--- When creating a derived class, the constructor of the base class will be called automatically
   CProtectedChildClass pt;
//--- Specify radius
   pt.SetRadius(10);
   PrintFormat("Length=%G",pt.GetCircleLength());
//--- If we uncomment the line below, we will get an error at the stage of compilation, since SetPI() is now protected
// pt.SetPI(3); 
 
//--- Now declare a variable of the base class and try to set the Pi constant equal to 10
   CBaseMathClass bc;
   bc.SetPI(10);
//--- Here is the result
   PrintFormat("bc.GetPI()=%G",bc.GetPI());
  }
