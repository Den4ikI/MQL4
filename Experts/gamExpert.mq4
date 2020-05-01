//+------------------------------------------------------------------+
//|                                                     GamExpert.mq4 |
//|                                                          liapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double Lot=0.05;
extern int TrailingStop=20; // трейлинг стоп
extern int MagicNumber=12345;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BB1=NormalizeDouble(iCustom(NULL,0,"Gambit",2,0),Digits); // верхняя линия боллинджера для установки тп по баю
double LL=NormalizeDouble(iCustom(NULL,0,"Gambit",4,0),Digits);  // нижняя линия боллинджера для установки тп по селу
double Prots=0.1;
string Symb=Symbol();
int frctl_zoom=30;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()


  {
//---
   int cnt;
   double Fractal_H=High[1]+Point*frctl_zoom; //нужно вытащить из 1fractal
   double Fractal_L=Low[1]-Point*frctl_zoom;  //нужно вытащить из 1fractal

   if(NormalizeDouble(iCustom(NULL,0,"1fractal",0,1),Digits)==Fractal_H)
     {
      if(TotalOpenOrders() == 0 && IsNewBar() == true)
        {
         OpenSell();
        }
     };
   if(NormalizeDouble(iCustom(NULL,0,"1fractal",1,1),Digits)==Fractal_L)
     {
      if(TotalOpenOrders() == 0 && IsNewBar() == true)
        {
         OpenBuy();
        }
     };
// управление трейлинг-стопом
   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // проверить открытую позицию
         OrderSymbol()==Symbol())  // проверить на символ
        {
         //--- открыта длинная позиция
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
//+------------------------------------------------------------------+
void OpenBuy()
  {
   int tiket=OrderSend(Symb,OP_BUY,Lot,Ask,10,(LL+Low[1])/2,BB1, "im buy", MagicNumber);
   Comment(StringFormat("цена покупки = %G\nTP = %G\nSL = %G\nошибка =%G",Ask,BB1,Low[1]-10*Point,GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell()
  {
   int tiket=OrderSend(Symb,OP_SELL,Lot,Bid,10,(BB1+High[1])/2,LL, "im sell", MagicNumber);
   Comment(StringFormat("цена продажи = %G\nTP = %G\nSL = %G\nошибка =%G",Bid,LL,High[1]+10*Point,GetLastError()));
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalOpenOrders()
  {
   int total_orders = 0;

   for(int order = 0; order < OrdersTotal(); order++)
     {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false)
         break;

      if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol)
        {
         total_orders++;
        }
     }

   return(total_orders);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime RegBarTime=0;
   datetime ThisBarTime = Time[0];

   if(ThisBarTime == RegBarTime)
     {
      return(false);
     }
   else
     {
      RegBarTime = ThisBarTime;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//
