enum SIGNAL_MODE{
   EXIT_CROSS_NORMAL,      // exit cross normal
   ENTRY_CROSS_NORMAL,     // entry cross normal
   EXIT_CROSS_REVERSED,    // exit cross reversed
   ENTRY_CROSS_REVERSED,   // entry cross reversed
};
enum ENUM_CUSTOM_PERF_CRITERIUM_METHOD
{
   NO_CUSTOM_METRIC,                            //No Custom Metric
   STANDARD_PROFIT_FACTOR,                      //Standard Profit Factor
   MODIFIED_PROFIT_FACTOR                       //Modified Profit Factor
};
enum ENUM_DIAGNOSTIC_LOGGING_LEVEL
{
   DIAG_LOGGING_NONE,                           //NONE
   DIAG_LOGGING_LOW,                            //LOW - Major Diagnostics Only
   DIAG_LOGGING_HIGH                            //HIGH - All Diagnostics (Warning - Use with caution)
};
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "==== General ====";
static input long       InpMagicNumber = 23857236;          // magicnumber
static input double     InpLotSize     = 0.01;              // lot size
input ENUM_TIMEFRAMES   InpTimeframe   = PERIOD_H1;         // timeframe
input group "=== Custom Criteria ==="
input ENUM_CUSTOM_PERF_CRITERIUM_METHOD   InpCustomPerfCriterium    = MODIFIED_PROFIT_FACTOR;   //Custom Performance Criterium
input ENUM_DIAGNOSTIC_LOGGING_LEVEL       InpDiagnosticLoggingLevel = DIAG_LOGGING_LOW;         //Diagnostic Logging Level
input group "==== Trading ====";
input SIGNAL_MODE       InpSignalMode  = EXIT_CROSS_NORMAL; //signal mode
input int               InpStopLoss    = 200;               // stop loss in points (0=off)
input int               InpTakeProfit  = 0;                 // take profit in points (0=off)
input bool              InpCloseSignal = false;             // close trades by opposite signal
input group "==== Stochastic RSI ====";
input int               InpKPeriod     = 21;                // K period
input int               InpDPeriod     = 1;                 // D period
input int               InpSlowing     = 3;                 // slowing value
input int               InpUpperLevel  = 80;                // upper level
input group "==== Clear bars filter ====";
//(if there are {InpClearBarsReversed?no:yes} crosses among the last {InpClearBars} bars (counting from index 2), then prevent opening trades)
input bool              InpClearBarsReversed = false;       // reverse clear bar filter
input int               InpClearBars = 0;                   // clear bars (0=off)

// checks user input
bool CheckInputs(){
   if(InpMagicNumber<=0){
      Alert("Wrong input: Magicnumber <= 0");
      return false;
   }
   if(InpLotSize<=0){
      Alert("Wrong input: Lot size <= 0");
      return false;
   }
   if(InpStopLoss<0){
      Alert("Wrong input: Stop loss < 0");
      return false;
   }
   if(InpTakeProfit<0){
      Alert("Wrong input: Take profit < 0");
      return false;
   }
   if(!InpCloseSignal && InpStopLoss==0){
      Alert("Wrong input: Close signal is false and no stop loss");
      return false;
   }
   if(InpKPeriod<=0){
      Alert("Wrong input: K period <=0");
      return false;
   }
   if(InpDPeriod<=0){
      Alert("Wrong input: D period <=0");
      return false;
   }
   if(InpSlowing<=0){
      Alert("Wrong input: Slowing <=0");
      return false;
   }
   if(InpUpperLevel<=50||InpUpperLevel>=100){
      Alert("Wrong input: Upper level <= 50 or >=100");
      return false;
   }
   if(InpClearBars<0){
      Alert("Wrong input: Clear bars < 0");
      return false;
   }
   return true;
}