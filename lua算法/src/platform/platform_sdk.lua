local BasePage = {
    _user = nil,  --{userName = "sasq",password = "123",isGuest = true}
    _users = nil,  --{key = userName,value = {userName = "sasq",password = "123",isGuest = true}}
    _serverId = nil,
    _layer = nil,
    _instance = nil
}

local DefaultPage = {
    _renderer = nil,
    _errors = {
        Language.src_platform_platform_playyx_1
    }
}

BasePage.__index = BasePage

function BasePage:getCurUser()
	if not self._user then
        local str = cc.UserDefault:getInstance():getStringForKey("userId")
        if str and str ~= "" then
            self._user = json.decode(str)
        end
	end
	return self._user
end

function BasePage:getUsers()
    if not self._users then
        local str = cc.UserDefault:getInstance():getStringForKey("userIds")
        if str and str ~= "" then
            self._users = json.decode(str)
        else
            self._users = {}
        end
    end
    return self._users
end

function BasePage:saveUsers()
    cc.UserDefault:getInstance():setStringForKey("userIds",json.encode(self._users))
end

function BasePage:setCurUser(user)
    self._user = user
    cc.UserDefault:getInstance():setStringForKey("userId",json.encode(user))
end

function BasePage:loadUI()
    local path = "res/ui/reg/reg.plist"
    cc.SpriteFrameCache:getInstance():addSpriteFrames(path)
end

function BasePage:addPage(render,isCenter)
    if not self._layer then
        self:_addDefaultLayer()
    end
    local dirSize = cc.Director:getInstance():getVisibleSize()
    local pageSize = render:getContentSize()
    local height = (dirSize.height - pageSize.height)/2
    height = isCenter and height or height - 15
    render:setPosition((dirSize.width - pageSize.width)/2, height)
    self._layer:addChild(render)
    self._layer:setLocalZOrder(1000)
end

function BasePage:showPop(message,func)
    cc.Director:getInstance():getTextureCache():addImage("res/ui/tips/plist_tips.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/tips/plist_tips.plist")
    local render = cc.CSLoader:createNode("res/ui/tips/W_tips.csb","res/ui/")
    local label = zzy.CocosExtra.seekNodeByName(render, "text_message")
    label:setString(message)
    local btn = zzy.CocosExtra.seekNodeByName(render,"Button_qingchu")
    btn:addTouchEventListener(function(sender, evnentType)
        if evnentType == ccui.TouchEventType.ended then
            render:removeFromParent()
            if func then
                func()
            end
        end
    end)
    self:addPage(render,true)
end

function BasePage:onLoginCompleted(response,isGuest)
    if isGuest == nil then
        isGuest = false
    end
    ch.PlayerModel.channeluser=response.channeluser or 0
    ch.PlayerModel.usertype=response.usertype or 0
    zzy.config.loginsvr = response.loginsvr
    self:_saveLoginAccount(response.username,response.passwd,isGuest)
    self:close()
    cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
    local evt = {
        type = zzy.Sdk.Events.loginDone,
        id = response.userid,
        params = response.params
    }
    zzy.EventManager:dispatch(evt)
end

function BasePage:_saveLoginAccount(userNameStr, passWordStr, isGuest)
    self._user = {userName = userNameStr, password = passWordStr, isGuest = isGuest}
    cc.UserDefault:getInstance():setStringForKey("userId", json.encode(self._user))
    local users = self:getUsers()
    users[userNameStr] = self._user
    cc.UserDefault:getInstance():setStringForKey("userIds", json.encode(users))
end

function BasePage:_addDefaultLayer()
    self._layer = ccui.Layout:create()
    local dirSize = cc.Director:getInstance():getVisibleSize()
    self._layer:setContentSize(dirSize)
    self._layer:setTouchEnabled(true)
    local scene = ch.LoginView.gameScene
    scene:addChild(self._layer,100)
end

