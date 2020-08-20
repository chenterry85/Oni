//
//  DetailPageViewController.swift
//  Oni
//
//  Created by Terry Chen on 2020/8/16.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit
import Charts
import TinyConstraints

class DetailPageViewController: UIViewController, ChartViewDelegate{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var exchange: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var chartHolderView: UIView!
    
    let stockDataManger = StocksDataManager.shared
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        return chartView
    }()
    
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
        
        //Line Chart Settings
        chartHolderView.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: chartHolderView)
        lineChartView.height(to: chartHolderView)
        
        
        let points = stockDataManger.getStockCandleChartEntry(for: symbol.text!, in: .oneDay)
        print(String(describing: points))
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    }

}
