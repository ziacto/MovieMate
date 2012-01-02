//
//  DetailViewController.m
//  MovieMate
//
//  Created by Dean Andreakis on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "DatabaseManager.h"
#import <Twitter/Twitter.h>

@interface DetailViewController ()
- (void)configureView;
- (void)tweeter;
- (void)buttonClicked:(id)sender;
@end

@implementation DetailViewController

@synthesize movie;

#pragma mark - Managing the detail item
- (void)tweeter
{
    // Create the view controller
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    // Optional: set an image, url and initial text
    [twitter setInitialText:@"Tweet from MovieMate: "];
    //Lets shorten the URL to insure it fits
    NSString* longURL = movie.alternate;
    NSString* format = @"http://tinyurl.com/api-create.php?url=%@";
    NSString* apiEndpoint = [NSString stringWithFormat:format,longURL];
    NSString* shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint] encoding:NSASCIIStringEncoding error:nil];
    [twitter addURL:[NSURL URLWithString:[NSString stringWithString:shortURL]]];
    
    // Show the controller
    [self presentModalViewController:twitter animated:YES];
    
    // Called when the tweet dialog has been closed
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        NSString *title = @"Tweet Status";
        NSString *msg; 
        
        if (result == TWTweetComposeViewControllerResultCancelled)
            msg = @"Tweet compostion was canceled.";
        else if (result == TWTweetComposeViewControllerResultDone)
            msg = @"Tweet composition completed.";
        
        // Show alert to see how things went...
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        
        // Dismiss the controller
        [self dismissModalViewControllerAnimated:YES];
    };
}

