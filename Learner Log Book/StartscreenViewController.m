//
//  StartscreenViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  Settings ideas: change what is displayed int the review table view for the drive titles

#import "StartscreenViewController.h"

@interface StartscreenViewController ()

{
    id unfinishedObjectToBeDeleted; //Deletes a managedobject with this id, which is disabled
}

@end

@implementation StartscreenViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    if (unfinishedObjectToBeDeleted) {
    }
}

//Gets the managedObjectContext from the app delegate
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"toDriveScreenSegue"]) {
        DriveDetailContainer *newContainer = [[DriveDetailContainer alloc] init];
        UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
        nextViewController.driveDetailContainer = newContainer;
    }
}

@end
