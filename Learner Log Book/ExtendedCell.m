//
//  ExtendedCell.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

//Note: Extended Cell is quite specialized to this logbook app
//Stop scrolling, make it a stationary view
//Add the swipe up to delete shit

#import "ExtendedCell.h"

@interface ExtendedCell()


@end

@implementation ExtendedCell

#pragma - property setters/getters

- (NSString*) cellType
{ //Set as soon as the cell is drawn
    if (!_cellType) {
        _cellType = @"UndefinedType";
    }
    return _cellType;
}

- (NSMutableArray*) cellData
{ //Warning: Always makes a new array, EVERY TIME it's called.... efficient? I think naht
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.cellType];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    if ([self isADriveDetailCell]) {
        NSError *error = nil;
        dataArray = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy]; //Array of nsmanagedobjects which are car entities
        if (error) NSLog(error.description);
    }
    
    //Adding cell's title to the start of array, and the add new cell to the end of the array
    [dataArray insertObject:self.cellType atIndex:0];
    [dataArray addObject:[NSString stringWithFormat:@"Add New %@...", self.cellType]]; //Add addnew title onto the data array end
    //NSLog(@"Data Array Fetched: %@",dataArray.description);
    //NSLog(@"Cell Data array before assignment %@", _cellData.description);
    _cellData = dataArray;
    return _cellData;
}

#pragma - Method implementations (general)

- (BOOL) isADriveDetailCell {
    NSArray *driveDetailSet = [[NSArray alloc] initWithObjects:@"Car", @"Driver", @"Supervisor", nil];
    if ([driveDetailSet containsObject:self.cellType]) return YES;
    else return NO;
}

- (void) setCellPositionToDefault
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"Defaults are currently: %@", defaults.description);
    self.cellPosition = CGPointMake([defaults integerForKey:self.cellType], 0.0);
    
    //Maybe pur this somewhere else dude
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (void) updateCellContents
{
    if ([[self.cellData objectAtIndex:self.cellPosition.x] isKindOfClass:[NSManagedObject class]]) {
        self.textLabel.text = [[self.cellData objectAtIndex:self.cellPosition.x] valueForKey:@"generalKey"];
    }
    else if ([[self.cellData objectAtIndex:self.cellPosition.x] isKindOfClass:[NSString class]]) {
        self.textLabel.text = [self.cellData objectAtIndex:self.cellPosition.x]; //If the object is just a string
    }
    [self updateOdometerCell];
}

