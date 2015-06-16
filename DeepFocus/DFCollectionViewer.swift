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
    var sortedFocusList = Array<Float>();
    var dfSequence:Dictionary<Float, UIImage>?{
        willSet(newValue){
            if(newValue == nil){
                return;
            }
            self.sortedFocusList = Array(newValue!.keys).sorted(<)
        }
    };
    let reuseIdentifier = "DFCollection";
    var collectionView:UICollectionView?;
    var autoLayoutDictionary:Dictionary<String, UIView> = Dictionary();

    var defaultMaxThumbHeight = 150;
    var defaultMaxThumbWidth = 150;
    
    // MARK: UIViewController overrides 
    
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
        
        // Add Export button to UINavigationBar
        let exportButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: nil);
        self.navigationItem.rightBarButtonItem = exportButton;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }
    
    // MARK: Flow Layout protocol implementation
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var focusValue = self.sortedFocusList[indexPath.row];
        var thumbnail = self.getImageForFocus(focusValue)
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
        return self.sortedFocusList.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // TODO: Consider subclassing UICollectioViewCell. Might make for better cleanup of images etc.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
        let imageView = UIImageView(frame: cell.contentView.frame)  ;
        imageView.contentMode = .ScaleAspectFill;
        imageView.image = self.getImageForFocus(self.sortedFocusList[indexPath.row]);
        cell.contentView.addSubview(imageView)
        return cell;
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO: turn off touches when the view is not active.
        if(self.collectionView != collectionView){
            println("Unknown collection view was selected");
            return;
        }
        var imageToDisplay:UIImage = self.getImageForFocus(self.sortedFocusList[indexPath.row]);
        let dfPresenter = DFPresenter();
        dfPresenter.imageView.image = imageToDisplay;
        self.navigationController?.pushViewController(dfPresenter, animated: true);
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
    
    private func getImageForFocus(focusValue:Float) -> UIImage{
        var thumbnail = self.dfSequence?[focusValue];
        if(thumbnail == nil){
            println("Error could not find thumbnail for focus \(focusValue)");
            var errorImage = UIImage(named: "errorImage")
            return errorImage!;
        }
        return thumbnail!;
    }
    
}