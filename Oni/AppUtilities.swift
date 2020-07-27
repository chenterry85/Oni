//
//  AppUtilities.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

class App{
    enum State{
        case unregistered
        case loggedIn(User)
        case sessionExpired(User)
    }
    
    var state: State = .unregistered
}

struct API{
    static let KEYS = ["bs88067rh5r8i6g9dhl0", "bsat2lnrh5r96cvcqtn0", "bsat31nrh5r96cvcqtu0", "bsat387rh5r96cvcquc0", ]
    static var CURRENT_KEY = KEYS[0]
    static func switchToNextKey(){
        let currentKeyIndex = KEYS.firstIndex(of: CURRENT_KEY)!
        let newKeyIndex:Int!
        if currentKeyIndex == KEYS.count - 1{ // when CURRENT_API_KEY is the last key in array
            newKeyIndex = 0
        }else{
            newKeyIndex = currentKeyIndex + 1
        }
        CURRENT_KEY = KEYS[newKeyIndex]
    }
}

struct Stock{
    let symbol: String
    let name: String
    var price: Double
    var priceChange: String
    var percentChange: String
    var previousClosePrice: Double
    var edittedTimestamp: Int64
}

struct TradeDataPacket{
    let price: Double
    let symbol: String
    let timestamp: Int64
    let volume: Double
    
    init(with dictionary: [String:Any]?){
        guard let dictionary = dictionary else {
            price = 0.0
            symbol = ""
            timestamp = Int64(NSDate().timeIntervalSince1970)
            volume = 0.0
            return
        }
        price = dictionary["p"] as! Double
        symbol = dictionary["s"] as! String
        timestamp = dictionary["t"] as! Int64
        volume = dictionary["v"] as! Double
    }
}

struct StockQuote: Decodable{
    let c: Double // current price
    let h: Double // high price of the day
    let l: Double // low price of the day
    let o: Double // open price of the day
    let pc: Double // previous close price
    let t:Int64 // timestamp
    
    init(){
        self.c = 0.0
        self.h = 0.0
        self.l = 0.0
        self.o = 0.0
        self.pc = 0.0
        self.t = 0
    }
}
