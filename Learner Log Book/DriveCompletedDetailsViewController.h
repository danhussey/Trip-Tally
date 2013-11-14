//
//  DriveCompletedDetailsViewController.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 6/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BinarySelectionCell.h"
#import "DriveDetailContainer.h"
#import "RecentDriveReviewViewController.h"
#import "DriveRecordDeveloper.h"

@interface DriveCompletedDetailsViewController : UITableViewController <DriveRecordDeveloper>

@property (strong, nonatomic) NSMutableDictionary *criteriaDictionary;
@property (strong, nonatomic) DriveRecord *driveRecord;

@end
