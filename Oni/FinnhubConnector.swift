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
    var eventHandler: ((Packet? ) -> Void)?
    var eventReady: (() -> Void)?
    var connectionReady: Bool = false
    var subscribedSymbols: [String] = []
    var heartbeater: Timer?
    static let shared = FinnhubConnector()
    
    private init() {}
    
    func start(myEventHandler: @escaping (Packet?) -> Void, onReadyEvent: @escaping () -> Void) {
        
        eventHandler = myEventHandler
        eventReady = onReadyEvent
    
        let finnhubURL = URL(string: "wss://ws.finnhub.io?token=" + AppConstants.API_KEY)!
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
    
    func heartbeat() {
        socket?.write(string: "")
    }

    func websocketDidConnect(_ headers: [String:String]) {
        
        print("websocket is connected: \(headers)")

        connectionReady = true
        subscribedSymbols = []
        
        heartbeater = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
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
            socket?.write(string: "{\"topic\": \"iex:securities:\(withSymbol)\",\"event\": \"phx_leave\",\"payload\": {},\"ref\": null}")
        }
    }
    
    func websocketDidReceiveMessage(text: String) {
        
        print("Received text: \(text)")

        let decoder = JSONDecoder()
        do {
            let packet: Packet = try decoder.decode(Packet.self, from: text.data(using: .utf8)!)
            
            DispatchQueue.main.async {
                self.eventHandler!(packet)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    func websocketDidReceiveData(data: Data) {
        
        print("Received data: \(data.count)")
        
        let decoder = JSONDecoder()
        do {
            let packet: Packet = try decoder.decode(Packet.self, from: data)
            
            DispatchQueue.main.async {
                self.eventHandler!(packet)
            }
        } catch {
            print(error)
        }
    }
    
    
}


