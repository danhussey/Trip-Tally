//
//  DetailViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 28/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "CarDetailViewController.h"

@interface CarDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *brandText;

@property (weak, nonatomic) IBOutlet UITextField *numberPlateText;

@end

@implementation CarDetailViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)save:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newCar = [NSEntityDescription insertNewObjectForEntityForName:@"Car" inManagedObjectContext:context];
    [newCar setValue:self.brandText.text forKey:@"brand"];
    [newCar setValue:self.numberPlateText.text forKey:@"numberPlate"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
