//
//  DFCollectionViewDataSource.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/29/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import Foundation
import UIKit

class DFCollectionViewDataSournce: NSObject, UICollectionViewDataSource{
    var imageCollection = Array<UIImage>();
    let reuseIdentifier = "DFCollection";  
    
    
    // MARK: protocol implementation
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        return cell;
    }
}