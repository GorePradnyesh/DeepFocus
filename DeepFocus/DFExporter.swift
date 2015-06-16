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
import AssetsLibrary

class DFExporter: NSObject {
    let frameDuration:CMTime = CMTimeMakeWithSeconds(1.0/5.0, 90000);
    
    var nextPTS:CMTime = kCMTimeZero;

    var assetWriter:AVAssetWriter?;
    var assetWriterInput:AVAssetWriterInput?;
    var assetName:String?;
    var formatDescription:CMFormatDescription?;
    var outputUrl:NSURL?;
    
    init(formatDescriptionRef:CMFormatDescription){
        super.init();
        self.assetName = NSUUID().UUIDString;
        self.outputUrl = NSURL(fileURLWithPath: String(format: "%@%lld.mov", NSTemporaryDirectory(), mach_absolute_time()));

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
        self.assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: nil);
        self.assetWriterInput!.expectsMediaDataInRealTime = true;
        if(self.assetWriter!.canAddInput(self.assetWriterInput)){
            self.assetWriter!.addInput(self.assetWriterInput)
        }else{
            println("Cannot add assetWriterInput to assetWriter");
        }
        var rotationDegree:CGFloat?;
        
        switch UIDevice.currentDevice().orientation
        {
            case UIDeviceOrientation.PortraitUpsideDown:
                rotationDegree = -90.0;
                break;
            case UIDeviceOrientation.LandscapeLeft:
                rotationDegree = 0.0;
                break;
            case UIDeviceOrientation.LandscapeRight:
                rotationDegree = 180.0;
                break;
            case UIDeviceOrientation.Portrait:
                fallthrough;
            case UIDeviceOrientation.Unknown:
                fallthrough;
            case UIDeviceOrientation.FaceDown:
                fallthrough;
            case UIDeviceOrientation.FaceUp:
                fallthrough;
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
    
    
    func writeImageBuffer(sampleBuffer:CMSampleBuffer)->Bool{
        var timingInfo:CMSampleTimingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = frameDuration;
        timingInfo.presentationTimeStamp = self.nextPTS;
        var bufferWithNewTiming:Unmanaged<CMSampleBuffer>?;
        let error = CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sampleBuffer, 1, &timingInfo, &bufferWithNewTiming);
        if(error > 0){
            return false;
        }
        let buf:CMSampleBuffer = bufferWithNewTiming!.takeRetainedValue();
        
        if(self.assetWriterInput!.readyForMoreMediaData){
            if(self.assetWriterInput!.appendSampleBuffer(buf)){
                self.nextPTS = CMTimeAdd(frameDuration, nextPTS);
            }else{
                NSLog("Failed to append sample buffer");
            }
        }else{
            println("AssetWriterInput not ready for more media");
        }
        return true;
    }
    
    func writeToCameraRoll(){
        
        self.assetWriterInput!.markAsFinished();
        self.assetWriter!.endSessionAtSourceTime(self.nextPTS);
        self.assetWriter!.finishWritingWithCompletionHandler { () -> Void in
            println("finished writing");
        };
        
        var error:NSError?;
        let library = ALAssetsLibrary();
        if(library.videoAtPathIsCompatibleWithSavedPhotosAlbum(self.outputUrl!)){
            println("video is compatible")
        }else{
            println("video is NOT compatible");
            return;
        }
        library.writeVideoAtPathToSavedPhotosAlbum(self.outputUrl!, completionBlock: { (assetURL:NSURL!, error:NSError!) -> Void in
            if(error != nil){
                NSLog("assets  library operation failed \(error)");
            }else{
                var err:NSError?;
                NSFileManager().removeItemAtURL(self.outputUrl!, error: &err);
                if(err != nil){
                    println("error deleting output url : \(err)");
                }
            }
        });
    }
}
