//
//  SearchViewController.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/31.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let sqliteConnector = SQLiteConnector.shared
    var allStocks = [DB_Stock]()
    var searchedStocks = [DB_Stock]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchBar.becomeFirstResponder()
        allStocks = sqliteConnector.searchStocks(withInput: "")
        
        let customCell = UINib(nibName: "SearchCell", bundle: nil)
        tableView.register(customCell, forCellReuseIdentifier: "searchCell")
        tableView.backgroundColor = .black
    }
    
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedStocks.count
        } else {
            return allStocks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        if isSearching {
            cell.stock = searchedStocks[indexPath.row]
        }else {
            cell.stock = allStocks[indexPath.row]
        }
        return cell
    }
    
}

extension SearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedStocks = sqliteConnector.searchStocks(withInput: searchText)
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // pop of out scene and return to watchlist
        //self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "unwindToWatchlist", sender: self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // close keyboard
        self.searchBar.endEditing(true)
    }
}
