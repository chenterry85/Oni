//
//  StockCell.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/25.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell{

    var stock: Stock? {
        didSet {
            if let stock = stock{
                symbol.text = stock.symbol
                price.text = "\(stock.price)"
                percentChange.text = "\(stock.percentChange)"
                changeWrapper.layer.cornerRadius = 5
                changeWrapper.backgroundColor = percentChange.text?.first == "+"
                    ? UIColor.green.withAlphaComponent(0.7)
                    : UIColor.red
            }
        }
    }
    
    @IBOutlet weak var symbol: UILabel!
    //@IBOutlet private weak var name: UILable!
    //@IBOutlet private weak var stockExchange: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var changeWrapper: UIView!
    //@IBOutlet private weak var changeSymbol: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
