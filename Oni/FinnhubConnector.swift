//
//  FinnhubConnector.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/17.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import Starscream

class FinnhubConnector: WebSocketDelegate{
    
    var socket: WebSocket?
    var eventHandler: ((TradeDataPacket) -> Void)?
    var eventReady: (() -> Void)?
    var connectionReady: Bool = false
    var subscribedSymbols: [String] = []
    var heartbeater: Timer?
    static let shared = FinnhubConnector()
    
    private init() {}
    
    func start(myEventHandler: @escaping (TradeDataPacket) -> Void, onReadyEvent: @escaping () -> Void) {
        
        eventHandler = myEventHandler
        eventReady = onReadyEvent
    
        let finnhubURL = URL(string: "wss://ws.finnhub.io?token=" + AppConstants.CURRENT_API_KEY)!
        socket = WebSocket(request: URLRequest(url: finnhubURL))
        socket?.delegate = self
        socket?.connect()
    
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            websocketDidConnect(headers)
        case .disconnected(let reason, let code):
            websocketDidDisconnect(reason, code)
        case .text(let string):
            websocketDidReceiveMessage(text: string)
        case .binary(let data):
            websocketDidReceiveData(data: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            connectionReady = false
        case .error(let error):
            connectionReady = false
            //handleError(error)
        }
    }
    
    func heartbeat() { // Send data to finnhub periodically to prevent disconnection for inactivity
        socket?.write(string: "")
    }

    func websocketDidConnect(_ headers: [String:String]) {
        
        print("websocket is connected: \(headers)")

        connectionReady = true
        
        heartbeater = Timer.scheduledTimer(withTimeInterval: Settings.heartbeatTimeInterval, repeats: true) { [weak self] _ in
            self?.heartbeat()
        }
        
        DispatchQueue.main.async {
            self.eventReady!()
        }
        
    }
    
    func websocketDidDisconnect(_ reason: String, _ code: UInt16) {
        
        print("websocket is dconnectionReady: \(reason) with code: \(code)")

        connectionReady = false
        heartbeater?.invalidate()
    }
    
    func subscribe(withSymbol: String) {
        if subscribedSymbols.firstIndex(of: withSymbol) == nil {
            subscribedSymbols.append(withSymbol)
            socket?.write(string: "{\"type\":\"subscribe\",\"symbol\":\"\(withSymbol)\"}")
        }
    }
    
    func unsubscribe(withSymbol: String) {
        if let index = subscribedSymbols.firstIndex(of: withSymbol) {
            subscribedSymbols.remove(at: index)
            socket?.write(string: "{\"type\":\"unsubscribe\",\"symbol\":\"\(withSymbol)\"}")
        }
    }
    
    func websocketDidReceiveMessage(text: String) {
        
        print("Received text: \(text)")

        let rawJSONData = text.data(using: .utf8)!
        
        do{
            if let jsonObject = try JSONSerialization.jsonObject(with:rawJSONData, options :[]) as? Dictionary<String,Any>{
                
                let messageType = jsonObject["type"] as! String
                switch messageType{
                    case "trade":
                        let rawTradeData = jsonObject["data"] as? [[String:Any]]
                        let tradeData = TradeDataPacket(with: rawTradeData![0])
                        print("trade: " + String(describing: tradeData))
                        DispatchQueue.main.async {
                            self.eventHandler!(tradeData)
                        }
                    case "ping":
                        return
                    case "error":
                        return
                    default:
                        return
                }
                
            }
        }catch let error as NSError{
            print(error)
        }
        
    }
    
    func websocketDidReceiveData(data: Data) {
        
        print("Received data: \(data.count)")
        
        let decoder = JSONDecoder()
        do {
            //let tradeDataPacket: TradeDataPacket = try decoder.decode(TradeDataPacket.self, from: data)
            
            DispatchQueue.main.async {
                //self.eventHandler!(tradeDataPacket)
            }
        } catch {
            print(error)
        }
    }
    
    func getStockQuote(withSymbol: String, stockQuoteCompleteHandler: @escaping (_ stockQuote: StockQuote?) -> Void){
                
        guard let requestURL = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(withSymbol)&token=\(AppConstants.CURRENT_API_KEY)") else {
            print("Stock Quote URL invalid")
            return
        }
            
        let task = URLSession.shared.downloadTask(with: requestURL, completionHandler: {
            (url:URL?, response:URLResponse?, error:Error?) in
            
            guard let url=url, let response=response else{
                print("error in grabbing Stock Quote JSON")
                return
            }
           
            guard error == nil else{
                print(error!);
                return
            }
           
            guard (response as! HTTPURLResponse).statusCode == 200 else { // status code 200 =  success download
                print("Grab Stock Quote failed")
                return
            }
           
            guard let data = try? Data.init(contentsOf: url) else{
                return
            }

            if let stockQuote = try? JSONDecoder().decode(StockQuote.self, from: data) {
                stockQuoteCompleteHandler(stockQuote) // return valid stock quote
            }
            
        })
        stockQuoteCompleteHandler(nil) // return nil when catch errors
        task.resume()
    }
    
    
}


