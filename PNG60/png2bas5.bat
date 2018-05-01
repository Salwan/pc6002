echo off
set pngfile=%1
set name=%pngfile:.png=%
echo on
python .\internal\png60.py %arg1% %*
set lop6bmp=%name%.lo.p6bmp
set hip6bmp=%name%.hi.p6bmp
python .\internal\p6bmp2bas.py %lop6bmp% %hip6bmp% -5
set basfile=%name%.bmp.bas
set p6bas=%name%.bmp.p6
.\internal\txt2bas.exe -5 %basfile% %p6bas%
del %lop6bmp%
del %hip6bmp%
del %basfile%
pause