//
//  MasterViewController.h
//  MovieMate
//
//  Created by Dean Andreakis on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define TITLELABEL_TAG 1
#define POSTER_TAG 2
#define RATING_TAG 3
#define CRITICSSCORE_TAG 4

//These are in points, not pixels so we don't have to do anything special for retina vs normal 
#define ROW_HEIGHT 91
#define ROW_WIDTH 320
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define TITLE_X 66
#define TITLE_Y 20
#define TITLE_WIDTH 180
#define TITLE_HEIGHT 24

#define RATING_X 251
#define RATING_Y 27
#define RATING_WIDTH_NC17_PG13 44
#define RATING_WIDTH_G 17
#define RATING_WIDTH_PG 27
#define RATING_WIDTH_R 18
#define RATING_HEIGHT 15

#define TITLE_RATING_SPACER 5

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
