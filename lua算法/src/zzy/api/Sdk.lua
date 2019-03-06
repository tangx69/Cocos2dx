---
-- @module Sdk

---
-- @field [parent=#Sdk] #bool PLATFORM_DEFAULT 

---
-- @field [parent=#Sdk] #bool PLATFORM_PLAYYX

---
-- @field [parent=#Sdk] #bool PLATFORM_HDUC



---
-- 获取平台标识
-- @function [parent=#Sdk] getFlag
-- @return #string ret

---
-- 初始化sdk
-- @function [parent=#Sdk] init

---
-- 打开登录界面
-- @function [parent=#Sdk] openLogin

---
-- 认证到zzy
-- @function [parent=#Sdk] authToZzy
-- @param #string id
-- @param #string sign
-- @param #table extraData
-- @param #function onDone callback(errorCode,id)


---
-- 设置角色信息
-- @function [parent=#Sdk] setRoleInfor
-- @function [parent=#Sdk] 
-- @param #string roleInfo  角色id  ( json串 roleId(角色id),roleName(角色名),roleLevel(角色等级)，zoneId(区id) ,zoneName(区名字)}


---
-- 扩展方法
-- @function [parent=#Sdk] extendFunc
-- @function [parent=#Sdk]  
-- @param #string info {"f":"login|share|charge","data":"{"t":"WX|SINAWB|QQ","link":"","image":"","text":"","extra":""}"} 
 
---
-- 切换账号
-- @function [parent=#Sdk] changeAccount

---
-- 请求支付
-- @function [parent=#Sdk] openCharge
-- @param #string orderInfo 订单信息 json字符串   {callBackData="svrid=sdfdsf#itemid=123",roleID="roleID",roleName="roleName",amount=5}

---
-- 打开用户中心
-- @function [parent=#Sdk] openUcenter

---
-- 事件列表
-- @field [parent=#Sdk] #SdkEvent Events

---
-- @module SdkEvent

---
-- 初始化完成事件
-- @field [parent=#SdkEvent] #string initDone

---
-- 登录完成事件 {data(额外数据 json串 id(用户id),sign(验证签名),name(用户昵称)，sid session id)}
-- @field [parent=#SdkEvent] #string loginDone

---
-- 充值完成事件 {ok(0=成功，其他error),data(额外数据 json串 payWay(支付通道),ordereId(订单号)，amount 充值金额)}
-- @field [parent=#SdkEvent] #string chargeDone

return nil