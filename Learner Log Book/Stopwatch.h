//
//  Stopwatch.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 2/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stopwatch : NSObject

{
    bool running;
    NSTimeInterval startTime;
}

@property (nonatomic) int timeElapsed;

@end
