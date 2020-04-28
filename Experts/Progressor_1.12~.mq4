#property copyright "Copyright © 2012,  ForexHit.net"
#property link      "info@forexhit.net"
string g_comment_76 = "Progressor 1.12";
double gd_unused_84 = 3535998.0;
int g_magic_92 = 345345;
int KEY = 3642959;
extern string S_1 = "Начальный фиксированный лот";
extern double First_lot = 0.02;
extern string S_2 = "Сколько центов закрыть";
extern double TP_in_money = 2.0;
extern double TP_koef = 0.8;
extern string S_3 = "Умножение дополнительных сделок";
extern bool Martin_mode = TRUE;
extern double Multiplier = 1.5;
extern double Increament = 0.1;
extern int Lot_multi_2_level = 13;
extern double Lot_Multiplier_2 = 1.5;
extern string S_4 = "Дистанция между уровнями/Всего уровней";
extern double Distance = 35.0;
extern int Level = 12;
extern string S_5 = "Хеджинг";
extern bool Hedge = TRUE;
extern int Hedge_start = 3;
extern double H_lot_factor = 0.5;
extern double H_tp_factor = 1.0;
extern double Max_SPREAAD = 30.0;
extern string S_6 = "Режим НЕВИДИМКА";
extern bool Invisible_mode = TRUE;
extern string S_7 = "Не ждать закрытия свечей";
extern bool EachTickMode = TRUE;
extern string S_8 = "Использовать фиксированные TP/SL";
extern bool Use_SL_TP = FALSE;
extern string S_9 = "Уровень прибыли(тейк профита)в пунктах";
extern double TakeProfit = 30.0;
extern string S_10 = "Уровень стоп-лосс в пунктах";
extern double StopLose = 60.0;
extern string S_11 = "Торговать в пятницу";
extern bool Trade_in_fri = TRUE;
extern string S_12 = "Working Time";
extern bool Working_Time = FALSE;
extern int OpenHour = 0;
extern int CloseHour = 24;
int gi_340 = 0;
int g_count_344 = 0;
int g_ticket_348 = 0;
int gi_unused_352 = 0;
int gi_unused_356;
int gi_unused_360;
int g_period_364 = 12;
int g_period_368 = 26;
int g_period_372 = 9;
double gd_376;
double g_minlot_392;
double g_maxlot_400;
double g_stoplevel_408;
double gd_416;
double gd_432;
double gd_440;
double gd_448;
double gd_456;
double gd_464;
double gd_472;
double g_imacd_480;
double g_imacd_488;
double g_imacd_496;
double g_imacd_504;
double g_imacd_512;
bool gi_520;
bool gi_unused_524 = FALSE;
string gs_null_528 = "NULL";
double gd_536;

