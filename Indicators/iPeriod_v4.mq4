//+------------------------------------------------------------------+
//|                                                   iPeriod_v4.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern color _color1 = Pink;
extern color _color2 = Gray;
extern color _color3 = Lavender;
extern color _color4 = PaleGreen;

extern int i = 1;
extern int iShift = 24;
extern bool iVertical = false;

extern int _style2 = 2;
extern int _width2 = 0;

string txt = "iP ";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   GetDellName (txt);
   Comment("");
   ObjectDelete("fibo_levels");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----

   // +++++++
   if(ObjectFind("iVertical")!=0 && iVertical==true) ObjectCreate("iVertical", OBJ_VLINE, 0, Time[0], 0);
   // +++++++
   
   datetime iVDate=ObjectGet("iVertical",OBJPROP_TIME1);
   int iV=iBarShift(NULL,0,iVDate,false);
   
   if (iVertical==false) i=i;
   if (iVertical==true) i=iV;
   
   //int i = 1;
   //int iShift = 24;
       
     double H1 = High[iHighest(NULL,0,MODE_HIGH,iShift,i)];
     double L1 = Low [iLowest (NULL,0,MODE_LOW, iShift,i)];
     double O1 = Open[iShift+i-1];
     double C1 = Close[i];
     
     double H2 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift+i)];
     double L2 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift+i)];
     double O2 = Open [iShift*2+i-1];
     double C2 = Close[iShift+i];
     
     double H3 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*2+i)];
     double L3 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*2+i)];
     double O3 = Open [iShift*3+i-1];
     double C3 = Close[iShift*2+i];
     
     double H4 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*3+i)];
     double L4 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*3+i)];
     double O4 = Open [iShift*4+i-1];
     double C4 = Close[iShift*3+i];
     
     double H5 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*4+i)];
     double L5 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*4+i)];
     double O5 = Open [iShift*5+i-1];
     double C5 = Close[iShift*4+i];
     
     double H6 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*5+i)];
     double L6 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*5+i)];
     double O6 = Open [iShift*6+i-1];
     double C6 = Close[iShift*5+i];
     
     double H7 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*6+i)];
     double L7 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*6+i)];     
     double O7 = Open [iShift*7+i-1];
     double C7 = Close[iShift*6+i];
     
     double H8 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*7+i)];
     double L8 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*7+i)];
     double O8 = Open [iShift*8+i-1];
     double C8 = Close[iShift*7+i];
     
     double H9 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*8+i)];
     double L9 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*8+i)];
     double O9 = Open [iShift*9+i-1];
     double C9 = Close[iShift*8+i];
     
     double H10 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*9+i)];
     double L10 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*9+i)];
     double O10 = Open [iShift*10+i-1];
     double C10 = Close[iShift*9+i];
     
     double H11 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*10+i)];
     double L11 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*10+i)];
     double O11 = Open [iShift*11+i-1];
     double C11 = Close[iShift*10+i];
     
     double H12 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*11+i)];
     double L12 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*11+i)];
     double O12 = Open [iShift*12+i-1];
     double C12 = Close[iShift*11+i];
     
     double H13 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*12+i)];
     double L13 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*12+i)];
     double O13 = Open [iShift*13+i-1];
     double C13 = Close[iShift*12+i];
     
     double H14 = High[iHighest(NULL,0,MODE_HIGH,iShift,iShift*13+i)];
     double L14 = Low [iLowest (NULL,0,MODE_LOW, iShift,iShift*13+i)];
     double O14 = Open [iShift*14+i-1];
     double C14 = Close[iShift*13+i];
     
     if (H1-L1 < H2-L2 && // проверка
         H1-L1 < H3-L3 && // сжатия
         H1-L1 < H4-L4 && // волатильности
         H1-L1 < H5-L5 && // за
         H1-L1 < H6-L6 && // 7
         H1-L1 < H7-L7)   // периодов
          {RectangleGraff1 (txt+" d1", Time[iShift+i-1],H1, Time[i],L1);}
     else if (H1-L1 > H2-L2 && // проверка
              H1-L1 > H3-L3 && // волатильности
              H1-L1 > H4-L4 && // рынка
              H1-L1 > H5-L5 && // за
              H1-L1 > H6-L6 && // 7
              H1-L1 > H7-L7)   // периодов
               {RectangleGraff2 (txt+" d1", Time[iShift+i-1],H1, Time[i],L1);}
          else
               {RectangleGraff  (txt+" d1", Time[iShift+i-1],H1, Time[i],L1);}
             
       TrendLineGraff (txt+" t1", Time[iShift+i-1],O1, Time[i],C1);
                
       RectangleGraff (txt+" d2", Time[iShift*2+i-1],H2, Time[iShift+i],L2);      
       TrendLineGraff (txt+" t2", Time[iShift*2+i-1],O2, Time[iShift+i],C2);
          
       RectangleGraff (txt+" d3", Time[iShift*3+i-1],H3, Time[iShift*2+i],L3);      
       TrendLineGraff (txt+" t3", Time[iShift*3+i-1],O3, Time[iShift*2+i],C3);
          
       RectangleGraff (txt+" d4", Time[iShift*4+i-1],H4, Time[iShift*3+i],L4);       
       TrendLineGraff (txt+" t4", Time[iShift*4+i-1],O4, Time[iShift*3+i],C4);
          
       RectangleGraff (txt+" d5", Time[iShift*5+i-1],H5, Time[iShift*4+i],L5);       
       TrendLineGraff (txt+" t5", Time[iShift*5+i-1],O5, Time[iShift*4+i],C5);
          
       RectangleGraff (txt+" d6", Time[iShift*6+i-1],H6, Time[iShift*5+i],L6);       
       TrendLineGraff (txt+" t6", Time[iShift*6+i-1],O6, Time[iShift*5+i],C6);
          
       RectangleGraff (txt+" d7", Time[iShift*7+i-1],H7, Time[iShift*6+i],L7);       
       TrendLineGraff (txt+" t7", Time[iShift*7+i-1],O7, Time[iShift*6+i],C7);
          
       RectangleGraff (txt+" d8", Time[iShift*8+i-1],H8, Time[iShift*7+i],L8);       
       TrendLineGraff (txt+" t8", Time[iShift*8+i-1],O8, Time[iShift*7+i],C8);
          
       RectangleGraff (txt+" d9", Time[iShift*9+i-1],H9, Time[iShift*8+i],L9);       
       TrendLineGraff (txt+" t9", Time[iShift*9+i-1],O9, Time[iShift*8+i],C9);
          
       RectangleGraff (txt+" d10", Time[iShift*10+i-1],H10, Time[iShift*9+i],L10);       
       TrendLineGraff (txt+" t10", Time[iShift*10+i-1],O10, Time[iShift*9+i],C10);
          
       RectangleGraff (txt+" d11", Time[iShift*11+i-1],H11, Time[iShift*10+i],L11);       
       TrendLineGraff (txt+" t11", Time[iShift*11+i-1],O11, Time[iShift*10+i],C11);
          
       RectangleGraff (txt+" d12", Time[iShift*12+i-1],H12, Time[iShift*11+i],L12);       
       TrendLineGraff (txt+" t12", Time[iShift*12+i-1],O12, Time[iShift*11+i],C12);
          
       RectangleGraff (txt+" d13", Time[iShift*13+i-1],H13, Time[iShift*12+i],L13);       
       TrendLineGraff (txt+" t13", Time[iShift*13+i-1],O13, Time[iShift*12+i],C13);
          
       RectangleGraff (txt+" d14", Time[iShift*14+i-1],H14, Time[iShift*13+i],L14);       
       TrendLineGraff (txt+" t14", Time[iShift*14+i-1],O14, Time[iShift*13+i],C14);