function BasePage:close()
    if self._layer and self._layer:getParent() then
        local path = "res/ui/reg/reg.plist"
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(path)
        self._layer:removeFromParent()
        self._layer = nil
    end
end


local RegisterPage = {
    _renderer = nil,
    _isGuest = nil,
    _userNameText = nil,
    _userNameCorrectImg = nil,
    _userNameWrongImg = nil,
    _userNameStatus = 2,  -- 0正确�?1错误状态，2未输�?
    _passwordText = nil,
    _passwordCorrectImg = nil,
    _passwordWrongImg = nil,
    _passwordStatus = 2,
    _password2Text = nil,
    _password2CorrectImg = nil,
    _password2WrongImg = nil,
    _password2Status = 2,
    _errorLabel = nil,
    _errors = {
        Language.src_platform_platform_playyx_2,
        Language.src_platform_platform_playyx_3,
        Language.src_platform_platform_playyx_4,
        Language.src_platform_platform_playyx_5,
        Language.src_platform_platform_playyx_6,
        Language.src_platform_platform_playyx_7, --以下为服务器返回错误
        Language.src_platform_platform_playyx_8,
        Language.src_platform_platform_playyx_9,
        Language.src_platform_platform_playyx_10,
        Language.src_platform_platform_playyx_11
    }
}

RegisterPage.__index = RegisterPage

function RegisterPage:new(isGuest)
    local o = {}
    setmetatable(o,self)
    o._isGuest = isGuest
    return o
end

function RegisterPage:render()
    self._renderer = cc.CSLoader:createNode("res/ui/reg/reg_reg.csb","res/ui/")
    BasePage:addPage(self._renderer,true)
    self._errorLabel = zzy.CocosExtra.seekNodeByName(self._renderer,"Text_tips2")
    self._errorLabel:setVisible(false)
    self:_addUserNameListener()
    self:_addPasswordListener()
    self:_addPassword2Listener()
    self:_addBtnTouchListener()
end

function RegisterPage:_addUserNameListener()
    local basePanel = zzy.CocosExtra.seekNodeByName(self._renderer,"diban_input1")
    self._userNameText = zzy.CocosExtra.seekNodeByName(basePanel,"textField_id")
    self._userNameCorrectImg = zzy.CocosExtra.seekNodeByName(basePanel,"ui_reg_correct")
    self._userNameCorrectImg:setVisible(false)
    self._userNameWrongImg = zzy.CocosExtra.seekNodeByName(basePanel,"ui_reg_wrong")
    self._userNameWrongImg:setVisible(false)
    self._userNameText:addEventListener(function(obj, eventType)
        if eventType ~= ccui.TextFiledEventType.detach_with_ime then
            local code = self:_check(true)
            if code == 0 then
                self:_setUserNameStatus(true)
            else
                self:_setUserNameStatus(false)
            end
            self:_showError(code,true)
        end
    end)
end

function RegisterPage:_addPasswordListener()
    local basePanel = zzy.CocosExtra.seekNodeByName(self._renderer,"diban_input2")
    self._passwordText = zzy.CocosExtra.seekNodeByName(basePanel,"textField_id")
    self._passwordCorrectImg = zzy.CocosExtra.seekNodeByName(basePanel,"ui_reg_correct")
    self._passwordCorrectImg:setVisible(false)
    self._passwordWrongImg = zzy.CocosExtra.seekNodeByName(basePanel,"ui_reg_wrong")
    self._passwordWrongImg:setVisible(false)
    self._passwordText:addEventListener(function(obj, eventType)
        if eventType ~= ccui.TextFiledEventType.detach_with_ime then
            local code = self:_check(false)
            local code2 = self:_checkPassword2()
            if code2 == 0 then
                self:_setPassword2Status(true)
            else
                self:_setPassword2Status(false)
            end
            if code == 0 then
                self:_setPasswordStatus(true)
            else
                self:_setPasswordStatus(false)
            end
            self:_showError(code,false)
        end
    end)