int init() {
   gi_unused_356 = Bars;
   if (EachTickMode) gi_unused_360 = 0;
   else gi_unused_360 = 1;
   if (Digits == 3 || Digits == 5) gd_376 = 10.0 * Point;
   else gd_376 = Point;
   g_minlot_392 = MarketInfo(Symbol(), MODE_MINLOT);
   g_maxlot_400 = MarketInfo(Symbol(), MODE_MAXLOT);
   g_stoplevel_408 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (First_lot < g_minlot_392) Print("lotsize is to small.");
   if (StopLose < g_stoplevel_408) Print("stoploss is to tight.");
   if (TakeProfit < g_stoplevel_408) Print("takeprofit is to tight.");
   if (g_minlot_392 == 0.01) gi_340 = 2;
   if (g_minlot_392 == 0.1) gi_340 = 1;
   gd_416 = First_lot;
   if (Hedge == FALSE) Hedge_start = 0;
   gd_432 = H_lot_factor;
   gd_440 = H_tp_factor * Distance * gd_376;
   gd_448 = Multiplier;
   gd_456 = Lot_Multiplier_2;
   gd_464 = Lot_multi_2_level;
   gd_472 = AccountEquity();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_28;
   int datetime_36;
   int datetime_40;
   int cmd_68;
   double order_open_price_72;
   double order_lots_80;
   double ld_96;
   double ld_104;
   double ld_112;
   double ld_136;
   double order_stoploss_144;
   double order_takeprofit_152;
   double spread_0 = MarketInfo(Symbol(), MODE_SPREAD);
   if (!Trade_in_fri && DayOfWeek() == 5 && f0_4() == 0) {
      Comment("\nstop trading in Friday.");
      return (0);
   }
   int acc_number_8 = AccountNumber();
   int li_12 = KEY;
   if (EachTickMode) {
      g_imacd_480 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_OPEN, MODE_MAIN, 0);
      g_imacd_488 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_MAIN, 1);
      g_imacd_496 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_SIGNAL, 1);
      g_imacd_504 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_MAIN, 2);
      g_imacd_512 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_SIGNAL, 2);
   } else {
      g_imacd_480 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_OPEN, MODE_MAIN, 1);
      g_imacd_488 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_MAIN, 2);
      g_imacd_496 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_SIGNAL, 2);
      g_imacd_504 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_MAIN, 3);
      g_imacd_512 = iMACD(NULL, 0, g_period_364, g_period_368, g_period_372, PRICE_CLOSE, MODE_SIGNAL, 3);
   }
   if (MACD_Signal(acc_number_8, li_12, g_imacd_480, g_imacd_488, g_imacd_496, g_imacd_504, g_imacd_512) == 3) {
      Print("Expert key is not activate");
      Comment(" Expert key is not activate");
      return (0);
   }
   int count_16 = 0;
   int count_20 = 0;
   int count_24 = 0;
   int li_32 = 0;
   bool li_44 = FALSE;
   bool li_48 = FALSE;
   string ls_52 = "0";
   for (int pos_60 = 0; pos_60 <= OrdersTotal(); pos_60++) {
      OrderSelect(pos_60, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_92 && OrderType() < OP_BUYLIMIT) {
         count_16++;
         datetime_36 = OrderOpenTime();
         if (OrderType() == OP_BUY) count_20++;
         if (OrderType() == OP_SELL) count_24++;
         if (count_16 == 1 || datetime_36 < datetime_40) {
            datetime_40 = datetime_36;
            ls_52 = "B";
            if (OrderType() == OP_SELL) ls_52 = "S";
         }
      }
   }
   if (ls_52 == "B") {
      li_32 = count_20;
      li_28 = count_24;
      gs_null_528 = "BUY";
      if (Hedge == TRUE && count_20 >= Hedge_start - 1) li_44 = TRUE;
   }
   if (ls_52 == "S") {
      li_32 = count_24;
      li_28 = count_20;
      gs_null_528 = "SELL";
      if (Hedge == TRUE && count_24 >= Hedge_start - 1) li_48 = TRUE;
   }
   Multiplier = gd_448;
   if (gd_456 > 0.0 && li_32 >= gd_464 - 1.0) Multiplier = gd_456;
   if (count_16 == 0) gi_520 = FALSE;
   if (f0_3() && spread_0 <= Max_SPREAAD && li_32 == 0 && g_count_344 == 0 && li_28 == 0) {
      if (f0_3() && MACD_Signal(acc_number_8, li_12, g_imacd_480, g_imacd_488, g_imacd_496, g_imacd_504, g_imacd_512) == 1 && gi_520 == FALSE) {
         if (Invisible_mode) {
            if (Use_SL_TP) {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416, Ask, 3, Ask - StopLose * gd_376, Ask + TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Blue);
            } else {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416, Ask, 3, 0, 0, g_comment_76, g_magic_92, 0, Blue);
            }
         } else {
            if (Use_SL_TP) {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, First_lot) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               if (OrderSend(Symbol(), OP_BUY, First_lot, Ask, 3, Ask - StopLose * gd_376, Ask + TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Blue) > 0) {
                  for (int li_64 = 1; li_64 < Level; li_64++) {
                     if (Martin_mode) {
                        gd_416 = NormalizeDouble(First_lot * MathPow(Multiplier, li_64), gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_BUYLIMIT, gd_416, Ask - Distance * li_64 * gd_376, 3, Ask - Distance * li_64 * gd_376 - StopLose * gd_376, Ask - Distance * li_64 * gd_376 +
                           TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Blue);
                     } else {
                        gd_416 = NormalizeDouble(First_lot + Increament * li_64, gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_BUYLIMIT, gd_416, Ask - Distance * li_64 * gd_376, 3, Ask - Distance * li_64 * gd_376 - StopLose * gd_376, Ask - Distance * li_64 * gd_376 +
                           TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Blue);
                     }
                  }
               }
            } else {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, First_lot) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               if (OrderSend(Symbol(), OP_BUY, First_lot, Ask, 3, 0, 0, g_comment_76, g_magic_92, 0, Blue) > 0) {
                  for (li_64 = 1; li_64 < Level; li_64++) {
                     if (Martin_mode) {
                        gd_416 = NormalizeDouble(First_lot * MathPow(Multiplier, li_64), gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_BUYLIMIT, gd_416, Ask - Distance * li_64 * gd_376, 3, 0, 0, g_comment_76, g_magic_92, 0, Blue);
                     } else {
                        gd_416 = NormalizeDouble(First_lot + Increament * li_64, gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_BUYLIMIT, gd_416, Ask - Distance * li_64 * gd_376, 3, 0, 0, g_comment_76, g_magic_92, 0, Blue);
                     }
                  }
               }
            }
         }
         if (li_44 == TRUE) {
            if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416 * gd_432) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
               Print("No money for opening order");
               return;
            }
            g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416 * gd_432, Bid, 3, 0, Bid - gd_440, g_comment_76 + " h", g_magic_92, 0, Red);
         }
      }
      if (f0_3() && spread_0 <= Max_SPREAAD && MACD_Signal(acc_number_8, li_12, g_imacd_480, g_imacd_488, g_imacd_496, g_imacd_504, g_imacd_512) == 2 && gi_520 == FALSE) {
         if (Invisible_mode) {
            if (Use_SL_TP) {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416, Bid, 3, Bid + StopLose * gd_376, Bid - TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Red);
            } else {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416, Bid, 3, 0, 0, g_comment_76, g_magic_92, 0, Red);
            }
         } else {
            if (Use_SL_TP) {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, First_lot) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               if (OrderSend(Symbol(), OP_SELL, First_lot, Bid, 3, Bid + StopLose * gd_376, Bid - TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Red) > 0) {
                  for (li_64 = 1; li_64 < Level; li_64++) {
                     if (Martin_mode) {
                        gd_416 = NormalizeDouble(First_lot * MathPow(Multiplier, li_64), gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_SELLLIMIT, gd_416, Bid + Distance * li_64 * gd_376, 3, Bid + Distance * li_64 * gd_376 + StopLose * gd_376, Bid + Distance * li_64 * gd_376 - TakeProfit * gd_376,
                           g_comment_76, g_magic_92, 0, Red);
                     } else {
                        gd_416 = NormalizeDouble(First_lot + Increament * li_64, gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_SELLLIMIT, gd_416, Bid + Distance * li_64 * gd_376, 3, Bid + Distance * li_64 * gd_376 + StopLose * gd_376, Bid + Distance * li_64 * gd_376 - TakeProfit * gd_376,
                           g_comment_76, g_magic_92, 0, Red);
                     }
                  }
               }
            } else {
               gd_416 = First_lot;
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, First_lot) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               if (OrderSend(Symbol(), OP_SELL, First_lot, Bid, 3, 0, 0, g_comment_76, g_magic_92, 0, Red) > 0) {
                  for (li_64 = 1; li_64 < Level; li_64++) {
                     if (Martin_mode) {
                        gd_416 = NormalizeDouble(First_lot * MathPow(Multiplier, li_64), gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_SELLLIMIT, gd_416, Bid + Distance * li_64 * gd_376, 3, 0, 0, g_comment_76, g_magic_92, 0, Red);
                     } else {
                        gd_416 = NormalizeDouble(First_lot + Increament * li_64, gi_340);
                        if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                           Print("No money for opening order");
                           return;
                        }
                        g_ticket_348 = OrderSend(Symbol(), OP_SELLLIMIT, gd_416, Bid + Distance * li_64 * gd_376, 3, 0, 0, g_comment_76, g_magic_92, 0, Red);
                     }
                  }
               }
            }
         }
         if (li_48 == TRUE) {
            if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416 * gd_432) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
               Print("No money for opening order");
               return;
            }
            g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416 * gd_432, Ask, 3, 0, Ask + gd_440, g_comment_76 + " h", g_magic_92, 0, Blue);
         }
      }
   }
   if (f0_3() && spread_0 <= Max_SPREAAD && Invisible_mode && li_32 > 0 && li_32 < Level && li_28 == 0) {
      for (li_64 = 0; li_64 < OrdersTotal(); li_64++) {
         OrderSelect(li_64, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92) continue;
         cmd_68 = OrderType();
         order_open_price_72 = OrderOpenPrice();
         order_lots_80 = OrderLots();
      }
      if (cmd_68 == OP_BUY && Ask <= order_open_price_72 - Distance * gd_376 && gi_520 == FALSE) {
         if (Use_SL_TP) {
            if (Martin_mode) {
               gd_416 = NormalizeDouble(order_lots_80 * Multiplier, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416, Ask, 3, Ask - StopLose * gd_376, Ask + TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Blue);
            } else {
               gd_416 = NormalizeDouble(order_lots_80 + Increament, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416, Ask, 3, Ask - StopLose * gd_376, Ask + TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Blue);
            }
         } else {
            if (Martin_mode) {
               gd_416 = NormalizeDouble(order_lots_80 * Multiplier, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416, Ask, 3, 0, 0, g_comment_76, g_magic_92, 0, Blue);
            } else {
               gd_416 = NormalizeDouble(order_lots_80 + Increament, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416, Ask, 3, 0, 0, g_comment_76, g_magic_92, 0, Blue);
            }
         }
         if (li_44 == TRUE) {
            if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416 * gd_432) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
               Print("No money for opening order");
               return;
            }
            g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416 * gd_432, Bid, 3, 0, Bid - gd_440, g_comment_76 + " h", g_magic_92, 0, Red);
         }
      }
      if (cmd_68 == OP_SELL && Bid >= order_open_price_72 + Distance * gd_376 && gi_520 == FALSE) {
         if (Use_SL_TP) {
            if (Martin_mode) {
               gd_416 = NormalizeDouble(order_lots_80 * Multiplier, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416, Bid, 3, Bid + StopLose * gd_376, Bid - TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Red);
            } else {
               gd_416 = NormalizeDouble(order_lots_80 + Increament, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416, Bid, 3, Bid + StopLose * gd_376, Bid - TakeProfit * gd_376, g_comment_76, g_magic_92, 0, Red);
            }
         } else {
            if (Martin_mode) {
               gd_416 = NormalizeDouble(order_lots_80 * Multiplier, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416, Bid, 3, 0, 0, g_comment_76, g_magic_92, 0, Red);
            } else {
               gd_416 = NormalizeDouble(order_lots_80 + Increament, gi_340);
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, gd_416) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
                  Print("No money for opening order");
                  return;
               }
               g_ticket_348 = OrderSend(Symbol(), OP_SELL, gd_416, Bid, 3, 0, 0, g_comment_76, g_magic_92, 0, Red);
            }
         }
         if (li_48 == TRUE) {
            if (AccountFreeMarginCheck(Symbol(), OP_BUY, gd_416 * gd_432) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
               Print("No money for opening order");
               return;
            }
            g_ticket_348 = OrderSend(Symbol(), OP_BUY, gd_416 * gd_432, Ask, 3, 0, Ask + gd_440, g_comment_76 + " h", g_magic_92, 0, Blue);
         }
      }
   }
   double ld_88 = 0;
   pos_60 = 0;
   for (pos_60 = 0; pos_60 <= OrdersTotal(); pos_60++) {
      OrderSelect(pos_60, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_92 && OrderType() < OP_BUYLIMIT) {
         if ((ls_52 == "B" && OrderType() == OP_SELL) || (ls_52 == "S" && OrderType() == OP_BUY)) ld_96 += OrderLots();
         ld_104 += OrderLots();
         ld_88 = ld_104 - ld_96;
         ld_112 = ld_88 - ld_96;
      }
   }
   gd_536 = TP_in_money;
   if (li_32 > 1 && gd_536 > 0.0 && TP_in_money > 0.0) for (li_64 = li_32 - 1; li_64 > 0; li_64--) gd_536 *= TP_koef;
   else gd_536 = TP_in_money;
   double ld_120 = AccountEquity();
   double ld_128 = ld_120 - gd_472;
   if (ld_128 > ld_136) ld_136 = ld_128;
   Comment("Copyright © 2012, ForexHit.net ", MACD_Signal(acc_number_8, li_12, g_imacd_480, g_imacd_488, g_imacd_496, g_imacd_504, g_imacd_512), 
      "\n Сигнал = ", gs_null_528, " \\ Уровней = ", li_32, 
      "\n Xеджинг после уровня = ", Hedge_start, " \\ Объем сделок по системе = ", DoubleToStr(ld_88, 2), " \\ Объем сделок хеджинг = ", DoubleToStr(ld_96, 2), 
      "\n Netto сделок = ", DoubleToStr(ld_112, 2), " \\ Свободные средства = ", DoubleToStr(ld_120, 2), " \\ Прибыль сегодня = ", f0_0(), " Прибыль вчера = ", f0_2(), " $", 
   "\n SPREAD = ", spread_0, " p (Max spread=", Max_SPREAAD, "p) TP_in_money_dinamic=", gd_536, " $");
   if (Use_SL_TP && f0_4() > 1) {
      for (li_64 = 0; li_64 < OrdersTotal(); li_64++) {
         OrderSelect(li_64, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92 || OrderType() > OP_SELL) continue;
         cmd_68 = OrderType();
         order_stoploss_144 = OrderStopLoss();
         order_takeprofit_152 = OrderTakeProfit();
      }
      for (li_64 = OrdersTotal() - 1; li_64 >= 0; li_64--) {
         OrderSelect(li_64, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92 || OrderType() > OP_SELL) continue;
         if (OrderType() == cmd_68)
            if (OrderStopLoss() != order_stoploss_144 || OrderTakeProfit() != order_takeprofit_152) OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_144, order_takeprofit_152, 0, CLR_NONE);
      }
   }
   double ld_160 = 0;
   for (li_64 = 0; li_64 < OrdersTotal(); li_64++) {
      OrderSelect(li_64, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92 || OrderType() > OP_SELL) continue;
      ld_160 += OrderProfit();
   }
   if (ld_160 >= gd_536 || g_count_344 > 0) {
      f0_1();
      f0_1();
      f0_1();
      g_count_344++;
      if (f0_4() == 0) g_count_344 = 0;
   }
   if ((!Invisible_mode) && Use_SL_TP && f0_4() < Level) f0_1();
   return (0);
}

