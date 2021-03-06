//+------------------------------------------------------------------+
//|                                                       gamExp.mq4 |
//|                                                          liapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int Magic=2323;                                               // магическое число
extern double TP=0;                                                  // тейкпрофит
extern int Rasst=25;                                                 // расст. между средними
extern double Lots=0.02;                                             // размер лота
extern double Prots=0.07;                                            // Процент свободных средств
extern int Percent=80;                                               // Процент закрытия открытой сделки

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double middle10=iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,0);
double middle20=iMA(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,0);
double SL=NormalizeDouble((middle20+middle10)/2.0,Digits);           // Стоплос
string Symb=Symbol();                                                // финансовый инструмент
int Total=0, Ticket, Type;
bool Opn_B=false,Opn_S=false,Cls_B=false,Cls_S=false;
bool Work=true,Part_C;
double Price, price_b, price_s;
double  Min_Lot=MarketInfo(Symb,MODE_MINLOT);                        // Миним. колич. лотов
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
// Предварит.обработка
   if(Bars < 20)                                                      // Недостаточно баров
     {
      Alert("Недостаточно баров в окне. Эксперт не работает.");
      return;                                                         // Выход из start()
     }
   if(Work==false)
     {
      Alert("Критическая ошибка. Эксперт не работает.");
      return;                                                         // Выход из start()
     }
//Торговые критерии
   if(middle10 > middle20 + Rasst*Point)                              // Если разница между МА1 и МА2 большая
     {
      Opn_B=true;                                                     // Критерий откр. Бай
      Opn_S=false;                                                     // Критерий закр. Селл
     }
   if(middle10 < middle20 - Rasst*Point)                              // Если разница между МА1 и МА2 большая
     {
      Opn_S=true;                                                     // Критерий откр. Сел
      Opn_B=false;                                                     // Критерий закр. Бай
     }
   /* алгоритм торговли
   - если при Opn_B, middle20<Close[1]<middle10, то OP_BUYSTOP по цене middle10+15*Point, SL=(middle20+middle10)/2.0
   - если при Opn_S, middle20>Close[1]>middle10, то OP_SELLSTOP по цене middle10-15*Point, SL=(middle20+middle10)/2.0
   проверка отложеных ордеров:
   - if Cls_B=true, удалить OP_BUYSTOP
   - if Cls_S=true, удалить OP_SELLSTOP
   проверка работающие ордера
   -(OP_BUY) if BB1<=Bid закрыть ордер на 80 процентов, проверка предыдущего условия и if Bid==middle10 закрыть весь ордер
   -(OP_SELL) if LL>=Ask закрыть ордер на 80 процентов, проверка предыдущего условия и if Ask==middle10 закрыть весь ордер
   */
//---установка отложеных ордеров
   if(TotalOpenOrders()==0 && Opn_B==true && IsNewCandle()==true && Close[1]<middle10 && Close[1]>middle20)
      Open_Buy();
   if(TotalOpenOrders()==0 && Opn_S==true && IsNewCandle()==true && Close[1]>middle10 && Close[1]<middle20)
      Open_Sell();
//-- проверка сработавших ордеров
   if(TotalOpenOrders()>0 && Part_C==false)
      PartCloseOrder();
//-- удаление отложеных ордеров
   if(middle10 < middle20)
     {
      for(int i=0; OrdersTotal()>i; i++)                          // Цикл перебора ордер
        {
         if(OrderSelect(i,SELECT_BY_POS))
           {
            if(OrderSymbol()!= Symb && OrderMagicNumber()!=Magic)
               continue;    // Не наш фин.инструм.
            else
               Ticket=OrderTicket();
            if(OrderType()==OP_BUYSTOP)
              {
               if(OrderDelete(Ticket))
                 {
                  Alert("Удален ордер", Ticket);
                 }
               else
                  Fun_Error(GetLastError());
              }
            else
               return;
           }
         else
            Alert("Ошибка выбора ордера при удалении,");
        }
     }
