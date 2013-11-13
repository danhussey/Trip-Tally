//
//  DriveDetailContainer.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 13/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DriveDetailsSingleton.h"

@interface DriveDetailContainer : NSObject <NSCoding>

@property (strong, nonatomic) NSString *driver, *supervisor, *car, *odometer;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) CLLocationDistance distanceTravelled;
@property (strong, nonatomic) NSDictionary *driveCompletionBinaryDetails;
@property (strong, nonatomic) NSDate *startDate, *endDate;

-(void) detailsFromSingleton: (DriveDetailsSingleton*) singleton;
+(DriveDetailContainer*) containerFromSingleton: (DriveDetailsSingleton*) singleton;

@end
