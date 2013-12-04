//
//  DriveDetailCell.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "DriveDetailCell.h"
#define detailLabelTag 1

@implementation WrappingCellPositionFactory

#pragma mark - Wrapping Cell Position Initialization

- (id) init
{
    self = [super init];
    if (self) {
        self.cellPosition = 0; //Change for user defaults in future
        self.cellDataArrayCount = 2; //Default for a parsed array without any custom insertions
    }
    return self;
}

#pragma mark - Incrementing and Decrementing Positions

- (void) incrementCellPosition
{
    if (self.cellPosition == self.cellDataArrayCount-1) self.cellPosition = 0;
    else self.cellPosition += 1;
}

- (void) decrementCellPosition
{
    if (self.cellPosition == 0) self.cellPosition = self.cellDataArrayCount-1;
    else self.cellPosition -= 1;
}

@end

@interface DriveDetailCell ()

{
    NSManagedObjectContext *managedObjectContext;
    WrappingCellPositionFactory *wrappingCellPosition;
    BOOL deleteFlag; //Decides whther or not incrementing will happen upon swipe
    
}

@property (weak, nonatomic) NSNumber *deleteButtonShowing;
@property (strong, nonatomic) NSNumber *cellPosition;
@property (strong, nonatomic) UIButton *deleteButton;

@end

@implementation DriveDetailCell

#pragma mark - Default Method Implementation

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
    // Configure the view for the selected state
}

- (void) awakeFromNib   //Cell type not yet set
{
    //Custom init goes here
    managedObjectContext = [self managedObjectContext];
    wrappingCellPosition = [[WrappingCellPositionFactory alloc] init];
    self.detailField.delegate = self;
    deleteFlag = NO;
}

#pragma mark - Cell Information Methods

- (NSManagedObject*) currentObjectBeingDisplayed //Only call after checked for custom cell position
{
    return [self.cellData objectAtIndex:wrappingCellPosition.cellPosition];
}

- (BOOL) isOdometerOrDriveCell
{
    if ([self.cellType isEqualToString:@"Odometer"] || [self.cellType isEqualToString:@"Drive"]) {
        return YES;
    }
    else return NO;
}

- (BOOL) isInCustomDetailPosition //Automatically returns no for odometer and drive cell
{
    if (wrappingCellPosition.cellPosition > 0 && wrappingCellPosition.cellPosition != self.cellData.count-1 && ![self isOdometerOrDriveCell]) return YES;
    else {
        return NO;
    }
}

- (BOOL) isReadyForSegue
{
    [self endEditing:YES];
    [self updateCellText];
    if ([self isInCustomDetailPosition]) return YES;
    else if ([self isOdometerOrDriveCell]) {
        if (![self.detailField.text isEqualToString:@"Odometer"]) return YES;
    }
    [self shakeView:self];
    return NO;
}

- (BOOL) isInAddNewPosition
{
    if (wrappingCellPosition.cellPosition == wrappingCellPosition.cellDataArrayCount-1) return YES;
    else return NO;
}
#pragma mark - Updating Cell Text

- (void) updateCellText
{
    NSString *updatedText;
    if ([self isInCustomDetailPosition]) {
        NSManagedObject *managedObject = (NSManagedObject*)[self.cellData objectAtIndex:wrappingCellPosition.cellPosition];
        updatedText = [self stringForManagedObject:managedObject];
    }
    else if ([self isOdometerOrDriveCell]) {
        //updatedText = [self.cellData firstObject]; //The title for these cells are always the first object (Check cell data method
        [self updateOdometerCell];
        return;
    }
    else updatedText = [self.cellData objectAtIndex:wrappingCellPosition.cellPosition];
    self.detailField.text = updatedText;
    [self updateOdometerCell];
}

