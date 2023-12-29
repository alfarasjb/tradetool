/*
STUFF TO TEST  

*/

#include "../oct_include.mqh"

enum TestResult{
   Passed = 0,
   Failed = 1
};

TestResult testresult;

struct TestFunction{
   string method;
   string expected_bool;
   string true_value_bool; 
   double lot_size;
   TestResult result;
   
   void stat(string mthd, string exp_val, string true_val){
      method = mthd;
      expected_bool = exp_val;
      true_value_bool = true_val;
      
      result = expected_bool == true_value_bool ? Passed : Failed;
   }
};

struct Tests{
   int passed;
   int failed;
   int total; 
   
   TestFunction added[];

   Tests(){
      passed = 0;
      failed = 0;
      total = 0;
   }
   
   void success(){ 
      total++;
      passed++;
   }
   
   void fail(){
      total++;
      failed++;
   }
   
   void add_tests(TestFunction &test_function){
      int current_size = ArraySize(added);
      ArrayResize(added, current_size + 1);
      added[current_size] = test_function;
   }
   
   void reset_tests(){
      ArrayFree(added);
   }
};

TestFunction testfunc;

Tests tests;






class TradeTool_Tests{
   protected: 
   private:
   
      void summarize(){
         PrintFormat("%i out of %i tests passed.", tests.passed, tests.total);
         
         for (int i = 0; i < ArraySize(tests.added); i ++){
            string method = tests.added[i].method;
            string expected = tests.added[i].expected_bool;
            string true_val = tests.added[i].true_value_bool;
            string test_result = EnumToString(tests.added[i].result);
            //Print(test_result);
            PrintFormat("Method: %s, Expected: %s, True: %s, Result: %s", method, (string)expected, (string)true_val, test_result);
         }
      }
      
      
      void validate(string expected, string true_value){
         
         if (expected == true_value) tests.success();
         else tests.fail();
      }
      
      
      void delete_pending_tests(){
      
         int orders_total = OrdersTotal();
         int pending_tickets[];
         
         for (int i = 0; i < orders_total; i ++){
            int t = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
            if (is_pending()){
               int num_pending = ArraySize(pending_tickets);
               ArrayResize(pending_tickets, num_pending + 1);
               pending_tickets[num_pending] = OrderTicket();
            }
         }
         
         int num_pending = ArraySize(pending_tickets);
         
         for (int i = 0; i < num_pending; i++){
            int ticket = pending_tickets[i];
            int d = OrderDelete(ticket, clrNONE);
         }
      }
      
      bool is_pending(){
         int ord_type = OrderType();
         
         switch(ord_type){
            case 0: 
            case 1:
               return false; 
               break; 
            case 2:
            case 3: 
            case 4:
            case 5: 
               return true; 
               break;
            default:
               return false; 
         }
         return false;
      }
      
      
      void edit_entry(string object_name, string text){ ObjectSetString(0, object_name, OBJPROP_TEXT, (string)text); }
      
      
   public:
   
      TradeTool_Tests(void);
      void test_max_lot(bool expected, double lot);
      void test_min_lot(bool expected, double lot);
      void test_min_points_value(int expected);
      void test_min_points_bool(bool expected, double points);
      
      void test_buy_limit();
      void test_buy_limit_error();
      void test_sell_limit();
      void test_sell_limit_error();
      void test_buy_stop();
      void test_buy_stop_error();
      void test_sell_stop();
      void test_sell_stop_error();
      
   
   void run_test(){
      /*
      Test conditions
      */
      tests.reset_tests();
      
      test_min_lot(true, 0.01);
      test_min_lot(false, 0.02);
      test_max_lot(true, 100000);
      test_max_lot(false, 0.01);
      test_min_points_value(0);
      test_min_points_bool(false, 10);
      test_min_points_bool(true, 0);
      
      test_buy_limit();
      test_buy_limit_error();
      test_sell_limit();
      test_sell_limit_error();
      
      test_buy_stop();
      test_buy_stop_error();
      test_sell_stop();
      test_sell_stop_error();
      
      summarize();
   }

  
};

