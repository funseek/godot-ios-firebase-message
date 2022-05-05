//
//  firebase_message.h
//  godot-ios-firebase-message
//
//  Created by YamazakiAkio on 2022/05/04.
//

#ifndef firebase_message_h
#define firebase_message_h

#include "core/object.h"

class FirebaseMessage : public Object {
    GDCLASS(FirebaseMessage, Object);
    
    static void _bind_methods();
    static String _token;
    
public:
    
    String get_token();
    void token_received(String t);
    
    FirebaseMessage();
    ~FirebaseMessage();
};

#endif /* firebase_message_h */
