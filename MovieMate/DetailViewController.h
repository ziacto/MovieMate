//
//  DetailViewController.h
//  MovieMate
//
//  Created by Dean Andreakis on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"
#import "Actor.h"
#import "Role.h"

#define IMAGE_TAG 0
#define SYNOPSISLABEL_TAG 1
#define SYNOPSISTEXT_TAG 2
#define CASTLABEL_TAG 3
#define CASTTEXT_TAG 4
#define DIVIDER_TAG 5
#define SUMMARYLABEL_TAG 6
#define SCROLLVIEW_TAG 7
#define FAVORITE_TAG 8
#define GOLDSTAR_TAG 9

#define kImageQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface DetailViewController : UIViewController
{
    Movie* movie;
}

@property (strong, nonatomic) Movie* movie;

@end
