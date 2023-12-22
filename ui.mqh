
#include "oct_include.mqh"

struct Layout{
   int row1; 
   int row2; 
   int row3; 
   
   Layout(){
      row1 = settings.defY - 45; 
      row2 = settings.defY - 75; 
      row3 = settings.defY - 105;
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
      DefYOffset = DefButtonHeight + settings.defY - 185; 
      OrdButtonYOffset = DefYOffset - 13;
      
      Col_1_Offset = 10; // sell button
      Col_2_Offset = 120; // buy button offset
      
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
         DefButtonWidth * width_scale,
         DefButtonHeight * height_scale,
         DefButtonFontSize, 
         "",
         font_color,
         button_color, 
         button_bord_color,
         DefZOrd      
      );
      obj.CTextLabel(label_handle, column + 10 + label_x_offset,label_offset, label_name, settings.font, DefButtonFontSize, font_color);
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

