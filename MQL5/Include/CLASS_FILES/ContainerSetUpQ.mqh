////+------------------------------------------------------------------+
////|                                              ContainerSetUpQ.mqh |
////|                                    Copyright 2019, Robert Baptie |
////|                                             https://www.mql5.com |
////+------------------------------------------------------------------+
//#property copyright "Copyright 2019, Robert Baptie"
//#property link      "https://www.mql5.com"
//#property version   "1.00"
//#include <Arrays\List.mqh>
//#include <CLASS_FILES\SetUpEle.mqh>
//class ContainerSetUpQ : public CList
//  {
//private:
//
//public:
//                     ContainerSetUpQ();
//   bool              ContainerSetUpQ::cleanDiagLine();                     
//                    ~ContainerSetUpQ();
//  };
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//ContainerSetUpQ::ContainerSetUpQ()
//  {
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//ContainerSetUpQ::~ContainerSetUpQ()
//  {
//  }
//  //+------------------------------------------------------------------+
////| delete diagonal lines                                            |
////+------------------------------------------------------------------+
//bool ContainerSetUpQ::cleanDiagLine()
//  {
//   ResetLastError();
//// --- create a trend line by the given coordinates
//   for(int line = 0; line<this.Total(); line++)
//     {
//      SetUpEle *sue = this.GetNodeAtIndex(line);
//      if((CheckPointer(sue)==POINTER_INVALID) || !(ObjectDelete(ChartID(),sue.diaTrendLineName)))
//        {
//         //No trend line to delete
//         //Print(_dl.diaTrendLineName);
//         // Print(__FUNCTION__,": failed to delete a trend line! Error code = ",GetLastError()," Description: ",ErrorDescription(GetLastError()));
//         return(false);
//        }
//     }
//   return true;
//  }
//+------------------------------------------------------------------+
