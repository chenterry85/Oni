//
//  ViewController.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/16.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let stocksDataManager = StocksDataManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stocksDataManager.connectToFinnhub()
        
    }


}

