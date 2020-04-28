//+------------------------------------------------------------------+
//|                                                     FullFade.mq4 |
//|                                     Copyright © 2010, NutCracker |
//|                                              forex-way@yandex.ru |
//|                                              http://wellforex.ru |
//-------------------------------------------------------------------+

#property copyright "Copyright © 2010, http://wellforex.ru"
#property link      "forex-way@yandex.ru"

extern double   Lots = 0.1;
extern int      BPeriod=20;
extern int      RSIPeriod=14;
extern int      RSIBuy=30;
extern int      RSISell=70;
extern bool     UseRSI=false;
extern bool     OneCandleTrade=true;
extern int      Take=110;
extern int      Stop=40;


int Magic=1021;
int MaxTries=5, OpenBuy, OpenSell;
int i,cnt=0, ticket, mode=0, digit=5;
double Lotsi=0,ress,spread;
double  TakeProfit;
int Dec=10, LastVol;
double Pivot;
datetime t1, t2, LastTimeBuy, LastTimeSell;
bool Buy, Sell;
double BollingerUp1, BollingerDn1, BollingerUp2, BollingerDn2, BollingerUp3, BollingerDn3, RSI;
string name="FullFade";

int init()
  {
   return(0);
  }

void deinit() 
{

}

int start()

{

   digit  = MarketInfo(Symbol(),MODE_DIGITS); 
   if (digit==5 || digit==3) Dec=10;
   if (digit==4 || digit==2) Dec=1;   

spread= MarketInfo(Symbol(),MODE_SPREAD);

Lotsi = Lots;

OpenBuy=ScanTradesOpenBuy(Magic);
OpenSell=ScanTradesOpenSell(Magic);

if (OpenBuy==1 && iClose(Symbol(),0,1)>BollingerUp2) AllBuyOrdDel(); 
if (OpenSell==1 && iClose(Symbol(),0,1)<BollingerDn2) AllSellOrdDel(); 

if (OpenBuy==1 || OpenSell==1) TP_Modify(Magic);

if (Volume[0]<=10 && (Volume[0]<LastVol || Volume[0]==1))
{

if (OneCandleTrade) Buy=false; Sell=false;

   BollingerUp1=iBands(Symbol(),0,BPeriod,1,0,PRICE_CLOSE,MODE_UPPER,1);
   BollingerDn1=iBands(Symbol(),0,BPeriod,1,0,PRICE_CLOSE,MODE_LOWER,1);
   BollingerUp2=iBands(Symbol(),0,BPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1);
   BollingerDn2=iBands(Symbol(),0,BPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1);
   BollingerUp3=iBands(Symbol(),0,BPeriod,3,0,PRICE_CLOSE,MODE_UPPER,1);
   BollingerDn3=iBands(Symbol(),0,BPeriod,3,0,PRICE_CLOSE,MODE_LOWER,1);

   RSI=iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,1);


if (iLow(Symbol(),0,1)<BollingerDn3) Buy=true;
if (iHigh(Symbol(),0,1)>BollingerUp3) Sell=true;

OpenBuy=ScanTradesOpenBuy(Magic);
OpenSell=ScanTradesOpenSell(Magic);

if (Buy && RSI>RSIBuy && UseRSI) Buy=false;
if (Sell && RSI<RSISell && UseRSI) Sell=false;

   if(Buy && iClose(Symbol(),0,1)>BollingerDn2 && iClose(Symbol(),0,1)<BollingerDn1 && iOpen(Symbol(),0,1)<iClose(Symbol(),0,1) && OpenBuy==0) 
   {Buy=false; TakeProfit=NormalizeDouble(Ask+Stop*Dec*Point,digit); BuyMarketOrdOpen(Blue,Magic); TakeProfit=NormalizeDouble(Ask+Take*Dec*Point,digit); BuyMarketOrdOpen(Blue,Magic);}
   if(Sell && iClose(Symbol(),0,1)<BollingerUp2 && iClose(Symbol(),0,1)>BollingerUp1 && iOpen(Symbol(),0,1)>iClose(Symbol(),0,1) && OpenSell==0) 
   {Sell=false; TakeProfit=NormalizeDouble(Bid-Stop*Dec*Point,digit); SellMarketOrdOpen(Red,Magic); TakeProfit=NormalizeDouble(Bid-Take*Dec*Point,digit); SellMarketOrdOpen(Red,Magic);}
}
LastVol=Volume[0]; 


}

 
void BuyMarketOrdOpen(int ColorOfBuy,int Magic)
  {
  int try, res;          
  for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();		  
      res=OrderSend(Symbol(),OP_BUY,Lotsi,NormalizeDouble(Ask ,digit),2*Dec,NormalizeDouble(Bid ,digit)-Stop*Dec*Point,TakeProfit,name+" ("+Symbol()+")",Magic,0,ColorOfBuy);
      Sleep(2000);
      if(res>0)
           {
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) {PlaySound("news.wav"); break;}
            }
         else 
         {
         Print("Error opening BUY order : ",GetLastError()); PlaySound("timeout.wav"); Sleep(5000);
         }     
       }
      return;
      }

