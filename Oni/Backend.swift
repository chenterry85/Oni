//
//  Backend.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

class Backend {
    
    var finnhubConnector:FinnhubConnector!
    
    func doSomething(){
        
        finnhubConnector = FinnhubConnector()
        finnhubConnector.start(myEventHandler: eventHandler(incoming:), onReadyEvent: eventReady)
        
    }
    
    func eventHandler(incoming: Packet?) -> () {
        
    }
    
    func eventReady() -> (){
        finnhubConnector.subscribe(withSymbol: "AAPL")
    }
    
}
