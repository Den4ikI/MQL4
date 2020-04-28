//+------------------------------------------------------------------+
//|                                                     StarDust.mq4 |
//|                                     Copyright © 2010, NutCracker |
//|                                              forex-way@yandex.ru |
//|                                              http://wellforex.ru |
//-------------------------------------------------------------------+

#property copyright "Copyright © 2010, http://wellforex.ru"
#property link      "forex-way@yandex.ru"
extern int Magic=10001;
extern string LotSet = "Управление капиталом";
extern double StartLots = 0.1;
extern bool     MM=false;                       // Включение ММ да/нет
extern double   MMRisk=0.3;                       // Risk Factor
extern string Sets = "Параметры";
extern int   CheckTime  = 22;
extern int   EndTime    = 0;
extern int   CloseTime    = 3;
extern int   OrderPriceShift    = 13;
extern int   Stop=59;
extern int   Take=11;
extern int   Step=3;
extern int   OrderMax=5;  
extern int   MaxDayRange=190;  

int MaxTries=5;
int LastSig=0;
int i,cnt=0, ticket, mode=0, digit=0, OrderCod=0;
double BuyProfit=0, SellProfit=0, MartinRise=1;
double Lotsi=0;
double BuyPrice, SellPrice, Stop_Loss, Take_Profit, p1,p2,max=0,min=0;
double  BuyStop=0, SellStop=0, StopLoss, TakeProfit, NewTake;
string  name="StarDust", dayrange="не определён", ModeStr="Нет";
int Dec=10, LastVol, total=0, Num=0;
double BuySig, SellSig, LastLot, LastPrice;
bool  OrderToday=false, Martin=false;

int init()
  {
   return(0);
  }

double MoneyManagement ( bool flag, double risk)
{
   double Lotsi=StartLots;
	    
   if ( flag ) Lotsi=NormalizeDouble(AccountBalance()*risk/1000,1);   
   if (Lotsi<0.1) Lotsi=0.1;  
   return(Lotsi);
}   
  
void BuyMarketOrdOpen(int ColorOfBuy,int Magic)
  {
  int try, res;

 //  if(Volume[0]>1) return;

          
  for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();		  

      res=OrderSend(Symbol(),OP_BUY,Lotsi,NormalizeDouble(Ask ,digit),2*Dec,NormalizeDouble(Bid ,digit)-StopLoss,NormalizeDouble(Ask ,digit)+TakeProfit,name,Magic,0,ColorOfBuy);
      Sleep(2000);
      if(res>0)
           {
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) break;
            }
         else 
         {
         Print("Error opening BUY order : ",GetLastError(), " Try ", try); 
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
         Sleep(5000);
         }     
       }
      return;
      }

void SellMarketOrdOpen(int ColorOfSell,int Magic)      
      { 
        int try, res;  

 //       if(Volume[0]>1) return;

  
 for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();	
       
      res=OrderSend(Symbol(),OP_SELL,Lotsi,NormalizeDouble(Bid ,digit),2*Dec,NormalizeDouble(Ask ,digit)+StopLoss,NormalizeDouble(Bid ,digit)-TakeProfit,name,Magic,0,ColorOfSell);
      Sleep(2000);
      if(res>0)
           {
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) break;
            }
         else 
         {
         Print("Error opening SELL order : ",GetLastError(), " Try ", try); 
         if (try==MaxTries) {Print("Warning!!!Last try failed!");} 
         Sleep(5000);
        }
      }
      return;
      }
      
void SellLimitOrdOpen(int ColorOfSell,int Magic)
{		     

  
 for (int try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();		  
		  
          ticket = OrderSend(Symbol(),OP_SELLLIMIT,Lotsi,
		                     NormalizeDouble(SellPrice,digit),
		                     6,
		                     NormalizeDouble(SellStop,digit),
		                     NormalizeDouble(SellProfit,digit),name,Magic,0,ColorOfSell);
       
           Sleep(2000);
            if (ticket>0) {OrderToday=true;break;  }          
            
            if(ticket<0)
            {
             if (try==MaxTries) {Print("Warning!!!Last try failed!");}
            Print("OrderSend failed with error #",GetLastError());
            Sleep(5000);
            return(0);
            }
}
}

