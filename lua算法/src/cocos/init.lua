
require "src.cocos.cocos2d.Cocos2d"
require "src.cocos.cocos2d.Cocos2dConstants"
require "src.cocos.cocos2d.extern"
require "src.cocos.cocos2d.bitExtend"
require "src.cocos.cocos2d.DrawPrimitives"

-- opengl
require "src.cocos.cocos2d.Opengl"
require "src.cocos.cocos2d.OpenglConstants"

-- cocosbuilder
require "src.cocos.cocosbuilder.CCBReaderLoad"

-- cocosdenshion
require "src.cocos.cocosdenshion.AudioEngine"

-- cocosstudio
require "src.cocos.cocostudio.CocoStudio"

-- ui
require "src.cocos.ui.GuiConstants"
require "src.cocos.ui.experimentalUIConstants"

-- extensions
require "src.cocos.extension.ExtensionConstants"

-- network
require "src.cocos.network.NetworkConstants"

-- Spine
require "src.cocos.spine.SpineConstants"

if CC_USE_DEPRECATED_API then
    -- CCLuaEngine
    require "src.cocos.cocos2d.DeprecatedCocos2dClass"
    require "src.cocos.cocos2d.DeprecatedCocos2dEnum"
    require "src.cocos.cocos2d.DeprecatedCocos2dFunc"
    require "src.cocos.cocos2d.DeprecatedOpenglEnum"

    -- register_cocostudio_module
    require "src.cocos.cocostudio.DeprecatedCocoStudioClass"
    require "src.cocos.cocostudio.DeprecatedCocoStudioFunc"

    -- register_cocosbuilder_module
    require "src.cocos.cocosbuilder.DeprecatedCocosBuilderClass"

    -- register_cocosdenshion_module
    require "src.cocos.cocosdenshion.DeprecatedCocosDenshionClass"
    require "src.cocos.cocosdenshion.DeprecatedCocosDenshionFunc"

    -- register_extension_module
    require "src.cocos.extension.DeprecatedExtensionClass"
    require "src.cocos.extension.DeprecatedExtensionEnum"
    require "src.cocos.extension.DeprecatedExtensionFunc"

    -- register_network_module
    require "src.cocos.network.DeprecatedNetworkClass"
    require "src.cocos.network.DeprecatedNetworkEnum"
    require "src.cocos.network.DeprecatedNetworkFunc"

    -- register_ui_moudle
    require "src.cocos.ui.DeprecatedUIEnum"
    require "src.cocos.ui.DeprecatedUIFunc"
end
