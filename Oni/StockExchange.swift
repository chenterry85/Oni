//
//  StockExchange.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/1.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import SQLite3

var db:OpaquePointer!
let dbPath = Bundle.main.path(forResource: "US-all-data", ofType: "db") ?? ""

func searchResult(input: String) -> [String] {
    if sqlite3_open(dbPath, &db) == SQLITE_OK{
        print("db_open")
    }else{
        print("db_faile")
    }
    
    return []
}

