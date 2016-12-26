//
//  ViewController.swift
//  CollectionAnimationDemo
//
//  Created by Andrew on 16/7/20.
//  Copyright © 2016年 Andrew. All rights reserved.
//

import UIKit

let screen_width = UIScreen.main().bounds.width
let screen_height = UIScreen.main().bounds.height
let CELLID = "cellId"


func getRandomColor() -> UIColor {
    let red = CGFloat(arc4random_uniform(255))
    let green = CGFloat( arc4random_uniform(255))
    let blue = CGFloat( arc4random_uniform(255))
    let color = UIColor(red: red / 255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    
    return color
}

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate{
    
    var collectionView:UICollectionView!
    
    var itemCounts:NSMutableArray = NSMutableArray()
    
    var smallLayout:FlowLayoutWithAnimation!
    var largeLayout:FlowLayoutWithAnimation!
    var pincher:UIPinchGestureRecognizer!
    
    
    var sectionCount:Int = 3
    var largeItems:Bool = false
    var selectedItem:Int?
    
    var sectionLb:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white()
        self.title = "CollectionView动画"
        
  
        
        itemCounts = [13,16,20]
        
        initCollectionView()
        
       

        
        pincher = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        self.collectionView.addGestureRecognizer(pincher)
        
        initView()
    }
    
    
    func initView() -> Void {
        let insetItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertItem))
        let deleteItem1 = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItem))
        let toggleSizeItem1 = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(toggleItemSize))
        
        self.navigationItem.rightBarButtonItems = [insetItem,deleteItem1,toggleSizeItem1]
        
    }
    
    //MARK: - 手势操作
    func handlePinch(gesture:UIPinchGestureRecognizer) -> Void {
        //只支持两个手指操作
        if gesture.numberOfTouches() != 2
        {
          return
        }
        if gesture.state == .began || gesture.state == .changed{
          //get the pinch points
            let p1 = gesture.location(ofTouch: 0, in: self.collectionView)
            let p2 = gesture.location(ofTouch: 1, in: self.collectionView)
            
            //计算距离
            let xd = p1.x - p2.x
            let yd = p1.y - p2.y
            let distance = sqrt(xd*xd + yd*yd)
            
            //更新collectionView的布局
            let flowLayout = (self.collectionView.collectionViewLayout) as! FlowLayoutWithAnimation
            
            
            let pinchedItem = collectionView.indexPathForItem(at: CGPoint(x: 0.5*(p1.x+p2.x), y: 0.5*(p1.y+p2.y)))
            
            if(pinchedItem != nil){
                
                flowLayout.resizeItemAtIndexPath(indexPath: pinchedItem!, distance: distance)
                flowLayout.invalidateLayout()
            }
            
        }else if gesture.state == .cancelled || gesture.state == .ended{
            let flowLayout = (self.collectionView.collectionViewLayout) as! FlowLayoutWithAnimation
            collectionView.performBatchUpdates({
                flowLayout.resetPinchedItem()
                }, completion: nil)
        }
    }
    
    func initCollectionView() -> Void {
        
        let smallwidth:CGFloat = (screen_width-5)/6
        let largeWidth:CGFloat = (screen_width-2)/2
        
        
        largeLayout = FlowLayoutWithAnimation()
        largeLayout.minimumLineSpacing = 2
        largeLayout.minimumInteritemSpacing = 2
        largeLayout.itemSize  = CGSize(width: largeWidth, height: largeWidth)
        largeLayout.headerReferenceSize = CGSize(width: screen_width, height: 30)

        
        smallLayout = FlowLayoutWithAnimation()
        smallLayout.minimumInteritemSpacing = 1
        smallLayout.minimumLineSpacing = 1
        smallLayout.itemSize = CGSize(width: smallwidth, height: smallwidth)
        smallLayout.headerReferenceSize = CGSize(width: screen_width, height: 30)
        
        let rect = CGRect(x: 0, y: 0, width: screen_width, height: screen_height)
        collectionView = UICollectionView(frame: rect, collectionViewLayout: smallLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white()
        
        self.view.addSubview(collectionView)
        
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CELLID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "head")
    }
    
    
    //MARK: - UICOllectionview delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCounts[section] as! Int
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        var cell:UICollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: CELLID, for: indexPath)
        if(cell == nil){
          cell = CollectionCell()
        }
        
        cell?.backgroundColor = getRandomColor()
        return cell!
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 10, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view:UICollectionReusableView? = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "head", for: indexPath)
        
        if(view == nil){
           view = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: screen_width, height: 20))
        }
        
        if(sectionLb != nil){
             sectionLb.removeFromSuperview()
            sectionLb = nil
        }
        view?.backgroundColor = UIColor.red()
        sectionLb = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 20))
        sectionLb.text = "section\(indexPath.section)"
        view?.addSubview(sectionLb)
        return view!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        
        let detail = DetailController()
        detail.layout =  collectionView.collectionViewLayout
        detail.itemCount = itemCounts[indexPath.section] as! Int
        selectedItem = indexPath.item
        
        self.navigationController?.pushViewController(detail, animated: true)
        

    }
    
    
    //MARK: - 按钮操作
    func insertItem() -> Void {
        
        let randomSection = arc4random_uniform(UInt32(sectionCount))
        let item = (itemCounts[Int(randomSection)] as! Int)+1
        itemCounts[Int(randomSection)] = item
        
        let indexPath = NSIndexPath(item: Int(arc4random_uniform(UInt32(item))), section: Int(randomSection))
        collectionView.insertItems(at: [indexPath as IndexPath])
        
    }
    func deleteItem() -> Void {
        let randomSection = arc4random_uniform(UInt32(sectionCount))
        let item = (itemCounts[Int(randomSection)] as? Int)
        
        if(item != nil){
            itemCounts[Int(randomSection)] = item! - 1
            let indexPath = NSIndexPath(item: Int(arc4random_uniform(UInt32(item!))), section: Int(randomSection))
         collectionView.deleteItems(at: [indexPath as IndexPath])
        }else{
         var totalItems = 0
            for item in itemCounts {
                totalItems += item as! Int
            }
            
            self.deleteItem()
        }
    }
    func toggleItemSize() -> Void {
        if largeItems == true{
            largeItems = false
            self.collectionView.setCollectionViewLayout(smallLayout, animated: true)
        }else{
            self.collectionView.setCollectionViewLayout(largeLayout, animated: true)
            largeItems = true
        }
    }

    
    //MARK: - UINavigationController delegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    
  


}