//----
   if(ObjectFind("fibo_levels")!= 0)
     {
      ObjectCreate("fibo_levels", OBJ_FIBO, 0, Time[i], H1, Time[i], L1);
      ObjectSet("fibo_levels", OBJPROP_RAY, true);
      ObjectSet("fibo_levels", OBJPROP_FIBOLEVELS, 12);
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 0, -5.764);
      ObjectSetFiboDescription("fibo_levels", 0, "(%$) -576.4");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 1, -3.236);
      ObjectSetFiboDescription("fibo_levels", 1, "(%$) -323.6");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 2, -1.618);
      ObjectSetFiboDescription("fibo_levels", 2, "(%$) -161.80");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 3, -0.618);
      ObjectSetFiboDescription("fibo_levels", 3, "(%$) -61.80");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 4, 0.000);
      ObjectSetFiboDescription("fibo_levels", 4, "(%$) 0.000");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 5, 0.382);
      ObjectSetFiboDescription("fibo_levels", 5, "(%$) 38.20");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 6, 0.618);
      ObjectSetFiboDescription("fibo_levels", 6, "(%$) 61.80");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 7, 1.00);
      ObjectSetFiboDescription("fibo_levels", 7, "(%$) 100.0");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 8, 1.618);
      ObjectSetFiboDescription("fibo_levels", 8, "(%$) 161.8");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 9, 2.618);
      ObjectSetFiboDescription("fibo_levels", 9, "(%$) 261.8");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 10, 4.236);
      ObjectSetFiboDescription("fibo_levels", 10, "(%$) 423.6");
      
      ObjectSet("fibo_levels", OBJPROP_FIRSTLEVEL + 11, 6.764);
      ObjectSetFiboDescription("fibo_levels", 11, "(%$) 676.4");
      
      ObjectSet("fibo_levels", OBJPROP_COLOR, CLR_NONE);
      ObjectSet("fibo_levels", OBJPROP_LEVELCOLOR, MidnightBlue);
      ObjectSet("fibo_levels", OBJPROP_LEVELSTYLE, 2);
      ObjectSet("fibo_levels", OBJPROP_LEVELWIDTH, 0);
      ObjectSet("fibo_levels", OBJPROP_BACK, true);
     }
      else
          {
           ObjectSet("fibo_levels", OBJPROP_PRICE1, H1);
           ObjectSet("fibo_levels", OBJPROP_PRICE2, L1);
           ObjectSet("fibo_levels", OBJPROP_TIME1, Time[i]);
           ObjectSet("fibo_levels", OBJPROP_TIME2, Time[i]);
          }

   return(0);
  }

