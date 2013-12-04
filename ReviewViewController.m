//
//  ReviewViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 15/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
// NOTE: Use the setter method on containerArray as it automatically sorts. Don't edit it with methods such as addObject:
//  Update idea: A bar at the bottom or somwhere that selects what the drives are sorted by. Eg. by driver, by car, by date etc.

#import "ReviewViewController.h"

@interface ReviewViewController ()
{
    NSManagedObjectContext *context;
}

@end

@implementation ReviewViewController

- (NSMutableArray*) containerArray
{
    if (!_containerArray) {
        _containerArray = [[NSMutableArray alloc] init];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DriveRecord"];
        NSError *error = nil;
        NSMutableArray *unsortedArray = [[context executeFetchRequest:request error:&error] mutableCopy];
        if (error) NSLog(@"%@", error.localizedDescription);
        [unsortedArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            DriveRecord* objectOne = (DriveRecord*) obj1;
            DriveRecord* objectTwo = (DriveRecord*) obj2;
            return ([objectOne.driveDetailContainer.startDate compare:objectTwo.driveDetailContainer.startDate]);
        }];
        _containerArray = unsortedArray;
        //Replaces DriveRecord element with its container property
        /*if (unsortedArray.count > 0) {
            for (id element in unsortedArray) {
                DriveDetailContainer *container = ((DriveRecord*)element).driveDetailContainer;
                NSUInteger index = [unsortedArray indexOfObject:element]; //This returns earliest index of such an object.. issues?
                [_containerArray insertObject:container atIndex:index];
            }
        }*/
    }
    return _containerArray;
}

//Gets the managedObjectContext from the app delegate
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *aContext = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        aContext = [delegate managedObjectContext];
    }
    return aContext;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    context = [self managedObjectContext];

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
    // Return the number of rows in the section.
    return self.containerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //NOTE: Maybe for later - cells that extend downards to show the drive details
    DriveDetailContainer *cellDriveRecord = [self.containerArray[indexPath.row] driveDetailContainer];
    NSDate *driveDate = cellDriveRecord.startDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[[NSCalendar currentCalendar] timeZone]];
    NSString *formattedDate = [formatter stringFromDate:driveDate];
    cell.textLabel.text = formattedDate;
    
    return cell;
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

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *selectedCell = ((UITableViewCell*) sender);
        NSUInteger selectedCellRow = [self.tableView indexPathForCell:selectedCell].row;
        
        if ([segue.identifier isEqualToString:@"toRecentDriveReview"]) {
            UIViewController <DriveRecordDeveloper> *nextViewController = segue.destinationViewController;
            nextViewController.driveDetailContainer = [self.containerArray[selectedCellRow] driveDetailContainer];
        }
    }
    
    //BREAK: check the container in the next view. Has it set correctly?
    
    // Pass the selected object to the new view controller.
}

@end
