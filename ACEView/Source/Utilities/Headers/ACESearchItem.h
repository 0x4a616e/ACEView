//
//  ACEObject.h
//  ACEView
//
//  Created by Jan Gassen on 10/01/15.
//  Copyright (c) 2015 Code of Interest. All rights reserved.
//

#ifndef ACEView_ACEObject_h
#define ACEView_ACEObject_h

@interface ACESearchItem : NSObject {
    NSInteger start_column;
    NSInteger start_row;
    NSInteger end_column;
    NSInteger end_row;
}

@property NSInteger start_column;
@property NSInteger start_row;
@property NSInteger end_column;
@property NSInteger end_row;

+ (NSArray*) fromString:(NSString*)text;

@end


#endif
