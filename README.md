# Firebase Cloud Messaging plugin for Godot
This is a plugin for Godot that calls Firebase Cloud Messaging on [iOS](https://firebase.google.com/docs/cloud-messaging/ios/client).

## Instructions

### Important
You will also need to include the following [plugins](https://github.com/funseek/godot-ios-firebase-analytics). This plugin is a Firebase Analytics plugin, but the initialization process is included in this plugin

### Building library and copy them to Godot Project
Clone this repository and it's submodules:
```
git clone --recurse-submodules git@github.com:funseek/godot-ios-firebase-message.git
```

To generate Godot headers you need to run compilation command inside godot submodule directory.   
Example:
```
./scripts/generate_headers.sh
```

run pod install. [CocoaPods](https://cocoapods.org/)
```
pod install
```

Building a .a library
```
./scripts/release_static_library.sh 3.5
```

Copy a.library to Godot plugin directory
```
cp bin/release/firebase-message/firebase-message.*.a $GODOT_HOME/ios/plugins/firebase-message/bin/
cp firebase-message.gdip $GODOT_HOME/ios/plugins/
```


### Export iOS project and edit Xcode project
Export iOS project by Godot. then you need to use CocoaPods in Xcode. Add the following to your Podfile if it does not exist, create a new one.
```
pod 'Firebase/Messaging'
```

run pod install.
```
pod install
```

### How to use it with GDScript

#### Method
* init_firebase_message
* get_fcm_token
* get_apns_token
#### signal
* did_receive_registration_token ([see](https://firebase.google.com/docs/cloud-messaging/ios/client?hl=en#monitor-token-refresh))

#### notice
get_fcm_token and get_apns_token are set after did_receive_registration_token is called

Calling plugin in Godot
```gdscript
# init_firebase_message
func init_firebase_message():
	if Engine.has_singleton("FirebaseMessage"):
		  var singleton = Engine.get_singleton("FirebaseMessage")
		  singleton.init_firebase_message()

# get_fcm_token
func get_fcm_token():
	if Engine.has_singleton("FirebaseMessage"):
		  var singleton = Engine.get_singleton("FirebaseMessage")
		  return singleton.get_fcm_token()

# get_apns_token
func get_fcm_token():
	if Engine.has_singleton("FirebaseMessage"):
		  var singleton = Engine.get_singleton("FirebaseMessage")
		  return singleton.get_apns_token()
		
# did_receive_registration_token
func did_receive_registration_token():
	if Engine.has_singleton("FirebaseMessage"):
		  firebase_message = Engine.get_singleton("FirebaseMessage")
		  firebase_message.connect('did_receive_registration_token', self, '_did_receive_registration_token')

func _did_receive_registration_token(fcm_token, apns_token):
	print(fcm_token)
	print(apns_token)
```

## License
MIT
