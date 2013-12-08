//
//  DriveInSessionViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 2/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  LoationServices - Check the heading for turns. Every time the heading changes a certain degree threshhold, the location is documented.
//  Then, maps or just simple distance calculations are used to measure distance travelled.

#import "DriveInSessionViewController.h"

#define kDistanceCalculationInterval 10 // the interval (seconds) at which we calculate the user's distance
#define kNumLocationHistoriesToKeep 5 // the number of locations to store in history so that we can look back at them and determine which is most accurate
#define kValidLocationHistoryDeltaInterval 3 // the maximum valid age in seconds of a location stored in the location history
#define kMinLocationsNeededToUpdateDistance 3 // the number of locations needed in history before we will even update the current distance
#define kRequiredHorizontalAccuracy 30.0f // the required accuracy in meters for a location.  anything above this number will be discarded


@interface DriveInSessionViewController ()
{
    //Timer stuff
    NSTimeInterval startTime;
    NSTimeInterval elapsedTimeCache;
    NSTimeInterval elapsedTime;
    bool running; 
    int hours, minutes, seconds;
}

@end

@implementation DriveInSessionViewController

- (NSMutableArray*) recordedLocationsArray {
    if (!_recordedLocationsArray) {
        _recordedLocationsArray = [[NSMutableArray alloc] init];
    }
    return _recordedLocationsArray;
}

- (CLLocationManager*) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.pausesLocationUpdatesAutomatically = NO; //Look into this
        _locationManager.distanceFilter = 5; //metres
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (IBAction)doDrivingStatusButton:(id)sender
{
    if (running) {
        [self pauseTimer];
        [self.driveStatusButton setTitle:@"Paused" forState:UIControlStateNormal];
        self.driveStatusButton.backgroundColor = [UIColor grayColor];
    }
    else {
        [self startTimer];
        [self.driveStatusButton setTitle:@"Driving" forState:UIControlStateNormal];
        self.driveStatusButton.backgroundColor = [UIColor greenColor];
    }
}

- (IBAction)doFinishedButton:(UIButton *)sender {
    self.driveDetailContainer.distanceTravelled = [self distanceTravelledFromLocations:self.recordedLocationsArray];
    int distanceInKilometres = self.driveDetailContainer.distanceTravelled/1000;
    self.driveDetailContainer.odometerFinish = [NSNumber numberWithInt:[self.driveDetailContainer.odometerStart intValue] + distanceInKilometres];
    self.driveDetailContainer.endDate = [NSDate date];
    //self.driveDetailContainer.elapsedTime = [self.driveDetailContainer.endDate timeIntervalSinceDate:self.driveDetailContainer.startDate];
    self.driveDetailContainer.elapsedTime = [NSString stringWithFormat:@"%i h %i m", hours, minutes];
    NSLog(@"Locations: %@", self.locationManager.location);
}

- (CLLocationDistance)distanceTravelledFromLocations:(NSMutableArray*)locations
{
    CLLocationDistance totalDistance;
    totalDistance = 0;
    if (locations.count > 0) {
        for (int i=0; i < (locations.count-1); i++) {
            totalDistance += ([locations[i] distanceFromLocation:locations[i+1]]);
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Locations Recorded"
                                                        message:@"Can't calculate distance travelled - No Locations Have Been Recorded Yet"
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles: nil];
        [alert show];
        NSLog(@"Locations array = nil");
    }
    return totalDistance;
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
    self.driveStatusButton.backgroundColor = [UIColor greenColor];
    [self setupTimer];
    [self startTimer]; //View only loads once... right?
    self.driveDetailContainer.startDate = [NSDate date];
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorized:
        {
            if ([CLLocationManager locationServicesEnabled]) { //NOTE: Do further checks later and handle non-enabled events (Authorizationstatus checks and stuff)
                self.locationHistory = [NSMutableArray arrayWithCapacity:kNumLocationHistoriesToKeep];
                [self.locationManager startUpdatingLocation];
            }
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            //Well shit. Maybe like do odometer calculations if they want?
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                            message:@"Can't Calculate Distance Travelled - Location Services Disabled"
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles: nil];
            [alert show];
        }
            
        default:
            NSLog(@"ERROR: Location authorization status is %i", [CLLocationManager authorizationStatus]);
            break;
    }
    
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusAuthorized:
        {
            if ([CLLocationManager locationServicesEnabled]) { //NOTE: Do further checks later and handle non-enabled events (Authorizationstatus checks and stuff)
                self.locationHistory = [NSMutableArray arrayWithCapacity:kNumLocationHistoriesToKeep];
                [self.locationManager startUpdatingLocation];
            }
        }
            break;
            case kCLAuthorizationStatusDenied:
        {
            //Well shit. Maybe like do odometer calculations if they want?
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                            message:@"Can't Calculate Distance Travelled - Location Services Disabled"
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles: nil];
            [alert show];
        }
            
        default:
            NSLog(@"ERROR: Location authorization status is %i", [CLLocationManager authorizationStatus]);
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTimer {
    self.timerLabel.text = @"00 : 00 : 00";
    running = false;
    elapsedTimeCache = 0;
}

