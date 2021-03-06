//+------------------------------------------------------------------+
//|                                                   SymbolsLib.mq4 |
//|                                          Copyright © 2009, Ilnur |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

//    Áèáëèîòåêà ôóíêöèé äëÿ ðàáîòû ñ ôèíàíñîâûìè èíñòðóìåíòàìè,
// çàãðóæåííûìè â òîðãîâûé òåðìèíàë.

#property copyright "Copyright © 2009, Ilnur"
#property link      "http://www.metaquotes.net"
#property library

//+------------------------------------------------------------------+
//| Ôóíêöèÿ âîçâðàùàåò ñïèñîê äîñòóïíûõ ñèìâîëîâ                     |
//+------------------------------------------------------------------+
int symbolsList(string &symbols[], bool Selected)
{
   string symbolsFileName;
   int Offset, symbolsNumber;
   
   if(Selected) symbolsFileName = "symbols.sel";
   else         symbolsFileName = "symbols.raw";
   
// Îòêðûâàåì ôàéë ñ îïèñàíèåì ñèìâîëîâ

   int hFile = FileOpenHistory(symbolsFileName, FILE_BIN|FILE_READ);
   if(hFile < 0) return(-1);

// Îïðåäåëÿåì êîëè÷åñòâî ñèìâîëîâ, çàðåãèñòðèðîâàííûõ â ôàéëå

   if(Selected) { symbolsNumber = int((FileSize(hFile) - 4) / 128); Offset = 116;  }
   else         { symbolsNumber = int(FileSize(hFile) / 1936);      Offset = 1924; }

   ArrayResize(symbols, symbolsNumber);

// Ñ÷èòûâàåì ñèìâîëû èç ôàéëà

   if(Selected) FileSeek(hFile, 4, SEEK_SET);
   
   for(int i = 0; i < symbolsNumber; i++)
   {
      symbols[i] = FileReadString(hFile, 12);
      FileSeek(hFile, Offset, SEEK_CUR);
   }
   
   FileClose(hFile);
   
// Âîçâðàùàåì êîëè÷åñòâî ñ÷èòàííûõ èíñòðóìåíòîâ

   return(symbolsNumber);
}

//+------------------------------------------------------------------+
//| Ôóíêöèÿ âîçâðàùàåò ðàñøèôðîâàííîå íàçâàíèå ñèìâîëà               |
//+------------------------------------------------------------------+
string SymbolDescription(string SymbolName)
{
   string SymbolDescription = "";
   
// Îòêðûâàåì ôàéë ñ îïèñàíèåì ñèìâîëîâ

   int hFile = FileOpenHistory("symbols.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");

// Îïðåäåëÿåì êîëè÷åñòâî ñèìâîëîâ, çàðåãèñòðèðîâàííûõ â ôàéëå

   int SymbolsNumber = int(FileSize(hFile) / 1936);

// Èùåì ðàñøèôðîâêó ñèìâîëà â ôàéëå

   for(int i = 0; i < SymbolsNumber; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {
         SymbolDescription = FileReadString(hFile, 64);
         break;
      }
      FileSeek(hFile, 1924, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   return(SymbolDescription);
}

//+------------------------------------------------------------------+
//| Ôóíêöèÿ îïðåäåëÿåò òèï èíñòðóìåíòà                               |
//+------------------------------------------------------------------+
string SymbolType(string SymbolName)
{
   int GroupNumber = -1;
   string SymbolGroup = "";
   
// Îòêðûâàåì ôàéë ñ îïèñàíèåì ñèìâîëîâ

   int hFile = FileOpenHistory("symbols.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");
   
// Îïðåäåëÿåì êîëè÷åñòâî ñèìâîëîâ, çàðåãèñòðèðîâàííûõ â ôàéëå
   
   int SymbolsNumber = int(FileSize(hFile) / 1936);
   
// Èùåì ñèìâîë â ôàéëå
   
   for(int i = 0; i < SymbolsNumber; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {
      // Îïðåäåëÿåì íîìåð ãðóïïû
         
         FileSeek(hFile, 1936*i + 100, SEEK_SET);
         GroupNumber = FileReadInteger(hFile);
         
         break;
      }
      FileSeek(hFile, 1924, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   if(GroupNumber < 0) return("");
   
// Îòêðûâàåì ôàéë ñ îïèñàíèåì ãðóïï
   
   hFile = FileOpenHistory("symgroups.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");
   
   FileSeek(hFile, 80*GroupNumber, SEEK_SET);
   SymbolGroup = FileReadString(hFile, 16);
   
   FileClose(hFile);
   return(SymbolGroup);
}