//
//  DriveRecordDeveloper.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 15/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriveRecord.h"

@protocol DriveRecordDeveloper <NSObject>

@property (strong, nonatomic) DriveRecord* driveRecord;

@end
