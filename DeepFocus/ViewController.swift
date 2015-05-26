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

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    // MARK: private members
    var imageView = UIImageView()
    var cameraPicker = UIImagePickerController();
    var captureSession = AVCaptureSession();
    
    // Optional to store the capture device if present
    var captureDevice : AVCaptureDevice?;
    var previewLayer: AVCaptureVideoPreviewLayer?;
    
    // variables to store captured media
    var stillImageOutput:AVCaptureStillImageOutput?;
    var stillImage:UIImage?;
    
    
    
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

    
    // MARK: Outlets and Actions
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
            return;
        }
    }
    
    func beginSession(){
        self.configureDevice()
        var error:NSError? = nil;
        // set the quality of the capture
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        // set the input of the session
        self.captureSession.addInput(AVCaptureDeviceInput(device:self.captureDevice, error:&error))
        if error != nil {
            println("error: \(error?.localizedDescription)")
        }
        
        // set the output of the session
        self.stillImageOutput = AVCaptureStillImageOutput()
        let settings = NSDictionary(objectsAndKeys: AVVideoCodecJPEG,AVVideoCodecKey);
        self.stillImageOutput?.outputSettings = settings;
        self.captureSession.addOutput(self.stillImageOutput);
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession);
        self.view.layer.addSublayer(self.previewLayer);
        self.previewLayer?.frame = self.view.layer.frame;
        initOverlayControlsForCamera();
        
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
        self.view.addSubview(overlayView);
        self.view.addSubview(toolBar);
    }
    
    // MARK : Capture Device Actions and Controls
    func configureDevice() {
        if let device = self.captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func focusTo(value: Float){
        if let device = self.captureDevice {
            if(device.lockForConfiguration(nil)){
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                })
                device.unlockForConfiguration();
            }
        }
    }

    
    func shootPicture(){
        if(self.stillImageOutput == nil){
            NSLog("Still Image output is not initialized");
        }
        // Use direct swift provided API to get the video connection
        if let videoConnection = self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection,
                completionHandler: { (imageSampleBuffer:CMSampleBuffer!, error:NSError!) -> Void in
                    if(error != nil){
                        println("error: \(error?.localizedDescription)")
                        return;
                    }
                    // TODO: What are exifAttachements ???
                    let exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, nil);
                    if (exifAttachments != nil) {
                        println("attachements: \(exifAttachments)");
                    } else {
                        println("no attachments");
                    }
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer);
                    self.imageView.image = UIImage(data: imageData);
                    self.adjustHeight()
                    
            });
        }else{
            NSLog("Could not create video Connection for AVMediaTypeVideo");
        }
    }
    
    
    func cancelPicture(){
        self.captureSession.stopRunning()
    }
    
    
    // Touches which control the focus ( _temporary functions_ )
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        let anyTouch = touches.anyObject() as UITouch;
        let touchPercentage = anyTouch.locationInView(self.view).x / screenWidth;
        self.focusTo(Float(touchPercentage));
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        touchesBegan(touches, withEvent: event);
    }
    

}

extension UIImage{
    var aspectRatio: CGFloat{
        return ((size.height != 0) ? (size.width / size.height) : 0);
    }
}

