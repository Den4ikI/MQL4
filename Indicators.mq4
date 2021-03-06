//+------------------------------------------------------------------+
//|                                                   Indicators.mq4 |
//|                                                          ljapkin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ljapkin"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Gambit"
#property strict

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 5    //пять линий индикатора
#property indicator_color1 Black //первая линия
#property indicator_color2 LightSeaGreen //вторая линия
#property indicator_color3 Blue //центральная линия болинджера
#property indicator_color4 LightSeaGreen //четвертая линия
#property indicator_color5 Black //пятая линия
//--- параметры индикатора
input int   InpBandsPeriod=30;  // период волн
input int   InpBandsShift1=0;    // сдвиг волн в обоих случаях 0
input int   InpBandsShift2=0;    // возможно нет необходимости
input double InpBandsDeviations1=1.0; // отклонение первое
input double InpBandsDeviations2=2.0; // отклонение второе
//--- Наверное, обьявление буферов где вычислются линии (дальше не лучшее задание индексов, возможна запарки со строками 15-20)
double ExtMovingBuffer[]; // центральная линия индикатора
double ExtUpperBuffer1[]; // первая верхняя линия, должна быть светло зеленой
double ExtUpperBuffer2[];  // вторая верхняя линия, должна быть черной
double ExtLowerBuffer1[]; // первая нижняя линия, должна быть светло зеленой
double ExtLowerBuffer2[];  // вторая нижняя линия, должна быть черной
double ExtStdDevBuffer[]; // не знаю что это

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//-- (?)1 дополнительный буффер для счета, и того получается 6
   IndicatorBuffers(6);
   IndicatorDigits(Digits);
//-- средняя линия
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMovingBuffer);
   SetIndexShift(0,InpBandsShift1);
   SetIndexLabel(0,"Bands SMA");
//--- верхняя линия 1
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtUpperBuffer1);
   SetIndexShift(1,InpBandsShift1);
   SetIndexLabel(1,"Bands Upper1");
//--- верхняя линия 2
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtUpperBuffer2);
   SetIndexShift(2,InpBandsShift1);
   SetIndexLabel(2,"Bands Upper2");
//--- нижняя линия 1
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtLowerBuffer1);
   SetIndexShift(3,InpBandsShift1);
   SetIndexLabel(3,"Bands Lower1");
//--- нижняя линия 2
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtLowerBuffer2);
   SetIndexShift(4,InpBandsShift1);
   SetIndexLabel(4,"Bands Lower2");

//--- рабочий буффер
   SetIndexBuffer(5,ExtStdDevBuffer);
//--- проверка входных парраметров
   if(InpBandsPeriod<=0)
     {
      Print("Неверный входной параметр Bands Period=",InpBandsPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpBandsPeriod+InpBandsShift1);
   SetIndexDrawBegin(1,InpBandsPeriod+InpBandsShift1);
   SetIndexDrawBegin(2,InpBandsPeriod+InpBandsShift1);
//--- initialization done
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Гамбит индикатор                              |
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
   int i,pos;
//---
   if(rates_total<=InpBandsPeriod || InpBandsPeriod<=0)
      return(0);
//--- counting from 0 to rates_total, не пойму что считает, добавил свои буфера
   ArraySetAsSeries(ExtMovingBuffer,false);
   ArraySetAsSeries(ExtUpperBuffer1,false);
   ArraySetAsSeries(ExtUpperBuffer2,false);
   ArraySetAsSeries(ExtLowerBuffer1,false);
   ArraySetAsSeries(ExtLowerBuffer2,false);
   ArraySetAsSeries(ExtStdDevBuffer,false);
   ArraySetAsSeries(close,false);
//--- initial zero, тоже поставил свои буферы
   if(prev_calculated<1)
     {
      for(i=0; i<InpBandsPeriod; i++)
        {
         ExtMovingBuffer[i]=EMPTY_VALUE;
         ExtUpperBuffer1[i]=EMPTY_VALUE;
         ExtUpperBuffer2[i]=EMPTY_VALUE;
         ExtLowerBuffer1[i]=EMPTY_VALUE;
         ExtLowerBuffer2[i]=EMPTY_VALUE;
        }
     }
//--- starting calculation
   if(prev_calculated>1)
      pos=prev_calculated-1;
   else
      pos=0;
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- middle line ВОТ ОНА ВСЯ МАТЕМАТИКА
      ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,close);
      //--- calculate and write down StdDev
      ExtStdDevBuffer[i]=StdDev_Func(i,close,ExtMovingBuffer,InpBandsPeriod);
      //--- upper line
      ExtUpperBuffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*ExtStdDevBuffer[i];
      //--- lower line
      ExtLowerBuffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*ExtStdDevBuffer[i];
      //---
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
