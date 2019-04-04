/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class TopicLayout: UICollectionViewLayout {

    let topicWidth: CGFloat = 130
    let heightToWidthRatio: CGFloat = 0.8
    var cellPadding: CGFloat = 6
    let maxCols = 4
    
    func xOffsets(for cols: Int, ofSize width: CGFloat) -> [CGFloat] {
        return (0 ..< cols).map { width * CGFloat($0) }
    }
    
    func yOffsets(for rows: Int, ofSize height: CGFloat) -> [CGFloat] {
        return (0 ..< rows).map { height * CGFloat($0) }
    }
    
    func cellHeight(relativeTo width: CGFloat, ratio: CGFloat = 1.0, padding: CGFloat = 0.0) -> CGFloat {
        let photoHeight = width*CGFloat(ratio)
        return padding * 2 + photoHeight
    }
    
    var columnWidth: CGFloat {
        get {
            return contentWidth / CGFloat(numberOfColumns)
        }
    }
    
    var numberOfColumns: Int {
        get {
            return min(Int(floor(contentWidth / (topicWidth + 2*cellPadding))), maxCols)
        }
    }

    override func invalidateLayout() {
        cache = []
        super.invalidateLayout()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.width != collectionView.bounds.width
    }
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    func cacheCell(at indexPath: IndexPath, frame: CGRect){
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = frame
        cache.append(attributes)
    }

    func frameFor(xOffset: CGFloat, yOffset: CGFloat, width: CGFloat, height: CGFloat, padding: CGFloat) -> CGRect {
        let frame = CGRect(
            x: xOffset, y: yOffset,
            width: width, height: height
        )
        
        return frame.insetBy(dx: padding, dy: padding)
    }
    
    //Content height and size
    var contentHeight: CGFloat = 0

    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    func getCoords(item: Int) -> (row: Int, col: Int){
        return (item/numberOfColumns, item%numberOfColumns)
    }

    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let height = cellHeight(relativeTo: columnWidth, ratio: heightToWidthRatio, padding: cellPadding)
        
        let (maxRow, _) = getCoords(item: collectionView.numberOfItems(inSection: 0))

        let yOffset = yOffsets(for: Int(maxRow + 1), ofSize: height)
        let xOffset = xOffsets(for: numberOfColumns, ofSize: columnWidth)

        // 3. Iterates through the list of items in the first section
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let (row, col) = getCoords(item: item)
            
            let frame = frameFor(xOffset: xOffset[col], yOffset: yOffset[row], width: columnWidth, height: height, padding: cellPadding)
            
            let indexPath = IndexPath(item: item, section: 0)

            cacheCell(at: indexPath, frame: frame)

            contentHeight = max(contentHeight, frame.maxY)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

}
