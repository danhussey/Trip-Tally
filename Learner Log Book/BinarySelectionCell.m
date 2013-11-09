//
//  BinarySelectionCell.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 6/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  Create an image that will be used at the background (Tick and cross)
//  The dynamic part of the cell will lay on top of this image

#import "BinarySelectionCell.h"

@interface BinarySelectionCell ()

@property (strong, nonatomic) NSMutableArray *arrayOfAllThingsIDraw;

@end

@implementation BinarySelectionCell

- (void) setupCell
{
    self.binaryPosition = NO; //All cells begin in the NO position
    self.dynamicCellTitle = @"Unset";
    self.dynamicView = [[UIView alloc] initWithFrame:CGRectMake(60, 0, 260, self.bounds.size.height)];
    self.dynamicView.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:self.dynamicView];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    CGRect tickPosition = CGRectMake(0, 0, 260, self.bounds.size.height);
    CGRect crossPosition = CGRectMake(60, 0, 260, self.bounds.size.height);
    
    if (!self.binaryPosition && recognizer.direction == UISwipeGestureRecognizerDirectionLeft) { //Flip to tick
        [UIView animateWithDuration:0.12 animations:^{self.dynamicView.frame = tickPosition;}];
        self.binaryPosition = !self.binaryPosition;
    }
    else if (self.binaryPosition && recognizer.direction == UISwipeGestureRecognizerDirectionRight) { //Flip to cross
        [UIView animateWithDuration:0.12 animations:^{self.dynamicView.frame = crossPosition;}];
        self.binaryPosition = !self.binaryPosition;
    }
}

@end
