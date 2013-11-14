//
//  DriveInSessionViewController.h
//  Learner Log Book
//
//  Created by Daniel Hussey on 2/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ExtendedCell.h"
#import "DriveRecord.h"
#import "DriveRecordDeveloper.h"

@interface DriveInSessionViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate, DriveRecordDeveloper>

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIButton *driveStatusButton;
@property (strong, nonatomic) IBOutlet UIButton *finishedButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *recordedLocationsArray;

@property (strong, nonatomic) DriveRecord *driveRecord;

@end
