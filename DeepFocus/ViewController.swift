//
//  ViewController.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/24/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        if(self.imageView.image != nil){
            self.adjustHeight()
        }
    }

    // MARK: private members
    var imageView = UIImageView()
    var cameraPicker = UIImagePickerController();

    
    // MARK: Outlts and Actions
    @IBOutlet weak var capture: UIButton!

    @IBOutlet weak var imageViewContainer: UIView!{
        didSet{
            imageViewContainer.addSubview(imageView);
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        self.cameraPicker.delegate = self;
        if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
            self.cameraPicker.sourceType = .Camera
        }
        self.cameraPicker.mediaTypes = [kUTTypeImage];
        self.cameraPicker.allowsEditing = true;
        presentViewController(self.cameraPicker, animated:true, completion:nil);
    }
    
    // MARK: private functions 
    func updateUI(){
        var urlString:NSString = "http://globe-views.com/dcim/dreams/car/car-03.jpg";
        var URL = NSURL(string:urlString);
        let qos = Int(QOS_CLASS_USER_INITIATED.value);
        dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
            if let imageData = NSData(contentsOfURL: URL!){
                if let image = UIImage(data: imageData){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = image;
                        self.adjustHeight()
                    });
                }
            }
        });
    }
    
    func adjustHeight(){
        if(self.imageView.image?.aspectRatio > 0){
            if let width = self.imageView.superview?.frame.size.width {
                let height = width / self.imageView.image!.aspectRatio
                self.imageView.frame = CGRect(x:0, y:0, width:width, height:height);
            }
        }else{
            self.imageView.frame = CGRectZero;
        }
    } // end of adjust width
    
    
    // MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage;
        if(image == nil){
            image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        }
        self.imageView.image = image;
        adjustHeight();
        dismissViewControllerAnimated(true, completion: nil);
    }
    

}

extension UIImage{
    var aspectRatio: CGFloat{
        return ((size.height != 0) ? (size.width / size.height) : 0);
    }
}

