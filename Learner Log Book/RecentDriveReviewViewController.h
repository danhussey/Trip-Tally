//
//  RecentDriveReviewViewController.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 13/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriveDetailContainer.h"
#import <CoreData/CoreData.h>
#import "DriveRecord.h"
#import "DriveRecordDeveloper.h"

@interface RecentDriveReviewViewController : UIViewController <DriveRecordDeveloper>

@property (weak, nonatomic) IBOutlet UILabel *detailsTextBox;
@property (nonatomic, strong) DriveDetailContainer* driveDetails;
@property (nonatomic, strong) DriveRecord *driveRecord;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *topRightNavButton;
@property (nonatomic) BOOL displaySave;


@end
