// +------------------------------------------------------------------+
// |                                        GetBrokerSymbolTFData.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                             https:// www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https:// www.mql5.com"
#include    <\\CLASS_FILES\\TFData.mqh>
// +------------------------------------------------------------------+
// |getUpdatedHistory: get a symbol/tf history from broker server     |
// +------------------------------------------------------------------+
bool getUpdatedHistory(string _symbol, ENUM_TIMEFRAMES _waveHTFPeriod, int _minHistBars,int _maxHistBars,int &_numBarsFound)
  {
   bool condition=false;
// get history for chart expert dropped on
   bool success=createMoveDeleteChart(_symbol,_waveHTFPeriod,_minHistBars,_maxHistBars,_numBarsFound);
   if(!success)
     {
      Print(__FUNCTION__," Problem Loading Single Broker Data #Bars =  ",_symbol," #Bars Found: ",_numBarsFound," Min Hist Bars:",_minHistBars,"Max Hist Bars: ",_maxHistBars," ",EnumToString(_waveHTFPeriod));
      condition = false;
     }
   else
     {
      Print(__FUNCTION__," Succesfully Checked Single Broker Data #Bars =  ",_symbol," #Bars Found: ",_numBarsFound," Min Hist Bars:",_minHistBars,"Max Hist Bars: ",_maxHistBars," TF: ",EnumToString(_waveHTFPeriod));
      condition = true;
     }
   return condition;
  }
// +------------------------------------------------------------------+
// |createMoveDeleteChart                                             |
// |Force the terminal to load the data it has for the symbol/tf pair |
// +------------------------------------------------------------------+
bool createMoveDeleteChart(string _sym,ENUM_TIMEFRAMES  _tf,int _minHistBars,int _maxHistBars,int &_numBars)
  {
   bool condition=false;
   long handle=ChartOpen(_sym,_tf);
   ResetLastError();
   if(handle>0) // if successful, additionally set up the chart
     {
      // go to oldest time
      ChartNavigate(handle,CHART_BEGIN);
      // go to newest time
      ChartNavigate(handle,CHART_END);
      if(Bars(_sym,_tf)>=_minHistBars)
        {
         _numBars=Bars(_sym,_tf);
         Print(__FUNCTION__," succesfully read from broker ");
         condition=true;
        }
      else
        {
         _numBars=Bars(_sym,_tf);
         Print(__FUNCTION__," Not enough history Bars read: #Min bars: ", _minHistBars, " #BarsRead: ", _numBars);
         condition=false;
        }
      ChartClose(handle);
     }
     {
      string err = ErrorDescription(GetLastError());
      Print(__FUNCTION__," Check Symbol: ",_sym," is in watch list ", err);
      return condition;
     }
  }
//+------------------------------------------------------------------+