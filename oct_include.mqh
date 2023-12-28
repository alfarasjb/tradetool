//###<Experts/B63/b63-mt4-experts/Prod/oct/TradeTool.mq4>


#property strict

#include <B63/CObjects.mqh>
#include <B63/TradeOperations.mqh>
#include <B63/Generic.mqh>
#include "ui.mqh"
#include "tests/tests.mqh"
#include "definition.mqh"
// SCREEN ADJUSTMENTS // 


// ENUM AND STRUCT //


struct STrade{
   double entry;
   double stop;
   double target;
   float volume;
   bool slOn;
   bool tpOn;
   bool volOn;
   int stopPts;
   int tpPts;
   
   void update(
      double InpEntry, 
      double InpStop, 
      double InpTarget, 
      float InpVolume, 
      double InpSLOn, 
      double InpTPOn, 
      double InpVolOn, 
      int InpSLPts, 
      int InpTPPts) {
      
      entry = InpEntry;
      stop = InpStop;
      target = InpTarget;
      volume = InpVolume == 0 ? (float)InpDefLots : (float)normLot(InpVolume);
      slOn = InpSLOn;
      tpOn = InpTPOn;
      volOn = InpVolOn;
      stopPts = InpSLPts;
      tpPts = InpTPPts;
      
   }
   
   void update(){
      update(0, 0, 0, volume, slOn, tpOn, volOn, stopPts, tpPts);
   }
   
   STrade(){
      update();
   }
   
   void reInit(double lot){
      entry = 0;
      stop = 0;
      target = 0;
      volume = (float)lot;
   }
};

struct SMarket{
   double minLot;
   double maxLot;
   double lotStep;
   int digits;
   double contract;
   
   SMarket(){
      minLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MIN);
      maxLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MAX);
      lotStep  = SymbolInfoDouble(Sym, SYMBOL_VOLUME_STEP);
      digits   = (int)SymbolInfoInteger(Sym, SYMBOL_DIGITS);
      contract = SymbolInfoDouble(Sym, SYMBOL_TRADE_CONTRACT_SIZE);
   }
   
   void reInit(){ 
      minLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MIN);
      maxLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MAX);
      lotStep  = SymbolInfoDouble(Sym, SYMBOL_VOLUME_STEP);
      digits   = (int)SymbolInfoInteger(Sym, SYMBOL_DIGITS);
      contract = SymbolInfoDouble(Sym, SYMBOL_TRADE_CONTRACT_SIZE);
   }
   
   
};

input int      InpMagic       = 232323; //Magic Number
MODE    InpMode        = Points; //Mode (Price/Points)
input double   InpDefLots     = 0.01; //Volume
input int      InpDefStop     = 200; //Default SL (Points)
input int      InpDefTP       = 200; //Default TP (Points)
input int      InpPointsStep  = 100; //Step (Points)
input bool     InpRunTests    = false; // Run Unit Tests


CTradeOperations op();

STrade trade;
STrade errTrade;
SMarket market;



static double slInput = InpDefStop;
static double tpInput = InpDefTP;
static string Sym;
static bool   MarketOpen;
static bool   TradeDisabled;
static bool   TradingDay;
static bool   TradingSession;
MARKET_STATUS MarketStatus;




int OnInit() {
   
   initData();
   
   //tradetool_app_beta.InitializeUIElements();
   tradetool_app.InitializeUIElements();
   tradetool_app.UpdatePrice(norm(ask()), norm(bid()));
   textFields();
   if (InpRunTests) tradetool_tests.run_test();
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)  { ObjectsDeleteAll(0, 0, -1); }
void OnTick()                    { tradetool_app.UpdatePrice(norm(ask()), norm(bid())); }

MARKET_STATUS status(){
   if (TradeDisabled) return TradingDisabled;
   if (TradingDay && TradingSession) return MarketIsOpen;
   return MarketIsClosed;
}
  
void initData(){
   Sym = Symbol();
   
   TradingDay = IsTradingDay(TimeCurrent());
   TradeDisabled= IsTradeDisabled(Sym);
   TradingSession = IsInSession(TimeCurrent());
   MarketStatus = status();
   
   market.reInit();
   //trade.reInit(market.minLot);
   trade.update();
   switch(InpMode){
      case Points:
         //slInput = InpDefPoints;
         //tpInput = InpDefPoints;
         break;
      case Price:
         slInput = bid();
         tpInput = bid();
         break;
      default:
         break;
   }
}

