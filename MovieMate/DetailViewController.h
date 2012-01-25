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

#define SYNOPSISTEXT_X 5
#define SYNOPSISTEXT_Y 295
#define SYNOPSISTEXT_WIDTH 310
#define SYNOPSISTEXT_HEIGHT 100

#define CASTLABEL_X 5
#define CASTLABEL_Y 395
#define CASTLABEL_WIDTH 250
#define CASTLABEL_HEIGHT 16

#define CASTTEXT_X 5
#define CASTTEXT_Y 412
#define CASTTEXT_WIDTH 310
#define CASTTEXT_HEIGHT 100

#define LINEVIEW_X 5
#define LINEVIEW_Y 535
#define LINEVIEW_WIDTH 305
#define LINEVIEW_HEIGHT 2

#define SUMMARYLABEL_X 10
#define SUMMARYLABEL_Y 545
#define SUMMARYLABEL_WIDTH 300
#define SUMMARYLABEL_HEIGHT 16


@interface DetailViewController : UIViewController
{
    Movie* movie;
}

@property (strong, nonatomic) Movie* movie;

@end
