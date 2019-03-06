--lua中基础类实现,使用元表方式
--用于在lua中类和对象的模拟
--规则：
--1.其它类都从CBaseObj继承，不能多重继承
--2.类用Class实现继承，名称统一用C 开头
--3.对象用类的New生成，对象不能继承和生成对象
--4.不提供对象的local访问设置
--定义基类
local CBaseObj = {}

--基类，其它类从这里派生
function CBaseObj:Class()
    local new_class = {}
    setmetatable(new_class, self)
    self.__index = self
    return new_class
end

--类的对象，从这里生成，可以传参数
function CBaseObj:New(...)
    local new_obj = {}
    setmetatable(new_obj, self)
    self.__index = self
    self.Class = nil --对象不能生成类
    self.New = nil --对象不能生成对象
    new_obj:OnNew(...) --新对象的构造
    return new_obj
end

--初始化对象时，会调用类的构造函数
--用来初始化成员变量及成员变量为的table实例
function CBaseObj:OnNew(...)

end

return CBaseObj
