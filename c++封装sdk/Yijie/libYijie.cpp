#ifdef USE_YIJIE

#include "libYijie.h"
#include "tolua++.h"

static std::string lastDataString = "";

namespace game {
	/************************************ SDK CallBack START **********************************/
	class SFNativeOnlineLoginCallbackImpl : public SFNativeOnlineLoginCallback, cocos2d::Ref {

		void onLoginSuccess(SFNativeOnlineUser* user, const char* remain) {
			CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
			libPlatform* platForm = libPlatform::getInstance();

			string url;
			url += platForm->_platformInfo->loginUrl;
			url += "?app=" + platForm->urlEncode(user->productCode);
			url += "&sdk=" + platForm->urlEncode(user->channelId);
			url += "&uin=" + platForm->urlEncode(user->channelUserId);
			url += "&sess=" + platForm->urlEncode(user->token);
			url += "&ext=" + platForm->urlEncode(platForm->_platformInfo->channelName);

			/* 去游服验证 */
			CCLOG("[CPP-print] [INFO][libYijie][%s]url=%s", __FUNCTION__, url.c_str());
			loginCheck(url.c_str());
		}

		void onLoginFailed(const char* r, const char* remain) {
			CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
			libPlatform::getInstance()->loginCallBack(-1, remain);
		}