end

function RegisterPage:_addPassword2Listener()
    local basePanel = zzy.CocosExtra.seekNodeByName(self._renderer,"diban_input3")
    self._password2Text = zzy.CocosExtra.seekNodeByName(basePanel,"textField_id")
    self._password2CorrectImg = zzy.CocosExtra.seekNodeByName(basePanel,"ui_reg_correct")
    self._password2CorrectImg:setVisible(false)
    self._password2WrongImg = zzy.CocosExtra.seekNodeByName(basePanel,"ui_reg_wrong")
    self._password2WrongImg:setVisible(false)
    self._password2Text:addEventListener(function(obj, eventType)
        if eventType ~= ccui.TextFiledEventType.detach_with_ime then
            local code = self:_checkPassword2()
            if code == 0 then
                self:_setPassword2Status(true)
            else
                self:_setPassword2Status(false)
            end
            self:_showError(code,false)
        end
    end)
end

function RegisterPage:_addBtnTouchListener()
    local registerBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_reg")
    local guestBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_regguest")
    local backBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_back")
    if self._isGuest then
        registerBtn:setVisible(false)
        guestBtn:setVisible(true)
        guestBtn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:_onRegisterTouch(BasePage:getCurUser())
            end
        end)
    else
        registerBtn:setVisible(true)
        guestBtn:setVisible(false)
        registerBtn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:_onRegisterTouch()
            end
        end)
    end
    backBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self._renderer:removeFromParent()
            self._renderer = nil
            local page = DefaultPage:new()
            page:render()
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false) 
        end
    end)
end

function RegisterPage:_onRegisterTouch(oldUser)
    if self._userNameStatus == 2 then
        self:_setUserNameStatus(false)
        self:_showError(1,true)
    elseif self._passwordStatus == 2 then
        self:_setPasswordStatus(false)
        self:_showError(1,false)
    elseif self._password2Status == 2 then
        local code = self:_checkPassword2()
        if code > 0 then
            self:_setPassword2Status(false)
            self:_showError(code,false)
        end
    elseif self._userNameStatus == 0 and self._passwordStatus == 0 and self._password2Status == 0 then
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        self:_sendRegister(self._userNameText:getString(),self._passwordText:getString(),oldUser)
    end
end

function RegisterPage:_check(isUserName)
    local textfield = isUserName and self._userNameText or self._passwordText
    local str = textfield:getString()
	local length = string.len(str)
	if length == 0 then
	   return 1
	elseif length < 6 and length > 0 then
	   return 2
	elseif length >  15 then
	   return 3
	end
    if string.match(str,"%W") then
        return 4
    end
    return 0
end

function RegisterPage:_checkPassword2()
    local str = self._passwordText:getString()
    local str2 = self._password2Text:getString() 
    local length = string.len(str)
    if str == str2 then
        return 0
    else
        return 5
    end
end

---
-- errorCode大于0 显示指定错误，为0自动检查错误，如果都没有隐藏错误提�?
function RegisterPage:_showError(errorCode, isUserName)
	if errorCode > 0 then
	   local str = isUserName and Language.src_platform_platform_playyx_12 or Language.src_platform_platform_playyx_13
	   self._errorLabel:setString(string.format(self._errors[errorCode],str))
	   self._errorLabel:setVisible(true)
    elseif self._userNameStatus == 1 then
        local code = self:_check(true)
        if code > 0 then
            self:_showError(code,true)
        end
	elseif self._passwordStatus == 1 then
        local code = self:_check(false)
        if code > 0 then
            self:_showError(code,false)
        end
	elseif self._password2Status == 1 then
        local code = self:_checkPassword2()
        if code > 0 then
            self:_showError(code,false)
        end
	else
	   self._errorLabel:setVisible(false)
	end
end

