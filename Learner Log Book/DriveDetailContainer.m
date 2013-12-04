//
//  DriveDetailContainer.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 13/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "DriveDetailContainer.h"

@implementation DriveDetailContainer

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.driver = [aDecoder decodeObjectForKey:@"driver"];
    self.supervisor = [aDecoder decodeObjectForKey:@"supervisor"];
    self.odometerStart = [aDecoder decodeObjectForKey:@"odometerStart"];
    self.odometerFinish = [aDecoder decodeObjectForKey:@"odometerFinish"];
    self.car = [aDecoder decodeObjectForKey:@"car"];
    self.driveCompletionBinaryDetails = [aDecoder decodeObjectForKey:@"driveCompletionBinaryDetails"];
    self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
    
    self.elapsedTime = [aDecoder decodeObjectForKey:@"elapsedTime"];
    self.distanceTravelled = [aDecoder decodeIntegerForKey:@"distanceTravelled"];
    
    return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.driver forKey:@"driver"];
    [aCoder encodeObject:self.supervisor forKey:@"supervisor"];
    [aCoder encodeObject:self.odometerStart forKey:@"odometerStart"];
    [aCoder encodeObject:self.odometerFinish forKey:@"odometerFinish"];
    [aCoder encodeObject:self.car forKey:@"car"];
    [aCoder encodeObject:self.driveCompletionBinaryDetails forKey:@"driveCompletionBinaryDetails"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.endDate forKey:@"endDate"];
    [aCoder encodeObject:self.elapsedTime forKey:@"elapsedTime"];
    [aCoder encodeInteger:self.distanceTravelled forKey:@"distanceTravelled"];
}


@end
