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

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"MovieMate", @"MovieMate");
    }
    return self;
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
    // Set up the edit and add buttons.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [self.tableView setRowHeight:ROW_HEIGHT];
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
    [self.tableView reloadData];
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
    UILabel* titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLELABEL_TAG];
    
    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:UIColorFromRGB(0xF2F2F2)];
        titleLabel.backgroundColor = UIColorFromRGB(0xF2F2F2);
    }
    else 
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        titleLabel.backgroundColor = [UIColor whiteColor];
    }
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
        
        criticsScore = [[UIProgressView alloc] initWithFrame:CGRectMake(66, 50, 210, 15)];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == SECTION_TOP_TEN)
        return @"Top Ten Box Office Earning Movies";
    else
        return @"Favorites";
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
    //NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"favorite" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"favorite" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
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

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView* poster = (UIImageView *)[cell.contentView viewWithTag:POSTER_TAG];
    UILabel* titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLELABEL_TAG];
    UIProgressView* criticsScore = (UIProgressView *)[cell.contentView viewWithTag:CRITICSSCORE_TAG];
    UIImageView* rating = (UIImageView *)[cell.contentView viewWithTag:RATING_TAG];    
    
    Movie *movie = (Movie*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    titleLabel.text = movie.title;
    
    //used to position rating image 5 points past end of title string
    CGFloat actualSize = 24.0f;
    CGSize stringSize = [titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:24] minFontSize:14 actualFontSize:&actualSize forWidth:TITLE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
    
    [criticsScore setProgress:[movie.critics_score doubleValue]/100.0];
    
    //example if rating is equal to "G"
    NSString *pathToRatingG = [[NSBundle mainBundle] pathForResource:@"g" ofType:@"png"];
    UIImage* imageG = [[UIImage alloc] initWithContentsOfFile:pathToRatingG];
    rating.frame = CGRectMake(TITLE_X + stringSize.width + TITLE_RATING_SPACER, RATING_Y, RATING_WIDTH_G, RATING_HEIGHT);
    [rating setImage:imageG];
    
    UIImage *posterImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.thumbnail]]];
    [poster setImage:posterImage];
}

- (void)insertNewObject
{
     //Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    Movie *newMovie = [NSEntityDescription insertNewObjectForEntityForName:[entity name] 
                                                                      inManagedObjectContext: context];
    
    newMovie.title = @"Harry Potter and the Silly Boofer";
    newMovie.mpaa_rating = @"PG-13";
    newMovie.critics_score = [NSNumber numberWithInt:93];
    newMovie.synopsis = @"Harry Potter and the Deathly Hallows - Part 2, is the final adventure in the Harry Potter film series. The much-anticipated motion picture event is the second of two full-length parts. In the epic finale, the battle between the good and evil forces of the wizarding world escalates into an all-out war. The stakes have never been higher and no one is safe. But it is Harry Potter who may be called upon to make the ultimate sacrifice as he draws closer to the climactic showdown with Lord Voldemort. It all ends here. -- (C) Warner Bros";
    newMovie.runtime = [NSNumber numberWithInt:133];
    newMovie.thumbnail = @"http://content9.flixster.com/movie/11/16/11/11161107_mob.jpg";
    newMovie.profile = @"http://content9.flixster.com/movie/11/16/11/11161107_det.jpg";
    newMovie.favorite = [NSNumber numberWithBool:false];
    
    Role* role1;
    role1 = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:context];
    role1.name = @"Ethan Hunt";
    
    Actor* actor1;
    actor1 = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:context];
    actor1.name = @"Tom Cruise";
    [actor1 addRoleObject:role1];
    
    Role* role2;
    role2 = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:context];
    role2.name = @"Bad President";
    
    Actor* actor2;
    actor2 = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:context];
    actor2.name = @"Bill Clinton";
    [actor2 addRoleObject:role2];
    
    Role* role3;
    role3 = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:context];
    role3.name = @"Weird Guy";
    
    Actor* actor3;
    actor3 = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:context];
    actor3.name = @"Jason Fried";
    [actor3 addRoleObject:role3];
    
    Role* role4;
    role4 = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:context];
    role4.name = @"Bad Guy";
    
    Actor* actor4;
    actor4 = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:context];
    actor4.name = @"Joe Schmo";
    [actor4 addRoleObject:role4];
    
    Role* role5;
    role5 = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:context];
    role5.name = @"Talk Show Hostess";
    
    Actor* actor5;
    actor5 = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:context];
    actor5.name = @"Oprah Winfrey";
    [actor5 addRoleObject:role5];
    
    [newMovie addActorObject:actor1];
    [newMovie addActorObject:actor2];
    [newMovie addActorObject:actor3];
    [newMovie addActorObject:actor4];
    [newMovie addActorObject:actor5];
    
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        
         //Replace this implementation with code to handle the error appropriately.
         
        abort();// causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
