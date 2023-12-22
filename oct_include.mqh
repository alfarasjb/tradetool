
#define app_copyright "Copyright 2023, block63"
#define app_version  "1.11"
#define app_description "A basic order management solution that allows Stop Loss and Take Profit levels to be automatically placed on market orders based on set POINTS distance."
#property strict

#include <B63/CObjects.mqh>
#include <B63/TradeOperations.mqh>
#include <B63/Generic.mqh>
#include "ui.mqh"
#include "tests/tests.mqh"
// SCREEN ADJUSTMENTS // 
int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
int scale_factor = (screen_dpi * 100) / 96;
ENUM_BASE_CORNER DefCorner = CORNER_LEFT_LOWER;

// ENUM AND STRUCT //

enum EMode{
   Points = 1,
   Price = 2,
};

struct SBTName{
   string plus;
   string minus;
   string toggle;
   
   SBTName(){
      plus = "";
      minus = "";
      toggle = "";
   }
};


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
   
   void update(double InpEntry, double InpStop, double InpTarget, float InpVolume, double InpSLOn, double InpTPOn, double InpVolOn, int InpSLPts, int InpTPPts){
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

struct InitSettings{
   int defX;
   int defY;
   string font;
   string font_bold; 
   
   InitSettings(){
      defX = 5; 
      defY = 315;
      font = "Segoe UI Semibold";
      font_bold = "Segoe UI Bold";
   }
};

InitSettings settings;

input int      InpMagic       = 232323; //Magic Number
EMode    InpMode        = Points; //Mode (Price/Points)
input double   InpDefLots     = 0.01; //Volume
input int      InpDefStop     = 200; //Default SL (Points)
input int      InpDefTP       = 200; //Default TP (Points)
input int      InpPointsStep  = 100; //Step (Points)
input bool     InpRunTests    = false; // Run Unit Tests

CObjects obj(settings.defX, settings.defY, 10, scale_factor, DefCorner);
CTradeOperations op();

STrade trade;
STrade errTrade;
SMarket market;

Layout layout;
Themes themes;
OrderButton ord_button;
Row row_tpl;

enum EMarketStatus{
   MarketIsOpen = 1,
   MarketIsClosed = 2,
   TradingDisabled = 3,
};

static double slInput = InpDefStop;
static double tpInput = InpDefTP;
static string Sym;
static bool   MarketOpen;
static bool   TradeDisabled;
static bool   TradingDay;
static bool   TradingSession;
EMarketStatus MarketStatus;




int OnInit() {
   
   initData();
   drawUI();
   if (InpRunTests) tradetool_tests.run_test();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, 0, -1);
}

void OnTick() {
   updatePrice();
}

EMarketStatus status(){
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
      case 1:
         //slInput = InpDefPoints;
         //tpInput = InpDefPoints;
         break;
      case 2:
         slInput = bid();
         tpInput = bid();
         break;
      default:
         break;
   }
}

