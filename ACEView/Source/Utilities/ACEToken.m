//
//  ACEToken.m
//  ACEView
//
//  Created by Jan Gassen on 23/12/14.
//  Copyright (c) 2014 Code of Interest. All rights reserved.
//

#import <ACEToken.h>

@interface ACEToken()
+ (ACEToken*) convertSingleObject:(NSDictionary*) data;
+ (NSMutableArray *)convertMultipleObjects:(NSArray*)object;
@end

@implementation ACEToken

@synthesize index, start, value, type;

+ (NSArray*) fromString:(NSString*)text {
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:[text dataUsingEncoding:NSUTF8StringEncoding]
                 options:0
                 error:&error];
    
    if(!error) {
        if([object isKindOfClass:[NSDictionary class]]) {
            return [NSArray arrayWithObject:[ACEToken convertSingleObject:object]];
        } else if ([object isKindOfClass:[NSArray class]]) {
            return [self convertMultipleObjects:object];
        }
    }
    
    return nil;
}

+ (NSMutableArray *)convertMultipleObjects:(NSArray*)list {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id item in list) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            [result addObject:[ACEToken convertSingleObject:item]];
        }
    }
    return result;
}

+ (ACEToken*) convertSingleObject:(NSDictionary*) data {
    ACEToken* result = [[ACEToken alloc] init];
    
    id start = [data objectForKey:@"start"];
    if (start != nil)
        [result setStart:start];
    
    id index = [data objectForKey:@"index"];
    if (start != nil)
        [result setIndex:index];
    
    [result setValue:[data objectForKey:@"value"]];
    [result setType:[data objectForKey:@"type"]];
    
    return result;
}

@end