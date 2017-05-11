/*
*/

#ifndef __LIBPLATFORM__H__
#define __LIBPLATFORM__H__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "CCDatas.h"
#include "CCLuaEngine.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#endif

using namespace cocos2d;
using namespace ui;
using namespace cocostudio;
using namespace std;

USING_NS_CC_EXT;

//ƽ̨��Ϣ
struct PLATFORM_INFO_S
{
	string channelName; //�Ӱ�������־
	string loginUrl;
	string payUrl;
    string packageName;

	PLATFORM_INFO_S(string jsonStr)
	{
		rapidjson::Document d;
		d.Parse<0>(jsonStr.c_str());

		channelName = d["channelName"].GetString();
		loginUrl = d["loginUrl"].GetString();
		payUrl = d["payUrl"].GetString();
        packageName = d["packageName"].GetString();
	}
};

struct ROLE_INFO_S
{
	string roleId= "1";
    string roleType= "1"; // male/female or zhanshi/gongjianshou/fashi
	string roleName= "1";
	string roleLevel= "1";
	string roleBalance= "1"; //left money
	string roleVip= "1";
	string roleGuildName= "1";
    string roleLevelUpTime = "1";

	string serverId = "1";
	string serverName = "1";

	string platformId = "1";
    
    string roleCTime = "0";

	ROLE_INFO_S(string jsonStr)
	{
		rapidjson::Document d;
		d.Parse<0>(jsonStr.c_str());

		if (d.HasMember("roleId")) roleId = d["roleId"].GetString();
        if (d.HasMember("roleType")) roleType = d["roleType"].GetString();
		if (d.HasMember("roleName")) roleName = d["roleName"].GetString();
		if (d.HasMember("roleLevel")) roleLevel = d["roleLevel"].GetString();
		if (d.HasMember("roleBalance")) roleBalance = d["roleBalance"].GetString();
		if (d.HasMember("roleVip")) roleVip = d["roleVip"].GetString();
		if (d.HasMember("roleGuildName")) roleGuildName = d["roleGuildName"].GetString();
		if (d.HasMember("roleLevelUpTime")) roleLevelUpTime = d["roleLevelUpTime"].GetString();
		if (d.HasMember("serverId")) serverId = d["serverId"].GetString();
		if (d.HasMember("serverName")) serverName = d["serverName"].GetString();
		if (d.HasMember("platformId")) platformId = d["platformId"].GetString();
        if (d.HasMember("roleCTime")) platformId = d["roleCTime"].GetString();
	}
};

struct PAY_INFO_S
{
	string id = "";
	string name = "";
	float price = 1;
	unsigned int count = 1;
	string desc = "";
    string userid = "";
    string ext = "";

	PAY_INFO_S(string jsonStr)
	{
		rapidjson::Document d;
		d.Parse<0>(jsonStr.c_str());

		id = d["id"].GetString();
		if (d.HasMember("name")) name = d["name"].GetString();
		if (d.HasMember("price")) price = d["price"].GetDouble();
		if (d.HasMember("count")) count = d["count"].GetUint();
		if (d.HasMember("desc")) desc = d["desc"].GetString();
        if (d.HasMember("userid")) userid = d["userid"].GetString();
        if (d.HasMember("ext")) ext = d["ext"].GetString();
	}
};

namespace game {
	class libPlatform : public Ref
	{
	public:
		libPlatform()   {};
		~libPlatform()  {};
		static libPlatform* getInstance();

		string getFlag();
		
		void setLoginCallBack(LUA_FUNCTION cb);
		void setLogoutCallBack(LUA_FUNCTION cb);
		void setPayCallBack(LUA_FUNCTION cb);
		void setExitGameCallBack(LUA_FUNCTION cb);
        bool isUseBeeCloud();

		virtual void init(string jInfo);
        virtual bool hasUserPugin();
        
		virtual void login();
		virtual void logout();

		/*�ϱ��û�����,�ڽ�ɫ������Ϸ֮ǰ,����Ҫ������һ��,���򲿷�ƽ̨���и�������
		* type ˵��:
		* ������ɫ: "createRole"
		* ��ɫ����: "levelUp",
		* ѡ������: "choseServer",
		* ѡȡ��ɫ: "choseRole",
		* ��ʼ��Ϸ: "startGame"
		* ����Ϸ: "exitGame"
		*/
		virtual void report(string type, string jInfo);
		virtual void pay(string jInfo); //����
		virtual void exitGame();
        virtual string getCustomParam();
    
		/* ����sdk����ַ���֮��ص� */
		/* 0: �ɹ�
		*  -1: http�������
		*  ����: ��sdk������
		*/
		void loginCallBack(int code, string strResult);
		void logoutCallBack(int code,  string strResult);
		void payCallBack(int code,  string strResult);
		void exitGameCallBack(int code,  string strResult);
        /* TALKING_DATA */
        void tdInit();
        void tdSetAccount(string account);
        void tdSetAccountType(int accountType);
        void setGameServer(string gameServer);
        
		/* lua���ù����Ļص� */
		LUA_FUNCTION _loginCallBack = -1;
		LUA_FUNCTION _logoutCallBack = -1;
		LUA_FUNCTION _payCallBack = -1;
		LUA_FUNCTION _exitGameCallBack = -1;
		PLATFORM_INFO_S* _platformInfo = nullptr;
		ROLE_INFO_S* _roleInfo = nullptr;
		string _platFormFlag = "";

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		//extern JavaVM* m_pVM; //define in javaactivity-android.cpp
#endif

		/* ���߷��� */
		string urlEncode(std::string str_source);
        
        string toString(float f)
        {
                stringstream ss;
                ss << f;
                return ss.str();
        }
        
        string toString(unsigned int i)
        {
            stringstream ss;
            ss << i;
            return ss.str();
        }
	};
}

#endif
