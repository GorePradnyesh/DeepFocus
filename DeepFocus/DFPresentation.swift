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
    var autoLayoutDictionary:Dictionary<String, UIView>?
    
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
        
        // Configure the imageContainer
        let parentBounds = self.view.bounds;
        let yOffset:Int = 10;
        self.imageViewContainer = DFImageContainerView(frame: CGRect(x:parentBounds.origin.x, y:(parentBounds.origin.y + 10), width:parentBounds.width - 10, height:(parentBounds.height - 10)));
        self.imageViewContainer?.setTranslatesAutoresizingMaskIntoConstraints(false);
        self.imageViewContainer?.backgroundColor = UIColor.redColor();
        
        
        
        self.view.addSubview(self.imageViewContainer!);
        let topEdgeConstraint = NSLayoutConstraint(item: self.imageViewContainer!,
                                                    attribute: .Top,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .Top,
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
    }
}


class DFImageContainerView: UIView {
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width:100, height:100);
    }
}