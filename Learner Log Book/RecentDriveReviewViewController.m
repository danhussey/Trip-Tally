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
        DriveRecord *driveRecord = [[DriveRecord alloc] initWithEntity:[NSEntityDescription entityForName:@"DriveRecord" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        
        driveRecord.driveDetailContainer = self.driveDetailContainer;
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
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
    
    NSString *string = [NSString stringWithFormat:@"%@", self.driveDetailContainer.description];
    self.detailsTextBox.text = string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
