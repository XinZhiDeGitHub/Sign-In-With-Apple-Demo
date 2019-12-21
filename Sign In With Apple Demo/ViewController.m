//
//  ViewController.m
//  Sign In With Apple Demo
//
//  Created by 志德的MacBook Pro on 2019/11/11.
//  Copyright © 2019 志德的MacBook Pro. All rights reserved.
//

#import "ViewController.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "keychain.h"

#define KEYCHAIN_IDENTIFIER(a) ([NSString stringWithFormat:@"%@_%@",[[NSBundle mainBundle] bundleIdentifier],a])

@interface ViewController () <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configUI];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // 尝试直接调用apple 登录
    [self perfomExistingAccountSetupFlows];
}

// 初始化apple 登入口，可以使用自定义的Button 但要注意符合苹果提供的设计规范，否则会有审核失败的风险
- (void)configUI{
    
    if (@available(iOS 13.0, *)) {
        // Sign In With Apple Button
        ASAuthorizationAppleIDButton *appleIDBtn = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhite];
        appleIDBtn.frame = CGRectMake(50, self.view.bounds.size.height - 200, self.view.bounds.size.width - 100, 80);
        [appleIDBtn addTarget:self action:@selector(handleAuthorizationAppleIDButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:appleIDBtn];
    }
}

// 处理授权
- (void)handleAuthorizationAppleIDButtonPress{
    
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        // 创建新的AppleID 授权请求
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        // 在用户授权期间请求的联系信息
        appleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName,ASAuthorizationScopeEmail];
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest]];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    } else {
        // 处理不支持系统版本
        NSLog(@"该系统版本不可用Apple登录");
    }
}

// 如果存在iCloud Keychain 凭证或者AppleID 凭证提示用户,如果不存在会走失败的回调
- (void)perfomExistingAccountSetupFlows{
    
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        // 授权请求AppleID
        ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
        // 为了执行钥匙串凭证分享生成请求的一种机制
        ASAuthorizationPasswordProvider *passwordProvider = [[ASAuthorizationPasswordProvider alloc] init];
        ASAuthorizationPasswordRequest *passwordRequest = [passwordProvider createRequest];
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest, passwordRequest]];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    } else {
        // 处理不支持系统版本
        NSLog(@"该系统版本不支持Apple登录");
    }
}

#pragma mark - delegate
//@optional 授权成功地回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    NSLog(@"授权完成:::%@", authorization.credential);
    
    if (@available(iOS 13.0, *)) {
        if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
            
            // 用户登录使用ASAuthorizationAppleIDCredential
            ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
            NSString *user = appleIDCredential.user;
            // 用户的唯一标识，需要使用钥匙串的方式保存
            [keychain save:KEYCHAIN_IDENTIFIER(@"userIdentifier") data:user];
            // 获取用户相关信息
            
            // 暂未使用
            // NSString *state = appleIDCredential.state;
            
            // 暂未使用
            // NSArray *authorizedScopes = appleIDCredential.authorizedScopes;
            
            // 用于判断当前登录的苹果账号是否是一个真实用户，ASUserDetectionStatusLikelyReal时可用
            // ASUserDetectionStatus realUserStatus = appleIDCredential.realUserStatus;
            
            // 用户信息
            /*
            NSString *familyName = appleIDCredential.fullName.familyName;
            NSString *givenName = appleIDCredential.fullName.givenName;
            NSString *email = appleIDCredential.email;*/

            // 请求服务器验证时需要使用的参数
            NSData *identityToken = appleIDCredential.identityToken;
            NSData *authorizationCode = appleIDCredential.authorizationCode;
    
            NSString *identityTokenStr = [[NSString alloc] initWithData:identityToken encoding:NSUTF8StringEncoding];
            NSString *authorizationCodeStr = [[NSString alloc] initWithData:authorizationCode encoding:NSUTF8StringEncoding];
            NSLog(@"%@\n\n%@", identityTokenStr, authorizationCodeStr);

        }else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]){
            // 这个获取的是iCloud记录的账号密码，需要配置支持iOS 12 记录账号密码的新特性，如果不支持，此处不执行
            // 用户登录使用现有的密码凭证
            ASPasswordCredential *passwordCredential = authorization.credential;
            // 密码凭证对象的用户标识 用户的唯一标识
            NSString *user = passwordCredential.user;
            // 密码凭证对象的密码
            NSString *password = passwordCredential.password;
            NSLog(@"******************************* %@:%@", user,password);
            
        }else{
            NSLog(@"************************************ 授权信息均不符");
        }
    } else {
        // Fallback on earlier versions
    }
}

// 授权失败的回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    // Handle error.
    NSLog(@"Handle error：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
            
        default:
            break;
    }
    NSLog(@"****************************** %@",errorMsg);
}

// 告诉代理应该在哪个window 展示内容给用户，xcode 11提供的场景概念，可忽略
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    // 返回window
    return self.view.window;
}

// 添加苹果登录的状态通知,可根据具体需要选择放置位置
- (void)observeAppleSignInState {
    if (@available(iOS 13.0, *)) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

// 观察SignInWithApple状态改变
- (void)handleSignInWithAppleStateChanged:(id)noti {
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", noti);
}

- (void)dealloc {
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

@end
