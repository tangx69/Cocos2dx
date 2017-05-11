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


/*** BEECLOUD ***/
import cn.beecloud.BCPay;
import cn.beecloud.BCQuery;
import cn.beecloud.BeeCloud;
import cn.beecloud.async.BCCallback;
import cn.beecloud.async.BCResult;
import cn.beecloud.entity.BCBillOrder;
import cn.beecloud.entity.BCPayResult;
import cn.beecloud.entity.BCQueryBillResult;
import cn.beecloud.entity.BCReqParams;

public class BeeCloudAdapter {
    static final String BC_APPID = "7a6a929f-5318-4424-9a23-49b2f3925e49";
    static final String BC_APPSECTET = "f76f85d6-0973-4ede-a95e-a6793175acfb";
    static final String WX_APPPAY_APPID = "wx90628b6fcca37dc3";
    
	static final String TAG = "BeeCloud";
	static Cocos2dxActivity _appContex;
	
	public static void init(Cocos2dxActivity appContex) {
		_appContex = appContex;
		
        
        //BEECLOUD初始化
        BeeCloud.setSandbox(false);
        BeeCloud.setAppIdAndSecret(BC_APPID, BC_APPSECTET);
                
        // 如果用到微信支付，在用到微信支付的Activity的onCreate函数里调用以下函数.
        // 第二个参数需要换成你自己的微信AppID
        String initInfo = BCPay.initWechatPay(_appContex, WX_APPPAY_APPID);
        if (initInfo != null) {
            Log.e(TAG, "微信初始化失败：" + initInfo);
        }
	}
    
    public static void pay(int billType, int billTotalFee, String billTitle, String billNum, final int luaCallBack, String playerid,String channeltype,String userid,String productid,String serverid) {
        Log.d("BeeCloud", "pay start");
        
    	/* callBack */
        BCCallback bcCallback = new BCCallback() {
            @Override
            public void done(final BCResult bcResult) {
                final BCPayResult bcPayResult = (BCPayResult)bcResult;
                
                if (bcPayResult.getResult() == BCPayResult.RESULT_SUCCESS)
                {
                    
                	Utils.callLuaFunctionWithString(luaCallBack, "0");
                }
                
                if (bcPayResult.getResult() == BCPayResult.RESULT_FAIL)
                {
                	Utils.callLuaFunctionWithString(luaCallBack, "1");
                }
                
                if (bcPayResult.getResult() == BCPayResult.RESULT_CANCEL)
                {
                	Utils.callLuaFunctionWithString(luaCallBack, "1");
                }
                
                if (bcPayResult.getId() != null )
                {
                    Log.d("getId", bcPayResult.getId());
                }
                if (bcPayResult.getResult() != null)
                {
                    Log.d("getResult", bcPayResult.getResult());
                }
                if (bcPayResult.getErrCode() != null)
                {
                    Log.d("getErrCode", ""+bcPayResult.getErrCode());
                }
                if (bcPayResult.getErrMsg() != null)
                {
                    Log.d("getErrMsg", bcPayResult.getErrMsg());
                }
                if (bcPayResult.getDetailInfo() != null)
                {
                    Log.d("getDetailInfo", bcPayResult.getDetailInfo());
                }
            }
        };

        //创建支付参数类
        /*1: ZFB, 2: WX*/
        BCPay.PayParams payParam = new BCPay.PayParams();
        payParam.channelType = BCReqParams.BCChannelTypes.ALI_APP;
        if (billType == 2)
        {
            Log.d(TAG, "是微信支付!!!");
        	payParam.channelType = BCReqParams.BCChannelTypes.WX_APP;
            
            //如果是微信.但是未安装,则直接返回错误码
            if (!BCPay.isWXAppInstalledAndSupported() || !BCPay.isWXPaySupported())
            {
                Log.e(TAG, "未安装微信或者不支持此方式!!!");
                Utils.callLuaFunctionWithString(luaCallBack, "2");
                return;
            }
        }
        else
        {
            Log.d(TAG, "是支付宝支付!!!");
        }

        //商品描述, 32个字节内, 汉字以2个字节计
        payParam.billTitle = billTitle;
        Log.d(TAG, "billTitle="+billTitle);

        //支付金额，以分为单位，必须是正整数
        payParam.billTotalFee = billTotalFee*100;
        Log.d(TAG, "billTotalFee="+billTotalFee);

        //商户自定义订单号
        payParam.billNum = billNum;
        Log.d(TAG, "billNum="+billNum);
        
        //扩展参数，可以传入任意数量的key/value对来补充对业务逻辑的需求，可以不设置
        Map<String, String> mapOptional = new HashMap<String, String>();
        mapOptional.put("playerid", playerid);
        mapOptional.put("channeltype", channeltype);
        mapOptional.put("userid", userid);
        mapOptional.put("productid", productid);
        mapOptional.put("serverid", serverid);
        mapOptional.put("bcappid", BC_APPID);
        payParam.optional = mapOptional;
        
        //发起支付
        Log.d("BeeCloud", "pay call, appid="+BC_APPID);
        BCPay.getInstance(_appContex).reqPaymentAsync(payParam, bcCallback);
	}
}
