//
//  DFPresentation.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/27/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import Foundation
import UIKit

class DFPresenter: UIViewController {
    var imageView = UIImageView()
    var imageViewContainer:UIView?
    
    
    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad();
        //self.addImageViewContainer();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: UIElements Addition
    func addImageViewContainer(){
        let parentBounds = self.view.bounds;
        let yOffset:Int = 10;
        self.imageViewContainer = UIView(frame: CGRect(x:parentBounds.origin.x, y:(parentBounds.origin.y + 10), width:parentBounds.width - 10, height:(parentBounds.height - 10)));
        self.imageViewContainer!.backgroundColor = UIColor.grayColor();
        self.view.addSubview(self.imageViewContainer!);
        let topEdgeConstraint = NSLayoutConstraint(item: self.imageViewContainer!,
                                                    attribute: .Top,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .Top,
                                                    multiplier: 1.0,
                                                    constant: 10.0);
        let centerXConstraint = NSLayoutConstraint(item: self.imageViewContainer!,
                                                    attribute: .CenterX,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .CenterX,
                                                    multiplier: 1.0,
                                                    constant: 0.0);
        self.view.addConstraint(topEdgeConstraint);
        self.view.addConstraint(centerXConstraint);
    }
}
