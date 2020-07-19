//
//  AppUtilities.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/18.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

struct AppConstants{
    static let API_KEY = "bs88067rh5r8i6g9dhl0"
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
