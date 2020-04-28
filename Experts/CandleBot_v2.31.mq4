//+------------------------------------------------------------------+
//|                                                    CandleBot.mq4 |
//|                                              forex-way@yandex.ru |
//|                                              http://wellforex.ru |
//-------------------------------------------------------------------+

#property copyright "Copyright � 2010, http://wellforex.ru"
#property link      "forex-way@yandex.ru"
extern  int     Magic=10012;                  //���������� ����� ��� ������������� �������� �� ������ �����
extern double   Lots = 0.1;                   //������������� ���
extern bool     MM=false;                     //��������� �� 
extern double   MMRisk=0.03;                  //����-������, ������� �������� ��� ������� ����
extern bool     UseTime       = false;        //������������ ����� ��/���
extern string   TimeStart  = "08:00";         //����� ������ ��������
extern string   TimeEnd    = "15:00";         //����� ��������� ��������
extern int      StopLoss=40;                  //��������, 0-��� ���������
extern int      TakeProfit=70;                //����������,0-��� �����������
extern bool     Tral=false;                      //��������-���� ���/����
extern int      TralStartLevel=30;             //������ ��������� ��������-����� 
extern int      TralStop=40;                    //������� ��������-����� 
extern bool     DrawInfo=false;                  //����� ����������-������������ �� ������ ���/����

extern string   C12="----------  Candles -------------";
extern bool Hammer=true;//�����
extern bool HangingMan=true;//����������
extern bool Engulfing =true; //������ ���������� 
extern bool MorningStar=true;//�������� ������
extern bool EveningStar=true;//�������� ������
extern bool DarkCloudCover=true;//������ �� ������ �������
extern bool Piercing=true;//������� � �������
extern bool ShootingStar=true;//�������� ������
extern bool InvertedHammer=true;//������������ �����
extern bool Harami=true;//������
extern bool Tweezer=true;//������� � ��������� "������"
extern bool BeltHoldLine=true;//������ �� ���� 
extern bool UpsideGapTwoCrows=true;//��� ���������� ������ 
extern bool ThreeCrows=true;//��� ������
extern bool MatHoldPattern=true;//��������� �� ������
extern bool CounterattackLines=true;//����������
extern bool SeparatingLines=true;//���������� 
extern bool GravestoneDoji=true;//�����-���������
extern bool LongLeggedDoji=true;//����������� �����
extern bool Doji=true;//����� (������ �����)
extern bool TasukiGap=true;//������ ������
extern bool SideBySideWhite=true;//������� ����� �����
extern bool ThreeMethods=true;//��� ������
extern bool Gap=true;//����
extern bool ThreeWhiteSoldiers=true;//��� ����� ������� 
extern bool AdvanceBlock=true;//������� ����������� 
extern bool StalledPattern=true;//���������� 
extern bool ThreeLineStrike=true;//������� ����
extern bool OnNeckLine=true;//� ����� ��� 
        
