/*
*/

#include "libPlatform.h"
#include "tolua++.h"

#ifdef USE_YIJIE
#include "LibYijie.h"
#endif
#ifdef USE_ANYSDK
#include "LibAnysdk.h"
#endif
#ifdef USE_TALKINGDATA
#include "TDCCAccount.h"
#include "TDCCTalkingDataGA.h"
#endif

namespace game {
	static libPlatform *m_sPlatform = nullptr;
#ifdef USE_TALKINGDATA
    static TDCCAccount* mTDGAaccount = nullptr;
#endif
    
	libPlatform* libPlatform::getInstance()
	{
        if (m_sPlatform)
        {
            return m_sPlatform;
        }        
#if USE_YIJIE
		m_sPlatform = new libYijie;
		m_sPlatform->_platFormFlag = "YIJIE";
#endif

#if USE_ANYSDK
		m_sPlatform = new libAnysdk;
		m_sPlatform->_platFormFlag = "ANYSDK";
#endif

		if (!m_sPlatform)
		{
			m_sPlatform = new libPlatform;
			m_sPlatform->_platFormFlag = "DEFAULT";
		}

		return m_sPlatform;
	}

	string libPlatform::getFlag()
	{
		return _platFormFlag;
	}

	bool libPlatform::hasUserPugin()
	{
		return true;
	}

	void libPlatform::setLoginCallBack(LUA_FUNCTION cb)
	{
		_loginCallBack = cb;
	}
	void libPlatform::setLogoutCallBack(LUA_FUNCTION cb)
	{
		_logoutCallBack = cb;
	}
	void libPlatform::setPayCallBack(LUA_FUNCTION cb)
	{
		_payCallBack = cb;
	}
	void libPlatform::setExitGameCallBack(LUA_FUNCTION cb)
	{
		_exitGameCallBack = cb;
	}
    
    bool libPlatform::isUseBeeCloud()
    {
        bool isUse = false;
#ifdef USE_BEECLOUD
        isUse = true;
#endif 
        return isUse;
    }
    
	//luaµ÷ÓÃ¹ýÀ´.³õÊ¼»¯Æ½Ì¨Ïà¹ØÐÅÏ¢
	//channelName: ÇþµÀÃû,ÀýÈçyijieµÄ"{xxxx-xxxxx}"
	//loginUrl: µÇÂ¼»Øµ÷µØÖ·
	//payUrl:   ¸¶·Ñ»Øµ÷µØÖ·
	void libPlatform::init(string jInfo)
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
		CC_SAFE_FREE(_platformInfo);
		_platformInfo = new PLATFORM_INFO_S(jInfo);  
	}

	void libPlatform::login()
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
	}

	void libPlatform::logout()
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
	}

	void libPlatform::report(string type, string jInfo)
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
	}

	void libPlatform::pay(string jInfo)
	{
		CCLOG("[CPP-print] [ERROR][%s]%s", __FUNCTION__, jInfo.c_str());
		PAY_INFO_S* payInfo = new PAY_INFO_S(jInfo);
	}

	void libPlatform::exitGame()
	{
		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
	}

	void libPlatform::loginCallBack(int code, string strResult)
	{
		LUA_FUNCTION callback = _loginCallBack;
		if (callback == -1)
		{
			CCLOG("[CPP-print] [ERROR][%s]not init in lua", __FUNCTION__);
			return;
		}

		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
		auto stack = LuaEngine::getInstance()->getLuaStack();
		stack->pushInt(code);
		stack->pushString(strResult.c_str());
		stack->executeFunctionByHandler(callback, 2);
	}

	void libPlatform::logoutCallBack(int code, string strResult)
	{
		LUA_FUNCTION callback = _logoutCallBack;
		if (callback == -1)
		{
			CCLOG("[CPP-print] [ERROR][%s]not init in lua", __FUNCTION__);
			return;
		}

		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
		auto stack = LuaEngine::getInstance()->getLuaStack();
		stack->pushInt(code);
		stack->pushString(strResult.c_str());
		stack->executeFunctionByHandler(callback, 2);
	}

	void libPlatform::payCallBack(int code, string strResult)
	{
		LUA_FUNCTION callback = _payCallBack;
		if (callback == -1)
		{
			CCLOG("[CPP-print] [ERROR][%s]not init in lua", __FUNCTION__);
			return;
		}

		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
		auto stack = LuaEngine::getInstance()->getLuaStack();
		stack->pushInt(code);
		stack->pushString(strResult.c_str());
		stack->executeFunctionByHandler(callback, 2);
	}

	void libPlatform::exitGameCallBack(int code, string strResult)
	{
		LUA_FUNCTION callback = _exitGameCallBack;
		if (callback == -1)
		{
			CCLOG("[CPP-print] [ERROR][%s]not init in lua", __FUNCTION__);
			return;
		}

		CCLOG("[CPP-print] [INFO][%s]", __FUNCTION__);
        auto stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushInt(code);
        stack->pushString(strResult.c_str());
        stack->executeFunctionByHandler(callback, 2);
	}
    
    string libPlatform::getCustomParam()
    {
        CCLOG("[CPP-print] [INFO][libPlatform][getCustomParam]%s", "");
        string customParam = "1";
        
        return customParam;
    }

    void libPlatform::tdInit()
    {
        CCLOG("[CPP-print][INFO][libPlatform][tdInit]%s", _platformInfo->packageName.c_str());
#ifdef USE_TALKINGDATA
        TDCCTalkingDataGA::onStart("8726BE0C745D45B38D10EA152D186C52", _platformInfo->packageName.c_str());
#endif
    }

    void libPlatform::tdSetAccount(string account)
    {
        CCLOG("[CPP-print] [INFO][libPlatform][tdSetAccount]%s", account.c_str());
#ifdef USE_TALKINGDATA
        mTDGAaccount = TDCCAccount::setAccount(account.c_str());
#endif
    }
    
    void libPlatform::tdSetAccountType(int accountType)
    {

        CCLOG("[CPP-print] [INFO][libPlatform][tdSetAccountType]%d", accountType);
#ifdef USE_TALKINGDATA
        mTDGAaccount->setAccountType(mTDGAaccount->kAccountRegistered);
#endif
    }
    
    void libPlatform::setGameServer(string gameServer)
    {

        CCLOG("[CPP-print] [INFO][libPlatform][setGameServer]%s", gameServer.c_str());
#ifdef USE_TALKINGDATA        
        mTDGAaccount->setGameServer(gameServer.c_str());
#endif
    }

	string libPlatform::urlEncode(std::string str_source)
	{
		char const *in_str = str_source.c_str();
		int in_str_len = strlen(in_str);
		int out_str_len = 0;
		string out_str;
		register unsigned char c;
		unsigned char *to, *start;
		unsigned char const *from, *end;
		unsigned char hexchars[] = "0123456789ABCDEF";

		from = (unsigned char *)in_str;
		end = (unsigned char *)in_str + in_str_len;
		start = to = (unsigned char *)malloc(3 * in_str_len + 1);

		while (from < end) {
			c = *from++;

			if (c == ' ') {
				*to++ = '+';
			}
			else if ((c < '0' && c != '-' && c != '.') || (c < 'A' && c > '9')
				|| (c > 'Z' && c < 'a' && c != '_') || (c > 'z' && c != '~')) {
				to[0] = '%';
				to[1] = hexchars[c >> 4];
				to[2] = hexchars[c & 15];
				to += 3;
			}
			else {
				*to++ = c;
			}
		}
		*to = 0;

		out_str_len = to - start;
		out_str = (char *)start;
		free(start);
		return out_str;
	}
}