function RegisterPage:_setUserNameStatus(isCorrect)
	if isCorrect then
	   self._userNameStatus = 0
	   self._userNameCorrectImg:setVisible(true)
	   self._userNameWrongImg:setVisible(false)
	else
        self._userNameStatus = 1
        self._userNameCorrectImg:setVisible(false)
        self._userNameWrongImg:setVisible(true)
	end
end

function RegisterPage:_setPasswordStatus(isCorrect)
    if isCorrect then
        self._passwordStatus = 0
        self._passwordCorrectImg:setVisible(true)
        self._passwordWrongImg:setVisible(false)
    else
        self._passwordStatus = 1
        self._passwordCorrectImg:setVisible(false)
        self._passwordWrongImg:setVisible(true)
    end
end

function RegisterPage:_setPassword2Status(isCorrect)
    if isCorrect then
        self._password2Status = 0
        self._password2CorrectImg:setVisible(true)
        self._password2WrongImg:setVisible(false)
    else
        self._password2Status = 1
        self._password2CorrectImg:setVisible(false)
        self._password2WrongImg:setVisible(true)
    end
end

function RegisterPage:_sendRegister(userNameStr, passwordStr,oldUser)
    local url = "http://account.djyx.zizaiyouxi.com/ucenter/register.php"
    local urlStr
    if oldUser then
        urlStr = string.format("%s?username=%s&passwd=%s&oldusername=%s&oldpasswd=%s",url,userNameStr,passwordStr,oldUser.userName,oldUser.password)
    else
        urlStr = string.format("%s?username=%s&passwd=%s&mac=%s&spid=%s&device_type=%s",url,userNameStr,passwordStr,
            zzy.cUtils.getDeviceID(), zzy.config.ChannelID, zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel()))
    end
    ch.CommonFunc:getNetString(urlStr, function(err, str)
        if err == 0 then
            local response = json.decode(str)
            if response.ERROR then
                local errKey = "src_platform_platform_playyx_"..response.ERROR
                local errorValue = Language[errKey]
                if errorValue then
                    BasePage:showPop(errorValue)
                else
                    BasePage:showPop(self._errors[10])
                end
            else
                if oldUser then
                    local users = BasePage:getUsers()
                    users[oldUser.userName] = nil
                end
                BasePage:onLoginCompleted(response)
            end
        else
            BasePage:showPop(self._errors[10])   
        end
    end)
end




local LoginPage = {
    _renderer = nil,
    _userNameText = nil,
    _passwordText = nil,
    _errors = {
        Language.src_platform_platform_playyx_14,
        Language.src_platform_platform_playyx_15,
        Language.src_platform_platform_playyx_16
    }
}

LoginPage.__index = LoginPage

function LoginPage:new()
    local o = {}
    setmetatable(o,self)
    return o
end

function LoginPage:render()
    self._renderer = cc.CSLoader:createNode("res/ui/reg/reg_login.csb","res/ui/")
    BasePage:addPage(self._renderer,true)
    self._userNameText = zzy.CocosExtra.seekNodeByName(self._renderer,"textField_id")
    self._passwordText = zzy.CocosExtra.seekNodeByName(self._renderer,"textField_pw")
    self:_addBtnTouchListener()
end

function LoginPage:setUserName(userNameStr)
    self._userNameText:setString(userNameStr)
end

function LoginPage:_addBtnTouchListener()
    local loginBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_login")
    local backBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_back")
    loginBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local userNameStr = self._userNameText:getString()
            local passwordStr = self._passwordText:getString()
            userNameStr = zzy.StringUtils:trim(userNameStr)
            local error = self:_checkStatue(userNameStr, passwordStr)
            if error == 0 then
                self:sendLogin(self._userNameText:getString(),self._passwordText:getString())
            else
                self:_showError(error)
            end 
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)   
        end
    end)
    backBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self._renderer:removeFromParent()
            self._renderer = nil
            local page = DefaultPage:new()
            page:render() 
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        end
    end)
end