void OnChartEvent(const int id, const long &lparam, const double &daram, const string &sparam){
   PrintFormat("ID: %i, LPARAM: %i, DARAM: %f, SPARAM: %s", id, lparam, daram, sparam);
   
   if (CHARTEVENT_OBJECT_CLICK){  
      if (sparam == tradetool_app.market_buy.button_name) {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY);
         if (ret < 0) error(ret);
      }
      if (sparam == tradetool_app.market_sell.button_name) {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_SELL);
         if (ret < 0) error(ret);
      }
      if (sparam == tradetool_app.buy_limit.button_name) {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY_LIMIT);
         if (ret < 0) error(ret);
         
      }
      if (sparam == tradetool_app.sell_limit.button_name) {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_SELL_LIMIT);
         if (ret < 0) error(ret);
      }
      if (sparam == tradetool_app.buy_stop.button_name){
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY_STOP);
         if (ret < 0) error(ret);
      }
      if (sparam == tradetool_app.sell_stop.button_name){
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_SELL_STOP);
         if (ret < 0) error(ret);
      }
      
      if (sparam == "BTEDITSL+")        { slInput = adj(slInput, InpPointsStep, slRow, sparam); }
      if (sparam == "BTEDITSL-")        { slInput = adj(slInput, -InpPointsStep, minPoints(), slRow,  sparam); }
      
      if (sparam == "BTEDITTP+")        { tpInput = adj(tpInput, InpPointsStep, tpRow,sparam); }  
      if (sparam == "BTEDITTP-")        { tpInput = adj(tpInput, -InpPointsStep, minPoints(), tpRow, sparam); }
      
      if (sparam == "BTEDITVOL+" )      { trade.volume = (float)adj(normLot(trade.volume), market.lotStep, market.maxLot, volRow, sparam); }
      if (sparam == "BTEDITVOL-")       { trade.volume = (float)adj(normLot(trade.volume), -market.lotStep, market.minLot, volRow, sparam); }
      
      if (sparam == "BTEDITPENDING+")   { 
         if (trade.entry == 0) trade.entry = bid();
         trade.entry = normLot(adj(trade.entry, normLot(InpPointsStep) / market.contract, poRow, sparam), market.digits);
      }
      if (sparam == "BTEDITPENDING-")   {
         if (trade.entry == 0) trade.entry = ask();
         trade.entry = normLot(adj(trade.entry, -normLot(InpPointsStep) / market.contract, poRow, sparam), market.digits);
      }
      
      if (swButton(1, sparam))     { trade.slOn = toggle(trade.slOn, slRow); }
      if (swButton(2, sparam))     { trade.tpOn = toggle(trade.tpOn, tpRow); }
   }
   if (CHARTEVENT_OBJECT_ENDEDIT){
      if (sparam == "EDITSL"){
         double val = StringToDouble(getText(sparam));
         slInput = !minPoints(val) ? val : 0;
         slRow();
      }
      if (sparam == "EDITTP"){
         double val = StringToDouble(getText(sparam));
         tpInput = !minPoints(val) ? val : 0;
         tpRow();
      }
      if (sparam == "EDITVOL"){
         double val = StringToDouble(getText(sparam));
         trade.volume = !minLot(val) ? !maxLot(val) ? (float)val : (float)market.maxLot : (float)market.minLot;
         volRow();
      }
      if (sparam == "EDITPENDING"){
         double val = StringToDouble(getText(sparam));
         trade.entry = val;
         poRow();
      }
   }
   ChartRedraw();
}

bool swButton(int sw, string sparam){

   bool ret = False;
   
   switch(sw){
   
      case 1: 
         if (sparam == "BTSLBOOL" || sparam == "BTSLBOOLNOT") ret = true;
         break;
      case 2:
         if (sparam == "BTTPBOOL" || sparam == "BTTPBOOLNOT") ret = true;
         break;
      default:
         ret = False;
         break;
   }
   return ret;
}

// ERROR HANDLING //

