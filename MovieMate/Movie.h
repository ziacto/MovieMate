//
//  Movie.h
//  MovieMate
//
//  Created by Dean Andreakis on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Actor;

@interface Movie : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * mpaa_rating;
@property (nonatomic, retain) NSNumber * critics_score;
@property (nonatomic, retain) NSString * synopsis;
@property (nonatomic, retain) NSNumber * runtime;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * alternate;
@property (nonatomic, retain) NSString * thumbnailFile;
@property (nonatomic, retain) NSString * profileFile;
@property (nonatomic, retain) NSSet *actor;
@end

@interface Movie (CoreDataGeneratedAccessors)

- (void)addActorObject:(Actor *)value;
- (void)removeActorObject:(Actor *)value;
- (void)addActor:(NSSet *)values;
- (void)removeActor:(NSSet *)values;

@end