function LoginPage:_checkStatue(userName, password)
	if userName == nil or  userName == "" then 
	   return 1
	end
    if password == nil or  password == "" then
        return 2
    end
    return 0
end

function LoginPage:_showError(error)
	if error == 1 or error == 2 then
        BasePage:showPop(self._errors[3])
	end
end

function LoginPage:sendLogin(userNameStr, passwordStr,isGuest)
    INFO("[playform_sdk][sendLogin]")
    local url = LOGIN_URL
    local channelType = zzy.cUtils.getCustomParam()
    local urlStr = string.format("%s?username=%s&passwd=%s&mac=%s&spid=%s&device_type=%s&channelType=%d",url,userNameStr,passwordStr,
            zzy.cUtils.getDeviceID(), zzy.config.ChannelID, zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel()), channelType)
    ch.CommonFunc:getNetString(urlStr, function(err, str)
        if err == 0 then
            local response = json.decode(str)
            if response.ERROR then
                if response.ERROR == 14 then
                    local errKey = "src_platform_platform_playyx_"..response.ERROR
                    local errorValue = Language[errKey]
                    if errorValue then
                        BasePage:showPop(errorValue)
                    else
                        BasePage:showPop(self._errors[2])
                    end
                else
                    BasePage:showPop("NetWork Error, Code="..response.ERROR)
                end
            else
                BasePage:onLoginCompleted(response,isGuest) 
            end
        else
            BasePage:showPop(self._errors[2])
        end
    end)
end


DefaultPage.__index = DefaultPage

function DefaultPage:new()
    local o = {}
    setmetatable(o,self)
    return o	
end

function DefaultPage:render()
    self._renderer = cc.CSLoader:createNode("res/ui/reg/reg_default.csb","res/ui/")
    BasePage:addPage(self._renderer,true)
    self:_addBtnTouchListener()
end

function DefaultPage:_addBtnTouchListener()
    local guestBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_guest")
    local loginBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_login")
    local registerBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_reg")
    guestBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:_sendAutoRegister()
        end
    end)
    loginBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local page = LoginPage:new()
            page:render()
            self._renderer:removeFromParent()
            self._renderer = nil
        end
    end)
    registerBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local page = RegisterPage:new()
            page:render()
            self._renderer:removeFromParent()
            self._renderer = nil
        end
    end)
end

function DefaultPage:_sendAutoRegister()
    local url = "http://account.djyx.zizaiyouxi.com/ucenter/autoreg.php"
    url = string.format("%s?mac=%s&spid=%s&device_type=%s",url,
        zzy.cUtils.getDeviceID(), zzy.config.ChannelID, zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel()))
    ch.CommonFunc:getNetString(url, function(err, str)
        if err == 0 then
            local response = json.decode(str)
            if response.ERROR then
                BasePage:showPop(self._errors[1])
            else
                BasePage:onLoginCompleted(response,true)
            end
        else
            BasePage:showPop(self._errors[1])    
        end
    end)
end

local UserItem = {
    _user = nil, -- {userName = "sasq",password = "123",isGuest = true}
    _parent = nil,

    _renderer = nil,
}

UserItem.__index = UserItem

function UserItem:create(user,parent)
    local o = {}
    setmetatable(o,self)
    o._user = user
    o._parent = parent
    return o
end

function UserItem:getRenderer()
    return self._renderer
end

function UserItem:render()
    self._renderer = cc.CSLoader:createNode("res/ui/reg/reg_default.csb","res/ui/")
    self:_addBtnTouchListener()
    self:_loadUser()
end

function UserItem:_addBtnTouchListener()
    local selectBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"touch_select")
    local removeBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"touch_delete")
    selectBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            self._parent:selectUser(self._user)
        end
    end)
    removeBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            self._parent:removeUser(self._user)
        end
    end)
end

