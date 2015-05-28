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

    // MARK: View overrides
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    // MARK: Outlets and Actions
    @IBOutlet weak var capture: UIButton!
    
    @IBAction func takePhoto(sender: AnyObject) {
        //self.initOverlayControlsForCamera();
    }
}