//+------------------------------------------------------------------+
   if(middle10 > middle20)
     {
      for(int i=0; OrdersTotal()>i; i++)                          // Цикл перебора ордер
        {
         if(OrderSelect(i,SELECT_BY_POS))
           {
            if(OrderSymbol()!= Symb && OrderMagicNumber()!=Magic)
               continue;    // Не наш фин.инструм.
            else
               Ticket=OrderTicket();
            if(OrderType()==OP_SELLSTOP)
              {
               if(OrderDelete(Ticket))
                 {
                  Alert("Удален ордер", Ticket);
                 }
               else
                  Fun_Error(GetLastError());
              }
            else
               return;
           }
         else
            Alert("Ошибка выбора ордера при удалении,");
        }
     }
//--- Сопровождение ордера до полного закрытия при пересечение первых линий Гамбита
   if(TotalOpenOrders()>0)
     {
      double BB2=NormalizeDouble(iCustom(NULL,0,"Gambit",1,0),Digits);// первая верхняя линия Гамбит
      double LL1=NormalizeDouble(iCustom(NULL,0,"Gambit",3,0),Digits);// первая нижняя линия Гамбит
      for(int i=0; i<OrdersTotal(); i++)                            // Цикл перебора ордер
        {
         if(OrderSelect(i,SELECT_BY_POS))
           {
            if(OrderSymbol()!=Symb && OrderMagicNumber()!=Magic)
               continue;
            Type=OrderType();
            Ticket=OrderTicket();
            Lots=OrderLots();
            RefreshRates();
            if(Type==OP_BUY && Close[1]>BB2 && Bid<BB2)
              {
               if(OrderClose(Ticket,Lots,Bid,2))
                  return;
               else
                  Fun_Error(GetLastError());
              }
            if(Type==OP_SELL && Close[1]<LL1 && Ask>LL1)
              {
               if(OrderClose(Ticket,Lots,Ask,2))
                  return;
               else
                  Fun_Error(GetLastError());
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|  отложеный ордер на покупку                                                                |
//+------------------------------------------------------------------+
void Open_Buy()
  {
   RefreshRates();
   price_b=NormalizeDouble(middle10+10*Point,Digits);
   Ticket=OrderSend(Symb,OP_BUYSTOP,LotF(),price_b,2,SL,TP,"InGodWeTrust",Magic);
   if(Ticket > 0)
     {
      Alert("Открыт ордер Buy ",Ticket);
      return;
     }
   else
      Fun_Error(GetLastError());           // Обработка ошибок
  }

//+------------------------------------------------------------------+
//|    Отложеный ордер на продажу                                    |                         |
//+------------------------------------------------------------------+
void Open_Sell()
  {
   RefreshRates();
   price_s=NormalizeDouble(middle10-10*Point,Digits);
   Ticket=OrderSend(Symb,OP_SELLSTOP,LotF(),price_s,2,SL,TP,"InGodWeTrust",Magic);
   if(Ticket > 0)
     {
      Alert("Открыт ордер Buy ",Ticket);
      return;
     }
   else
      Fun_Error(GetLastError());           // Обработка ошибок
  }

//+------------------------------------------------------------------+
//| Проверка свечи                                                                 |
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
//|   проверка ордеров                                                               |
//+------------------------------------------------------------------+
int TotalOpenOrders()
  {
   int total_orders = 0;

   for(int order = 0; order < OrdersTotal(); order++)
     {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false)
         break;

      if(OrderMagicNumber() == Magic && OrderSymbol() == _Symbol)
        {
         total_orders++;
        }
     }

   return(total_orders);
  }

//+------------------------------------------------------------------+
//|расчитать лот для начального ордера                               |
//+------------------------------------------------------------------+
double LotF()
  {
   RefreshRates();
   double
   Free=AccountFreeMargin(),                                          // Свободн средства
   One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED),                      // Стоимость 1 лота
   Step=MarketInfo(Symb,MODE_LOTSTEP),                                // Шаг изменен размера
   Lts;

   if(Lots > 0)                                                       // Если заданы лоты
     {
      if(Opn_B == true && iMA(NULL,60,10,0,MODE_SMA,PRICE_CLOSE,0) > iMA(NULL,60,10,0,MODE_SMA,PRICE_CLOSE,0))
         Lts=Lots*2;
      else
         Lts=Lots;
      if(Opn_S == true && iMA(NULL,60,10,0,MODE_SMA,PRICE_CLOSE,0) < iMA(NULL,60,10,0,MODE_SMA,PRICE_CLOSE,0))
         Lts=Lots*2;
      else
         Lts=Lots;
     }
   else                                                              // % свободных средст
      Lts=MathFloor(Free*Prots/One_Lot/Step)*Step;                   // Для открытия

   if(Lts < Min_Lot)
      Lts=Min_Lot;                                                   // Не меньше минимальн
   if(Lts*One_Lot > Free)                                            // Лот дороже свободн.
     {
      Alert("Не хватает денег на ", Lts, " лотов");
      return(0);
     }
   return(Lts);
  }
//+------------------------------------------------------------------+
//|       Ч А С Т И Ч Н О Е  З А К Р Ы Т И Е  О Р Д Е Р А            |
//+------------------------------------------------------------------+
void PartCloseOrder()
  {
   RefreshRates();

   double BB1=NormalizeDouble(iCustom(NULL,0,"Gambit",2,0),Digits); // верхняя линия боллинджера для установки тп по баю
   double LL=NormalizeDouble(iCustom(NULL,0,"Gambit",4,0),Digits);  // нижняя линия боллинджера для установки тп по селу
   bool error=true;
   int OT;
   double OOP;
   string txt;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber()==Magic)
           {
            OT = OrderType();
            Ticket = OrderTicket();
            OOP = OrderOpenPrice();
            if(OT==OP_BUY && Bid>=BB1)
              {
               error=OrderClose(Ticket,LotClose(),NormalizeDouble(Bid,Digits),2,Red);
               Part_C=true;
               if(error)
                  txt = StringConcatenate(txt,"\nЗакрыт ордер BUY ",Ticket);
               else
                  txt = StringConcatenate(txt,"\nОшибка закрытия ",GetLastError()," ордера",Ticket);
              }
            if(OT==OP_SELL && Ask<=LL)
              {
               error=OrderClose(Ticket,LotClose(),NormalizeDouble(Ask,Digits),2,Blue);
               Part_C=true;
               if(error)
                  txt = StringConcatenate(txt,"\nЗакрыт ордер SELL ",Ticket);
               else
                  txt = StringConcatenate(txt,"\nОшибка закрытия ",GetLastError()," ордера ",Ticket);
              }
           }
        }
     }
   Comment(txt,"\nСкрипт закончил работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return;
  }
