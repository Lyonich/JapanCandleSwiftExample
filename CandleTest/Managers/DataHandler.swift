//
//  Datamanager.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 23/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

protocol DataHandlerDelegate: class {
    func didCreateCandle(_ candle: CandleModel)
    func didUpdateBidPrice(_ price: CGFloat)
    func dataDidFailure()
}

class DataHandler: NSObject,  WebSocketManagerDelegate {
    
    weak var delegate: DataHandlerDelegate?
    
    private let socketManager = WebSocketManager()
    
    private var lowerPriceCandle: CGFloat = 0.0
    private var higherPriceCandle: CGFloat = 0.0
    private var openPriceCandle: CGFloat = 0.0

    private var bidArray = [CGFloat]()
    
    private var timer:Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }
    
    func startUpdateRemoteData() {
        socketManager.delegate = self
        socketManager.connectToWebSocket()
    }
    
    func stopUpdateRemoteData() {
        timer = nil
        socketManager.disconnect()
    }
    
    // MARK: - WebSocketManagerDelegate
    
    func dataDidFailure() {
        stopUpdateRemoteData()
    }
    
    func didConnect() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] timer in
            let openPrice = self?.bidArray.first ?? 0.0
            let closePrice = self?.bidArray.last ?? 0.0
            let lowerPrice = self?.bidArray.min() ?? 0.0
            let higherPrice = self?.bidArray.max() ?? 0.0
            
            let candle = CandleModel(lowPrice: lowerPrice, highPrice: higherPrice, openPrice: openPrice, closePrice: closePrice)
            self?.delegate?.didCreateCandle(candle)
            
            self?.bidArray = [CGFloat]()
        })
    }
    
    func didUpdateBidPrice(price: CGFloat) {
        bidArray.append(price)
        delegate?.didUpdateBidPrice(price)
    }
    
}
