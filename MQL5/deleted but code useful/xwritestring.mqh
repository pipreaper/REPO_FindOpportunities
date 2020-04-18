//+------------------------------------------------------------------+
//|                                                       EXPERT.mqh |
//|                                    Copyright 2019, Robert Baptie |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      ""
#property strict
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//|trendStageObj: Contains Stages of evolution of up or down trend   |
//+------------------------------------------------------------------+
class writeStringObj : public CObject
  {
public:
   int               fileHandle;
   string            fileName;
   //+------------------------------------------------------------------+
   //|constructor                                                       |
   //+------------------------------------------------------------------+
                     writeStringObj(string _fileName)
     {
      fileName=_fileName;
     }
   //+------------------------------------------------------------------+
   //|initialise file                                                   |
   //|accepts a const array of fixed size                               |    
   //+------------------------------------------------------------------+     
   void fileInit(const string &headers[])
     {
     string str=NULL;
     for (int i =0; i<ArraySize(headers); i++)
      str += headers[i]+";";
      fileHandle=NULL;
      if(FileIsExist(fileName))
         FileDelete(fileName);
      fileHandle=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_CSV);
      //file_handle=FileOpen(inpFileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
      if(fileHandle!=INVALID_HANDLE)        
         FileWrite(fileHandle,str);     
        // FileWrite(fileHandle,"waveHTFPeriod","shift","htfShift","Time[shift]","endFloatMax","endFloatMin");        
        else        
        PrintFormat("Bad handle, %s file is closed",fileName);        
     }
   //+------------------------------------------------------------------+
   //|fileClose:                                                        |
   //+------------------------------------------------------------------+     
   void fileClose()
     {
      //--- close the file
      FileClose(fileHandle);
      PrintFormat("Data is written, %s file is closed",fileName);
     }
   //+------------------------------------------------------------------+
   //|Write info string to file                                         |
   //|accepts an array of string types should match size fileInit       |   
   //+------------------------------------------------------------------+
   void writeInstruments(string &values[])
     {
     string str=NULL;
     for (int i =0; i<ArraySize(values); i++)
      str += values[i]+";";
           
      ResetLastError();
      if(fileHandle!=INVALID_HANDLE)
         FileWrite(fileHandle,str);
      else
        {
         PrintFormat("Failed to open %s file, Error code = %d",fileName,GetLastError());
         return;
        }
     }
  };
//+------------------------------------------------------------------+
