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
    var subscribedSymbols:[String] = []
    
    private init() {}
    
    func grabSubscribedStocksFromFirebase(){
        // grab user subscribed stocks from Firebase
        subscribedSymbols = ["AAPL", "IBM","CCL","TSLA"]
    }
    
    func connectToFinnhub(){
        finnhubConnector.start(myEventHandler: finnhubHandler(incoming:), onReadyEvent: finnhubReady)
    }
    
    func finnhubHandler(incoming: TradeDataPacket?){
        
    }
    
    func finnhubReady(){
        print("Event Ready")
        
        for symbol in subscribedSymbols{
            print(symbol)
            finnhubConnector.subscribe(withSymbol: symbol)
        }
       
        
        DispatchQueue.global(qos: .userInteractive).async {
            let _ = self.finnhubConnector.getStockQuote(withSymbol: "AAPL") {
                (stockQuote: StockQuote?) in
                if stockQuote != nil{
                    print(stockQuote!)
                }
            }
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
            
        if marketOpenTime <= currentTime && currentTime <= marketCloseTime{ // 9:00 am <= current time <= 4:00pm
            if weekday != 1 && weekday != 7 { //current day is not Saturday and Sunday
                return true
            }
        }
        
        return false
    }
    
}
