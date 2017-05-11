#ifdef USE_ANYSDK

#include "libAnysdk.h"
#include "tolua++.h"

static std::string lastDataString = "";

using namespace anysdk::framework;

namespace game {
	/************************************ SDK CallBack START **********************************/
    class UserActionListener_Impl:public UserActionListener
    {
        void onActionResult(ProtocolUser* pPlugin, UserActionResultCode code, const char* msg)
        {
            CCLOG("[CPP-print] [INFO][libAnysdk][%s][code=%d][msg=%s]", __FUNCTION__, code, msg);
            
            bool _userLogined = false;
            switch(code)
            {
                case kInitSuccess://初始化SDK成功回调
                    break;
                case kInitFail://初始化SDK失败回调
                    break;
                case kLoginSuccess://登陆成功回调
                    //rapidjson::Document d;
                    //d.Parse<0>(jsonStr.c_str());

                    // if (d.HasMember("account")) roleId = d["account"].GetString();
                    // if (d.HasMember("password")) roleId = d["password"].GetString();

                    libPlatform::getInstance()->loginCallBack(0, msg);
                    break;
                case kLoginNetworkError://登陆失败回调
                case kLoginCancel://登陆取消回调
                case kLoginFail://登陆失败回调
                    libPlatform::getInstance()->loginCallBack(-1, msg);
                    break;
                case kLogoutSuccess://登出成功回调
                    libPlatform::getInstance()->logoutCallBack(0, msg);
                    break;
                case kLogoutFail://登出失败回调
                    libPlatform::getInstance()->logoutCallBack(-1, msg);
                    break;
                case kPlatformEnter://平台中心进入回调
                    break;
                case kPlatformBack://平台中心退出回调
                    break;
                case kPausePage://暂停界面回调
                    break;
                case kExitPage://退出游戏回调
                    break;
                case kAntiAddictionQuery://防沉迷查询回调
                    break;
                case kRealNameRegister://实名注册回调
                    break;
                case kAccountSwitchSuccess://切换账号成功回调
                    break;
                case kAccountSwitchFail://切换账号成功回调
                    break;
                default:
                    break;
            }
        }
    };
    
    class PayResultListener_Impl:public PayResultListener
    {
        void onPayInitResult(PayResultCode ret, const char* msg, TProductInfo info)
        {
            CCLOG("[CPP-print] [INFO][libAnysdk][%s][ret=%d][msg=%s]", __FUNCTION__, ret, msg);
            
            switch(ret)
            {
                case kPayInitSuccess:
                    CCLOG("[CPP-print] [INFO][libAnysdk][%s]pay init ok", __FUNCTION__);
                    break;
                default:
                    CCLOG("[CPP-print] [INFO][libAnysdk][%s]pay init error", __FUNCTION__);
                    break;
            }
        }

        
        void onPayResult(PayResultCode ret, const char* msg, TProductInfo info)
        {
            CCLOG("[CPP-print] [INFO][libAnysdk][%s][ret=%d][msg=%s]", __FUNCTION__, ret, msg);
            
            switch(ret)
            {
                case kPaySuccess://支付成功回调
                    libPlatform::getInstance()->payCallBack(0, msg);
                    break;
                case kPayFail://支付失败回调
                    libPlatform::getInstance()->payCallBack(-1, msg);
                    break;
                case kPayCancel://支付取消回调
                    libPlatform::getInstance()->payCallBack(-2, msg);
                    break;
                case kPayNetworkError://支付超时回调
                    libPlatform::getInstance()->payCallBack(-3, msg);
                    break;
                case kPayProductionInforIncomplete://支付超时回调
                    libPlatform::getInstance()->payCallBack(-4, msg);
                    break;
                    /**
                     * 新增加:正在进行中回调
                     * 支付过程中若SDK没有回调结果，就认为支付正在进行中
                     * 游戏开发商可让玩家去判断是否需要等待，若不等待则进行下一次的支付
                     */
                case kPayNowPaying:
                    libPlatform::getInstance()->payCallBack(-5, msg);
                    break;
                default:
                    break;
            }
        }
        
    };
	/************************************ SDK CallBack END **********************************/

	libAnysdk::libAnysdk()
	{
		/*init callback*/
		UserActionListener_Impl* userListener = NULL;
		PayResultListener_Impl* payListener = NULL;

		userListener = new UserActionListener_Impl();
		payListener = new PayResultListener_Impl();

		//获取AgentManager
		AgentManager* agent = AgentManager::getInstance();
		std::string appKey = "6A48ADE8-3FB3-97CE-B715-B5F3DE853A1C";
		std::string appSecret = "e2fa1a8c65c1bc32bc1bcd5c829c81b3";
		std::string privateKey = "3D39FFF01D046524217A7BFC3E6FBA52";
		std::string oauthLoginServer = "http://oauth.anysdk.com/api/OauthLoginDemo/Login.php";
		//初始化agent
		agent->init(appKey, appSecret, privateKey, oauthLoginServer);
		//加载插件
		agent->loadAllPlugins();

		//初始化用户系统监听
		if (AgentManager::getInstance()->getUserPlugin())
		{
			AgentManager::getInstance()->getUserPlugin()->setActionListener(userListener);
		}

        std::map<std::string , ProtocolIAP*>* _pluginsIAPMap = AgentManager::getInstance()->getIAPPlugin();
		std::map<std::string, ProtocolIAP*>::iterator iter;
		for (iter = _pluginsIAPMap->begin();iter!=_pluginsIAPMap->end();iter++)
		{
			(iter->second)->setResultListener(payListener);
		}
	}

