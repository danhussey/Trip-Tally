//
//  DriveCompletedDetailsViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 6/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "DriveCompletedDetailsViewController.h"

@interface DriveCompletedDetailsViewController ()
{
    NSMutableArray *criteriaSectionKeys;
}
@end

@implementation DriveCompletedDetailsViewController

- (NSMutableDictionary*) criteriaDictionary
{
    if (!_criteriaDictionary) {
        NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"vicCriteria" ofType:@"plist"];
        NSData *criteriaData = [NSData dataWithContentsOfFile:thePath];
        
        NSError *error;
        _criteriaDictionary = [NSPropertyListSerialization propertyListWithData:criteriaData
                                                                        options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];
        if (error) NSLog(@"%@", error.description);
    }
    return _criteriaDictionary;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableDictionary*) cellDictionaryForPath: (NSIndexPath*) indexPath
{
    if (indexPath.section < criteriaSectionKeys.count) {
        NSString *currentSectionKey = criteriaSectionKeys[indexPath.section];
        NSArray *currentSectionArray = [self.criteriaDictionary objectForKey:currentSectionKey];
        NSMutableDictionary *currentCellDictionary = currentSectionArray[indexPath.row];
        return currentCellDictionary;
    }
    else return nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    criteriaSectionKeys = [self.criteriaDictionary objectForKey:@"sectionKeys"];
    
    //Add gesture recognizer to the tableView
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:gestureR];
    
    UISwipeGestureRecognizer *gestureL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:gestureL];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    //Find cell the swipe happened on
    UITableView *tableView = [self tableView];
    CGPoint location = [recognizer locationInView:self.view];
    NSIndexPath *swipedIndexPath = [tableView indexPathForRowAtPoint:location];
    BinarySelectionCell *swipedCell  = (BinarySelectionCell*)[tableView cellForRowAtIndexPath:swipedIndexPath];
    
    //NOTE: MAke global.
    NSMutableDictionary *currentCellDictionary = [self cellDictionaryForPath:swipedIndexPath];
    
    if (!swipedCell.binaryPosition && recognizer.direction == UISwipeGestureRecognizerDirectionRight) { //Flip to tick
        swipedCell.binaryPosition = true;
        [currentCellDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:@"Value"];
        if (swipedCell.isFinishedCell) [self finishedCellSwiped];
        
    }
    else if (swipedCell.binaryPosition && recognizer.direction == UISwipeGestureRecognizerDirectionLeft) { //Flip to cross
        swipedCell.binaryPosition = false;
        [currentCellDictionary setValue:[NSNumber numberWithBool:FALSE] forKey:@"Value"];
        
    }
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
    int sections = criteriaSectionKeys.count;
    return (sections+1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == criteriaSectionKeys.count) { //Finish section
        return 1;
    }
    else {
        int rows = [(NSMutableArray*)[self.criteriaDictionary objectForKey:criteriaSectionKeys[section]] count];
        return rows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BinarySelectionCell *cell = (BinarySelectionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == Nil && indexPath.section < criteriaSectionKeys.count) {
        cell = [[BinarySelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section < criteriaSectionKeys.count) {
        NSMutableDictionary *currentCellDictionary = [self cellDictionaryForPath:indexPath];
        cell.dynamicView.textLabel.text = [currentCellDictionary objectForKey:@"Title"];
        [cell snapToBinaryPosition:[[currentCellDictionary objectForKey:@"Value"] boolValue]];
    }
    
    else {
        cell.isFinishedCell = YES;
    }
    
    return cell;
}

- (void) finishedCellSwiped
{
    //Go to finished page
    [self performSegueWithIdentifier:@"toRecentDriveReview" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.driveRecord.driveDetailContainer.driveCompletionBinaryDetails = self.criteriaDictionary;
    if ([segue.identifier  isEqualToString:@"toRecentDriveReview"]) {
        [((RecentDriveReviewViewController*) segue.destinationViewController) setDisplaySave:YES];
        
        UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
        nextViewController.driveRecord = self.driveRecord;
    }
    //[self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < criteriaSectionKeys.count) {
        return [[self.criteriaDictionary objectForKey:@"sectionKeys"] objectAtIndex:section];
    }
    
    else if (section == criteriaSectionKeys.count) {
        return @"Finished";
    }
    else return nil;
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

