//
//  WatchlistViewController.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/22.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class WatchlistViewController: UITableViewController {

    let stocksDataManager = StocksDataManager.shared

    override func viewDidLoad(){
        super.viewDidLoad()
        
        stocksDataManager.connectToFinnhub()
        stocksDataManager.currentTableView = tableView
        
        let customCell = UINib(nibName: "StockCell", bundle: nil)
        tableView.register(customCell, forCellReuseIdentifier: "stock")
        tableView.backgroundColor = .black
    }
    
    @IBAction func addNewStock(_ sender: UIBarButtonItem){
        performSegue(withIdentifier: "addStock", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStock" {
            // prep
        }else if segue.identifier == "navigateToDetailPage"{
            let stock = sender as! Stock
            let detailPageVC = segue.destination as! DetailPageViewController
            detailPageVC.stock = stock
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocksDataManager.subscribedSymbols.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stock", for: indexPath) as! StockCell
        cell.stock = stocksDataManager.subscribedStocks[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StockCell
        
        if let stock = cell.stock {
            performSegue(withIdentifier: "navigateToDetailPage", sender: stock)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // handling deleted row
        if (editingStyle == .delete) {
            let cell = tableView.cellForRow(at: indexPath) as? StockCell
            if let stock = cell?.stock {
                stocksDataManager.unsubscribe(withSymbol: stock.symbol)
                print("Unsubscribe \(stock.symbol)")
                tableView.reloadData()
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
