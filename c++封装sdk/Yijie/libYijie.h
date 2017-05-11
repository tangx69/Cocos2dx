/*
*/
#ifdef USE_YIJIE

#ifndef __LIBYIJIE__H__
#define __LIBYIJIE__H__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "CCDatas.h"
#include "libPlatform.h"
#include "SFGameNativeInterface.hpp"
#include "network/HttpClient.h"

using namespace cocos2d;
using namespace cocos2d::network;
using namespace ui;
using namespace cocostudio;
using namespace std;

USING_NS_CC_EXT;

namespace game {
	class libYijie : public libPlatform
	{
	public:
		libYijie();
		~libYijie();

		//libPlatform ʵ��
		virtual void init(string jInfo);
		virtual void login();
		virtual void logout();
		virtual void report(string type, string jInfo); //�ϱ��û�����
		virtual void pay(string jInfo); //����
		virtual void exitGame();
		
		//���÷���
		string getRoleDataJString();
	};
}

#endif

#endif
