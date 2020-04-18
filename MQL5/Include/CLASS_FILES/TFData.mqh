// +------------------------------------------------------------------+
// |                                                        tfObj.mqh |
// |                                    Copyright 2019, Robert Baptie |
// |                                             https:// www.mql5.com |
// +------------------------------------------------------------------+
#property copyright "Copyright 2019, Robert Baptie"
#property link      "https:// www.mql5.com"
#property strict
#include <INCLUDE_FILES\\WaveLibrary.mqh>
class TFDataObj
  {
public:
   ENUM_TIMEFRAMES   chartTF;
   ENUM_TIMEFRAMES   useTF[];
   color             tfColor[];
   bool              showTrendWave[3];
   int               numberWindows;
   bool              showDiaTrendLine[3];
   int               trendIndex[3];
   bool              showCCI[3];
   bool              showEMA[3];
   void              TFDataObj::TFDataObj();
   void TFDataObj:: ~TFDataObj();
   void              TFDataObj::ToLog(string desc,bool show);
  };
// +------------------------------------------------------------------+
// |constructor                                                       |
// +------------------------------------------------------------------+
void TFDataObj::TFDataObj()  {}
// +------------------------------------------------------------------+
// |To Log: last node to print is most current                        |
// +------------------------------------------------------------------+
void              TFDataObj::ToLog(string desc,bool show)
  {
   if(show)
     {
      for(int i=0; i<ArraySize(this.useTF); i++)
         Print(" TFs all data ",EnumToString(this.useTF[i]));
     }
   Print("-------------------------------------------------------------------------------------------------------");
  }
// +------------------------------------------------------------------+
// |~Destructor                                                       |
// +------------------------------------------------------------------+
void TFDataObj::~TFDataObj() {}
//+------------------------------------------------------------------+
//|TFDataObj                                                         |
//+------------------------------------------------------------------+
class TFTrendDataObj:public TFDataObj
  {
public:
   bool              showATR[3];
   void              TFTrendDataObj() : TFDataObj()
     {
      numberWindows=0;
     }
   // Destructor
   void                 ~TFTrendDataObj() {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TFLevelDataObj:public TFDataObj
  {
public:
   bool              showLevels;
   // constructor
   void              TFLevelDataObj() : TFDataObj() {};
   // initLevels
   void              TFLevelDataObj::initLevels(bool _showLevels);
   // ~Destructor
   void              ~TFLevelDataObj() {};
  };
// +------------------------------------------------------------------+
// |~initLevels                                                       |
// +------------------------------------------------------------------+
void TFLevelDataObj::initLevels(bool _showLevels)
  {
   showLevels = _showLevels;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TFVolumeDataObj:public TFDataObj
  {
public:
   bool              showVolumes;
   bool              showATR[5];
   // constructor
                     TFVolumeDataObj::TFVolumeDataObj() : TFDataObj()
     {
      numberWindows=0;
     };
   // initVolumes
   void              TFVolumeDataObj::initVolumes(bool _showVolumes);
   // ~Destructor
                    ~TFVolumeDataObj() {};
  };
// +------------------------------------------------------------------+
// |~initVolumes                                                      |
// +------------------------------------------------------------------+
void TFVolumeDataObj::initVolumes(bool _showVolumes)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TFAllDataObj:public TFDataObj
  {
public:
   // constructor
   void                 TFAllDataObj::TFAllDataObj();
   // check tf is already in array
   bool                 TFAllDataObj::alreadyInArray(ENUM_TIMEFRAMES _isIn);
   void                 TFAllDataObj::ToLog(string desc,bool show);
   // ~Destructor
   void                 TFAllDataObj:: ~TFAllDataObj();
  };
//+------------------------------------------------------------------+
//| constructor                                                      |
//+------------------------------------------------------------------+
void TFAllDataObj::TFAllDataObj(): TFDataObj()
  {
  }
//+------------------------------------------------------------------+
//| destructor                                                       |
//+------------------------------------------------------------------+
void TFAllDataObj:: ~TFAllDataObj()
  {
  }
//+------------------------------------------------------------------+
//| alreadyInArray                                                   |
//+------------------------------------------------------------------+
bool   TFAllDataObj::alreadyInArray(ENUM_TIMEFRAMES _isIn)
  {
   bool condition = false;
   for(int i = 0 ; i< ArraySize(useTF); i++)
     {
      if(_isIn == this.useTF[i])
        {
         condition = true;
         break;
        }
     }
   return condition;
  }
// +------------------------------------------------------------------+
// |To Log: last node to print is most current                        |
// +------------------------------------------------------------------+
void              TFAllDataObj::ToLog(string desc,bool show)
  {
   if(show)
     {
      for(int i=0; i<ArraySize(this.useTF); i++)
         Print(" Tfs all data ",EnumToString(this.useTF[i]));
     }
   Print("-------------------------------------------------------------------------------------------------------");
  }
//+------------------------------------------------------------------+
