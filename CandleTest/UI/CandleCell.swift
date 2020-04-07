//
//  CandleCell.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 22/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

class CandleCell: UICollectionViewCell {
    
    static let width: CGFloat = 40.0
    
    enum Constant {
        static let shadowWidth: CGFloat = 1
    }
    
    let bodyView = UIView()
    let shadowView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(bodyView)
        
        shadowView.backgroundColor = .black
        insertSubview(shadowView, at: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.shadowView.frame = CGRect(x: CandleCell.width / 2, y: self.frame.size.height, width: Constant.shadowWidth, height: 0)
        self.bodyView.frame = CGRect(x: 0, y: self.frame.size.height, width: CandleCell.width, height: 0)
    }
    
    func setTrand(_ trand: Trand) {
        switch trand {
        case .bullish:
            bodyView.backgroundColor = .green
        case .bearish:
            bodyView.backgroundColor = .red
        }
    }
    
    func setShadowFrame(height: CGFloat, y: CGFloat) {
        self.shadowView.frame = CGRect(x: CandleCell.width / 2, y: y, width: Constant.shadowWidth, height: height)
    }
    
    func setBodyFrame(height: CGFloat, y: CGFloat) {
        self.bodyView.frame = CGRect(x: 0, y: y, width: CandleCell.width, height: height)
    }
    
}
