//
//  DFExporter.swift
//  DeepFocus
//
//  Created by Pradnyesh Gore on 6/15/15.
//  Copyright (c) 2015 Pradnyesh Gore. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class DFExporter: NSObject {
    let frameDuration:CMTime = CMTimeMakeWithSeconds(1.0/5.0, 90000);
    
    var nextPTS:CMTime = kCMTimeZero;

    var assetWriter:AVAssetWriter?;
    var assetWriterInput:AVAssetWriterInput?;
    var assetName:String?;
    var formatDescription:CMFormatDescriptionRef?;
    var outputUrl:NSURL?;
    
    init(formatDescriptionRef:CMFormatDescriptionRef){
        super.init();
        self.assetName = NSUUID().UUIDString;
        NSURL(fileURLWithPath: String(format: "%@:%lld", NSTemporaryDirectory(), mach_absolute_time()));

        // Setup assetWriter here
        self.setupAssetWriter();
    }
    
    private func setupAssetWriter() -> Bool{
        var error:NSError?;
        self.assetWriter = AVAssetWriter(URL: self.outputUrl!, fileType: AVFileTypeQuickTimeMovie, error: &error);
        if(error != nil){
            //TODO: Log error
            return false;
        }
        // TODO: Explore output settings
        self.assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: nil);
        var rotationDegree:CGFloat?;
        
        switch(UIDevice.currentDevice().orientation){
            case UIDeviceOrientation.PortraitUpsideDown:
                rotationDegree = -90;
                break;
            case UIDeviceOrientation.LandscapeLeft:
                rotationDegree = 0;
                break;
            case UIDeviceOrientation.LandscapeRight:
                rotationDegree = 180;
                break;
            case UIDeviceOrientation.Portrait:
                rotationDegree = 90;
            case UIDeviceOrientation.Unknown:
                rotationDegree = 90;
            case UIDeviceOrientation.FaceDown:
                rotationDegree = 90;
            case UIDeviceOrientation.FaceUp:
                rotationDegree = 90;
            default:
                rotationDegree = 90;
        }
        //TODO: verify that the rotations radians have been obtained correctly
        var rotationRadians:CGFloat = (CGFloat(M_PI) * rotationDegree!) / 180;
        self.assetWriterInput!.transform = CGAffineTransformMakeRotation(rotationRadians);
        
        self.nextPTS = kCMTimeZero;
        self.assetWriter!.startWriting();
        self.assetWriter!.startSessionAtSourceTime(nextPTS);
        
        return true;
    }
    
    
    func writeImageBuffer(sampleBuffer:CMSampleBufferRef){
        var timingInfo:CMSampleTimingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = frameDuration;
        timingInfo.presentationTimeStamp = self.nextPTS;
        var bufferWithNewTiming:CMSampleBufferRef?;
        //let error = CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sampleBuffer, 1, &timingInfo, &bufferWithNewTiming);
        
    }
}
