//
//  AppUtilities.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

struct AppConstants{
    static let API_KEYS = ["bs88067rh5r8i6g9dhl0", "bsat2lnrh5r96cvcqtn0", "bsat31nrh5r96cvcqtu0", "bsat387rh5r96cvcquc0", ]
    static var CURRENT_API_KEY = AppConstants.API_KEYS[0]
    static func switchToNextAPIKey(){
        let currentKeyIndex = API_KEYS.firstIndex(of: CURRENT_API_KEY)!
        let newKeyIndex:Int!
        if currentKeyIndex == API_KEYS.count - 1{ // when CURRENT_API_KEY is the last key in array
            newKeyIndex = 0
        }else{
            newKeyIndex = currentKeyIndex + 1
        }
        CURRENT_API_KEY = API_KEYS[newKeyIndex]
    }
}

struct Stock{
    let name: String
    let price: Double
    let priceChange: Double
    let percentageChange: String
}

struct TradeDataPacket: Decodable{
    let p: Double // last price
    let s: String // symbol
    let t: Int64  // timestamp
    let v: Double // volume
}

struct StockQuote: Decodable{
    let c: Double // current price
    let h: Double // high price of the day
    let l: Double // low price of the day
    let o: Double // open price of the day
    let pc: Double // previous close price
    let t:Int64
    
    init(){
        self.c = 0.0
        self.h = 0.0
        self.l = 0.0
        self.o = 0.0
        self.pc = 0.0
        self.t = 0
    }
}
