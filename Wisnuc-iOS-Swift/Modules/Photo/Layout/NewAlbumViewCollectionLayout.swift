//
//  NewAlbumViewCollectionLayout.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/10.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

private let colSpace:CGFloat = 4
//列数
private let colCount:CGFloat = 2

typealias itemHeightBlock = (IndexPath?) -> CGFloat
class NewAlbumViewCollectionLayout: UICollectionViewFlowLayout {
    //单元格宽度

    var colWidth: CGFloat = 0.0
    
    var heightBlock: itemHeightBlock?
    
    override init() {
        super.init()
    }
    
    init(itemsHeightBlock block: @escaping itemHeightBlock) {
         super.init()
         heightBlock = block
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        colWidth = itemWidth
        
    }
    
    lazy var itemWidth: CGFloat = { [weak self] in
        return ((collectionView?.frame.size.width)! - (colCount + 1) * colSpace) / colCount
    }()

    override var collectionViewContentSize: CGSize{
        var longest = colsHeight[0]
        for i in 0..<colsHeight.count {
            let rolHeight = colsHeight[i]
            if longest.floatValue < rolHeight.floatValue {
                longest = rolHeight
            }
        }
        return CGSize(width: collectionView!.frame.size.width, height: CGFloat(truncating: longest))
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var shortest = colsHeight[0]
        var shortCol: Int = 0
        for i in 0..<colsHeight.count {
            let rolHeight = colsHeight[i]
            if shortest.floatValue > rolHeight.floatValue {
                shortest = rolHeight
                shortCol = i
            }
        }
        
        let x = CGFloat(shortCol + 1) * colSpace + CGFloat(shortCol) * colWidth
        let y = CGFloat(CGFloat(shortest.floatValue) + colSpace)
        //获取cell高度
        var height: CGFloat = 0
        assert(heightBlock != nil, "未实现计算高度的block ")
        if (heightBlock != nil) {
            height = heightBlock!(indexPath)
        }
        attr.frame = CGRect(x: x, y: 200, width: colWidth, height: height)
        colsHeight[shortCol] = NSNumber.init(value: shortest.floatValue + Float(colSpace) + Float(height))
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array: [UICollectionViewLayoutAttributes] = []
        let items: Int = collectionView!.numberOfItems(inSection: 0)
        for i in 0..<items {
            let attr: UICollectionViewLayoutAttributes? = layoutAttributesForItem(at: IndexPath(item: i, section: 0))
            if let anAttr = attr {
                array.append(anAttr)
            }
        }
        return array
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    

    lazy var colsHeight: [NSNumber] = {
        var array: [NSNumber] = []
        for i in 0..<Int(colCount){
            //这里可以设置初始高度
            array.append(0)
        }
        return array
    }()
}
