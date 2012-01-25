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
        
//        dispatch_async(kImageQueue, ^{
//            //Go get and save the images for offline viewing
//            
//            //get list of document directories in sandbox 
//            NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            //get one and only document directory from that list
//            NSString *appDir = [documentDirectories objectAtIndex: 0];
//            
//            NSData *rawImageData = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.thumbnail]]];
//            UIImage *image = [[UIImage alloc] initWithData:rawImageData];
//            NSData *dataImage = [NSData dataWithData:UIImagePNGRepresentation(image)];
//            NSMutableString* fileName = [[NSMutableString alloc] initWithCapacity:10];
//            [fileName appendString:@"thumbnail"];
//            [fileName appendString:movie.title];
//            [fileName appendString:@".png"];
//            NSString* myFilePath = [NSString stringWithFormat:@"%@/%@",appDir,fileName];
//            [dataImage writeToFile:myFilePath atomically:YES];
//            movie.thumbnailFile = myFilePath;
//            
//            NSData *rawImageData2 = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.profile]]];
//            UIImage *image2 = [[UIImage alloc] initWithData:rawImageData2];
//            NSData *dataImage2 = [NSData dataWithData:UIImagePNGRepresentation(image2)];
//            NSMutableString* fileName2 = [[NSMutableString alloc] initWithCapacity:10];
//            [fileName2 appendString:@"profile"];
//            [fileName2 appendString:movie.title];
//            [fileName2 appendString:@".png"];
//            NSString* myFilePath2 = [NSString stringWithFormat:@"%@/%@",appDir,fileName2];
//            [dataImage2 writeToFile:myFilePath2 atomically:YES];
//            movie.profileFile = myFilePath2;
//        });        
    }
    else
    {
        movie.favorite = [NSNumber numberWithBool:false];
        [starView setImage:nil];
    }
    
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        
        
    }
}