- (void) updateOdometerCell {
        ExtendedCell *carCell = (ExtendedCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        ExtendedCell *odometerCell = (ExtendedCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        if ([carCell isInCustomDetailPosition]) {
            NSManagedObject *car = [carCell.cellData objectAtIndex:carCell.cellPosition.x];
            int odometer = (int)[[car valueForKey:@"odometer"] intValue];
            odometerCell.textLabel.text = [NSString stringWithFormat:@"%i KM", odometer];
        }
        else odometerCell.textLabel.text = @"Odometer";
    if (self.textLabel.hidden) self.textLabel.hidden = NO;
}

- (UITableView*) tableView
{
    id view = [self superview];
    while ([view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    return tableView;
}

- (void) updateCellContentsAnimatedWithDirection:(UISwipeGestureRecognizerDirection)direction
{
    UITableView *tableView = [self tableView];
    
    ExtendedCell *transitionView = [[ExtendedCell alloc] initWithFrame:self.contentView.frame];
    
    CGRect leftOfCurrentFrame = CGRectMake(self.frame.origin.x-320, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect rightOfCurrentFrame = CGRectMake(self.frame.origin.x+320, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect originalFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    if (direction == UISwipeGestureRecognizerDirectionLeft) transitionView.frame = rightOfCurrentFrame;
    else if (direction == UISwipeGestureRecognizerDirectionRight) transitionView.frame = leftOfCurrentFrame;
    transitionView.backgroundView = self.backgroundView;
    transitionView.textLabel.textAlignment = NSTextAlignmentCenter;
    [tableView addSubview:transitionView];
    
    if ([[self.cellData objectAtIndex:self.cellPosition.x] isKindOfClass:[NSManagedObject class]]) {
        transitionView.textLabel.text = [[self.cellData objectAtIndex:self.cellPosition.x] valueForKey:@"generalKey"];
        [UIView animateWithDuration:0.15
                         animations:^{if (direction == UISwipeGestureRecognizerDirectionLeft) {self.frame = leftOfCurrentFrame;}
                         else {self.frame = rightOfCurrentFrame;}
                             transitionView.frame = originalFrame;
                         }
         
                         completion:^(BOOL finished) {
                             if (finished) {
                                 self.textLabel.text = transitionView.textLabel.text;
                                 self.frame = transitionView.frame;
                                 [transitionView removeFromSuperview];
                             }
                         }];
    }
    else if ([[self.cellData objectAtIndex:self.cellPosition.x] isKindOfClass:[NSString class]]) {
        transitionView.textLabel.text = [self.cellData objectAtIndex:self.cellPosition.x];
        [UIView animateWithDuration:0.15
                         animations:^{if (direction == UISwipeGestureRecognizerDirectionLeft) {self.frame =leftOfCurrentFrame;}
                         else {self.frame = rightOfCurrentFrame;}
                             transitionView.frame = originalFrame;
                         }
         
                         completion:^(BOOL finished) {
                             if (finished) {
                                 self.textLabel.text = transitionView.textLabel.text;
                                 self.frame = transitionView.frame;
                                 [transitionView removeFromSuperview];
                             }
                         }];
    }
    [self updateOdometerCell];
}

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

- (void) incrementCellPositionInDirection:(UISwipeGestureRecognizerDirection)direction
{
    
    NSLog(@"Before: %f", self.cellPosition.x);
    if ([self isADriveDetailCell]) {
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            if (self.cellPosition.x == self.cellData.count-1) self.cellPosition = CGPointMake(0.0, self.cellPosition.y); //Looping functionality of swipe list
            else self.cellPosition = CGPointMake(self.cellPosition.x+1,self.cellPosition.y);
        }
        else if (direction == UISwipeGestureRecognizerDirectionRight) {
            if (self.cellPosition.x == 0) self.cellPosition = CGPointMake(self.cellData.count-1, self.cellPosition.y);
            else self.cellPosition = CGPointMake(self.cellPosition.x-1, self.cellPosition.y);
        }
    }
        //Leaving the other two tabs just clickable for now... I feel it's better UI
    NSLog(@"After: %f", self.cellPosition.x);
    //[self updateCellContents]; //Update the cell after the incrementing of position
    [self updateCellContentsAnimatedWithDirection:direction];
}

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft
        || //or
        recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        
        if ([self isADriveDetailCell]) {
            if ([self.contentView viewWithTag:1984]) [[self.contentView viewWithTag:1984] removeFromSuperview]; //Get rid of text box if it's there before any cell movement
            else if ([self.contentView viewWithTag:69]) {
                [[self.contentView viewWithTag:69] removeFromSuperview];
                self.textLabel.hidden = NO;
                self.textLabel.userInteractionEnabled = YES;
            }
            [self incrementCellPositionInDirection:recognizer.direction]; //Note: What will happen with a down or up gesture...??
        }
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void) handleTapFrom:(UISwipeGestureRecognizer *)recognizer
{
    if ([self isADriveDetailCell] && [self isInCustomDetailPosition]) {
        UITextField *textField = [[UITextField alloc] initWithFrame:self.textLabel.frame];
        [textField setTag:69];
        textField.text = self.textLabel.text;
        self.textLabel.hidden = YES;
        self.textLabel.userInteractionEnabled = NO;
        textField.delegate = self;
        textField.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:textField];
        [[self.contentView viewWithTag:69] becomeFirstResponder]; //Begin editing immediately
    }
    
    else if ([self isADriveDetailCell]) {
        if([self.textLabel.text isEqualToString:[NSString stringWithFormat:@"Add New %@...", self.cellType]]) {
            if (![self.contentView viewWithTag:1984]) { //If there isn't already a text box
                //Add text box (Warning, it's invisible usually)
                self.textLabel.hidden = YES;
                UITextField *textField = [[UITextField alloc]initWithFrame:self.textLabel.frame];
                textField.clearsOnBeginEditing = NO;
                textField.delegate = self;
                //textField.backgroundColor = [UIColor grayColor];
                textField.tag = 1984;
                textField.textAlignment = NSTextAlignmentCenter;
                [self.contentView addSubview:textField];
                [[self.contentView viewWithTag:1984] becomeFirstResponder];
            }
        }
    }
    else if ([self.cellType isEqualToString:@"Odometer"]) {
        ExtendedCell *carCell = (ExtendedCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([carCell isInCustomDetailPosition]) {
            //Add text box (Warning, it's invisible usually)
            UITextField *textField = [[UITextField alloc]initWithFrame:self.textLabel.frame];
            textField.clearsOnBeginEditing = NO;
            textField.text = [NSString stringWithFormat:@"%i",[self.textLabel.text integerValue]];
            textField.delegate = self;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            //textField.backgroundColor = [UIColor grayColor];
            textField.tag = 1984;
            textField.textAlignment = NSTextAlignmentCenter;
            self.textLabel.hidden = YES;
            [self.contentView addSubview:textField];
            [[self.contentView viewWithTag:1984] becomeFirstResponder];
        }
    }
}

- (void) setupLabelTapRecognizer {
    if (![self.cellType  isEqual: @"Drive"]) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    self.textLabel.userInteractionEnabled = YES;
    [self.textLabel addGestureRecognizer:recognizer];
    }
}

- (BOOL) isInCustomDetailPosition {
    if (![self.cellType isEqualToString:@"Odometer"]) {
        if (self.cellPosition.x == self.cellData.count-1 || self.cellPosition.x == 0) return NO;
        else if ([self.textLabel.text isEqualToString:@"Odometer"]) NSLog(@"Odometer not ready");
        else return YES;
    }
    else {
        if (![self.textLabel.text isEqualToString:@"Odometer"]) return YES;
    }
}

- (void) handleLabelTap
{
    if ([self isADriveDetailCell] && [self isInCustomDetailPosition]) {
        UITextField *textField = [[UITextField alloc] initWithFrame:self.textLabel.frame];
        [textField setTag:69];
        textField.text = self.textLabel.text;
        textField.frame = self.textLabel.frame;
        self.textLabel.hidden = YES;
        self.textLabel.userInteractionEnabled = NO;
        textField.delegate = self;
        [self.contentView addSubview:textField];
        [[self.contentView viewWithTag:69] becomeFirstResponder]; //Begin editing immediately
    }
}

- (BOOL) textFieldShouldReturn: (UITextField *)textField
{
    if (textField.tag == 1984 && ![self.cellType isEqualToString:@"Odometer"]) [self addTextFieldToDatabase:textField];
    else if (textField.tag == 1984 && [self.cellType isEqualToString:@"Odometer"]) [self alterOdometerWithTextField:textField];
    else if (textField.tag == 69) [self editExistingDetailFromField:textField];
    [textField removeFromSuperview]; //Get rid of text box
    [self updateCellContents];
    [self endEditing:YES];
    
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    [textField removeFromSuperview]; //Get rid of text box
    if (self.textLabel.hidden) self.textLabel.hidden = NO;
    return YES;
}

- (void) editExistingDetailFromField: (UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        if ([self hasDuplicateInDatabase:self.textLabel.text])
        {
            NSLog(@"Currently editing %@", self.textLabel.text);
            NSManagedObjectContext *context = [self managedObjectContext]; //Create context
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *description = [NSEntityDescription entityForName:self.cellType inManagedObjectContext:context];
            [fetchRequest setEntity:description];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"generalKey == %@",self.textLabel.text];
            [fetchRequest setPredicate:predicate];
            NSError *error;
            NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
            if (!array) NSLog(@"ERROR: %@",error.description);
            if ([self hasDuplicateInDatabase:textField.text]) [self shakeView:self.contentView];
            else if (array.count == 1 && ![self hasDuplicateInDatabase:textField.text]) [array.lastObject setValue:textField.text forKey:@"generalKey"];
            else if (array.count >1) NSLog(@"Error. editExistingDetail array returned more than one object for the text.");
            error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
        }
        else NSLog(@"Error. editExistingDetail. No duplicate was found for the text in the cell.");
    }
    else [self shakeView:self.contentView];
    self.textLabel.hidden = NO;
    self.textLabel.userInteractionEnabled = YES;
    [self updateCellContents];
}

- (NSString*) textAtCellPosition:(int)index
{
    return self.cellData[index];
}

- (BOOL) hasDuplicateInDatabase: (NSString*) text {
    for (id element in self.cellData) {
        if ([element isKindOfClass:[NSString class]]) {
            if ([text caseInsensitiveCompare:element] == NSOrderedSame) return YES;
        }
        if ([element isKindOfClass:[NSManagedObject class]]) {
            NSString* objectText = [element valueForKey:@"generalKey"];
            if ([text caseInsensitiveCompare:objectText] == NSOrderedSame) return YES;
        }
    }
    return NO;
}

- (void) addTextFieldToDatabase:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) { //If text field isn't blank
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (![self hasDuplicateInDatabase:textField.text]) { //If that detail isn't alreaedy in the database (not a copy)
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:self.cellType inManagedObjectContext:context]; //Insert a new object into coredatea of entity type that has been defined in cellType
            [newObject setValue:[textField text] forKey:@"generalKey"];
        }
        else [self dataDuplicateTriedToBeAdded]; //If it's a duplicate, deal with it in that method
        
        NSError *error;
        error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void) alterOdometerWithTextField:(UITextField*)textField
{
    if ([self.cellType isEqualToString:@"Odometer"]) {
        NSManagedObjectContext *context = [self managedObjectContext];
        ExtendedCell *carCell = (ExtendedCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([carCell isInCustomDetailPosition]) {
            NSManagedObject *car = [carCell.cellData objectAtIndex:carCell.cellPosition.x];
            [car setValue:[NSNumber numberWithInt:textField.text.intValue] forKey:@"odometer"];
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

- (void) dataDuplicateTriedToBeAdded {
    [self shakeView:self.contentView];
}

- (BOOL) cellIsReadyForSegue
{
    if (self.isInCustomDetailPosition) return YES;
    else {
        [self shakeView:self];
        return NO;
    }
}

@end