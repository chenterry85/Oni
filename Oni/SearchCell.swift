//
//  UITableViewCell.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/4.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var addToWatchlistButton: UIButton!
    @IBOutlet weak var symbolWidth: NSLayoutConstraint!
    
    var stock: DB_Stock? {
        didSet{
            if let stock = stock{
                symbol.text = stock.symbol
                name.text = stock.description
                
                symbolWidth.constant = CGFloat(symbol.intrinsicContentSize.width)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addToWatchlistButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
