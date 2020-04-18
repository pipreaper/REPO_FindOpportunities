#import "user32.dll"
   int GetAncestor(int hWnd, int gaFlags);
   int GetDlgItem(int hDlg, int nIDDlgItem);
   int PostMessageA(int hWnd, int Msg, int wParam, int lParam);
#import
#define WM_COMMAND   0x0111
#define WM_KEYDOWN   0x0100
#define VK_HOME      0x0024
#define VK_DOWN      0x0028

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
{
// New charts opens from the "Market Watch" window with the DEFAULT.TPL template.
   ChartWindow("GBPUSD..");
}

//+------------------------------------------------------------------+
//| Open a new chart                                                 |
//+------------------------------------------------------------------+
int ChartWindow(string Name)
{
   int hFile, SymbolsTotal, hTerminal, hWnd;

   hFile = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
   if(hFile < 0) { Alert("Error File open operation!"); return(-1); }

   SymbolsTotal = (FileSize(hFile) - 4) / 128;
   FileSeek(hFile, 4, SEEK_SET);

   hTerminal = GetAncestor(WindowHandle(Symbol(), PERIOD_M1/*Period()*/), 2);

   hWnd = GetDlgItem(hTerminal, 0xE81C);
   hWnd = GetDlgItem(hWnd, 0x50);
   hWnd = GetDlgItem(hWnd, 0x8A71);

   PostMessageA(hWnd, WM_KEYDOWN, VK_HOME, 0);

   for(int i = 0; i < SymbolsTotal; i++)
   {
      
      if(FileReadString(hFile, 12) == Name)
      {
         PostMessageA(hTerminal, WM_COMMAND, 33160, 0);
         return(0);
      }
      PostMessageA(hWnd, WM_KEYDOWN, VK_DOWN, 0);
      FileSeek(hFile, 116, SEEK_CUR);
      
   }

   FileClose(hFile);

   return(-1);
}
