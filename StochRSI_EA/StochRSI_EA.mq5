//+------------------------------------------------------------------+
//|                                                  StochRSI_EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include "InpConfig.mqh"
#include "Helper.mqh"
#include "GlobalVar.mqh"
#include "OpenCond.mqh"
#include "CustomCriteria.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // check user inputs
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   
   // set magicnumber to trade object
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   // create indicator handle
   handle = iStochastic(_Symbol,InpTimeframe,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,STO_LOWHIGH);
   if(handle==INVALID_HANDLE){
      Alert("Failed to create indicator handle");
      return INIT_FAILED;
   }
   
   // set buffer as series
   ArraySetAsSeries(bufferMain,true);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // release indicator handle
   if(handle!=INVALID_HANDLE){
      IndicatorRelease(handle);
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // check for bar open tick
   if(!IsNewBar()){return;}
   
   // get current tick
   if(!SymbolInfoTick(_Symbol,cT)){Print("Failed to get current symbol tick"); return;}
   
   // get indicator values
   if(CopyBuffer(handle,0,0,3+InpClearBars,bufferMain)!=(3+InpClearBars)){
      Print("Failed to get indicator values");
      return;
   }
   
   // count open positions
   int cntBuy, cntSell;
   if(!CountOpenPositions(cntBuy,cntSell)){
      Print("Failed to count open positions");
      return;
   }
   
   // check for buy position
   if(CheckSignal(true,cntBuy)&&CheckClearBars(true)){
      Print("Open buy position");
      
      if(InpCloseSignal){if(!ClosePositions(2)){return;}} // close all sell positions
      double sl = InpStopLoss==0 ? 0 : cT.bid - InpStopLoss*_Point;
      double tp = InpTakeProfit==0 ? 0 : cT.bid + InpTakeProfit*_Point;
      if(!NormalizePrice(sl)){return;}
      if(!NormalizePrice(tp)){return;}
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLotSize,cT.ask,sl,tp,"Stochastic EA");
   }
   
   // check for sell position
   if(CheckSignal(false,cntSell)&&CheckClearBars(false)){
      Print("Open sell position");
      
      if(InpCloseSignal){if(!ClosePositions(1)){return;}} // close all buy positions
      double sl = InpStopLoss==0 ? 0 : cT.ask + InpStopLoss*_Point;
      double tp = InpTakeProfit==0 ? 0 : cT.ask - InpTakeProfit*_Point;
      if(!NormalizePrice(sl)){return;}
      if(!NormalizePrice(tp)){return;}
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,InpLotSize,cT.bid,sl,tp,"Stochastic EA");
   }
}
//+------------------------------------------------------------------+
//| Expert Test function                                             |
//+------------------------------------------------------------------+
double OnTester()  
{
   double customPerformanceMetric;  
   
   if(InpCustomPerfCriterium == STANDARD_PROFIT_FACTOR)
   {
      customPerformanceMetric = TesterStatistics(STAT_PROFIT_FACTOR);
   }
   else if(InpCustomPerfCriterium == MODIFIED_PROFIT_FACTOR)
   {
      int numTrades = ModifiedProfitFactor(customPerformanceMetric);
      
      //IF NUMBER OF TRADES < 250 THEN NO STATISTICAL SIGNIFICANCE, SO DISREGARD RESULTS (PROBABLE THAT GOOD 
      //RESULTS CAUSED BY RANDOM CHANCE / LUCK, THAT WOULD NOT BE REPEATABLE IN FUTURE PERFORMANCE)
      if(numTrades < 250)
         customPerformanceMetric = 0.0;
   } 
   else if(InpCustomPerfCriterium == NO_CUSTOM_METRIC)
   {
      customPerformanceMetric = 0.0;
   }
   else
   {
      Print("Error: Custom Performance Criterium requested (", EnumToString(InpCustomPerfCriterium), ") not implemented in OnTester()");
      customPerformanceMetric = 0.0;
   }
   
   Print("Custom Perfromance Metric = ", DoubleToString(customPerformanceMetric, 3));
   
   return customPerformanceMetric;
}
//+------------------------------------------------------------------+