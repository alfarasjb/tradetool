


#include "oct_include.mqh"
#include <B63/CObjects.mqh>


#define app_font           "Segoe UI Semibold"
#define app_font_bold      "Segoe UI Bold"
#define app_def_y          315
#define app_def_x          5
#define app_corner         CORNER_LEFT_LOWER
#define app_line_style        STYLE_SOLID
#define app_border_type       BORDER_FLAT
#define app_main_border_type  BORDER_RAISED
#define app_line_width        1

int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
int scale_factor = (screen_dpi * 100) / 96;

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

//CObjects obj(app_def_x, app_def_y, 10, scale_factor, app_corner);
CObjects obj(app_def_x, app_def_y, 10, scale_factor, app_corner);
struct Layout{
   int row1; 
   int row2; 
   int row3; 
   
   Layout(){
      row1 = app_def_y - 45; 
      row2 = app_def_y - 75; 
      row3 = app_def_y - 105;
   }
};



struct Themes{
   color colors[];
   color DefFontColor;
   color ButtonBordColor;
   color BuyColor;
   color SellColor;
   
   color RowButtonBG;
   color RowButtonBord;
   color EditCol;
   
   Themes(){
      const color init_colors[] = {clrWhite, clrGray, clrDodgerBlue, clrCrimson, clrDimGray, clrDarkGray};
      ArrayCopy(colors, init_colors);
      DefFontColor = colors[0];
      ButtonBordColor   = colors[1];
      BuyColor          = colors[2];
      SellColor         = colors[3];
      
      RowButtonBG       = colors[4];
      RowButtonBord     = colors[5];
      EditCol           = colors[1];
   
   }
};



struct OrderButton{
   /*
   struct for holding information on button dimensions, methods, etc. 
   */
   
   // dimensions
   int DefButtonWidth;
   int DefButtonHeight; 
   
   // off set from top
   int DefYOffset; // distance from bottom 
   int OrdButtonYOffset;
   
   // offset from corner
   int Col_1_Offset;
   int Col_2_Offset;
   
   // button font size
   int DefButtonFontSize;
   
   // zord
   int DefZOrd;
   
   string buttons[];
   
   int DefButtonSpace;
   
   OrderButton(){
      DefButtonWidth = 105;
      DefButtonHeight = 50;
      DefYOffset = DefButtonHeight + app_def_y - 185; 
      OrdButtonYOffset = DefYOffset - 13;
      
      Col_1_Offset = 15; // sell button
      Col_2_Offset = 125; // buy button offset
      
      DefZOrd = 5; 
      DefButtonSpace = 10;
      DefButtonFontSize = 10;
      const string init_buttons[] = {"BTBuy", "BTSell", "BTSLBOOL", "BTTPBOOL", "BTVOLBOOL", "BTBuyLim", "BTSellLim", "BTBuyStop", "BTSellStop"};
      ArrayCopy(buttons, init_buttons);
   }
   
   // TEMPLATES: STANDARD ORDER BUTTONS 
   void standard_order_button(int button_index, int column, int y_offset, double width_scale, double height_scale, color button_color, string label_handle, string label_name, int label_offset, int label_x_offset){
      color font_color = themes.DefFontColor;
      color button_bord_color = themes.ButtonBordColor;
      
      obj.CButton(
         buttons[button_index],
         column, 
         y_offset,
         (int)(DefButtonWidth * width_scale),
         (int)(DefButtonHeight * height_scale),
         DefButtonFontSize, 
         "",
         font_color,
         button_color, 
         button_bord_color,
         DefZOrd      
      );
      obj.CTextLabel(label_handle, column + 10 + label_x_offset,label_offset, label_name, app_font, DefButtonFontSize, font_color);
   }
 
