//
//  ResponseModel.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 24/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

struct ResponseModel: Decodable {
    let ticks: [Ticket]?
}

struct Ticket: Decodable {
    let stockName: String?
    let bidPrice: String?
    let askPrice: String?
    
    enum CodingKeys: String, CodingKey {
        case stockName = "s"
        case bidPrice = "b"
        case askPrice = "a"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        stockName = try values.decodeIfPresent(String.self, forKey: .stockName)
        bidPrice = try values.decodeIfPresent(String.self, forKey: .bidPrice)
        askPrice = try values.decodeIfPresent(String.self, forKey: .askPrice)
    }
}