function UserItem:_loadUser()
    local userLabel = zzy.CocosExtra.seekNodeByName(self._renderer,"label_id")
    if self._user.isGuest then
        local userGuestLabel = zzy.CocosExtra.seekNodeByName(self._renderer,"label_guest")
        userGuestLabel:setString(self._user.userName)
        userGuestLabel:setVisible(true)
        userLabel:setVisible(false)
    else
        userLabel:setString(self._user.userName)
    end
end



local ChangeUserPage = {
    _curUser = nil, -- {userName = "sasq",password = "123",isGuest = true}
    _hasLoadUserList = nil,
    _isOpening = nil,
    _itemCache = nil,
    
    _renderer = nil,
    _curUserLabel = nil,
    _curUserGuestLabel = nil,
    _registerBtn = nil,
    _bindBtn = nil,
    _userListView = nil,
    _openImage = nil,
    _closeImage = nil
}

ChangeUserPage.__index = ChangeUserPage

function ChangeUserPage:new()
    local o = {}
    setmetatable(o,self)
    return o    
end

function ChangeUserPage:render()
    self._renderer = cc.CSLoader:createNode("res/ui/reg/reg_change.csb","res/ui/")
    BasePage:addPage(self._renderer,true)
    self:_addBtnTouchListener()
    self:_loadCurUser() --需要更改按钮状�?
    self._userListView = zzy.CocosExtra.seekNodeByName(self._renderer,"listView_users")
    self._openImage = zzy.CocosExtra.seekNodeByName(self._renderer,"icon_open")
    self._closeImage = zzy.CocosExtra.seekNodeByName(self._renderer,"icon_close")
end

function ChangeUserPage:selectUser(user)
    self:_closeUserList()
    self:_setCurUser(user)
    BasePage:setCurUser(user)
end

function ChangeUserPage:removeUser(user)
    local users = BasePage:getUsers() 
    users[user.userName] = nil
    BasePage:saveUsers()
    self:_removeItem(user.userName)
    if user.userName == self._curUser.userName then
        local curUser = nil
        for k,v in pairs(users) do
            curUser = v
            break
        end
        self:_setCurUser(curUser)
        BasePage:setCurUser(curUser)
        if curUser == nil then
            self:_close()
            local page = DefaultPage:new()
            page:render()
        end
    end
end

function ChangeUserPage:_addBtnTouchListener()
    local loginBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_login")
    self._registerBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_reg")
    self._bindBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"btn_regguest")
    local userListBtn = zzy.CocosExtra.seekNodeByName(self._renderer,"touch_panel")
    loginBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._curUser then
                LoginPage:sendLogin(self._curUser.userName,self._curUser.password,self._curUser.isGuest)
            end
        end
    end)
    self._registerBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:_closeUserList()
            local page = RegisterPage:new(false)
            page:render()
        end
    end)
    self._bindBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:_closeUserList()
            local page = RegisterPage:new(true)
            page:render()
        end
    end)
    userListBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._isOpening then
                self:_closeUserList()
            else
                self:_openUserList()
            end
        end
    end)
end

function ChangeUserPage:_loadCurUser()
    self._curUserLabel = zzy.CocosExtra.seekNodeByName(self._renderer,"label_id")
    self._curUserGuestLabel = zzy.CocosExtra.seekNodeByName(self._renderer,"label_guest")
    self:_setCurUser(BasePage:getCurUser())
end

function ChangeUserPage:_setCurUser(user)
    self._curUser = user
    if user == nil then
        self._curUserGuestLabel:setVisible(false)
        self._curUserLabel:setVisible(true)
        self._bindBtn:setVisible(false)
        self._registerBtn:setVisible(true)
        self._curUserLabel:setString("")
        return
    end
    if user.isGuest then
        self._curUserGuestLabel:setVisible(true)
        self._curUserLabel:setVisible(false)
        self._bindBtn:setVisible(true)
        self._registerBtn:setVisible(false)
        self._curUserGuestLabel:setString(user.userName)
    else
        self._curUserGuestLabel:setVisible(false)
        self._curUserLabel:setVisible(true)
        self._bindBtn:setVisible(false)
        self._registerBtn:setVisible(true)
        self._curUserLabel:setString(user.userName)
	end
