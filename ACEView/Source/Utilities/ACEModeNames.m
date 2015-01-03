//
//  ACEModeNames.m
//  ACEView
//
//  Created by Michael Robinson on 2/12/12.
//  Copyright (c) 2012 Code of Interest. All rights reserved.
//

#import "ACEModeNames.h"
#import "Headers/ACEResourceFinder.h"

@implementation ACEModeNames

+ (NSArray *) modeNames {
    return [[[ACEResourceFinder defaultResources] modes] allValues];
}

+ (NSArray *) humanModeNames {
    return [[[ACEResourceFinder defaultResources] modes] keysSortedByValueUsingSelector:@selector(compare:)];
}

+ (NSString *) humanNameForMode:(NSString*)mode {    
    return [[ACEResourceFinder defaultResources] humanize:mode];
}

+ (NSString*) nameByHumanName:(NSString*)humanName {
    return [[[ACEResourceFinder defaultResources] modes] objectForKey:humanName];
}

+ (NSInteger) getIndexByName:(NSString*) name {
    NSArray* sortedKeys = [self humanModeNames];
    NSDictionary* themes = [[ACEResourceFinder defaultResources] modes];
    
    for (NSInteger i = 0; i < [sortedKeys count]; i++) {
        NSString* key = [sortedKeys objectAtIndex:i];
        if ([[themes objectForKey:key] isEqualToString:name]) {
            return i;
        }
    }
    
    return -1;
}

+ (NSString*) getNameByIndex:(NSInteger)index {
    NSString* humanName = [[self humanModeNames] objectAtIndex:index];
    return [[[ACEResourceFinder defaultResources] modes] objectForKey:humanName];
}

@end
