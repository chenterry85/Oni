//
//  Backend.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import Charts
import UIKit

class StocksDataManager{
    
    static let shared = StocksDataManager()
    
    let finnhubConnector = FinnhubConnector.shared
    let sqliteConnector = SQLiteConnector.shared
    
    var subscribedSymbols: [String] = []
    var subscribedStocks: [Stock] = [Stock()]
    var refresher: Timer!
    var currentTableView: UITableView?
        
    private init() {
        fetchSubscribedStocksFromFirebase()
        initStockObject()
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
    
    func initStockObject(){
        DispatchQueue.global(qos: .userInteractive).async{
            self.fetchNumericalStockComponents(symbols: self.subscribedSymbols)
            self.fetchCompanyDetailStockComponents(symbols: self.subscribedSymbols)
            self.reloadTableView()
        }
    }
    
    func fetchNumericalStockComponents(symbols: [String]){
        
        let dispatchGroup = DispatchGroup()
        
        for (index, symbol) in zip(0 ..< symbols.count, symbols){
                        
            dispatchGroup.enter()
            finnhubConnector.getStockQuote(with: symbol) {
                (stockQuote: StockQuote?) in
                                
                if let stockQuote = stockQuote{
                    var updatedStock = self.subscribedStocks[index]
                    updatedStock.symbol = symbol
                    updatedStock.price = stockQuote.c.round(to: Settings.decimalPlace)
                    updatedStock.previousClosePrice = stockQuote.pc.round(to: Settings.decimalPlace)
                    updatedStock.priceChange = calculatePriceChange(updatedStock.price, updatedStock.previousClosePrice)
                    updatedStock.percentChange = calculatePercentChange(updatedStock.price, updatedStock.previousClosePrice)
                    updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
                    
                    self.subscribedStocks[index] = updatedStock
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
    
    func fetchCompanyDetailStockComponents(symbols: [String]){
        
        let dispatchGroup = DispatchGroup()
        
        for (index, symbol) in zip(0 ..< symbols.count,symbols) {
                        
            dispatchGroup.enter()
            finnhubConnector.getCompanyInfo(with: symbol) {
                (companyInfo: CompanyInfo?) in
                
                if let companyInfo = companyInfo{
                    var updatedStock = self.subscribedStocks[index]
                    let stockFromDB: DB_Stock = self.sqliteConnector.getStock(withSymbol: symbol)
                    
                    updatedStock.name = stockFromDB.description
                    updatedStock.exchange = abbreviationForStockExchange(companyInfo.exchange)
                    
                    self.subscribedStocks[index] = updatedStock
                    print(String(describing: updatedStock))
                }else{
                    // error when requesting company info
                }
                dispatchGroup.leave()
            }
        }
        
        //returns after all API calls are responded
        dispatchGroup.wait()
    }
    
    func finnhubHandler(incoming: TradeDataPacket){
        let stockSymbol = incoming.symbol
        let currentPrice = incoming.price
        updateStockData(with: stockSymbol, and: currentPrice)
    }
    
    func finnhubReady(){
        print("Finnhub Ready")
        
        for symbol in subscribedSymbols{
            subscribe(with: symbol)
        }
        
        if marketIsOpen(){
            // do something
        }else{
            print("makert closed")
        }
    }
    
    func subscribe(with symbol: String){
           if subscribedSymbols.firstIndex(of: symbol) == nil {
               subscribedSymbols.append(symbol)
               finnhubConnector.subscribe(with: symbol)
           }
       }
       
       func unsubscribe(with symbol: String){
           if let index = subscribedSymbols.firstIndex(of: symbol) {
               subscribedSymbols.remove(at: index)
               subscribedStocks.remove(at: index)
               finnhubConnector.unsubscribe(with: symbol)
           }
       }
    
    // called every 8 seconds
    func refreshStockDataOnUI(){
        
        print("Refreshing--------------------")
        
        let eight_seconds_ago = Int64(NSDate().timeIntervalSince1970) - 8
        let dispatchGroup = DispatchGroup()
    
        // ensure all stocks are refreshed in the last 8 seconds
        for (index, stock) in zip(0 ..< subscribedStocks.count, subscribedStocks){

            var updatedStock = stock
                        
            if stock.edittedTimestamp < eight_seconds_ago{ // update stock that did not get updated by webscoekt
                
                print("Getting info for \(stock.symbol)")
                dispatchGroup.enter()

                finnhubConnector.getStockQuote(with: stock.symbol) {
                    (stockQuote: StockQuote?) in
                    if let stockQuote = stockQuote{
                        print("\(stock.symbol) with old price: \(stock.price), new price: \(stockQuote.c)")
                        updatedStock.price = stockQuote.c.round(to: Settings.decimalPlace)
                        updatedStock.priceChange = calculatePriceChange(updatedStock.price, updatedStock.previousClosePrice)
                        updatedStock.percentChange = calculatePercentChange(updatedStock.price, updatedStock.previousClosePrice)
                        updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
                        
                        self.subscribedStocks[index] = updatedStock
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
    
    func updateStockData(with symbol: String, and price: Double){
        if let index = subscribedSymbols.firstIndex(of: symbol){
            var updatedStock = subscribedStocks[index]
            updatedStock.price = price.round(to: Settings.decimalPlace)
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
    
    // function called from searchVC
    func addNewStockObject(with symbol: String, and description: String){
        
        if subscribedSymbols.contains(symbol){ // exit function if stock already exists
            return
        }
        
        subscribe(with: symbol)
        subscribedStocks.append(Stock()) // init empty stock container
        let newStockIndex = subscribedStocks.count - 1
        
        //fill in company name
        var updatedStock = subscribedStocks[newStockIndex]
        updatedStock.symbol = symbol
        updatedStock.name = description
        subscribedStocks[newStockIndex] = updatedStock
        
        // fetch stock info
        DispatchQueue.global(qos: .userInteractive).async{
            
            let dg1 = DispatchGroup()
            dg1.enter()
            
            self.finnhubConnector.getStockQuote(with: symbol) {
                (stockQuote: StockQuote?) in
                                
                if let stockQuote = stockQuote{
                    var updatedStock = self.subscribedStocks[newStockIndex]
                    updatedStock.price = stockQuote.c.round(to: Settings.decimalPlace)
                    updatedStock.previousClosePrice = stockQuote.pc.round(to: Settings.decimalPlace)
                    updatedStock.priceChange = calculatePriceChange(updatedStock.price, updatedStock.previousClosePrice)
                    updatedStock.percentChange = calculatePercentChange(updatedStock.price, updatedStock.previousClosePrice)
                    updatedStock.edittedTimestamp = Int64(NSDate().timeIntervalSince1970)
                    
                    self.subscribedStocks[newStockIndex] = updatedStock
                    print(String(describing: updatedStock))
                }else{
                    // error when requesting stock quote
                }
                dg1.leave()
            }
            dg1.wait()
            
            self.reloadTableView()
            
            let dg2 = DispatchGroup()
            dg2.enter()
            
            self.finnhubConnector.getCompanyInfo(with: symbol) {
                (companyInfo: CompanyInfo?) in
                
                if let companyInfo = companyInfo{
                    var updatedStock = self.subscribedStocks[newStockIndex]
                    updatedStock.exchange = abbreviationForStockExchange(companyInfo.exchange)
                    
                    self.subscribedStocks[newStockIndex] = updatedStock
                    print(String(describing: updatedStock))
                }else{
                    // error when requesting company info
                }
                dg2.leave()
            }
            dg2.wait()
            
            self.reloadTableView()
        }
    }
    
    func getStockCandleChartDataEntry(with symbol: String, in timespan: ChartTimespan) -> [ChartDataEntry]{
        let now = NSDate().timeIntervalSince1970
        var startingTimestamp: Double = 0.0
        var chartEntryList = [ChartDataEntry]()
    
        switch timespan{
        case .oneDay:
            let secondsInOneDay = 86400.0
            startingTimestamp = now - secondsInOneDay
        case .oneMonth:
            let secondsInOneMonth = 2592000.0
            startingTimestamp = now - secondsInOneMonth
        case .threeMonths:
            let secondsInThreeMonth = 7776000.0
            startingTimestamp = now - secondsInThreeMonth
        case .oneYear:
            let secondsInOneYear = 31536000.0
            startingTimestamp = now - secondsInOneYear
        case .threeYears:
            let secondsInThreeYears = 94608000.0
            startingTimestamp = now - secondsInThreeYears
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        finnhubConnector.getStockCandle(with: symbol, from: Int64(startingTimestamp), to: Int64(now)) {
            (stockCandle: StockCandle?) in
            if let stockCandle = stockCandle{
                
                let openPrices = stockCandle.o
                for (index, price) in zip(1...openPrices.count, openPrices){
                    let entry = ChartDataEntry(x: Double(index), y: price)
                    chartEntryList.append(entry)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        return chartEntryList
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
    

}

extension Double{

    func round(to places: Int) -> Double{
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
