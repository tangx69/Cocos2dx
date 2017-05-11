import os
import hashlib
import md5
import string  
import struct  
import re  
import fileinput  
import fnmatch  
import sys,shutil
import platform


def walkDir(directory, ext='*.*', topdown=True):  
    fileArray = []  
    for root, dirs, files in os.walk(directory, topdown):  
        for name in files:
            if fnmatch.fnmatch(name, ext):  
                fileArray.append(os.path.abspath(os.path.join(root, name)))  
    return fileArray  

def getMD5(src):
    _md5 = md5.new(src)
    dst = _md5.hexdigest()
    
    return dst

def rename(path):
    filelist = walkDir(path)
    for file in filelist:
        oldFile=os.path.join(path,file)
        if os.path.isdir(oldFile):
            continue;
        filePath,fileNameType=os.path.split(file)
        fileName = os.path.splitext(fileNameType)[0]
        fileType = os.path.splitext(fileNameType)[1]
        newFile=os.path.join(filePath, getMD5(fileName) +fileType)
        
        if len(fileName) != 32 and fileName+fileType != "project.manifest" and fileName+fileType != "extra.zip" :
            print "[md5-file]["+oldFile+"]"
            if os.path.exists(newFile) :
                os.remove(newFile)
            sysstr = platform.system()
            if(sysstr =="Windows"):
                #shutil.copy(oldFile,  newFile)
                os.rename(oldFile,newFile)
            else:
                os.rename(oldFile,newFile)
            

rename("./src")
rename("./res")