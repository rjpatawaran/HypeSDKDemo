//
//  NSDictionary+MutableDeepCopy.m
//  Pangolin
//
//  Created by RJ Patawaran on 11/4/13.
//  Copyright (c) 2013 Entropy. All rights reserved.
//

#import "NSDictionary+MutableDeepCopy.h"

@implementation NSDictionary (MutableDeepCopy)

-(NSMutableDictionary *)mutableDeepCopy {
    NSMutableDictionary *mself = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id mObj = nil;
        
        if ([obj respondsToSelector:@selector(mutableDeepCopy)]) {
            mObj = [obj mutableDeepCopy];
        } else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)]) {
            mObj = [obj mutableCopy];
        } else {
            mObj = obj;
        }
        
        [mself setObject:mObj forKey:key];
    }];
    
    return mself;
}


@end