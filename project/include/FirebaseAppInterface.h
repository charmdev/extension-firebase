#ifndef FIREBASE_APP_INTERFACE_H
#define FIREBASE_APP_INTERFACE_H

#import <Foundation/Foundation.h>
#include <hx/CFFI.h>

@interface FirebaseAppInterface : NSObject
@end

namespace extension_ios_firebase {

    static value sendFirebaseAnalyticsEvent(value eventName, value jsonPayload);
    DEFINE_PRIM(sendFirebaseAnalyticsEvent, 2);
    
    static value setUserProperty(value propName, value propValue);
    DEFINE_PRIM(setUserProperty, 2);
    
    static value setCurrentScreen(value screenName, value screenClass);
    DEFINE_PRIM(setCurrentScreen, 2);
    
    static value setUserID(value userID);
    DEFINE_PRIM(setUserID, 1);

    //static value getInstanceIDToken();
    //DEFINE_PRIM(getInstanceIDToken, 0);

}

#endif
