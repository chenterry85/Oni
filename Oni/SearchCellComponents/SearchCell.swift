//
//  UITableViewCell.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/4.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

protocol NewStockAdded{
    func displayAlert(forSymbol: String)
}

class SearchCell: UITableViewCell {

    var stocksDataManager: StocksDataManager!
    var cellDelegate: NewStockAdded?
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var symbolWidth: NSLayoutConstraint!
    
    
    var stock: DB_Stock? {
        didSet{
            if let stock = stock{
                symbol.text = stock.symbol
                name.text = stock.description
                
                stocksDataManager = StocksDataManager.shared
                symbolWidth.constant = CGFloat(symbol.intrinsicContentSize.width)
            }
        }
    }
    
    @IBAction func addStock(_ sender: UIButton){
        let symbol = stock?.symbol ?? ""
        let description = stock?.description ?? ""
        
        stocksDataManager.addNewStockObject(with: symbol, and: description)
        cellDelegate?.displayAlert(forSymbol: symbol)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
