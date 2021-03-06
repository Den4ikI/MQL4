//+------------------------------------------------------------------+
//| removal or closure order, which put the mouse script             |
//|                              Copyright © 2012, Vladimir Khlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012-2020, Vladimir Khlystov"
#property link      "cmillion@narod.ru"
#property strict
#property show_inputs
#property description "Скрипт закрывает заданный процент от позиции на которую его бросили мышью"
extern double Percent = 50;//процент закрытия ордера
extern int slippage = 20;
double MINLOT,MAXLOT;
//--------------------------------------------------------------------
int OnStart()
  {
   MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
   MAXLOT = MarketInfo(Symbol(),MODE_MAXLOT);
   double Price = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("The script removal or cl   osure order ",
                                DoubleToStr(Price-slippage*Point,Digits)," - ",
                                DoubleToStr(Price+slippage*Point,Digits)," start ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   RefreshRates();

   bool error=true;
   int Error,OT,Ticket;
   double OOP,LotClose;
   for(int j = OrdersTotal()-1; j >= 0; j--)
     {
      if(OrderSelect(j, SELECT_BY_POS))
        {
         if((OrderSymbol() == Symbol()))
           {
            OT = OrderType();
            Ticket = OrderTicket();
            OOP = OrderOpenPrice();
            if(OOP<Price-slippage*Point || OOP > Price+slippage*Point)
               continue;
            if(OT==OP_BUY)
              {
               LotClose = NormalizeDouble(OrderLots()*Percent/100,2);
               if(LotClose<MINLOT)
                  LotClose = MINLOT;
               error=OrderClose(Ticket,LotClose,NormalizeDouble(Bid,Digits),slippage,Red);
               if(error)
                  txt = StringConcatenate(txt,"\nclosed order BUY ",Ticket);
               else
                  txt = StringConcatenate(txt,"\nError closing ",GetLastError());
              }
            if(OT==OP_SELL)
              {
               LotClose = NormalizeDouble(OrderLots()*Percent/100,2);
               if(LotClose<MINLOT)
                  LotClose = MINLOT;
               error=OrderClose(Ticket,LotClose,NormalizeDouble(Ask,Digits),slippage,Blue);
               if(error)
                  txt = StringConcatenate(txt,"\nclosed order SELL ",Ticket);
               else
                  txt = StringConcatenate(txt,"\nError ",GetLastError()," close ",Ticket);
              }
            if(OT>1)
              {
               error=OrderDelete(Ticket);
               if(error)
                  txt = StringConcatenate(txt,"\nDelete order ",StrOrdersType(OT)," ",Ticket);
               else
                  txt = StringConcatenate(txt,"\nError ",GetLastError()," delete ",StrOrdersType(OT)," ",Ticket);
              }
            if(!error)
              {
               Error = GetLastError();
               if(Error<2)
                  continue;
               if(Error==129)
                 {
                  Comment("Wrong price ",TimeToStr(TimeCurrent(),TIME_SECONDS));
                  Sleep(5000);
                  RefreshRates();
                  continue;
                 }
               if(Error==146)
                 {
                  j++;
                  if(IsTradeContextBusy())
                     Sleep(2000);
                  continue;
                 }
               Comment("Error ",Error," closed order N ",OrderTicket(),
                       "     ",TimeToStr(TimeCurrent(),TIME_SECONDS));
              }
           }
        }
     }
   Comment(txt,"\nThe script has finished its work ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
  }
//--------------------------------------------------------------------
string StrOrdersType(int t)
  {
   if(t==OP_BUY)
      return("Buy");
   if(t==OP_SELL)
      return("Sell");
   if(t==OP_BUYLIMIT)
      return("BuyLimit");
   if(t==OP_SELLLIMIT)
      return("SellLimit");
   if(t==OP_BUYSTOP)
      return("BuyStop");
   if(t==OP_SELLSTOP)
      return("SellStop");
   return("");
  }
//--------------------------------------------------------------------
//+------------------------------------------------------------------+
