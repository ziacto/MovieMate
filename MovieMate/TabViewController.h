//
//  TabViewController.h
//  MovieMate
//
//  Created by Dean Andreakis on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabViewController : UIViewController <UITabBarControllerDelegate>

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UINavigationController *navigationControllerFavorite;
@property (strong, nonatomic) UITabBarController *tabBarController;
@end
