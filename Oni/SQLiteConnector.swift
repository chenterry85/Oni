//
//  StockExchange.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/1.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteConnector {

    var db: OpaquePointer!
    let dbPath = Bundle.main.path(forResource: "US-all-data", ofType: "db") ?? ""
    static let shared = SQLiteConnector()
    
    private init() {}

    func searchStocks(withInput: String) -> [DB_Stock] {
        let sqlCommand = "SELECT * FROM  'US-all-data' WHERE symbol  LIKE '\(withInput)%'"
        var statement: OpaquePointer!
        var searchResult = [DB_Stock]()
        
        connectDatabase()
        
        if sqlite3_prepare_v2(db, sqlCommand, -1, &statement, nil) == SQLITE_OK{
            print("db: prepare_v2 success")
        }else{
            print("db: prepare_v2 failed")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW{
            var currency = "", description = "", displaySymbol = "", symbol = "", type = ""

            if let col0 = sqlite3_column_text(statement, 0){ currency = String(cString: col0) }
            if let col1 = sqlite3_column_text(statement, 1){ description = String(cString: col1) }
            if let col2 = sqlite3_column_text(statement, 2){ displaySymbol = String(cString: col2) }
            if let col3 = sqlite3_column_text(statement, 3){ symbol = String(cString: col3) }
            if let col4 = sqlite3_column_text(statement, 4){ type = String(cString: col4) }

            let extractedStock = DB_Stock(currency: currency, description: description, displaySymbol: displaySymbol, symbol: symbol, type: type)
            searchResult.append(extractedStock)
        }
        
        sqlite3_finalize(statement)
        return searchResult
    }

    private func connectDatabase(){
        if sqlite3_open(dbPath, &db) == SQLITE_OK{
            print("db: open success")
        }else{
            print("db: open failed")
        }
    }

}
