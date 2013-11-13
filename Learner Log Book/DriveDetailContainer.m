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
    self.odometer = [aDecoder decodeObjectForKey:@"odometer"];
    self.car = [aDecoder decodeObjectForKey:@"car"];
    self.driveCompletionBinaryDetails = [aDecoder decodeObjectForKey:@"driveCompletionBinaryDetails"];
    self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
    
    self.elapsedTime = [aDecoder decodeIntegerForKey:@"elapsedTime"];
    self.distanceTravelled = [aDecoder decodeIntegerForKey:@"distanceTravelled"];
    
    NSLog(@"fuck");
    
    return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.driver forKey:@"driver"];
    [aCoder encodeObject:self.supervisor forKey:@"supervisor"];
    [aCoder encodeObject:self.odometer forKey:@"odometer"];
    [aCoder encodeObject:self.car forKey:@"car"];
    [aCoder encodeObject:self.driveCompletionBinaryDetails forKey:@"driveCompletionBinaryDetails"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.endDate forKey:@"endDate"];
    [aCoder encodeInteger:self.elapsedTime forKey:@"elapsedTime"];
    [aCoder encodeInteger:self.distanceTravelled forKey:@"distanceTravelled"];
    
    NSLog(@"shit");
    
}

- (void) detailsFromSingleton:(DriveDetailsSingleton *)singleton
{
    self.elapsedTime = singleton.elapsedTime;
    self.driver = singleton.driver;
    self.supervisor = singleton.supervisor;
    self.odometer = singleton.odometer;
    self.car = singleton.car;
    self.distanceTravelled = singleton.distanceTravelled;
    self.driveCompletionBinaryDetails = singleton.driveCompletionBinaryDetails;
    self.startDate = singleton.startDate;
    self.endDate = singleton.endDate;
}

+ (DriveDetailContainer*) containerFromSingleton:(DriveDetailsSingleton *)singleton
{
    DriveDetailContainer *newContainer = [[DriveDetailContainer alloc] init];
    newContainer.elapsedTime = singleton.elapsedTime;
    newContainer.driver = singleton.driver;
    newContainer.supervisor = singleton.supervisor;
    newContainer.odometer = singleton.odometer;
    newContainer.car = singleton.car;
    newContainer.distanceTravelled = singleton.distanceTravelled;
    newContainer.driveCompletionBinaryDetails = singleton.driveCompletionBinaryDetails;
    newContainer.startDate = singleton.startDate;
    newContainer.endDate = singleton.endDate;
    return newContainer;
}


@end
