@echo off 
set lang=EN

path %dosdir%;%dosdir%\..\add
keyb no,865

@bootutil.exe -all -bootenable=pxe -setupenable -setwaittime=5 -messageenable

choice/Ty,60 Will coldboot the machine in 60-ish seconds. Hit N to cancel.
if errorlevel 2 goto end
@fdapm coldboot
:end
