//
//  CandleModel.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 24/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

enum Trand {
    case bullish
    case bearish
}

struct CandleModel {
    
    let lowPrice: CGFloat
    let highPrice: CGFloat
    let openPrice: CGFloat
    let closePrice: CGFloat
    
    var trand: Trand {
        return closePrice -  openPrice >= 0 ? .bullish : .bearish
    }
    
}
