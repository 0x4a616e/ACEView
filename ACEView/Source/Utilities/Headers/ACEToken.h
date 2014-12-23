//
//  ACEToken.h
//  ACEView
//
//  Created by Jan Gassen on 23/12/14.
//  Copyright (c) 2014 Code of Interest. All rights reserved.
//

#ifndef ACEView_ACEToken_h
#define ACEView_ACEToken_h

@interface ACEToken : NSObject {
    int index;
    int start;
    
    NSString *type;
    NSString *value;
}

@property int index;
@property int start;
@property(retain) NSString *type;
@property(retain) NSString *value;

+ (NSArray*) fromString:(NSString*)text;

@end


#endif
