//
//  StockCell.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/25.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell {
    
    @IBOutlet private weak var symbol: UILabel!
    //@IBOutlet private weak var name: UILable!
    //@IBOutlet private weak var stockExchange: UILabel!
    @IBOutlet private weak var price: UILabel!
    @IBOutlet private weak var percentChange: UILabel!
    @IBOutlet private weak var changeWrapper: UIView!
    //@IBOutlet private weak var changeSymbol: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        changeWrapper.layer.cornerRadius = 5
    }
    
    var stock: Stock? {
        didSet {
            if let stock = stock{
                symbol.text = stock.symbol
                price.text = "\(stock.price)"
                percentChange.text = "\(stock.percentChange)"
                changeWrapper.backgroundColor = percentChange.text?.first == "+"
                    ? UIColor.green.withAlphaComponent(0.7)
                    : UIColor.red
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
