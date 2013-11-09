//
//  DriveInSessionViewController.m
//  Learner Log Book
//
//  Created by Daniel Hussey on 2/10/13.
//  Copyright (c) 2013 Daniel Hussey. All rights reserved.
//

#import "DriveInSessionViewController.h"

@interface DriveInSessionViewController ()
{
    //Timer stuff
    NSTimeInterval startTime;
    NSTimeInterval elapsedTimeCache;
    NSTimeInterval elapsedTime;
    bool running;
}

@end

@implementation DriveInSessionViewController

- (IBAction)doDrivingStatusButton:(id)sender {
    if (running) {
        [self pauseTimer];
        [self.driveStatusButton setTitle:@"Paused" forState:UIControlStateNormal];
        self.driveStatusButton.backgroundColor = [UIColor grayColor];
    }
    else {
        [self startTimer];
        [self.driveStatusButton setTitle:@"Driving" forState:UIControlStateNormal];
        self.driveStatusButton.backgroundColor = [UIColor greenColor];
    }
}

- (IBAction)doFinishedButton:(UIButton *)sender {
}

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
    self.driveStatusButton.backgroundColor = [UIColor greenColor];
    [self setupTimer];
    [self startTimer]; //View only loads once... right?
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTimer {
    self.timerLabel.text = @"00 : 00 : 00";
    running = false;
    elapsedTimeCache = 0;
}

- (void) startTimer {
    running = true;
    startTime = [NSDate timeIntervalSinceReferenceDate];
    [self updateTimer];
}

- (void) updateTimer {
    if (!running) return;
    
    else if (running) {
        //Calculate elapsed time
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        elapsedTime = (currentTime - startTime) + elapsedTimeCache;
        
        //Extract time in form of hours minutes and seconds from elapsed time
        int hours = (int) (elapsedTime/(60*60));
        elapsedTime -= (hours*60*60);
        int minutes = (int) (elapsedTime/60);
        elapsedTime -= (minutes*60);
        int seconds = (int) elapsedTime;
        
        //Creates strings that have zeroes in them for numbers like 01
        NSString *hoursSection;
        if (hours < 10) hoursSection = [NSString stringWithFormat:@"0%i", hours];
        else if (hours < 100) hoursSection = [NSString stringWithFormat:@"%i", hours];
        else hoursSection = @"99";
        
        NSString *minutesSection;
        if (minutes < 10) minutesSection = [NSString stringWithFormat:@"0%i", minutes];
        else if (minutes < 100) minutesSection = [NSString stringWithFormat:@"%i", minutes];
        else minutesSection = @"99";
        
        NSString *secondsSection;
        if (seconds < 10) secondsSection = [NSString stringWithFormat:@"0%i", seconds];
        else if (seconds < 100) secondsSection = [NSString stringWithFormat:@"%i", seconds];
        else secondsSection = @"99";
        
        self.timerLabel.text = [NSString stringWithFormat:@"%@ : %@ : %@", hoursSection, minutesSection, secondsSection];
        
        [self performSelector:@selector(updateTimer) withObject:self afterDelay:0.1];
    }
}

- (void) pauseTimer {
    elapsedTimeCache = elapsedTime; //Gets the elapsed time of that session of ticking to be added back to elapsed time next start
    running = false;
}

@end
