//
//  FavoriteViewController.h
//  MovieMate
//
//  Created by Dean Andreakis on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FAVTABITEM_TAG 0

@class DetailViewController;

@interface FavoriteViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    BOOL rowcolorState;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
