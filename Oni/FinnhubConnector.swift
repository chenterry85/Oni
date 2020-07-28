//
//  FinnhubConnector.swift
//  Oni
//
//  Created by Terry Chen on 2020/7/17.
//  Copyright © 2020 Terry Chen. All rights reserved.
//

import Foundation
import Alamofire
import Starscream

class FinnhubConnector: WebSocketDelegate{
    
    var socket: WebSocket?
    var eventHandler: ((TradeDataPacket) -> Void)?
    var eventReady: (() -> Void)?
    var connectionReady: Bool = false
    var heartbeater: Timer?
    
    var stocksDataManger: StocksDataManager!
    static let shared = FinnhubConnector()
    
    private init() {}
    
    func start(myEventHandler: @escaping (TradeDataPacket) -> Void, onReadyEvent: @escaping () -> Void) {
        
        eventHandler = myEventHandler
        eventReady = onReadyEvent
        stocksDataManger = StocksDataManager.shared
    
        let finnhubURL = URL(string: "wss://ws.finnhub.io?token=" + API.CURRENT_KEY)!
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
        
        print("heartbeat")
        for symbol in stocksDataManger.subscribedSymbols{
            socket?.write(string: "{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}")
        }
        
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
        if stocksDataManger.subscribedSymbols.firstIndex(of: withSymbol) == nil{
            stocksDataManger.subscribedSymbols.append(withSymbol)
            socket?.write(string: "{\"type\":\"subscribe\",\"symbol\":\"\(withSymbol)\"}")
        }
    }
    
    func unsubscribe(withSymbol: String) {
        if let index = stocksDataManger.subscribedSymbols.firstIndex(of: withSymbol) {
            stocksDataManger.subscribedSymbols.remove(at: index)
            socket?.write(string: "{\"type\":\"subscribe\",\"symbol\":\"\(withSymbol)\"}")
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
        
        AF.request("https://finnhub.io/api/v1/quote?symbol=\(withSymbol)&token=\(API.CURRENT_KEY)")
            .validate()
            .responseJSON { [unowned self] response in
                guard let data = response.data else {
                    print("Error fetching stock quote")
                    stockQuoteCompleteHandler(nil)
                    return
                }
                
                if let stockQuote = try? JSONDecoder().decode(StockQuote.self, from: data) {
                    stockQuoteCompleteHandler(stockQuote)
                }

        }
    }
    
}


