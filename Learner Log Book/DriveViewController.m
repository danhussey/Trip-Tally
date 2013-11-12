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
        ExtendedCell *cell = (ExtendedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.cellPosition.x != cell.cellData.count-1 && cell.cellPosition.y == 0.0) {
        [defaults setObject:[NSNumber numberWithInt:cell.cellPosition.x] forKey:cell.cellType];
        }
        
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

- (ExtendedCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ExtendedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Sets the properties as the cells are made
    //cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.cellType = [tableData objectAtIndex:indexPath.row];
    [cell setCellPositionToDefault];
    [cell updateCellContents];
    [cell setupLabelTapRecognizer];
    //NSLog(@"Cell %@ is in position %i after setting default.", cell.cellType, cell.cellPosition.x);
    
    return cell;
}

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    //Find cell the swipe happened on
    UITableView *tableView = [self tableView];
    CGPoint location = [recognizer locationInView:self.view];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    ExtendedCell *swipedCell  = (ExtendedCell*)[tableView cellForRowAtIndexPath:swipedIndexPath];
    
    [swipedCell handleSwipeFrom:recognizer];
}

- (void) handleTapFrom:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"Tableview Tapped");
    [self becomeFirstResponder];
    //Find cell the tap happened on
    UITableView *tableView = [self tableView];
    CGPoint location = [recognizer locationInView:self.view];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    ExtendedCell *tappedCell  = (ExtendedCell*)[tableView cellForRowAtIndexPath:swipedIndexPath];
    
    //This is some terrible programming.
    if ([tappedCell.cellType isEqualToString:@"Drive"]) //If it's the drive button
    {
        DriveDetailsSingleton *singleton = [DriveDetailsSingleton sharedInstance];
        BOOL readyForDrive = YES;
        
        for (int i = 0; i < 4; i++) {
            ExtendedCell *cell = (ExtendedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (!cell.cellIsReadyForSegue) readyForDrive = NO;
        }
        
        if (readyForDrive) {
            for (int i = 0; i < 4; i++) {
                ExtendedCell *cell = (ExtendedCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                [self synchroniseDataFromCell:cell toSingleton:singleton];
            }
            [self performSegueWithIdentifier:@"pushToDriveSession" sender:tappedCell];
        }
    }
    
    else [tappedCell handleTapFrom:recognizer];
}

- (void) synchroniseDataFromCell:(ExtendedCell *)cell toSingleton:(DriveDetailsSingleton*)singleton
{
    if ([cell isInCustomDetailPosition]) {
        if ([cell.cellType isEqualToString:@"Car"]) singleton.car = cell.textLabel.text;
        else if ([cell.cellType isEqualToString:@"Driver"]) singleton.driver = cell.textLabel.text;
        else if ([cell.cellType isEqualToString:@"Supervisor"]) singleton.supervisor = cell.textLabel.text;
        else if ([cell.cellType isEqualToString:@"Odometer"]) singleton.odometer = cell.textLabel.text;
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
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(ExtendedCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == ExtendedCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == ExtendedCellEditingStyleInsert) {
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
