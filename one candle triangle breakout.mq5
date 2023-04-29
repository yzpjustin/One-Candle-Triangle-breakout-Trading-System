//+------------------------------------------------------------------+
//|                                 one candle triangle breakout.mq5 |
//|                                                     yin zhanpeng |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "yin zhanpeng"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

input double lot = 0.01; // lot size
input bool reverse_trade = false; // Reverse Trade
input int magic_num = 123; //Magic Number

input double tp_mult = 2; // TP muliplier
input double sl_mult = 1;  // SL muliplier

input bool time_fil = false; // Time Filter
input string start_t = "02:00"; // Start Trading time
input string end_t = "24:00";  // End Trading time
bool allow_trading = false;

string current_time;
int OnInit()
  {

   trade.SetExpertMagicNumber(magic_num);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {



   datetime time = TimeLocal();
   current_time = TimeToString(time,TIME_MINUTES);

   double close_3 = iClose(_Symbol,PERIOD_CURRENT,3);
   double open_3 = iOpen(_Symbol,PERIOD_CURRENT,3);
   double high_3 = iHigh(_Symbol,PERIOD_CURRENT,3);
   double low_3 = iLow(_Symbol,PERIOD_CURRENT,3);

   double close_2 = iClose(_Symbol,PERIOD_CURRENT,2);
   double open_2 = iOpen(_Symbol,PERIOD_CURRENT,2);
   double high_2 = iHigh(_Symbol,PERIOD_CURRENT,2);
   double low_2 = iLow(_Symbol,PERIOD_CURRENT,2);

   double close_1 = iClose(_Symbol,PERIOD_CURRENT,1);
   double open_1 = iOpen(_Symbol,PERIOD_CURRENT,1);
   double high_1 = iHigh(_Symbol,PERIOD_CURRENT,1);
   double low_1 = iLow(_Symbol,PERIOD_CURRENT,1);
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);


   double sub_close;  // checking A

// time filter

   check_trading_time();

   if(time_fil == false)
     {
      allow_trading = true;
     }



// cancel ordes
   if(OrdersTotal() == 2 && sub_close != close_1 && high_3 > high_2 && high_3 > high_1 && low_3 < low_2 && low_3 < low_1)   // checking for new cnadle A
     {
      cancel_order();

     }
   if(PositionsTotal() == 0 && OrdersTotal() == 1 &&(bid > high_2 || bid < low_2))     // check for unsual order B
     {

      cancel_order();
     }

   if(equity != balance)
      cancel_order();

// logic
   if(high_3 > high_2 && high_3 > high_1 && low_3 < low_2 && low_3 < low_1 && PositionsTotal() == 0 && OrdersTotal() == 0 && bid < high_2 && bid > low_2 && allow_trading == true)
     {

      ObjectCreate(0,"high1",OBJ_HLINE,0,0,high_2);
      ObjectCreate(0,"low1",OBJ_HLINE,0,0,low_2);


      // revers trades


      if(reverse_trade == false)
        {

         double buy_tp = high_3 + (high_3 - low_3)*tp_mult;
         double buy_sl = high_3 - (high_3 - low_3)*sl_mult;

         double sell_sl = low_3 + (high_3 - low_3)*sl_mult;
         double sell_tp = low_3 - (high_3 - low_3)*tp_mult;


         NormalizeDouble(buy_tp,_Digits);
         NormalizeDouble(buy_sl,_Digits);

         NormalizeDouble(sell_tp,_Digits);
         NormalizeDouble(sell_sl,_Digits);

         trade.BuyStop(lot,high_3,_Symbol,low_2,buy_tp);
         trade.SellStop(lot,low_3,_Symbol,high_2,sell_tp);

         sub_close = close_1;

        }
      if(reverse_trade == true)
        {

         double sell_limit_sl = high_3 + (high_3 - low_3)*sl_mult;
         double sell_limit_tp = high_3 - (high_3 - low_3)*tp_mult;

         double buy_limit_sl = low_3 - (high_3 - low_3)*sl_mult;
         double buy_limit_tp = low_3 + (high_3 - low_3)*tp_mult;

         NormalizeDouble(sell_limit_sl,_Digits);
         NormalizeDouble(sell_limit_tp,_Digits);

         NormalizeDouble(buy_limit_sl,_Digits);
         NormalizeDouble(buy_limit_tp,_Digits);

         trade.SellLimit(lot,high_3,_Symbol,sell_limit_sl,sell_limit_tp);
         trade.BuyLimit(lot,low_3,_Symbol,buy_limit_sl,buy_limit_tp);
         sub_close = close_1;

        }




     }





  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cancel_order()     // cancel pending orders
  {
   for(int i = OrdersTotal()-1; i>=0; i--)
     {
      ulong orderticket = OrderGetTicket(i);
      trade.OrderDelete(orderticket);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool check_trading_time()   // check trading time
  {
   if(StringSubstr(current_time,0,-1) == start_t)
     {
      allow_trading = true;
     }
   if(StringSubstr(current_time,0,-1) == end_t)
     {
      allow_trading = false;
     }
   return allow_trading;
  }
//+------------------------------------------------------------------+
