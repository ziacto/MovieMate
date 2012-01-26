//
//  URLConnectionManager.m
//  MovieMate
//
//  Created by Dean Andreakis on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "URLConnectionManager.h"

@implementation URLConnectionManager

@synthesize responseData;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        responseData = [NSMutableData data];
        
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Once this method is invoked, "responseData" contains the complete result
    [delegate urlData:responseData];
}


@end
