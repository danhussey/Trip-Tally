//
//  DriveRecord.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "DriveRecord.h"


@implementation DriveRecord

@dynamic driveDetailContainer;

@end

@implementation DriveDetailTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
        DriveDetailContainer *container = value;
        NSData *dataContainer = [NSKeyedArchiver archivedDataWithRootObject:container];
        return dataContainer;
}

// Takes an NSData, returns a DriveDetailContainer
- (id)reverseTransformedValue:(id)value {
    NSData *dataContainer = value;
    DriveDetailContainer *container = [NSKeyedUnarchiver unarchiveObjectWithData:dataContainer];
    return container;
}


@end