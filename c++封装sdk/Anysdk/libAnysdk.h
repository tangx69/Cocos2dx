/*
*/
#ifdef USE_ANYSDK

#ifndef __LIBANYSDK__H__
#define __LIBANYSDK__H__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "CCDatas.h"
#include "libPlatform.h"
#include "network/HttpClient.h"

//sdk
#include "AgentManager.h"
using namespace anysdk::framework;
//sdk

using namespace cocos2d;
using namespace cocos2d::network;
using namespace ui;
using namespace cocostudio;
using namespace std;

USING_NS_CC_EXT;

namespace game {
    class libAnysdk : public libPlatform
	{
	public:
		libAnysdk();
		~libAnysdk();

		//libPlatform 实现
		virtual void init(string jInfo);
        virtual bool hasUserPugin();
		virtual void login();
		virtual void logout();
		virtual void report(string type, string jInfo); //上报用户数据
		virtual void pay(string jInfo); //购买
		virtual void exitGame();
        virtual string getCustomParam();
        
		//自用方法
		string getRoleDataJString();
	};
}

#endif

#endif
