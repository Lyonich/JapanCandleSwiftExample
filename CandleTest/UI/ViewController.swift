//
//  ViewController.swift
//  CandleTest
//
//  Created by Leonid Kibukevich on 22/03/2020.
//  Copyright © 2020 Leonid Kibukevich. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DataHandlerDelegate {
    
    enum Constant {
        static let deltaDiapason: CGFloat = 10
        static let errorTitle = "Error"
        static let errorMessage = "No connection to server"
        static let errorOkTitle = "OK"
    }
    
    var maxVisibleValue: CGFloat = 0 {
        didSet {
            maxValueLabel.text = String(describing: maxVisibleValue)
        }
    }
    var minVisiblevalue: CGFloat = 0 {
        didSet {
            minValueLabel.text = String(describing: minVisiblevalue)
        }
    }
    
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var testModeButton: UIButton!
    @IBOutlet weak var onlineModeButton: UIButton!
    @IBOutlet weak var scaleSwitch: UISwitch!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: [CandleModel] = [CandleModel]()
    
    var candleGenerator = TestGenerator()
    let dataHandler = DataHandler()
    
    var lastPrice: CGFloat = 0.0
    var firstPrice: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataHandler.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - DataHandlerDelegate
    
    func didUpdateBidPrice(_ price: CGFloat) {
        if firstPrice == nil {
            if maxVisibleValue == 0 && minVisiblevalue == 0 {
                maxVisibleValue = price + Constant.deltaDiapason
                minVisiblevalue = price - Constant.deltaDiapason
            }

            firstPrice = price
            lastPrice = price
        } else {
            lastPrice = price
        }
        
        rescale()
    }
    
    func didCreateCandle(_ candle: CandleModel) {
        firstPrice = nil
        handlerNewCandle(candle)
    }
    
    func dataDidFailure() {
        let alert = UIAlertController(title: Constant.errorTitle, message: Constant.errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constant.errorOkTitle, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    /// включение / выключение режима автомасштаирования
    @IBAction private func switchAction(_ sender: UISwitch) {
        if !sender.isOn {
            maxVisibleValue += Constant.deltaDiapason
            minVisiblevalue -= Constant.deltaDiapason
        }
    }
    
    ///включение режима получения данных из Интернета
    @IBAction private func onlineButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            dataHandler.stopUpdateRemoteData()
        } else {
            dataSource = [CandleModel]()
            dataHandler.startUpdateRemoteData()
        }
    
        sender.isSelected = !sender.isSelected
        testModeButton.isEnabled = !sender.isSelected
    }
    
    ///включение режима генерации тестовых данных
    @IBAction private func testModeButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            candleGenerator.stopGenerate()
        } else {
            dataSource = [CandleModel]()
            
            let testDelta: CGFloat = 100
            
            // Для демонстрации автомасштабирования в режиме генерации свечей
            maxVisibleValue = testDelta / 10
            minVisiblevalue = -(testDelta / 10)
            
            candleGenerator.startGenerate(minValue: -testDelta, maxValue: testDelta) { [weak self] candle in
                self?.handlerNewCandle(candle)
            }
        }
        
        sender.isSelected = !sender.isSelected
        onlineModeButton.isEnabled = !sender.isSelected
    }
    
    //сохранение свечи
    private func handlerNewCandle(_ candle: CandleModel) {
        DispatchQueue.main.async {
            self.dataSource.append(candle)
            if candle.highPrice > self.maxVisibleValue {
                self.maxVisibleValue = candle.highPrice
            }
            
            if candle.lowPrice < self.minVisiblevalue {
                self.minVisiblevalue = candle.lowPrice
            }
            
            self.collectionView.performBatchUpdates({ [weak self] in
                let indexSet = IndexSet(integersIn: 0...0)
                self?.collectionView.reloadSections(indexSet)
            }, completion: nil)
            
            let index = IndexPath(row: (self.dataSource.count), section: 0)
            self.collectionView.scrollToItem(at: index, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    ///вычисление высоты тени и тела свечи
    private func calculateHeight(startPrice: CGFloat, endPrice: CGFloat) -> CGFloat {
        let pixelValue: CGFloat = collectionView.frame.size.height / (maxVisibleValue - minVisiblevalue)
        let prices = [startPrice, endPrice]
        
        return (prices.max()! - prices.min()!) * pixelValue
    }
    
    ///вычисление вертикальной координаты для тени и тела свечи
    private func calculateYPosition(startPrice: CGFloat, endPrice: CGFloat) -> CGFloat {
        let pixelValue: CGFloat = collectionView.frame.size.height / (maxVisibleValue - minVisiblevalue)
        
        let maxValue = [startPrice, endPrice].max()!
        
        let inset = maxVisibleValue - maxValue
        
        return inset * pixelValue
    }
    
    ///пересчета масштабирования по максимальному и минимальному видимому значения с учетом "дельта-отступа" от верхнего и нижнего края
    private func rescale() {
        guard scaleSwitch.isOn else {
            collectionView.reloadData()
            return
        }
        
        let visibleIndexes = collectionView.indexPathsForVisibleItems.compactMap({ $0.row })
        
        if visibleIndexes.count > 0 {
            var visibleData = [CandleModel]()
            for index in visibleIndexes {
                if index < dataSource.count {
                    visibleData.append(dataSource[index])
                }
            }
            
            let maxValue: CGFloat = visibleData.compactMap({ $0.highPrice }).max() ?? lastPrice + Constant.deltaDiapason
            let minValue: CGFloat = visibleData.compactMap({ $0.lowPrice }).min() ?? lastPrice - Constant.deltaDiapason
            
            if visibleIndexes.contains(dataSource.count) {
                maxVisibleValue = [maxValue, lastPrice].max()!
                minVisiblevalue = [minValue, lastPrice].min()!
            } else {
                maxVisibleValue = maxValue
                minVisiblevalue = minValue
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        rescale()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            rescale()
        }
    }
    
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == dataSource.count {
            return createRealtimeCandleCell(indexPath)
            
        }
        
        return createCandleCell(indexPath)
    }
    
    private func createRealtimeCandleCell(_ indexPath: IndexPath) -> CandleCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CandleCell.self), for: indexPath) as! CandleCell

        if let openPrice = firstPrice {
            let bodyHeight = calculateHeight(startPrice: openPrice, endPrice: lastPrice + 1)
            let yBody = calculateYPosition(startPrice: openPrice, endPrice: lastPrice)

            cell.setBodyFrame(height: bodyHeight, y: yBody)
            cell.setTrand(lastPrice - (firstPrice ?? lastPrice) >= 0 ? .bullish : .bearish)
        }

        return cell
    }
    
    private func createCandleCell(_ indexPath: IndexPath) -> CandleCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CandleCell.self), for: indexPath) as! CandleCell
        let candle = dataSource[indexPath.row]
        
        let bodyHeight = calculateHeight(startPrice: candle.openPrice, endPrice: candle.closePrice)
        let yBody = calculateYPosition(startPrice: candle.openPrice, endPrice: candle.closePrice)
        cell.setBodyFrame(height: bodyHeight, y: yBody)
        
        let shadowHeight = calculateHeight(startPrice: candle.lowPrice, endPrice: candle.highPrice)
        let yShadow = calculateYPosition(startPrice: candle.lowPrice, endPrice: candle.highPrice)
        
        cell.setShadowFrame(height: shadowHeight, y: yShadow)
        
        cell.setTrand(candle.trand)
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CandleCell.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
