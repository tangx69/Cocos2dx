import os
import xml.dom.minidom
import re
import fileinput

xmlName = "xxxxxx/runtime-src/proj.android/AndroidManifest.xml"

def genApk(channel):
    packageName = '%s[%s]'%("com.xxxxx.xxxxx", channel)
    print "==============="+packageName+"==============="
    compileApkCmd = "cocos compile -s ../.. -p android -m release --lua-encrypt --lua-encrypt-key xxxxxxx --lua-encrypt-sign xxxxxxx"
    os.system(compileApkCmd)
    renameApkCmd = "copy xxxx-release-signed.apk %s.apk"%(packageName)
    os.system(renameApkCmd)
    return

def replaceInFile(filename, strFrom, strTo):  
    for line in fileinput.input(filename, inplace=True):
        if re.search(strFrom, line):
            line = line.replace(strFrom, strTo)  
        print line,  
        
def genAllApks():
    firstChannel = 2001
    lastChannel = 2020
    for i in range(firstChannel, lastChannel+1):
        print i
        _strFrom = '%s"%s"'%("android:value=", i)
        _strTo = '%s"%s"'%("android:value=", i+1)
        genApk(i)
        
        if (i < lastChannel):
            replaceInFile(xmlName, _strFrom, _strTo)
        #else:
            #reset
        #    _strTo = '%s"%s"'%("android:value=", firstChannel)
        #    replaceInFile(xmlName, _strFrom, _strTo)
    return

genAllApks()