- (void) startTimer {
    running = true;
    startTime = [NSDate timeIntervalSinceReferenceDate];
    [self updateTimer];
}

- (void) updateTimer {
    if (!running) return;
    
    else if (running) {
        //Calculate elapsed time
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        elapsedTime = (currentTime - startTime) + elapsedTimeCache;
        
        //Extract time in form of hours minutes and seconds from elapsed time
        hours = (int) (elapsedTime/(60*60));
        elapsedTime -= (hours*60*60);
        minutes = (int) (elapsedTime/60);
        elapsedTime -= (minutes*60);
        seconds = (int) elapsedTime;
        
        //Creates strings that have zeroes in them for numbers like 01
        NSString *hoursSection;
        if (hours < 10) hoursSection = [NSString stringWithFormat:@"0%i", hours];
        else if (hours < 100) hoursSection = [NSString stringWithFormat:@"%i", hours];
        else hoursSection = @"99";
        
        NSString *minutesSection;
        if (minutes < 10) minutesSection = [NSString stringWithFormat:@"0%i", minutes];
        else if (minutes < 100) minutesSection = [NSString stringWithFormat:@"%i", minutes];
        else minutesSection = @"99";
        
        NSString *secondsSection;
        if (seconds < 10) secondsSection = [NSString stringWithFormat:@"0%i", seconds];
        else if (seconds < 100) secondsSection = [NSString stringWithFormat:@"%i", seconds];
        else secondsSection = @"99";
        
        self.timerLabel.text = [NSString stringWithFormat:@"%@ : %@ : %@", hoursSection, minutesSection, secondsSection];
        
        [self performSelector:@selector(updateTimer) withObject:self afterDelay:0.1];
    }
}

- (void) pauseTimer { //Improve to also pause locations later on
    elapsedTimeCache = elapsedTime; //Gets the elapsed time of that session of ticking to be added back to elapsed time next start
    running = false;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
        for (id element in locations) {
            CLLocation *location;
            if ([element isKindOfClass:[CLLocation class]]) location = element;
			
            if (([location.timestamp compare:self.driveDetailContainer.startDate] == NSOrderedDescending || [location.timestamp compare:self.driveDetailContainer.startDate] == NSOrderedSame) && location.horizontalAccuracy < kRequiredHorizontalAccuracy) {
                [self.recordedLocationsArray addObject:location];
                //For each element in the locations array, if it's a location assign it to the location variable, and if its timestamp is less than 5 minutes old, add the location to the recorded locations array property
                NSLog(@"%@", location.description);
            }
        }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString: @"toDriveCompletedSegue"]) {
        if (self.recordedLocationsArray.count > 0) {
            return YES;
        }
        else return NO;
    }
    else return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"toDriveCompletedSegue"]) {
        UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
        nextViewController.driveDetailContainer = self.driveDetailContainer;
    }
}

@end
