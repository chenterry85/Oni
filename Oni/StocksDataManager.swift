//
//  Backend.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

class StocksDataManager{
    
    var finnhubConnector:FinnhubConnector!
    
    init() {
        
        finnhubConnector = FinnhubConnector()
        finnhubConnector.start(myEventHandler: eventHandler(incoming:), onReadyEvent: eventReady)
        
    }
    
    func timezone(){
        let secondsInOneHour = 3600.0
        let timestamp = NSDate().timeIntervalSince1970
        let wallStreetTimestamp = timestamp - (secondsInOneHour * 4)
        let time = NSDate(timeIntervalSince1970: wallStreetTimestamp)
        print(time)
        
        let now = Date()
        let calendar = Calendar.current
        print(calendar.date(bySettingHour: 17, minute: 30, second: 0, of: now)!)
        print(NSDate(timeIntervalSince1970: calendar.startOfDay(for: now).timeIntervalSince1970 + (secondsInOneHour * 24)))
    }
    
    func eventHandler(incoming: Packet?) -> () {
        
    }
    
    func eventReady() -> (){
        print("Event Ready")
        finnhubConnector.subscribe(withSymbol: "IBM")
        finnhubConnector.subscribe(withSymbol: "CCL")

    }
    
}
