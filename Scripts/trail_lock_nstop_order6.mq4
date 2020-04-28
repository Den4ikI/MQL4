//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, http://cmillion.ru/"
#property link      "cmillion@narod.ru"
#property show_inputs
//--------------------------------------------------------------------
#property description "Скрипт выставляет стоп ордер на то место куда его бросили или на расстояние Delta от цены, если Delta указана больше ноля."
#property description "BuyStop, если кинули Выше цены и SellStop если ниже"
#property description "Далее скрипт будет тралить этот ордер за ценой вплоть до срабатывания> после чего закончит свою работу."
#property description "Если не указан лот в параметре Lot, то скрипт сам вычисляет лот как разницу суммы лотов направлений (лок)"
//--------------------------------------------------------------------
extern int     TakeProfit        = 0;     //тейкпрофит ордера, если 0 то нет стоплосса
extern int     StopLoss          = 0;     //стоплосс ордера, если 0 то нет стоплосса
extern int     Delta             = 0;     //расстояние от цены до ордера, если 0 то ордер открываем в точке, куда бросили его мышью
extern int     StepMove          = 1;     //шаг смещения ордера в пунктах
extern double  Lot               = 0.1;   //лот, если 0 то скрипт сам рассчитывает лок
extern int     Magic             = 100;   //уникальный номер ордера
//--------------------------------------------------------------------
int start()
{
   int i,OT,TicketBuyStop,TicketSellStop;
   double LB=0,LS=0,PriceBuyStop=0,PriceSellStop=0;
   if (Lot==0)
   {
      for (i=0; i<OrdersTotal(); i++)
      {    
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if (OrderSymbol()==Symbol())
            { 
               OT = OrderType(); 
               if (OT==OP_BUY) 
               {  
                  LB=OrderLots();
               }                                         
               if (OT==OP_SELL) 
               {
                  LS=OrderLots();
               }                                         
            }
         }
      }
   }
   
   //---
   
   double SL,TP,delta;
   double StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
   double Price = NormalizeDouble(WindowPriceOnDropped(),Digits);
   if(Price>=Ask) 
   {
      if (Lot==0) Lot = LS-LB;
      if (Lot<0)  {Comment("Лок ордер в данном направлении не нужен, скрипт закончил свою работу");return(0);}
      if (Delta>0) Price = NormalizeDouble(Ask+Delta*Point,Digits);
      if (Price<NormalizeDouble(Ask+StopLevel,Digits)) Price = NormalizeDouble(Ask+StopLevel,Digits);
      if (TakeProfit!=0) TP = NormalizeDouble(Price + TakeProfit * Point,Digits); else TP=0;
      if (StopLoss!=0) SL = NormalizeDouble(Price - StopLoss * Point,Digits); else SL=0;
      if (OrderSend(Symbol(),OP_BUYSTOP,Lot,Price,0,SL,TP,"http://cmillion.ru/",Magic,0,CLR_NONE)==-1) Comment("Error OrderSend BUYSTOP ",GetLastError());
      delta = NormalizeDouble(Price-Ask,Digits);
   }
   if(Price<=Bid) 
   {
      if (Lot==0) Lot = LB-LS;
      if (Lot<0)  {Comment("Лок ордер в данном направлении не нужен, скрипт закончил свою работу");return(0);}
      if (Delta>0) Price = NormalizeDouble(Bid-Delta*Point,Digits);
      if (Price>NormalizeDouble(Bid-StopLevel,Digits)) Price = NormalizeDouble(Bid-StopLevel,Digits);
      if (TakeProfit!=0) TP = NormalizeDouble(Price - TakeProfit * Point,Digits); else TP=0;
      if (StopLoss!=0) SL = NormalizeDouble(Price + StopLoss * Point,Digits); else SL=0;
      if (OrderSend(Symbol(),OP_SELLSTOP,Lot,Price,0,SL,TP,"http://cmillion.ru/",Magic,0,CLR_NONE)==-1) Comment("Error OrderSend SELLSTOP ",GetLastError());
      delta = NormalizeDouble(Bid-Price,Digits);
   }
   Comment("Тянем стоп ордер на расстоянии ",DoubleToStr(delta/Point,0),"п");

   //---

   while(!IsStopped())
   {
      TicketBuyStop=0;TicketSellStop=0;
      for (i=0; i<OrdersTotal(); i++)
      {    
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if (OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
            { 
               OT = OrderType(); 
               if (OT==OP_BUYSTOP) 
               {  
                  TicketBuyStop=OrderTicket();
                  PriceBuyStop = NormalizeDouble(OrderOpenPrice(),Digits);
               }                                         
               if (OT==OP_SELLSTOP) 
               {
                  TicketSellStop=OrderTicket();
                  PriceSellStop = NormalizeDouble(OrderOpenPrice(),Digits);
               }                                         
            }
         }
      }
      
      //---
   
      if (TicketBuyStop+TicketSellStop==0) {Comment("Скрипт закончил свою работу");return(0);}
      
      //---
   
      if (PriceBuyStop!=0)             
      {  
         Price = NormalizeDouble(Ask+delta,Digits);
         if (NormalizeDouble(PriceBuyStop-StepMove*Point,Digits) > Price)
         {  
            if (!OrderModify(TicketBuyStop,Price,0,0,0,White)) Print("Error ",GetLastError(),"   Order Modify Buy   OOP ",PriceBuyStop,"->",Price);
            //else Print("Order Buy Modify   OOP ",PriceBuyStop,"->",Price);
         }
      }                                         
      if (PriceSellStop!=0)        
      {
         Price = NormalizeDouble(Bid-delta,Digits);
         if (NormalizeDouble(PriceSellStop+StepMove*Point,Digits) < Price)
         {  
            if (!OrderModify(TicketSellStop,Price,0,0,0,White)) Print("Error ",GetLastError(),"   Order Modify Sell   OOP ",PriceSellStop,"->",Price);
            //else Print("Order Sell Modify   OOP ",PriceSellStop,"->",Price);
         }
      } 
      Sleep(500);
      RefreshRates();
   }
   return(0);
}
//--------------------------------------------------------------------

