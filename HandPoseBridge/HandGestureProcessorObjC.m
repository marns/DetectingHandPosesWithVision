//
//  HandGestureProcessorObjC.m
//  HandPoseBridge
//
//  Created by Martin Smith on 8/30/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HandPoseBridge/HandPoseBridge-Swift.h>
#import <ARKit/ARKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UnityXRNativePtrs.h"
#import "HandGestureProcessorObjC.h"

struct PointC EmptyPointC(void) {
    struct PointC empty;
    empty.x = 0;
    empty.y = 0;
    return empty;
}
struct PointsPairC EmptyPointsPairC(void) {
    struct PointsPairC empty;
    empty.index = EmptyPointC();
    empty.thumb = EmptyPointC();
    return empty;
}

bool IsEmptyPoint(struct PointC point) {
    return point.x == 0 && point.y == 0;
}

bool IsEmptyPair(struct PointsPairC pair) {
    return IsEmptyPoint(pair.index) && IsEmptyPoint(pair.thumb);
}

void doProcess() {
    
    printf("doProcess\n");
    [[HandGestureProcessor shared] reset];
}

struct PointsPairC detect(intptr_t *ptr) {
    
    if (!ptr) {
        return EmptyPointsPairC();
    }
    
    printf("Detect...\n");
    UnityXRNativeFrame_1* unityXRFrame = (UnityXRNativeFrame_1*) ptr;
    ARFrame* frame = (__bridge ARFrame*)unityXRFrame->framePtr;
    
    CVPixelBufferRef buffer = frame.capturedImage;
    
    // Forward message to the swift api
    printf("To swift... ");
    struct PointsPairC pair = [[HandPoseProcessor shared] detectWithSampleBuffer: buffer];
    printf("Got (%f, %f)\n", pair.index.x, pair.index.y);
    return pair;
}