		void onLogout(const char* remain) {
			CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
            Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
                libPlatform::getInstance()->logoutCallBack(0, remain);
            });
		}

		void loginCheck(const char* pData)
		{
			CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
			HttpRequest* request = new HttpRequest();

			request->setUrl(pData);
			request->setRequestType(HttpRequest::Type::GET);
			request->setResponseCallback(this, httpresponse_selector(SFNativeOnlineLoginCallbackImpl::onHttpRequestCompleted));
			request->setTag("SFLOGIN");
			cocos2d::network::HttpClient::getInstance()->send(request);
			request->release();
		}

		void onHttpRequestCompleted(HttpClient *sender, HttpResponse *response)
		{
			CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);

			if (!response) {
				libPlatform::getInstance()->loginCallBack(-1, "!response");
				return;
			}

			if (0 != strlen(response->getHttpRequest()->getTag())) {
				CCLOG("%s completed", response->getHttpRequest()->getTag());
			}

			long statusCode = response->getResponseCode();
			char statusString[64] = {};

			sprintf(statusString, "HTTP Status Code: %ld, tag = %s", statusCode, response->getHttpRequest()->getTag());

			if (!response->isSucceed()) {
				libPlatform::getInstance()->loginCallBack(-1, "!response->isSucceed()");
				return;
			}

			if (statusCode != 200){
				CCLOG("[ERROR][%s]response code: %ld", __FUNCTION__, statusCode);
				libPlatform::getInstance()->loginCallBack(-1, "statusCode != 200");
				return;
			}

			std::vector<char>* buffer = response->getResponseData();
			string result_str(buffer->begin(), buffer->end());
			CCLOG("[CPP-print] [INFO][libYijie][%s][response data=%s]", __FUNCTION__, result_str.c_str());
			
			if (result_str.length() > 1 && (result_str[0] == '{'))
			{
                Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
                    libPlatform::getInstance()->loginCallBack(0, result_str);
                });
			}
			else
			{
				libPlatform::getInstance()->loginCallBack(-2, result_str);
			}
		}
	};

	/* 付费 */
	class SFNativeOnlinePayResultCallbackImpl : public SFNativeOnlinePayResultCallback {

		virtual void onFailed(const char* remain) {
			libPlatform::getInstance()->payCallBack(-1, remain);
		}
		virtual void onSuccess(const char* remain) {
			libPlatform::getInstance()->payCallBack(-1, remain);
		}
		virtual void onOderNo(const char* orderNo) {
		}

	};

	/* 游戏退出 */
	class SFNativeOnlineExitCallbackImpl : public SFNativeOnlineExitCallback {

		/*SDK没有退出界面时，走此方法，可以自定义退出界面*/
		void onNoExiterProvide() {
            CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
            //SFGameNativeInterface::onDestroy();
            //libPlatform::getInstance()->exitGameCallBack(0, "onNoExiterProvide");
            //游戏没有提供退出确认界面，所以注释掉，不然一点返回键就退出了
		}

		/*SDK有退出界面时调用此方法
		* result
		* 		true：退出
		* 		false：取消退出*/
		void onSDKExit(bool result) {
            Director::getInstance()->end();
 #if 0
            CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
			if (!result)  return;
            //sdk弹出了退出界面。且用户点了确认，这里直接退出。游戏没有二次确认
            CCLOG("[CPP-print] [INFO][libYijie][%s]1", __FUNCTION__);
            //SFGameNativeInterface::onDestroy();
            CCLOG("[CPP-print] [INFO][libYijie][%s]2", __FUNCTION__);
            libPlatform::getInstance()->exitGameCallBack(0, "onSDKExit"); 
            CCLOG("[CPP-print] [INFO][libYijie][%s]3", __FUNCTION__);
 #endif
		}
	};

	/************************************ SDK CallBack END **********************************/

	libYijie::libYijie()
	{
		/*init callback*/
		SFNativeOnlineLoginCallbackImpl* loginCallback = NULL;
		SFNativeOnlineExitCallbackImpl* exitCallback = NULL;
		SFNativeOnlinePayResultCallbackImpl* payCallback = NULL;

		loginCallback = new SFNativeOnlineLoginCallbackImpl();
		SFGameNativeInterface::setLoginCallback(loginCallback);
        
        exitCallback = new SFNativeOnlineExitCallbackImpl();
        SFGameNativeInterface::setExitCallback(exitCallback);
        
		payCallback = new SFNativeOnlinePayResultCallbackImpl();
		SFGameNativeInterface::setPayResultCallback(payCallback);
	}

	libYijie::~libYijie()
	{

	}

	void libYijie::init(string jInfo)
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
		CC_SAFE_FREE(_platformInfo);
		_platformInfo = new PLATFORM_INFO_S(jInfo);

		return;
	}

	void libYijie::login()
	{
		CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);

		SFGameNativeInterface::login("login");
	}

	void libYijie::logout()
	{
		CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
		SFGameNativeInterface::logout("logout");
	}

	void libYijie::report(string type, string jInfo)
	{
		CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
		
		//CC_SAFE_FREE(_roleInfo);
		_roleInfo = new ROLE_INFO_S(jInfo);

		SFGameNativeInterface::setRoleData(_roleInfo->roleId.c_str(),
										   _roleInfo->roleName.c_str(),
										   _roleInfo->roleLevel.c_str(),
										   _roleInfo->serverId.c_str(),
										   _roleInfo->serverName.c_str());

		string cmd = "gamestart";
		if (type == "createRole")
		{
			cmd = "createrole";
		}
		else if (type == "levelUp")
		{
			cmd = "levelup";
		}
		else if (type == "enterServer")
		{
			cmd = "enterServer";
		}
		else if (type == "loginGameRole")
		{
			cmd = "loginGameRole";
		}
		else if (type == "startGame")
		{
			cmd = "gamestart";
		}

		SFGameNativeInterface::setData(cmd.c_str(), jInfo.c_str());
	}

	void libYijie::pay(string jInfo)
	{
		CCLOG("[CPP-print] [INFO][libYijie][%s]", __FUNCTION__);
		PAY_INFO_S* payInfo = new PAY_INFO_S(jInfo);

		const char* itemName = payInfo->name.c_str();
		int unitPrice = payInfo->price;
		int count = payInfo->count;

		string callBackInfoStr = "";
		callBackInfoStr += "user_id:" + _roleInfo->roleId;
		callBackInfoStr += ":product_id:" + payInfo->id;
		callBackInfoStr += ":server_id:" + _roleInfo->serverId;
		callBackInfoStr += ":em_platfomChannel:"+ _platformInfo->channelName;
        callBackInfoStr += ":account_id:"+ payInfo->userid;

		string callBackUrlStr = _platformInfo->payUrl;
		SFGameNativeInterface::charge(itemName, unitPrice*100, count, callBackInfoStr.c_str(), callBackUrlStr.c_str());

		//CC_SAFE_FREE(payInfo);
	}

	void libYijie::exitGame()
	{
		/*调用易接退出方法*/
		SFGameNativeInterface::exit();
	}

	//创建角色信息的json字符串
	string libYijie::getRoleDataJString()
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
		ss << _roleInfo->roleCTime;
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
