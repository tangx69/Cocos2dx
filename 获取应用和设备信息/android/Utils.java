package com.funyou.utils;

import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
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

public class Utils {
	static final String TAG = "Utils";
	static Cocos2dxActivity _appContex;
	
	public static void init(Cocos2dxActivity appContex) {
		_appContex = appContex;
	}

    public static String getDeviceName() {
        String deviceName = android.os.Build.MODEL;
        return deviceName;
    }
    
    public static String getPackageName() {
        final ApplicationInfo applicationInfo = _appContex.getApplicationInfo();
        String packageName = applicationInfo.packageName;
        return packageName;
    }
    
    public static int getVersionCode() {
        PackageManager pm = _appContex.getPackageManager();
        int versionCode = 0;
        try{
            PackageInfo packageInfo = pm.getPackageInfo(_appContex.getPackageName(), 0);
            versionCode = packageInfo.versionCode;
        }catch(NameNotFoundException e){
            e.printStackTrace();
        }
        
        return versionCode;
    }
    
    public static String getVersionName() {
        PackageManager pm = _appContex.getPackageManager();
        String versionName = "1.0.0";
        try{
            PackageInfo packageInfo = pm.getPackageInfo(_appContex.getPackageName(), 0);
            versionName = packageInfo.versionName;
        }catch(NameNotFoundException e){
            e.printStackTrace();
        }
        
        return versionName;
    }
    
