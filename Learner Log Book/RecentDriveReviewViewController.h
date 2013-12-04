//
//  RecentDriveReviewViewController.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 4/12/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriveDetailContainer.h"
#import <CoreData/CoreData.h>
#import "DriveRecord.h"
#import "DriveRecordDeveloper.h"

@interface RecentDriveReviewViewController : UITableViewController <DriveRecordDeveloper>

@property (strong, nonatomic) DriveDetailContainer *driveDetailContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *topRightNavButton;
@property (nonatomic) BOOL displaySave;


@end
