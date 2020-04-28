//+------------------------------------------------------------------+
//|                                                    CandleBot.mq4 |
//|                                              forex-way@yandex.ru |
//|                                              http://wellforex.ru |
//-------------------------------------------------------------------+

#property copyright "Copyright © 2010, http://wellforex.ru"
#property link      "forex-way@yandex.ru"
extern  int     Magic=10012;                  //Магический номер для одновременной торговли на разных парах
extern double   Lots = 0.1;                   //Фиксированный лот
extern bool     MM=false;                     //Включение ММ 
extern double   MMRisk=0.03;                  //Риск-фактор, процент депозита при расчёте лота
extern bool     UseTime       = false;        //Использовать время да/нет
extern string   TimeStart  = "08:00";         //Время начала торговли
extern string   TimeEnd    = "15:00";         //Время окончания торговли
extern int      StopLoss=40;                  //Стоплосс, 0-без стоплосса
extern int      TakeProfit=70;                //Тейкпрофит,0-без тейкпрофита
extern bool     Tral=false;                      //Трейлинг-стоп вкл/выкл
extern int      TralStartLevel=30;             //Профит включения трейлинг-стопа 
extern int      TralStop=40;                    //Уровень трейлинг-стопа 
extern bool     DrawInfo=false;                  //Вывод информации-комментариев на график вкл/выкл

extern string   C12="----------  Candles -------------";
extern bool Hammer=true;//Молот
extern bool HangingMan=true;//Повешенный
extern bool Engulfing =true; //Модель Поглощения 
extern bool MorningStar=true;//Утренняя звезда
extern bool EveningStar=true;//Вечерняя звезда
extern bool DarkCloudCover=true;//Завеса из темных облаков
extern bool Piercing=true;//Просвет в облаках
extern bool ShootingStar=true;//Падающая Звезда
extern bool InvertedHammer=true;//Перевернутый Молот
extern bool Harami=true;//Харами
extern bool Tweezer=true;//Вершины и Основания "Пинцет"
extern bool BeltHoldLine=true;//Захват за пояс 
extern bool UpsideGapTwoCrows=true;//Две взлетевшие вороны 
extern bool ThreeCrows=true;//Три вороны
extern bool MatHoldPattern=true;//Удержание на татами
extern bool CounterattackLines=true;//Контратака
extern bool SeparatingLines=true;//Разделение 
extern bool GravestoneDoji=true;//Доджи-надгробие
extern bool LongLeggedDoji=true;//Длинноногий доджи
extern bool Doji=true;//Доджи (Харами крест)
extern bool TasukiGap=true;//Разрыв тасуки
extern bool SideBySideWhite=true;//Смежные белые свечи
extern bool ThreeMethods=true;//Три метода
extern bool Gap=true;//Окно
extern bool ThreeWhiteSoldiers=true;//Три белых солдата 
extern bool AdvanceBlock=true;//Отбитое наступление 
extern bool StalledPattern=true;//Торможение 
extern bool ThreeLineStrike=true;//Тройной удар
extern bool OnNeckLine=true;//У линии шеи 
        
bool  UseSound  = True;  // Использовать звуковой сигнал да/нет              
int  MaxTries=5, Dec, LastOrderType=0;
int   i, cnt=0, ticket, mode=0, digit=0, total, OrderToday=0;
double  Lotsi=0,  spread;
int LastVol;
string  name="CandleBot";
string SoundSuccess   = "alert.wav";      // Звук успеха
string SoundError     = "timeout.wav";    // Звук ошибки
double BuyProfit=0, SellProfit=0, BuyPrice, SellPrice, BuyStop, SellStop, LastOrderLot, LastOrderBuyPrice, LastOrderSellPrice;
datetime t1, t2, t3;
bool CloseStop=false;   
string TralOn="Off";
string Text;
int CandleBuy=0, CBuy=0;
int CandleSell=0, CSell=0;
   
int init()
  {
DrawLogo2();

 return(0);
  }

void deinit() 
{

}

int start()
{
  t1=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE)+" "+TimeStart);
  t2=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE)+" "+TimeEnd);
   digit  = MarketInfo(Symbol(),MODE_DIGITS); 

   if (digit==5 || digit==3) Dec=10;
   if (digit==4 || digit==2) Dec=1; 
   Lotsi=Lots;
   if (MM) Lotsi=NormalizeDouble(AccountBalance()*MMRisk/100,2);   
   if (Lotsi<MarketInfo(Symbol(), MODE_MINLOT)) Lotsi=MarketInfo(Symbol(), MODE_MINLOT);  
   spread= MarketInfo(Symbol(),MODE_SPREAD);

