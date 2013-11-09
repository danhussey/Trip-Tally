//
//  DriveDetailsSingleton.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 4/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriveDetailsSingleton : NSObject

@property (strong, nonatomic) NSString *driver, *supervisor, *car, *odometer;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (strong, nonatomic) NSDictionary *driveCompletionBinaryDetails;

+ (DriveDetailsSingleton*)sharedInstance;

@end
