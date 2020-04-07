//
//  Generator.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 22/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

class TestGenerator {
    
    var timer : Timer?
    
    func startGenerate(minValue: CGFloat, maxValue: CGFloat,  candle: ((CandleModel) -> Void)?) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            candle?(self.randomCandle(minValue: minValue, maxValue: maxValue))
        }
    }
    
    func stopGenerate() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private
    
    private func randomCandle(minValue: CGFloat, maxValue: CGFloat) -> CandleModel {
        let lowPrice = randomFloat() * (maxValue - minValue) + [maxValue, minValue].min()!
        let highPrice = randomFloat() * ([maxValue, minValue].max()! - lowPrice) + lowPrice
        let openPrice = randomFloat() * (highPrice - lowPrice) + lowPrice
        let closePrice = randomFloat() * (highPrice - lowPrice) + lowPrice
        
        return CandleModel(lowPrice: lowPrice, highPrice: highPrice, openPrice: openPrice, closePrice: closePrice)
    }
    
    private func randomFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
}








