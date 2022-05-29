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
String FirebaseMessage::_apns_token;
static FirebaseMessage *_instance = NULL;

String from_nsstring(NSString* str) {
    const char *s = [str UTF8String];
    return String::utf8(s != NULL ? s : "");
}

void FirebaseMessage::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_fcm_token"), &FirebaseMessage::get_token);
    ClassDB::bind_method(D_METHOD("init_firebase_message"), &FirebaseMessage::init_firebase_message);
    ClassDB::bind_method(D_METHOD("get_apns_token"), &FirebaseMessage::get_apns_token);
    ADD_SIGNAL(MethodInfo("did_receive_registration_token", PropertyInfo(Variant::STRING, "token"), PropertyInfo(Variant::STRING, "apns_token")));
}

/*
 *  Delegate
 */

@interface FirebaseMessageDelegate : NSObject <FIRMessagingDelegate, UNUserNotificationCenterDelegate>
@end

@implementation FirebaseMessageDelegate

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
//    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FCMToken" object:nil userInfo:dataDict];

    // Note: This callback is fired at each app startup and whenever a new token is generated.
    NSData *apnsToken = messaging.APNSToken;
    NSString *deviceTokenString = [self stringWithDeviceToken:apnsToken];
    NSLog(@"FCM registration FCMToken: %@ APNSToken: %@", fcmToken, deviceTokenString);
    _instance->token_received(from_nsstring(fcmToken), from_nsstring(deviceTokenString));
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const unsigned char *data = (const unsigned char *)deviceToken.bytes;
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }

    return [token copy];
}
@end


FirebaseMessage::FirebaseMessage() {
    NSLog(@"initialize FirebaseMessage");
}

FirebaseMessage::~FirebaseMessage() {
    NSLog(@"deinitialize FirebaseMessage");
}

void FirebaseMessage::init_firebase_message() {
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
//    [[FIRMessaging messaging] tokenWithCompletion:^(NSString *token, NSError *error) {
//        if (error != nil) {
//            NSLog(@"Error getting FCM registration token: %@", error);
//        } else {
//            NSString *deviceTokenString = @"";
//            NSLog(@"FCM registration token: %@ %@", token, deviceTokenString);
//            _token = from_nsstring(token);
//            emit_signal("did_receive_registration_token", _token, from_nsstring(deviceTokenString));
//        }
//    }];
}

String FirebaseMessage::get_token() {
    return _token;
}

String FirebaseMessage::get_apns_token() {
    return _apns_token;
}

void FirebaseMessage::token_received(String t, String apnsToken) {
    _token = t;
    _apns_token = apnsToken;
    emit_signal("did_receive_registration_token", t, apnsToken);
}
