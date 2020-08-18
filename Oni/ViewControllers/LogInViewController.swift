//
//  LogInViewController.swift
//  Omnic - ETF
//
//  Created by Terry Chen on 2020/7/7.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    @IBAction func clickLogIn(){
        performSegue(withIdentifier: "userLogIn", sender: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userLogIn"{
            
        }
    }
    

}
