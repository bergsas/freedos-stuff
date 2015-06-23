@echo off 
set lang=EN

REM I see no reason not to do it like this for now. :)

add\bootutil.exe -all -bootenable=pxe -setupenable -setwaittime=5 -messageenable