double f0_0() {
   int day_0 = Day();
   double ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92) continue;
      if (TimeDay(OrderOpenTime()) == day_0) ld_ret_4 += OrderProfit();
   }
   return (ld_ret_4);
}

double f0_2() {
   int li_0 = Day() - 1;
   double ld_ret_4 = 0;
   int li_unused_12 = 0;
   if (li_0 == 1) li_0 = 7;
   for (int pos_16 = 0; pos_16 < OrdersHistoryTotal(); pos_16++) {
      OrderSelect(pos_16, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92) continue;
      if (TimeDay(OrderOpenTime()) == li_0) ld_ret_4 += OrderProfit();
   }
   return (ld_ret_4);
}

int f0_4() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92) continue;
      count_0++;
   }
   return (count_0);
}

void f0_1() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_92) continue;
      gi_520 = TRUE;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, Blue);
         else OrderClose(OrderTicket(), OrderLots(), Ask, 3, Red);
      }
   }
}

int f0_3() {
   if (!Working_Time) return (1);
   if (OpenHour < CloseHour && TimeHour(TimeCurrent()) < OpenHour || TimeHour(TimeCurrent()) >= CloseHour) return (0);
   if (OpenHour > CloseHour && (TimeHour(TimeCurrent()) < OpenHour && TimeHour(TimeCurrent()) >= CloseHour)) return (0);
   if (OpenHour == 0) CloseHour = 24;
   if (Hour() == CloseHour - 1 && Minute() >= 55) return (0);
   return (1);
}
int MACD_Signal(int acc_number_8, int li_12, double g_imacd_480, double g_imacd_488, double g_imacd_496, double g_imacd_504, double g_imacd_512){
      if ( g_imacd_480 < 0.0 && g_imacd_488 > g_imacd_496 && g_imacd_504 < g_imacd_512 ) return (1);
      if ( g_imacd_480 > 0.0 && g_imacd_488 < g_imacd_496 && g_imacd_504 > g_imacd_512 ) return (2);
      return(0);
}