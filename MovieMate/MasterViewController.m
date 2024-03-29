//
//  MasterViewController.m
//  MovieMate
//
//  Created by Dean Andreakis on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "Movie.h"
#import "DetailViewController.h"
#import "DatabaseManager.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)fetchedData:(NSData *)responseData;
- (void)parseResponse:(NSArray *)topMovies;
- (void)refresher;
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
//@synthesize urlConnectionManager;
@synthesize theRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Top Earning Movies", @"Top Earning Movies");
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"clapboard" ofType:@"png"]];
        self.tabBarItem.title = @"Top Earners";
        //self.urlConnectionManager = [[URLConnectionManager alloc] init];
        //[self.urlConnectionManager setDelegate:self];
        
        self.theRequest = [NSURLRequest requestWithURL:kRottenTomatoesURL
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.0];
        connectionActive = FALSE;
    }
    return self;
}


-(void)urlData:(NSData*)responseData
{
    //the response data has been received from the URLConnectionManager object
    [[DatabaseManager sharedDatabaseManager] deleteUnfavoriteObjects];
    [self fetchedData:responseData];
}

-(void)urlError:(NSError *)errorData
{
    //the url connection manager has returned an error
    [theActivityIndicator stopAnimating];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
     message:[errorData localizedDescription]
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     
     [message show];
    connectionActive = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions 
                          error:&error];
    
    NSArray* topMovies = [json objectForKey:@"movies"];
    
    [self parseResponse:topMovies];
}

- (void)parseResponse:(NSArray *)topMovies
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    dispatch_async(kBgQueue, ^{
        for (int x=0; x<10; x++)//top ten movies 
        {
            NSDictionary* movie = [topMovies objectAtIndex:x];
            if([[DatabaseManager sharedDatabaseManager] compareMovieTitle:[movie objectForKey:@"title"]])
            {
                [context lock];
                Movie *newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" 
                                                                inManagedObjectContext: context];
                
                newMovie.title = [movie objectForKey:@"title"];
                //NSLog(@"Movie Titles: %@", newMovie.title);
                
                newMovie.mpaa_rating = [movie objectForKey:@"mpaa_rating"];
                
                newMovie.critics_score = [[movie objectForKey:@"ratings"] objectForKey:@"critics_score"];
                //NSLog(@"Critics Score: %@", newMovie.critics_score);
                
                newMovie.synopsis = [movie objectForKey:@"synopsis"];
                newMovie.runtime = [movie objectForKey:@"runtime"];
                
                newMovie.thumbnail = [[movie objectForKey:@"posters"] objectForKey:@"thumbnail"];
                newMovie.profile = [[movie objectForKey:@"posters"] objectForKey:@"detailed"];
                newMovie.alternate = [[movie objectForKey:@"links"] objectForKey:@"alternate"];
                
                newMovie.favorite = [NSNumber numberWithBool:false];
                newMovie.topten = [NSNumber numberWithBool:true];
                
                NSArray* ac = [movie objectForKey:@"abridged_cast"];
                //NSLog(@"abridged cast: %@", [ac description]);
                
                for (int y = 0; y < [ac count]; y++) {
                    Actor* actor = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:context];
                    NSDictionary* actorArray = [ac objectAtIndex:y];
                    //NSLog(@"Actor array: %@", [actorArray description]);
                    actor.name = [actorArray objectForKey:@"name"];
                    NSArray* roleArray = [actorArray objectForKey:@"characters"];
                    //NSLog(@"Role array: %@", [roleArray description]);
                    for (int z = 0; z < [roleArray count]; z++) {
                        Role* role = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:context];
                        role.name = [roleArray objectAtIndex:z];
                        [actor addRoleObject:role];
                    }
                    [newMovie addActorObject:actor];
                }
                //Go get and save the images for offline viewing
                
                //get list of document directories in sandbox 
                NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                //get one and only document directory from that list
                NSString *appDir = [documentDirectories objectAtIndex: 0];
                
                NSData *rawImageData = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newMovie.thumbnail]]];
                UIImage *image = [[UIImage alloc] initWithData:rawImageData];
                NSData *dataImage = [NSData dataWithData:UIImagePNGRepresentation(image)];
                NSMutableString* fileName = [[NSMutableString alloc] initWithCapacity:10];
                [fileName appendString:@"thumbnail"];
                [fileName appendString:newMovie.title];
                [fileName appendString:@".png"];
                NSString* myFilePath = [NSString stringWithFormat:@"%@/%@",appDir,fileName];
                [dataImage writeToFile:myFilePath atomically:YES];
                newMovie.thumbnailFile = myFilePath;
                
                NSData *rawImageData2 = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newMovie.profile]]];
                UIImage *image2 = [[UIImage alloc] initWithData:rawImageData2];
                NSData *dataImage2 = [NSData dataWithData:UIImagePNGRepresentation(image2)];
                NSMutableString* fileName2 = [[NSMutableString alloc] initWithCapacity:10];
                [fileName2 appendString:@"profile"];
                [fileName2 appendString:newMovie.title];
                [fileName2 appendString:@".png"];
                NSString* myFilePath2 = [NSString stringWithFormat:@"%@/%@",appDir,fileName2];
                [dataImage2 writeToFile:myFilePath2 atomically:YES];
                newMovie.profileFile = myFilePath2;
                [context unlock];
            }
        }
        
        [theActivityIndicator stopAnimating];
        connectionActive = FALSE;
        [context lock];
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
        }
        [context unlock];
    });
}

