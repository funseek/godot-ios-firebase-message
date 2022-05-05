//
//  firebase_message.m
//  godot-ios-firebase-message
//
//  Created by YamazakiAkio on 2022/05/04.
//

#import <Foundation/Foundation.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

#include "core/project_settings.h"
#include "core/class_db.h"

#import "firebase_message.h"

String FirebaseMessage::_token;
static FirebaseMessage *_instance = NULL;

String from_nsstring(NSString* str) {
    const char *s = [str UTF8String];
    return String::utf8(s != NULL ? s : "");
}

void FirebaseMessage::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_token"), &FirebaseMessage::get_token);
    ADD_SIGNAL(MethodInfo("did_receive_registration_token", PropertyInfo(Variant::STRING, "token")));
}

/*
 *  Delegate
 */

@interface FirebaseMessageDelegate : NSObject <FIRMessagingDelegate, UNUserNotificationCenterDelegate>
@end

@implementation FirebaseMessageDelegate

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FCMToken" object:nil userInfo:dataDict];

    // Note: This callback is fired at each app startup and whenever a new token is generated.
    _instance->token_received(from_nsstring(fcmToken));
}

@end


FirebaseMessage::FirebaseMessage() {
    NSLog(@"initialize FirebaseMessage");
    _instance = this;
    UIApplication *application = UIApplication.sharedApplication;
    FirebaseMessageDelegate* _delegate = [FirebaseMessageDelegate new];
    
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = _delegate;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // ...
          }];
    }

    [application registerForRemoteNotifications];
    
    [FIRMessaging messaging].delegate = _delegate;
    [[FIRMessaging messaging] tokenWithCompletion:^(NSString *token, NSError *error) {
        if (error != nil) {
            NSLog(@"Error getting FCM registration token: %@", error);
        } else {
            NSLog(@"FCM registration token: %@", token);
            _token = from_nsstring(token);
            emit_signal("did_receive_registration_token", _token);
        }
    }];
}

FirebaseMessage::~FirebaseMessage() {
    NSLog(@"deinitialize FirebaseMessage");
}

String FirebaseMessage::get_token() {
    return _token;
}

void FirebaseMessage::token_received(String t) {
    _token = t;
    emit_signal("did_receive_registration_token", t);
}
