//
//  DFCaptureController.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 7/5/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import ImageIO
import AVFoundation


class DFCaptureController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    // Session management
    var captureSession: AVCaptureSession?;
    var captureDevice : AVCaptureDevice?;
    var videoDeviceInput: AVCaptureDeviceInput?;
    var movieFileOutput: AVCaptureMovieFileOutput?;
    
    var previewLayer: AVCaptureVideoPreviewLayer?;
    
    // Utils
    var backgroundRecordingID:UIBackgroundTaskIdentifier?;
    var deviceAuthorized:Bool = false;
    var sessionRunningAndDeviceAuthorized:Bool = false;
    var lockInterfaceRotation:Bool = false;
    // TODO: add runtimeErrorHandlingObserver
    
    
    func isSessionRunningAndDeviceAuthorised() -> Bool{
        if(self.captureSession != nil){
            return (self.captureSession!.running && self.deviceAuthorized);
        }
        return false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var configError:NSError?;
        
        self.captureSession = AVCaptureSession();
        
        // set up preview view
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession);
        
        // setup capture device
        if let videoDevice:AVCaptureDevice = DFCaptureController.getDeviceWithMediaTypeAndPosition(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back){
            let videoDeviceInput:AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error:&configError) as AVCaptureDeviceInput;
            if(configError != nil){
                println("Could not obtain video Device input \(configError)");
                return;
            }
            if(self.captureSession!.canAddInput(videoDeviceInput)){
                self.captureSession!.addInput(videoDeviceInput);
                self.videoDeviceInput = videoDeviceInput;
                
                self.previewLayer!.connection.videoOrientation = self.getCaptureOrientation();
                
            }else{
                
            }
        }else{
            println("Could not obtain specified device");
        }
        
    }
    
    // Helper functions
    
    func getCaptureOrientation() -> AVCaptureVideoOrientation {
        let uiOrientation = self.interfaceOrientation;
        switch uiOrientation {
        case UIInterfaceOrientation.LandscapeLeft:
            return AVCaptureVideoOrientation.LandscapeLeft;
        case UIInterfaceOrientation.LandscapeRight:
            return AVCaptureVideoOrientation.LandscapeRight;
        case UIInterfaceOrientation.Portrait:
            return AVCaptureVideoOrientation.Portrait;
        case UIInterfaceOrientation.PortraitUpsideDown:
            return AVCaptureVideoOrientation.PortraitUpsideDown;
        }
    
    }
    
    class func getDeviceWithMediaTypeAndPosition(mediaType:String, position:AVCaptureDevicePosition) -> AVCaptureDevice?{
        let devices:[AnyObject] = AVCaptureDevice.devicesWithMediaType(mediaType);
        var cDevice:AVCaptureDevice?;
        for device in devices{
            let captureDevice = device as AVCaptureDevice;
            if(captureDevice.position == position){
                cDevice = captureDevice;
                break;
            }
        }
        return cDevice;
    }
    
    func checkDeviceGrantStatus(){
        let mediaType:String = AVMediaTypeVideo;        
        AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted:Bool) -> Void in
            if(granted){
                self.deviceAuthorized = true;
            }else{
                self.deviceAuthorized = false;
                println("Device NOT Authorized");
            }
        })
    }
    
    
}