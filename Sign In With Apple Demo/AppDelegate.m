//
//  AppDelegate.m
//  Sign In With Apple Demo
//
//  Created by 志德的MacBook Pro on 2019/11/11.
//  Copyright © 2019 志德的MacBook Pro. All rights reserved.
//

#import "AppDelegate.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "keychain.h"

#define KEYCHAIN_IDENTIFIER(a) ([NSString stringWithFormat:@"%@_%@",[[NSBundle mainBundle] bundleIdentifier],a])

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 
    [self observeAuthticationState];
    
    return YES;
}

#pragma mark - Private functions
//! 观察授权状态
- (void)observeAuthticationState {
    
    if (@available(iOS 13.0, *)) {
        // A mechanism for generating requests to authenticate users based on their Apple ID.
        // 基于用户的Apple ID 生成授权用户请求的机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        // 需要使用钥匙串的方式获取已经存在的用户唯一标识
        NSString *userIdentifier = [keychain load:KEYCHAIN_IDENTIFIER(@"userIdentifier")];
        
        if (userIdentifier) {
            NSString* __block errorMsg = nil;
            //Returns the credential state for the given user in a completion handler.
            // 在回调中返回用户的授权状态
            [appleIDProvider getCredentialStateForUserID:userIdentifier completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                switch (credentialState) {
                        // 苹果证书的授权状态
                    case ASAuthorizationAppleIDProviderCredentialRevoked:
                        // 苹果授权凭证失效
                        errorMsg = @"苹果授权凭证失效";
                        break;
                    case ASAuthorizationAppleIDProviderCredentialAuthorized:
                        // 苹果授权凭证状态良好
                        errorMsg = @"苹果授权凭证状态良好";
                        break;
                    case ASAuthorizationAppleIDProviderCredentialNotFound:
                        // 未发现苹果授权凭证
                        errorMsg = @"未发现苹果授权凭证";
                        // 可以引导用户重新登录
                        break;
                    case ASAuthorizationAppleIDProviderCredentialTransferred:
                        errorMsg = @"苹果授权信息变动";
                        break;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"SignInWithApple授权状态变化情况");
                    NSLog(@"%@", errorMsg);
                });
            }];
            
        }
    }
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    if (@available(iOS 13.0, *)) {
        return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    } else {
        // Fallback on earlier versions
        return nil;
    }
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
