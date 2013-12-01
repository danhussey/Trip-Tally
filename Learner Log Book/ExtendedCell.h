//
//  ExtendedCell.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  Ideally this will be separated into two sub classes in future, one
//  that is more robust and acts more as a template, and one that is
//  extended into the driveviewcontrollerextendedcell type

#import <UIKit/UIKit.h>
#import "DriveViewController.h"
#import <CoreData/CoreData.h>
#import <CoreGraphics/CGGeometry.h>
#import "DriveInSessionViewController.h"

@interface ExtendedCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) NSString *cellType;
@property (nonatomic) CGPoint cellPosition;
@property (strong, nonatomic) NSMutableArray *cellData;
@property (strong, nonatomic) UITextField *detailField;

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
- (void) handleTapFrom:(UISwipeGestureRecognizer *)recognizer;
- (void) setCellPositionToDefault;
- (void) updateCellContents;
- (void) setupLabelTapRecognizer;
- (BOOL) isInCustomDetailPosition;
- (BOOL) cellIsReadyForSegue;

@end