void BuyLimitOrdOpen(int ColorOfBuy,int Magic)
{		     
  
for (int try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();	

		   ticket = OrderSend(Symbol(),OP_BUYLIMIT ,Lotsi,
		                     NormalizeDouble(BuyPrice ,digit),
		                     6,
		                     NormalizeDouble(BuyStop ,digit),
		                     NormalizeDouble(BuyProfit,digit),name,Magic,0,ColorOfBuy);		        		                     		                                   
                   Sleep(2000);    
            if (ticket>0) {OrderToday=true;break; }         
            if(ticket<0)
            {
            if (try==MaxTries) {Print("Warning!!!Last try failed!");}
            Print("OrderSend failed with error #",GetLastError());
            Sleep(5000);
            return(0);
            }
            }
}  



int ScanTradesLimit(int Magic)
{   
   total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<=total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT) && OrderMagicNumber() == Magic) 
   numords++;
   }
   return(numords);
}

void AllOrdDel(int Magic)
{
    int total=OrdersTotal();
    bool result = false;
    for (int cnt=total-1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);   
      
        if (OrderMagicNumber()==Magic && OrderType()==OP_BUY)     
        {
        result = false;
 
 for (int try=1;try<=MaxTries;try++)
       {		 
          result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid ,digit),2*Dec,Yellow);
          if(result) break;            
          if(!result) Print("OrderSend failed with error #",GetLastError());                                      
        }
       }
        if (OrderMagicNumber()==Magic && OrderType()==OP_SELL)     
        {
        result = false;
 
 for (try=1;try<=MaxTries;try++)
       {		 
          result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask ,digit),2*Dec,Yellow);
          if(result) break;            
          if(!result) Print("OrderSend failed with error #",GetLastError());                                      
        }
       }
      } 
     
  return;
  } 


void PendLimitOrdDel(int Magic)
{
    total=OrdersTotal();
    for (int cnt=total+1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);   
      
        if (OrderMagicNumber()==Magic && (OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYLIMIT))     
        {
        bool result = false;
 
 for (int try=1;try<=MaxTries;try++)
       {		 
          result = OrderDelete(OrderTicket()); 
          if(result) break;
          if(!result) Print("OrderSend failed with error #",GetLastError());                           

        }
       }
      } 
     
  return;
  }  


int ScanTradesOpen(int Magic)
{   
   total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL)  && OrderMagicNumber() == Magic) 
   numords++;
   }
   return(numords);
}

