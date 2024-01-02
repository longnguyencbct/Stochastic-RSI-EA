#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Open Condition functions                                         |
//+------------------------------------------------------------------+

// check for new signals
bool CheckSignal(bool buy_sell, int cntBuySell){

   // return false if a position is open
   if(cntBuySell>0){return false;}
   
   //check crossovers
   int lowerLevel = 100 - InpUpperLevel;
   bool upperExitCross = bufferMain[1]>=InpUpperLevel&&bufferMain[2]<InpUpperLevel;
   
   bool upperEntryCross = bufferMain[1]<=InpUpperLevel&&bufferMain[2]>InpUpperLevel;
   
   bool lowerExitCross = bufferMain[1]<=lowerLevel&&bufferMain[2]>lowerLevel;
   
   bool lowerEntryCross = bufferMain[1]>=lowerLevel&&bufferMain[2]<lowerLevel;

   // check signal
   switch(InpSignalMode){
      case EXIT_CROSS_NORMAL:       return ((buy_sell&&lowerExitCross)||(!buy_sell&&upperExitCross));       // buy at lower exit cross, sell at upper exit cross
      case ENTRY_CROSS_NORMAL:      return ((buy_sell&&lowerEntryCross)||(!buy_sell&&upperEntryCross));     // buy at lower entry cross, sell at upper entry cross
      case EXIT_CROSS_REVERSED:     return ((buy_sell&&upperExitCross)||(!buy_sell&&lowerExitCross));       // buy at upper exit cross, sell at lower exit cross
      case ENTRY_CROSS_REVERSED:    return ((buy_sell&&upperEntryCross)||(!buy_sell&&lowerEntryCross));     // buy at upper entry cross, sell at lower entry cross
      
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Clear Bars Filter functions                                      |
//+------------------------------------------------------------------+

// check clear bars filter
bool CheckClearBars(bool buy_sell){
   
   // return true if filter is inactive
   if(InpClearBars==0){return true;}
   
   bool checkLower = ((buy_sell&&(InpSignalMode==EXIT_CROSS_NORMAL||InpSignalMode==ENTRY_CROSS_NORMAL))
                     ||(!buy_sell&&(InpSignalMode==EXIT_CROSS_REVERSED||InpSignalMode==ENTRY_CROSS_REVERSED)));
   
   for(int i=3;i<(3+InpClearBars);i++){
      
      //check upper level
      if(!checkLower&&(  (bufferMain[i-1]>InpUpperLevel&&bufferMain[i]<=InpUpperLevel)
      ||  (bufferMain[i-1]<InpUpperLevel&&bufferMain[i]>=InpUpperLevel)  ) ){// if upper level cross detected
      
         if(InpClearBarsReversed){return true;}
         else{
            Print("Clear bars filter prevented ",buy_sell?"buy":"sell"," signal. Cross of upper level at index ",(i-1),"->",i);
            return false;
         }
      }
      
      // check lower level
      int lowerLevel=100-InpUpperLevel;
      if(checkLower&&(  (bufferMain[i-1]<lowerLevel&&bufferMain[i]>=lowerLevel)
      ||  (bufferMain[i-1]>lowerLevel&&bufferMain[i]<=lowerLevel)  ) ){// if lower level cross detected
      
         if(InpClearBarsReversed){return true;}
         else{
            Print("Clear bars filter prevented ",buy_sell?"buy":"sell"," signal. Cross of lower level at index ",(i-1),"->",i);
            return false;
         }
      }
   }
   // if no cross detected
   if(InpClearBarsReversed){
      Print("Clear bars filter prevented ",buy_sell?"buy":"sell"," signal. No cross detected");
      return false;
   }else{
      return true;
   }
}