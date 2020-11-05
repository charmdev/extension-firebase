package org.haxe.extension;

import android.app.Activity;
import android.app.Application;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.ApplicationInfo;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
//import com.google.firebase.remoteconfig.FirebaseRemoteConfigInfo;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
//import com.google.samples.quickstart.config.BuildConfig;
//import com.google.samples.quickstart.config.R;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.iid.FirebaseInstanceId;
//import com.google.firebase.iid.FirebaseInstanceIdService;
import com.google.firebase.iid.InstanceIdResult;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.FirebaseApp;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Map;
import java.util.Iterator;

import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import org.json.JSONObject;
import org.json.JSONException;

import com.google.firebase.crashlytics.FirebaseCrashlytics;


public class Firebase extends Extension {

	static final String TAG = "FIREBASE-EXTENSION";
	private static final String CONFIG_KEY_ABTEST = "ab_test";


	private static FirebaseRemoteConfig mFirebaseRemoteConfig;

	private static Map<String, String> getPayloadFromJson(String jsonString) {
		Type type = new TypeToken<Map<String, String>>(){}.getType();
		Map<String, String> payload = new Gson().fromJson(jsonString, type);
		return payload;
	}


	private static Bundle getFirebaseAnalyticsBundleFromJson(String jsonString) {
		Map<String, String> payloadMap = getPayloadFromJson(jsonString);

		Bundle payloadBundle = new Bundle();
		for (Map.Entry<String, String> entry : payloadMap.entrySet()) {
			payloadBundle.putString(entry.getKey(), entry.getValue());
		}

		return payloadBundle;
	}

	// Get token
	/*
	* The registration token may change when:
	* The app deletes Instance ID
	* The app is restored on a new device
	* The user uninstalls/reinstall the app
	* The user clears app data.*/
	public static String getInstanceIDToken()
	{
		final String token = FirebaseInstanceId.getInstance().getToken();
		Log.d(TAG, "getInstanceId success: " + token);

		return token;

		/*
		FirebaseInstanceId.getInstance().getInstanceId()
		.addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
			@Override
			public void onComplete(@NonNull Task<InstanceIdResult> task) {
				if (!task.isSuccessful()) {
					Log.d(TAG, "getInstanceId failed", task.getException());
					return;
				}

				Log.d(TAG, "getInstanceId success", task.getResult().getToken());
			}
		});
		*/
	}


	public static void sendFirebaseAnalyticsEvent(String eventName, String jsonPayload) {
		Log.d(TAG, "Firebase.java: sendFirebaseAnalyticsEvent name= " + eventName + ", payload= " + jsonPayload);

		Application mainApp = Extension.mainActivity.getApplication();
		FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.getInstance(mainApp);

		Bundle payloadBundle = getFirebaseAnalyticsBundleFromJson(jsonPayload);
		firebaseAnalytics.logEvent(eventName, payloadBundle);
	}

	public static void setUserProperty(String propName, String propValue) {
		Log.d(TAG, "Firebase.java: setUserProperty name= " + propName + ", value= " + propValue);

		Application mainApp = Extension.mainActivity.getApplication();
		FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.getInstance(mainApp);


		firebaseAnalytics.setUserProperty(propName, propValue);
	}

	public static void setCurrentScreen(String screenName, String screenClass) {
		Log.d(TAG, "Firebase.java: setScreen name= " + screenName + ", class= " + screenClass);

		Application mainApp = Extension.mainActivity.getApplication();
		FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.getInstance(mainApp);

		firebaseAnalytics.setCurrentScreen(Extension.mainActivity, screenName, screenClass);
	}

	public static void setUserID(String userID) {
		Log.d(TAG, "Firebase.java: setUserID id= " + userID);

		Application mainApp = Extension.mainActivity.getApplication();
		FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.getInstance(mainApp);

		firebaseAnalytics.setUserId(userID);
	}

	public static void setCrashlyticsProperty(String propName, String propValue) {
		FirebaseCrashlytics crashlytics = FirebaseCrashlytics.getInstance();
		crashlytics.setCustomKey(propName, propValue);
		Log.d(TAG, "Firebase.java: setCrashlyticsProperty name= " + propName + ", value= " + propValue);
	}

	public static void setCrashlyticsUserID(String userID) {
		FirebaseCrashlytics crashlytics = FirebaseCrashlytics.getInstance();
		crashlytics.setUserId(userID);
		Log.d(TAG, "Firebase.java: setCrashlyticsUserID id= " + userID);
	}


