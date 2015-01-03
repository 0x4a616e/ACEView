//
//  ACEResourceFinder.h
//  ACEView
//
//  Created by Jan Gassen on 03/01/15.
//  Copyright (c) 2015 Code of Interest. All rights reserved.
//

#ifndef ACEView_ACEResourceFinder_h
#define ACEView_ACEResourceFinder_h

@interface ACEResourceFinder : NSObject {
    NSDictionary* themes;
    NSDictionary* modes;
    
    NSDictionary* name_overrides;
    
    NSArray* resources;
}

@property(retain,readonly) NSDictionary* themes;
@property(retain,readonly) NSDictionary* modes;

@property(retain,readonly) NSDictionary* name_overrides;

@property(retain,readonly) NSArray* resources;

-(NSString*) humanize:(NSString*)value;

+(id) defaultResources;

@end

#endif
