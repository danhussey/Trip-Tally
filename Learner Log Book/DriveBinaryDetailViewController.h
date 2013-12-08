//
//  DriveBinaryDetailViewController.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 8/12/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriveRecordDeveloper.h"

@interface DriveBinaryDetailViewController : UITableViewController <DriveRecordDeveloper>

@property (strong, nonatomic) DriveDetailContainer* driveDetailContainer;

@end
