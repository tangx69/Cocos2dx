 ############################################################  
#                                                          #  
# The implementation of PHPRPC Protocol 3.0                #  
#                                                          #  
# xxtea.py                                                 #  
#                                                          #  
# Release 3.0.0                                            #  
# Copyright (c) 2005-2008 by Team-PHPRPC                   #  
#                                                          #  
# WebSite:  http://www.phprpc.org/                         #  
#           http://www.phprpc.net/                         #  
#           http://www.phprpc.com/                         #  
#           http://sourceforge.net/projects/php-rpc/       #  
#                                                          #  
# Authors:  Ma Bingyao <andot@ujn.edu.cn>                  #  
#                                                          #  
# This file may be distributed and/or modified under the   #  
# terms of the GNU Lesser General Public License (LGPL)    #  
# version 3.0 as published by the Free Software Foundation #  
# and appearing in the included file LICENSE.              #  
#                                                          #  
############################################################  
#  
# XXTEA encryption arithmetic library.  
#  
# Copyright (C) 2005-2008 Ma Bingyao <andot@ujn.edu.cn>  
# Version: 1.0  
# LastModified: Oct 5, 2008  
# This library is free.  You can redistribute it and/or modify it.  

import os
import struct  
import fnmatch  
from ctypes import *

CharArray17 = c_char * 17


_KEY = "1FF2F64F723F2F96"
_SIGN = "0xf8f7a5a6"
_DELTA = 0x9E3779B9  

keyTable = [0x76, 0xF9,0xA6, 0xA5, 0xF7, 0xF8, 0xC2, 0x20, 0x38, 0x01,
            0x38,0xD8,0xAA,0x9B,0x06,0x61,0x7B,0xA3,0x04,0xAA,0x48,0xDE,0xD8,0xD2,
            0x1B,0x09,0x09,0x7E,0x7B,0xE5,0xEC,0x11,0x45,0xE4,0x21,0x26,0xE2,0x38,
            0x08,0x3D,0x6D,0xFD,0xF5,0x49,0x04,0x87,0xC9,0x22,0x70,0xF7,0xFD,0xFC,
            0xEF,0x72,0x1A,0x18,0xCA,0xC6,0xAD,0x58,0x02,0x97,0x53,0x19,0xE1,0xD6,
            0xDD,0x8B,0x19,0x05,0x7A,0x14,0xA8,0x45,0xC8,0xF9,0x6E,0x74,0x7B,0xB2,
            0x23,0x2B,0x34,0x74,0xCB,0x84,0xA5,0x36,0x83,0x27,0x68,0x21,0x46,0x35,
            0x39,0x0C,0x24,0xF2,0x7C,0x8F,0x06,0x1D,0xE9,0x1D,0x50,0xDE,0x2C,0xF9,
            0x8E,0x95,0xFF,0xF4,0x73,0x4D,0x0A,0x47,0xAA,0xD5,0x88,0x45,0x15,0x8B,
            0x0D,0x4C,0xF0,0xD8,0x9A,0x7E,0xDA,0xDB,0xEF,0x37,0xAA,0xBF,0x79,0x75,
            0x38,0xC2,0x6D,0xF8,0xE2,0xE2,0xBE,0x24,0xCB,0xDE,0xE6,0x4E,0x42,0x2E,
            0x0]

szText = CharArray17()
szText = ("funyou.com777777")

funyouKey = CharArray17()


def InitFunyouKey():
    ch = c_char()
    for i in range(0,len(keyTable)):
        if (keyTable[i] == 0):
            break
        n = i % 16
        funyouKey[n] = keyTable[i] ^ ord(ch + chr(szText[n]))
        ch = funyouKey[n]
        print ch

    for i in range(0,16):
        print 'xxx'
        formated_str = "%X"%(funyouKey[i])
        funyouKey[i] = formated_str[0]
        
    print "funyouKey="+( ','.join(str(i) for i in funyouKey))
    return

def _long2str(v, w):  
    n = (len(v) - 1) << 2  
    if w:  
        m = v[-1]  
        if (m < n - 3) or (m > n): return ''  
        n = m  
    s = struct.pack('<%iL' % len(v), *v)  
    return s[0:n] if w else s  
  
def _str2long(s, w):  
    n = len(s)  
    m = (4 - (n & 3) & 3) + n  
    s = s.ljust(m, "\0")  
    v = list(struct.unpack('<%iL' % (m >> 2), s))  
    if w: v.append(n)  
    return v  
  
def encrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, True)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    sum = 0  
    q = 6 + 52 // (n + 1)  
    while q > 0:  
        sum = (sum + _DELTA) & 0xffffffff  
        e = sum >> 2 & 3  
        for p in xrange(n):  
            y = v[p + 1]  
            v[p] = (v[p] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            z = v[p]  
        y = v[0]  
        v[n] = (v[n] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff  
        z = v[n]  
        q -= 1  
    return _long2str(v, False)  
  
def decrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, False)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    q = 6 + 52 // (n + 1)  
    sum = (q * _DELTA) & 0xffffffff  
    while (sum != 0):  
        e = sum >> 2 & 3  
        for p in xrange(n, 0, -1):  
            z = v[p - 1]  
            v[p] = (v[p] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            y = v[p]  
        z = v[n]  
        v[0] = (v[0] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff  
        y = v[0]  
        sum = (sum - _DELTA) & 0xffffffff  
    return _long2str(v, True)  

def walkDir(directory, ext='*.lua', topdown=True):  
    fileArray = []  
    for root, dirs, files in os.walk(directory, topdown):  
        for name in files:
            if fnmatch.fnmatch(name, ext):  
                fileArray.append(os.path.abspath(os.path.join(root, name)))  
    return fileArray  
    
def encryptFile(file):
    inputFileStream = open(file, 'rb')
    inputFileStream.seek(0,2) #move to the end
    inputSize = inputFileStream.tell()
    inputFileStream.seek(0,0) #move to the head
    flag = inputFileStream.read(10)
    if (flag == _SIGN):
        print "[SKIP]"+file
        return
    print "[ENCRYPT]"+file
    inputFileStream.seek(0,0) #move to the head
    inputFileStreamContent = inputFileStream.read()
    encryptedContent = encrypt(inputFileStreamContent, _KEY)
    inputFileStream.close()
    
    inputFileStream = open(file, 'wb')
    inputFileStream.seek(0, 0);
    inputFileStream.write(_SIGN)
    inputFileStream.write(encryptedContent)
    inputFileStream.flush()
    inputFileStream.close()
    
def encryptFolder(path):
    filelist = walkDir(path)
    for file in filelist:
        encryptFile(file)
    
if __name__ == "__main__":  
    #InitFunyouKey()
    #print decrypt(encrypt('Hello XXTEA!', '16bytelongstring'), '16bytelongstring')
    encryptFolder("./src")
    encryptFolder("./res")
    
    
    
    
    
    
    