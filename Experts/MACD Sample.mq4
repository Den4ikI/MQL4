//+------------------------------------------------------------------+
//|                                                  MACD Sample.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"

input double TakeProfit    =50;
input double Lots          =0.1;
input double TrailingStop  =30;
input double MACDOpenLevel =3;
input double MACDCloseLevel=2;
input int    MATrendPeriod =26;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   double MacdCurrent,MacdPrevious;
   double SignalCurrent,SignalPrevious;
   double MaCurrent,MaPrevious;
   int    cnt,ticket,total;
//---
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external 
// variables (Lots, StopLoss, TakeProfit, 
// TrailingStop) in our case, we check TakeProfit
// on a chart of less than 100 bars
//---
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;
     }
//--- для упрощения кодирования и ускорения доступа данные помещаются во внутренние переменные
   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);

   total=OrdersTotal();
   if(total<1)
     {
      //--- открытие ордера
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("У вас нет денег. Свободная маржа = ",AccountFreeMargin());
         return;
        }
      //--- проверка условий для покупки
      if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && 
         MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening BUY order : ",GetLastError());
         return;
        }
      //--- проверка условий для продажи
      if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("SELL order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening SELL order : ",GetLastError());
        }
      //--- выход из блока «нет открытых ордеров»
      return;
     }
//--- важно правильно войти в рынок, но важнее правильно выйти ...   
   for(cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // проверить открытую позицию 
         OrderSymbol()==Symbol())  // проверить на символ
        {
         //--- открыта длинная позиция
         if(OrderType()==OP_BUY)
           {
            //--- Закрыть?
            if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
               MacdCurrent>(MACDCloseLevel*Point))
              {
               //--- закрыть ордер и выйти
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- проверить трейлинг-стоп
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     //--- изминить ордер и выйти
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // переход к короткой позиции
           {
            //--- Закрыть?
            if(MacdCurrent<0 && MacdCurrent>SignalCurrent && 
               MacdPrevious<SignalPrevious && MathAbs(MacdCurrent)>(MACDCloseLevel*Point))
              {
               //--- закрыть ордер и выйти
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- проверка трейлинг-стопа
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