void OnChartEvent(const int id, const long &lparam, const double &daram, const string &sparam){
   if (CHARTEVENT_OBJECT_CLICK){  
      if (sparam == "BTBuy") {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY);
         if (ret < 0) error(ret);
      }
      if (sparam == "BTSell") {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_SELL);
         if (ret < 0) error(ret);
      }
      if (sparam == "BTBuyLim") {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY_LIMIT);
         if (ret < 0) error(ret);
         
      }
      if (sparam == "BTSellLim") {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_SELL_LIMIT);
         if (ret < 0) error(ret);
      }
      if (sparam == "BTBuyStop"){
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY_STOP);
         if (ret < 0) error(ret);
      }
      if (sparam == "BTSellStop"){
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

void drawUI(){
   /*
   Main UI Method
   */
   
   const int rectLabelWidth      = 235;
   
   const int headerLineLen       = 205;
   const int headerLineHeight    = 0;
   
   
   const int headerY             = settings.defY - 20;
   const int headerX             = 15;
   const int headerFontSize      = 13;
   
   
   // MISC 
   const ENUM_LINE_STYLE style   = STYLE_SOLID;
   const ENUM_BORDER_TYPE border = BORDER_FLAT;
   const ENUM_BORDER_TYPE main   = BORDER_RAISED;
   const int lineWidth           = 1;
   
   const string headerString     = Sym + " | " + marketStatus();
   
   obj.CRectLabel("Buttons", settings.defX, settings.defY, rectLabelWidth, settings.defY - 5, main, themes.ButtonBordColor, style, 2);  
   ord_button.buy_market_button();
   ord_button.sell_market_button();
   
   obj.CTextLabel("Symbol", headerX, headerY, headerString, settings.font, headerFontSize, themes.DefFontColor);
   obj.CRectLabel("Header", headerX, headerY - 15, headerLineLen, headerLineHeight, border, themes.DefFontColor, style, 1);
   obj.CRectLabel("Header2", headerX, headerY - 175, headerLineLen, headerLineHeight, border, themes.DefFontColor, style, 1);  
   
   ord_button.buy_limit_button();
   ord_button.sell_limit_button();
   ord_button.buy_stop_button();
   ord_button.sell_stop_button();
   
   
   textFields();
   updatePrice();
}

string marketStatus(){
   string val = "";
   switch(MarketStatus){
      case 1: 
         val = "Open";
         break;
      case 2:
         val = "Closed";
         break;
      case 3:
         val = "Disabled";
         break;
      default:
         val = "";
         break;
   }
   return val;
}

void updatePrice(){
   const int yOffset       = settings.defY - 170;
   const int fontSize      = 13;
   

   obj.CTextLabel("BuyPrice", ord_button.Col_2_Offset + ord_button.DefButtonSpace, yOffset, norm(ask()), settings.font_bold, fontSize, themes.DefFontColor);
   obj.CTextLabel("SellPrice", ord_button.Col_1_Offset + ord_button.DefButtonSpace , yOffset, norm(bid()), settings.font_bold, fontSize, themes.DefFontColor);

}


double slPts() { return getValues("EDITSL"); }
double tpPts() { return getValues("EDITTP"); }


void textFields(){

   const int xOffset      = 15;
   
   obj.CTextLabel("TFSL", xOffset, layout.row1 - 13, "SL", settings.font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFTP", xOffset, layout.row2 - 12, "TP", settings.font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFVol", xOffset, layout.row3 - 11, "VOL", settings.font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFVolLots", xOffset + 175, layout.row3 - 11, "Lots", settings.font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFPending", xOffset, layout.row3 - 110, "PENDING", settings.font, ord_button.DefButtonFontSize, themes.DefFontColor);
   
   slRow();
   tpRow();
   volRow();
   poRow();

}

void slRow(double inp, bool state)  { createRow("EDITSL", ord_button.buttons[2], ord_button.buttons[2]+ "NOT", layout.row1, (string)inp, state, true);}
void slRow(bool state)              { slRow(slInput, state); }
void slRow(double inp)              { slRow(inp, trade.slOn);}
void slRow()                        { slRow(slInput, trade.slOn); } // Default State

void tpRow(double inp, bool state)  { createRow("EDITTP",ord_button.buttons[3], ord_button.buttons[3] + "NOT", layout.row2, (string)inp, state, true);}
void tpRow(bool state)              { tpRow(tpInput, state); }
void tpRow(double inp)              { tpRow(inp, trade.tpOn); }
void tpRow()                        { tpRow(tpInput, trade.tpOn); } 

void volRow(double inp)             { createRow("EDITVOL", ord_button.buttons[4], ord_button.buttons[4] + "NOT", layout.row3, norm(inp, 2), trade.volOn, false);}
void volRow()                       { volRow(trade.volume); }

void poRow(double inp)              { createRow("EDITPENDING", ord_button.buttons[4], ord_button.buttons[4] + "NOT", layout.row3 - 100, (string)inp, trade.volOn, false, 80); }
void poRow()                        { poRow(trade.entry); }


void createRow(string edit, string enabled, string disabled, int row, string editText, bool state, bool showSwitch, int bgX){

   // OFFSET
   const int space         = 3;
   
   const int btDisabled    = bgX + row_tpl.BGWidth + 5;
   const int btEnabled     = btDisabled + row_tpl.BTSize - 2;
   
   // COLORS
   const color togOnCol    = state ? themes.colors[0] : themes.colors[4];
   const color togOffCol   = state ? themes.colors[2] : themes.colors[0];  
   // FONTS
   // MISC 
   obj.CAdjRow(edit, 
      bgX, 
      row, 
      row_tpl.BGWidth, 
      row_tpl.BGHeight, 
      row_tpl.EditWidth, 
      row_tpl.EditHeight, 
      row_tpl.BTSize, 
      editText, 
      row_tpl.FontSize, 
      themes.RowButtonBG,
      themes.RowButtonBord, 
      themes.DefFontColor, 
      themes.EditCol);
      
   if (showSwitch){
      // name1, name2, x, y, width, height, col1, col2, state
      obj.CSwitch(enabled, disabled, btDisabled, row - space, row_tpl.BTSize, row_tpl.BTSize, togOnCol, togOffCol, state);
   }
   
}

void createRow(string edit, string enabled, string disabled, int row, string editText, bool state, bool showSwitch){
   const int bgX = 50;
   createRow(edit, enabled, disabled, row, editText, state, showSwitch, bgX);
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

string invalid_order() { return "Invalid Order Parameters for "; }
void logger(string message){ PrintFormat("LOGGER: %s", message); }

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

double minPoints(){ return 0; }

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



