//
//  Backend.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

class StocksDataManager{
    
    static let shared = StocksDataManager()
    let finnhubConnector = FinnhubConnector.shared
    var subscribedSymbols: [String] = []
    var subscribedStocks: Stock!
    
    private init() {}
    
    func grabSubscribedStocksFromFirebase(){
        // grab user subscribed stocks from Firebase
        subscribedSymbols = ["AAPL","IBM","CCL","TSLA","GOOG","AMZN","CRM"]
    }
    
    func connectToFinnhub(){
        DispatchQueue.main.async {
            self.initStockObjects()
        }
        finnhubConnector.start(myEventHandler: finnhubHandler(incoming:), onReadyEvent: finnhubReady)
    }
    
    func initStockObjects(){
        
        for symbol in subscribedSymbols{
            var name: String?
            var price: Double?
            var priceChange: Double?
            var percentChange: Double?
            var previousClosePrice: Double?
            
            let _ = finnhubConnector.getStockQuote(withSymbol: symbol) {
                (stockQuote: StockQuote?) in
                if let stockQuote = stockQuote{
                    name = "" // empty for now
                    price = stockQuote.c
                    previousClosePrice = stockQuote.pc
                    priceChange = self.calculatePriceChange(price!,previousClosePrice!)
                    percentChange = self.calculatePercentChange(price!, previousClosePrice!)
                    
                    let stock = Stock(symbol: symbol, name: name!, price: price!, priceChange: priceChange!, percentChange: percentChange!, previousClosePrice: previousClosePrice!)
                    
                    print(String(describing: stock))
                }else{
                    // error when requesting stock quote
                }
            }
            
            
        }
    }
    
    func finnhubHandler(incoming: TradeDataPacket){
        updateStockDataOnUI()
    }
    
    func finnhubReady(){
        print("Event Ready")
        
        if marketIsOpen(){
            for symbol in subscribedSymbols{
                finnhubConnector.subscribe(withSymbol: symbol)
            }
        }else{
            
        }
        
    }
    
    func updateStockDataOnUI(){
        
    }
    
    func marketIsOpen() -> Bool{
        let secondsInOneHour = 3600.0
        
        let timestamp = NSDate().timeIntervalSince1970
        let easternTimestamp = timestamp - (secondsInOneHour * 4)
        let currentTime = NSDate(timeIntervalSince1970: easternTimestamp) as Date
        
        let now = Date()
        let calendar = Calendar.current
        let marketOpenTime = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: now)!
        let marketCloseTime = NSDate(timeIntervalSince1970: calendar.startOfDay(for: now).timeIntervalSince1970 + (secondsInOneHour * 24)) as Date
    
        let weekday = calendar.component(.weekday, from: currentTime)
            
        if marketOpenTime <= currentTime && currentTime <= marketCloseTime{ // when 9:00 am <= current time <= 4:00pm
            if weekday != 1 && weekday != 7 { // when current day is not Saturday and Sunday
                return true
            }
        }
        
        return false
    }
    
    func calculatePriceChange(_ currentPrice: Double, _ previousClosingPrice: Double) -> Double{
        let priceChange = currentPrice - previousClosingPrice
        return roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: priceChange)
    }
    
    func calculatePercentChange(_ currentPrice: Double, _ previousClosingPrice: Double) -> Double{
        let percentChange = 100 * (abs(currentPrice - previousClosingPrice) / previousClosingPrice)
        return roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: percentChange)
    }
    
    func roundTo(decimalPlace: Int, withValue: Double) -> Double{
        var base:Double = 10.0
        for _ in 0 ..< (decimalPlace - 1){
            base *= 10
        }
        return Double(round(base * withValue) / base)
    }
    
}