- (void) updateOdometerCell {
    DriveDetailCell *carCell = (DriveDetailCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    DriveDetailCell *odometerCell = (DriveDetailCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    odometerCell.detailField.text = @"Odometer";
    if ([carCell isInCustomDetailPosition]) {
        NSManagedObject *car = [carCell currentObjectBeingDisplayed];
        int odometer = (int)[[car valueForKey:@"odometer"] intValue];
        odometerCell.detailField.text = [NSString stringWithFormat:@"%i KM", odometer];
    }
}

#pragma mark - Getting and Parsing Cell Data

- (NSMutableArray*) cellData //Simple, parsed copy of the cell's data coming from the database. Also updates the wrapping position incrementor
//Array of NSStrings
{
    if (![self isOdometerOrDriveCell]) {
        NSString *cellEntityName = self.cellType;
        NSFetchRequest *cellDataRequest = [[NSFetchRequest alloc] initWithEntityName:cellEntityName];
        NSMutableArray *cellDataFetchResults = [[managedObjectContext executeFetchRequest:cellDataRequest error:nil] mutableCopy];
        NSMutableArray *parsedCellDataArray = [self parsedCellDataArrayForCurrentCellType: cellDataFetchResults];
        
        //Updating the wrapping position keeper
        wrappingCellPosition.cellDataArrayCount = parsedCellDataArray.count;
        
        return parsedCellDataArray;
    }
    
    else if ([self.cellType isEqualToString:@"Drive"]) {
        NSMutableArray *driveCellDataArray = [NSMutableArray arrayWithObject:@"Drive"];
        return driveCellDataArray;
    }
}

- (NSMutableArray*) convertAllManagedObjectsToStrings: (NSMutableArray*) array
{
    NSMutableArray *convertedArray = [NSMutableArray arrayWithArray:array];
    for (id element in array) {
        if ([element isKindOfClass:[NSManagedObject class]]) {
            int index = [array indexOfObject:element];
            NSString* convertedObject = [self stringForManagedObject:element];
            [convertedArray replaceObjectAtIndex:index withObject:convertedObject];
        }
    }
    return convertedArray;
}

- (NSMutableArray*) parsedCellDataArrayForCurrentCellType: (NSMutableArray*) arrayToBeParsed
{
    //Current cell referring to whatever type of cell the particular instance is
    //NSMutableArray *arrayToBeParsed = [NSMutableArray arrayWithArray:arrayAboutToBeParsed];
    NSString *currentCellTitle = [NSString stringWithFormat:@"%@", self.cellType];
    [arrayToBeParsed insertObject:currentCellTitle atIndex:0];
    NSString *addNewDetailString = [NSString stringWithFormat:@"Add New %@...", self.cellType];
    [arrayToBeParsed addObject:addNewDetailString];
    return arrayToBeParsed;
}

#pragma mark - Managed Object Parser
- (NSString*) stringForManagedObject:(NSObject*) managedObject
{
    if ([managedObject isKindOfClass:[NSManagedObject class]]) {
        NSString *string = [managedObject valueForKey:@"generalKey"];
        return string;
    }
    else return (NSString*)managedObject;
}

#pragma mark - Handling Swipe Event

- (void) handleSwipeFromTableViewRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (![self isOdometerOrDriveCell])
    [self swipeEventAnimated:YES withRecognizer:gestureRecognizer];
}

- (UIView*) newDriveDetailCellView //Returns xib cells content view. Could cause issues with IBOutlets...
{
    UINib *nib = [UINib nibWithNibName:@"DriveDetailCell" bundle:nil];
    NSArray *nibContents = [nib instantiateWithOwner:nil options:nil];
    
    UIView *driveDetailCellContentView = (DriveDetailCell*)[nibContents objectAtIndex:0]; //Assumes the contents view is at index 1
    return driveDetailCellContentView;
}

- (void) swipeEventAnimated: (BOOL) animated withRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
//Gets new view, places it out of view, increments the cell position, edits new view's contents accordingly to it's position, then puts the increment in effect with or without animation
{
    if (animated)
    {
        NSLog(@"Before: %i", wrappingCellPosition.cellPosition);
        
        //Frame positions
        CGRect originalContentViewFrame = self.contentView.frame;
        CGRect leftOfOriginalContentViewFrame = CGRectMake(originalContentViewFrame.origin.x-320, originalContentViewFrame.origin.y, originalContentViewFrame.size.width, originalContentViewFrame.size.height);
        CGRect rightOfOriginalContentViewFrame = CGRectMake(originalContentViewFrame.origin.x+320, originalContentViewFrame.origin.y, originalContentViewFrame.size.width, originalContentViewFrame.size.height);
        
        UINib *transitionNib = [UINib nibWithNibName:@"DriveDetailCell" bundle:nil];
        DriveDetailCell *transitionView = (DriveDetailCell*)[[transitionNib instantiateWithOwner:self options:nil] firstObject];
        
        
        switch (gestureRecognizer.direction) {
            case UISwipeGestureRecognizerDirectionLeft: //Increment
            {
                if (!deleteFlag)
                    [wrappingCellPosition incrementCellPosition];
                transitionView.frame = rightOfOriginalContentViewFrame;
            }
                break;
                
            case UISwipeGestureRecognizerDirectionRight: //Decrement
            {
                if (!deleteFlag)
                    [wrappingCellPosition decrementCellPosition];
                transitionView.frame = leftOfOriginalContentViewFrame;
            }
                break;
                
            default:
                break;
        }
        
        transitionView.detailField.text = [self stringForManagedObject:[self.cellData objectAtIndex:wrappingCellPosition.cellPosition]];
        [self.contentView addSubview:transitionView];
        
        [UIView animateWithDuration:0.15
                         animations:^{
                             if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)
                                 self.contentView.frame = leftOfOriginalContentViewFrame;
                             else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight)
                                 self.contentView.frame = rightOfOriginalContentViewFrame;
                         }
         
                         completion:^(BOOL finished) {
                             if (finished) {
                                 self.detailField.text = transitionView.detailField.text;
                                 self.contentView.frame = originalContentViewFrame;
                                 [self.detailField endEditing:YES];
                                 [transitionView removeFromSuperview];
                                 NSLog(@"After: %i", wrappingCellPosition.cellPosition);
                                 deleteFlag = NO;
                                 [self updateCellText];
                             }
                         }];
        [self updateOdometerCell];
    }
}