bool  UseSound  = True;  // ������������ �������� ������ ��/���              
int  MaxTries=5, Dec, LastOrderType=0;
int   i, cnt=0, ticket, mode=0, digit=0, total, OrderToday=0;
double  Lotsi=0,  spread;
int LastVol;
string  name="CandleBot";
string SoundSuccess   = "alert.wav";      // ���� ������
string SoundError     = "timeout.wav";    // ���� ������
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
if (HangingMan && Text=="����������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Hammer && Text=="�����") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (MorningStar && Text=="�������� ������") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (EveningStar && Text=="�������� ������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Engulfing && Text=="����������" && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Engulfing && Text=="����������" && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (DarkCloudCover && Text=="������ �� �������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Piercing && Text=="������� � �������") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (ShootingStar && Text=="�������� ������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (InvertedHammer && Text=="����������� �����") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Harami && Text=="������" && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Harami && Text=="������" && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Tweezer && Text=="������� ������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (Tweezer && Text=="��������� ������") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (BeltHoldLine && Text=="������ �� ����"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (BeltHoldLine && Text=="������ �� ����"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (UpsideGapTwoCrows && Text=="��� ���������� ������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeCrows && Text=="��� ������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (MatHoldPattern && Text=="��������� �� ������") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}
if (CounterattackLines && Text=="����������"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (CounterattackLines && Text=="����������" && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (SeparatingLines && Text=="����������"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (SeparatingLines && Text=="����������"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (GravestoneDoji && Text=="�����-���������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (LongLeggedDoji && Text=="����������� �����"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (LongLeggedDoji && Text=="����������� �����"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (Doji && Text=="����� ����������"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (Doji && Text=="����� ����������"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (TasukiGap && Text=="������ ������"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (TasukiGap && Text=="������ ������"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (SideBySideWhite && Text=="������� ����� �����"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (SideBySideWhite && Text=="������� ����� �����"  && CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeMethods && Text=="��� ������"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeMethods && Text=="��� ������"  &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (Gap && Text=="����" &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (Gap && Text=="����" && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);} 
if (ThreeWhiteSoldiers && Text=="��� ����� �������") {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}   
if (AdvanceBlock && Text=="������� �����������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (StalledPattern && Text=="����������") {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}   
if (ThreeLineStrike && Text=="������� ����"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}    
if (ThreeLineStrike && Text=="������� ����" &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}  
if (OnNeckLine && Text=="� ����� ���"  && CandleSell>0) {CSell=1; CreateTextObject(Time[1], 0, Yellow, Text);}    
if (OnNeckLine && Text=="� ����� ���" &&  CandleBuy>0) {CBuy=1; CreateTextObject(Time[1], 0, Yellow, Text);}   

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
            if (IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) {Text="����������"; CandleBuy=1;return(0);}
            if (IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) {Text="����������"; CandleSell=1;return(0);}
            if (GetBodyHeight(ai_0 + 2) >= 15.0 * Point*Dec || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) {Text="����������"; CandleBuy=1;return(0);}
            if (GetBodyHeight(ai_0 + 2) >= 15.0 * Point*Dec || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) {Text="����������"; CandleSell=1;return(0);}
         }
      }
   }
   if (IsDoji(ai_0 + 2)) {
      if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMin(Close[ai_0 + 2], Open[ai_0 +2])) 
      {
         if (IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) Text="����� ���������� ���";
         if (IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) Text="����� ���������� ����";
      }
   }
   if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec && Open[ai_0 + 1] > High[ai_0 + 2] && Close[ai_0 + 1] < Open[ai_0 +
      2] + (Close[ai_0 + 2] - (Open[ai_0 + 2])) / 2.0 && GetLowCloseOpen(ai_0 + 1) > GetLowCloseOpen(ai_0 + 2)) {Text="������ �� �������"; CandleSell=1; return(0);}
   if (MathAbs(Close[ai_0 + 2] - (Open[ai_0 + 2])) > 15.0 * Point*Dec) {
      if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMin(Close[ai_0 + 2], Open[ai_0 +
         2])) {
         if ((IsYang(ai_0 + 2) && IsHigher(ai_0 + 2)) || (IsYang(ai_0 + 2) )) {Text="������"; CandleSell=1; return(0);}
         if ((IsYing(ai_0 + 2) && IsLower(ai_0 + 2)) || (IsYing(ai_0 + 2) )) {Text="������"; CandleBuy=1; return(0);}
      }
   }
   
   if (IsHammer(ai_0 + 1)) {Text="�����"; CandleBuy=1;return(0);}
   if (IsHangMan(ai_0 + 1)) {Text="����������"; CandleSell=1; return(0);}
   if (IsInvertHammer(ai_0 + 1)) {Text="����������� �����"; CandleBuy=1; return(0);}
   if (IsInvertHammerCFM(ai_0 + 1)) {Text="����������� �����"; CandleBuy=1; return(0);}
   if (IsYang(ai_0 + 1) && IsYing(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec && Open[ai_0 + 1] < Low[ai_0 + 2] && Close[ai_0 + 1] > Close[ai_0 + 2] + (Open[ai_0 +
      2] - (Close[ai_0 + 2])) / 2.0 && GetHighCloseOpen(ai_0 + 1) < GetHighCloseOpen(ai_0 + 2)) {Text="������� � �������"; CandleBuy=1; return(0);}
   if (IsYing(ai_0 + 3) && IsYang(ai_0 + 1) && IsLower(ai_0 + 3)) {
      if (GetLowCloseOpen(ai_0 + 3) > GetHighCloseOpen(ai_0 + 2) || GetLowCloseOpen(ai_0 + 1) > GetHighCloseOpen(ai_0 + 2) && GetHighCloseOpen(ai_0 + 1) > GetLowCloseOpen(ai_0 +
         3) && GetBodyHeight(ai_0 + 2) <= 10.0 * Point*Dec && GetBodyHeight(ai_0 + 3) >= 8.0 * Point*Dec && GetBodyHeight(ai_0 + 1) >= 8.0 * Point*Dec) {Text="�������� ������"; CandleBuy=1;return(0);}
   }
   if (IsYang(ai_0 + 3) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 3)) {
      if (GetHighCloseOpen(ai_0 + 3) < GetLowCloseOpen(ai_0 + 2) || GetHighCloseOpen(ai_0 + 1) < GetLowCloseOpen(ai_0 + 2) && GetLowCloseOpen(ai_0 + 1) < GetHighCloseOpen(ai_0 +
         3) && GetBodyHeight(ai_0 + 2) <= 10.0 * Point*Dec && GetBodyHeight(ai_0 + 3) > 8.0 * Point*Dec && GetBodyHeight(ai_0 + 1) > 8.0 * Point*Dec) {Text="�������� ������";  CandleSell=1;return(0);}
   }
   if (GetLowerShadowHeight(ai_0 + 1) < GetAllHeight(ai_0 + 1) / 5.0) {
      if (GetUpperShadowHeight(ai_0 + 1) > 2.0 * GetBodyHeight(ai_0 + 1))
         if (IsHigher(ai_0 + 1)) {Text="�������� ������";  CandleSell=1; return(0);}
   }
   if (IsHigher(ai_0 + 2) && High[ai_0 + 2] == High[ai_0 + 1] || High[ai_0 + 3] == High[ai_0 + 1] || High[ai_0 +
      4] == High[ai_0 + 1]) {Text="������� ������"; CandleSell=1; return(0);}
   if (IsLower(ai_0 + 2) && Low[ai_0 + 2] == Low[ai_0 + 1] || Low[ai_0 + 3] == Low[ai_0 + 1] || Low[ai_0 +
      4] == Low[ai_0 + 1]) {Text="��������� ������"; CandleBuy=1; return(0);}
 
   if (GetBodyHeight(ai_0 + 1) >= 10.0 * Point*Dec && IsYang(ai_0 + 1) && GetLowerShadowHeight(ai_0+1) == 0.0 && GetBodyHeight(ai_0 + 1) > GetAllHeight(ai_0 +
      1) / 2.0) {Text="������ �� ����";  CandleBuy=1; return(0);}
   if (GetBodyHeight(ai_0 + 1) >= 10.0 * Point*Dec && IsYing(ai_0 + 1) && GetUpperShadowHeight(ai_0+1) == 0.0 && GetBodyHeight(ai_0 + 1) > GetAllHeight(ai_0 +
      1) / 2.0) {Text="������ �� ����";  CandleSell=1; return(0);}

   if (IsHigher(ai_0 + 3) && IsYang(ai_0 + 3) && IsYing(ai_0 + 2) && IsYing(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] && Open[ai_0 + 1] > Open[ai_0 + 2] && Close[ai_0 +
      1] < Close[ai_0 + 2] && GetLowCloseOpen(ai_0 + 1) > GetHighCloseOpen(ai_0 + 3) && GetLowCloseOpen(ai_0 + 2) > GetHighCloseOpen(ai_0 + 3)) {Text="��� ���������� ������";  CandleSell=1;return(0);}
   if (IsYang(ai_0 + 5) && IsYing(ai_0 + 4) && IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 4] < Close[ai_0 + 1] &&
      GetBodyHeight(ai_0 + 5) >= 5.0 * Point*Dec && GetBodyHeight(ai_0 + 1) >= 5.0 * Point*Dec) {Text="��������� �� ������";  CandleBuy=1; return(0);}
   if (IsThree_Crows(ai_0 + 1)) {Text="��� ������"; CandleSell=1; return(0);}
   if (GetBodyHeight(ai_0 + 1) > 5.0 * Point && GetBodyHeight(ai_0 + 2) > 5.0 * Point) {
      if (IsHigher(ai_0 + 1) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && GetHighCloseOpen(ai_0 + 1) - GetHighCloseOpen(ai_0 + 2) >= 2.0 * Point*Dec && Close[ai_0 + 2] > Close[ai_0 + 1] && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec) {Text="����������";  CandleSell=1; return(0);}
      if (IsLower(ai_0 + 1) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && GetLowCloseOpen(ai_0 + 2) - GetLowCloseOpen(ai_0 + 1) >= 2.0 * Point*Dec && Close[ai_0 + 2] < Close[ai_0 + 1] && GetBodyHeight(ai_0 + 2) >= 10.0 * Point*Dec) {Text="����������";  CandleBuy=1; return(0);}
   }
   if (GetBodyHeight(ai_0 + 1) > 5.0 * Point && GetBodyHeight(ai_0 + 2) > 5.0 * Point) {
      if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && Open[ai_0 + 2] - (Open[ai_0 + 1]) >= -2.0 * Point*Dec && GetBodyHeight(ai_0 + 2) >= 2.0 * Point*Dec) {Text="����������"; CandleSell=1; return(0);}
      if (IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 1] - (Open[ai_0 + 2]) >= -2.0 * Point*Dec && GetBodyHeight(ai_0 + 2) >= 2.0 * Point*Dec) {Text="����������";  CandleBuy=1; return(0);}
   }
   if (Close[ai_0 + 1] == Open[ai_0 + 1] && GetLowerShadowHeight(ai_0+1) == 0.0) {Text="�����-���������"; CandleSell=1; return(0);}
   
   if (IsHigher(ai_0 + 1) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 2.0 * Point*Dec && GetAllHeight(ai_0 + 1) > 10.0 * Point*Dec && High[ai_0 + 1] > High[ai_0 + 2]) {Text="����������� �����"; CandleSell=1; return(0);}
   if (IsLower(ai_0 + 1) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 2.0 * Point*Dec && GetAllHeight(ai_0 + 1) > 10.0 * Point*Dec && Low[ai_0 + 1] < Low[ai_0 + 2]) {Text="����������� �����"; CandleBuy=1; return(0);}
  
   if (GetBodyHeight(ai_0 + 2) > 10.0 * Point*Dec && IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYang(ai_0 + 2) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 1.0 * Point*Dec) {Text="����� ����������"; CandleSell=1; return(0);}
   if (GetBodyHeight(ai_0 + 2) > 10.0 * Point*Dec && IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYing(ai_0 + 2) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 1.0 * Point*Dec) {Text="����� ����������"; CandleBuy=1; return(0);}
      
   if (IsHigher(ai_0 + 3) || IsHigher(ai_0 + 2) && (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1))  && Low[ai_0 +
      1] - (Low[ai_0 + 3]) >= 2.0 * Point && Open[ai_0 + 2] - (Close[ai_0 + 3]) > 0.1 * Point*Dec && Close[ai_0 + 1] < Open[ai_0 + 2] && MathAbs(GetBodyHeight(ai_0 +
      1) - GetBodyHeight(ai_0 + 2)) < 5.0 * Point*Dec) {Text="������ ������";   CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 3) || IsLower(ai_0 + 2) && (IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1))  && High[ai_0 +
      3] - (High[ai_0 + 1]) >= 2.0 * Point && Close[ai_0 + 3] - (Open[ai_0 + 2]) > 0.1 * Point*Dec && Close[ai_0 + 1] > Open[ai_0 + 2] && MathAbs(GetBodyHeight(ai_0 +
      1) - GetBodyHeight(ai_0 + 2)) < 5.0 * Point*Dec) {Text="������ ������"; CandleSell=1; return(0);}

   if (IsHigher(ai_0 + 3) && (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1))  && MathAbs(Open[ai_0 + 1] - Open[ai_0 +
      2]) < 3.0 * Point*Dec && MathAbs(GetBodyHeight(ai_0 + 1) - GetBodyHeight(ai_0 + 2)) < 10.0 * Point*Dec) {Text="������� ����� �����"; CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 3) && (IsYing(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1))  && MathAbs(Open[ai_0 + 1] - Open[ai_0 +
      2]) < 3.0 * Point*Dec && MathAbs(GetBodyHeight(ai_0 + 1) - GetBodyHeight(ai_0 + 2)) < 10.0 * Point*Dec) {Text="������� ����� �����"; CandleSell=1; return(0);}
      
   if (IsHigher(ai_0 + 5) && IsYang(ai_0 + 5) && IsYang(ai_0 + 1) && IsYing(ai_0 + 2) && IsYing(ai_0 + 3) && IsYing(ai_0 + 4) && GetBodyHeight(ai_0 + 5) > 5.0 * Point &&
      GetBodyHeight(ai_0 + 1) > 5.0 * Point*Dec && Open[ai_0 + 5] < Close[ai_0 + 1]) {Text="��� ������"; CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 5) && IsYing(ai_0 + 5) && IsYing(ai_0 + 1) && IsYang(ai_0 + 2) && IsYang(ai_0 + 3) && IsYang(ai_0 + 4) && GetBodyHeight(ai_0 + 5) > 5.0 * Point &&
      GetBodyHeight(ai_0 + 1) > 5.0 * Point*Dec && Open[ai_0 + 5] > Close[ai_0 + 1]) {Text="��� ������";  CandleSell=1; return(0);}
          
   if (IsHigher(ai_0 + 1) && IsYang(ai_0 + 1) && IsYang(ai_0 + 2) && Open[ai_0 + 1] - (Close[ai_0 + 2]) >= 1 * Point*Dec) {Text="����"; CandleBuy=1; return(0);}
   if (IsLower(ai_0 + 1) && IsYing(ai_0 + 1) && IsYing(ai_0 + 2) && Close[ai_0 + 2] - (Open[ai_0 + 1]) >= 1 * Point*Dec) {Text="����"; CandleSell=1; return(0);}


   if (IsThree_White_Soldiers(ai_0)) {Text="��� ����� �������"; CandleBuy=1; return(0);}
   
   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2]  && GetBodyHeight(ai_0 + 3) > GetBodyHeight(ai_0 + 2) && GetBodyHeight(ai_0 + 2) > GetBodyHeight(ai_0 + 1)) {Text="������� �����������"; CandleSell=1; return(0);}

   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2] && GetBodyHeight(ai_0 + 3) < GetBodyHeight(ai_0 + 2)/2 && GetBodyHeight(ai_0 + 1) < GetBodyHeight(ai_0 + 2)/2) {Text="����������";  CandleSell=1; return(0);}
      
     
   if (IsYang(ai_0 + 1) && IsThree_Crows(ai_0 + 2) && Close[ai_0 + 1] > Open[ai_0 + 2]) {Text="������� ����"; CandleSell=1; return(0);}
   if (IsYing(ai_0 + 1) && IsThree_White_Soldiers(ai_0 + 1) && Close[ai_0 + 1] < Open[ai_0 + 2]) {Text="������� ����"; CandleBuy=1; return(0);}
   
   if (IsYing(ai_0 + 2) && IsYang(ai_0 + 1)  && Close[ai_0 + 1] < Open[ai_0 + 2] - (Open[ai_0 + 2] - (Close[ai_0 +
      2])) / 2.0 && Open[ai_0 + 1] < GetLowCloseOpen(ai_0 + 2)) {Text="� ����� ���";  CandleSell=1; return(0);}
   if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1)  && Close[ai_0 + 1] > Open[ai_0 + 2] + (Close[ai_0 + 2] - (Open[ai_0 +
      2])) / 2.0 && Open[ai_0 + 1] > GetHighCloseOpen(ai_0 + 2)) {Text="� ����� ���";  CandleBuy=1; return(0);}      

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