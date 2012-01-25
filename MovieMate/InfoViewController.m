//
//  InfoViewController.m
//  MovieMate
//
//  Created by Dean Andreakis on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()
- (void)buttonClicked:(id)sender;
@end


@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"information" ofType:@"png"]];
        self.tabBarItem.title = @"Information";
        //self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    UILabel* infoText = [[UILabel alloc] initWithFrame:CGRectMake(10,10,310,170)];
    infoText.tag = INFOTEXT_TAG;
    infoText.font =  [UIFont fontWithName:@"Verdana-Bold" size:20];
    infoText.textAlignment = UITextAlignmentCenter;
    infoText.textColor = [UIColor blackColor];
    infoText.lineBreakMode = UILineBreakModeWordWrap;
    infoText.numberOfLines = 0;
    infoText.text = @"MovieSmash v1.0\nCopyright 2012\nDean Andreakis\nAll Rights Reserved";
    [self.view addSubview:infoText];
    
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 170, 128, 128)];
    NSString *pathToIcon = [[NSBundle mainBundle] pathForResource:@"movieicon" ofType:@"png"];
    UIImage* iconImage = [[UIImage alloc] initWithContentsOfFile:pathToIcon];
    [iconView setImage:iconImage];
    [self.view addSubview:iconView];
    
    UIButton* rateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rateButton.frame = CGRectMake(100, 330, 125, 44);
    [rateButton setTitle:@"Rate This App!" forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rateButton];
}

- (void)buttonClicked:(id)sender
{
    //replace with app id for this app when submitting
 //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=417667154"]];   
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
