﻿//+------------------------------------------------------------------+
//|                                                 TickReporter.mq4 |
//|                                                            Vitek |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vitek"
#property link      "https://www.mql5.com"
#property version   "1.003"
#property strict

const bool debug=false;
const bool verbose=false;
const bool print_result=false;

// ustawienie parametrów do metody Ichimoku
const int TS_parameter = 7;
const int KS_parameter = 28;
const int SSB_parameter= 119;
//----------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum CloudColor
  {
   green=0,
   red=1
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Indicators
  {
   bool              candleUpGreenCloud;
   bool              candleUpRedCloud;
   bool              candleDownRedCloud;
   bool              candleDownGreenCloud;

   bool              TSAboveKS;
   bool              KSAboveTS;
   bool              CSAboveOthersInPast;
   bool              CSBelowOthersInPast;
   bool              PriceAboveTS;
   bool              PriceBelowTS;
   bool              GreenCloundInTheFuture;
   bool              RedCloundInTheFuture;

   Indicators() 
     {
      candleUpGreenCloud=false;
      candleUpRedCloud=false;
      candleDownRedCloud=false;
      candleDownGreenCloud=false;

      TSAboveKS=false;
      KSAboveTS=false;
      CSAboveOthersInPast=false;
      CSBelowOthersInPast=false;
      PriceAboveTS=false;
      PriceBelowTS=false;
      GreenCloundInTheFuture=false;
      RedCloundInTheFuture=false; 
     }
  };
//+------------------------------------------------------------------+
//|   Trading functions                                              |
//+------------------------------------------------------------------+
void sell()
  {
   Print("Słaba tendencja spadkowa. Sprzedawaj!!! ",Time[1]);
   double price=Bid;

   Print("Ask=",Ask," Bid=",Bid);
//double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
//minstoplevel = MathMax(20, minstoplevel);
//Print("Minimum Stop Level=",minstoplevel," points");
//Print("Points", Point);
   double stoploss=NormalizeDouble(Ask+60*Point,Digits);
//double stoploss=NormalizeDouble(kijou_sen_current+30*Point,Digits); 
   double takeprofit=NormalizeDouble(Bid-60*Point,Digits);
//double takeprofit=NormalizeDouble(Bid-200*Point,Digits);
   Print("Price=",price," SL=",stoploss," TP=",takeprofit);
   int ticket=OrderSend(Symbol(),OP_SELL,1,price,3,stoploss,takeprofit,"Sell order",16384,0,clrGreen);
   if(ticket<0)
     {
      Print("OrderSend failed with error #",GetLastError());
     }
   else
     {
      Print("OrderSend placed successfully");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void buy()
  {
   Print("Silna tendencja wzrostowa. Kupuj!!! ",Time[1]);
   double price=Ask;
   Print("Ask=",Ask," Bid=",Bid);
//double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
//minstoplevel = MathMax(20, minstoplevel);
//Print("Minimum Stop Level=",minstoplevel," points");
   double stoploss=NormalizeDouble(Bid-60*Point,Digits);
//double stoploss=NormalizeDouble(kijou_sen_current-30*Point,Digits); 
   double takeprofit=NormalizeDouble(Ask+60*Point,Digits);
//double takeprofit=NormalizeDouble(Ask+200*Point,Digits);
   Print("Price=",price," SL=",stoploss," TP=",takeprofit);
   int ticket=OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"Buy order",16384,0,clrGreen);
   if(ticket<0)
     {
      Print("OrderSend failed with error #",GetLastError());
     }
   else
     {
      Print("OrderSend placed successfully");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicators calculateIndicators(ENUM_TIMEFRAMES period=PERIOD_M5)
  {
   Indicators indicators();

   double candle_open=Close[2]; // Hack, żeby poprawnie ustalić czy świeca opuściła chmurę.
   double candle_close=Close[1];
   double senkou_spanA_current = iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANA,1);
   double senkou_spanB_current = iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANB,1);
   CloudColor cloudColor=senkou_spanA_current>senkou_spanB_current ? green : red;

   double tenkan_sen_current=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_TENKANSEN,1);
   double kijou_sen_current=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_KIJUNSEN,1);

   double chikou_span_past=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_CHIKOUSPAN,KS_parameter+1);
   double senkou_spanA_past=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANA,KS_parameter+1);
   double senkou_spanB_past=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANB,KS_parameter+1);
   double tenkan_sen_past=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_TENKANSEN,KS_parameter+1);
   double kijou_sen_past=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_KIJUNSEN,KS_parameter+1);

   double senkou_spanA_future=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANA,-KS_parameter+1);
   double senkou_spanB_future=iIchimoku(NULL,period,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANB,-KS_parameter+1);

   if(verbose)
     {
      Print("Open price of the current bar of the current chart=",candle_open);
      Print("Close price of the current bar of the current chart=",candle_close);
      Print("Tenkan-Sen the current bar of the current chart=",tenkan_sen_current);
      Print("Kijou-Sen of the current bar of the current chart=",kijou_sen_current);
      Print("SSA current=",senkou_spanA_current);
      Print("SSB current=",senkou_spanB_current);

      Print("Chikou Span from ",KS_parameter," periods ago=",chikou_span_past);
      Print("Price from ",KS_parameter," periods ago=",Close[KS_parameter+1]);
      Print("Tenkan-Sen from ",KS_parameter," periods ago=",tenkan_sen_past);
      Print("Kijou-Sen from ",KS_parameter," periods ago=",kijou_sen_past);
      Print("SSA from ",KS_parameter," periods ago=",senkou_spanA_past);
      Print("SSB from ",KS_parameter," periods ago=",senkou_spanB_past);
      Print("Cloud color is ",EnumToString(cloudColor));
     }

   if(candle_close>candle_open && candle_close>senkou_spanA_current && candle_open<senkou_spanA_current && cloudColor==green)
     {
      if(debug) Print("Swieca wyszła wzrostowo z chmury wzrostowej. ",Time[1]);
      indicators.candleUpGreenCloud=true;
     }

   if(candle_close>candle_open && candle_close>senkou_spanB_current && candle_open<senkou_spanB_current && cloudColor==red)
     {
      if(debug) Print("Swieca wyszła wzrostowo z chmury spadkowej. ",Time[1]);
      indicators.candleUpRedCloud=true;
     }

   if(candle_close<candle_open && candle_close<senkou_spanA_current && candle_open>senkou_spanA_current && cloudColor==red)
     {
      if(debug)Print("Swieca wyszła spadkowo z chmury spadkowej. ",Time[1]);
       indicators.candleDownRedCloud=true;
     }

   if(candle_close<candle_open && candle_close<senkou_spanB_current && candle_open>senkou_spanB_current && cloudColor==green)
     {
      if(debug)Print("Swieca wyszła spadkowo z chmury wzrostowej. ",Time[1]);
       indicators.candleDownGreenCloud=true;
     }

   if(tenkan_sen_current>kijou_sen_current)
     {
      if(debug) Print("Tenkan-Sen jest powyzej Kijou-Sen. Tendencja wzrostowa. ",Time[1]);
      indicators.TSAboveKS=true;
     }

   if(tenkan_sen_current<kijou_sen_current)
     {
      if(debug)Print("Tenkan-Sen jest ponizej Kijou-Sen. Tendencja spadkowa. ",Time[1]);
      indicators.KSAboveTS=true;
     }

   if(chikou_span_past>senkou_spanA_past && chikou_span_past>senkou_spanB_past && chikou_span_past>kijou_sen_past && chikou_span_past>Close[KS_parameter+1])
     {
      if(debug) Print("Chikou Span sprzed ",KS_parameter," okresów ponad wszystkimi wskaźnikami. Tendencja wzrostowa. ",Time[1]);
      indicators.CSAboveOthersInPast=true;
     }

   if(chikou_span_past<senkou_spanA_past && chikou_span_past<senkou_spanB_past && chikou_span_past<kijou_sen_past && chikou_span_past<Close[KS_parameter+1])
     {
      if(debug) Print("Chikou Span sprzed ",KS_parameter," okresów poniżej wszystkich wskaźników. Tendencja spadkowa. ",Time[1]);
      indicators.CSBelowOthersInPast=true;
     }

   if(candle_close>tenkan_sen_current)
     {
      if(debug)Print("Cena jest powyzej Tenkan-Sen. Tendencja wzrostowa. ",Time[1]);
      indicators.PriceAboveTS=true;
     }

   if(candle_close<tenkan_sen_current)
     {
      if(debug)Print("Cena jest poniżej Tenkan-Sen. Tendencja spadkowa. ",Time[1]);
      indicators.PriceBelowTS=true;
     }

   if(senkou_spanA_future>senkou_spanB_future)
     {
      if(debug)Print("Chmura wzrostowa w przyszłości. Tendencja wzrostowa. ",Time[1]);
      indicators.GreenCloundInTheFuture=true;
     }

   if(senkou_spanA_future<senkou_spanB_future)
     {
      if(debug)Print("Chmura spadkowa w przyszłości. Tendencja spadkowa. ",Time[1]);
      indicators.RedCloundInTheFuture=true;
     }
   return indicators;
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Volume[0]==1)
     {
      datetime currentTime=TimeGMT();
      MqlDateTime mqlDateTime;
      TimeToStruct(currentTime,mqlDateTime);
      if(mqlDateTime.hour<6 || mqlDateTime.hour>20)
        {
         return;
        }
        
      // Indykatory policzone dla M5
      Indicators inds = calculateIndicators(PERIOD_M5);

      // mechanizm kupowania dla silnej tendencji wzrostowej
      if(inds.candleUpGreenCloud && inds.TSAboveKS && inds.CSAboveOthersInPast && inds.PriceAboveTS && inds.GreenCloundInTheFuture && true) // jeśli spełnione wszystkie warunki to kupuj
        {
         buy();
        }
      //---------------------------------------------------

      // mechanizm sprzedawania dla silnej tendencji spadkowej
      if(inds.candleDownRedCloud && inds.KSAboveTS && inds.CSBelowOthersInPast && inds.PriceBelowTS && inds.RedCloundInTheFuture && true) // żeby wyłączyć sprzedawanie zmien 'true' na 'false' w tej lini
        {
         sell();
        }
      //---------------------------------------------------

      // mechanizm kupowania dla słabej tendencji wzrostowej
      if(inds.candleUpRedCloud && inds.TSAboveKS && inds.CSAboveOthersInPast && inds.PriceAboveTS && inds.GreenCloundInTheFuture && true) // żeby wyłączyć sprzedawanie zmien 'true' na 'false' w tej lini
        {
         buy();
        }
      //---------------------------------------------------

      // mechanizm sprzedawania dla słabej tendencji spadkowej
      if(inds.candleDownGreenCloud && inds.KSAboveTS && inds.CSBelowOthersInPast && inds.PriceBelowTS && inds.RedCloundInTheFuture && true) // żeby wyłączyć sprzedawanie zmien 'true' na 'false' w tej lini
        {
         sell();
        }
     }
  }
//+------------------------------------------------------------------+