end

function ChangeUserPage:_openUserList()
	self._userListView:setVisible(true)
	self._openImage:setVisible(false)
	self._closeImage:setVisible(true)
	self._isOpening = true
	self:_loadUserList()
end

function ChangeUserPage:_closeUserList()
    self._userListView:setVisible(false)
    self._openImage:setVisible(true)
    self._closeImage:setVisible(false)
    self._isOpening = false
end

function ChangeUserPage:_loadUserList()
    if not self._hasLoadUserList then
        self._itemCache = {}
        local index = 0
        for k,v in pairs(BasePage:getUsers()) do
            local item = UserItem:create(v,self)
            item:render()
            self._itemCache[v.userName] = index
            self._userListView:pushBackCustomItem(item:getRenderer())
            index = index + 1
        end
        self:_addOther()
        self._hasLoadUserList = true
    end
end

function ChangeUserPage:_removeItem(userName)
	local index = self._itemCache[userName]
	if index then 
        self._itemCache[userName] = nil
        self._userListView:removeItem(index)
        for k,v in pairs(self._itemCache) do
            if v > index then
                self._itemCache[k] = v - 1
            end
        end
    end
end

function ChangeUserPage:_addOther()
    local view = cc.CSLoader:createNode("res/ui/reg/Nreg_idlist_unit2.csb","res/ui/")
    local touchBtn = zzy.CocosExtra.seekNodeByName(view,"touch_select")
	touchBtn:addTouchEventListener(function(obj,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:_closeUserList()
            local page = LoginPage:new()
            page:render()
        end
    end)
    self._userListView:pushBackCustomItem(view)
end

function ChangeUserPage:_close()
	if self._renderer then
	   self._renderer:removeFromParent()
	   self._renderer = nil
	end
end

zzy.Sdk.init = function()
    INFO("[playform_sdk]sdk init")
    local packageName = zzy.cUtils.getPackageName()
    local platFormInfo = {
        channelName = zzy.cUtils.getCustomParam(),
        loginUrl = "http://115.159.66.225:27199/yjsdk/login",
        payUrl = "http://115.159.66.225:27199/yjsdk/pay"
    }
    platFormInfo.packageName = packageName
    local jsonInfo = json.encode(platFormInfo)
    
    cc.libPlatform:getInstance():init(jsonInfo)
    
    cc.libPlatform:getInstance():setLoginCallBack(BasePage.onSdkLoginCompleted)
    cc.libPlatform:getInstance():setLogoutCallBack(BasePage.onSdkLogoutCompleted)
    cc.libPlatform:getInstance():setExitGameCallBack(BasePage.onSdkExitGame)
    ch.CommonFunc:addBackListener()

    INFO("[[playform_sdk]]dispatch:"..zzy.Sdk.Events.initDone)
    zzy.EventManager:dispatch({type=zzy.Sdk.Events.initDone})
end

zzy.Sdk.openLogin = function()
    INFO("[playform_sdk]openLogin")
    cc.libPlatform:getInstance():login()
end

function BasePage.onSdkLoginCompleted(code, msg)
    INFO("[playform_sdk][onSdkLoginCompleted]")
    INFO("[playform_sdk][onSdkLoginCompleted]code="..code)
    INFO("[playform_sdk][onSdkLoginCompleted]msg="..(msg or ""))
    if code ~= 0 then
        return
    end
    
    if zzy.Sdk.getFlag() == "ANYSDK" or zzy.Sdk.getFlag() == "YIJIE" then
        local msg_t = json.decode(msg)
        local account = msg_t.account
        local password = msg_t.pwd
        INFO("[ANYSDK]account=%s, password=%s", account, password)
        
        --在游戏里面。而且切换了账号，则切换回登陆界面
        if IS_IN_GAME and GAME_ACCOUNT ~= account then
            if zzy.Sdk.getFlag() == "YIJIE" then
                ch.CommonFunc:gotoLogin()
                return
            end
        end
        
        LoginPage:sendLogin(account, password, false)
    end
end 

function BasePage.onSdkLogoutCompleted(code, msg)
    INFO("[playform_sdk][onSdkLogoutCompleted]")
    INFO("[playform_sdk][onSdkLogoutCompleted]code="..code)
    INFO("[playform_sdk][onSdkLogoutCompleted]msg="..(msg or ""))

    --在游戏里面，而且登出了账号，则切换回登陆界面
    if IS_IN_GAME then
        if zzy.Sdk.getFlag() == "YIJIE" then
            ch.CommonFunc:gotoLogin()
        end
    end 
end

function BasePage.onSdkExitGame(code, msg)
    --这里直接退出。或者弹出一个游戏自己的框确认下
    DEBUG("[onSdkExitGame]code=%d,msg=%s",code, msg)
    if code == 0 then
        DEBUG("游戏自己的退出界面")
        if _G_SHOW_EXIT and zzy.CocosExtra.isCobjExist(_G_SHOW_EXIT) then
            _G_SHOW_EXIT:removeFromParent()
            return
        end
        
        if IS_IN_GAME then
            ch.UIManager:showMsgBox(2,true,Language.EXIT_GAME_CONFIRM, function()
                cc.Director:getInstance():endToLua()
            end,nil,nil,2)
        end
    end

    if code == 1 then --sdk的弹出界面点了"退出"
        cc.Director:getInstance():endToLua()
    end
end

function BasePage:onLoginCompleted(response,isGuest)
    if response.ret ~= 0 then
        --ERROR("Login failed with old username and password")
        --return
    end
    
    if isGuest == nil then
        isGuest = false
    end
    ch.PlayerModel.channeluser=response.channeluser or 0
    ch.PlayerModel.usertype=response.usertype or 0
    zzy.config.loginsvr = response.loginsvr
    self:_saveLoginAccount(response.username,response.passwd,isGuest)
    self:close()
    cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
    local evt = {
        type = zzy.Sdk.Events.loginDone,
        id = response.userid,
        params = response.params
    }
    zzy.EventManager:dispatch(evt)
end

zzy.Sdk.changeAccount = function()
--    BasePage:loadUI()
--	local page = ChangeUserPage:new()
----    local page = BasePage:new()
--	page:render()
    local tmpData = {}
    cc.UserDefault:getInstance():setStringForKey("userId",json.encode(tmpData))
    BasePage:setCurUser(nil)
    zzy.Sdk.openLogin()
    
end

if not __G_MAKED_IAPPPAY_FUNC then
    __G_MAKED_IAPPPAY_FUNC = true
    local _iappPayStartPay = zzy.Sdk.openCharge
    local _makingOrder = false
    zzy.Sdk.openCharge = function(pid, pName, pdata, price)
        if _makingOrder then return end
        _makingOrder = true
        
        local urlTemplate = "http://recharge.zizaiyx.com/zizaiyouxi_xlm/iapppay/iapppay_order.php?userid=%s&svrid=%s&waresid=%s&spid=%s&apptype=%s"
        local url = string.format(urlTemplate, zzy.config.loginData.userid, zzy.config.svrid, pid, zzy.config.ChannelID,
            cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID and "android" or "ios")
        ch.CommonFunc:getNetString(url, function(err, content)
            if err == 0 then
                local ret = json.decode(content)
                if ret.ERROR == 0 then
                    local iapppayData = string.format("transid=%s&appid=%s", ret.TRANSID, cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID and "3001567626" or "")
                    _iappPayStartPay("", "", iapppayData, 0)
                end
            end
            _makingOrder = false
        end)
    end
end