   void buy_market_button()   { standard_order_button(0, Col_2_Offset, DefYOffset, 1, 1, themes.BuyColor, "BuyLabel", "BUY", OrdButtonYOffset, 0); }
   void sell_market_button()  { standard_order_button(1, Col_1_Offset, DefYOffset, 1, 1, themes.SellColor, "SellLabel","SELL", OrdButtonYOffset, 0); }
   void buy_limit_button()    { standard_order_button(5, Col_2_Offset, DefYOffset - 100, 1, 0.6, themes.BuyColor, "BuyLimitLabel", "BUY LIMIT", OrdButtonYOffset - 100, 8); } 
   void sell_limit_button()   { standard_order_button(6, Col_1_Offset, DefYOffset - 100, 1, 0.6, themes.SellColor, "SellLimitLabel", "SELL LIMIT", OrdButtonYOffset - 100, 8); }
   void buy_stop_button()     { standard_order_button(7, Col_2_Offset, DefYOffset - 135, 1, 0.6, themes.BuyColor, "BuyStopLabel", "BUY STOP", OrdButtonYOffset - 135, 8); }
   void sell_stop_button()    { standard_order_button(8, Col_1_Offset, DefYOffset - 135, 1, 0.6, themes.SellColor, "SellStopLabel", "SELL STOP", OrdButtonYOffset - 135, 8); }
   
};



struct Row{
   int edit_dims[];
   int bg_dims[];
   
   int EditWidth;
   int EditHeight;
   int BGWidth;
   int BGHeight;
   
   int BTSize;
   int FontSize;
   
   Row(){
      const int edit[] = {80, 18};
      const int bg[] = {130, 25};
      
      ArrayCopy(edit_dims, edit);
      ArrayCopy(bg_dims, bg);

      EditWidth = edit_dims[0];
      EditHeight = edit_dims[1];
      BGWidth = bg_dims[0];
      BGHeight = bg_dims[1];
      
      BTSize = 18; 
      FontSize = 10;
   }
};



void drawUI(){
   /*
   Main UI Method
   */
   
   const int rectLabelWidth      = 235;
   
   const int headerLineLen       = 205;
   const int headerLineHeight    = 0;
   
   
   const int headerY             = app_def_y - 20;
   const int headerX             = 15;
   const int headerFontSize      = 13;
   
   
   // MISC 
   //const ENUM_LINE_STYLE style   = STYLE_SOLID;
   //const ENUM_BORDER_TYPE border = BORDER_FLAT;
   //const ENUM_BORDER_TYPE main   = BORDER_RAISED;
   //const int lineWidth           = 1;
   
   //Temporarily Disabled. marketStatus is buggy
   //const string headerString     = Sym + " | " + marketStatus();
   const string headerString     = Sym;
   
   obj.CRectLabel("Buttons", app_def_x, app_def_y, rectLabelWidth, app_def_y - 5, app_main_border_type, themes.ButtonBordColor, app_line_style, 2);  
   ord_button.buy_market_button();
   ord_button.sell_market_button();
   
   obj.CTextLabel("Symbol", headerX, headerY, headerString, app_font, headerFontSize, themes.DefFontColor);
   obj.CRectLabel("Header", headerX, headerY - 15, headerLineLen, headerLineHeight, app_border_type, themes.DefFontColor, app_line_style, 1);
   obj.CRectLabel("Header2", headerX, headerY - 175, headerLineLen, headerLineHeight, app_border_type, themes.DefFontColor, app_line_style, 1);  
   
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
   const int yOffset       = app_def_y - 170;
   const int fontSize      = 13;
   

   obj.CTextLabel("BuyPrice", ord_button.Col_2_Offset + ord_button.DefButtonSpace, yOffset, norm(ask()), app_font_bold, fontSize, themes.DefFontColor);
   obj.CTextLabel("SellPrice", ord_button.Col_1_Offset + ord_button.DefButtonSpace , yOffset, norm(bid()), app_font_bold, fontSize, themes.DefFontColor);

}


double slPts() { return getValues("EDITSL"); }
double tpPts() { return getValues("EDITTP"); }


void textFields(){

   const int xOffset      = 15;
   
   obj.CTextLabel("TFSL", xOffset, layout.row1 - 13, "SL", app_font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFTP", xOffset, layout.row2 - 12, "TP", app_font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFVol", xOffset, layout.row3 - 11, "VOL", app_font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFVolLots", xOffset + 175, layout.row3 - 11, "Lots", app_font, ord_button.DefButtonFontSize, themes.DefFontColor);
   obj.CTextLabel("TFPending", xOffset, layout.row3 - 110, "PENDING", app_font, ord_button.DefButtonFontSize, themes.DefFontColor);
   
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