	public static void getRemoteConfig(HaxeObject callbackSuccess, HaxeObject callbackError) {
		Log.d(TAG, "GET REMOTE CONFIG");
		final HaxeObject cbSuccess = callbackSuccess;
		final HaxeObject cbError = callbackError;
		mFirebaseRemoteConfig.fetchAndActivate()
				.addOnCompleteListener(new OnCompleteListener<Boolean>() {
					@Override
					public void onComplete(@NonNull Task<Boolean> task) {
						if (task.isSuccessful())
						{
							Log.d(TAG, "GET REMOTE CONFIG SUCCESS");
								JSONObject resultJson = new JSONObject();
							Iterator<Map.Entry<String, FirebaseRemoteConfigValue>> it = mFirebaseRemoteConfig.getAll().entrySet().iterator();
							try
							{
								while (it.hasNext())
								{
									Map.Entry<String, FirebaseRemoteConfigValue> pair = it.next();
									resultJson.put(pair.getKey(), pair.getValue().asString());
								}
								cbSuccess.call1("setResult", resultJson.toString());
							}
							catch (JSONException e)
							{
								Log.d(TAG, "PARSE REMOTE CONFIG ERROR");
								cbError.call1("setResult", "PARSE REMOTE CONFIG ERROR");
							}
						}
						else
						{
							Log.d(TAG, "GET REMOTE CONFIG ERROR");
                            cbError.call1("setResult", "GET REMOTE CONFIG ERROR");
						}
					}
				});
				
	}

	/**
	 * Called when the activity is starting.
	 */
	public void onCreate (Bundle savedInstanceState) {

		Log.d(TAG, "Firebase extension onCreate ");

		FirebaseApp.initializeApp(mainContext);

		// Handle possible data accompanying notification message.
		Intent intent = null;
		try {
			PackageManager pm = mainContext.getPackageManager();
			if(pm != null) {
				String packageName = mainContext.getPackageName();
				intent = pm.getLaunchIntentForPackage(packageName);
				intent.addCategory(Intent.CATEGORY_LAUNCHER); // Should already be set, but just in case
			}
		} catch (Exception e) {
			Log.d(TAG, "Failed to get application launch intent");
		}

		Bundle intentBundle = null;
		if (intent != null && intent.getExtras() != null) {
			intentBundle = intent.getExtras();
			for (String key : intentBundle.keySet()) {
				Object value = intentBundle.get(key);
				Log.d(TAG, "Launch intent Key: " + key + " Value: " + value);
			}
		}

		// subscribe for new messages
		FirebaseMessaging.getInstance().subscribeToTopic("news")
		.addOnCompleteListener(new OnCompleteListener<Void>() {
			@Override
			public void onComplete(@NonNull Task<Void> task) {
				String msg = "Successful Subscribed messages from Firebase";
				if (!task.isSuccessful()) {
					msg = "Failed Subscribed messages from Firebase";
				}
				Log.d(TAG, msg);
			}
		});


		Firebase.getInstanceIDToken();

		mFirebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
		FirebaseRemoteConfigSettings configSettings = new FirebaseRemoteConfigSettings.Builder()
				//.setDeveloperModeEnabled(BuildConfig.DEBUG)
				.setMinimumFetchIntervalInSeconds(60)
				.build();
		mFirebaseRemoteConfig.setConfigSettingsAsync(configSettings);
		//mFirebaseRemoteConfig.setDefaults(R.xml.remote_config_defaults);
	}


	/**
	 * Perform any final cleanup before an activity is destroyed.
	 */
	public void onDestroy () {



	}


	/**
	 * Called as part of the activity lifecycle when an activity is going into
	 * the background, but has not (yet) been killed.
	 */
	public void onPause () {



	}


	/**
	 * Called after {@link #onStop} when the current activity is being
	 * re-displayed to the user (the user has navigated back to it).
	 */
	public void onRestart () {



	}


	/**
	 * Called after {@link #onRestart}, or {@link #onPause}, for your activity
	 * to start interacting with the user.
	 */
	public void onResume () {



	}


	/**
	 * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when
	 * the activity had been stopped, but is now again being displayed to the
	 * user.
	 */
	public void onStart () {

		Log.d(TAG, "Firebase.java: onStart ");
	}


	/**
	 * Called when the activity is no longer visible to the user, because
	 * another activity has been resumed and is covering this one.
	 */
	public void onStop () {



	}

}