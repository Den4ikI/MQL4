//+------------------------------------------------------------------+
//|                                                    OpenOrder.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int Magic = 2323;
   int Ticket =OrderSend(_Symbol,OP_BUYSTOP,1,Bid + 30,2,Bid - 60,Bid + 60, "simple open order", Magic);
   Comment(GetLastError());
   Alert("hey ho");
  }
//+------------------------------------------------------------------+
