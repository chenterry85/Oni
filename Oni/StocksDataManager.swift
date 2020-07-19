//
//  Backend.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

class StocksDataManager{
    
    let finnhubConnector = FinnhubConnector.shared
    static let shared = StocksDataManager()
    
    private init() {}
    
    func connectToFinnhub(){
        finnhubConnector.start(myEventHandler: finnhubHandler(incoming:), onReadyEvent: finnhubReady)
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
            
        if marketOpenTime <= currentTime && currentTime <= marketCloseTime{
            if weekday != 1 && weekday != 7 { //if current day is not Saturday and Sunday
                return true
            }
        }
        
        return false
    }
    
    func finnhubHandler(incoming: Packet?) -> () {
        
    }
    
    func finnhubReady() -> (){
        print("Event Ready")
        finnhubConnector.subscribe(withSymbol: "IBM")
        finnhubConnector.subscribe(withSymbol: "CCL")
    }
    
}
