//
//  DriveDetailCell.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DriveDetailCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *detailField;
@property (strong, nonatomic, readonly) NSMutableArray *cellData;
@property (strong, nonatomic) NSString *cellType;

- (void) handleSwipeFromTableViewRecognizer: (UISwipeGestureRecognizer*) gestureRecognizer;
- (BOOL) isReadyForSegue;
- (BOOL) isInCustomDetailPosition;


@end

@interface WrappingCellPositionFactory : NSObject

@property int cellPosition;
@property int cellDataArrayCount;

- (void) incrementCellPosition;
- (void) decrementCellPosition;

@end