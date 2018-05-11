package com.funyou.utils;

import android.util.Base64;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.io.ByteArrayOutputStream;
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

import android.content.Context;
import android.provider.MediaStore;
import android.net.Uri;
import java.io.FileInputStream;  
import java.io.FileOutputStream;  
import java.io.IOException;  
import java.io.InputStream;  
import java.io.OutputStream; 
import android.database.Cursor; 
import android.graphics.Bitmap;
import android.graphics.BitmapFactory; 

import org.json.JSONObject;


public class PhotosManager{
    private static final String TAG = "PhotosManager";
	static Cocos2dxActivity _appContex;
    
    private static final int PHOTO_REQUEST_GALLERY = 1;// 从相册中选择
    private static int _luaCallBack = 0;
    private static float _maxWidth = 300;
    private static float _maxHeigh = 400;
    private static float _qualityRatio = 50;
    
    public static void init(Cocos2dxActivity appContex) {
        Log.d(TAG, "JAVA_VERSION=" + System.getProperty("java.version"));
		_appContex = appContex;
	}
    
    /*
     * 从相册获取
     */
    public static void getScreenShot(int luacallBack, float maxWidth, float maxHeigh, float qualityRatio) {
        // 激活系统图库，选择一张图片
        _luaCallBack = luacallBack;
        _maxWidth = maxWidth;
        _maxHeigh = maxHeigh;
        _qualityRatio = qualityRatio;
        
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_GALLERY
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        _appContex.startActivityForResult(intent, PHOTO_REQUEST_GALLERY);
    }

    public static void onActivityResult(int requestCode, int resultCode, Intent data) {
        String base64Image = "";
        if (requestCode == PHOTO_REQUEST_GALLERY)
        {
            // 从相册返回的数据
            if (data != null) {
                // 得到图片的全路径
                Uri uri = data.getData();
                String imagePath = getRealPathFromURI(_appContex, uri);
                Log.d(TAG, "imagePath=" + imagePath);
                base64Image = GetImageBase64Str(imagePath);
                //Log.d(TAG, "base64Image=" + base64Image);
            }
        }
        Utils.callLuaFunctionWithString(_luaCallBack, base64Image);
    }
    
    //图片转化成base64字符串  
    public static String GetImageBase64Str(String imgFile)  
    {   
        return getSmallBitmap(imgFile);
    }
    
    public static String getRealPathFromURI(Context context, Uri contentURI) {
       String result;
       Cursor cursor = context.getContentResolver().query(contentURI,
             new String[]{MediaStore.Images.ImageColumns.DATA},//
             null, null, null);
       if (cursor == null) result = contentURI.getPath();
       else {
          cursor.moveToFirst();
          int index = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
          result = cursor.getString(index);
          cursor.close();
       }
       return result;
    }
    
    public static String getSmallBitmap(String filePath) {  
              
        final BitmapFactory.Options options = new BitmapFactory.Options();  
        options.inJustDecodeBounds = true;//get real size, save in options
        BitmapFactory.decodeFile(filePath, options);
        
        options.inSampleSize = calculateInSampleSize(options, (int)_maxWidth, (int)_maxHeigh); //calc scale by _maxWidth,_maxHeigh, and real size in options
        options.inJustDecodeBounds = false;
          
        Bitmap bm = BitmapFactory.decodeFile(filePath, options);
        if(bm == null){  
            return  null;  
        }  
        
        ByteArrayOutputStream baos = null ;  
        try{  
            baos = new ByteArrayOutputStream();  
            Log.d(TAG, "_qualityRatio=" + _qualityRatio);
            bm.compress(Bitmap.CompressFormat.JPEG, (int)_qualityRatio, baos);
        }finally{  
            try {  
                if(baos != null)  
                    baos.close() ;  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
        }

        
        byte[] output = Base64.encode(baos.toByteArray(), Base64.NO_WRAP);
        String base64Image = new String(output);
        Log.d(TAG, "base64ImageLength=" + base64Image.length());
        
        return base64Image;
    }  
    
    public static int calculateInSampleSize(BitmapFactory.Options op, int reqWidth, int reqHeight) {  
        int originalWidth = op.outWidth;  
        int originalHeight = op.outHeight;  
        Log.d(TAG, "originalWidth=" + originalWidth);
        Log.d(TAG, "originalHeight=" + originalHeight);
        Log.d(TAG, "reqWidth=" + reqWidth);
        Log.d(TAG, "reqHeight=" + reqHeight);
        
        int inSampleSize = 1;  
        if (originalWidth > reqWidth || originalHeight > reqHeight) {  
            int halfWidth = originalWidth / 2;  
            int halfHeight = originalHeight / 2;  
            while ((halfWidth / inSampleSize > reqWidth)  
                    &&(halfHeight / inSampleSize > reqHeight)) {  
                inSampleSize *= 2;  
  
            }  
        }  
        Log.d(TAG, "inSampleSize=" + inSampleSize);
        return inSampleSize;  
    } 
}