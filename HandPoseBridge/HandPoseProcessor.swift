//
//  HandPoseProcessor.swift
//  HandPoseBridge
//
//  Created by Martin Smith on 8/30/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import Vision

@objc public class PointsPair: NSObject {
    public var thumbTip: CGPoint
    public var indexTip: CGPoint
    
    public init(thumbTip: CGPoint, indexTip: CGPoint) {
        self.thumbTip = thumbTip
        self.indexTip = indexTip
    }
    
    @objc public static let zero = PointsPair(thumbTip: CGPoint.zero, indexTip: CGPoint.zero)
}

@objc public class HandPoseProcessor : NSObject {

    @objc public static let shared = HandPoseProcessor()
    
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    @objc public func detect(sampleBuffer: CVPixelBuffer) -> PointsPairC {
        
        var thumbTip: CGPoint = CGPoint.zero
        var indexTip: CGPoint = CGPoint.zero
        
        /*
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
            }
        }*/
        let handler = VNImageRequestHandler(cvPixelBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            print("DO THING")
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return PointsPairC() //.zero
            }
            // Get points for thumb and index finger.
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                return PointsPairC() //.zero
            }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return PointsPairC() //.zero
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            print("HandPoseProcessor error")
        }
        
        var thumb = PointC()
        thumb.x = thumbTip.x.native
        thumb.y = thumbTip.y.native
        
        var index = PointC()
        index.x = indexTip.x.native
        index.y = indexTip.y.native
        
        var pair = PointsPairC()
        pair.thumb = thumb
        pair.index = index
        
        return pair
        
        //return PointsPair(thumbTip: thumbTip, indexTip: indexTip)
    }
}