void error(int e){

#ifdef __MQL4__
const int ErrTradeDisabled    = 133;
const int ErrMarketClosed     = 132;
const int ErrBadVol           = 131;
const int ErrBadStops         = 130;
const int ErrAutoTrading      = 4109;
#endif


#ifdef __MQL5__
const int ErrTradeDisabled    = 10017;
const int ErrMarketClosed     = 10018;
const int ErrBadVol           = 10014;
const int ErrBadStops         = 10016;
#endif

const int errorCode = GetLastError();

   switch(e){
   
      case 0:
         if (errorCode == ErrTradeDisabled) logger("Order Send Failed. Trading is disabled for current symbol");
         if (errorCode == ErrMarketClosed) logger("Order Send Failed. Market is closed.");
         if (errorCode == ErrBadVol) logger(StringFormat("Order Send Error: Invalid Volume. Vol: %f", errTrade.volume));
         if (errorCode == ErrBadStops) logger(StringFormat("Order Send Error: Invalid Stops. SL: %f, TP: %f", errTrade.stop, errTrade.target));
         if (errorCode == ErrAutoTrading) logger("Order Send Failed. Auto Trading is Disabled.");
         break;
      case -10:
         logger(StringFormat("%s Market Buy. Price: %f, SL: %f, TP: %f", ask(), errTrade.entry, errTrade.stop, errTrade.target)); 
         break;
      case -20:
         logger(StringFormat("%s Market Sell. Price: %f, SL: %f, TP: %f", bid(), errTrade.entry, errTrade.stop, errTrade.target)); 
         break;
      case -30: 
         logger(StringFormat("%s Buy Limit. Price: %f, SL: %f, TP: %f", invalid_order(), errTrade.entry, errTrade.stop, errTrade.target)); 
         break; 
      case -40: 
         logger(StringFormat("%s Sell Limit. Price: %f, SL: %f, TP: %f", invalid_order(), errTrade.entry, errTrade.stop, errTrade.target)); 
         break; 
      case -50: 
         logger(StringFormat("%s Buy Stop. Price: %f, SL: %f, TP: %f", invalid_order(), errTrade.entry, errTrade.stop, errTrade.target)); 
         break;
      case -60: 
         logger(StringFormat("%s Sell Stop. Price: %f, SL: %f, TP: %f", invalid_order(), errTrade.entry, errTrade.stop, errTrade.target)); 
         break;
      default:
         logger(StringFormat("Order Send Failed. Code: %i", e));
         break;
   }
}

string invalid_order()        { return "Invalid Order Parameters for "; }
void logger(string message)   { PrintFormat("LOGGER: %s", message); }

// ERROR HANDLING // 

// BUTTON FUNCTIONS //

// TYPEDEF (SEE DOCS)
// SYNTAX 
//  typedef type new_name;
// typedef function_result_type (*Function_name_type)(list_of_input_parameters_types);
typedef void (*Togg)(bool state);
typedef void (*Adj)(double inp);


bool toggle(bool toggle, Togg rowFunc){
   // SOLUTION: Created overload which accepts state bool 
   toggle =! toggle;
   rowFunc(toggle);
   return toggle;   
}

double adj(double inp, double step, Adj rowFunc, string sparam){

   return adj (inp, step, -1, rowFunc, sparam);
}

double adj(double inp, double step, double limit, Adj rowFunc, string sparam){

   double val = inp + step;
   resetObject(sparam);
   if (step < 0 && limit >= 0 && inp <= limit) return inp;
   if (step > 0 && limit >= 0 && inp >= limit) return inp;
   rowFunc(val);
   return val;
}

