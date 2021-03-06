//+------------------------------------------------------------------+
//|                                                     GamExpert.mq4|
//|                                                          liapkin |
//|                                             https://www.mql5.com 
//|                  Тейкпрофитов нет, сделки закрываються по условию 
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property tester_indicator "Gambit.ex4"  // файл с пользовательским индикатором, указанным в iCustom() в виде переменной
#property tester_indicator "1fractal.ex4"  // файл с пользовательским индикатором, указанным в iCustom() в виде переменной

extern double Lot=0.05;
extern bool TrailingStop=true; // трейлинг стоп
extern int delta=15;        // дельта средних
extern int MagicNumber=6767;

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
   int total=OrdersTotal();
   Comment(iBands(NULL,0,20,1,2,PRICE_CLOSE,MODE_UPPER,0));


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
   changeStopLoss();



   /*

   */
//---
  }

//+------------------------------------------------------------------+
void OpenBuy()
  {
   int tiket=OrderSend(Symb,OP_BUY,Lot,Ask,10,Low[1]-30.0*point1,0, "test Рома v3 buy", MagicNumber);
   Comment(StringFormat("цена покупки = %G\nTP = %G\nSL = %G\nошибка =%G",Ask,BB1,Low[1]-30*Point,GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell()
  {
   int tiket=OrderSend(Symb,OP_SELL,Lot,Bid,10,High[1]+30.0*point1,0, "test Рома v3 sell", MagicNumber);
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
   ObjectSetText(l_name_8, StringFormat("Дельта средних=%G\n,",different()), 8, "Verdana", Silver);


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
double different() //разница средних
  {
   double iMA10=iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double iMA20=iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);

   double diff = MathAbs((iMA20-iMA10)/Point);
   return (NormalizeDouble(diff,0));

  }
//+------------------------------------------------------------------+
void changeStopLoss()
  {

   double newStopLoss; //новое значение стоплосса если стоплосс нужно изменить
   bool result; // значение которое будет проверять верно ли віполнилась модификация ордера
   if(OrdersTotal() != 0 && IsNewCandle() == true)  //если есть какая либо сделка и появилась новая свеча
     {
      for(int order = 0; order <= OrdersTotal(); order++)  //идем проверять что єто за ордер
        {
         OrderSelect(order, SELECT_BY_POS);
         int mode=OrderType();
         if(OrderMagicNumber() == 6767 && OrderSymbol() == _Symbol) // сделка заключена роботом
           {
            // если сделка на бай то тейкпрофит подымаеться
            if(mode == OP_BUY)  //если сделка BUY
              {
               if(iClose(NULL,PERIOD_M15,1)>iClose(NULL,PERIOD_M15,2))
                 {
                  newStopLoss = OrderStopLoss() + (iClose(NULL,PERIOD_M5,2)-iClose(NULL,PERIOD_M15,1))*0.66;
                  newStopLoss = NormalizeDouble(newStopLoss, Digits);
                  result = OrderModify(OrderTicket(),OrderOpenPrice(), newStopLoss, OrderTakeProfit(),0, Blue);
                  Alert("result modify ", result);
                 }
              }
            // конец условию сделка по баю

            // если сделка на селл то тейкпрофит опускаеться
            if(mode == OP_SELL)  //если сделка SELL
              {
               if(iClose(NULL,PERIOD_M15,2)>iClose(NULL,PERIOD_M15,1))   /*(Close[2] > Close[1])*/
                 {
                  newStopLoss = OrderStopLoss() - (iClose(NULL,PERIOD_M15,2) - iClose(NULL,PERIOD_M15,1))*0.66;
                  newStopLoss = NormalizeDouble(newStopLoss, Digits);
                  result = OrderModify(OrderTicket(),OrderOpenPrice(), newStopLoss, OrderTakeProfit(),0, Blue);
                  Alert("result modify ", result);
                 }
              }
            //
           }
        }
     }
  }
//+------------------------------------------------------------------+
void  needCloseOrder()
{
   bool result;
   if (OrdersTotal() != 0 && IsNewCandle() == true)
   {
      for (int order =0; order <= OrdersTotal(); order++)
      {
         OrderSelect(order, SELECT_BY_POS);
         int mode=OrderType();
         if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol)
         {
            if (mode == OP_BUY &&  Open[1]>iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_UPPER,0) && Close[1]<iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_UPPER,0))
            {
               OrderClose(OrderTicket(),OrderLots(),Bid, 5, Red);
            }
            
            if (mode == OP_SELL &&  Open[1]<iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_LOWER,0) && Close[1]>iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_LOWER,0))
            {
               OrderClose(OrderTicket(),OrderLots(),Ask, 5, Red);
            }
         }
         
         
      }
   }
}