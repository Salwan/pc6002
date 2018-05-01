echo off
set pngfile=%1
set name=%pngfile:.png=%
echo on
python .\internal\png60.py %arg1% -6 %*
set p6bmp=%name%.p6bmp
python .\internal\p6bmp2bas.py %p6bmp% -6 -RLE
set basfile=%name%.bmp.bas
set p6bas=%name%.bmp.p6
.\internal\txt2bas.exe -6 %basfile% %p6bas%
del %p6bmp%
del %basfile%
pause