//
//  TabViewController.m
//  MovieMate
//
//  Created by Dean Andreakis on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TabViewController.h"
#import "MasterViewController.h"
#import "FavoriteViewController.h"
#import "InfoViewController.h"
#import "DatabaseManager.h"

@implementation TabViewController

@synthesize navigationController = _navigationController;
@synthesize navigationControllerFavorite = _navigationControllerFavorite;
@synthesize tabBarController = _tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    FavoriteViewController *favoriteViewController = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
    InfoViewController *infoViewController = [[InfoViewController alloc] init];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.view.frame = CGRectMake(0, 0, 320, 460);
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.navigationControllerFavorite = [[UINavigationController alloc] initWithRootViewController:favoriteViewController];
    
    [self.tabBarController setViewControllers:
     [NSArray arrayWithObjects: self.navigationController, self.navigationControllerFavorite, infoViewController, nil]];
    [self.tabBarController setDelegate:self];
    
    masterViewController.managedObjectContext = [[DatabaseManager sharedDatabaseManager] managedObjectContext];
    favoriteViewController.managedObjectContext = [[DatabaseManager sharedDatabaseManager] managedObjectContext];
    [self.view addSubview:self.tabBarController.view];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //NSLog(@"Pressed tab bar");
    //[viewController viewWillAppear:NO];
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
