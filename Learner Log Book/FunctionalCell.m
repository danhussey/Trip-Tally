//
//  FunctionalCell.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 29/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "FunctionalCell.h"

@implementation FunctionalCell

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
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(110, 10, 185, 30)];
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = UITextAlignmentRight;
    textField.delegate = self;
    [self.contentView addSubview:textField];
    // Configure the view for the selected state
}

@end
