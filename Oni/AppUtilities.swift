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
    var symbol: String
    var name: String
    var exchange: String
    var price: Double
    var priceChange: String
    var percentChange: String
    var previousClosePrice: Double
    var edittedTimestamp: Int64
    
    init(){
        self.symbol = ""
        self.name = ""
        self.exchange = ""
        self.price = 0.0
        self.priceChange = ""
        self.percentChange = ""
        self.previousClosePrice = 0.0
        self.edittedTimestamp = 0
    }
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
    let t: Int64 // timestamp
}

struct CompanyInfo: Decodable{
    let country: String
    let currency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Double
    let name: String
    let phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
}

struct StockCandle: Decodable{
    let c: [Double] // close price
    let h: [Double] // high price
    let l: [Double] // low price
    let o: [Double] // open price
    let s: String   // status of respond: (ok || no_data)
    let t: [Int64]  // timestamp
    let v: [Int64]  // volume
}

enum ChartTimespan{
    case oneDay
    case oneMonth
    case threeMonths
    case oneYear
    case threeYears
}

struct DB_Stock{
    let currency: String
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
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