void SellMarketOrdOpen(int ColorOfSell,int Magic)      
      { 
        int try, res;    
 for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();	    
      res=OrderSend(Symbol(),OP_SELL,Lotsi,NormalizeDouble(Bid ,digit),2*Dec,NormalizeDouble(Ask ,digit)+Stop*Dec*Point,TakeProfit,name+" ("+Symbol()+")",Magic,0,ColorOfSell);
      Sleep(2000);
      if(res>0)
           {
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) {PlaySound("news.wav"); break;}
            }
         else 
         {
         Print("Error opening BUY order : ",GetLastError()); PlaySound("timeout.wav"); Sleep(5000);
        }
      }
      return;
      }
     


int ScanTradesOpenBuy(int Magic)
{   
   int total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_BUY)  && OrderMagicNumber() == Magic) 
   numords++;
   }
   return(numords);
}

int ScanTradesOpenSell(int Magic)
{   
   int total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_SELL)  && OrderMagicNumber() == Magic) 
   numords++;
   }
   return(numords);
}

void AllBuyOrdDel()
{
    int total=OrdersTotal();
    for (int cnt=total-1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);   
      
        bool result = false;
 
 for (int try=1;try<=MaxTries;try++)
       {		 
       while (!IsTradeAllowed()) Sleep(5000);
          RefreshRates();
          if (OrderType()==0) result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid ,digit),5*Dec,Yellow);
          if(result) break;            
          if(!result) Print("OrderSend CloseBuy failed with error #",GetLastError(), " Try ", try);                                      
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
          Sleep(5000);
        }
       }
       
     
  return;
  }
  
void AllSellOrdDel()
{
    int total=OrdersTotal();
    for (int cnt=total-1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);   
      
        bool result = false;
 
 for (int try=1;try<=MaxTries;try++)
       {		 
       while (!IsTradeAllowed()) Sleep(5000);
          RefreshRates();
          if (OrderType()==1) result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask ,digit),5*Dec,Yellow);
          if(result) break;            
          if(!result) Print("OrderSend CloseBuy failed with error #",GetLastError(), " Try ", try);                                      
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
          Sleep(5000);
        }
       }
       
     
  return;
  }


void TP_Modify(int Magic)
{        
    int total=OrdersTotal();
    for (cnt=0;cnt<total;cnt++)
    { 
     OrderSelect(cnt, SELECT_BY_POS);   
     mode=OrderType();    
        if ( OrderSymbol()==Symbol() && OrderMagicNumber()==Magic ) 
        {
          
            if ( mode==OP_BUY )
            {
           if(NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(OrderOpenPrice(),Digits))
            {
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Yellow);
            //return(0);
            } 
            }
             
           if ( mode==OP_SELL)
            {
           if(NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(OrderOpenPrice(),Digits))
            {
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Yellow);
            //return(0);
            }           
           }    
        }
    }   
}