- (void)configureView
{
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.tag = SCROLLVIEW_TAG;
    [scrollView setContentSize:CGSizeMake(320, 800)];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    //[scrollView setContentOffset:CGPointMake(0,0) animated:NO];
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
    
    UILabel* synopsisText = [[UILabel alloc] initWithFrame:CGRectMake(SYNOPSISTEXT_X, SYNOPSISTEXT_Y, SYNOPSISTEXT_WIDTH, SYNOPSISTEXT_HEIGHT)];
    synopsisText.tag = SYNOPSISTEXT_TAG;
    synopsisText.font = [UIFont systemFontOfSize:12.0];
    synopsisText.textAlignment = UITextAlignmentLeft;
    synopsisText.textColor = [UIColor blackColor];
    synopsisText.lineBreakMode = UILineBreakModeWordWrap;
    synopsisText.numberOfLines = 0;
    [scrollView addSubview:synopsisText];
    
    UILabel* castLabel = [[UILabel alloc] initWithFrame:CGRectMake(CASTLABEL_X, CASTLABEL_Y, CASTLABEL_WIDTH, CASTLABEL_HEIGHT)];
    castLabel.tag = CASTLABEL_TAG;
    castLabel.font = [UIFont boldSystemFontOfSize:14.0];
    castLabel.textAlignment = UITextAlignmentLeft;
    castLabel.textColor = [UIColor blackColor];
    castLabel.text = @"Cast";
    [scrollView addSubview:castLabel];
    
    UILabel* castText = [[UILabel alloc] initWithFrame:CGRectMake(CASTTEXT_X, CASTTEXT_Y, CASTTEXT_WIDTH, CASTTEXT_HEIGHT)];
    castText.tag = CASTTEXT_TAG;
    castText.font = [UIFont systemFontOfSize:12.0];
    castText.textAlignment = UITextAlignmentLeft;
    castText.textColor = [UIColor blackColor];
    castText.lineBreakMode = UILineBreakModeWordWrap;
    castText.numberOfLines = 0;
    [scrollView addSubview:castText];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(LINEVIEW_X, LINEVIEW_Y, LINEVIEW_WIDTH, LINEVIEW_HEIGHT)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.tag = DIVIDER_TAG;
    [scrollView addSubview:lineView];
    
    UILabel* summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(SUMMARYLABEL_X, SUMMARYLABEL_Y, SUMMARYLABEL_WIDTH, SUMMARYLABEL_HEIGHT)];
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
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(tweeter)];
    //[[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(tweeter)];
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
    UILabel* synopsisText = (UILabel *)[scrollView viewWithTag:SYNOPSISTEXT_TAG];
    UILabel* castLabel = (UILabel*)[scrollView viewWithTag:CASTLABEL_TAG];
    UILabel* castText = (UILabel *)[scrollView viewWithTag:CASTTEXT_TAG];
    UILabel* summaryLabel = (UILabel *)[scrollView viewWithTag:SUMMARYLABEL_TAG];
    UIImageView* starView = (UIImageView*)[scrollView viewWithTag:GOLDSTAR_TAG];
    UIView* lineView = (UIView*)[scrollView viewWithTag:DIVIDER_TAG];
    UIImage *posterImage;
    
    //if([movie.favorite boolValue] == NO)
    //{
      //  posterImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.profile]]];   
    //}
    //else
    //{
        posterImage = [UIImage imageWithContentsOfFile:movie.profileFile];
    //}
    
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
    
    CGSize constraintSize = CGSizeMake(SYNOPSISTEXT_WIDTH, 800);
    CGSize stringSize = [movie.synopsis sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    synopsisText.frame = CGRectMake(SYNOPSISTEXT_X, SYNOPSISTEXT_Y, SYNOPSISTEXT_WIDTH, stringSize.height);
    synopsisText.text = movie.synopsis;
    
    castLabel.frame = CGRectMake(CASTLABEL_X, SYNOPSISTEXT_Y + stringSize.height + 5, CASTLABEL_WIDTH, CASTLABEL_HEIGHT);
    
    NSMutableString* castString = [[NSMutableString alloc] initWithCapacity:10];
    for (Actor* actor in movie.actor) {
        for (Role* role in actor.role) {
            [castString appendString:actor.name];
            [castString appendString:@" as "];
            [castString appendString:role.name];
            [castString appendString:@"\n"];
        }
    }
    CGSize ctstringSize = [castString sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    castText.frame = CGRectMake(CASTTEXT_X, SYNOPSISTEXT_Y + stringSize.height + 5 + CASTLABEL_HEIGHT + 5, CASTTEXT_WIDTH, ctstringSize.height);
    castText.text = castString;
    
    lineView.frame = CGRectMake(LINEVIEW_X, SYNOPSISTEXT_Y + stringSize.height + 5 + CASTLABEL_HEIGHT + 5 + ctstringSize.height + 5, LINEVIEW_WIDTH, LINEVIEW_HEIGHT);
    
    NSMutableString* summaryString = [[NSMutableString alloc] initWithCapacity:10];
    [summaryString appendString:@"Rated "];
    [summaryString appendString:movie.mpaa_rating];
    [summaryString appendString:@" Freshness: "];
    [summaryString appendFormat:@"%d", [movie.critics_score intValue]];
    [summaryString appendString:@"% "];
    [summaryString appendFormat:@"Runtime: %dhr %dmin", [movie.runtime intValue]/60, [movie.runtime intValue]%60];
    CGSize slstringSize = [summaryString sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    summaryLabel.frame = CGRectMake(SUMMARYLABEL_X, SYNOPSISTEXT_Y + stringSize.height + 5 + CASTLABEL_HEIGHT + 5 + ctstringSize.height + 5 + LINEVIEW_HEIGHT + 5, SUMMARYLABEL_WIDTH, slstringSize.height);
    summaryLabel.text = summaryString;
    
    self.navigationItem.title = movie.title;
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    tlabel.minimumFontSize = 18;
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
