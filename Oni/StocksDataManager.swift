//
//  Backend.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import UIKit

class StocksDataManager{
    
    static let shared = StocksDataManager()
    static var subscribedSymbols: [String] = []
    static var subscribedStocks: [Stock] = []
    
    let finnhubConnector = FinnhubConnector.shared
    var refresher: Timer!
    var currentTableView: UITableView?
    
        
    private init() {
        grabSubscribedStocksFromFirebase()
        fetchStockObjects()
        refresher = Timer.scheduledTimer(withTimeInterval: Settings.stockDataRefreshRate, repeats: true, block: { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshStockDataOnUI()
            }
        })
    }
    
    func grabSubscribedStocksFromFirebase(){
        // grab user subscribed stocks from Firebase
        subscribedSymbols = ["AAPL","IBM","CCL","TSLA","GOOG","AMZN","CRM"]
    }
    
    func connectToFinnhub(){
        finnhubConnector.start(myEventHandler: self.finnhubHandler(incoming:), onReadyEvent: self.finnhubReady)
    }
    
    func fetchStockObjects(){
        
        for symbol in subscribedSymbols{
            var name: String?
            var price: Double?
            var priceChange: String?
            var percentChange: String?
            var previousClosePrice: Double?
            
            let _ = finnhubConnector.getStockQuote(withSymbol: symbol) {
                (stockQuote: StockQuote?) in
                                
                if let stockQuote = stockQuote{
                    name = "" // empty for now
                    price = self.roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: stockQuote.c)
                    previousClosePrice = stockQuote.pc
                    priceChange = self.calculatePriceChange(price!,previousClosePrice!)
                    percentChange = self.calculatePercentChange(price!, previousClosePrice!)
                    
                    let stock = Stock(symbol: symbol, name: name!, price: price!, priceChange: priceChange!, percentChange: percentChange!, previousClosePrice: previousClosePrice!, edittedTimestamp: Int64(NSDate().timeIntervalSince1970))
                    
                    self.subscribedStocks.append(stock)
                    print(String(describing: stock))
                }else{
                    // error when requesting stock quote
                }
            }
        }
        
    }
    
    func finnhubHandler(incoming: TradeDataPacket){
        let stockSymbol = incoming.symbol
        let currentPrice = incoming.price
        updateStockData(withSymbol: stockSymbol, withPrice: currentPrice)
    }
    
    func finnhubReady(){
        print("Finnhub Ready")
        
        for symbol in subscribedSymbols{
            finnhubConnector.subscribe(withSymbol: symbol)
        }
        
        if marketIsOpen(){
            
        }else{
            print("makert closed")
        }
    }
    
    // called every 8 seconds
    func refreshStockDataOnUI(){
        
        print("Begin Refresh")
        
        let eight_seconds_ago = Int64(NSDate().timeIntervalSince1970) - 8
    
        // ensure all stocks are refreshed in the last 8 seconds
        for i in 0 ..< subscribedStocks.count{

            let stock = subscribedStocks[i]
            var updatedStock = stock
            
            if stock.edittedTimestamp < eight_seconds_ago{ // update stock that did not get updated by webscoekt
                finnhubConnector.getStockQuote(withSymbol: stock.symbol) {
                    (stockQuote: StockQuote?) in
                    if let stockQuote = stockQuote{
                        print("\(stock.symbol) with old price: \(stock.price), new price: \(stockQuote.c)")
                        updatedStock.price = self.roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: stockQuote.c)
                        updatedStock.priceChange = self.calculatePriceChange(stockQuote.c, stock.previousClosePrice)
                        updatedStock.percentChange = self.calculatePriceChange(stockQuote.c, stock.previousClosePrice)
                        updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
                    }
                }
                subscribedStocks[i] = updatedStock
            }
        }
        
        currentTableView?.reloadData()
        
    
    }
    
    func updateStockData(withSymbol: String, withPrice: Double){
        if let index = subscribedSymbols.firstIndex(of: withSymbol){
            var updatedStock = subscribedStocks[index]
            updatedStock.price = roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: withPrice)
            updatedStock.priceChange = calculatePriceChange(withPrice, updatedStock.previousClosePrice)
            updatedStock.percentChange = calculatePriceChange(withPrice, updatedStock.previousClosePrice)
            updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
            
            subscribedStocks[index] = updatedStock
        }
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
    
    func getSubscribedStocks() -> [Stock] {
        return subscribedStocks
    }
    
    func calculatePriceChange(_ currentPrice: Double, _ previousClosingPrice: Double) -> String{
        let priceChange = currentPrice - previousClosingPrice
        let formattedPriceChange = "\(roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: priceChange))"
        let sign = formattedPriceChange.first == "-" ?
            "" : "+"
        return sign + formattedPriceChange
    }
    
    func calculatePercentChange(_ currentPrice: Double, _ previousClosingPrice: Double) -> String{
        let percentChange = 100 * ((currentPrice - previousClosingPrice) / previousClosingPrice)
        let formmatedPercentChange = "\(roundTo(decimalPlace: Settings.roundingDecimalPlaces, withValue: percentChange))"
        let sign = formmatedPercentChange.first == "-" ?
            "" : "+"
        return sign + formmatedPercentChange
    }
    
    func roundTo(decimalPlace: Int, withValue: Double) -> Double{
        var base:Double = 10.0
        for _ in 0 ..< (decimalPlace - 1){
            base *= 10
        }
        return Double(round(base * withValue) / base)
    }
    
}
