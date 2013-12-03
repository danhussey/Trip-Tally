//
//  DriveDetailCell.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "DriveRecordDeveloper.h"

@interface DriveDetailCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *detailField;
@property (strong, nonatomic, readonly) NSMutableArray *cellData;
@property (strong, nonatomic) NSString *cellType;
@property (weak, nonatomic) UITableView* tableView;

- (void) handleSwipeFromTableViewRecognizer: (UISwipeGestureRecognizer*) gestureRecognizer;
- (BOOL) isReadyForSegue;
- (BOOL) isInCustomDetailPosition;
- (NSManagedObject*) currentObjectBeingDisplayed;
- (void) updateCellText;


@end

@interface WrappingCellPositionFactory : NSObject

@property int cellPosition;
@property int cellDataArrayCount;

- (void) incrementCellPosition;
- (void) decrementCellPosition;

@end