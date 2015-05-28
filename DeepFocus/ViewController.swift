//
//  ViewController.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/24/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO
import AVFoundation

class ViewController: UIViewController{
    
    let captureController = CaptureController()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // MARK: Prepare Capture Button
        let captureButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        captureButton.setTitle("Capture", forState: .Normal)
        captureButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(captureButton);
        let topEdgeConstraint = NSLayoutConstraint(item: captureButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0.0);
        let centerXConstraint = NSLayoutConstraint(item: captureButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0.0);
        self.view.addConstraint(topEdgeConstraint);
        self.view.addConstraint(centerXConstraint);
        // Add Action to capture button
        captureButton.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)

    }
    
    func takePhoto(sender:UIButton!){
        presentViewController(self.captureController, animated: true, completion: nil);
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

