//
//  StockExchange.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/1.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import SQLite3

var db: OpaquePointer!
let dbPath = Bundle.main.path(forResource: "US-all-data", ofType: "db") ?? ""

func searchResult(searchInput: String) -> [DB_Stock] {
    let sqlCommand = "SELECT * FROM  'US-all-data' WHERE symbol  LIKE '\(searchInput)%'"
    var statement: OpaquePointer!
    var searchResult = [DB_Stock]()
    
    connectDatabase()
    
    if sqlite3_prepare_v2(db, sqlCommand, -1, &statement, nil) == SQLITE_OK{
        print("db: prepare_v2 success")
    }else{
        print("db: prepare_v2 failed")
    }
    
    while sqlite3_step(statement) == SQLITE_ROW{
        let currency = String(cString: sqlite3_column_text(statement, 0))
        let description = String(cString: sqlite3_column_text(statement, 1))
        let displaySymbol = String(cString: sqlite3_column_text(statement, 2))
        let symbol = String(cString: sqlite3_column_text(statement, 3))
        let type = String(cString: sqlite3_column_text(statement, 4))
        
        let extractedStock = DB_Stock(currency: currency, description: description, displaySymbol: displaySymbol, symbol: symbol, type: type)
        searchResult.append(extractedStock)
    }
    
    sqlite3_finalize(statement)
    return searchResult
}

func connectDatabase(){
    if sqlite3_open(dbPath, &db) == SQLITE_OK{
        print("db: open success")
    }else{
        print("db: open failed")
    }
}

