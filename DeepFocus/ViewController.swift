//
//  ViewController.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/24/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import UIKit
import MobileCoreServices

import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    // MARK: private members
    var imageView = UIImageView()
    var cameraPicker = UIImagePickerController();
    var customImagePicker = UIImagePickerController();
    var captureSession = AVCaptureSession();
    
    // Optional to store the capture device if present
    var captureDevice : AVCaptureDevice?;
    var previewLayer: AVCaptureVideoPreviewLayer?;
    

    // MARK: View overrides
    override func viewDidLoad() {
        super.viewDidLoad();
        self.updateUI();
        self.initCaptureDevice();
    }
    
    override func viewDidLayoutSubviews() {
        if(self.imageView.image != nil){
            self.adjustHeight()
        }
    }

    
    // MARK: Outlts and Actions
    @IBOutlet weak var capture: UIButton!

    @IBOutlet weak var imageViewContainer: UIView!{
        didSet{
            imageViewContainer.addSubview(imageView);
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        //self.initOverlayControlsForCamera();
        self.beginSession();
    }
    
    
    // MARK: private helper functions
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
    
    
    // MARK: Camera controller methods
    
    func initCaptureDevice(){
        let devices = AVCaptureDevice.devices();
        for device in devices{
            if(device.hasMediaType(AVMediaTypeVideo)){
                if(device.position == AVCaptureDevicePosition.Back){
                    self.captureDevice = device as? AVCaptureDevice;
                }
            }
        }
        if(self.captureDevice == nil){
            NSLog("Could not find camera for device")
        }
    }
    
    func beginSession(){
        var error:NSError? = nil;
        self.captureSession.addInput(AVCaptureDeviceInput(device:self.captureDevice, error:&error))
        if error != nil {
            println("error: \(error?.localizedDescription)")
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession);
        self.view.layer.addSublayer(self.previewLayer);
        self.previewLayer?.frame = self.view.layer.frame;
        self.captureSession.startRunning();
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage;
        
        if(image == nil){
            image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        }
        self.imageView.image = image;
        adjustHeight();
        dismissViewControllerAnimated(true, completion: nil);
    }

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    func initOverlayControlsForCamera(){
        var toolBar =   UIToolbar(frame:CGRectMake(0, self.view.frame.height-54, self.view.frame.width, 55));
        toolBar.barStyle = UIBarStyle.BlackTranslucent;
        
        let cancelPictureItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelPicture");
        let shootPictureItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "shootPicture");
        let flexibleSpaceItem_1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil);
        let flexibleSpaceItem_2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil);
        let flexibleSpaceItem_3 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil);
    
        let items  = [cancelPictureItem, flexibleSpaceItem_1, shootPictureItem, flexibleSpaceItem_2, flexibleSpaceItem_3];
        toolBar.setItems(items, animated: false);
        
        let overlayView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 44));
        overlayView.opaque = false;
        overlayView.backgroundColor = UIColor.clearColor();
        
        let cameraView = UIView(frame: self.view.bounds);
        cameraView.addSubview(overlayView);
        cameraView.addSubview(toolBar);
        
        // set the delegate
        self.customImagePicker.delegate = self;
        if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
            self.customImagePicker.sourceType = .Camera
        }else{
            NSLog("Camera not found");
            return;
        }
        self.customImagePicker.mediaTypes = [kUTTypeImage];
        self.customImagePicker.allowsEditing = true;
        
        // hide the camera controls 
        self.customImagePicker.showsCameraControls = false;
        self.customImagePicker.cameraOverlayView = cameraView;
        
        presentViewController(self.customImagePicker, animated:true, completion:nil);
    }
    
    
    func shootPicture(){
        self.customImagePicker.takePicture();
    }
    
    
    func cancelPicture(){
        dismissViewControllerAnimated(true, completion: nil);
    }

}

extension UIImage{
    var aspectRatio: CGFloat{
        return ((size.height != 0) ? (size.width / size.height) : 0);
    }
}

