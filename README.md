# TradeTool 2.0
TradeTool is a basic order execution tool, as an alternative to MetaTrader's One Click Trading. 

TradeTool allows automatically placing stop-loss, and take-profit levels, as well as pending orders. 

Download TradeTool [here](https://www.mql5.com/en/market/product/105331)

UI Features: 
1. Textfields - for manually placing SL and TP points distance from current market price.
2. Toggles - enforces SL and TP levels
3. Adjustment Buttons - Allows adjustment without having the need to manually enter stop levels.
4. Market Buy and Market Sell Buttons - Allows immediate order execution and automatic placement of stops
   given that the features are enabled.


Key Priorties: 
1. Efficiency and execution speed

Limitations: 
1. Position Sizing is not calculated based on Risk/Trade
2. No interactive chart objects
3. Does not set limitations in the event that the trader decides to over-leverage on a trade.
   

## ENABLING TRADETOOL
Make sure **AUTOTRADING** is enabled and **ALLOW LIVE TRADING** is checked. 
![enable_labeled](https://github.com/alfarasjb/tradetool/assets/72119101/fdbd1570-b1eb-46d8-b704-d43e9b1ac15f)

## INPUTS 
![inputs](https://github.com/alfarasjb/tradetool/assets/72119101/5cf7d391-ef07-45ad-95a8-1de277f4ef1a)

1. Magic Number - Expert Magic Number
2. Volume - Default Volume
3. Default SL - Stop Loss default points distance from entry price (current market price for market orders, entry price for pending orders)
4. Default TP - Take Profit default points distance from entry price (current market price for market orders, entry price for pending orders)
5. Step - Adjustment step size in points.

## USAGE
![main_labeled](https://github.com/alfarasjb/tradetool/assets/72119101/9431e697-508d-4f36-80b0-29aafedb9045)

1. Adjustment Buttons - Adjusts SL and TP points based on input step size.
2. Toggle - Enables/Disables placing SL and TP
3. Input - Input field for SL and TP Points, Volume, Pending Order Entry Price
4. Market - Market Buy / Market Sell Button
5. Pending - Pending Order (Limit / Stop)
