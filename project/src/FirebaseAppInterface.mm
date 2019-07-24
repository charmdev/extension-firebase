#include "FirebaseAppDelegate.h"
#include "FirebaseAppInterface.h"

@implementation FirebaseAppInterface : NSObject
@end

namespace extension_ios_firebase {

    static value sendFirebaseAnalyticsEvent(value eventName, value jsonPayload) {
        //NSLog(@"extension_ios_firebase sendAnalyticsEvent");
        return alloc_bool([[FirebaseAppDelegate sharedInstance]
            sendFirebaseAnalyticsEvent:[NSString stringWithUTF8String:val_string(eventName)]
            jsonPayload:[NSString stringWithUTF8String:val_string(jsonPayload)]
        ]);
    }
    
    static value setUserProperty(value propName, value propValue) {
        //NSLog(@"extension_ios_firebase setUserProperty");
        return alloc_bool([[FirebaseAppDelegate sharedInstance]
            setUserProperty:[NSString stringWithUTF8String:val_string(propName)]
            propValue:[NSString stringWithUTF8String:val_string(propValue)]
        ]);
    }
    
    static value setCurrentScreen(value screenName, value screenClass) {
        //NSLog(@"extension_ios_firebase setScreen");
        return alloc_bool([[FirebaseAppDelegate sharedInstance]
            setCurrentScreen:[NSString stringWithUTF8String:val_string(screenName)]
            screenClass:[NSString stringWithUTF8String:val_string(screenClass)]
        ]);
    }
    
    static value setUserID(value userID) {
        //NSLog(@"extension_ios_firebase setUserID");
        return alloc_bool([[FirebaseAppDelegate sharedInstance]
           setUserID:[NSString stringWithUTF8String:val_string(userID)]
       ]);
    }
    
/*
    static value getInstanceIDToken() {
        NSLog(@"extension_ios_firebase getInstanceIDToken");
        NSString* idToken = [[FirebaseAppDelegate sharedInstance] getInstanceIDToken];
        return alloc_string([idToken UTF8String]);
    }
 */
}
