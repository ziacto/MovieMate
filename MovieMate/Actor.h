//
//  Actor.h
//  MovieMate
//
//  Created by Dean Andreakis on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Movie, Role;

@interface Actor : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Movie *movie;
@property (nonatomic, retain) NSSet *role;
@end

@interface Actor (CoreDataGeneratedAccessors)

- (void)addRoleObject:(Role *)value;
- (void)removeRoleObject:(Role *)value;
- (void)addRole:(NSSet *)values;
- (void)removeRole:(NSSet *)values;

@end
