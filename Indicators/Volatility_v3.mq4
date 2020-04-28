//+------------------------------------------------------------------+
//|                                                Volatility_v3.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 CornflowerBlue
#property indicator_color2 IndianRed
#property indicator_width1 1
#property indicator_width2 1
//---- input parameters
  extern int P=24;
//---- indicator buffers
  double ExtHighBuffer[];
  double ExtLowBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
  SetIndexBuffer(0,ExtHighBuffer);
  SetIndexStyle (0,DRAW_LINE);
  SetIndexLabel (0,"Vol. High");
  SetIndexBuffer(1,ExtLowBuffer);
  SetIndexStyle (1,DRAW_LINE);
  SetIndexLabel (1,"Vol. Low");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Price_High");
   ObjectDelete("Price_Low");
   ObjectDelete("Line_High");
   ObjectDelete("Line_Low");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //int    counted_bars=IndicatorCounted();
//----
int i,firstbar,lastbar;
 
firstbar=WindowFirstVisibleBar();
 
if (firstbar<WindowBarsPerChart())
   {
    lastbar=0;
   }
   else
   {
    lastbar=firstbar-WindowBarsPerChart();
   }
//----
for(i=lastbar;i<=firstbar;i++)   
     {
      ExtHighBuffer[i]=High[iHighest(NULL,0,MODE_HIGH,P,i-P/2)];
      ExtLowBuffer[i]= Low [iLowest (NULL,0,MODE_LOW, P,i-P/2)];
     }
//----
   double P_H=High[iHighest(NULL,0,MODE_HIGH,P,0)];
   double P_L=Low [iLowest (NULL,0,MODE_LOW, P,0)];
//----

   if (ObjectFind("Price_High")!= 0)
      {
       ObjectCreate("Price_High", OBJ_ARROW, 0, Time[0], P_H);
       ObjectSet("Price_High",OBJPROP_ARROWCODE,6);
       ObjectSet("Price_High",OBJPROP_COLOR,Blue);
       ObjectSet("Price_High",OBJPROP_WIDTH,1);
       ObjectSet("Price_High",OBJPROP_BACK,true);
      }
      else
      {
       ObjectMove("Price_High", 0, Time[0], P_H);
      }

//----

   if (ObjectFind("Price_Low")!= 0)
      {
       ObjectCreate("Price_Low",  OBJ_ARROW, 0, Time[0], P_L);
       ObjectSet("Price_Low",OBJPROP_ARROWCODE,6);
       ObjectSet("Price_Low",OBJPROP_COLOR,Red);
       ObjectSet("Price_Low",OBJPROP_WIDTH,1);
       ObjectSet("Price_Low",OBJPROP_BACK,true);
      }
      else
      {
       ObjectMove("Price_Low",  0, Time[0], P_L);
      }

//----

   if (ObjectFind("Line_High")!= 0)
       {
        ObjectCreate("Line_High", OBJ_TREND, 0, Time[P/2], P_H, Time[0], P_H);
        ObjectSet("Line_High",OBJPROP_COLOR,Blue);
        ObjectSet("Line_High",OBJPROP_STYLE,0);
        ObjectSet("Line_High",OBJPROP_WIDTH,1);
        ObjectSet("Line_High",OBJPROP_RAY,false);
        ObjectSet("Line_High",OBJPROP_BACK,false);
       }
   else
       {
        ObjectDelete("Line_High");
        ObjectCreate("Line_High", OBJ_TREND, 0, Time[P/2], P_H, Time[0], P_H);
        ObjectSet("Line_High",OBJPROP_COLOR,Blue);
        ObjectSet("Line_High",OBJPROP_STYLE,0);
        ObjectSet("Line_High",OBJPROP_WIDTH,1);
        ObjectSet("Line_High",OBJPROP_RAY,false);
        ObjectSet("Line_High",OBJPROP_BACK,false);
       }

//----

   if (ObjectFind("Line_Low")!= 0)
       {
        ObjectCreate("Line_Low", OBJ_TREND, 0, Time[P/2], P_L, Time[0], P_L);
        ObjectSet("Line_Low",OBJPROP_COLOR,Red);
        ObjectSet("Line_Low",OBJPROP_STYLE,0);
        ObjectSet("Line_Low",OBJPROP_WIDTH,1);
        ObjectSet("Line_Low",OBJPROP_RAY,false);
        ObjectSet("Line_Low",OBJPROP_BACK,false);
       }
   else
       {
        ObjectDelete("Line_Low");
        ObjectCreate("Line_Low", OBJ_TREND, 0, Time[P/2], P_L, Time[0], P_L);
        ObjectCreate("Line_Low", OBJ_TREND, 0, Time[P/2], P_L, Time[0], P_L);
        ObjectSet("Line_Low",OBJPROP_COLOR,Red);
        ObjectSet("Line_Low",OBJPROP_STYLE,0);
        ObjectSet("Line_Low",OBJPROP_WIDTH,1);
        ObjectSet("Line_Low",OBJPROP_RAY,false);
        ObjectSet("Line_Low",OBJPROP_BACK,false);
       }

//----

   return(0);
  }
//+------------------------------------------------------------------+