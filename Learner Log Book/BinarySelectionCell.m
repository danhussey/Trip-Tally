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

{
    CGRect tickPosition;
    CGRect crossPosition;
}
@property (strong, nonatomic) NSMutableArray *arrayOfAllThingsIDraw;

@end

@implementation BinarySelectionCell

- (void) setBinaryPosition:(BOOL)binaryPosition
{
    _binaryPosition = binaryPosition;
    if (binaryPosition == YES) {
        [UIView animateWithDuration:0.12 animations:^{self.dynamicView.frame = tickPosition;}];
    }
    else if (binaryPosition == NO){
        [UIView animateWithDuration:0.12 animations:^{self.dynamicView.frame = crossPosition;}];
    }
    
}

- (void) snapToBinaryPosition:(BOOL)binaryPosition
{
    _binaryPosition = binaryPosition;
    if (binaryPosition) {
        self.dynamicView.frame = tickPosition;
    }
    else {
        self.dynamicView.frame = crossPosition;
    }
    
}

- (void) setIsFinishedCell:(BOOL)isFinishedCell
{
    _isFinishedCell = isFinishedCell;
    if (_isFinishedCell) {
        //Setup the cell for it's special position.
        self.dynamicView.textLabel.text = @"Finished";
        //NOTE: Change the icon on the right to something else to signify the finishedness of the wipe (To the next screen)
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        tickPosition = CGRectMake(60, 0, 260, self.bounds.size.height);
        crossPosition = CGRectMake(0, 0, 260, self.bounds.size.height);
        
        self.dynamicView.textLabel.text = @"Unset";
        self.dynamicView = [[UITableViewCell alloc] initWithFrame:CGRectMake(60, 0, 260, self.bounds.size.height)];
        self.dynamicView.backgroundColor = [UIColor blueColor];
        self.dynamicView.frame = crossPosition;
        self.binaryPosition = NO; //All cells begin in the NO position
        [self.contentView addSubview:self.dynamicView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
