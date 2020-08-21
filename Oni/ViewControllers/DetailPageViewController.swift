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
    
    let stocksDataManager:StocksDataManager = StocksDataManager.shared
    var stock: Stock!
    var yValues: [ChartDataEntry] = []
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .insideChart
        
        chartView.xAxis.labelPosition = .bottom
        
        return chartView
    }()
    

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //yValues = stocksDataManager.getStockCandleChartDataEntry(with: name.text!, in: .oneDay)
        for i in 0...40 {
            yValues.append(ChartDataEntry(x: Double(i), y: Double(Int.random(in: 0...100 ))))
        }
        setData()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Price")
        
        let data = LineChartData(dataSet: set1)
        lineChartView.data = data
    }
    
}