void OrderReply()
{        
    int total=OrdersTotal(), try;
    double LastOpen;
    bool result=false;
    if (ScanTradesOpen(Magic)>=OrderMax) return (0); 

     for (cnt=0;cnt<=total;cnt++)      
       {
      OrderSelect(cnt, SELECT_BY_POS);
      if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL)) 
      {LastOpen=OrderOpenPrice(); LastLot=OrderLots(); mode=OrderType();
      if (mode==OP_BUY) ModeStr="Buy";
      if (mode==OP_SELL) ModeStr="Sell";
       }              
       }
      if (Martin) Lotsi=LastLot*MartinRise;      
 //   OrderSelect(total-1, SELECT_BY_POS);     

      StopLoss=Stop*Dec*Point;
      TakeProfit=Take*Dec*Point;
    if (NormalizeDouble(Ask ,digit)-LastOpen<-(Step*Dec*Point) && mode==OP_BUY)
    {
     BuyMarketOrdOpen(Blue,Magic);

     total=OrdersTotal();
     //OrderSelect(total-1, SELECT_BY_POS); 
     NewTake=NormalizeDouble(Ask ,digit)+TakeProfit;
     for (cnt=0;cnt<total-1;cnt++)      
       {
      OrderSelect(cnt, SELECT_BY_POS);           
      if (OrderMagicNumber() == Magic) 
      {
 for (try=1;try<=MaxTries;try++)
       {		 
          result = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NewTake,0,Green);
          if(result) break;
          if(!result) Print("OrderModify failed with error #",GetLastError());                           

        }
      }
       }
    }
    if (LastOpen-NormalizeDouble(Bid ,digit)<-(Step*Dec*Point) && mode==OP_SELL)
    {
     SellMarketOrdOpen(Red,Magic);

     total=OrdersTotal();
     //OrderSelect(total-1, SELECT_BY_POS); 
     NewTake=NormalizeDouble(Bid ,digit)-TakeProfit;
     for (cnt=0;cnt<total-1;cnt++)      
       {
       OrderSelect(cnt, SELECT_BY_POS);           
       if (OrderMagicNumber() == Magic) 
       {
        for (try=1;try<=MaxTries;try++)
       {		 
          result = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NewTake,0,Green);
          if(result) break;
          if(!result) Print("OrderModify failed with error #",GetLastError());                           

        }
       
       }
       }
    }
    return(0);
} 


  
int Rules() 
{
    if (Hour()==CheckTime && OrderToday==false) 
    {  

   max=0;
   for(int kkk=1;kkk<=Hour();kkk++){
         if (iHigh(Symbol(),PERIOD_H1,kkk)>max) max=iHigh(Symbol(),PERIOD_H1,kkk);
      }
      p1=max;
    min=100000; 
   for(int lll=1;lll<=Hour();lll++){
         if (iLow(Symbol(),PERIOD_H1,lll)<min) min=iLow(Symbol(),PERIOD_H1,lll);
      }
      p2=min;

 if ((p1-p2)>MaxDayRange*Point*Dec) {dayrange="аномальный, торговля запрещена"; return(0);}
 dayrange="нормальный, торговля разрешена";      
      SellPrice=iClose(Symbol(),0,1)+OrderPriceShift*Dec*Point;
      BuyPrice =iClose(Symbol(),0,1)-OrderPriceShift*Dec*Point;    
      SellStop=SellPrice + Stop*Dec*Point;
      BuyStop=BuyPrice - Stop*Dec*Point;
      BuyProfit=BuyPrice+Take*Dec*Point;
      SellProfit=SellPrice-Take*Dec*Point;
      StopLoss=Stop*Dec*Point;
      TakeProfit=Take*Dec*Point;  
      return(1); 

     } 
   }

int start()
{


   digit  = MarketInfo(Symbol(),MODE_DIGITS); 
   if (digit==5 || digit==3) Dec=10;
   if (digit==4 || digit==2) Dec=1;   
   Lotsi = MoneyManagement (MM,MMRisk);
if (!IsOptimization() && !IsTesting() && !IsVisualMode()) {Comment("Magic = ", Magic,"\nСледующий лот = ", Lotsi,
         "\nНаправление = "+ModeStr, "\nОткрытых = ", ScanTradesOpen(Magic),
        "   \nМинимальный лот = ", MarketInfo(Symbol(), MODE_MINLOT),"\nДневной диапазон = "+dayrange);}


//if (Month()==12 && Day()>=24) return(0);   
if(ScanTradesOpen(Magic)!=0 && ScanTradesLimit(Magic)!=0) PendLimitOrdDel(Magic);
if (Hour()==EndTime && ScanTradesLimit(Magic)>0) {PendLimitOrdDel(Magic); OrderToday=false;}
if (Hour()==CloseTime && ScanTradesOpen(Magic)>0 && !Martin) {AllOrdDel(Magic); OrderToday=false;} 
if (Hour()==CloseTime) OrderToday=false;

 

if((Volume[0]<=LastVol))
{   
OrderCod=Rules();    
if (ScanTradesOpen(Magic)==0 && ScanTradesLimit(Magic)==0 && OrderToday==false)
      {
      if (Rules()==1) {BuyLimitOrdOpen(Blue,Magic); SellLimitOrdOpen(Red,Magic);}            
      }
if(ScanTradesOpen(Magic)>0) OrderReply();
}
   LastVol=Volume[0]; 

}