- (void)buttonClicked:(id)sender
{
    UIScrollView* scrollView = (UIScrollView *)[self.view viewWithTag:SCROLLVIEW_TAG];
    UIImageView* starView = (UIImageView*)[scrollView viewWithTag:GOLDSTAR_TAG];
    
    NSManagedObjectContext *context = [[DatabaseManager sharedDatabaseManager] managedObjectContext];
    if([movie.favorite boolValue] == NO)
    {
        movie.favorite = [NSNumber numberWithBool:true];
        NSString *pathToStar = [[NSBundle mainBundle] pathForResource:@"goldstar" ofType:@"png"];
        UIImage* starImage = [[UIImage alloc] initWithContentsOfFile:pathToStar];
        [starView setImage:starImage];
        
        dispatch_async(kImageQueue, ^{
            //Go get and save the images for offline viewing
            
            //get list of document directories in sandbox 
            NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //get one and only document directory from that list
            NSString *appDir = [documentDirectories objectAtIndex: 0];
            
            NSData *rawImageData = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.thumbnail]]];
            UIImage *image = [[UIImage alloc] initWithData:rawImageData];
            NSData *dataImage = [NSData dataWithData:UIImagePNGRepresentation(image)];
            NSMutableString* fileName = [[NSMutableString alloc] initWithCapacity:10];
            [fileName appendString:@"thumbnail"];
            [fileName appendString:movie.title];
            [fileName appendString:@".png"];
            NSString* myFilePath = [NSString stringWithFormat:@"%@/%@",appDir,fileName];
            [dataImage writeToFile:myFilePath atomically:YES];
            movie.thumbnailFile = myFilePath;
            
            NSData *rawImageData2 = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.profile]]];
            UIImage *image2 = [[UIImage alloc] initWithData:rawImageData2];
            NSData *dataImage2 = [NSData dataWithData:UIImagePNGRepresentation(image2)];
            NSMutableString* fileName2 = [[NSMutableString alloc] initWithCapacity:10];
            [fileName2 appendString:@"profile"];
            [fileName2 appendString:movie.title];
            [fileName2 appendString:@".png"];
            NSString* myFilePath2 = [NSString stringWithFormat:@"%@/%@",appDir,fileName2];
            [dataImage2 writeToFile:myFilePath2 atomically:YES];
            movie.profileFile = myFilePath2;
        });        
    }
    else
    {
        movie.favorite = [NSNumber numberWithBool:false];
        [starView setImage:nil];
    }
    
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        
        //Replace this implementation with code to handle the error appropriately.
        
        abort();// causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)configureView
{
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.tag = SCROLLVIEW_TAG;
    [scrollView setContentSize:CGSizeMake(320, 570)];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:scrollView];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 5, 180, 267)];
    imageView.tag = IMAGE_TAG;
    [scrollView addSubview:imageView];
    
    UIButton* favoriteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    favoriteButton.frame = CGRectMake(245, 5, 63, 44);
    favoriteButton.tag = FAVORITE_TAG;
    [favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
    [favoriteButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:favoriteButton];
    
    UIImageView* starView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 50, 30, 30)];
    starView.tag = GOLDSTAR_TAG;
    [scrollView addSubview:starView];
    
    UILabel* synopsisLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 275, 250, 16)];
    synopsisLabel.tag = SYNOPSISLABEL_TAG;
    synopsisLabel.font = [UIFont boldSystemFontOfSize:14.0];
    synopsisLabel.textAlignment = UITextAlignmentLeft;
    synopsisLabel.textColor = [UIColor blackColor];
    synopsisLabel.text = @"Synopsis";
    [scrollView addSubview:synopsisLabel];
    
    UITextView* synopsisText = [[UITextView alloc] initWithFrame:CGRectMake(5, 290, 310, 100)];
    synopsisText.tag = SYNOPSISTEXT_TAG;
    synopsisText.font = [UIFont systemFontOfSize:12.0];
    synopsisText.textAlignment = UITextAlignmentLeft;
    synopsisText.textColor = [UIColor blackColor];
    synopsisText.editable = NO;
    [scrollView addSubview:synopsisText];
    
    UILabel* castLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 395, 250, 16)];
    castLabel.tag = CASTLABEL_TAG;
    castLabel.font = [UIFont boldSystemFontOfSize:14.0];
    castLabel.textAlignment = UITextAlignmentLeft;
    castLabel.textColor = [UIColor blackColor];
    castLabel.text = @"Cast";
    [scrollView addSubview:castLabel];
    
    UITextView* castText = [[UITextView alloc] initWithFrame:CGRectMake(5, 412, 310, 100)];
    castText.tag = CASTTEXT_TAG;
    castText.font = [UIFont systemFontOfSize:12.0];
    castText.textAlignment = UITextAlignmentLeft;
    castText.textColor = [UIColor blackColor];
    castText.editable = NO;
    [scrollView addSubview:castText];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, 535, 305, 2)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.tag = DIVIDER_TAG;
    [scrollView addSubview:lineView];
    
    UILabel* summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 545, 300, 16)];
    summaryLabel.tag = SUMMARYLABEL_TAG;
    summaryLabel.font = [UIFont systemFontOfSize:13.0];
    summaryLabel.textAlignment = UITextAlignmentLeft;
    summaryLabel.textColor = [UIColor blackColor];
    [scrollView addSubview:summaryLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(tweeter)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIScrollView* scrollView = (UIScrollView *)[self.view viewWithTag:SCROLLVIEW_TAG];
    UIImageView* imageView = (UIImageView *)[scrollView viewWithTag:IMAGE_TAG];
    UITextView* synopsisText = (UITextView *)[scrollView viewWithTag:SYNOPSISTEXT_TAG];
    UITextView* castText = (UITextView *)[scrollView viewWithTag:CASTTEXT_TAG];
    UILabel* summaryLabel = (UILabel *)[scrollView viewWithTag:SUMMARYLABEL_TAG];
    UIImageView* starView = (UIImageView*)[scrollView viewWithTag:GOLDSTAR_TAG];
    UIImage *posterImage;
    
    if([movie.favorite boolValue] == NO)
    {
        posterImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.profile]]];   
    }
    else
    {
        posterImage = [UIImage imageWithContentsOfFile:movie.profileFile];
    }
    
    [imageView setImage:posterImage];
    
    if([movie.favorite boolValue] == YES)
    {
        NSString *pathToStar = [[NSBundle mainBundle] pathForResource:@"goldstar" ofType:@"png"];
        UIImage* starImage = [[UIImage alloc] initWithContentsOfFile:pathToStar];
        [starView setImage:starImage];
    }
    else
    {
        [starView setImage:nil];
    }
    
    synopsisText.text = movie.synopsis;
    
    NSMutableString* castString = [[NSMutableString alloc] initWithCapacity:10];
    for (Actor* actor in movie.actor) {
        for (Role* role in actor.role) {
            [castString appendString:actor.name];
            [castString appendString:@" as "];
            [castString appendString:role.name];
            [castString appendString:@"\n"];
        }
    }
    castText.text = castString;
    
    NSMutableString* summaryString = [[NSMutableString alloc] initWithCapacity:10];
    [summaryString appendString:@"Rated "];
    [summaryString appendString:movie.mpaa_rating];
    [summaryString appendString:@" Freshness: "];
    [summaryString appendFormat:@"%d", [movie.critics_score intValue]];
    [summaryString appendString:@"% "];
    [summaryString appendFormat:@"Runtime: %dhr %dmin", [movie.runtime intValue]/60, [movie.runtime intValue]%60];
    summaryLabel.text = summaryString;
    
    self.navigationItem.title = movie.title;
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    tlabel.minimumFontSize = 14;
    self.navigationItem.titleView=tlabel;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
@end
