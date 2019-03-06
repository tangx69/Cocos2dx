---
-- c/c++写的工具
-- @module cUtils

---
-- 使用系统默认浏览器打开链接
-- @function [parent=#cUtils] openUrl
-- @param #string url

---
-- 获取文件夹下的文件列表
-- @function [parent=#cUtils] getDirFiles
-- @param #dirPath
-- @return #string ret(所有文件全路径拼成一个串，分隔符",")

---
-- 获取设备唯一标识
-- @function [parent=#cUtils] getDeviceID
-- @return #string ret
--
-- ---
-- 获取版本号
-- @function [parent=#cUtils] getVersion
-- @return #string ret


---
-- 是否是debug模式
-- @function [parent=#cUtils] isDebug
-- @return #bool ret

---
-- 获取设备机型
-- @function [parent=#cUtils] getDeviceModel
-- @return #string ret
-- 
-- 
---
-- 获取设备系统
-- @function [parent=#cUtils] getDeviceSystem
-- @return #string ret

---
-- 删除文件/文件夹
-- @function [parent=#cUtils] removeFile
-- @param #string path 全路径，可以是文件，也可以是文件夹
-- @return #int ret(0=成功，其他=errorCode)

---
-- 将字符串写入文件
-- @function [parent=#cUtils] writeFileWithString
-- @param #string content 写入内容
-- @param #string path 全路径
-- @return #int ret(0=成功，其他=errorCode)

--[[
---
-- 根据差量生成新文件
-- @function [parent=#cUtils] bsPatch
-- @param #string oldpath 旧文件的全路径
-- @param #string newpath 新文件的全路径
-- @param #string patchpath 差量文件的全路径
-- @return #int ret(0=成功，其他=errorCode)
--]]

---
-- 下载，异步(如果是zip直接解压)
-- @function [parent=#cUtils] download
-- @param #string url 文件下载地址
-- @param #string filename 文件的相对路径及名称
-- @param #string md5 文件的md5码
-- @param #function onProgress 下载进度Handler，回调（已下载量，总量）
-- @param #string onComplete 完成Handler，回调（errorCode） 0=完全完成，1=下载完成，<0=错误
-- @return #int ret(0=成功，其他=errorCode)

---
-- 从网络上获取一个字符串，异步
-- @function [parent=#cUtils] getNetString
-- @param #string url 请求的url地址
-- @param #string onComplete 完成Handler，回调（errorCode，内容） errorCode：0=获取完成，<0=错误
-- @return #int ret(0=成功，其他=errorCode)

---
-- 执行一段lua代码
-- @function [parent=#cUtils] doString
-- @param #string code

---
-- 获取设备网络状态
-- @function [parent=#cUtils] getNetworkState
-- @return #int ret (0=无网络 1=非wifi 2=wifi)

---
-- 添加本地通知（仅ios、安卓有效）
-- @function [parent=#cUtils] addLocalNotification
-- @param #double notificationTime 从1970触发时间的秒数
-- @param #bool reoeat 是否循环，只支持每天循环
-- @param #string ios_message ios通知消息
-- @param #string android_message 安卓通知消息
-- @param #string android_title 安卓通知标题
-- @param #string android_show 安卓滚动文字

---
-- 撤销本地所有通知
-- @function [parent=#cUtils] cancelLocalNotifications

---
-- 分享给微信好友
-- @function [parent=#cUtils] sendToFriendLua
-- @param #string content 写入内容
-- @param #string path 全路径
-- @return #int ret(0=成功，其他=errorCode)
--

---
-- 获取App配置
-- @function [parent=#cUtils] getAppConfig
-- @return #string ret （URL_SERVER_INFO、Ver）

---
-- 安装APK包，仅支持android
-- @function [parent=#Ver] installApk
-- @param #string apkFullPath

---
-- 是否为低内存状态（目前ios通过物理内存控制，android通过系统当前可用内存）
-- @function [parent=#cUtils] isLowMemory
-- @return #bool

---
-- 获取当前内存状态(单位MB)
-- @function [parent=#cUtils] getMemory
-- @return #number freeMemory,physicalMemory,activeMemory,inactiveMemory,wireMemory

---
-- 重启
-- @function [parent=#cUtils] reStart

return nil
