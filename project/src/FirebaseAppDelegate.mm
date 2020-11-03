#include "FirebaseAppDelegate.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Firebase.h>
#import <FirebaseCrashlytics/FirebaseCrashlytics.h>



@interface NMEAppDelegate : NSObject <UIApplicationDelegate>
@end

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation NMEAppDelegate(FirebaseAppDelegate)
/*
	-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *) launchOptions
	{
		[FIRApp configure];
		NSLog(@"willFinishLaunchingWithOptions Firebase");
		return YES;
	}
 */
@end

@implementation FirebaseAppDelegate

extern "C" void responseRemoteConfig(const char* config);
extern "C" void errorRemoteConfig(const char* messge);

//NSString *const kGCMMessageIDKey = @"gcm.message_id";
//NSString* firebaseInstanceIdToken = @"";
//FIRRemoteConfig* remoteConfig;

+ (instancetype)sharedInstance
{
  static FirebaseAppDelegate *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
	_sharedInstance = [[self alloc] _init];
  });
  return _sharedInstance;
}

- (instancetype)_init
{
	NSLog(@"FirebaseAppDelegate: _init");

	return self;
}

- (instancetype)init
{
  return nil;
}

- (BOOL)setUserID:(NSString *)userID
{
	NSLog(@"FirebaseAppDelegate: setUserID id= %@", userID);
	
	[FIRAnalytics setUserID:userID];
	return YES;
}

- (BOOL)setCrashlyticsUserID:(NSString *)userID
{
	NSLog(@"FirebaseAppDelegate: setCrashlyticsUserID id= %@", userID);

	[[FIRCrashlytics crashlytics] setUserID:userID];

	return YES;
}

- (BOOL)setCurrentScreen:(NSString *)screenName screenClass:(NSString *)screenClass
{
	NSLog(@"FirebaseAppDelegate: setScreen name= %@, class= %@", screenName, screenClass);
	
	[FIRAnalytics setScreenName:screenName screenClass:screenClass];
	//warning: 'setScreenName:screenClass:' is deprecated:
	//Use +[FIRAnalytics logEventWithName:kFIREventScreenView parameters:] instead.

	return YES;
}

- (BOOL)setUserProperty:(NSString *)propName propValue:(NSString *)propValue
{
	NSLog(@"FirebaseAppDelegate: setUserProperty key= %@, val= %@", propName, propValue);
	
	[FIRAnalytics setUserPropertyString:propValue forName:propName];
	return YES;
}

- (BOOL)setCrashlyticsProperty:(NSString *)propName propValue:(NSString *)propValue
{
	NSLog(@"FirebaseAppDelegate: setCrashlyticsProperty key= %@, val= %@", propName, propValue);

	[[FIRCrashlytics crashlytics] setCustomValue:propValue forKey:propName];

	return YES;
}

- (BOOL)sendFirebaseAnalyticsEvent:(NSString *)eventName jsonPayload:(NSString *)jsonPayload
{
	NSLog(@"FirebaseAppDelegate: sendFirebaseAnalyticsEvent name= %@, parameter= %@", eventName, jsonPayload);

	NSData * jsonData = [jsonPayload dataUsingEncoding:NSUTF8StringEncoding];
	NSError * error = nil;
	NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

	[FIRAnalytics logEventWithName:eventName parameters:parsedData];
	return YES;
}

- (void)requestRemoteConfig
{
	//NSLog(@"extension_ios_firebase requestRemoteConfig OK");
	
	FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
	FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
	remoteConfigSettings.minimumFetchInterval = 0;
	remoteConfig.configSettings = remoteConfigSettings;
	
	[remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
		if (status == FIRRemoteConfigFetchStatusSuccess) {
			NSLog(@"Config fetched!");
			
			[remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
				//NSLog(@"---------------> WAITING FOR RESPONSE");
				NSArray<NSString*>* keys = [remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote];
				NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
				for (id key in keys)
				{
					//NSLog(key);
					NSString* strValue = [[remoteConfig configValueForKey:key] stringValue];
					//NSLog(strValue);
					[resultDict setValue:strValue forKey:key];
				}
				NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:&error];
				dispatch_async(dispatch_get_main_queue(), ^{
					NSString *resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
					//NSLog(resultString);
					const char* responseChar = [resultString cStringUsingEncoding:[NSString defaultCStringEncoding]];
					responseRemoteConfig(responseChar);
				});
			}];
		} else {
			NSLog(@"Config not fetched");
			NSLog(@"Error %@", error.localizedDescription);
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *errorMessage = error.localizedDescription;
				const char* responseChar = [errorMessage cStringUsingEncoding:[NSString defaultCStringEncoding]];
				errorRemoteConfig(responseChar);
			});
		}
	}];
}

@end
