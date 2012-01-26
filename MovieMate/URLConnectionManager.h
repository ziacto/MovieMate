//
//  URLConnectionManager.h
//  MovieMate
//
//  Created by Dean Andreakis on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol URLConnectionManagerDelegate
-(void)urlData:(NSData*)responseData;
@end

@interface URLConnectionManager : NSObject
{
    NSMutableData* responseData;
    id delegate;
}

@property (strong, nonatomic) NSMutableData* responseData;
@property (strong, nonatomic) id <URLConnectionManagerDelegate> delegate;
@end
