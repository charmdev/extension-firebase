package extension.firebase;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end

import msignal.Signal;

class RemoteConfigCallback
{
	public var onResult:String -> Void;
	
	public function new(callback:String->Void)
	{
		this.onResult = callback;
	}

	public function setResult(result:String):Void
	{
		onResult(result);
	}
}

class Firebase {

	
	public static function sendAnalyticsEvent (eventName:String, payload:String):Void {

		#if (ios || android)
			extension_firebase_send_analytics_event(eventName, payload);
		#else
			trace("sendAnalyticsEvent not implemented on this platform.");
		#end
	}

	public static function getInstanceIDToken ():String {

		#if (ios || android)
			return extension_firebase_get_instance_id_token();
		#else
			trace("getInstanceIDToken not implemented on this platform.");
		return null;
		#end
	}

	public static function setCurrentScreen (screenName:String, screenClass:String = null):Void {

		#if (ios || android)
			extension_firebase_set_current_screen(screenName, screenClass);
		#else
			trace("setCurrentScreen not implemented on this platform.");
		#end
	}

	public static function setUserProperty (propName:String, propValue:String = null):Void {

		#if (ios || android)
			extension_firebase_set_user_property(propName, propValue);
		#else
			trace("setUserProperty not implemented on this platform.");
		#end
	}

	public static function setUserID (userID:String):Void {

		#if (ios || android)
			extension_firebase_set_user_id(userID);
		#else
			trace("setUserID not implemented on this platform.");
		#end
	}

	public static function setCrashlyticsProperty (propName:String, propValue:String = null):Void {

		#if (android || ios)
			extension_firebase_set_crashlytics_property(propName, propValue);
		#else
			trace("setCrashlyticsProperty not implemented on this platform.");
		#end
	}

	public static function setCrashlyticsUserID (userID:String):Void {

		#if (android || ios)
			extension_firebase_set_crashlytics_user_id(userID);
		#else
			trace("setCrashlyticsUserID not implemented on this platform.");
		#end
	}
	
	public static function getRemoteConfig(onSuccess:String -> Void, onError:String -> Void = null):Void {
		//trace("-----------------------> get remote config");
		if (onError == null)
		{
			onError = function(e:String)
			{
				trace('default remote config error handler: ${e}');
			};
		}
		#if (android)
			return extension_firebase_get_remote_config(new RemoteConfigCallback(onSuccess), new RemoteConfigCallback(onError));
		#else
			trace("getRemoteConfig not implemented on this platform.");
			return null;
		#end
	}

	#if (ios)
	private static var extension_firebase_send_analytics_event = Lib.load ("firebase", "sendFirebaseAnalyticsEvent", 2);
	private static var extension_firebase_set_current_screen = Lib.load ("firebase", "setCurrentScreen", 2);
	private static var extension_firebase_set_user_property = Lib.load ("firebase", "setUserProperty", 2);
	private static var extension_firebase_set_crashlytics_property = Lib.load ("firebase", "setCrashlyticsProperty", 2);
	private static var extension_firebase_get_instance_id_token = Lib.load ("firebase", "getInstanceIDToken", 0);
	private static var extension_firebase_set_user_id = Lib.load ("firebase", "setUserID", 1);
	private static var extension_firebase_set_crashlytics_user_id = Lib.load ("firebase", "setCrashlyticsUserID", 1);
	#end

	#if (android)
	private static var extension_firebase_send_analytics_event = JNI.createStaticMethod("org.haxe.extension.Firebase", "sendFirebaseAnalyticsEvent", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_set_current_screen = JNI.createStaticMethod("org.haxe.extension.Firebase", "setCurrentScreen", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_set_user_property = JNI.createStaticMethod("org.haxe.extension.Firebase", "setUserProperty", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_set_crashlytics_property = JNI.createStaticMethod("org.haxe.extension.Firebase", "setCrashlyticsProperty", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_get_instance_id_token = JNI.createStaticMethod("org.haxe.extension.Firebase", "getInstanceIDToken", "()Ljava/lang/String;");
	private static var extension_firebase_set_user_id = JNI.createStaticMethod("org.haxe.extension.Firebase", "setUserID", "(Ljava/lang/String;)V");
	private static var extension_firebase_set_crashlytics_user_id = JNI.createStaticMethod("org.haxe.extension.Firebase", "setCrashlyticsUserID", "(Ljava/lang/String;)V");
	private static var extension_firebase_get_remote_config = JNI.createStaticMethod("org.haxe.extension.Firebase", "getRemoteConfig", "(Lorg/haxe/lime/HaxeObject;Lorg/haxe/lime/HaxeObject;)V");
	#end
	
	
}