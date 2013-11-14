//
//  RecentDriveReviewViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 13/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  NOTE: This MVC become just standard drive review screen.
//  NOTE: Later on, change the singleton to just use a CoreData instance of DriveRecord, and only save at the end, and delete it from the buffer if it gets cancelled (so it doesn't get saved) and also check it hadn't already been saved

#import "RecentDriveReviewViewController.h"

@interface RecentDriveReviewViewController ()


@end

@implementation RecentDriveReviewViewController

- (IBAction)topRightNavButton:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"Save"]) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.navigationController.viewControllers[0] performSelector:@selector(defuseManagedObjectDeleter)];
        //Add metres to the odometer (Futile, I know, but I might as well)
        //NOTE: Update when the singleton has been changed to an instance of DriveRecord
        
    }

    else if ([sender.title isEqualToString:@"Done"]) { //Came from review, so return to review
        //[self performSegueWithIdentifier:@"returnToDriveReviewSegue" sender:self];
        [self.navigationController popViewControllerAnimated:YES];
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

- (DriveDetailContainer*) driveDetails
{
    if (!_driveDetails) {
        _driveDetails = self.driveRecord.driveDetailContainer;
    }
    return _driveDetails;
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
    
    else if ([self.topRightNavButton.title isEqualToString:@"Done"]) {
        self.topRightNavButton.style = UIBarButtonItemStylePlain;
        self.topRightNavButton.enabled = false;
        self.topRightNavButton.title = nil;
    }
    
    NSString *string = [NSString stringWithFormat:@"Date and time: %@\nDriving Time: %f\n Odometer Start: %i \nOdometer Finish: %f\n And all this stuff: %@", self.driveRecord.driveDetailContainer.startDate.description, self.driveDetails.elapsedTime, self.driveRecord.driveDetailContainer.odometer.intValue, (self.driveRecord.driveDetailContainer.odometer.intValue + self.driveRecord.driveDetailContainer.distanceTravelled), self.driveRecord.driveDetailContainer.driveCompletionBinaryDetails.description];
    self.detailsTextBox.text = string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
