//
//  godot_ios_firebase_message.m
//  godot-ios-firebase-message
//
//  Created by YamazakiAkio on 2022/05/04.
//

#import "godot_ios_firebase_message.h"

#import <Foundation/Foundation.h>

#import "firebase_message.h"
#import "core/engine.h"

FirebaseMessage *firebase_message_plugin;

void godot_firebase_message_init() {
    NSLog(@"init Firebasemessage plugin");
    firebase_message_plugin = memnew(FirebaseMessage);
    Engine::get_singleton()->add_singleton(Engine::Singleton("FirebaseMessage", firebase_message_plugin));
}

void godot_firebase_message_deinit() {
    NSLog(@"deinit Firebasemessage plugin");
    if (firebase_message_plugin) {
        memdelete(firebase_message_plugin);
    }
}