int sendOrd(ENUM_ORDER_TYPE ord){

   double val = StringToDouble(getText("EDITVOL"));
   tradeParams(ord);
   double entry = trade.entry;
   double sl = trade.stop;
   double tp = trade.target;
   
   int ticket = op.SendOrder(ord, val, trade.entry, sl, tp, InpMagic);
   logger(StringFormat("ORDER: %s, Volume: %f, Entry: %f, SL: %f, TP: %f", EnumToString(ord), val, entry, sl, tp));
   
   if (ticket < 0) {
   
      errTrade.stop = sl;
      errTrade.target = tp;
      errTrade.volume = trade.volume;
      errTrade.entry = entry;
      
      switch(ord){
      
         case 0: 
            // market buy
            if ((sl > 0 && tp > 0)  && (sl > tp || sl > ask() || ask() > tp)) return -10;
            break; 
         case 1: 
            // market sell
            if ((sl > 0 && tp > 0) && (tp > sl || tp > bid() || bid() > sl)) return -20;
            break; 
         case 2:
            // buy limit
            if ((entry > ask() || sl > ask() || entry < tp)) return -30;
            break;
         case 3:
            // sell limit
            if ((bid() > entry || bid() > sl || tp > entry)) return -40; 
            break;
         case 4: 
            // buy stop
            if (entry < ask()) return -50; 
            break;
         case 5: 
            // sell stop 
            if (entry > bid()) return -60;
            break;
         default: 
            break; 
      }
      error(0);
   }
   
   return ticket;
}


// BUTTON FUNCTIONS //

// MISC FUNCTIONS //
string norm(double val)             { return DoubleToString(val, market.digits); }
string norm(double val, int digits) { return DoubleToString(val, digits); }

double minPoints()                  { return 0; }

bool minPoints(double points){
   if (points > 0) return false;
   return true;
}

bool minLot(double lot){

   if (lot > market.minLot) return false;
   return true;
}

bool maxLot(double lot){

   if (lot < market.maxLot) return false;
   return true;
}

void tradeParams(ENUM_ORDER_TYPE ord){

   double sl = getValues("EDITSL");
   double tp = getValues("EDITTP");
   double vol = getValues("EDITVOL");
   double pending_price = getValues("EDITPENDING");
   double stop = 0;
   double target = 0;
   if (InpMode == Points){
      switch(ord){
      
         case 0: 
            stop = trade.slOn ? sl != 0 ? ask() - sl * point() : 0 : 0;
            target = trade.tpOn ? tp != 0 ? ask() + tp * point() : 0 : 0;
            trade.update(ask(), stop, target, (float)vol, trade.slOn, trade.tpOn, true,(int)sl, (int)tp);
            break; 
            
         case 1:
            stop = trade.slOn ? sl!= 0 ? bid() + sl * point() : 0 : 0;
            target = trade.tpOn ? tp!= 0 ? bid() - tp * point() : 0 : 0;
            trade.update(bid(), stop, target, (float)vol, trade.slOn, trade.tpOn, true, (int)sl, (int)tp);
            break;
            
         case 2: 
         case 4:
            stop = trade.slOn ? sl != 0 ? pending_price - sl * point() : 0 : 0;
            target = trade.tpOn ? tp != 0 ? pending_price + tp * point() : 0 : 0;
            trade.update(pending_price, stop, target, (float)vol, trade.slOn, trade.tpOn, true, (int)sl, (int)tp);
            break;
            
         case 3: 
         case 5:
            stop = trade.slOn ? sl != 0 ? pending_price + sl * point() : 0 : 0;
            target = trade.tpOn ? tp != 0 ? pending_price - tp * point() : 0 : 0;
            trade.update(pending_price, stop, target, (float)vol, trade.slOn, trade.tpOn, true, (int)sl, (int)tp);
            break;
            
       
         default:
            break;
      }
      
   }
   if (InpMode == Price){
      trade.stop = sl;
      trade.target = tp;
   } 
}


// WRAPPER //
string getText(string sparam)          { return ObjectGetString(0, sparam, OBJPROP_TEXT); }
double getValues(string sparam)        { return StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT)); }
bool getBool(string sparam)            { return (bool)ObjectGetInteger(0, sparam, OBJPROP_STATE); }
double point()                         { return SymbolInfoDouble(Sym, SYMBOL_POINT); }
double normLot(double lot)             { return normLot(lot, 2); }
double normLot(double lot, int digits) { return NormalizeDouble(lot, digits); }
#ifdef __MQL4__
double ask()   { return SymbolInfoDouble(Sym, SYMBOL_ASK); }
double bid()   { return SymbolInfoDouble(Sym, SYMBOL_BID); }

#endif

#ifdef __MQL5__
double ask()   { return SymbolInfoDouble(Sym, SYMBOL_ASK); }
double bid()   { return SymbolInfoDouble(Sym, SYMBOL_BID); }

#endif



