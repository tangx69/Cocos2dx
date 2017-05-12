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
import time
import sys

print "---------------------------------------------------------------"
vers = str(input("please input start and end version,format is 'start,end':\n"))
vers = vers[1:-1]
vers = vers.replace(" ", "")
startVerEnd = vers.find(",")
endVerstart = vers.find(",")+1
svn_start_ver = vers[:startVerEnd]
svn_end_ver = vers[endVerstart:]
print "start getting all changes from version %s to %s,please wait" % (svn_start_ver, svn_end_ver)
###################################

timeStr = time.strftime('[%y%m%d%H%M]',time.localtime(time.time()))
verStr = "[%s-%s]" % (svn_start_ver, svn_end_ver)
hotDir = "0-hotupdate" + timeStr + verStr
changeListFile = "./" + hotDir + "/changelist.txt"

def genChangeList():
    #make folder
    if os.path.exists(hotDir):
        shutil.rmtree(hotDir)
    os.mkdir(hotDir)     
    
    #make changelist file
    srcChangeListFile = "./" + hotDir + "/changelistSrc.txt"
    cmdSrc = "svn diff -r " + svn_start_ver + ":" + svn_end_ver + " --summarize svn://192.168.1.104/projects/dmw/trunk/client/dmw/src > " + srcChangeListFile
    os.popen(cmdSrc)
    resChangeListFile = "./" + hotDir + "/changelistRes.txt"
    cmdRes = "svn diff -r " + svn_start_ver + ":" + svn_end_ver + " --summarize svn://192.168.1.104/projects/dmw/trunk/client/dmw/res > " + resChangeListFile
    os.popen(cmdRes)

    
    fChangeList = open(changeListFile, "w+")
    for line in open("./" + hotDir + "/changelistSrc.txt"):
        fChangeList.writelines(line)
    for line in open("./" + hotDir + "/changelistRes.txt"):
        fChangeList.writelines(line)
    fChangeList.close()
    os.remove(srcChangeListFile)
    os.remove(resChangeListFile)

def moveFiles():
    for line in open(changeListFile):
        line = line.replace("M       ", "")
        line = line.replace("A       ", "")
        line = line.replace("\n", "")

        if -1 != line.find("vscode"):
            continue
        
        fileFrom = line.replace("svn://192.168.1.104/projects/dmw/trunk/client/dmw", "I:/proj/dmw_trunk/client/dmw")
        fileTo = line.replace("svn://192.168.1.104/projects/dmw/trunk/client/dmw",  "./" + hotDir)

        if os.path.isdir(fileTo):
            continue

        newDir = fileTo[:fileTo.rfind("/")]
        if not os.path.exists(newDir):
            os.makedirs(newDir)
        #print "%s" % (fileFrom)
        shutil.copyfile(fileFrom, fileTo)

genChangeList()
moveFiles()

print "complete"
os.system('pause')
