---
-- 网络通信类
-- @module Socket

---
-- 新建一个连接对象
-- @function [parent=#Socket] new
-- @param self
-- @param #function onStateChangeHandler (0=CONNECTING,1=CONNECTED,2=LINKED,3=DISCONNECT)
-- @param #function onServerDataHandler
-- @return #Socket ret

---
-- 建立链接
-- @function [parent=#Socket] connect
-- @param self
-- @param #string host 链接地址
-- @param #int port 链接端口
-- @return #int ret(0=SUCCEED,1=ERROR,2=INVALID_IP,3=INVALID_SOCKET,4=GETHOSTBYNAME_FAILURE,5=CONNECT_SERVER_ERROR,6=PTHREAD_ERR)

---
-- 断开链接
-- @function [parent=#Socket] disconnect
-- @param self

---
-- 删除实例
-- @function [parent=#Socket] release
-- @param self

---
-- 向缓冲区写入指令
-- @function [parent=#Socket] putCmd
-- @param self
-- @param #string cmd 文本指令
-- @param #bool doCompress 是否进行指令压缩

---
-- 向服务器发送链接验证串
-- @function [parent=#Socket] sendLinkStr
-- @param self

---
-- 将缓冲区内容发送给服务器
-- @function [parent=#Socket] flush
-- @param self

return nil