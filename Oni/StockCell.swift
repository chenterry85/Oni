//
//  StockCell.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/25.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation

class StockCell: UITableViewCell {
    
    var stock: Stock? {
        didSet {
            if let stock = stock{
                stockName.text = stock.name
            }
        }
    }
    
}
