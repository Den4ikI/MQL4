//+------------------------------------------------------------------+
//|                                                  RenderLabel.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   ObjectCreate("Label_Obj_MACD", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Label_Obj_MACD", "Opa", 10, "Arial");
   ObjectSet("Label_Obj_MACD", OBJPROP_CORNER, 1);
   ObjectSet("Label_Obj_MACD", OBJPROP_XDISTANCE, 10);
   ObjectSet("Label_Obj_MACD", OBJPROP_YDISTANCE, 15);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

string CandleTimeLeft()
  {
//---
   string TimeLeft;
   int offset;
   TimeLeft=TimeToStr(Time[0]+Period()*60-TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
//---
   return TimeLeft;
  }