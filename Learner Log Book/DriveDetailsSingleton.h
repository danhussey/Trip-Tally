//
//  DriveDetailsSingleton.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 4/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DriveDetailsSingleton : NSObject

@property (strong, nonatomic) NSString *driver, *supervisor, *car, *odometer;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) CLLocationDistance distanceTravelled;
@property (strong, nonatomic) NSDictionary *driveCompletionBinaryDetails;
@property (strong, nonatomic) NSDate *startDate, *endDate;

+ (DriveDetailsSingleton*)sharedInstance;

@end
