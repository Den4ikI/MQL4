//+------------------------------------------------------------------+
//|                                           Stochastic Trading.mq4 |
//|                                     Copyright © 2010, NutCracker |
//|                                              forex-way@yandex.ru |
//|                                              http://wellforex.ru |
//-------------------------------------------------------------------+
#property copyright "Copyright © 2010, http://wellforex.ru"
#property link      "forex-way@yandex.ru"
extern  int     Magic=10012;
extern string   ParamertSet1 = "ADX Set";
extern int      ADXperiod=15;                      //ADX period
extern int      ADXLevel = 30;                     //Уровень тренда
extern string   ParamertSet2 = "MA Set";
extern bool     UseMA=true;                        //Включение ADX-MA
extern int      MAperiod=30;                       //MA period
extern bool     CloseByMA=true;                    //Включение закрытия по обратному пересечению МА  
extern string   ParamertSet3 = "Stochastic Set";
extern bool     UseStochastic=true;                //Включение ADX-Stochastic
extern int      Kperiod=16;                        //%K line period
extern int      Dperiod=3;                         //%D line period 
extern int      Slowing=3;                         //Slowing value
extern int      SellLevel = 80;                    //Уровень продажи
extern int      BuyLevel = 20;                     //Уровень покупки
extern string   ParamertSet4 = "Expert Set";
extern int      TakeMA=280;                        //Тейкпрофит ADX-MA
extern int      StopMA=50;                         //Стоплосс ADX-MA
extern int      TakeStochastic=110;                 //Тейкпрофит ADX-Stochastic
extern int      StopStochastic=110;                 //Стоплосс ADX-Stochastic
extern bool     Tral=false;                        //Трал обычный да/нет                  
extern int      TS=60;                             //Уровень трала                          
extern int      TralStep=30;                       //Шаг трала 
extern string   MMSet = "Управление капиталом";
extern bool     MM=false;                       // Включение ММ да/нет
extern double   MMRisk=0.1;                     // Risk Factor
extern double   Lots = 0.1;                     // Лот


int  MaxTries=10, Dec, method=2;
int   i, cnt=0, ticket, mode=0, digit=0, total, BuySig=0, SellSig=0;
double  StopLoss, TakeProfit, Lotsi=0;
double  BuyStop=0, SellStop=0, SM1, SS1, SM2, SS2, ADX1, ADX2,MA,DMINUS,DPLUS;
int LastVol;
string  name;

      
int init()
  {


   return(0);
  }


int start()
{
   name="ADX-MA-St "+DoubleToStr(Period(),0);
   digit  = MarketInfo(Symbol(),MODE_DIGITS); 
   if (digit==5 || digit==3) Dec=10;
   if (digit==4 || digit==2) Dec=1; 
 
   Lotsi = MoneyManagement (MM,MMRisk);



if(Volume[0]==1 || Volume[0]<LastVol)
{ 
SM1=iStochastic(Symbol(),Period(),Kperiod,Dperiod,Slowing,method,1,MODE_MAIN,1);
SS1=iStochastic(Symbol(),Period(),Kperiod,Dperiod,Slowing,method,1,MODE_SIGNAL,1);
SM2=iStochastic(Symbol(),Period(),Kperiod,Dperiod,Slowing,method,1,MODE_MAIN,2);
SS2=iStochastic(Symbol(),Period(),Kperiod,Dperiod,Slowing,method,1,MODE_SIGNAL,2);
ADX1=iADX(Symbol(),Period(),ADXperiod,0,MODE_MAIN,1);
ADX2=iADX(Symbol(),Period(),ADXperiod,0,MODE_MAIN,2);
DPLUS=iADX(Symbol(),Period(),ADXperiod,0,MODE_PLUSDI,1);
DMINUS=iADX(Symbol(),Period(),ADXperiod,0,MODE_MINUSDI,1);
MA=iMA(Symbol(),Period(),MAperiod,0,MODE_SMMA,0,1);


if (ScanTradesOpen(Magic)>0 && CloseByMA) CloseByMA(Magic); 
if (ScanTradesOpen(Magic)>0 && Tral) TrailStops(Magic); 
if (ScanTradesOpen(Magic+1)>0 && Tral) TrailStops(Magic+1); 
 
if (Rules()==1 && ScanTradesOpen(Magic)==0 && UseMA)
  {
   if (!IsOptimization())
 {
         ObjectCreate("BB"+TimeCurrent(), OBJ_ARROW,0,0,0,0,0);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_COLOR, Blue);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_ARROWCODE, 233);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_TIME1,TimeCurrent()-Period());
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_PRICE1,iLow(Symbol(),Period(),1));   
 }
TakeProfit=TakeMA*Dec*Point;StopLoss=StopMA*Dec*Point;
 BuyMarketOrdOpen(Blue,Magic);}

  if (Rules()==2 && ScanTradesOpen(Magic)==0 && UseMA)
  {
   if (!IsOptimization())
 {
         ObjectCreate("BB"+TimeCurrent(), OBJ_ARROW,0,0,0,0,0);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_COLOR, Red);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_ARROWCODE, 234);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_TIME1,TimeCurrent()-Period());
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_PRICE1,iHigh(Symbol(),Period(),1)+Period()/10*Point);   
 }
