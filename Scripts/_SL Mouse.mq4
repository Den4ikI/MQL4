//+------------------------------------------------------------------+
#property copyright "Copyright © 2017"
#property link      "http://cmillion.ru"
#property version   "2.00"
#property strict
//+------------------------------------------------------------------+
void OnStart()
  {
   int Ticket;
   double OOP,OL,value = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("Скрипт выставления SL ",DoubleToStr(value,Digits)," старт ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   RefreshRates();
   double profit,Rrofit=0,TICKVALUE=MarketInfo(Symbol(),MODE_TICKVALUE);
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      
      Ticket = OrderTicket();
      OOP = OrderOpenPrice();
      OL = OrderLots();
      if(OrderType()==OP_BUY)     
      if(value<Ask) 
      {
         profit=(value-OOP)/Point*OL*TICKVALUE;
         if (OrderModify(Ticket,OrderOpenPrice(),value,OrderTakeProfit() ,OrderExpiration(),White))
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," BUY ордеру ",Ticket," на ",DoubleToStr((value-OOP)/Point,2)," п.  ",DoubleToStr(profit,2)," ",AccountCurrency());
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс BUY ордеру ",Ticket);
         Rrofit+=profit;
      }
      
      if(OrderType()==OP_SELL)
      if(value>Bid) 
      {
         profit=(OOP-value)/Point*OL*TICKVALUE;
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White))   
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," SELL ордеру ",Ticket," на ",DoubleToStr((OOP-value)/Point,2)," п.  ",DoubleToStr(profit,2)," ",AccountCurrency());
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс SELL ордеру ",Ticket);
         Rrofit+=profit;
      }
         
      if((OrderType()==OP_BUYSTOP) || (OrderType()==OP_BUYLIMIT))     
      if(value<OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White)) 
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," отложенному BUY  ордеру ",Ticket);
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс отложенному BUY ордеру ",Ticket);
      }
       
      if((OrderType()==OP_SELLSTOP) || (OrderType()==OP_SELLLIMIT))
      if(value>OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White))                
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," отложенному SELL ордеру ",Ticket);
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс отложенному SELL ордеру ",Ticket);
      }
      Comment(txt);
   }   
   Comment(txt,"\nПри закрытии по SL получим прибыль = ",DoubleToStr(Rrofit,2)," ",AccountCurrency(),"\nСкрипт закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return;
  }
//+------------------------------------------------------------------+