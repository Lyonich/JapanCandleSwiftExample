//
//  Strings+ConvertCGFloat.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 24/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

extension String {
    
    func CGFloatValue() -> CGFloat {
        guard let doubleValue = Double(self) else {
            return 0.0
        }
        
        return CGFloat(doubleValue)
    }
}