//+------------------------------------------------------------------+
//|                Л О Т  Д Л Я  З А К Р Ы Т И Я                     |
//+------------------------------------------------------------------+
double LotClose()
  {
   double LtClose;
   LtClose = NormalizeDouble(OrderLots()*Percent/100,2);
   if(LtClose<Min_Lot)
      LtClose = Min_Lot;
   return(LtClose);
  }

//+------------------------------------------------------------------+
//|                     О Б Р А Б О Т К А  О Ш И Б О К               |
//+------------------------------------------------------------------+
int Fun_Error(int Error)                                             // Ф-ция обработ ошибок
  {
   switch(Error)
     {
      case  4:
         Alert("Торговый сервер занят. Пробуем ещё раз..");
         Sleep(30000);
         return(1);
      case 135:
         Alert("Цена изменилась. Пробуем ещё раз..");
         RefreshRates();
         return(1);
      case 136:
         Alert("Нет цен. Ждем новый тик..");
         while(RefreshRates()==false)
            Sleep(1);
         return(1);
      case 137:
         Alert("Брокер занят. Пробуем еще раз..");
         Sleep(30000);
         return(1);
      case 146:
         Alert("Подсистема торговли занята. Пробуем еще..");
         Sleep(500);
         return(1);
      // Критические ошибки
      case 2:
         Alert("Общая ошибка.");
         return(0);
      case 5:
         Alert("Старая версия терминала.");
         Work=false;
         return(0);
      case 64:
         Alert("Счет заблокирован.");
         Work=false;
         return(0);
      case 133:
         Alert("Торговля запрещена");
         return(0);
      case 134:
         Alert("Недостаточно денег для совершения операции.");
         return(0);
      case 4107:
         Alert(price_b,price_s,SL);
         return(0);
      default:
         Alert("Возникла ошибка ",Error);
         return(0);
     }
  }
//+------------------------------------------------------------------+