if (DrawInfo) 
{
Comment(" ",   
        "   \n------------------------------------------------------------------",
        "   \nAccountNumber : ",DoubleToStr(AccountNumber(),0), 
        "   \n",TerminalCompany(), 
        "   \nCurrent Server Time : " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS),
        "   \n------------------------------------------------------------------",               
        "   \nLot = ", DoubleToStr(Lotsi,2)," / Take = ",DoubleToStr(TakeProfit,0),
        "   \nWorkTime = ", TimeStart," - ",TimeEnd, " / Stop = ",DoubleToStr(StopLoss,0),
        "   \nCurrent spread = ",spread,
        "   \nMinLot on symbol = ",DoubleToStr(MarketInfo(Symbol(),MODE_MINLOT), 2)," / Tral - ",TralOn,
        "   \n------------------------------------------------------------------"); 
}

if (Tral) {TralOn="On"; TrailStops(Magic);}
              
if (Volume[0]<=10 && (Volume[0]<LastVol || Volume[0]==1))
{

Text=" ";
CandleBuy=-1; CBuy=-1;
CandleSell=-1; CSell=-1;
Condition(0);
if (HangingMan && Text=="Повешенный") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Hammer && Text=="Молот") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (MorningStar && Text=="Утренняя звезда") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (EveningStar && Text=="Вечерняя звезда") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Engulfing && Text=="Поглощение" && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Engulfing && Text=="Поглощение" && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (DarkCloudCover && Text=="Завеса из облаков") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Piercing && Text=="Просвет в облаках") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (ShootingStar && Text=="Падающая Звезда") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (InvertedHammer && Text=="Перевёрнутый Молот") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Harami && Text=="Харами" && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Harami && Text=="Харами" && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Tweezer && Text=="Вершина Пинцет") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Tweezer && Text=="Основание Пинцет") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (BeltHoldLine && Text=="Захват за пояс"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (BeltHoldLine && Text=="Захват за пояс"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (UpsideGapTwoCrows && Text=="Две взлетевшие вороны") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeCrows && Text=="Три вороны") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (MatHoldPattern && Text=="Удержание на татами") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (CounterattackLines && Text=="Контратака"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (CounterattackLines && Text=="Контратака" && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (SeparatingLines && Text=="Разделение"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (SeparatingLines && Text=="Разделение"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (GravestoneDoji && Text=="Доджи-надгробие") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (LongLeggedDoji && Text=="Длинноногий доджи"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (LongLeggedDoji && Text=="Длинноногий доджи"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (Doji && Text=="Доджи поглощения"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (Doji && Text=="Доджи поглощения"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (TasukiGap && Text=="Разрыв Тасуки"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (TasukiGap && Text=="Разрыв Тасуки"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (SideBySideWhite && Text=="Смежные белые свечи"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (SideBySideWhite && Text=="Смежные белые свечи"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeMethods && Text=="Три метода"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeMethods && Text=="Три метода"  &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (Gap && Text=="Окно" &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (Gap && Text=="Окно" && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeWhiteSoldiers && Text=="Три белых солдата") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}   
if (AdvanceBlock && Text=="Отбитое наступление") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (StalledPattern && Text=="Торможение") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}   
if (ThreeLineStrike && Text=="Тройной удар"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}    
if (ThreeLineStrike && Text=="Тройной удар" &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (OnNeckLine && Text=="У линии шеи"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}    
if (OnNeckLine && Text=="У линии шеи" &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}   

if (UseTime && (TimeCurrent()<t1 || TimeCurrent()>=t2)) return;

if(ScanTradesOpen(Magic)==0 && CBuy>0) 
{
PlaySound("news.wav");  
BuyOpen(Blue,Magic);
}

if(ScanTradesOpen(Magic)==0 && CSell>0)
{
PlaySound("news.wav");  
SellOpen(Red,Magic);
}

}
LastVol=Volume[0];  

}

   
void BuyOpen(int ColorOfBuy,int Magic)
  {
  int try, res;
  int try2, res2;
  bool result=false;
  double SSL=0, TTP=0;
  
  if (StopLoss>0) SSL=NormalizeDouble(Bid ,digit)-StopLoss*Dec*Point;  
  if (TakeProfit>0) TTP=NormalizeDouble(Ask ,digit)+TakeProfit*Dec*Point;                
  for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();		  
      res=OrderSend(Symbol(),OP_BUY,Lotsi,NormalizeDouble(Ask ,digit),2*Dec,0,0,name+" ("+Symbol()+")",Magic,0,ColorOfBuy);
      Sleep(2000);
      if(res>0)
           {
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) 
            {
       for (try2=1;try2<=MaxTries;try2++)
       {		 
          while (!IsTradeAllowed()) Sleep(2000);
          RefreshRates();
          if (TakeProfit==0) break;
          result = OrderModify(OrderTicket(),OrderOpenPrice(),SSL,TTP,0,Green);
          if(result) break;
          if(!result) Print("OrderModify Buy failed with error #",GetLastError());                           
          Sleep(5000);
        }
         PlaySound("news.wav");            
         break;   
            }
            }
         else 
         {
         Print("Error opening BUY order : ",GetLastError()); PlaySound("timeout.wav"); Sleep(5000);
         }     
       }
      return;
      }

void SellOpen(int ColorOfSell,int Magic)      
      { 
  int try, res;
  int try2, res2;
  bool result=false;  
  double SSL=0, TTP=0; 
  if (StopLoss>0) SSL=NormalizeDouble(Ask ,digit)+StopLoss*Dec*Point;  
  if (TakeProfit>0) TTP=NormalizeDouble(Bid ,digit)-TakeProfit*Dec*Point;       
  for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();		  
      res=OrderSend(Symbol(),OP_SELL,Lotsi,NormalizeDouble(Bid ,digit),2*Dec,0,0,name+" ("+Symbol()+")",Magic,0,ColorOfSell);
      Sleep(2000);
      if(res>0)
           {
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) 
            {
       for (try2=1;try2<=MaxTries;try2++)
       {		 
          while (!IsTradeAllowed()) Sleep(2000);
          RefreshRates();
          if (TakeProfit==0) break;
          result = OrderModify(OrderTicket(),OrderOpenPrice(),SSL,TTP,0,Green);
          if(result) break;
          if(!result) Print("OrderModify Sell failed with error #",GetLastError());                           
          Sleep(5000);
        } 
         PlaySound("news.wav");          
         break;   
            }
            }
         else 
         {
         Print("Error opening SELL order : ",GetLastError()); PlaySound("timeout.wav"); Sleep(5000);
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
   {
   LastOrderLot=OrderLots();
   if (OrderType()==OP_BUY) LastOrderType=1;
   if (OrderType()==OP_SELL) LastOrderType=2;
   numords++;
   }
   }
   return(numords);
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
            if(NormalizeDouble(Ask-OrderOpenPrice(),Digits)>Point*TralStartLevel*Dec && NormalizeDouble(Ask-OrderStopLoss(),Digits)>Point*TralStop*Dec)
               {
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask-TralStop*Dec*Point,Digits),OrderTakeProfit(),0,Green);
         return(0);
        }        
            }
             
           if ( mode==OP_SELL)
            {
            if(NormalizeDouble(OrderOpenPrice()-Bid,Digits)>Point*TralStartLevel*Dec && (NormalizeDouble(OrderStopLoss()-Bid,Digits)>Point*TralStop*Dec || OrderStopLoss()==0))
            {
           OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid+TralStop*Dec*Point,Digits),OrderTakeProfit(),0,Green);
           return(0);
            }
        }    
        }
    }   
}

//******************************************************************************

double GetUpperShadowHeight(int ai_0) {
   return (MathAbs(High[ai_0] - MathMax(Close[ai_0], Open[ai_0])));
}

double GetLowerShadowHeight(int ai_0) {
   return (MathAbs(MathMin(Close[ai_0], Open[ai_0]) - Low[ai_0]));
}

double GetBodyHeight(int ai_0) {
   return (MathAbs(Close[ai_0] - Open[ai_0]));
}

double GetAllHeight(int ai_0) {
   return (MathAbs(High[ai_0] - Low[ai_0]));
}

bool IsHigher(int ai_0) {
   if (High[ai_0] >= High[ai_0 + 1] + 2.0 * Point && High[ai_0] >= High[ai_0 + 2] + 2.0 * Point && High[ai_0] >= High[ai_0 + 3] + 2.0 * Point) return (TRUE);
   return (FALSE);
}

bool IsLower(int ai_0) {
   if (Low[ai_0] + 2.0 * Point*Dec < Low[ai_0 + 1] && Low[ai_0] + 2.0 * Point*Dec < Low[ai_0 + 2] && Low[ai_0] + 2.0 * Point*Dec < Low[ai_0 + 3]) return (TRUE);
   return (FALSE);
}


int IsYing(int ai_0) {
   if (Close[ai_0] < Open[ai_0]) return (1);
   return (0);
}

int IsYang(int ai_0) {
   if (Close[ai_0] > Open[ai_0]) return (1);
   return (0);
}


double GetLowCloseOpen(int ai_0) {
   return (MathMin(Close[ai_0], Open[ai_0]));
}

double GetHighCloseOpen(int ai_0) {
   return (MathMax(Close[ai_0], Open[ai_0]));
}

int AlmostSameBodyHeight(int ai_0, int ai_4) {
   if (MathAbs(GetBodyHeight(ai_0) - GetBodyHeight(ai_4)) < 5.0 * Point*Dec) return (1);
   return (0);
}

void CreateTextObject(int a_datetime_0, double a_price_4, color a_color_12, string a_text_16) {
   string l_name_24;
   l_name_24=TimeToStr(TimeCurrent());

if (CandleSell>0)
{
   ObjectCreate(l_name_24, OBJ_ARROW,0,0,0,0,0);
   ObjectSet   (l_name_24, OBJPROP_COLOR, Pink);
   ObjectSet   (l_name_24, OBJPROP_ARROWCODE, 234);
   ObjectSet   (l_name_24, OBJPROP_TIME1,Time[1]);
   ObjectSet   (l_name_24, OBJPROP_PRICE1,High[1]+Period()*Dec*Point/2);
   ObjectCreate(l_name_24+"T", OBJ_TEXT, 0, a_datetime_0, High[1]+Period()*Dec*Point);
   ObjectSetText(l_name_24+"T", a_text_16, 7);

   ObjectSet(l_name_24+"T", OBJPROP_COLOR, Yellow);
}
if (CandleBuy>0)
{
   ObjectCreate(l_name_24, OBJ_ARROW,0,0,0,0,0);
   ObjectSet   (l_name_24, OBJPROP_COLOR, DeepSkyBlue);
   ObjectSet   (l_name_24, OBJPROP_ARROWCODE, 233);
   ObjectSet   (l_name_24, OBJPROP_TIME1,Time[1]);
   ObjectSet   (l_name_24, OBJPROP_PRICE1,Low[1]-Period()*Dec*Point/2);
   ObjectCreate(l_name_24+"T", OBJ_TEXT, 0, a_datetime_0, Low[1]-Period()*Dec*Point);
   ObjectSetText(l_name_24+"T", a_text_16, 7);
   ObjectSet(l_name_24+"T", OBJPROP_COLOR, Yellow);
}      
}

bool IsHammer(int ai_0) {
   if (GetAllHeight(ai_0) >= 10.0 * Point*Dec && GetUpperShadowHeight(ai_0) < GetAllHeight(ai_0) / 5.0 && GetLowerShadowHeight(ai_0) > 2.0 * GetBodyHeight(ai_0) && GetUpperShadowHeight(ai_0) > 0.0 * Point*Dec)
      if (IsLower(ai_0)) return (TRUE);
   return (FALSE);
}

bool IsHangMan(int ai_0) {
   if (GetAllHeight(ai_0) >= 10.0 * Point*Dec && GetUpperShadowHeight(ai_0) < GetAllHeight(ai_0) / 5.0 && GetLowerShadowHeight(ai_0) > 1.0 * GetBodyHeight(ai_0))
      if (IsHigher(ai_0)) return (TRUE);
   return (FALSE);
}

bool IsDoji(int ai_0) {
   if (MathAbs(Open[ai_0] - Close[ai_0]) < 3.0 * Point) return (TRUE);
   return (FALSE);
}

bool IsInvertHammer(int ai_0) {
   if (GetLowerShadowHeight(ai_0) < GetAllHeight(ai_0) / 5.0) {
      if (GetUpperShadowHeight(ai_0) > 2.0 * GetBodyHeight(ai_0))
         if (IsLower(ai_0)) return (TRUE);
   }
   return (FALSE);
}

bool IsInvertHammerCFM(int ai_unused_0) {
   return (FALSE);
}

bool IsThree_Crows(int ai_0) {
   if (High[ai_0 + 1] > High[ai_0 + 2] && IsYing(ai_0 + 2) && IsYing(ai_0 + 1) && IsYing(ai_0) && Open[ai_0 + 1] < Open[ai_0 + 2] && Close[ai_0 +
      1] < Close[ai_0 + 2] && Open[ai_0] < Open[ai_0 + 1] && Close[ai_0] < Close[ai_0 + 1]) return (TRUE);
   return (FALSE);
}

bool IsThree_White_Soldiers(int ai_0) {
   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2] && GetUpperShadowHeight(ai_0+1) < 10.0*Dec*Point && GetUpperShadowHeight(ai_0+2) < 10.0*Dec*Point && GetUpperShadowHeight(ai_0+3) < 10.0*Dec*Point && AlmostSameBodyHeight(ai_0 + 3, ai_0 + 2) && AlmostSameBodyHeight(ai_0 + 2, ai_0 + 1)) return (TRUE);
   return (FALSE);
}

