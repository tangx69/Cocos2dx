#import "LuaOcBridge.h"

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

#import <sys/utsname.h>


using namespace cocos2d;

@implementation LuaOcBridge


 + (NSString *) getDeviceName:(NSDictionary *)dict{
     struct utsname systemInfo;
     uname(&systemInfo);
     NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
 
     return deviceString;
 }

+ (NSString *) getPackageName:(NSDictionary *)dict{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    return identifier;
}

+ (NSString *) getVersionCode:(NSDictionary *)dict{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    return version;
}

+ (NSString *) getVersionName:(NSDictionary *)dict{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    
    return version;
}

+ (NSString *) addSkipBackupAttributeToItemAtURL:(NSDictionary *)dict{

    NSString *strPath = (NSString*)[dict objectForKey:@"para"];
    
    const char* attrName = "com.apple.MobileBackup";
    const char* path = [strPath UTF8String];
    u_int8_t attrValue = 1;
    setxattr(path, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return @"succ";
    
}

@end

