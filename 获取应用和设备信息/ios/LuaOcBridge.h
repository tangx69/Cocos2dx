#ifndef LUA_OC_BRIDGE_H
#define LUA_OC_BRIDGE_H
#import <Foundation/Foundation.h>

@interface LuaOcBridge : NSObject {

}

//call by lua

+ (NSString *) getDeviceName:(NSDictionary *)dict;
+ (NSString *) getPackageName:(NSDictionary *)dict;
+ (NSString *) getVersionCode:(NSDictionary *)dict;
+ (NSString *) getVersionName:(NSDictionary *)dict;
+ (NSString *) addSkipBackupAttributeToItemAtURL:(NSDictionary *)dict;

@end

#endif  //  LUA_OC_BRIDGE_H
