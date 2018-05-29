SET buildPath=build
SET target=picard
SET outPath=C:\Users\Salwa\ownCloud\PC60\disks
SET orgAddress=0x9000

mkdir %buildPath%
cd %buildPath%
z80asm.exe --cpu=z80 -O=%buildPath% --output=%target% --make-bin --list ..\%target%.asm

if exist %target%.bin (
	if exist %target%.d88 (
		rem Disk exists
	) else (
		rem Create new disk
		..\internal\D88TOOL.exe %target%.d88 -1ddbas
	)
	..\internal\D88TOOL.exe %target%.d88 %target% -bin %orgAddress%
	copy /B /Y %target%.d88 %outPath%\%target%.d88
)

pause