TakeProfit=TakeMA*Dec*Point;StopLoss=StopMA*Dec*Point;
SellMarketOrdOpen(Red,Magic);} 

if (Rules()==3 && ScanTradesOpen(Magic+1)==0 && UseStochastic)
  {
   if (!IsOptimization())
 {
         ObjectCreate("BB"+TimeCurrent(), OBJ_ARROW,0,0,0,0,0);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_COLOR, DeepSkyBlue);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_ARROWCODE, 233);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_TIME1,TimeCurrent()-Period());
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_PRICE1,iLow(Symbol(),Period(),1));   
 }
TakeProfit=TakeStochastic*Dec*Point;StopLoss=StopStochastic*Dec*Point;
 BuyMarketOrdOpen(DeepSkyBlue,Magic+1);}

  if (Rules()==4 && ScanTradesOpen(Magic+1)==0 && UseStochastic)
  {
   if (!IsOptimization())
 {
         ObjectCreate("BB"+TimeCurrent(), OBJ_ARROW,0,0,0,0,0);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_COLOR, Salmon);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_ARROWCODE, 234);
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_TIME1,TimeCurrent()-Period());
         ObjectSet   ("BB"+TimeCurrent(), OBJPROP_PRICE1,iHigh(Symbol(),Period(),1)+Period()/10*Point);   
 }
TakeProfit=TakeStochastic*Dec*Point;StopLoss=StopStochastic*Dec*Point;
SellMarketOrdOpen(Salmon,Magic+1);}       
}
LastVol=Volume[0];  

}

 
int Rules() ////////////////////////////////////////////////
{

if (ADX1>ADXLevel && ADX1>ADX2 && DPLUS>DMINUS && iClose(Symbol(),Period(),1)>MA) return(1);
if (ADX1>ADXLevel && ADX1>ADX2 && DPLUS<DMINUS && iClose(Symbol(),Period(),1)<MA) return(2);
if (SM2<SS2 && SM1>SS1 && SM1<BuyLevel && ADX1<ADXLevel) return(3);
if (SM2>SS2 && SM1<SS1 && SM1>SellLevel && ADX1<ADXLevel) return(4);


return(0);
}


//Money Management
double MoneyManagement ( bool flag, double risk)
{
   double Lotsi=Lots;
	    
   if ( flag ) Lotsi=NormalizeDouble(AccountFreeMargin()*risk/1000,2);   
   if (Lotsi<0.01) Lotsi=0.01;  
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


// ---- Scan Trades opened
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


void CloseByMA(int Magic)
{
    int total=OrdersTotal();
    int CloseBar, try;
    double CloseLot, BodyPriceHigh, BodyPriceLow;
    bool result = false;

    for (int cnt=total-1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);     
           
        if (OrderMagicNumber()==Magic && OrderType()==OP_BUY && iClose(Symbol(),Period(),1)<MA)     
        {

 for (try=1;try<=MaxTries;try++)
       {		 
          RefreshRates();
          result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid ,digit),5*Dec,Yellow);
         break;}           
          if(!result) Print("OrderSend failed with error #",GetLastError(), " Try ", try);                                     
          if (try==MaxTries) {Print("Warning!!!Last try failed!");
          Sleep(5000);
        }
       }
        if (OrderMagicNumber()==Magic && OrderType()==OP_SELL && iClose(Symbol(),Period(),1)>MA)     
        {
 
 for (try=1;try<=MaxTries;try++)
       {		 
          RefreshRates();  
          result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask ,digit),5*Dec,Yellow);
          if(result) break;          
          if(!result) Print("OrderSend failed with error #",GetLastError(), " Try ", try);                                    
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
          Sleep(5000);
        }
       }
      } 
     
  return;
  }


void TrailStops(int Magic)
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
           if(OrderStopLoss()<OrderOpenPrice() && NormalizeDouble(Ask,digit)-OrderOpenPrice()>Point*TS*Dec)
               {
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask,digit)-TralStep*Dec*Point,OrderTakeProfit(),0,Green);
         return(0);
        } 
           if(OrderStopLoss()>OrderOpenPrice() && NormalizeDouble(Ask,digit)-OrderStopLoss()>Point*TralStep*Dec)
               {
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask,digit)-TralStep*Dec*Point,OrderTakeProfit(),0,Green);
         return(0);
        }        
            }
             
           if ( mode==OP_SELL)
            {
            if((OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0) && OrderOpenPrice()-NormalizeDouble(Bid,digit)>Point*TS*Dec)
            {
           OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid,digit)+TralStep*Dec*Point,OrderTakeProfit(),0,Green);
           return(0);
            }
            if(OrderStopLoss()<OrderOpenPrice()  && OrderStopLoss()-NormalizeDouble(Bid,digit)>Point*TralStep*Dec)
            {
           OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid,digit)+TralStep*Dec*Point,OrderTakeProfit(),0,Green);
           return(0);
            }
        }    
        }
    }   
}

