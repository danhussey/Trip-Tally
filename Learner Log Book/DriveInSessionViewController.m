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

@interface DriveInSessionViewController ()
{
    //Timer stuff
    NSTimeInterval startTime;
    NSTimeInterval elapsedTimeCache;
    NSTimeInterval elapsedTime;
    bool running;
    bool readyToRecordLocation; //Bool that allows the adding of a location to the locationsarray, set to true when the heading change is updated
}

@end

@implementation DriveInSessionViewController

- (CLLocationManager*) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.pausesLocationUpdatesAutomatically = NO; //Look into this
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //Check this, could cause issues later for accuracy
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.headingFilter = 25; //Degrees
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
    DriveDetailsSingleton *singleton = [DriveDetailsSingleton sharedInstance];
    singleton.distanceTravelled = [self distanceTravelledFromLocations:self.recordedLocationsArray];
    singleton.endDate = [NSDate date];
}

- (CLLocationDistance)distanceTravelledFromLocations:(NSMutableArray*)locations
{
    CLLocationDistance totalDistance = 0;
    if (locations) {
        for (int i=0; i < (locations.count-1); i++) {
            totalDistance += ([locations[i] distanceFromLocation:locations[i+1]]);
        }
    }
    else if (!locations) {
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
    DriveDetailsSingleton *singleton = [DriveDetailsSingleton sharedInstance];
    singleton.startDate = [NSDate date];
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorized:
        {
            if ([CLLocationManager headingAvailable] && [CLLocationManager locationServicesEnabled]) { //NOTE: Do further checks later and handle non-enabled events (Authorizationstatus checks and stuff)
                [self.locationManager startUpdatingLocation];
                [self.locationManager startUpdatingHeading];
            }
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            //Well shit. Maybe like do odometer calculations if they want?
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                           message:@"Can't calculate distance travelled - Location Services Disabled"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Okay", nil];
            [alert show];
        }
            
        default:
            break;
    }
    
	// Do any additional setup after loading the view.
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
        int hours = (int) (elapsedTime/(60*60));
        elapsedTime -= (hours*60*60);
        int minutes = (int) (elapsedTime/60);
        elapsedTime -= (minutes*60);
        int seconds = (int) elapsedTime;
        
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

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    readyToRecordLocation = true;
    //Could possibly implement optimization here where location isn't updated unless this value is true
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (readyToRecordLocation == true) {
        for (id element in locations) {
            CLLocation *location;
            if ([element isKindOfClass:[CLLocation class]]) location = element;
            NSDate *currentTime = [NSDate date];
            NSTimeInterval locationThreshhold = (60*5); //60 seconds (a minutes) times 30
            if ([currentTime timeIntervalSinceDate:location.timestamp] <= locationThreshhold) {
                [self.recordedLocationsArray addObjectsFromArray:locations];
                //For each element in the locations array, if it's a location assign it to the location variable, and if its timestamp is less than 5 minutes old, add the location to the recorded locations array property
            }
        }
        readyToRecordLocation = NO; //Reset the corner-turned flag
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

@end
