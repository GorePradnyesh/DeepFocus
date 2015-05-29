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
    var autoLayoutDictionary:Dictionary<String, UIView> = Dictionary()
    
    // MARK: UIViewController overrides
    
    override func loadView() {
        self.configureLayout();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

    }
    
    override func viewDidLoad() {
        super.viewDidLoad();

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: configure the layout
    func configureLayout(){
        // Configure base view
        let baseView:UIView = UIView(frame: UIScreen.mainScreen().bounds);
        baseView.backgroundColor = UIColor(white: 1.0, alpha: 1.0);
        self.view = baseView;
        
        // Configure the imageContainer properties
        let imageViewContainerName = "imageViewContainer";
        let parentBounds = self.view.bounds;
        let yOffset:Int = 10;

        //self.imageViewContainer = UIView(frame: CGRect(x:parentBounds.origin.x, y:(parentBounds.origin.y + 10), width:parentBounds.width - 10, height:(parentBounds.height - 10)));
        self.imageViewContainer = UIView();
        self.imageViewContainer?.setTranslatesAutoresizingMaskIntoConstraints(false);
        self.imageViewContainer?.backgroundColor = UIColor.redColor();

        // Add to the dictionary
        self.autoLayoutDictionary[imageViewContainerName] = self.imageViewContainer;
        self.view.addSubview(self.imageViewContainer!);
        
        // Configure autoLayout
        //TODO: find a way to use string constants
        let baseWidth = 100;
        let baseHeight = 100;
        let view1_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:[\(imageViewContainerName)(>=\(baseWidth))]", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary);
        let view1_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(imageViewContainerName)(>=\(baseHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary);
        self.view.addConstraints(view1_constraint_H)
        self.view.addConstraints(view1_constraint_V)
        
        let imageContainerHContraint:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[\(imageViewContainerName)]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary)
        let imageContainerVContraint:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[\(imageViewContainerName)]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: self.autoLayoutDictionary)
        self.view.addConstraints(imageContainerHContraint);
        self.view.addConstraints(imageContainerVContraint);

        /*
        let topEdgeConstraint = NSLayoutConstraint(item: self.imageViewContainer!,
                                                    attribute: .CenterY,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .CenterY,
                                                    multiplier: 1.0,
                                                    constant: 0.0);
        let centerXConstraint = NSLayoutConstraint(item: self.imageViewContainer!,
                                                    attribute: .CenterX,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .CenterX,
                                                    multiplier: 1.0,
                                                    constant: 0.0);
        self.view.addConstraint(topEdgeConstraint);
        self.view.addConstraint(centerXConstraint);
        */
        
    }
}