	libAnysdk::~libAnysdk()
	{

	}

	void libAnysdk::init(string jInfo)
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
		CC_SAFE_FREE(_platformInfo);
		_platformInfo = new PLATFORM_INFO_S(jInfo);

	    _platformInfo->channelName = AgentManager::getInstance()->getChannelId();


		return;
	}

	bool libAnysdk::hasUserPugin()
	{
        bool isHave = false;
        if (AgentManager::getInstance()->getUserPlugin() != nullptr)
        {
            isHave = true;
        }
        
		return isHave;
	}

	void libAnysdk::login()
	{
		CCLOG("[CPP-print] [INFO][libAnysdk][%s]", __FUNCTION__);

		AgentManager::getInstance()->getUserPlugin()->login("login");
	}

	void libAnysdk::logout()
	{
		CCLOG("[CPP-print] [INFO][libAnysdk][%s]", __FUNCTION__);
	}

	void libAnysdk::report(string type, string jInfo)
	{
		CCLOG("[CPP-print] [INFO][libAnysdk][%s][type=%s][info=%s]", __FUNCTION__, type.c_str(), jInfo.c_str());
		
		//CC_SAFE_FREE(_roleInfo);
		_roleInfo = new ROLE_INFO_S(jInfo);

	}
    
    string libAnysdk::getCustomParam()
    {
        return AgentManager::getInstance()->getCustomParam();
    }
    
	void libAnysdk::pay(string jInfo)
	{
        CCLOG("[CPP-print] [INFO][%s]%s", __FUNCTION__, jInfo.c_str());
        
        std::map<std::string , ProtocolIAP*>* _pluginsIAPMap = AgentManager::getInstance()->getIAPPlugin();
        std::map<std::string , ProtocolIAP*>::iterator it = _pluginsIAPMap->begin();
        if(_pluginsIAPMap)
        {
            std::map<std::string, std::string> productInfo;
            
            PAY_INFO_S* payInfo = new PAY_INFO_S(jInfo);
            
            productInfo["Product_Id"] = payInfo->id;
            productInfo["Product_Name"] = payInfo->name;
            productInfo["Product_Price"] = toString(payInfo->price);
            productInfo["Product_Count"] = toString(payInfo->count);
            productInfo["Product_Desc"] = payInfo->desc;
            
            productInfo["Server_Id"] = _roleInfo->serverId;
            productInfo["Role_Id"] = _roleInfo->roleId;
            productInfo["Role_Name"] = _roleInfo->roleName;
            productInfo["Role_Grade"] = _roleInfo->roleLevel;
            productInfo["Role_Balance"] = _roleInfo->roleBalance;
            productInfo["EXT"] = payInfo->ext;
            
            if(_pluginsIAPMap->size() == 1)//只存在一种支付方式
            {
                (it->second)->payForProduct(productInfo);
            }
            else //多种支付方式
            {
                //开发者需要自己设计多支付方式的逻辑及UI
                CCLOG("[CPP-print] [ERROR][%s]multiple pay-plugin used!", __FUNCTION__);

            }
        }
	}

	void libAnysdk::exitGame()
	{
		CCLOG("[CPP-print] [INFO][libAnysdk][%s]", __FUNCTION__);
	}

	//´´½¨½ÇÉ«ÐÅÏ¢µÄjson×Ö·û´®
	string libAnysdk::getRoleDataJString()
	{
		std::stringstream ss;
		ss << "{";
		ss << "\"roleId\":";
		ss << "\"";
		ss << _roleInfo->roleId;
		ss << "\"";
		ss << ",";

		ss << "\"roleName\":";
		ss << "\"";
		ss << _roleInfo->roleName;
		ss << "\"";
		ss << ",";

		ss << "\"roleLevel\":";
		ss << "\"";
		ss << _roleInfo->roleLevel;
		ss << "\"";
		ss << ",";

		ss << "\"zoneId\":";
		ss << "\"";
		ss << _roleInfo->serverId;
		ss << "\"";
		ss << ",";

		ss << "\"zoneName\":";
		ss << "\"";
		ss << _roleInfo->serverName;
		ss << "\"";
		ss << ",";

		ss << "\"balance\":";
		ss << "\"";
		ss << _roleInfo->roleBalance;
		ss << "\"";
		ss << ",";

		ss << "\"vip\":";
		ss << "\"";
		ss << _roleInfo->roleVip;
		ss << "\"";
		ss << ",";

		ss << "\"partyName\":";
		ss << "\"";
		ss << _roleInfo->roleGuildName;
		ss << "\"";
		ss << ",";

		ss << "\"roleCTime\":";
		ss << "\"";
		ss << _roleInfo->roleLevelUpTime;
		ss << "\"";
		ss << ",";

		ss << "\"roleLevelMTime\":";
		ss << "\"";
		ss << "1000";
		ss << "\"";

		ss << "}";

		lastDataString = ss.str();

		return ss.str();
	}
}

#endif