//+------------------------------------------------------------------+
//| Функция удаляет объекты                                          |
//+------------------------------------------------------------------+
 void GetDellName (string name_n = "ip_")
  {
   string vName;
   for(int i=ObjectsTotal()-1; i>=0;i--)
    {
     vName = ObjectName(i);
     if (StringFind(vName,name_n) !=-1) ObjectDelete(vName);
    }  
  }
//+------------------------------------------------------------------+
//| Функция отображения прямоугольной зоны                           |
//+------------------------------------------------------------------+
 void RectangleGraff(string labebe,datetime time1,double price1,datetime time2,double price2)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_RECTANGLE, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, _color3);
   ObjectSet(labebe, OBJPROP_STYLE,2);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_BACK, true);
  }
 void RectangleGraff1(string labebe,datetime time1,double price1,datetime time2,double price2)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_RECTANGLE, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, _color4);
   ObjectSet(labebe, OBJPROP_STYLE,2);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_BACK, true);
  }
 void RectangleGraff2(string labebe,datetime time1,double price1,datetime time2,double price2)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_RECTANGLE, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, _color1);
   ObjectSet(labebe, OBJPROP_STYLE,2);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
//| Функция отображения трендовой линии                              |
//+------------------------------------------------------------------+
 void TrendLineGraff(string labebe,datetime time1,double price1,datetime time2,double price2)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_TREND, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, _color2);
   ObjectSet(labebe, OBJPROP_STYLE,_style2);
   ObjectSet(labebe, OBJPROP_WIDTH,_width2);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_BACK, true);
  }

