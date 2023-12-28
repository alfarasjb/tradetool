
#include <B63/CObjects.mqh>
#include "definition.mqh"
#include <B63/CInterface.mqh>


// CINTERFACE: LAYOUT
// CTRADETOOLAPP: EVENT HANDLING


class CTradeToolAppBeta : public CInterface{
   protected:
   private:
   public: 
      Terminal    terminal;
      
      CTradeToolAppBeta(int ui_x, int ui_y, int ui_width, int ui_height);
      
      void        InitializeUIElements();
   
};

CTradeToolAppBeta::CTradeToolAppBeta(int ui_x, int ui_y, int ui_width, int ui_height){
   UI_X = ui_x;
   UI_Y = ui_y;
   UI_WIDTH = 235;
   UI_HEIGHT = UI_Y - 5;
   
   UI_BORDER = BORDER_RAISED;
   UI_BG_COLOR = clrBlack;
}

void CTradeToolAppBeta::InitializeUIElements(){
   UI_Terminal(terminal, "MAIN");
}


class CTradeToolApp: public CObjects{
   protected:
      
   private:
      int APP_SCREEN_DPI, APP_SCALE_FACTOR, APP_X, APP_Y, APP_COL_1, APP_COL_2;
      string font, font_bold;
      
      
      void     InitializeUIValues();
      
   public:
   
      CTradeToolApp(); // non-parametrized constructor
      void     InitializeUIElements();
      void     DrawOrderButton(Button &button, string name, int x, int y_adjust, double width_factor, double height_factor, color button_color, string label_handle, string label_name, int label_adjust, int label_x_offset);
      void     DrawRectLabel(RectLabel &rect, string name, int x, int y, int width, int height,ENUM_BORDER_TYPE border, int line_width);
      
      
      Button market_buy, market_sell, buy_limit, sell_limit, buy_stop, sell_stop;
      RectLabel main, header_1, header_2;
      
      // Utilities 
      void     UpdatePrice(string ask, string bid);
};


CTradeToolApp::CTradeToolApp(void){
   InitializeUIValues();
   
}


void CTradeToolApp::DrawOrderButton(Button &button, string name, int x, int y_adjust, double width_factor, double height_factor, color button_color, string label_handle, string label_name, int label_adjust, int label_x_offset){
   
   int DefButtonWidth = 105;
   int DefButtonHeight = 50; 
   int APP_YOffset = DefButtonHeight + APP_Y - 185;
   int OrdButtonYOffset = APP_YOffset - 13;
   
   int y = APP_YOffset - y_adjust;
   
   int width = (int)(DefButtonWidth * width_factor);
   int height = (int)(DefButtonHeight * height_factor);
   
   int label_offset = OrdButtonYOffset - label_adjust;
   
   long ZOrder = 5;
   
   button.button_name = name;
   
   CButton(name, x, y, width, height, DefFontSize, "", DEF_FONT_COLOR, button_color, BUTTON_BORD_COLOR, ZOrder);
   CTextLabel(label_handle, x + 10 + label_x_offset, label_offset, label_name, font, DefFontSize, DEF_FONT_COLOR);
}

void CTradeToolApp::DrawRectLabel(RectLabel &rect, string name, int x, int y, int width, int height,ENUM_BORDER_TYPE border, int line_width){

   rect.rect_name = name;
   CRectLabel(name, x, y, width, height, border, DEF_FONT_COLOR, STYLE_SOLID, line_width);
   
}

void CTradeToolApp::UpdatePrice(string ask, string bid){
   
   const int y_offset = APP_Y - 170;
   const int font_size = 13; 
   
   const int buy_offset = APP_COL_2 + 10;
   const int sell_offset = APP_COL_1 + 10;
   
   // DONT FORGET TO NORMALIZE BID AND ASK
   CTextLabel("BuyPrice", buy_offset, y_offset, ask, font_bold, font_size, DEF_FONT_COLOR);
   CTextLabel("SellPrice", sell_offset, y_offset, bid, font_bold, font_size, DEF_FONT_COLOR);
}

void CTradeToolApp::InitializeUIElements(void){

   int RectLabelWidth      = 235; 
   int HeaderLineLen       = 205;
   int HeaderLineHeight    = 0; 
   
   int HeaderY             = APP_Y - 20;
   int HeaderX             = 15; 
   int HeaderFontSize      = 13; 
   
   DrawRectLabel(main, "Buttons", APP_X, APP_Y, RectLabelWidth, APP_Y - 5, BORDER_RAISED, 2);
   CTextLabel("Symbol", HeaderX, HeaderY, Symbol(), font, HeaderFontSize, DEF_FONT_COLOR);
   DrawRectLabel(header_1, "Header", HeaderX, HeaderY - 15, HeaderLineLen, HeaderLineHeight, BORDER_FLAT, 1);
   DrawRectLabel(header_2, "Header2", HeaderX, HeaderY - 175, HeaderLineLen, HeaderLineHeight, BORDER_FLAT, 1);

   DrawOrderButton(market_buy, "BTBuy", APP_COL_2, 0, 1, 1, BUY_COLOR, "BuyLabel", "BUY", 0, 0);
   DrawOrderButton(market_sell, "BTSell", APP_COL_1, 0, 1, 1, SELL_COLOR, "SellLabel", "SELL", 0, 0);
   DrawOrderButton(buy_limit, "BTBuyLim", APP_COL_2, 100, 1, 0.6, BUY_COLOR, "BuyLimitLabel", "BUY LIMIT", 100, 8);
   DrawOrderButton(sell_limit, "BTSellLim", APP_COL_1, 100, 1, 0.6, SELL_COLOR, "SellLimitLabel", "SELL LIMIT", 100, 8);
   DrawOrderButton(buy_stop, "BTBuyStop", APP_COL_2, 135, 1, 0.6, BUY_COLOR, "BuyStopLabel", "BUY STOP", 135, 8);
   DrawOrderButton(sell_stop, "BTSellStop", APP_COL_1, 135, 1, 0.6, SELL_COLOR, "SellStopLabel", "SELL STOP", 135, 8);
   
}
   

void CTradeToolApp::InitializeUIValues(void){
   APP_SCREEN_DPI = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   APP_SCALE_FACTOR = (APP_SCREEN_DPI * 100) / 96;
   APP_X = 5;
   APP_Y = 315;
   font = UI_FONT;
   font_bold = UI_FONT_BOLD;
   
   APP_COL_1 = 15;
   APP_COL_2 = 125;
   
   DefXDist = APP_X; 
   DefYDist = APP_Y;
   DefFontSize = FONT_SIZE;
   DefScaleFactor = APP_SCALE_FACTOR;
   DefCorner = CORNER_LEFT_LOWER;
   
}
