//
//  BinarySelectionCell.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 6/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BinarySelectionCell : UITableViewCell

- (void) snapToBinaryPosition:(BOOL)binaryPosition;

@property (nonatomic) BOOL binaryPosition;
@property (strong, nonatomic) UITableViewCell *dynamicView;
@property (nonatomic) BOOL isFinishedCell;

@end