- (void)refresher
{
    if(!connectionActive)
    {
        [theActivityIndicator startAnimating];
        
        if ([URLConnectionManager internetReachable] )
        {
            if([URLConnectionManager hostReachable:RTHOSTNAME])
            {
                URLConnectionManager* urlConnectionManager = [[URLConnectionManager alloc] init];
                [urlConnectionManager setDelegate:self];
                NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.theRequest delegate:urlConnectionManager];
                if(theConnection == nil)
                {
                    [theActivityIndicator stopAnimating];
                    // Inform the user that the connection failed.
                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                      message:@"Connection cannot be initialized"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                    
                    [message show];
                }
                else
                {
                    connectionActive = TRUE;
                }
            }
            else
            {
                [theActivityIndicator stopAnimating];
                // Inform the user that the connection failed.
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                  message:@"Host Not Available"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                
                [message show];
            }
        }
        else
        {
            [theActivityIndicator stopAnimating];
            // Inform the user that the connection failed.
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                              message:@"No Internet Connection Available"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            
            [message show];   
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.tableView setRowHeight:ROW_HEIGHT];
    //stopIndicator = 0;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresher)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //go get the JSON data from Rotten Tomatoes and do it on a background thread
    theActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:theActivityIndicator];
    theActivityIndicator.center = CGPointMake(160, 200);
	theActivityIndicator.hidesWhenStopped = YES;
    [self refresher];
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retVal = [[self.fetchedResultsController sections] count];
    return retVal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//Highlight the alternating rows
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UILabel *titleLabel;
    UIImageView *poster, *rating;
    UIProgressView *criticsScore;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.frame = CGRectMake(0, 0, ROW_WIDTH, ROW_HEIGHT);
        
        poster = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 91)];
        poster.tag = POSTER_TAG;
        poster.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:poster];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_X, TITLE_Y, TITLE_WIDTH, TITLE_HEIGHT)];
        titleLabel.tag = TITLELABEL_TAG;
        titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
        titleLabel.minimumFontSize = 14.0;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:titleLabel];
        
        criticsScore = [[UIProgressView alloc] initWithFrame:CGRectMake(66, 65, 210, 15)];
        criticsScore.tag = CRITICSSCORE_TAG;
        criticsScore.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:criticsScore];
        
        rating = [[UIImageView alloc] initWithFrame:CGRectMake(RATING_X, RATING_Y, RATING_WIDTH_NC17_PG13, RATING_HEIGHT)];
        rating.tag = RATING_TAG;
        rating.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:rating];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    
    [self.detailViewController setMovie:(Movie*)[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"critics_score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor,nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"topten == %@", [NSNumber numberWithBool: YES]];
    [fetchRequest setPredicate:fetchPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView* poster = (UIImageView *)[cell.contentView viewWithTag:POSTER_TAG];
    UILabel* titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLELABEL_TAG];
    UIProgressView* criticsScore = (UIProgressView *)[cell.contentView viewWithTag:CRITICSSCORE_TAG];
    UIImageView* rating = (UIImageView *)[cell.contentView viewWithTag:RATING_TAG];    
    UIImage *posterImage;
    
    Movie *movie = (Movie*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    titleLabel.text = movie.title;
    
    //used to position rating image 5 points past end of title string
    CGFloat actualSize = 24.0f;
    CGSize stringSize = [titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:24] minFontSize:14 actualFontSize:&actualSize forWidth:TITLE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    
    [criticsScore setProgress:[movie.critics_score doubleValue]/100.0];
    
    //example if rating is equal to "G"
    if([movie.mpaa_rating isEqualToString:@"G"])
    {
        NSString *pathToRatingG = [[NSBundle mainBundle] pathForResource:@"g" ofType:@"png"];
        UIImage* imageG = [[UIImage alloc] initWithContentsOfFile:pathToRatingG];
        rating.frame = CGRectMake(TITLE_X + stringSize.width + TITLE_RATING_SPACER, RATING_Y, RATING_WIDTH_G, RATING_HEIGHT);
        [rating setImage:imageG];
    }
    else if([movie.mpaa_rating isEqualToString:@"PG"])
    {
        NSString *pathToRatingG = [[NSBundle mainBundle] pathForResource:@"pg" ofType:@"png"];
        UIImage* imageG = [[UIImage alloc] initWithContentsOfFile:pathToRatingG];
        rating.frame = CGRectMake(TITLE_X + stringSize.width + TITLE_RATING_SPACER, RATING_Y, RATING_WIDTH_PG, RATING_HEIGHT);
        [rating setImage:imageG];
    }
    else if([movie.mpaa_rating isEqualToString:@"PG-13"])
    {
        NSString *pathToRatingG = [[NSBundle mainBundle] pathForResource:@"pg_13" ofType:@"png"];
        UIImage* imageG = [[UIImage alloc] initWithContentsOfFile:pathToRatingG];
        rating.frame = CGRectMake(TITLE_X + stringSize.width + TITLE_RATING_SPACER, RATING_Y, RATING_WIDTH_NC17_PG13, RATING_HEIGHT);
        [rating setImage:imageG];
    }
    else if([movie.mpaa_rating isEqualToString:@"R"])
    {
        NSString *pathToRatingG = [[NSBundle mainBundle] pathForResource:@"r" ofType:@"png"];
        UIImage* imageG = [[UIImage alloc] initWithContentsOfFile:pathToRatingG];
        rating.frame = CGRectMake(TITLE_X + stringSize.width + TITLE_RATING_SPACER, RATING_Y, RATING_WIDTH_R, RATING_HEIGHT);
        [rating setImage:imageG];
    }
    else if([movie.mpaa_rating isEqualToString:@"NC-17"])
    {
        NSString *pathToRatingG = [[NSBundle mainBundle] pathForResource:@"nc_17" ofType:@"png"];
        UIImage* imageG = [[UIImage alloc] initWithContentsOfFile:pathToRatingG];
        rating.frame = CGRectMake(TITLE_X + stringSize.width + TITLE_RATING_SPACER, RATING_Y, RATING_WIDTH_NC17_PG13, RATING_HEIGHT);
        [rating setImage:imageG];
    }
    
    posterImage = [UIImage imageWithContentsOfFile:movie.thumbnailFile];
    [poster setImage:posterImage];
}

@end
