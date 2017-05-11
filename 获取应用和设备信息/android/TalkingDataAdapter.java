package com.funyou.utils;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;
import android.util.Log;

import org.json.JSONObject;


/*** TAKINGDATA AD TRACK ***/
import com.tendcloud.appcpa.TalkingDataAppCpa;


public class TalkingDataAdapter {
    static final String APPID = "E96BF648B89447C58FF1832309684956";
	static final String TAG = "TalkingDataAdapter";
	
    //初始化
	public static void init(Cocos2dxActivity appContex) {
        TalkingDataAppCpa.init(appContex.getApplicationContext(), APPID, Utils.getPackageName());
	}
    
    //登陆
	public static void onLogin(String userid) {
		Log.d(TAG, "onLogin");
        TalkingDataAppCpa.onLogin(userid);
	}
    
    //付费成功
	public static void onPaySuccess(String userid, String order, int price, String priceType, String payType) {
        Log.d(TAG, "onPaySuccess");
		TalkingDataAppCpa.onOrderPaySucc(userid, order, price*100, priceType, payType);
	}
}
