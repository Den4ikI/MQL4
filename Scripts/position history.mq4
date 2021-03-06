//+------------------------------------------------------------------+
//|                                             position history.mq4 |
//|                                               Yuriy Tokman (YTG) |
//|                       https://www.mql5.com/ru/users/satop/seller |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "https://www.mql5.com/ru/users/satop/seller"
#property version   "1.00"
#property strict
#property show_inputs

input color buy = clrGreen;
input color sell = clrRed;
input int   _width=3;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int i, k= OrdersHistoryTotal(), r=-1;
   string sy=Symbol();
   for(i=0; i<k; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol()==sy)
           {
            if(OrderType()==OP_BUY)
              {
               TrendCreate(0,"TrendLine"+(string)OrderTicket(),0,
                           OrderOpenTime(),           // время первой точки
                           OrderOpenPrice(),          // цена первой точки
                           OrderCloseTime(),           // время второй точки
                           OrderClosePrice(),          // цена второй точки
                           buy,        // цвет линии
                           STYLE_SOLID, // стиль линии
                           _width
                          );
              }
            if(OrderType()==OP_SELL)
              {
               TrendCreate(0,"TrendLine"+(string)OrderTicket(),0,
                           OrderOpenTime(),           // время первой точки
                           OrderOpenPrice(),          // цена первой точки
                           OrderCloseTime(),           // время второй точки
                           OrderClosePrice(),          // цена второй точки
                           sell,        // цвет линии
                           STYLE_SOLID, // стиль линии
                           _width
                          );
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Создает линию тренда по заданным координатам                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // ID графика
                 const string          name="TrendLine",  // имя линии
                 const int             sub_window=0,      // номер подокна
                 datetime              time1=0,           // время первой точки
                 double                price1=0,          // цена первой точки
                 datetime              time2=0,           // время второй точки
                 double                price2=0,          // цена второй точки
                 const color           clr=clrRed,        // цвет линии
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии
                 const int             width=1,           // толщина линии
                 const bool            back=false,        // на заднем плане
                 const bool            selection=false,    // выделить для перемещений
                 const bool            ray_right=false,   // продолжение линии вправо
                 const bool            hidden=true,       // скрыт в списке объектов
                 const long            z_order=0)         // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим трендовую линию по заданным координатам
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": не удалось создать линию тренда! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим цвет линии
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль отображения линии
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линии
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим перемещения линии мышью
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- включим (true) или отключим (false) режим продолжения отображения линии вправо
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
   return(true);
  }
//----
//+------------------------------------------------------------------+
