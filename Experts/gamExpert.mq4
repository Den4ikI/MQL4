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
extern bool TrailingStop=true; // трейлинг стоп
extern int delta=15;        // дельта средних
extern int MagicNumber=12345;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BB1=NormalizeDouble(iCustom(NULL,0,"Gambit",2,0),_Digits); // верхняя линия боллинджера для установки тп по баю
double LL=NormalizeDouble(iCustom(NULL,0,"Gambit",4,0),_Digits);  // нижняя линия боллинджера для установки тп по селу
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
   int total=OrdersTotal();
   
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
        }
    }
    else 
    {
    return;
    }

/*

*/
//---
  }

//+------------------------------------------------------------------+
void OpenBuy()
  {
   int tiket=OrderSend(Symb,OP_BUY,Lot,Ask,10,Low[1]-30.0*point1,BB1, "im buy", MagicNumber);
   PlaySound("alert2.wav");
   Comment(StringFormat("цена покупки = %G\nTP = %G\nSL = %G\nошибка =%G",Ask,BB1,Low[1]-30*Point,GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell()
  {
   int tiket=OrderSend(Symb,OP_SELL,Lot,Bid,10,High[1]+30.0*point1,LL, "im sell", MagicNumber);
   PlaySound("alert2.wav");
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
   ObjectSetText(l_name_8, StringFormat("Дельта средних=%G\n,",Spraed), 8, "Verdana", Silver);


   l_name_8 = "Logo" + "12";
   if(ObjectFind(l_name_8) == -1)
     {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 3);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 5);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 20);
     }
   ObjectSetText(l_name_8, StringFormat("Ваш лот = %G\n,",Lot), 10, "Verdana", Red);
  }
//+------------------------------------------------------------------+
double different() //наклон средней
  {
   double iMA10=iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double iMA20=iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);

   double diff = MathAbs((iMA20-iMA10)/Point);
   return (NormalizeDouble(diff,0));
   
  }

//+------------------------------------------------------------------+
