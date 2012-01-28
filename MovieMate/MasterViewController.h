//
//  MasterViewController.h
//  MovieMate
//
//  Created by Dean Andreakis on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kRottenTomatoesURL [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=uh7c6g5u3j5sew9dfafhtx8w"]
#define RTHOSTNAME @"www.rottentomatoes.com"

#define TITLELABEL_TAG 1
#define POSTER_TAG 2
#define RATING_TAG 3
#define CRITICSSCORE_TAG 4
#define TABITEM_TAG 5

//These are in points, not pixels so we don't have to do anything special for retina vs normal 
#define ROW_HEIGHT 91
#define ROW_WIDTH 320
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define TITLE_X 66
#define TITLE_Y 20
#define TITLE_WIDTH 160
#define TITLE_HEIGHT 30

#define RATING_X 251
#define RATING_Y 30
#define RATING_WIDTH_NC17_PG13 44
#define RATING_WIDTH_G 17
#define RATING_WIDTH_PG 27
#define RATING_WIDTH_R 18
#define RATING_HEIGHT 15

#define TITLE_RATING_SPACER 5

#define SECTION_TOP_TEN 0
#define SECTION_FAVORITES 1

#define NUM_IN_LIST 10

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>
#import "URLConnectionManager.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, URLConnectionManagerDelegate>
{
    BOOL rowcolorState;
    int stopIndicator;
    UIActivityIndicatorView* theActivityIndicator;
    URLConnectionManager* urlConnectionManager;
    NSURLRequest *theRequest;
}

@property (strong, nonatomic) NSURLRequest* theRequest;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) URLConnectionManager* urlConnectionManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
