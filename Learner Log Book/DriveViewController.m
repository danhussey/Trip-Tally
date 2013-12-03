//
//  DriveViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  Cells return to their initial positions when scrolled out of view.
//
//  Add cell deleting
//  Remove the scrolling element
//  Means implement autoLayout
//  All view controllers in the driverecord generating sequence MUST have their driverecord set by the view before it. What happens if it's not? Shitstorm. ShitPHOON!

#import "DriveViewController.h"

@interface DriveViewController ()

{
    NSArray *tableData;
}

@end

@implementation DriveViewController

- (void) setInitialDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Check it doesn't exist first
    if (![defaults objectForKey:@"Car"]) { //Is it safe just checking one?
        [defaults setObject:@0 forKey:@"Car"];
        [defaults setObject:@0 forKey:@"Driver"];
        [defaults setObject:@0 forKey:@"Supervisor"];
        [defaults setObject:@0 forKey:@"Odometer"];
        [defaults setObject:@0 forKey:@"Drive"];
        if (![defaults synchronize]) NSLog(@"Synchronise error in initial default setting");
    }
}

- (IBAction)setDefaultsButton:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i<2;i++) { //Cycle through !!first three!! cells and set defaults as their current positions
        DriveDetailCell *cell = (DriveDetailCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        
        NSLog(@"Cell %@ default is now %i after setting it.", cell.cellType, [defaults integerForKey:cell.cellType]);
    }
    
    if (![defaults synchronize]) NSLog(@"Synchronise error in initial default setting");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //Setup custon cell XIBs
    UINib *nib = [UINib nibWithNibName:@"DriveDetailCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DriveDetailCell"];
    
    tableData = [NSMutableArray arrayWithObjects:@"Car", @"Driver", @"Supervisor", @"Odometer", @"Drive", nil];
    
    [self setInitialDefaults]; //Set the initial default positions
    
    //Add gesture recognizer to the tableView
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:gestureR];
    
    UISwipeGestureRecognizer *gestureL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:gestureL];
    
    UITapGestureRecognizer *gestureT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [gestureT setNumberOfTapsRequired:1];
    [self.tableView addGestureRecognizer:gestureT];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {//The drive cell
        NSString *driveCellIdentifier = @"DriveCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:driveCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Drive";
        return cell;
    }
    static NSString *CellIdentifier = @"DriveDetailCell";
    DriveDetailCell *cell = (DriveDetailCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == Nil) {
        cell = [[DriveDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    cell.cellType = [tableData objectAtIndex:indexPath.row];
    cell.tableView = self.tableView;
    if ([cell.cellType isEqualToString:@"Odometer"]) cell.detailField.text = cell.cellType;
    return cell;
}

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    //Find cell the swipe happened on
    UITableView *tableView = [self tableView];
    CGPoint location = [recognizer locationInView:self.view];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    DriveDetailCell *swipedCell  = (DriveDetailCell*)[tableView cellForRowAtIndexPath:swipedIndexPath];
    
    if ([swipedCell respondsToSelector:@selector(handleSwipeFromTableViewRecognizer:)]) {
        NSLog(@"Responds to swipe selector");
        [swipedCell handleSwipeFromTableViewRecognizer:recognizer];
    }
}

- (void) handleTapFrom:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"Tableview Tapped");
    //Find cell the tap happened on
    UITableView *tableView = [self tableView];
    CGPoint location = [recognizer locationInView:self.view];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    UITableViewCell *tappedCell  = [tableView cellForRowAtIndexPath:swipedIndexPath];
    
    //This is some terrible programming.
    if ([tappedCell.textLabel.text isEqualToString:@"Drive"]) //If it's the drive button
    {
        if ([self cellsAreReadyForSegue]) {
            for (int i = 0; i < 4; i++) {
                DriveDetailCell *cell = (DriveDetailCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                [self synchroniseDataToManagedObjectFromCell:cell];
            }
            [self performSegueWithIdentifier:@"toDriveInSessionSegue" sender:tappedCell];
        }
    }
}

- (BOOL) cellsAreReadyForSegue {
    BOOL readyForDrive = YES;
    
    for (int i = 0; i < 4; i++) {
        DriveDetailCell *cell = (DriveDetailCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (![cell isReadyForSegue]) readyForDrive = NO;
    }
    if (readyForDrive) return YES;
    return NO;
}

- (void) synchroniseDataToManagedObjectFromCell:(DriveDetailCell *)cell
{
    if ([cell isInCustomDetailPosition]) {
        if ([cell.cellType isEqualToString:@"Car"]) self.driveRecord.driveDetailContainer.car = cell.detailField.text;
        else if ([cell.cellType isEqualToString:@"Driver"]) self.driveRecord.driveDetailContainer.driver = cell.detailField.text;
        else if ([cell.cellType isEqualToString:@"Supervisor"]) self.driveRecord.driveDetailContainer.supervisor = cell.detailField.text;
        else if ([cell.cellType isEqualToString:@"Odometer"]) self.driveRecord.driveDetailContainer.odometerStart = [NSNumber numberWithInt:[cell.textLabel.text intValue]];
        NSError *error = nil;
        [[self managedObjectContext] save:&error];
        if (error) NSLog(@"error: %@", error.localizedDescription);
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"toDriveInSessionSegue"]) {
        UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
        nextViewController.driveRecord = self.driveRecord;
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
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(DriveDetailCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == DriveDetailCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == DriveDetailCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
