//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int handle;          // handle of the stochastic indicator
double bufferMain[]; // buffer for indicator values
MqlTick cT;          // current tick object to access prices and time
CTrade trade;        // object to open and close positions