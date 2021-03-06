//+------------------------------------------------------------------+
//|                                                      slepcov.mq4 |
//|                                                          liapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "liapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
extern double  StopLoss  =400;         // SL для открываемого ордера
extern double  TakeProfit =2000;       // TP для открываемого ордера
extern int     Period_MA_1=10;         //Период МА 1
extern int     Period_MA_2=30;         //Период МА 2
extern double  Rasst       =28;        //Расстояние между МА
extern double  Lots        =0.1;       //Жестко заданное колич. лотов
extern double  Prots       =0.07;      //Процент свободных средств

bool Work=true;                        //эксперт будет работать
string Symb;                           //Название финанс. инструмента
//---2
int start()
  {
   int
   Total,                              //Количество ордеров в окне
   Tip=-1,                             //Тип выбран. ордера (B=0,S=1)
   Ticket;                              // Номер ордера
   double
   MA_1_t,                             // Значен МА_1 текущее
   MA_2_t,                             // Значен МА_2 текущее
   Lot,                                // Колич. лотов в выбран.ордере
   Lts,                                // Колич. лотов в открыв.ордере
   Min_Lot,                            // Минимальное количество лотов
   Step,                               // Шаг изменения размера лота
   Free,                               // Текущие свободные средства
   One_Lot,                            // Стоимость одного лота
   Price,                              // Цена выбранного ордера
   SL,                                 // SL выбранного ордера
   TP;                                 // TP выбранного ордера
   bool
   Ans   =false,                       // Ответ сервера после закрыти
   Cls_B=false,                        // Критерий для закрытия Бай
   Cls_S=false,                        // Критерий для закрытия Сел
   Opn_B=false,                        // Критерий для открытия Бай
   Opn_S=false;                        // Критерий для открытия Сел
//------------------------------------------------------------------------- 3 ----
// Предварит.обработка
   if(Bars < Period_MA_2)              // Недостаточно баров
     {
      Alert("Недостаточно баров в окне. Эксперт не работает.");
      return(0);                          // Выход из start()
     }
   if(Work==false)
     {
      Alert("Критическая ошибка. Эксперт не работает.");
      return(0);                          // Выход из start()
     }
//-------------------------------------------------------------------- 4 ---
// Учет ордеров
   Symb=Symbol();                      // Название фин.инстр.
   Total=0;                            // Количество ордеров
   for(int i=1; i<=OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i-1,SELECT_BY_POS)==true)   // Если есть следущий
     {
      if(OrderSymbol()!=Symb)continue;    // Не наш фин. инструм
         if(OrderType()>1)                   // Попался отложеный
           {
            Alert("Обнаружен отложеныый ордер. Эксперт не работает.");
            return(0);
           }
         Total++;                            // Счетчик рыноч.орд
         if(Total>1)                         // Не более одного орд
           {
            Alert("Несколько рычночных ордеров. Эксперт не работает.");
            return(0);
           }
         Ticket=OrderTicket();                // Номер выбранн.орд.
         Tip=OrderType();                      // Тип выбранн.орд.
         Price=OrderOpenPrice();             // Цена выбранн.орд.
         SL=OrderStopLoss();                 // SL выбранн.орд.
         TP=OrderTakeProfit();               // TP выбранн.орд.
         Lot=OrderLots();                    // Количество лотов
        }
     }
//---------------------------------------------------------------------------- 5 -----
//Торговые критерии
   MA_1_t=iMA(NULL,0,Period_MA_1,0,MODE_SMA,PRICE_CLOSE,0);//MA_1
   MA_2_t=iMA(NULL,0,Period_MA_2,0,MODE_SMA,PRICE_CLOSE,0);//MA_2

   if(MA_1_t > MA_2_t + Rasst*Point)              // Если разница между МА1 и МА2 большая
     {
      Opn_B=true;                                 // Критерий откр. Бай
      Cls_S=true;                                 // Критерий закр. Селл
     }
   if(MA_1_t < MA_2_t - Rasst*Point)               // Если разница между МА1 и МА2 большая
     {
      Opn_S=true;                                 // Критерий откр. Сел
      Cls_B=true;                                 // Критерий закр. Бай
     }
