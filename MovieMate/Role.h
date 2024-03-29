//
//  Role.h
//  MovieMate
//
//  Created by Dean Andreakis on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Actor;

@interface Role : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Actor *actor;

@end
