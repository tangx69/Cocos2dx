 	
@echo off

SETLOCAL ENABLEDELAYEDEXPANSION 

for /f "usebackq tokens=*" %%d in (`dir /s /b .\res\*.msk`) do (
	set fullName=%%d
	echo !fullName!
	set fileName=!fullName:~0,-4!
	echo [png.bat][input]!fileName!
    magick !fileName!".png" !fileName!".msk" -compose copyopacity -composite !fileName!"_all.png"
	
	copy !fileName!"_all.png" !fileName!".png"
	del !fileName!"_all.png"
	del !fileName!".msk"
)


