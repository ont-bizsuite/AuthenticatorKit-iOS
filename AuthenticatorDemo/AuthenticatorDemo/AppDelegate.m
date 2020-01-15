//
//  AppDelegate.m
//  AuthenticatorDemo
//
//  Created by Mac on 2019/11/11.
//  Copyright © 2019 Onchain. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"%@", [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]);
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


- (BOOL)application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"app = %@", app);
    NSLog(@"url = %@", url);
    NSLog(@"url.scheme = %@", url.scheme);
    NSLog(@"url.absoluteString = %@", url.absoluteString);
    NSLog(@"url.query = %@", url.query);
    NSLog(@"options = %@", options);
    
    if (url && [url.scheme isEqualToString:@"authenticatordemo"]) { // Authenticatordemo
        NSArray *array = [url.query componentsSeparatedByString:@"params="];
        if (array.count > 0) {
            NSString *actionBody = array.lastObject;
            NSData *data = [[NSData alloc] initWithBase64EncodedString:actionBody options:0];
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (!error && [json isKindOfClass:[NSDictionary class]]) {
                NSLog(@"%@", json);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ONTAuthCallbackNotification" object:json];
                return YES;
            }
        }
    }
    
    return YES;
}

@end
