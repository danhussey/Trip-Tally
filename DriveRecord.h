//
//  DriveRecord.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DriveDetailContainer.h"


@interface DriveRecord : NSManagedObject

@property (nonatomic, strong) DriveDetailContainer *driveDetailContainer;


@end

@interface DriveDetailTransformer : NSValueTransformer

@end
