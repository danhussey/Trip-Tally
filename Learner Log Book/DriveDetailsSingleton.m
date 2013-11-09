//
//  DriveDetailsSingleton.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 4/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

//  Get the drive table view to send this singleton the data
//  specified in the extendedCells every time drive is pressed
//  (would also work for editing the drive while timer is running
//
//  Get the finished screen to retrieve this info when it needs it.

#import "DriveDetailsSingleton.h"

@implementation DriveDetailsSingleton

- (id)init
{
    self = [super init];
    if (self) {
        self.driver = @"unset";
        self.supervisor = @"unset";
        self.odometer = @"unset";
        self.car = @"unset";
        self.elapsedTime = 0;
    }
    return self;
}

+ (DriveDetailsSingleton*) sharedInstance
{
    static DriveDetailsSingleton *driveDetailsSingletonInstance = nil;
    @synchronized(self) {
        if (driveDetailsSingletonInstance == nil)
            driveDetailsSingletonInstance = [[DriveDetailsSingleton alloc] init];
    }
    return driveDetailsSingletonInstance;
}

@end
