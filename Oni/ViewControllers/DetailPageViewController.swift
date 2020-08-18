//
//  DetailPageViewController.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/16.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class DetailPageViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var exchange: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var percentChange: UILabel!
    
    var stock: Stock!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let priceChangeSign = stock.percentChange.first == "+" ? "▲" : "▼"

        name.text = stock.name
        symbol.text = stock.symbol
        //currency.text = stock?.currency
        exchange.text = stock.exchange
        price.text = "$ \(stock.price)"
        priceChange.text = "\(priceChangeSign) \(stock.priceChange)"
        percentChange.text = "\(stock.percentChange)%"
        
        priceChange.textColor = percentChange.text?.first == "+"
            ? Settings.customGreen
            : Settings.customRed
        percentChange.textColor = percentChange.text?.first == "+"
            ? Settings.customGreen
            : Settings.customRed
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
