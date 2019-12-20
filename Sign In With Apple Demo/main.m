//
//  main.m
//  Sign In With Apple Demo
//
//  Created by 志德的MacBook Pro on 2019/11/11.
//  Copyright © 2019 志德的MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
