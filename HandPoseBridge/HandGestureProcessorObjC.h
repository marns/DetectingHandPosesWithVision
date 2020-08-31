//
//  HandGestureProcessorObjC.h
//  HandPose
//
//  Created by Martin Smith on 8/30/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#ifndef HandGestureProcessorObjC_h
#define HandGestureProcessorObjC_h

struct PointC {
    double x, y;
};

struct PointsPairC {
    struct PointC thumb, index;
};

struct PointC EmptyPointC(void);
struct PointsPairC EmptyPointsPairC(void);

bool IsEmptyPoint(struct PointC point);
bool IsEmptyPair(struct PointsPairC pair);

#endif /* HandGestureProcessorObjC_h */
