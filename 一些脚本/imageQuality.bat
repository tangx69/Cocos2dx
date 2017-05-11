@echo off
set exevar="magick"

SETLOCAL ENABLEDELAYEDEXPANSION 

for /f "usebackq tokens=*" %%d in (`dir /s /b .\res\*.png`) do (
    set fullName=%%d
	set fileName=!fullName:~0,-4!
	echo [png.bat]!fileName!
    
    copy !fileName!".png" !fileName!".jpg"
    
    %exevar% -quality 85% !fileName!".jpg" !fileName!".jpg"
    
    del !fileName!".png"
    copy !fileName!".jpg" !fileName!".png"
    del !fileName!".jpg"
)