#pragma mark - Text Field Editing Logic

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [self updateCellText];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    if (![self isOdometerOrDriveCell] && [self isInCustomDetailPosition] && ![self.deleteButtonShowing boolValue]) {
        self.deleteButtonShowing = [NSNumber numberWithBool:YES];
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self isInCustomDetailPosition]) {
        textField.clearsOnBeginEditing = NO;
        return YES;
    }
    else if ([self isInAddNewPosition]) {
        textField.clearsOnBeginEditing = YES;
        return YES;
    }
    else if ([self isOdometerOrDriveCell]) {
        DriveDetailCell *carCell = (DriveDetailCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([carCell isInCustomDetailPosition]) {
            textField.clearsOnBeginEditing = YES;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            return YES;
        }
        else return NO;
    }
    else return NO;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSString *copyOfText = [[NSString alloc] initWithString:textField.text];
    [self endEditing:YES];
    self.deleteButtonShowing = NO;
    if ([self isInAddNewPosition]){
        if ([self hasDuplicateInDatabase:copyOfText] || [copyOfText isEqualToString:@""] ) {
            [self shakeView:self];
            [self updateCellText];
            return NO;
        }
        else {
            [self addDetailToDatabaseWithGeneralKey:copyOfText];
            [self updateCellText];
            return YES;
        }
    }
    else if ([self isInCustomDetailPosition]) {
        if ([copyOfText isEqualToString:@""]) {
            [self shakeView:self];
            [self updateCellText];
            return NO;
        }
        else if ([self numberOfMatchesToString:copyOfText] == 0) {
            [[self.cellData objectAtIndex:wrappingCellPosition.cellPosition] setValue:copyOfText forKey:@"generalKey"];
        }
        else if ([self numberOfMatchesToString:copyOfText] > 0) {
            [self shakeView:self];
            [self updateCellText];
            return NO;
        }
        [self updateCellText];
        return YES;
    }
    else if ([self isOdometerOrDriveCell]) {
        if ([self.cellType isEqualToString:@"Odometer"]) {
            [self alterOdometerWithText:copyOfText];
        }
    }
    return YES;
}

#pragma mark - Database methods

