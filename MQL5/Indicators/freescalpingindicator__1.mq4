#property copyright "Copyright 2010, Free Scalping Indicator"
#property link      "freescalpingindicators.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrBlue
#property indicator_color2 clrYellow
#property indicator_color3 clrRed

#property indicator_maximum  0.5
#property indicator_minimum -0.5

extern int intensity = 18;
extern int periods = 800;
double G_ibuf_84[];
double G_ibuf_88[];
double G_ibuf_92[];

int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2, Yellow);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 2, Red);
   SetIndexBuffer(0, G_ibuf_84);
   SetIndexBuffer(1, G_ibuf_88);
   SetIndexBuffer(2, G_ibuf_92);
   IndicatorShortName("All Free - FREESCALPINGINDICATORS.COM");
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   return (0);
}

int start() {
   int Li_0;
   double Ld_8;
   double Ld_16;
   double Ld_80;
   int Li_4 = IndicatorCounted();
   double Ld_32 = 0;
   double Ld_40 = 0;
   double Ld_unused_48 = 0;
   double Ld_unused_56 = 0;
   double Ld_64 = 0;
   double Ld_unused_72 = 0;
   double low_88 = 0;
   double high_96 = 0;
   if (Li_4 > 0) Li_4--;
   if (periods > Bars || periods == 0) Li_0 = Bars - intensity;
   else Li_0 = periods - intensity;
   for (int Li_104 = Li_0; Li_104 >= 0; Li_104--) {
      high_96 = High[iHighest(NULL, 0, MODE_HIGH, intensity, Li_104)];
      low_88 = Low[iLowest(NULL, 0, MODE_LOW, intensity, Li_104)];
      Ld_80 = (High[Li_104] + Low[Li_104]) / 2.0;
      Ld_32 = 0.66 * ((Ld_80 - low_88) / (high_96 - low_88) - 0.5) + 0.05 * Ld_40;
      Ld_32 = MathMin(MathMax(Ld_32, -0.999), 0.999);
      G_ibuf_84[Li_104] = MathLog((Ld_32 + 1.0) / (1 - Ld_32)) / 2.0 + Ld_64 / 2.0;
      Ld_40 = Ld_32;
      Ld_64 = G_ibuf_84[Li_104];
   }
   bool Li_108 = TRUE;
   for (Li_104 = Li_0 - 2; Li_104 >= 0; Li_104--) {
      Ld_16 = G_ibuf_84[Li_104];
      Ld_8 = G_ibuf_84[Li_104 + 1];
      if ((Ld_16 < 0.0 && Ld_8 > 0.0) || Ld_16 < 0.0) Li_108 = FALSE;
      if ((Ld_16 > 0.0 && Ld_8 < 0.0) || Ld_16 > 0.0) Li_108 = TRUE;
      if (!Li_108) {
         G_ibuf_92[Li_104] = Ld_16;
         G_ibuf_88[Li_104] = 0.0;
      } else {
         G_ibuf_88[Li_104] = Ld_16;
         G_ibuf_92[Li_104] = 0.0;
      }
   }
   return (0);
}
