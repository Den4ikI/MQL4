//+------------------------------------------------------------------+
//|                                                     GamExpert.mq4|
//|                                                          liapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double Lot=0.05;
extern int TrailingStop=20; // трейлинг стоп
extern int delta=15;
extern int MagicNumber=12345;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BB1=NormalizeDouble(iCustom(NULL,0,"Gambit",2,0),Digits); // верхняя линия боллинджера для установки тп по баю
double LL=NormalizeDouble(iCustom(NULL,0,"Gambit",4,0),Digits);  // нижняя линия боллинджера для установки тп по селу
double Prots=0.1;
string Symb=Symbol();
int frctl_zoom=30;
double point1=Point;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

     {
      DrawLogo2();
      return(0);
     }


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
   double Fractal_H=High[1]+Point*frctl_zoom; //нужно вытащить из 1fractal
   double Fractal_L=Low[1]-Point*frctl_zoom;  //нужно вытащить из 1fractal

   if(different()>delta)
     {
      if(NormalizeDouble(iCustom(NULL,0,"1fractal",0,1),Digits)==Fractal_H)
        {
         if(TotalOpenOrders() == 0 && IsNewCandle() == true)
           {
            OpenSell();
           }
        };
      if(NormalizeDouble(iCustom(NULL,0,"1fractal",1,1),Digits)==Fractal_L)
        {
         if(TotalOpenOrders() == 0 && IsNewCandle() == true)
           {
            OpenBuy();
           }
        };
     }
   else
      return;
/*
модификация ордера
условие закрытия покупки
если Low[2]>Close[1] && Bid<NormalizeDouble(iCustom(NULL,0,"Gambit",1,0),Digits)
условие закрытия продажи
если Close[1]>High[2] && Ask>NormalizeDouble(iCustom(NULL,0,"Gambit",3,0),Digits)
*/
  }
//+------------------------------------------------------------------+
void OpenBuy()
  {
   int tiket=OrderSend(Symb,OP_BUY,Lot,Ask,10,NormalizeDouble((LL+Low[1])/2,Digits),BB1, "im buy", MagicNumber);
   Comment(StringFormat("цена покупки = %G\nTP = %G\nSL = %G\nошибка =%G",Ask,BB1,Low[1]-10*Point,GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell()
  {
   int tiket=OrderSend(Symb,OP_SELL,Lot,Bid,10,NormalizeDouble((BB1+High[1])/2,Digits),LL, "im sell", MagicNumber);
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
/*
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
 аналог */
datetime NewCandleTime=TimeCurrent();
bool IsNewCandle()
  {
   if(NewCandleTime==iTime(Symbol(),0,0))
      return(false);
   else
     {
      NewCandleTime=iTime(Symbol(),0,0);
      return(true);
     }
  }

//+------------------------------------------------------------------+
//
void DrawLogo2()
  {
   string l_name_8 = "Logo" + "10";
   l_name_8 = "Logo" + "11";
   if(ObjectFind(l_name_8) == -1)
     {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 3);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 5);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 5);
     }
   ObjectSetText(l_name_8, StringFormat("Угол наклона=%G\n",different()), 8, "Verdana", Silver);


   l_name_8 = "Logo" + "12";
   if(ObjectFind(l_name_8) == -1)
     {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 3);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 5);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 20);
     }
   ObjectSetText(l_name_8, StringFormat("Ваш лот = %G\n",Lot), 10, "Verdana", Red);
  }
//+------------------------------------------------------------------+
double different() //наклон средней
  {
   double iMA5 = iMA(NULL, 0, 20, 5, MODE_SMA, PRICE_CLOSE, 5);
   double iMA1 = iMA(NULL, 0, 20, 5, MODE_SMA, PRICE_CLOSE, 1);

   double diff = MathAbs(iMA5 - iMA1)/point1;
   return NormalizeDouble(diff,Digits);
   
  }

//+------------------------------------------------------------------+