    public static String encodeURI(String _uri) {
        String uri = "";
        try {
            uri = URLEncoder.encode(_uri, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return uri;
    }

    public static String getIMSI() {
        TelephonyManager mTelephonyMgr = (TelephonyManager) _appContex.getSystemService(Context.TELEPHONY_SERVICE);  
        Log.d("getImsi", "get mTelephonyMgr " + mTelephonyMgr.toString());  
        String imsi = mTelephonyMgr.getSubscriberId();  
        if(imsi == null)
        {
           imsi = "123456789";
        }
        return imsi;  
    }
    
    public static String getIMEI() {
        TelephonyManager mTelephonyMgr = (TelephonyManager) _appContex.getSystemService(Context.TELEPHONY_SERVICE);
        Log.d("getImsi", "get mTelephonyMgr " + mTelephonyMgr.toString());  
        String imei = mTelephonyMgr.getDeviceId(); 
        return imei;  
    }
    
    /** 
     * 获取手机的MAC地址 
     * @return 
     */  
    public static String getMac(){
        String str="";  
        String macSerial="";  
        try {  
            Process pp = Runtime.getRuntime().exec(  
                    "cat /sys/class/net/wlan0/address ");  
            InputStreamReader ir = new InputStreamReader(pp.getInputStream());  
            LineNumberReader input = new LineNumberReader(ir);  
  
            for (; null != str;) {  
                str = input.readLine();  
                if (str != null) {  
                    macSerial = str.trim();// 去空格  
                    break;  
                }  
            }  
        } catch (Exception ex) {  
            ex.printStackTrace();  
        }  
        if (macSerial == null || "".equals(macSerial)) {  
            try {  
                return loadFileAsString("/sys/class/net/eth0/address")  
                        .toUpperCase().substring(0, 17);  
            } catch (Exception e) {  
                e.printStackTrace();  
                  
            }  
              
        }  
        return macSerial;  
    }
    public static String loadFileAsString(String fileName) throws Exception {  
        FileReader reader = new FileReader(fileName);    
        String text = loadReaderAsString(reader);  
        reader.close();  
        return text;  
    }
    public static String loadReaderAsString(Reader reader) throws Exception {  
        StringBuilder builder = new StringBuilder();  
        char[] buffer = new char[4096];  
        int readLength = reader.read(buffer);  
        while (readLength >= 0) {  
            builder.append(buffer, 0, readLength);  
            readLength = reader.read(buffer);  
        }  
        return builder.toString();  
    }

    public static int getMemory() {
        final ActivityManager activityManager = (ActivityManager) _appContex.getSystemService(Context.ACTIVITY_SERVICE);    
        ActivityManager.MemoryInfo info = new ActivityManager.MemoryInfo();   
        activityManager.getMemoryInfo(info);    

        int memory =  (int) (info.availMem >> 20);
        Log.i(TAG, "系统剩余内存: "+memory+"M");
        Log.i(TAG, "系统是否处于低内存运行："+info.lowMemory);
        Log.i(TAG, "当系统剩余内存低于"+info.threshold+"时就看成低内存运行");

        return memory;
    }
    
    public static int getNetworkState() {
        Context context = _appContex.getContext();
    	int TYPE_NET_WORK_DISABLED = 0;
    	int TYPE_MOBILE = 1;
    	int TYPE_WIFI = 2;
    	
    	int ret = TYPE_NET_WORK_DISABLED;
    	
    	try {  
            final ConnectivityManager connectivityManager = (ConnectivityManager) context  
                    .getSystemService(Context.CONNECTIVITY_SERVICE);  
            final NetworkInfo mobNetInfoActivity = connectivityManager  
                    .getActiveNetworkInfo();  
            if (mobNetInfoActivity == null || !mobNetInfoActivity.isAvailable()) {  
                // 注意一：  
                // NetworkInfo 为空或者不可以用的时候正常情况应该是当前没有可用网络，  
                // 但是有些电信机器，仍可以正常联网，  
                // 所以当成net网络处理依然尝试连接网络。  
                // （然后在socket中捕捉异常，进行二次判断与用户提示）。  
            	ret = TYPE_NET_WORK_DISABLED;  
            } else {  
                // NetworkInfo不为null开始判断是网络类型  
                int netType = mobNetInfoActivity.getType();  
                if (netType == ConnectivityManager.TYPE_WIFI) {  
                    // wifi net处理  
                	ret = TYPE_WIFI;  
                } else if (netType == ConnectivityManager.TYPE_MOBILE) {
                	ret = TYPE_MOBILE;
                }  
            }  
  
        } catch (Exception ex) {  
            ex.printStackTrace();  
        }  
		
    	Log.d(TAG, "[JAVA][Utils][getNetworkState]NetWorkState is "+ret);
    	
        return ret;  
    }
    
    public static String getMetaData(String strKey){
        String msg = "";
		try {
			ApplicationInfo appInfo = _appContex.getPackageManager().getApplicationInfo(getPackageName(),PackageManager.GET_META_DATA);
			//msg=appInfo.metaData.getString(strKey);
            msg= "" + appInfo.metaData.getInt(strKey);

		} catch (Exception e) {
			// TODO Auto-generated catch block
            Log.e(TAG, "[JAVA][Utils][getMetaData]");
			e.printStackTrace();
		}
		Log.d(TAG, strKey+"="+msg);
		
		return msg;
    }
    
    @SuppressWarnings("deprecation")
	public static void restartApplication() {  
    	/*
        final Intent intent = _appContex.getPackageManager().getLaunchIntentForPackage(getPackageName());  
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);  
        _appContex.startActivity(intent);  
        */
    	final ActivityManager activityManager = (ActivityManager) _appContex.getSystemService(Context.ACTIVITY_SERVICE); 
    	activityManager.restartPackage(getPackageName()); 
    }  
    
    public static void callLuaFunctionWithString(final int luaFunc, String para) {
    	if(luaFunc == 0) {
    		return;
    	}
    		
    	final String paraJson = para;
    	_appContex.runOnGLThread(new Runnable(){
			@Override
            public void run() {
				//System.out.println("callLuaGlobalFunctionWithString");
                //call a global lua function by name
				//Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("luaFuncName", "strPara");

				Log.d(TAG, "callLuaFunctionWithString para is:" + paraJson);
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunc, paraJson); //
				}
        });
    }
    
    /* a demo
     * shows how to set a lua callback function to java
     */
    public static void callbackDemo(String pruduct_sku, int luaPurchFinish)
	{
        JSONObject jsonObj = new JSONObject();
        try{
            jsonObj.put("key1", "value1");
            jsonObj.put("key2", "value2");
            callLuaFunctionWithString(luaPurchFinish, jsonObj.toString());
        }catch(Exception e) {
            e.printStackTrace();
        }
	}
}