//+------------------------------------------------------------------ 6 ----
// Закрытие ордеров
   while(true)                                     // цикл закрытия орд.
     {
      if(Tip==0 && Cls_B==true)                   // Открыт ордер Бай и есть критерий закр
        {
         Alert("Попытка закрыть Buy ", Ticket,". Ожидание ответа..");
         RefreshRates();
         Ans=OrderClose(Ticket,Lot,Bid,2);        // Закрытие Бай
         if(Ans==true)
           {
            Alert("Закрыт ордер Buy ", Ticket);
            break;                                // Выход из цикла закр
           }
         if(Fun_Error(GetLastError())==1)         // Обработка ошибок
            continue;                              // Повторная попытка
         return(0);
        }
      if(Tip==1 && Cls_S==true)                   // Открыт ордер Сел и есть критерий на закр
        {
         Alert("Попытка закрыть Sell ",Ticket,". Ожидание ответа..");
         RefreshRates();
         Ans=OrderClose(Ticket,Lot,Ask,2);         // Закрытие Сел
         if(Ans==true)
           {
            Alert("Закрыт ордер Sell ",Ticket);
            break;
           }
         if(Fun_Error(GetLastError())==1)         // Обработка ошибок
            continue;
         return(0);
        }
      break;
     }
//+------------------------------------------------------------------ 7 ---+
// Стоимость ордеров
   RefreshRates();
   Min_Lot=MarketInfo(Symb,MODE_MINLOT);           // Миним. колич. лотов
   Free=AccountFreeMargin();                       // Свободн средства
   One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);   // Стоимость 1 лота
   Step=MarketInfo(Symb,MODE_LOTSTEP);             // Шаг изменен размера

   if(Lots > 0)                                    // Если заданы лоты
      Lts=Lots;
   else                                            // % свободных средст
      Lts=MathFloor(Free*Prots/One_Lot/Step)*Step; // Для открытия

   if(Lts < Min_Lot)
      Lts=Min_Lot;                  // Не меньше минимальн
   if(Lts*One_Lot > Free)                          // Лот дороже свободн.
     {
      Alert("Не хватает денег на ", Lts, " лотов");
      return(0);
     }
//+--------------------------------------------------------------- 8 ---+
// Открытие ордеров
   while(true)                                     // Цикл закрытия орд.
     {
      if(Total==0 && Opn_B==true)                  // Открытых орд. нет + критерий откр. Бай
        {
         RefreshRates();
         SL=Bid-New_Stop(StopLoss)*Point;          // Вычисление SL откр.
         TP=Bid+New_Stop(TakeProfit)*Point;         // Вычисление TP откр.
            Alert("Попытка открыть Buy. Ожидание ответа..");
         Ticket=OrderSend(Symb,OP_BUY,Lts,Ask,2,SL,TP);// Открытие Buy
         if(Ticket > 0)
           {
            Alert("Открыт ордер Buy ",Ticket);
            return(0);
           }
         if(Fun_Error(GetLastError()==1))           // Обработка ошибок
            continue;
            return(0);
        }
   if(Total==0 && Opn_S==true)                   // Открытых орд. нет + критерий откр. Сел
        {
         RefreshRates();
         SL=Ask+New_Stop(StopLoss)*Point;          // Вычисление SL откр.
         TP=Ask-New_Stop(TakeProfit)*Point;        // ВЫчисление TP откр.
         Alert("Попытка открыть Sell. Ожидание ответа..");
         Ticket=OrderSend(Symb,OP_SELL,Lts,Bid,2,SL,TP);// Открытие Сел
         if(Ticket > 0)
           {
            Alert("Открыт ордер Sell ",Ticket);
            return(0);
           }
         if(Fun_Error(GetLastError())==1)
            continue;
         return(0);
        }
      break;
     }
//+-------------------------------------------------------------- 9 ----+
   return(0);
  }
//+--------------------------------------------------------------- 10 ---+
int Fun_Error(int Error)                        // Ф-ция обработ ошибок
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
      default:
         Alert("Возникла ошибка ",Error);
         return(0);
     }
  }
//+--------------------------------------------------------------- 11 ---+
int New_Stop(int Parametr)                            //проверка стоп-приказ
  {
   int Min_Dist=MarketInfo(Symb,MODE_STOPLEVEL);      // Миним. дист
   if(Parametr<Min_Dist)
     {
      Parametr=Min_Dist;
      Alert("Увеличена дистанция стоп-приказа.");
     }
   return(Parametr);
  }
//+--------------------------------------------------------------- 12 ---+
