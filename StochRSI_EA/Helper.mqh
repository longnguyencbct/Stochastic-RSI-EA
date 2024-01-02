//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+
#include "InpConfig.mqh"
#include "GlobalVar.mqh"

// check if we have a bar open tick
bool IsNewBar(){
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol,InpTimeframe,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}

// count open positions
bool CountOpenPositions(int &cntBuy, int &cntSell){
   cntBuy = 0;
   cntSell = 0;
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket");return false;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position");return false;}
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get position magicnumber");return false;}
      if(magic==InpMagicNumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return false;}
         if(type==POSITION_TYPE_BUY){cntBuy++;}
         if(type==POSITION_TYPE_SELL){cntSell++;}
      }
   }
   return true;
}

// normalize price
bool NormalizePrice(double &price){

   double tickSize=0;
   if(!SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE,tickSize)){
      Print("Failed to get tick size");
      return false;
   }
   price = NormalizeDouble(MathRound(price/tickSize)*tickSize,_Digits);
   
   return true;
}

// close positions
bool ClosePositions(int all_buy_sell){
   int total = PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket<=0){Print("Failed to get position ticket");return false;}
      if(!PositionSelectByTicket(ticket)){Print("Failed to select position");return false;}
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get position magicnumber");return false;}
      if(magic==InpMagicNumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get position type");return false;}
         if(all_buy_sell==1&&type==POSITION_TYPE_SELL){continue;}
         if(all_buy_sell==2&&type==POSITION_TYPE_BUY){continue;}
         trade.PositionClose(ticket);
         if(trade.ResultRetcode()!=TRADE_RETCODE_DONE){
            Print("Failed to close position, ticket:",
            (string) ticket,", result:",(string)trade.ResultRetcode(),":",trade.CheckResultRetcodeDescription());
         }
      }
   }
   return true;
}