int Condition(int ai_0) {
   int l_count_4;
   if (!IsDoji(ai_0 + 2)) {
      if (IsYang(ai_0 + 2) != IsYang(ai_0 + 1)) {
         if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMin(Close[ai_0 + 2], Open[ai_0 +2])) 
         {
            if (IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) {Text="Поглощение"; CandleBuy=1;return(0);}
            if (IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) {Text="Поглощение"; CandleSell=1;return(0);}
            if (GetBodyHeight(ai_0 + 2) >= 15.0 * Point*Dec || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) {Text="Поглощение"; CandleBuy=1;return(0);}
            if (GetBodyHeight(ai_0 + 2) >= 15.0 * Point*Dec || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) {Text="Поглощение"; CandleSell=1;return(0);}
         }
      }
   }
   if (IsDoji(ai_0 + 2)) {
      if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMin(Close[ai_0 + 2], Open[ai_0 +2])) 
      {
         if (IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) Text="Доджи поглощение бай";
         if (IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) Text="Доджи поглощение селл";
      }
   }
   if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec && Open[ai_0 + 1] > High[ai_0 + 2] && Close[ai_0 + 1] < Open[ai_0 +
      2] + (Close[ai_0 + 2] - (Open[ai_0 + 2])) / 2.0 && GetLowCloseOpen(ai_0 + 1) > GetLowCloseOpen(ai_0 + 2)) {Text="Завеса из облаков"; CandleSell=1; return(0);}
   if (MathAbs(Close[ai_0 + 2] - (Open[ai_0 + 2])) > 15.0 * Point*Dec) {
      if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMin(Close[ai_0 + 2], Open[ai_0 +
         2])) {
         if ((IsYang(ai_0 + 2) && IsHigher(ai_0 + 2)) || (IsYang(ai_0 + 2) )) {Text="Харами"; CandleSell=1; return(0);}
         if ((IsYing(ai_0 + 2) && IsLower(ai_0 + 2)) || (IsYing(ai_0 + 2) )) {Text="Харами"; CandleBuy=1; return(0);}
      }
   }
   
   if (IsHammer(ai_0 + 1)) {Text="Молот"; CandleBuy=1;return(0);}
   if (IsHangMan(ai_0 + 1)) {Text="Повешенный"; CandleSell=1; return(0);}
   if (IsInvertHammer(ai_0 + 1)) {Text="Перевёрнутый Молот"; CandleBuy=1; return(0);}
   if (IsInvertHammerCFM(ai_0 + 1)) {Text="Перевёрнутый Молот"; CandleBuy=1; return(0);}
   if (IsYang(ai_0 + 1) && IsYing(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec && Open[ai_0 + 1] < Low[ai_0 + 2] && Close[ai_0 + 1] > Close[ai_0 + 2] + (Open[ai_0 +
      2] - (Close[ai_0 + 2])) / 2.0 && GetHighCloseOpen(ai_0 + 1) < GetHighCloseOpen(ai_0 + 2)) {Text="Просвет в облаках"; CandleBuy=1; return(0);}
   if (IsYing(ai_0 + 3) && IsYang(ai_0 + 1) && IsLower(ai_0 + 3)) {
      if (GetLowCloseOpen(ai_0 + 3) > GetHighCloseOpen(ai_0 + 2) || GetLowCloseOpen(ai_0 + 1) > GetHighCloseOpen(ai_0 + 2) && GetHighCloseOpen(ai_0 + 1) > GetLowCloseOpen(ai_0 +
         3) && GetBodyHeight(ai_0 + 2) <= 10.0 * Point*Dec && GetBodyHeight(ai_0 + 3) >= 8.0 * Point*Dec && GetBodyHeight(ai_0 + 1) >= 8.0 * Point*Dec) {Text="Утренняя звезда"; CandleBuy=1;return(0);}
   }
   if (IsYang(ai_0 + 3) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 3)) {
      if (GetHighCloseOpen(ai_0 + 3) < GetLowCloseOpen(ai_0 + 2) || GetHighCloseOpen(ai_0 + 1) < GetLowCloseOpen(ai_0 + 2) && GetLowCloseOpen(ai_0 + 1) < GetHighCloseOpen(ai_0 +
         3) && GetBodyHeight(ai_0 + 2) <= 10.0 * Point*Dec && GetBodyHeight(ai_0 + 3) > 8.0 * Point*Dec && GetBodyHeight(ai_0 + 1) > 8.0 * Point*Dec) {Text="Вечерняя звезда";  CandleSell=1;return(0);}
   }
   if (GetLowerShadowHeight(ai_0 + 1) < GetAllHeight(ai_0 + 1) / 5.0) {
      if (GetUpperShadowHeight(ai_0 + 1) > 2.0 * GetBodyHeight(ai_0 + 1))
         if (IsHigher(ai_0 + 1)) {Text="Падающая Звезда";  CandleSell=1; return(0);}
   }
   if (IsHigher(ai_0 + 2) && High[ai_0 + 2] == High[ai_0 + 1] || High[ai_0 + 3] == High[ai_0 + 1] || High[ai_0 +
      4] == High[ai_0 + 1]) {Text="Вершина Пинцет"; CandleSell=1; return(0);}
   if (IsLower(ai_0 + 2) && Low[ai_0 + 2] == Low[ai_0 + 1] || Low[ai_0 + 3] == Low[ai_0 + 1] || Low[ai_0 +
      4] == Low[ai_0 + 1]) {Text="Основание Пинцет"; CandleBuy=1; return(0);}
 
   if (GetBodyHeight(ai_0 + 1) >= 10.0 * Point*Dec && IsYang(ai_0 + 1) && GetLowerShadowHeight(ai_0+1) == 0.0 && GetBodyHeight(ai_0 + 1) > GetAllHeight(ai_0 +
      1) / 2.0) {Text="Захват за пояс";  CandleBuy=1; return(0);}
   if (GetBodyHeight(ai_0 + 1) >= 10.0 * Point*Dec && IsYing(ai_0 + 1) && GetUpperShadowHeight(ai_0+1) == 0.0 && GetBodyHeight(ai_0 + 1) > GetAllHeight(ai_0 +
      1) / 2.0) {Text="Захват за пояс";  CandleSell=1; return(0);}

   if (IsHigher(ai_0 + 3) && IsYang(ai_0 + 3) && IsYing(ai_0 + 2) && IsYing(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] && Open[ai_0 + 1] > Open[ai_0 + 2] && Close[ai_0 +
      1] < Close[ai_0 + 2] && GetLowCloseOpen(ai_0 + 1) > GetHighCloseOpen(ai_0 + 3) && GetLowCloseOpen(ai_0 + 2) > GetHighCloseOpen(ai_0 + 3)) {Text="Две взлетевшие вороны";  CandleSell=1;return(0);}
   if (IsYang(ai_0 + 5) && IsYing(ai_0 + 4) && IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 4] < Close[ai_0 + 1] &&
      GetBodyHeight(ai_0 + 5) >= 5.0 * Point*Dec && GetBodyHeight(ai_0 + 1) >= 5.0 * Point*Dec) {Text="Удержание на татами";  CandleBuy=1; return(0);}
   if (IsThree_Crows(ai_0 + 1)) {Text="Три вороны"; CandleSell=1; return(0);}
   if (GetBodyHeight(ai_0 + 1) > 5.0 * Point && GetBodyHeight(ai_0 + 2) > 5.0 * Point) {
      if (IsHigher(ai_0 + 1) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && GetHighCloseOpen(ai_0 + 1) - GetHighCloseOpen(ai_0 + 2) >= 2.0 * Point*Dec && Close[ai_0 + 2] > Close[ai_0 + 1] && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec) {Text="Контратака";  CandleSell=1; return(0);}
      if (IsLower(ai_0 + 1) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && GetLowCloseOpen(ai_0 + 2) - GetLowCloseOpen(ai_0 + 1) >= 2.0 * Point*Dec && Close[ai_0 + 2] < Close[ai_0 + 1] && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec) {Text="Контратака";  CandleBuy=1; return(0);}
   }
   if (GetBodyHeight(ai_0 + 1) > 5.0 * Point && GetBodyHeight(ai_0 + 2) > 5.0 * Point) {
      if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && Open[ai_0 + 2] - (Open[ai_0 + 1]) >= -2.0 * Point*Dec && GetBodyHeight(ai_0 + 2) >= 2.0 * Point*Dec) {Text="Разделение"; CandleSell=1; return(0);}
      if (IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 1] - (Open[ai_0 + 2]) >= -2.0 * Point*Dec && GetBodyHeight(ai_0 + 2) >= 2.0 * Point*Dec) {Text="Разделение";  CandleBuy=1; return(0);}
   }
   if (Close[ai_0 + 1] == Open[ai_0 + 1] && GetLowerShadowHeight(ai_0+1) == 0.0) {Text="Доджи-надгробие"; CandleSell=1; return(0);}
   
   if (IsHigher(ai_0 + 1) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 2.0 * Point*Dec && GetAllHeight(ai_0 + 1) > 10.0 * Point*Dec && High[ai_0 + 1] > High[ai_0 + 2]) {Text="Длинноногий доджи"; CandleSell=1; return(0);}
   if (IsLower(ai_0 + 1) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 2.0 * Point*Dec && GetAllHeight(ai_0 + 1) > 10.0 * Point*Dec && Low[ai_0 + 1] < Low[ai_0 + 2]) {Text="Длинноногий доджи"; CandleBuy=1; return(0);}
  
   if (GetBodyHeight(ai_0 + 2) > 10.0 * Point*Dec && IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYang(ai_0 + 2) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 1.0 * Point*Dec) {Text="Доджи поглощения"; CandleSell=1; return(0);}
   if (GetBodyHeight(ai_0 + 2) > 10.0 * Point*Dec && IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYing(ai_0 + 2) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 1.0 * Point*Dec) {Text="Доджи поглощения"; CandleBuy=1; return(0);}
      
   if (IsHigher(ai_0 + 3) || IsHigher(ai_0 + 2) && (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1))  && Low[ai_0 +
      1] - (Low[ai_0 + 3]) >= 2.0 * Point && Open[ai_0 + 2] - (Close[ai_0 + 3]) > 0.1 * Point*Dec && Close[ai_0 + 1] < Open[ai_0 + 2] && MathAbs(GetBodyHeight(ai_0 +
      1) - GetBodyHeight(ai_0 + 2)) < 5.0 * Point*Dec) {Text="Разрыв Тасуки";   CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 3) || IsLower(ai_0 + 2) && (IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1))  && High[ai_0 +
      3] - (High[ai_0 + 1]) >= 2.0 * Point && Close[ai_0 + 3] - (Open[ai_0 + 2]) > 0.1 * Point*Dec && Close[ai_0 + 1] > Open[ai_0 + 2] && MathAbs(GetBodyHeight(ai_0 +
      1) - GetBodyHeight(ai_0 + 2)) < 5.0 * Point*Dec) {Text="Разрыв Тасуки"; CandleSell=1; return(0);}

   if (IsHigher(ai_0 + 3) && (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1))  && MathAbs(Open[ai_0 + 1] - Open[ai_0 +
      2]) < 3.0 * Point*Dec && MathAbs(GetBodyHeight(ai_0 + 1) - GetBodyHeight(ai_0 + 2)) < 10.0 * Point*Dec) {Text="Смежные белые свечи"; CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 3) && (IsYing(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1))  && MathAbs(Open[ai_0 + 1] - Open[ai_0 +
      2]) < 3.0 * Point*Dec && MathAbs(GetBodyHeight(ai_0 + 1) - GetBodyHeight(ai_0 + 2)) < 10.0 * Point*Dec) {Text="Смежные белые свечи"; CandleSell=1; return(0);}
      
   if (IsHigher(ai_0 + 5) && IsYang(ai_0 + 5) && IsYang(ai_0 + 1) && IsYing(ai_0 + 2) && IsYing(ai_0 + 3) && IsYing(ai_0 + 4) && GetBodyHeight(ai_0 + 5) > 5.0 * Point &&
      GetBodyHeight(ai_0 + 1) > 5.0 * Point*Dec && Open[ai_0 + 5] < Close[ai_0 + 1]) {Text="Три метода"; CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 5) && IsYing(ai_0 + 5) && IsYing(ai_0 + 1) && IsYang(ai_0 + 2) && IsYang(ai_0 + 3) && IsYang(ai_0 + 4) && GetBodyHeight(ai_0 + 5) > 5.0 * Point &&
      GetBodyHeight(ai_0 + 1) > 5.0 * Point*Dec && Open[ai_0 + 5] > Close[ai_0 + 1]) {Text="Три метода";  CandleSell=1; return(0);}
          
   if (IsHigher(ai_0 + 1) && IsYang(ai_0 + 1) && IsYang(ai_0 + 2) && Open[ai_0 + 1] - (Close[ai_0 + 2]) >= 1 * Point*Dec) {Text="Окно"; CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 1) && IsYing(ai_0 + 1) && IsYing(ai_0 + 2) && Close[ai_0 + 2] - (Open[ai_0 + 1]) >= 1 * Point*Dec) {Text="Окно"; CandleSell=1; return(0);}


   if (IsThree_White_Soldiers(ai_0)) {Text="Три белых солдата"; CandleBuy=1; return(0);}
   
   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2]  && GetBodyHeight(ai_0 + 3) > GetBodyHeight(ai_0 + 2) && GetBodyHeight(ai_0 + 2) > GetBodyHeight(ai_0 + 1)) {Text="Отбитое наступление"; CandleSell=1; return(0);}

   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2] && GetBodyHeight(ai_0 + 3) < GetBodyHeight(ai_0 + 2)/2 && GetBodyHeight(ai_0 + 1) < GetBodyHeight(ai_0 + 2)/2) {Text="Торможение";  CandleSell=1; return(0);}
      
     
   if (IsYang(ai_0 + 1) && IsThree_Crows(ai_0 + 2) && Close[ai_0 + 1] > Open[ai_0 + 2]) {Text="Тройной удар"; CandleSell=1; return(0);}
   if (IsYing(ai_0 + 1) && IsThree_White_Soldiers(ai_0 + 1) && Close[ai_0 + 1] < Open[ai_0 + 2]) {Text="Тройной удар"; CandleBuy=1; return(0);}
   
   if (IsYing(ai_0 + 2) && IsYang(ai_0 + 1)  && Close[ai_0 + 1] < Open[ai_0 + 2] - (Open[ai_0 + 2] - (Close[ai_0 +
      2])) / 2.0 && Open[ai_0 + 1] < GetLowCloseOpen(ai_0 + 2)) {Text="У линии шеи";  CandleSell=1; return(0);}
   if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1)  && Close[ai_0 + 1] > Open[ai_0 + 2] + (Close[ai_0 + 2] - (Open[ai_0 +
      2])) / 2.0 && Open[ai_0 + 1] > GetHighCloseOpen(ai_0 + 2)) {Text="У линии шеи";  CandleBuy=1; return(0);}      

   return (0);
}

void DrawLogo2() {
  int stt=15;

   string l_name_8 = "Logo" + "10";
   l_name_8 = "Logo" + "11";
   if (ObjectFind(l_name_8) == -1) {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 3);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 5);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 5);
   }
   ObjectSetText(l_name_8, "http://wellforex.ru", 8, "Verdana", Silver);


   l_name_8 = "Logo" + "12";
   if (ObjectFind(l_name_8) == -1) {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 3);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 5);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 20);
   }
   ObjectSetText(l_name_8, "WELLFOREX", 10, "Verdana", Red);


}