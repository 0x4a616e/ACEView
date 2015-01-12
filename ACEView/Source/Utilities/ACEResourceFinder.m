//
//  ACEResourceFinder.m
//  ACEView
//
//  Created by Jan Gassen on 03/01/15.
//  Copyright (c) 2015 Code of Interest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Headers/ACEResourceFinder.h"

@interface ACEResourceFinder ()
    -(NSDictionary*) resourceMapForPrefix:(NSString*) prefix;
    -(NSArray*) resourceNamesForPrefix:(NSString*)prefix;
    -(NSArray*) resourcesWithPrefix:(NSString*)prefix;
    -(NSArray*) loadResources;

    -(NSDictionary*) getNameOverrides;
@end

@implementation ACEResourceFinder

@synthesize resources, modes, themes, name_overrides;

- (NSDictionary *)resourceMapForPrefix:(NSString *)prefix {
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    NSArray* resourceNames = [self resourceNamesForPrefix:prefix];
    for (NSString* resourceName in resourceNames) {
        [result setObject:resourceName forKey:[self humanize:resourceName]];
    }
    
    return [result copy];
}

-(NSString*)humanize:(NSString *)value {
    NSString* override = [[self name_overrides] objectForKey:value];
    if (override != nil) {
        return override;
    }
    
    return [[value stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
}

-(NSArray*) resourceNamesForPrefix:(NSString*)prefix {
    NSArray* resourceNames = [self resourcesWithPrefix:prefix];
    
    NSMutableArray *resultBuilder = [NSMutableArray arrayWithCapacity:[resourceNames count]];
    for (NSUInteger i = 0; i < [resourceNames count]; i++) {
        [resultBuilder insertObject:[[resourceNames objectAtIndex:i] substringFromIndex:[prefix length]] atIndex:i];
    }
    
    return [resultBuilder copy];
}

-(NSArray*) resourcesWithPrefix:(NSString*)prefix {
    return [resources filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", prefix]];
}

-(NSArray*) loadResources {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSArray* paths = [bundle pathsForResourcesOfType:@".js" inDirectory:@"Resources"];
    
    NSMutableArray *resultBuilder = [NSMutableArray arrayWithCapacity:[paths count]];
    for (NSUInteger i = 0; i < [paths count]; i++) {
        [resultBuilder insertObject:[[[paths objectAtIndex:i] lastPathComponent] stringByDeletingPathExtension] atIndex:i];
    }
    
    return [resultBuilder copy];
}

-(NSDictionary*) getNameOverrides {
    NSDictionary* overrides = @{
                           @"c_cpp": @"C++",
                           @"javascript": @"JavaScript",
                           @"csharp": @"C#",
                           @"golang": @"Go",
                           @"objectivec": @"Objective-C",
                           @"ftl": @"FreeMarker",
                           @"sh": @"Shell"
                           };
    
    return [overrides copy];
}

- (id)init {
    if (self = [super init]) {
        name_overrides = [self getNameOverrides];

        resources = [self loadResources];
        modes = [self resourceMapForPrefix:@"mode-"];
        themes = [self resourceMapForPrefix:@"theme-"];
    }
    return self;
}

+(id)defaultResources {
    static ACEResourceFinder *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end