//
//  BinarySelectionCell.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 6/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BinarySelectionCell : UITableViewCell

- (void) setupCell;
- (void) handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer;

@property (nonatomic) BOOL binaryPosition;
@property (strong, nonatomic) UITableViewCell *dynamicInnerCell;
@property (strong, nonatomic) NSString *dynamicCellTitle;
@property (strong, nonatomic) UIView *dynamicView;

@end
