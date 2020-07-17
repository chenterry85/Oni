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

struct Packet: Decodable{
    let p:Double
    let s:String
    let t:Int64
    let v:Double
}
