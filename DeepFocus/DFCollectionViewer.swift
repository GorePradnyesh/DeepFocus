//
//  DFCollectionViewer.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/29/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import Foundation
import UIKit

class DFCollectionViewer: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    // TODO: move away from using constants here
    var sectionInsets:UIEdgeInsets?

    // The collection that holds the thumbnails to display
    var imageCollection = Array<UIImage>();
    let reuseIdentifier = "DFCollection";
    var collectionView:UICollectionView?;
    var autoLayoutDictionary:Dictionary<String, UIView> = Dictionary()

    var defaultMaxThumbHeight = 100;
    var defaultMaxThumbWidth = 100;
    
    override func loadView() {
        super.loadView();
        
        // Configure base view
        let baseView:UIView = UIView(frame: UIScreen.mainScreen().bounds);
        baseView.backgroundColor = UIColor(white: 1.0, alpha: 1.0);
        self.view = baseView;
        
        // flow layout initialization
        let flowLayout = UICollectionViewFlowLayout();
        // collection view initialization
        let collectionViewName = "collectionView";
        self.collectionView = UICollectionView(frame:self.view.frame, collectionViewLayout: flowLayout);
        self.collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false);
        self.autoLayoutDictionary[collectionViewName] = self.collectionView!;
        // TODO: Move the data source to a location outside the class
        self.collectionView!.dataSource = self;
        self.collectionView!.delegate = self;
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier);
        self.collectionView!.backgroundColor = UIColor.whiteColor();
        // Add the collectionView as a subview of the view
        self.view.addSubview(self.collectionView!);

        // Add auto layout constraints to collection view.
        let baseWidth = 100;
        let baseHeight = 100;
        let view1_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:[\(collectionViewName)(>=\(baseWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary);
        let view1_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(collectionViewName)(>=\(baseHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary);
        self.view.addConstraints(view1_constraint_H)
        self.view.addConstraints(view1_constraint_V)
        let collectionViewContainerHContraint:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[\(collectionViewName)]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary)
        let collectionViewContainerVContraint:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[\(collectionViewName)]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary)
        self.view.addConstraints(collectionViewContainerHContraint);
        self.view.addConstraints(collectionViewContainerVContraint);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    // MARK: Flow Layout protocol implementation
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var thumbnail = self.imageCollection[indexPath.row];
        return self.getThumbnailBounds(thumbnail);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if(self.sectionInsets == nil){
            // Use relative values
            let vInset:CGFloat = 20.0;
            let hInset:CGFloat = 10.0;
            self.sectionInsets = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset);
        }
        return self.sectionInsets!;
    }
    
    
    // MARK: DataSource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // TODO: Consider subclassing UICollectioViewCell. Might make for better cleanup of images etc.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
        let imageView = UIImageView(frame: cell.contentView.frame)  ;
        imageView.contentMode = .ScaleAspectFill;
        imageView.image = self.imageCollection[indexPath.row];
        cell.contentView.addSubview(imageView)
        return cell;
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(self.collectionView != collectionView){
            println("Unknown collection view was selected");
            return;
        }
        var imageToDisplay:UIImage = self.imageCollection[indexPath.row]
        let dfPresenter = DFPresenter();
        dfPresenter.imageView.image = imageToDisplay;
        self.presentViewController(dfPresenter, animated: true) { () -> Void in
        }
    }
    
    
    // MARK: private helper methods 
    private func getThumbnailBounds(let image:UIImage) -> CGSize {
        var localWidth = 5;     // non zero values for error detection
        var localHeight = 5;    // non zero values for error detection
        var aspectRatio = image.aspectRatio;
        if(aspectRatio > 1){  // width > height
            localWidth = self.defaultMaxThumbWidth;
            localHeight = Int(CGFloat(localWidth) / aspectRatio);
        }else{
            localHeight = self.defaultMaxThumbHeight;
            localWidth = Int(CGFloat(localHeight) * aspectRatio);
        }
        return CGSize(width:localWidth, height:localHeight);
    }
    
}