//+------------------------------------------------------------------+
//|                                                  Margin Mode.mq5 |
//|                               Copyright ©2016, Robertomar Trader |
//|                            https://robertomartrader.blogspot.com |
//|                                       robertomartrader@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright ©2016, Robertomar Trader"
#property link      "https://robertomartrader.blogspot.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
// hedging
    ENUM_ACCOUNT_MARGIN_MODE margin_mode;
    string hedge = IsHedging(margin_mode) ? "allowed" : "not allowed";    
    PrintFormat("Margin Mode: %s.  Hedging %s", EnumToString(margin_mode), hedge);
// Netting
    string net = IsNetting(margin_mode) ? "allowed" : "not allowed";    
    PrintFormat("Margin Mode: %s.  Netting %s", EnumToString(margin_mode), net);   
  }
  
//+------------------------------------------------------------------+

bool IsHedging(ENUM_ACCOUNT_MARGIN_MODE &margmod) 
{ 
  
  margmod = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  return(margmod==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING); 

}
bool IsNetting(ENUM_ACCOUNT_MARGIN_MODE &margmod) 
{ 
  
  margmod = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  return(margmod==ACCOUNT_MARGIN_MODE_RETAIL_NETTING); 

}

//+------------------------------------------------------------------+
