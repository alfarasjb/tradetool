

color    DEF_FONT_COLOR       = clrWhite;
color    BUTTON_BORD_COLOR    = clrGray; 
color    BUY_COLOR            = clrDodgerBlue;
color    SELL_COLOR           = clrCrimson;

color    ROW_BUTTON_BG        = clrDimGray;
color    ROW_BUTTON_BORD      = clrDarkGray;
color    EDIT_COLOR           = clrGray;

string   UI_FONT              = "Segoe UI Semibold";
string   UI_FONT_BOLD         = "Segoe UI Bold";

int      FONT_SIZE            = 10;

enum MODE{
   Points,
   Price,
};

enum MARKET_STATUS{
   MarketIsOpen,
   MarketIsClosed,
   TradingDisabled,
};

struct SETTINGS{
   int row1, row2, row3;

} settings;