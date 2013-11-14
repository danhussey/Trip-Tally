//
//  DriveViewController.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ExtendedCell.h"
#import "DriveRecordDeveloper.h"

@interface DriveViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, DriveRecordDeveloper>

@property (strong, nonatomic) DriveRecord *driveRecord;

@end
