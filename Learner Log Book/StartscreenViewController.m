//
//  StartscreenViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "StartscreenViewController.h"

@interface StartscreenViewController ()

{
    id unfinishedObjectToBeDeleted; //Deletes a managedobject with this id, which is disabled
}

@end

@implementation StartscreenViewController

- (void) defuseManagedObjectDeleter
{
    unfinishedObjectToBeDeleted = nil;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    if (unfinishedObjectToBeDeleted) {
        [[self managedObjectContext] deleteObject:unfinishedObjectToBeDeleted];
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
        NSManagedObjectContext *context = [self managedObjectContext];
        DriveRecord *newDriveRecord = (DriveRecord*)[NSEntityDescription insertNewObjectForEntityForName:@"DriveRecord" inManagedObjectContext:context];
        DriveDetailContainer *newContainer = [[DriveDetailContainer alloc] init];
        newDriveRecord.driveDetailContainer = newContainer;
        UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
        nextViewController.driveRecord = newDriveRecord;
        
        unfinishedObjectToBeDeleted = newDriveRecord;
    }
}

@end
