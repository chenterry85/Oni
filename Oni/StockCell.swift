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
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var exchange: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var changeWrapper: UIView!
    @IBOutlet weak var positiveSignChangeIcon: UIImageView!
    @IBOutlet weak var negativeSignChangeIcon: UIImageView!


    var stock: Stock? {
        didSet {
            if let stock = stock{
                symbol.text = stock.symbol
                name.text = stock.name
                exchange.text = stock.exchange
                price.text = "\(stock.price)"
                percentChange.text = "\(stock.percentChange)%"
                changeWrapper.backgroundColor = percentChange.text?.first == "+"
                    ? UIColor.green.withAlphaComponent(0.7)
                    : UIColor.red
                positiveSignChangeIcon.image = percentChange.text?.first == "+"
                    ? UIImage(named: "double-up")
                    : UIImage(named: "empty-double-up")
                negativeSignChangeIcon.image = percentChange.text?.first == "-"
                    ? UIImage(named: "double-down")
                    : UIImage(named: "empty-double-down")
                
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
