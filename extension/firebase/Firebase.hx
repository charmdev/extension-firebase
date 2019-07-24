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
	public var crossPromoModelCallback:Signal1<String>;
	
	public function new(listener:String->Void)
	{
		crossPromoModelCallback = new Signal1<String>();
		crossPromoModelCallback.add(listener);
	}

	public function setJSON(json:String):Void
	{
		crossPromoModelCallback.dispatch(json);
	}
}

class Firebase {

	
	public static function sendAnalyticsEvent (eventName:String, payload:String):Void {

		#if android
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
	
	public static function getRemoteConfig(callback:RemoteConfigCallback):Void {
		#if (ios || android)
			return extension_firebase_get_remote_config(callback);
		#else
			trace("setUserID not implemented on this platform.");
			return null;
		#end
	}

	#if (ios)
	private static var extension_firebase_send_analytics_event = Lib.load ("firebase", "sendFirebaseAnalyticsEvent", 2);
	private static var extension_firebase_set_current_screen = Lib.load ("firebase", "setCurrentScreen", 2);
	private static var extension_firebase_set_user_property = Lib.load ("firebase", "setUserProperty", 2);
	private static var extension_firebase_get_instance_id_token = Lib.load ("firebase", "getInstanceIDToken", 0);
	private static var extension_firebase_set_user_id = Lib.load ("firebase", "setUserID", 1);
	#end

	#if (android)
	private static var extension_firebase_send_analytics_event = JNI.createStaticMethod("org.haxe.extension.Firebase", "sendFirebaseAnalyticsEvent", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_set_current_screen = JNI.createStaticMethod("org.haxe.extension.Firebase", "setCurrentScreen", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_set_user_property = JNI.createStaticMethod("org.haxe.extension.Firebase", "setUserProperty", "(Ljava/lang/String;Ljava/lang/String;)V");
	private static var extension_firebase_get_instance_id_token = JNI.createStaticMethod("org.haxe.extension.Firebase", "getInstanceIDToken", "()Ljava/lang/String;");
	private static var extension_firebase_set_user_id = JNI.createStaticMethod("org.haxe.extension.Firebase", "setUserID", "(Ljava/lang/String;)V");
	private static var extension_firebase_get_remote_config = JNI.createStaticMethod("org.haxe.extension.Firebase", "getRemoteConfig", "(Lorg/haxe/lime/HaxeObject;)V");
	#end
	
	
}