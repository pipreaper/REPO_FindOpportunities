// +------------------------------------------------------------------+
// |                                                       EXPERT.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                                                  |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      ""
#property strict
#include <Arrays\List.mqh>
#include <errordescription.mqh>
// +------------------------------------------------------------------+
// |Read a file with headers                                          |
// +------------------------------------------------------------------+
class ReadStringFile : public CObject
  {
public:
   int               fileHandle;
   string            fileName;
   bool              fileInit(string _fileName);
   bool              readSymbolsList(string &_symbolsArray[],bool _firstSymbolOnly);
   void              fileClose(string &_symbolsArray[],bool _isSingleSymbol);
  };
// +------------------------------------------------------------------+
// |initialise file                                                   |
// |accepts a const array of fixed size                               |
// +------------------------------------------------------------------+
bool ReadStringFile::fileInit(string _fileName)
  {
   if(!FileIsExist(_fileName,FILE_COMMON))
     {
      PrintFormat("Bad File, %s File Does Not Exist: ",fileName);
      return false;
     }
   fileName = _fileName;
   string seperator=",";
   fileHandle=FileOpen(fileName,FILE_CSV|FILE_ANSI|FILE_READ|FILE_COMMON,seperator,CP_ACP);
   if(fileHandle!=INVALID_HANDLE)
      return true;
   else
      PrintFormat("Bad handle, %s file is closed: ",fileName);
   return false;
  }
// +------------------------------------------------------------------+
// | readSymbolsList read Symbols to Trade                            |
// +------------------------------------------------------------------+
bool ReadStringFile::readSymbolsList(string &_symbolsArray[],bool _firstSymbolOnly)
  {
   int numInstruments=0;
   string   res[];
// --- read data from the file
   while(!FileIsEnding(fileHandle))
     {
      ZeroMemory(res);
      ArrayResize(res,2);
      for(int colNum=0; (colNum<2); colNum++)
        {
         // --- read the string
         res[colNum]=string(FileReadString(fileHandle));
         if(res[1]=="INCLUDE")
           {
            numInstruments++;
            int hasResized=ArrayResize(_symbolsArray,numInstruments);
            if(_firstSymbolOnly)
              {
               //Here its only the chart symbol you are interested in not what is in the files
               _symbolsArray[numInstruments-1]=_Symbol;
               return true;
              }
            else
               _symbolsArray[numInstruments-1]=res[0];
           }
        }
     }
   return true;
  }
// +------------------------------------------------------------------+
// |fileClose:                                                        |
// +------------------------------------------------------------------+
void ReadStringFile::fileClose(string &_symbolsArray[],bool _isSingleSymbol)
  {
// --- close the file
   FileClose(fileHandle);
   if(_isSingleSymbol)
      PrintFormat("Data is set to _Symbol: "+_Symbol);
   else
     {
      PrintFormat("Data is read, %s file is closed: ",fileName," Data that Expert will act on:");
      for(int i = 0; (i<ArraySize(_symbolsArray)); i++)
         Print(_symbolsArray[i]);
     }
  }
// +------------------------------------------------------------------+
// |Write info string to file                                         |
// |accepts an array of string types should match size fileInit       |
// +------------------------------------------------------------------+
// void writeInstruments(string &values[])
// {
// string str=NULL;
// for (int i =0; i<ArraySize(values); i++)
// str += values[i]+";";
//
// ResetLastError();
// if(fileHandle!=INVALID_HANDLE)
// FileWrite(fileHandle,str);
// else
// {
// PrintFormat("Failed to open %s file, Error code = %d",fileName,GetLastError());
// return;
// }
// }
// +------------------------------------------------------------------+
