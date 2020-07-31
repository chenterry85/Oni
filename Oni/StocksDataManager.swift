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
    
    var subscribedSymbols: [String] = []
    var subscribedStocks: [Stock] = [Stock()]
    let finnhubConnector = FinnhubConnector.shared
    var refresher: Timer!
    var currentTableView: UITableView?
    
        
    private init() {
        fetchSubscribedStocksFromFirebase()
        fetchStockObjects()
        refresher = Timer.scheduledTimer(withTimeInterval: Settings.stockDataRefreshRate, repeats: true, block: { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshStockDataOnUI()
            }
        })
    }
    
    func connectToFinnhub(){
        finnhubConnector.start(myEventHandler: self.finnhubHandler(incoming:), onReadyEvent: self.finnhubReady)
    }
    
    func fetchSubscribedStocksFromFirebase(){
        // grab user subscribed stocks from Firebase
        subscribedSymbols = ["AAPL","IBM","GOOG","CCL","TSLA","MGM","AMZN","CRM","MSFT","DAL","AMD"]
           
        // init the size of subscribedStocks[]
        subscribedStocks = [Stock](repeating: Stock(), count: subscribedSymbols.count)
    }
    
    func fetchStockObjects(){
        DispatchQueue.global(qos: .userInitiated).sync{
            fetchNumericalStockComponents()
            fetchCompanyDetailStockComponents()
        }
    }
    
    func fetchNumericalStockComponents(){
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0 ..< subscribedSymbols.count{
            
            let symbol = subscribedSymbols[i]
            
            dispatchGroup.enter()
            finnhubConnector.getStockQuote(withSymbol: symbol) {
                (stockQuote: StockQuote?) in
                                
                if let stockQuote = stockQuote{
                    var updatedStock = self.subscribedStocks[i]
                    updatedStock.symbol = symbol
                    updatedStock.price = stockQuote.c.round(to: Settings.decimalPlace)
                    updatedStock.previousClosePrice = stockQuote.pc.round(to: Settings.decimalPlace)
                    updatedStock.priceChange = self.calculatePriceChange(updatedStock.price, updatedStock.previousClosePrice)
                    updatedStock.percentChange = self.calculatePercentChange(updatedStock.price, updatedStock.previousClosePrice)
                    updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
                    
                    self.subscribedStocks[i] = updatedStock
                    print(String(describing: updatedStock))
                }else{
                    // error when requesting stock quote
                }
                dispatchGroup.leave()
            }
        }
        
        //returns after all API calls are responded
        dispatchGroup.wait()
    }
    
    func fetchCompanyDetailStockComponents(){
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0 ..< subscribedSymbols.count{
            
            let symbol = subscribedSymbols[i]
            
            dispatchGroup.enter()
            finnhubConnector.getCompanyInfo(withSymbol: symbol) {
                (companyInfo: CompanyInfo?) in
                
                if let companyInfo = companyInfo{
                    var updatedStock = self.subscribedStocks[i]
                    updatedStock.name = companyInfo.name
                    updatedStock.exchange = self.abbreviationForStockExchange(companyInfo.exchange)
                    
                    self.subscribedStocks[i] = updatedStock
                    print(String(describing: updatedStock))
                }else{
                    // error when requesting company info
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            self.reloadTableView()
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
            // do something
        }else{
            print("makert closed")
        }
    }
    
    // called every 8 seconds
    func refreshStockDataOnUI(){
        
        print("Refreshing--------------------")
        
        let eight_seconds_ago = Int64(NSDate().timeIntervalSince1970) - 8
        let dispatchGroup = DispatchGroup()
    
        // ensure all stocks are refreshed in the last 8 seconds
        for i in 0 ..< subscribedStocks.count{

            let stock = subscribedStocks[i]
            var updatedStock = stock
                        
            if stock.edittedTimestamp < eight_seconds_ago{ // update stock that did not get updated by webscoekt
                
                print("Getting info for \(stock.symbol)")
                dispatchGroup.enter()

                finnhubConnector.getStockQuote(withSymbol: stock.symbol) {
                    (stockQuote: StockQuote?) in
                    if let stockQuote = stockQuote{
                        print("\(stock.symbol) with old price: \(stock.price), new price: \(stockQuote.c)")
                        updatedStock.price = stockQuote.c.round(to: Settings.decimalPlace)
                        updatedStock.priceChange = self.calculatePriceChange(updatedStock.price, updatedStock.previousClosePrice)
                        updatedStock.percentChange = self.calculatePercentChange(updatedStock.price, updatedStock.previousClosePrice)
                        updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
                        
                        self.subscribedStocks[i] = updatedStock
                    }else{
                        // invalid stock quote
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished Refreshing------------")
            self.reloadTableView()
        }

    }
    
    func updateStockData(withSymbol: String, withPrice: Double){
        if let index = subscribedSymbols.firstIndex(of: withSymbol){
            var updatedStock = subscribedStocks[index]
            updatedStock.price = withPrice.round(to: Settings.decimalPlace)
            updatedStock.priceChange = calculatePriceChange(updatedStock.price, updatedStock.previousClosePrice)
            updatedStock.percentChange = calculatePercentChange(updatedStock.price, updatedStock.previousClosePrice)
            updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
            
            subscribedStocks[index] = updatedStock
        }
    }
    
    func reloadTableView(){
        DispatchQueue.main.async {
            self.currentTableView?.reloadData()
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
    
    func calculatePriceChange(_ currentPrice: Double, _ previousClosePrice: Double) -> String{
        let priceChange = currentPrice - previousClosePrice
        let formattedPriceChange = "\(priceChange.round(to: Settings.decimalPlace))"
        let sign = formattedPriceChange.first == "-" ?
            "" : "+"
        return sign + formattedPriceChange
    }
    
    func calculatePercentChange(_ currentPrice: Double, _ previousClosePrice: Double) -> String{
        let percentChange = 100.0 * ((currentPrice - previousClosePrice) / previousClosePrice)
        let formmatedPercentChange = "\(percentChange.round(to: Settings.decimalPlace))"
        let sign = formmatedPercentChange.first == "-" ?
            "" : "+"
        return sign + formmatedPercentChange
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func abbreviationForStockExchange(_ exchange: String) -> String{
        switch exchange {
        case "NEW YORK STOCK EXCHANGE, INC.":
            return "NYSE"
        case "NASDAQ NMS - GLOBAL MARKET":
            return "NASDAQ"
        default:
            return exchange
        }
    }

}

extension Double{
    
    func round(to places: Int) -> Double{
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
