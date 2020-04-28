//+------------------------------------------------------------------+
//|                                                         come.mq4 |
//|                                                          liapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int start()
   {
   double b=iCustom(NULL,0,"1fractal",0,0);
   Comment(b);
   return(0);
   }