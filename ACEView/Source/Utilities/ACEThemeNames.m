//
//  ACEModeNames.m
//  ACEView
//
//  Created by Michael Robinson on 2/12/12.
//  Copyright (c) 2012 Code of Interest. All rights reserved.
//

#import "ACEThemeNames.h"
#import "Headers/ACEResourceFinder.h"

@implementation ACEThemeNames

+ (NSArray *) themeNames {
    return [[[ACEResourceFinder defaultResources] themes] allValues];
}

+ (NSArray *) humanThemeNames {
    return [[[ACEResourceFinder defaultResources] themes] keysSortedByValueUsingSelector:@selector(compare:)];
}

+ (NSString *) humanNameForTheme:(NSString*) theme {
    return [[ACEResourceFinder defaultResources] humanize:theme];
}

+ (NSInteger) getIndexByName:(NSString*) name {
    NSArray* sortedKeys = [self humanThemeNames];
    NSDictionary* themes = [[ACEResourceFinder defaultResources] themes];
    
    for (NSInteger i = 0; i < [sortedKeys count]; i++) {
        NSString* key = [sortedKeys objectAtIndex:i];
        if ([[themes objectForKey:key] isEqualToString:name]) {
            return i;
        }
    }
    
    return -1;
}

+ (NSString*) getNameByIndex:(NSInteger)index {
    NSString* humanName = [[self humanThemeNames] objectAtIndex:index];
    return [[[ACEResourceFinder defaultResources] themes] objectForKey:humanName];
}

+ (BOOL) isDarkTheme:(NSString*)name {
    return [name isEqualToString:@"ambiance"] ||
            [name isEqualToString:@"chaos"] ||
            [name isEqualToString:@"clouds_midnight"] ||
            [name isEqualToString:@"cobalt"] ||
            [name isEqualToString:@"idle_fingers"] ||
            [name isEqualToString:@"kr_theme"] ||
            [name isEqualToString:@"merbivore"] ||
            [name isEqualToString:@"merbivore_soft"] ||
            [name isEqualToString:@"mono_industrial"] ||
            [name isEqualToString:@"monokai"] ||
            [name isEqualToString:@"pastel_on_dark"] ||
            [name isEqualToString:@"solarized_dark"] ||
            [name isEqualToString:@"terminal"] ||
            [name isEqualToString:@"tomorrow_night"] ||
            [name isEqualToString:@"tomorrow_night_blue"] ||
            [name isEqualToString:@"tomorrow_night_bright"] ||
            [name isEqualToString:@"tomorrow_night_eighties"] ||
            [name isEqualToString:@"twilight"] || 
            [name isEqualToString:@"vibrant_ink"];
}

@end
