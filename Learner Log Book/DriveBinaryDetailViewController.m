//
//  DriveBinaryDetailViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 8/12/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "DriveBinaryDetailViewController.h"

@interface DriveBinaryDetailViewController ()

{
	NSMutableDictionary *detailsDictionary;
	NSMutableArray *tickedDetails;
	NSMutableArray *criteriaSectionKeys;
}

@property (strong, nonatomic) NSMutableDictionary *criteriaDictionary;

@end

@implementation DriveBinaryDetailViewController

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

- (NSMutableDictionary*) cellDictionaryForPath: (NSIndexPath*) indexPath
{
    if (indexPath.section < criteriaSectionKeys.count) {
        NSString *currentSectionKey = criteriaSectionKeys[indexPath.section];
        NSArray *currentSectionArray = [detailsDictionary objectForKey:currentSectionKey];
        NSMutableDictionary *currentCellDictionary = currentSectionArray[indexPath.row];
        return currentCellDictionary;
        
    }
    else return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self tableView:self.tableView numberOfRowsInSection:section] == 0) return nil;
    else return [[self.criteriaDictionary objectForKey:@"sectionKeys"] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int rows = [[detailsDictionary objectForKey:criteriaSectionKeys[section]] count];
    return rows;
	
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
	
	//Setup custon cell XIBs
    //UINib *nib = [UINib nibWithNibName:@"DriveBinaryDetailCell" bundle:nil];
    //[[self tableView] registerNib:nib forCellReuseIdentifier:@"BinaryDetailCell"];
	
	criteriaSectionKeys = [self.criteriaDictionary objectForKey:@"sectionKeys"];
	
	NSLog(@"Just checking this is actually getting called...");
	tickedDetails = [[NSMutableArray alloc] init];
	detailsDictionary = [self.driveDetailContainer.driveCompletionBinaryDetails copy];
	NSEnumerator *enumerator = [detailsDictionary keyEnumerator];
	id element;
	
	while ((element = [enumerator nextObject])) {
		if ([element isEqualToString:@"sectionKeys"]) continue;
		NSMutableArray *arrayForCurrentSection = [detailsDictionary valueForKey:element];
		NSMutableArray *objectsToBeDeleted = [[NSMutableArray alloc] init];
		for (id currentDictionary in arrayForCurrentSection) {
			id value = [currentDictionary valueForKey:@"Value"];
			//if ([value isEqualToNumber:[NSNumber numberWithBool:YES]])
				//[tickedDetails addObject:[currentDictionary valueForKey:@"Title"]];
			if ([value isEqualToNumber:[NSNumber numberWithBool:NO]])
				[objectsToBeDeleted addObject:currentDictionary];
		}
		[arrayForCurrentSection removeObjectsInArray:objectsToBeDeleted];
	}
	
	
	
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
    int sections = criteriaSectionKeys.count;
    return (sections-1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	UILabel *cellsLabel = (UILabel*)[cell viewWithTag:1];
	
	// Configure the cell...
    NSMutableDictionary *currentCellDictionary = [self cellDictionaryForPath:indexPath];
    cellsLabel.text = [currentCellDictionary objectForKey:@"Title"];
    
    // Configure the cell...
	//If the detail's value is FALSE, then make the image a cross. If yes, make cells image a tick.
    
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
