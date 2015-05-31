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
    
    //TODO: move away from using constants here
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0);
    var imageCollection = Array<UIImage>();
    let reuseIdentifier = "DFCollection";
    var collectionView:UICollectionView?;
    
    override func loadView() {
        super.loadView();
        
        // Configure base view
        let baseView:UIView = UIView(frame: UIScreen.mainScreen().bounds);
        baseView.backgroundColor = UIColor(white: 1.0, alpha: 1.0);
        self.view = baseView;
        // flow layout initialization
        let flowLayout = UICollectionViewFlowLayout();
        // collection view initialization
        let collectionViewFrame:CGRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
        self.collectionView = UICollectionView(frame:self.view.frame, collectionViewLayout: flowLayout);
        self.collectionView!.dataSource = self;
        self.collectionView!.delegate = self;
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier);
        self.collectionView!.backgroundColor = UIColor.whiteColor();
        self.view.addSubview(self.collectionView!);

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    //MARK: Flow Layout protocol implementation
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 30, height: 30);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return self.sectionInsets;
    }
    
    
    // MARK: override dataSource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20;
        //return self.imageCollection.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
        return cell;
    }
    
    
}