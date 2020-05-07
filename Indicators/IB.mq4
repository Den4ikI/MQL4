//+------------------------------------------------------------------+
//|                                                           IB.mq4 |
//|                                                          liapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1

double Fractal_H[],Fractal_L[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    
   SetIndexBuffer(0,Fractal_H);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(1,Fractal_L);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
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
//----

     }
//----
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+