TradeTool_Tests::TradeTool_Tests(void){}

void TradeTool_Tests::test_max_lot(bool expected, double lot){

   bool true_value = tradetool_app.MaxLot(lot);
   
   testfunc.stat("max_lot", expected, true_value);
   tests.add_tests(testfunc);
   
   if (expected == true_value) tests.success();
   else tests.fail();
   
}

void TradeTool_Tests::test_min_lot(bool expected, double lot){

   bool true_value = tradetool_app.MinLot(lot);
      
   testfunc.stat("min_lot", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
}

void TradeTool_Tests::test_min_points_value(int expected){
   
   int true_value = 0;
   
   testfunc.stat("min_points", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   
}

void TradeTool_Tests::test_min_points_bool(bool expected, double points){
   bool true_value = tradetool_app.MinPoints(points);
   
   testfunc.stat("min_points", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);

}

void TradeTool_Tests::test_buy_limit(){
   /*
   Testing Pending Orders: First set trade parameters. entry, stop, target
   */
   
   ENUM_ORDER_TYPE ord = ORDER_TYPE_BUY_LIMIT;
   
   double entry = ask() - 200*point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = true_value > 0 ? true_value : 100;
   
   testfunc.stat("success_buy_lim", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
}

void TradeTool_Tests::test_buy_limit_error(){
   
   ENUM_ORDER_TYPE ord = ORDER_TYPE_BUY_LIMIT;

   double entry = ask() + 200*point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = -30;
   
   testfunc.stat("err_buy_lim", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
}

void TradeTool_Tests::test_sell_limit(){
   
   ENUM_ORDER_TYPE ord = ORDER_TYPE_SELL_LIMIT;
   
   double entry = bid() + 200 * point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = true_value > 0 ? true_value : 100;
   
   testfunc.stat("success_sell_lim", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
}

void TradeTool_Tests::test_sell_limit_error(){
   
   ENUM_ORDER_TYPE ord = ORDER_TYPE_SELL_LIMIT;
   
   double entry = bid() - 200 * point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = -40;
   
   testfunc.stat("err_sell_lim", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
   
}

void TradeTool_Tests::test_buy_stop(){
   
   ENUM_ORDER_TYPE ord = ORDER_TYPE_BUY_STOP;
   
   double entry = ask() + 200 * point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = true_value > 0 ? true_value : 100;
   
   testfunc.stat("success_buy_stop", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
   
}

void TradeTool_Tests::test_buy_stop_error(){

   ENUM_ORDER_TYPE ord = ORDER_TYPE_BUY_STOP;
   
   double entry = ask() - 200 * point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = -50;
   
   testfunc.stat("err_buy_stop", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
}

void TradeTool_Tests::test_sell_stop(){
   ENUM_ORDER_TYPE ord = ORDER_TYPE_SELL_STOP;
   
   double entry = bid() - 200 * point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = true_value > 0 ? true_value : 100;
   
   testfunc.stat("success_sell_stop", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
}

void TradeTool_Tests::test_sell_stop_error(){
   ENUM_ORDER_TYPE ord = ORDER_TYPE_SELL_STOP;
   
   double entry = bid() + 200 * point();
   edit_entry("EDITPENDING", (string)entry);
   
   int true_value = tradetool_main.SendOrder(ord);
   int expected = -60;
   
   testfunc.stat("err_sell_stop", expected, true_value);
   tests.add_tests(testfunc);
   
   validate((string)expected, (string)true_value);
   delete_pending_tests();
}


TradeTool_Tests tradetool_tests;

double point()                         { return SymbolInfoDouble(tradetool_main.SYMBOL, SYMBOL_POINT); }

double ask()   { return tradetool_main.util_ask(); }
double bid()   { return tradetool_main.util_bid(); }

