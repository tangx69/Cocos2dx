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

		//libPlatform ʵ��
		virtual void init(string jInfo);
        virtual bool hasUserPugin();
		virtual void login();
		virtual void logout();
		virtual void report(string type, string jInfo); //�ϱ��û�����
		virtual void pay(string jInfo); //����
		virtual void exitGame();
        virtual string getCustomParam();
        
		//���÷���
		string getRoleDataJString();
	};
}

#endif

#endif
