//
//  FlowLayoutWithAnimation.swift
//  CollectionAnimationDemo
//
//  Created by Andrew on 16/7/20.
//  Copyright © 2016年 Andrew. All rights reserved.
//

import UIKit

class FlowLayoutWithAnimation: UICollectionViewFlowLayout {
    
    var pinchedItem:NSIndexPath!
    
    var pinchedItemSize:CGSize!
    
    var indexPathsToAnimate:NSMutableArray?
    
    var previousSize:CGSize!
    
    override init() {
        super.init()
        indexPathsToAnimate = NSMutableArray()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///Returns the layout attributes for all of the cells and views in the specified rectangle
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
       let attrs =  super.layoutAttributesForElements(in: rect)
        if(self.pinchedItem != nil){
         let attr = attrs?.filter({ (element) -> Bool in
            element.indexPath == pinchedItem
         }).first
            
            attr?.size = pinchedItemSize
            attr?.zIndex = 100
            
        }
        return attrs
        
    }
    ///Returns the layout attributes for the item at the specified index path.
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.layoutAttributesForItem(at: indexPath)
        
        if(indexPath == pinchedItem){
            attr?.size = pinchedItemSize
            attr?.zIndex = 100
        }
        
        return attr
    }
    //初始化布局的时候调用的方法
    /*
     This method is called after the prepare(forCollectionViewUpdates:) method and before the finalizeCollectionViewUpdates() method for any items that are about to be inserted. Your implementation should return the layout information that describes the initial position and state of the item. The collection view uses this information as the starting point for any animations. (The end point of the animation is the item’s new location in the collection view.) If you return nil, the layout object uses the item’s final attributes for both the start and end points of the animation.
     
     The default implementation of this method returns ni
     */
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        
        if((indexPathsToAnimate?.contains(itemIndexPath)) != nil){
            
            attr?.transform = CGAffineTransform(scaleX: 0.2,y: 0.2).rotate(CGFloat(M_PI))
            attr?.center = CGPoint(x:  (self.collectionView?.bounds.midX)!, y:  (self.collectionView?.bounds.maxY)!)
            indexPathsToAnimate?.remove(itemIndexPath)
        }
        
        return attr
    }
    /*
     Tells the layout object to prepare to be installed as the layout for the collection view.
     */
    override func prepareForTransition(from oldLayout: UICollectionViewLayout) {
        super.prepareForTransition(from: oldLayout)
        self.previousSize = self.collectionView?.bounds.size
    }
    
    ///告诉上下文去更新布局
    override func prepare() {
        super.prepare()
        self.previousSize = self.collectionView?.bounds.size
    }
    //Notifies the layout object that
    //the contents of the collection view are about to change.
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        let indexArray  = NSMutableArray()
        for item in updateItems {
            switch item.updateAction {
            case .insert:
                indexArray.add(item.indexPathAfterUpdate!)
            case .delete:
                indexArray.add(item.indexPathBeforeUpdate!)
            case .move:
                indexArray.add(item.indexPathAfterUpdate!)
                 indexArray.add(item.indexPathBeforeUpdate!)
            default:
                break
            }
        }
        
        self.indexPathsToAnimate = indexArray
    }
   /*
     Performs any additional animations or clean up needed during a collection view update.
     The collection view calls this method as the last step before preceding to animate any changes into place. This method is called within the animation block used to perform all of the insertion, deletion, and move animations so you can create additional animations using this method as needed. Otherwise, you can use it to perform any last minute tasks associated with managing your layout object’s state information
     */
    override func finalizeCollectionViewUpdates() {
        
        print("\(self)finalize updates")
        super.finalizeCollectionViewUpdates()
        self.indexPathsToAnimate = nil
    }
    
    /*
     Returns the final layout information for a decoration view that is about to be removed from the collection view.
     This method is called after the prepare(forCollectionViewUpdates:) method and before the finalizeCollectionViewUpdates() method for any decoration views that are about to be deleted. Your implementation should return the layout information that describes the final position and state of the view. The collection view uses this information as the end point for any animations. (The starting point of the animation is the view’s current location.) If you return nil, the layout object uses the same attributes for both the start and end points of the animation.
     
     The default implementation of this method returns nil.
     */
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(self)initial attr for:\(itemIndexPath)")
        
        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        if((indexPathsToAnimate?.contains(itemIndexPath)) == true){
        var flyUpTransform = CATransform3DIdentity
            flyUpTransform.m34 = 1.0 / -20000
            flyUpTransform = CATransform3DTranslate(flyUpTransform, 0, 0, 19500)
            attr?.transform3D = flyUpTransform
            attr?.center = (collectionView?.center)!
            
            attr?.alpha = 0.1
            attr?.zIndex = 1
            
            indexPathsToAnimate?.remove(itemIndexPath)
        }else{
         attr?.alpha = 1
        }
        
        return attr
    }
    
    /*
     Prepares the layout object for animated changes to the view’s bounds or the insertion or deletion of items.
     The collection view calls this method before performing any animated changes to the view’s bounds or before the animated insertion or deletion of items. This method is the layout object’s opportunity to perform any calculations needed to prepare for those animated changes. Specifically, you might use this method to calculate the initial or final positions of inserted or deleted items so that you can return those values when asked for them.
     You can also use this method to perform additional animations. Any animations you create are added to the animation block used to handle the insertions, deletions, and bounds changes.
     */
    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        print("\(self)prepare animated bounds change")
        super.prepare(forAnimatedBoundsChange: oldBounds)
    }
    /*
     Cleans up after any animated changes to the view’s bounds or after the insertion or deletion of items.
     */
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        print("\(self)finalize animated bounds change")
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = self.collectionView?.bounds
        if(!__CGSizeEqualToSize((oldBounds?.size)!, newBounds.size)){
         return true
        }
        
        return false
    }
  
    
    
    //MARK: - 自定义方法
    
    func resizeItemAtIndexPath(indexPath:NSIndexPath,distance:CGFloat) -> Void {
        
        print("pinchedItem:\(indexPath.section)-\(indexPath.row)")
        self.pinchedItem = indexPath
        self.pinchedItemSize = CGSize(width: distance, height: distance)
    }
    
    func resetPinchedItem() {
        self.pinchedItem = nil
        self.pinchedItemSize = CGSize.zero
    }
    
    

    
}








