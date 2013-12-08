//
//  RecentDriveReviewViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 4/12/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "RecentDriveReviewViewController.h"

@interface RecentDriveReviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startFinishLabel;
@property (weak, nonatomic) IBOutlet UILabel *thisTripLabel;
@property (weak, nonatomic) IBOutlet UILabel *thisTripNightLabel;
@property (weak, nonatomic) IBOutlet UILabel *odometerStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *odometerFinishLabel;
@property (weak, nonatomic) IBOutlet UILabel *carLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverLabel;
@property (weak, nonatomic) IBOutlet UILabel *supervisorLabel;


@end

@implementation RecentDriveReviewViewController

- (IBAction)topRightNavButton:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"Save"]) {
        NSManagedObjectContext *context = [self managedObjectContext];
        DriveRecord *driveRecord = [[DriveRecord alloc] initWithEntity:[NSEntityDescription entityForName:@"DriveRecord" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        driveRecord.driveDetailContainer = self.driveDetailContainer;
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        //Add metres to the odometer (Futile, I know, but I might as well)
        //NOTE: Update when the singleton has been changed to an instance of DriveRecord
        
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.displaySave) {
        [self.topRightNavButton setTitle:@"Save"];
        //self.driveDetails = [DriveDetailContainer containerFromSingleton:[DriveDetailsSingleton sharedInstance]];
    }
    
    else {
        self.topRightNavButton.enabled = false;
        self.topRightNavButton.title = nil;
    }
    
    [self configureCellLabels];
}

- (void) configureCellLabels
{
    //Setting the car
    self.carLabel.text = self.driveDetailContainer.car;
    
    //Setting the driver
    self.driverLabel.text = self.driveDetailContainer.driver;
    
    //Setting the supervisor
    self.supervisorLabel.text = self.driveDetailContainer.supervisor;
    
    //Setting the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    self.dateLabel.text = [dateFormatter stringFromDate:self.driveDetailContainer.startDate];
    
    //Setting the Start - Finish time
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    [timeFormatter setLocale:[NSLocale currentLocale]];
    NSString *startTime = [NSString stringWithString:[timeFormatter stringFromDate:self.driveDetailContainer.startDate]];
    NSString *finishTime = [NSString stringWithString:[timeFormatter stringFromDate:self.driveDetailContainer.endDate]];
    NSString *startAndFinishTime = [NSString stringWithFormat:@"%@ - %@", startTime, finishTime];
    self.startFinishLabel.text = startAndFinishTime;
    
    //Setting this trips driving
    self.thisTripLabel.text = self.driveDetailContainer.elapsedTime;
    
    //Setting this trips night driving, uses same formatter as above
    
    //Idea: Night driving tie is finished date minus elapsed time. If the result is positive, all driving was night. If it's negative, night driving is elapsed time minus the result of previous subtraction. If negative value magnitude is greater than elapsed time, none of it is night driving.

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay) fromDate:self.driveDetailContainer.startDate];
    
    [comps setTimeZone:[[NSCalendar currentCalendar] timeZone]];
    [comps setDay:currentDateComponents.day];
    [comps setMonth:currentDateComponents.month];
    [comps setYear:currentDateComponents.year];
    [comps setHour:18];
    [comps setMinute:0];
    [comps setSecond:0];
    
    NSDate *nightDateThreshold = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:nightDateThreshold toDate:self.driveDetailContainer.endDate options:0];
    
    NSLog(@"%ld hours, %ld minutes, %ld seconds", (long)components.hour, (long)components.minute, (long)components.second);
    int nightHours, nightMinutes;
    if (components.hour < 0 || components.minute < 0) {
        nightHours = 0;
        nightMinutes = 0;
    }
    else {
        nightHours = components.hour;
        nightMinutes = components.second;
    }
    
    self.thisTripNightLabel.text = [NSString stringWithFormat:@"%i h %i m", nightHours, nightMinutes];
    
    //Setting odometer start
    self.odometerStartLabel.text = [self.driveDetailContainer.odometerStart stringValue];
    
    //Setting odometer finish
    self.odometerFinishLabel.text = [self.driveDetailContainer.odometerFinish stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"toDriveBinaryDetailView"]) {
        UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
        nextViewController.driveDetailContainer = self.driveDetailContainer;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
