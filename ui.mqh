


#include "oct_include.mqh"
#include <B63/CObjects.mqh>
#include "tradetool_app.mqh"

#define app_font           "Segoe UI Semibold"
#define app_font_bold      "Segoe UI Bold"
#define app_def_y          315
#define app_def_x          5
#define app_corner         CORNER_LEFT_LOWER
#define app_line_style        STYLE_SOLID
#define app_border_type       BORDER_FLAT
#define app_main_border_type  BORDER_RAISED
#define app_line_width        1

CTradeToolApp tradetool_app;
CTradeToolAppBeta tradetool_app_beta(5, 315, 235, 300);

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
} layout;



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
} themes;



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
   void standard_order_button(Button &button_var, int button_index, int column, int y_offset, double width_scale, double height_scale, color button_color, string label_handle, string label_name, int label_offset, int label_x_offset){

      
      button_var.button_name = buttons[button_index];
      
      obj.CButton(
         buttons[button_index],
         column, 
         y_offset,
         (int)(DefButtonWidth * width_scale),
         (int)(DefButtonHeight * height_scale),
         DefButtonFontSize, 
         "",
         DEF_FONT_COLOR,
         button_color, 
         BUTTON_BORD_COLOR,
         DefZOrd      
      );
      obj.CTextLabel(label_handle, column + 10 + label_x_offset,label_offset, label_name, app_font, DefButtonFontSize, DEF_FONT_COLOR);
   }

   
} ord_button;




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
} row_tpl;





string marketStatus(){
   string val = "";
   switch(MarketStatus){
      case MarketIsOpen: 
         val = "Open";
         break;
      case MarketIsClosed:
         val = "Closed";
         break;
      case TradingDisabled:
         val = "Disabled";
         break;
      default:
         val = "";
         break;
   }
   return val;
}



double slPts() { return getValues("EDITSL"); }
double tpPts() { return getValues("EDITTP"); }


void textFields(){

   const int xOffset      = 15;
   
   obj.CTextLabel("TFSL", xOffset, layout.row1 - 13, "SL", app_font, ord_button.DefButtonFontSize, DEF_FONT_COLOR);
   obj.CTextLabel("TFTP", xOffset, layout.row2 - 12, "TP", app_font, ord_button.DefButtonFontSize, DEF_FONT_COLOR);
   obj.CTextLabel("TFVol", xOffset, layout.row3 - 11, "VOL", app_font, ord_button.DefButtonFontSize, DEF_FONT_COLOR);
   obj.CTextLabel("TFVolLots", xOffset + 175, layout.row3 - 11, "Lots", app_font, ord_button.DefButtonFontSize, DEF_FONT_COLOR);
   obj.CTextLabel("TFPending", xOffset, layout.row3 - 110, "PENDING", app_font, ord_button.DefButtonFontSize, DEF_FONT_COLOR);
   
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
      //tradetool_app_beta.UI_Switch(enabled, btDisabled, row - space, row_tpl.BTSize, row_tpl.BTSize, state);
   }
   
}

void createRow(string edit, string enabled, string disabled, int row, string editText, bool state, bool showSwitch){
   const int bgX = 50;
   createRow(edit, enabled, disabled, row, editText, state, showSwitch, bgX);
}
