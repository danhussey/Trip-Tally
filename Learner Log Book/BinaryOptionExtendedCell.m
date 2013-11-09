//
//  BinaryOptionExtendedCell.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 6/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "BinaryOptionExtendedCell.h"

@interface BinaryOptionExtendedCell ()

@property (strong, nonatomic) NSMutableArray *arrayOfAllThingsIDraw;

@end

@implementation BinaryOptionExtendedCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.binaryPosition = NO; //All cells begin in the NO position
        self.dynamicCellTitle = @"Unset";
        
        //Put all the things the cell will draw into this array
        
    }
    return self;
}

- (void) setDynamicCellTitle:(NSString *)dynamicCellTitle {
    _dynamicCellTitle = dynamicCellTitle;
    self.dynamicInnerCell.textLabel.text = dynamicCellTitle;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void) drawRect:(CGRect)rect {
    id thing;
    NSEnumerator *thingEnumerator = [[self arrayOfAllThingsIDraw] objectEnumerator];
    while (thing = [thingEnumerator nextObject]) {
        if ([self needsToDrawRect:[thing bounds]]) {
            [self drawThing:thing];
        }
    }
}

- (void) setupDrawnObjectArray
{
    NSEnumerator
}


@end
