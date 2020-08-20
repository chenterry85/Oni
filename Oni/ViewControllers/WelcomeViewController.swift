//Welcome Screen (with Sign In and Log In)

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadDataToDB()
    }
    
    @IBAction func clickLogIn(){
        let userInfo = "info"
        performSegue(withIdentifier: "choseLogIn", sender: userInfo)
    }
    
    @IBAction func clickSignUp(){
        performSegue(withIdentifier: "choseSignUp", sender: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choseLogIn"{
        }
    }
    
    func loadDataToDB(){
        let databaseLoader = DatabaseLoader.shared
        let finnhubConnector = FinnhubConnector.shared
        let allStocks = databaseLoader.searchForStocks(withInput: "")

        let dg = DispatchGroup()

        for stock in allStocks{
            let symbol = stock.symbol
            
            dg.enter()
            finnhubConnector.getCompanyInfo(with: symbol) {
                (companyInfo: CompanyInfo?) in
                
                if let companyInfo = companyInfo{
                    let exchange = self.abbreviationForStockExchange(companyInfo.exchange)
                    print("\(symbol) has \(exchange)")
                    databaseLoader.fillIn(column: "exchange", with: exchange, if: "symbol", is: symbol)
                }else{
                    print("\(symbol) has no info")
                    databaseLoader.fillIn(column: "exchange", with: "", if: "symbol", is: symbol)
                }
                dg.leave()
            }
            
        }
        
        dg.wait()
    }
    
    func abbreviationForStockExchange(_ exchange: String) -> String{
        switch exchange {
        case "NEW YORK STOCK EXCHANGE, INC.":
            return "NYSE"
        case "NASDAQ NMS - GLOBAL MARKET":
            return "NASDAQ NMS"
        default:
            return exchange
        }
    }
}
