//
//  keychain.h
//  Sign In With Apple Demo
//
//  Created by 志德的MacBook Pro on 2019/11/17.
//  Copyright © 2019 志德的MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface keychain : NSObject

// save ... to keychain
+ (void)save:(NSString *)service data:(id)data;

// take out ... from keychain
+ (id)load:(NSString *)service;

// delete ... from keychain
+ (void)delete:(NSString *)service;


@end

NS_ASSUME_NONNULL_END
