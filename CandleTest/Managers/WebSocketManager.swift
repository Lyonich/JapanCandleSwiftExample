//
//  WebSocketManager.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 23/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit
import Starscream

protocol WebSocketManagerDelegate: class {
    func didUpdateBidPrice(price: CGFloat)
    func didConnect()
    func dataDidFailure()
}


class WebSocketManager: NSObject, WebSocketDelegate {
    
    enum Constant {
        static let urlString = "wss://quotes.eccalls.mobi:18400"
        static let subscribeMessage = "SUBSCRIBE: BTCUSD"
    }
    
    let socket = WebSocket(request: URLRequest(url: URL(string: Constant.urlString, relativeTo: nil)!), certPinner: nil)
    
    weak var delegate: WebSocketManagerDelegate?
    
    func connectToWebSocket() {
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    // MARK: - WebSocketManagerDelegate
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            delegate?.didConnect()
            socket.write(string: Constant.subscribeMessage, completion: nil)
        case .disconnected(let reason, let code):
            delegate?.dataDidFailure()
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            guard let data: Data = string.data(using: .utf8) else { return }
            
            if let tickData = try? JSONDecoder().decode(ResponseModel.self, from: data) {
                guard let tick = tickData.ticks?.first, let bidPrice = tick.bidPrice else { return }
                print(tick)
                delegate?.didUpdateBidPrice(price: bidPrice.CGFloatValue())
            }
        case .cancelled:
            delegate?.dataDidFailure()
        case .error(_):
            delegate?.dataDidFailure()
        default:
            break
        }
    }

    
}
