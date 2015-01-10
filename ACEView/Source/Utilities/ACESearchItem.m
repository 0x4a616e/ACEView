//
//  ACEObject.m
//  ACEView
//
//  Created by Jan Gassen on 10/01/15.
//  Copyright (c) 2015 Code of Interest. All rights reserved.
//

#import <ACESearchItem.h>

@interface ACESearchItem()
+ (ACESearchItem*) convertSingleObject:(NSDictionary*) data;
+ (NSMutableArray *)convertMultipleObjects:(NSArray*)object;
@end

@implementation ACESearchItem

@synthesize start_column, start_row, end_column, end_row;

+ (NSArray*) fromString:(NSString*)text {
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:[text dataUsingEncoding:NSUTF8StringEncoding]
                 options:0
                 error:&error];
    
    if(!error && [object isKindOfClass:[NSArray class]]) {
        return [self convertMultipleObjects:object];
    }
    
    return nil;
}

+ (NSMutableArray *)convertMultipleObjects:(NSArray*)list {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id item in list) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            [result addObject:[ACESearchItem convertSingleObject:item]];
        }
    }
    return result;
}

+ (ACESearchItem*) convertSingleObject:(NSDictionary*) data {
    ACESearchItem* result = [[ACESearchItem alloc] init];
    
    NSDictionary* start = [data objectForKey:@"start"];
    if (start != nil) {
        [result setStart_row:[ACESearchItem getInt:start key:@"row"]];
        [result setStart_column:[ACESearchItem getInt:start key:@"column"]];
    }
    
    NSDictionary* end = [data objectForKey:@"end"];
    if (end != nil) {
        [result setEnd_row:[ACESearchItem getInt:end key:@"row"]];
        [result setEnd_column:[ACESearchItem getInt:end key:@"column"]];
    }
    
    return result;
}

+ (NSInteger) getInt:(NSDictionary*) dict key:(NSString*)key {
    id val = [dict objectForKey:key];
    if (val) {
        return [val integerValue];
    }
    return 0;
}

@end