//+------------------------------------------------------------------+
//|                                                      MAAngle.mq4 |
//|                                               original    jpkfox |
//|                                               edited by dariuske |
//| You can use this indicator to measure when the MA angle is       |
//| "near zero". AngleTreshold determines when the angle for the     |
//| EMA is "about zero": This is when the value is between           |
//| [-AngleTreshold, AngleTreshold] (or when the histogram is red).  |
//|   MAMode : 0 = SMA, 1 = EMA, 2 = Smoothed, 3 = Weighted          |
//|   MAPeriod: MA period                                            |
//|   AngleTreshold: The angle value is "about zero" when it is      |
//|     between the values [-AngleTreshold, AngleTreshold].          |
//|   StartMAShift: The starting point to calculate the              |
//|     angle. This is a shift value to the left from the            |
//|     observation point. Should be StartEMAShift > EndEMAShift.    |
//|   StartMAShift: The ending point to calculate the                |
//|     angle. This is a shift value to the left from the            |
//|     observation point. Should be StartEMAShift > EndEMAShift.    |
//|                                                                  |
/*
Вы можете использовать этот индикатор для измерения, когда угол MA "около нуля".
   AngleTreshold определяет, когда угол для EMA равен «примерно нулю»: это
когда значение находится между [-AngleTreshold, AngleTreshold] (или когда гистограмма красного цвета).
   MAMode: 0 = SMA, 1 = EMA, 2 = сглаженный, 3 = взвешенный
   MAPeriod: период MA
   AngleTreshold: значение угла «около нуля», когда оно находится между значениями [-AngleTreshold, AngleTreshold].
   StartMAShift: начальная точка для расчета угла. Это значение сдвига влево от точки наблюдения. Должно быть StartEMAShift> EndEMAShift.
   EndMAShift: конечная точка для расчета угла. Это значение сдвига влево от точки наблюдения. Должно быть StartEMAShift> EndEMAShift.
*/
//|   Modified by MrPip                                              |
//|       Red for down                                               |
//|       Yellow for near zero                                       |
//|       Green for up                                               |
/*
   красный - вниз
   Жолтый - возле нуля
   зеленый - вверх
*/
//|  10/15/05  MrPip                                                 |
//|            Corrected problem with USDJPY and optimized code      |
//|  10/23/05  Added other JPY crosses                               |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//|  12/01/07  Dariuske: Changed code for SMA50 (PhilNelSystem)      |
//|  18/01/07  Dariuske: Changed code for multiple mode MA's         |
//+------------------------------------------------------------------+

#property  copyright "jpkfox"
#property  link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15274&page=1&pp=8"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  FireBrick
#property indicator_color3  Yellow
#property indicator_width1  4
#property indicator_width2  4
#property indicator_width3  4

//
//
//
//
//

extern int    MAMode          = 0;
extern int    MAPeriod        = 50;
extern int    Price           = 4;
extern double AngleTreshold   = 0.25;
extern int    StartMAShift    = 2;
extern int    EndMAShift      = 0;

extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   neutralAlerts   = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsNotify    = false;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";


//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];
double fAngle[];
double trend[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(5);
   SetIndexBuffer(0,UpBuffer);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DownBuffer);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ZeroBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,fAngle);
   SetIndexBuffer(4,trend);

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   IndicatorShortName("MAAngle");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| The angle for EMA                                                |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   limit = MathMin(Bars-counted_bars,Bars-1);

//
//
//
//
//

   if(EndMAShift >= StartMAShift)
     {
      Print("Error: EndMAShift >= StartMAShift");
      StartMAShift = 6;
      EndMAShift   = 0;
     }


   double dFactor = 2*3.14159/180.0;
   double mFactor = 10000.0;
   string Sym     = StringSubstr(Symbol(),3,3);
   if(Sym == "JPY")
      mFactor = 100.0;
   int ShiftDif   = StartMAShift-EndMAShift;
   mFactor /= ShiftDif;
//---- main loop
   for(i=limit; i>=0; i--)
     {
      double fEndMA   = iMA(NULL,0,MAPeriod,0,MAMode,Price,i+EndMAShift);
      double fStartMA = iMA(NULL,0,MAPeriod,0,MAMode,Price,i+StartMAShift);
      // 10000.0 : Multiply by 10000 so that the fAngle is not too small
      // for the indicator Window.
      fAngle[i] = mFactor * (fEndMA - fStartMA)/2.0;
      DownBuffer[i] = EMPTY_VALUE;
      UpBuffer[i]   = EMPTY_VALUE;
      ZeroBuffer[i] = EMPTY_VALUE;
      trend[i] = 0;

      if(fAngle[i]> AngleTreshold)
         trend[i] = 1;
      if(fAngle[i]<-AngleTreshold)
         trend[i] =-1;
      if(fAngle[i] <= AngleTreshold && fAngle[i] >= AngleTreshold)
         trend[i] = 0;
      if(trend[i] == 1)
         UpBuffer[i]   = fAngle[i];
      if(trend[i] ==-1)
         DownBuffer[i] = fAngle[i];
      if(trend[i] == 0)
         ZeroBuffer[i] = fAngle[i];
     }
   manageAlerts();
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts()
  {
   if(alertsOn)
     {
      if(alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      if(trend[whichBar] != trend[whichBar+1])
        {
         if(!neutralAlerts)
           {
            if(trend[whichBar] == 1)
               doAlert(whichBar,"up");
            if(trend[whichBar] ==-1)
               doAlert(whichBar,"down");
           }
         else
           {
            if(trend[whichBar] == 1)
               doAlert(whichBar,"up");
            if(trend[whichBar] ==-1)
               doAlert(whichBar,"down");
            if(trend[whichBar] == 0)
               doAlert(whichBar,"no trade");
           }

        }
     }
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];

      //
      //
      //
      //
      //

      message =  StringConcatenate(Symbol(),TimeToStr(TimeLocal(),TIME_SECONDS)," MaAngle ",doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol()," MaAngle "),message);
      if(alertsSound)
         PlaySound("alert2.wav");
     }
  }


//+------------------------------------------------------------------+
