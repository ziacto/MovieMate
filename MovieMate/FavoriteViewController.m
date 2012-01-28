//
//  FavoriteViewController.m
//  MovieMate
//
//  Created by Dean Andreakis on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoriteViewController.h"
#import "Movie.h"
#import "DetailViewController.h"
#import "DatabaseManager.h"
#import "MasterViewController.h"

@interface FavoriteViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FavoriteViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Favorites", @"Favorites");
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:FAVTABITEM_TAG];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView setRowHeight:ROW_HEIGHT];
    rowcolorState = FALSE;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]];
    [fetchRequest setPredicate:fetchPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Favorite"];
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
