//
//  StartscreenViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 14/09/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "StartscreenViewController.h"

@interface StartscreenViewController ()

@end

@implementation StartscreenViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