- (void) deleteDetailFromStore: (NSString*) detailName
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:self.cellType];
    [request setPredicate:[NSPredicate predicateWithFormat:@"generalKey like %@", detailName]];
    NSMutableArray *results = [[managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    if (results.count == 1) {
        [managedObjectContext deleteObject:results[0]];
        [managedObjectContext save:nil];
        deleteFlag = YES;
    }
    else {
        NSLog(@"ERROR: deleteDetailFromStore fetch results returned with count: %i", results.count);
    }
    UISwipeGestureRecognizer *dummyRecognizer = [[UISwipeGestureRecognizer alloc] init]; //A dummy recognizer to simulate swiping left
    dummyRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self swipeEventAnimated:YES withRecognizer:dummyRecognizer];
    //[self updateCellText];
}

- (void) alterOdometerWithText: (NSString*) text
{
    if ([self.cellType isEqualToString:@"Odometer"]) {
        NSManagedObjectContext *context = [self managedObjectContext];
        DriveDetailCell *carCell = (DriveDetailCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([carCell isInCustomDetailPosition]) {
            NSManagedObject *car = [carCell currentObjectBeingDisplayed];
            [car setValue:[NSNumber numberWithInt:text.intValue] forKey:@"odometer"];
            NSError *error;
            error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            [self updateOdometerCell];
        }
    }
}

- (void) addDetailToDatabaseWithGeneralKey: (NSString*) string
{
    NSManagedObject *newDetail = [NSEntityDescription insertNewObjectForEntityForName:self.cellType inManagedObjectContext:managedObjectContext];
    [newDetail setValue:string forKey:@"generalKey"];
    [managedObjectContext save:nil];
}

//Gets the managedObjectContext from the app delegate
- (NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (BOOL) hasDuplicateInDatabase: (NSString*) string
{
    int hitCounter = 0;
    for (id element in self.cellData) {
        if ([[self stringForManagedObject:element] isEqualToString:string]) hitCounter++;
    }
    
    if (hitCounter > 0) return YES;
    else return NO;
}

- (int) numberOfMatchesToString: (NSString*) string
{
    int hitCounter = 0;
    for (id element in self.cellData) {
            if ([[self stringForManagedObject:element] isEqualToString:string]) hitCounter++;
        }
    
    return hitCounter;
}

#pragma mark - Custom Getter and Setters
- (void) setCellType:(NSString *)cellType
{
    _cellType = cellType;
    [self updateCellText]; //Only called once, when set
}

- (UIButton*) deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        UINib *deleteButtonNib = [UINib nibWithNibName:@"DeleteButton" bundle:nil];
        
        _deleteButton = [[deleteButtonNib instantiateWithOwner:self options:nil] firstObject];
        //_deleteButton.alpha = 0.0;
        _deleteButton.frame = CGRectMake(320, self.frame.origin.y, _deleteButton.frame.size.width, _deleteButton.frame.size.height);
        
        [_deleteButton addTarget:self
                          action:@selector(deleteButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (void) setDeleteButtonShowing:(NSNumber *)deleteButtonShowing
{
    BOOL boolValue = [deleteButtonShowing boolValue];
    [self.tableView insertSubview:self.deleteButton aboveSubview:self.detailField];
    
    if (boolValue && [_deleteButtonShowing boolValue] == NO) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.deleteButton.frame = CGRectMake(320-55, _deleteButton.frame.origin.y, _deleteButton.frame.size.width, _deleteButton.frame.size.height);
                         }];
    }
    else if (!boolValue && [_deleteButtonShowing boolValue] == YES) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.deleteButton.frame = CGRectMake(320, _deleteButton.frame.origin.y, _deleteButton.frame.size.width, _deleteButton.frame.size.height);
                         }];
        self.deleteButton = nil;
    }
    _deleteButtonShowing = deleteButtonShowing;
}

#pragma mark - Misc

- (void)shakeView:(UIView *)viewToShake
{
    CGFloat t = 2.0;
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

- (void) deleteButtonPressed
{
    if ([self isInCustomDetailPosition]){
        NSString *originalTextBeforeEditing = [self stringForManagedObject:[self.cellData objectAtIndex:wrappingCellPosition.cellPosition]];
        self.deleteButtonShowing = NO;
        [self deleteDetailFromStore:originalTextBeforeEditing];
    }
}

@end
