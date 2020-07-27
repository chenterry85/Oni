//
//  StockCell.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/25.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell{
    
    @IBOutlet weak var symbol: UILabel!
    //@IBOutlet private weak var name: UILable!
    //@IBOutlet private weak var stockExchange: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var changeWrapper: UIView!
    @IBOutlet weak var changeSymbol: UIImageView!

    var stock: Stock? {
        didSet {
            if let stock = stock{
                symbol.text = stock.symbol
                price.text = "\(stock.price)"
                percentChange.text = "\(stock.percentChange)%"
                changeWrapper.backgroundColor = percentChange.text?.first == "+"
                    ? UIColor.green.withAlphaComponent(0.7)
                    : UIColor.red
                changeSymbol.image = percentChange.text?.first == "+"
                    ? UIImage(named: "double--up")
                    : UIImage(named: "double--down")
                
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        changeWrapper.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
