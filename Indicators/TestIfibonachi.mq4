//+------------------------------------------------------------------+
//|                                                   iFibonacci.mq4 |
//|                                        Copyright © 2015, Awran5. |
//|                                                 awran5@yahoo.com |
//|      Credit:                                                     |
//|       JimDandy: http://www.jimdandyforex.com                     |
//|       WHRoeder: https://www.mql5.com/en/users/WHRoeder           |
//|       RaptorUK: https://www.mql5.com/en/users/RaptorUK           |
//|       deVries : https://www.mql5.com/en/users/deVries            |                
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2015, Awran5."
#property link        "awran5@yahoo.com"
#property version     "1.01"
#property description "This indicator will Draw Fibonacci Tools e.g. Retracement, Arc, Fan, Expansion, TimeZones. Based on zigzag indicator.\n"
#property description "Credit: \n      JimDandy, \n      WHRoeder, \n      RaptorUK, \n      deVries"
#property strict
#property indicator_chart_window

// Retrieves the coordinates of a window's client area, Used for Fibo Arc scale
#import "user32.dll"
int GetClientRect(int hWnd,int &lpRect[]);
#import
//---
enum ArcScale
  {
   Math,       // MathAbs
   ClientRect, // ClientRect
   Manual      // Set Manually
  };


input string  lb_22                    = "";                // ----------  Свечное время
extern bool   ShowCanldeTime           = true;              // Показывать свечное время
extern color  TimerColor               = clrYellow;         // Цвет времени
extern int    TimerFontSize            = 7;                 // Размер шрифта времени
//|--------------------------------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                                                      |
//|--------------------------------------------------------------------------------------------------------------------|
//---
double   zValue[5];  // zigzag swings value. zValue[1] = swing 1, and so on.
datetime zTime[5];   // Time for zigzag swings value
//---
int rect[4];         // находим координаты окна.
int hwnd;            // Дескриптор окна, чьи клиентские координаты должны быть получены. 
int gPixels,vPixels;
//---
double DayLow,DayHigh,DayClose,DayPivot,WeekLow,WeekHigh,MonthLow,MonthHigh;
//----
string Tools[8]  = {"Fibo Retracement", "Fibo Arc", "Fibo Fan", "Fibo TimeZones", "Fibo Expansion", "Pattern1", "Pattern2", "Candle Time"},
Names[7]  = {"Yesterday High", "Yesterday Low", "Weekly High", "Weekly Low", "Monthly High", "Monthly Low", "Pivot"},
Labels[7] = {"YH","YL","WH","WL","MH", "ML", "PVT"}, space = "       ";
//+------------------------------------------------------------------+
//| Инициализация функций выбранных индикаторов                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- отображение индикаторных буферов
   if(!IsDllsAllowed())
     {
      Print("Один из методов Fibo ARC требует DLL, не забудьте разрешить импорт DLL, если вы хотите его использовать");
      return(INIT_SUCCEEDED);
     }
//---
   hwnd=WindowHandle(Symbol(),Period());
   if(hwnd>0)
     {
      GetClientRect(hwnd,rect);
      gPixels = rect[2];
      vPixels = rect[3];
     }
//---- форсировать ежедневную загрузку данных
   iBars(NULL,PERIOD_D1);
//---- короткое имя индикатора
   IndicatorShortName("iFibonacci");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Деинициализация функций                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   for(int i=0; i<9; i++)
     {
      if(ObjectFind(0,Tools[i])        >=0) ObjectDelete(Tools[i]);
      if(ObjectFind(0,Names[i])        >=0) ObjectDelete(Names[i]);
      if(ObjectFind(0,space+Labels[i]) >=0) ObjectDelete(space+Labels[i]);
     }
  }
//+------------------------------------------------------------------+
//| Итерация функций пользовательского индикатора                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   if(ShowCanldeTime) CandleTimeLeft();

//--- Возвращает значение из prev_calculated для следующего вызова
   return(rates_total);
  }

void CandleTimeLeft()
  {
//---
   string TimeLeft;
   int offset;
   TimeLeft=TimeToStr(Time[0]+Period()*60-TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
   offset=Period()*200;
   ObjectDelete(Tools[7]);
   ObjectCreate(Tools[7],OBJ_TEXT,0,Time[0]+offset,Close[0]);
   ObjectSetText(Tools[7],TimeLeft,TimerFontSize,"Calibri",Black);
//---
  }
//|--------------------------------------------------------------------------------------------------------------------|
//|                                                      КОНЕЦ                                                         |
//|--------------------------------------------------------------------------------------------------------------------|
