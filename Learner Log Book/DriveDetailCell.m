//
//  DriveDetailCell.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/11/2013.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//
//  Not to be used for the odometer cell

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
    
}

@property (strong, nonatomic) NSNumber *cellPosition;

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
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) awakeFromNib
{
    //Custom init goes here
    managedObjectContext = [self managedObjectContext];
    wrappingCellPosition = [[WrappingCellPositionFactory alloc] init];
    
    self.detailField.delegate = self;
}

#pragma mark - Cell Information Methods

- (BOOL) isInCustomDetailPosition
{
    if (wrappingCellPosition.cellPosition > 0 && wrappingCellPosition.cellPosition != self.cellData.count-1) return YES;
    else {
        return NO;
    }
}

- (BOOL) isReadyForSegue
{
    if ([self isInCustomDetailPosition]) return YES;
    else return NO;
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
    else updatedText = [self.cellData objectAtIndex:wrappingCellPosition.cellPosition];
    self.detailField.text = updatedText;
}

#pragma mark - Getting and Parsing Cell Data

- (NSMutableArray*) cellData //Simple, parsed copy of the cell's data coming from the database. Also updates the wrapping position incrementor
//Array of NSStrings
{
    NSString *cellEntityName = self.cellType;
    NSFetchRequest *cellDataRequest = [[NSFetchRequest alloc] initWithEntityName:cellEntityName];
    NSMutableArray *cellDataFetchResults = [[managedObjectContext executeFetchRequest:cellDataRequest error:nil] mutableCopy];
    NSMutableArray *parsedCellDataArray = [self parsedCellDataArrayForCurrentCellType: cellDataFetchResults];
    
    //Updating the wrapping position keeper
    wrappingCellPosition.cellDataArrayCount = parsedCellDataArray.count;
    
    return parsedCellDataArray;
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
        [self.detailField endEditing:YES]; //In case it's editing while we swipe
        
        //Frame positions
        CGRect originalContentViewFrame = self.contentView.frame;
        CGRect leftOfOriginalContentViewFrame = CGRectMake(originalContentViewFrame.origin.x-320, originalContentViewFrame.origin.y, originalContentViewFrame.size.width, originalContentViewFrame.size.height);
        CGRect rightOfOriginalContentViewFrame = CGRectMake(originalContentViewFrame.origin.x+320, originalContentViewFrame.origin.y, originalContentViewFrame.size.width, originalContentViewFrame.size.height);
        
        UINib *transitionNib = [UINib nibWithNibName:@"DriveDetailCell" bundle:nil];
        DriveDetailCell *transitionView = (DriveDetailCell*)[[transitionNib instantiateWithOwner:self options:nil] firstObject];
        
        NSLog(@"TransitionView: %@", transitionView.description);
        
        switch (gestureRecognizer.direction) {
            case UISwipeGestureRecognizerDirectionLeft: //Increment
            {
                [wrappingCellPosition incrementCellPosition];
                transitionView.frame = rightOfOriginalContentViewFrame;
            }
                break;
                
            case UISwipeGestureRecognizerDirectionRight: //Decrement
            {
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
                                 [transitionView removeFromSuperview];
                             }
                         }];
        NSLog(@"After: %i", wrappingCellPosition.cellPosition);
    }
}

#pragma mark - Text Field Editing Logic

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self isInCustomDetailPosition]) return YES;
    else if ([self isInAddNewPosition]) {
        textField.clearsOnBeginEditing = YES;
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    if ([self isInAddNewPosition]){
        if ([self hasDuplicateInDatabase:textField.text] || [textField.text isEqualToString:@""] ) {
            [self shakeView:self];
            [self updateCellText];
            return NO;
        }
        else {
            [self addDetailToDatabaseWithGeneralKey:textField.text];
            [self updateCellText];
            return YES;
        }
    }
    else if ([self isInCustomDetailPosition]) {
        if ([textField.text isEqualToString:@""]) {
            [self shakeView:self];
            [self updateCellText];
            return NO;
        }
        else if ([self numberOfMatchesToString:textField.text] == 0) {
            [[self.cellData objectAtIndex:wrappingCellPosition.cellPosition] setValue:textField.text forKey:@"generalKey"];
            [managedObjectContext save:nil];
        }
        else if ([self numberOfMatchesToString:textField.text] > 0) {
            [self shakeView:self];
            [self updateCellText];
            return NO;
        }
        [self updateCellText];
        return YES;
    }
}

#pragma mark - Database methods

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

@end
