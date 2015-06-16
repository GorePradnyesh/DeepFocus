//
//  CaptureController.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 5/24/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import ImageIO
import AVFoundation



class CaptureController: UIViewController {
    
    // MARK: private members
    var captureSession:AVCaptureSession?;
    
    // Optional to store the capture device if present
    var captureDevice : AVCaptureDevice?;
    var previewLayer: AVCaptureVideoPreviewLayer?;
    
    // variables to store captured media
    var stillImageOutput:AVCaptureStillImageOutput?;
    var stillImage:UIImage?;
    var dfSequence:Dictionary<Float, CMSampleBuffer> = Dictionary();
    
    let focusIncrement = 0.1;
    
    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad();
        //self.initCaptureDevice();
        //self.beginSession();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        // Hide the navigation bar on the camera overlay. Use the toolBar buttons instead
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        self.initCamera();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    // MARK: Camera controller methods
    func initCamera(){
        self.initCaptureDevice();
        self.beginSession();
    }
    
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
        // initialize the capture session
        self.captureSession = AVCaptureSession()
        var error:NSError? = nil;
        // set the quality of the capture
        self.captureSession!.sessionPreset = AVCaptureSessionPresetHigh;
        
        // set the input of the session
        self.captureSession!.addInput(AVCaptureDeviceInput(device:self.captureDevice, error:&error))
        if error != nil {
            println("error: \(error?.localizedDescription)")
        }
        
        // set the output of the session
        self.stillImageOutput = AVCaptureStillImageOutput()
        let settings = NSDictionary(objectsAndKeys: AVVideoCodecJPEG,AVVideoCodecKey);
        self.stillImageOutput?.outputSettings = settings;
        self.captureSession!.addOutput(self.stillImageOutput);
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession);
        self.view.layer.addSublayer(self.previewLayer);
        self.previewLayer?.frame = self.view.layer.frame;
        initOverlayControlsForCamera();
        
        self.captureSession!.startRunning();
        
        // re-initialize the data structures which hold captured artifacts
        self.dfSequence = Dictionary();
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    func initOverlayControlsForCamera(){
        var toolBar =   UIToolbar(frame:CGRectMake(0, self.view.frame.height-54, self.view.frame.width, 55));
        toolBar.barStyle = UIBarStyle.BlackTranslucent;
        
        let libraryPictureItem = UIBarButtonItem(barButtonSystemItem: .Bookmarks, target: self, action: "library")
        let shootPictureItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "shootPicture");
        let flexibleSpaceItem_1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil);
        let flexibleSpaceItem_2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil);
        let flexibleSpaceItem_3 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil);
        
        let items  = [/*flexibleSpaceItem_1, */flexibleSpaceItem_2, shootPictureItem, flexibleSpaceItem_3, libraryPictureItem];
        toolBar.setItems(items, animated: false);
        
        // TODO: Add Auto layout functionlity for toolbar and overlay view.
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
        if(value > 1.0){
            println("Got focus value \(value) > 1")
        }
        if let device = self.captureDevice {
            if(device.lockForConfiguration(nil)){
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                })
                device.unlockForConfiguration();
            }
        }
    }
    
    
    func shootPicture(){
        // TODO: start from 0.0
        self.captureDFSequence(0.1);
    }
    
    func captureDFSequence(focusValue:Float){
        if(stillImageOutput == nil){
            println("stillImageOutput has not been initialized");
        }
        if(focusValue >= 1.0){
            // DFCapture sequence has completed.
            println("Done capturing DFSequence. Sequence length :\(self.dfSequence.count)");
            self.showPresentationController(self.dfSequence)
        }
        else{
            if let videoConnection = self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
                self.focusTo(focusValue);
                self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection,
                    completionHandler: { (imageSampleBuffer:CMSampleBuffer!, error:NSError!) -> Void in
                        if(error != nil){
                            println("error: \(error?.localizedDescription)")
                            return;
                        }
                        // TODO: What are exifAttachements ???
                        let exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, nil);
                        /*
                        if (exifAttachments != nil) {
                            println("attachements: \(exifAttachments)");
                        } else {
                            println("no attachments");
                        }*/
                        
                        //let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer);
                        self.dfSequence[focusValue] = imageSampleBuffer;
                        let newFocus = focusValue + Float(self.focusIncrement);
                        self.captureDFSequence(newFocus);
                });
            }else{
                NSLog("Could not create video Connection for AVMediaTypeVideo");
            }
        }
    }
    
    
    // Touches which control the focus ( _temporary functions_ )
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(self.isViewLoaded() && self.view.window != nil){
            // dont process touches if view is not the current view
            let screenWidth = UIScreen.mainScreen().bounds.size.width;
            let anyTouch = touches.anyObject() as UITouch;
            let touchPercentage = anyTouch.locationInView(self.view).x / screenWidth;
            self.focusTo(Float(touchPercentage));
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        touchesBegan(touches, withEvent: event);
    }
    
    // MARK: segue
    func showPresentationController(dfSequence: Dictionary<Float, CMSampleBuffer>){
        let collectionViewer = DFCollectionViewer();
        collectionViewer.dfSequence = dfSequence;
        self.navigationController?.pushViewController(collectionViewer, animated: true){
            self.captureSession!.stopRunning();
            println("Stopped the capture session");
        }
    }
}
    

extension UINavigationController{
    func pushViewController(viewController:UIViewController, animated:Bool, completion:Void -> Void){
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated);
        CATransaction.commit();
    }
}

    
    
    
    
    
    
    
    

