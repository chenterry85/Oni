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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
