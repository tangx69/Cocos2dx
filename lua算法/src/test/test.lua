require "src.cocos.init"
require "src.zzy.zzy"
require "res.config.GameConfig"
require "res.language.Language"
require "src.clickhero.ch"
local changeGray

local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

--    local director = cc.Director:getInstance()
--    director:setDisplayStats(true)
--    director:setAnimationInterval(1.0 / 30)
--    director:getOpenGLView():setDesignResolutionSize(640, 1136, 1)
--    
--    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/aaui_png/common02.plist")
--    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/aaui_png/plist_rank.plist")
--    
--    
--    local boneName = "body"
--    
--    --create scene 
--    local gameScene = cc.Scene:create()    
--    local node = cc.CSLoader:createNode("res/ui/card/N_card_1.csb","res/ui/")
--    gameScene:addChild(node)
--    node:setPosition(300,900)
--    local image = zzy.CocosExtra.seekNodeByName(node, "quality_flag")
--    
--    local node2 = cc.CSLoader:createNode("res/ui/baowu/N_BaowuIcon.csb","res/ui/")
--    gameScene:addChild(node2)
--    node2:setPosition(300,700)
--    local image2 = zzy.CocosExtra.seekNodeByName(node2, "item_Baowu")
--
--    local ifGray = true
--    changeGray(image2,ifGray)
--    
--    local button = ccui.Button:create()
--    button:setPosition(500,300)
--    button:setTitleText("输出")
--    button:setTitleFontSize(28)
--    button:addTouchEventListener(function(obj,evt)
--        if ccui.TouchEventType.ended == evt then
----            local size = image:getContentSize()
----            image:setContentSize(size.width,size.height+30)
--            ifGray = not ifGray
--            changeGray(image2,ifGray)
--        end
--    end)
--    gameScene:addChild(button)
    
    local gameScene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    
    local c = ch.LongDouble:toLongDouble("   23.42")
    local d = ch.LongDouble:toLongDouble(" - 0003.00")
    cclog(c+d)
    cclog(c-d)
    cclog(c*d)
    cclog(c/d)
    
    local e = ch.LongDouble:toLongDouble("   -    00002034454354869543534534534")
    local f = ch.LongDouble:toLongDouble("2034454354869543534534534")
    cclog(e+f)
    cclog(e-f)
    cclog(e*f)
    cclog(e/f)
    
    if e < f then
        cclog("e小")
    end
    
    local g = -e
    cclog(g)
    
    
    local a = ch.LongDouble:new(2060342432)
    local c = 340
    local b = a + c
    cclog(tostring(a))
    local d = ch.LongDouble:new(54134324)
    cclog(ch.NumberHelper:toString(d))
    cclog(ch.NumberHelper:toString(54134324))
    
    cclog(string.format("%f",3.500000000000000000000))  
end


changeGray = function(image2,data)
    local point = image2:getPosition3D()
    if data then
    local vertDefaultSource = "\n"..
        "attribute vec4 a_position; \n" ..
        "attribute vec2 a_texCoord; \n" ..
        "attribute vec4 a_color; \n"..                                                    
        "#ifdef GL_ES  \n"..
        "varying lowp vec4 v_fragmentColor;\n"..
        "varying mediump vec2 v_texCoord;\n"..
        "#else                      \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord;  \n"..
        "#endif    \n"..
        "void main() \n"..
        "{\n" ..
        "gl_Position = CC_PMatrix * a_position; \n"..
        "v_fragmentColor = a_color;\n"..
        "v_texCoord = a_texCoord;\n"..
        "}"
    local pszFragSource = "#ifdef GL_ES \n" ..
        "precision mediump float; \n" ..
        "#endif \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord; \n" ..
        "void main(void) \n" ..
        "{ \n" ..
        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
        "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
        "gl_FragColor.w = c.w; \n"..
        "}"
    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    image2:getVirtualRenderer():getSprite():setGLProgram(pProgram)
    else
    
        image2:getVirtualRenderer():getSprite():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram(cc.SHADER_POSITION_TEXTURE_COLOR)))
        image2:setPosition3D(point)
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
