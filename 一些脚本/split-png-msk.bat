@echo off
set exevar="magick"

SETLOCAL ENABLEDELAYEDEXPANSION 

for /f "usebackq tokens=*" %%d in (`dir /s /b .\res\*.png`) do (
    set fullName=%%d
	set fileName=!fullName:~0,-4!
	echo [png.bat]!fileName!
    %exevar% !fileName!".png" -background black -alpha remove !fileName!".jpg"
	%exevar% !fileName!".png" -alpha extract !fileName!".msk"
    
    del !fileName!".png"
    %exevar% -quality 60% !fileName!".jpg" !fileName!".jpg"
    copy !fileName!".jpg" !fileName!".png"
	del !fileName!".jpg"
)