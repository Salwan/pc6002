; PC-6001 MkII (64K) Mode 6
; Optimized clear function
IFNDEF __FASTCLEAR__
DEFINE __FASTCLEAR__

include "n66sr_bios.asm"

; Slow clears all Screen 2 Mode 6 using given color.
; Upside-down clear because why not?
; C = Single 16 color (0 - 15)
CLEARSCREEN2:
	DI
	LD A, 0
	OUT (M2YCOORDH), A
	LD A, 199
	OUT (M2YCOORDL), A
CLEARSCREEN2_VLOOP:
	LD HL, 0
	LD B, 0FFH
CLEARSCREEN2_HLOOP1:
	LD (HL), C
	INC L
	DJNZ CLEARSCREEN2_HLOOP1
	LD (HL), C			; Hack to write 255th pixel (lol)
	LD B, 319-256
	INC H
	LD L, 0
CLEARSCREEN2_HLOOP2:
	LD (HL), C
	INC L
	DJNZ CLEARSCREEN2_HLOOP2
	LD HL, 0
	AND A
	JP Z, CLEARSCREEN2_END
	DEC A
	OUT (M2YCOORDL), A
	JP CLEARSCREEN2_VLOOP
CLEARSCREEN2_END:
	EI
	RET
	
; Fast clears screen 2 @ 0, 12: 256x188
; C = two 16 colors: 00 - FF
FASTCLEARSCREEN2:
	DI
	LD A, 0
	OUT (M2YCOORDH), A
	OUT (M2YCOORDL), A
	LD HL, 02000H
	LD D, 94
	LD B, 0FFH
FASTCLEARSCREEN2_LOOP:
	LD (HL), C
	INC HL
	DJNZ FASTCLEARSCREEN2_LOOP
	LD (HL), C			; Hack to write last pixel
	DEC D
	JP NZ, FASTCLEARSCREEN2_LOOP
	EI
	RET
	
; Slow clears screen 2 top part (0,0)-step(256,12)
; C = 1 Color
; for y=0 to 12:
;	out Y=y
; 	for x=0 to 256:
;		(HL) = C
CLEARSCREEN2TOP:
	DI
	LD A, 0
	OUT (M2YCOORDH), A
	OUT (M2YCOORDL), A
	LD D, 12
CLEARSCREEN2TOP_VLOOP:
	LD B, 0FFH
	LD HL, 0
CLEARSCREEN2TOP_HLOOP1:
	LD (HL), C
	INC HL
	DJNZ CLEARSCREEN2TOP_HLOOP1
	LD B, 319 - 256
CLEARSCREEN2TOP_HLOOP2:
	LD (HL), C
	INC HL
	DJNZ CLEARSCREEN2TOP_HLOOP2
	LD (HL), C
	DEC D
	JP Z, CLEARSCREEN2TOP_END
	INC A
	OUT (M2YCOORDL), A
	JP CLEARSCREEN2TOP_VLOOP
CLEARSCREEN2TOP_END:
	EI
	RET
	
; Slow clears screen 2 right part (256,0)-step(64,200)
; C = 1 Color
CLEARSCREEN2RIGHT:
	DI
	LD A, 0
	OUT (M2YCOORDH), A
	OUT (M2YCOORDL), A
	LD D, 200
CLEARSCREEN2RIGHT_VLOOP:
	LD B, 319 - 256
	LD HL, 256
CLEARSCREEN2RIGHT_HLOOP1:
	LD (HL), C
	INC HL
	DJNZ CLEARSCREEN2RIGHT_HLOOP1
	LD (HL), C
	DEC D
	JP Z, CLEARSCREEN2RIGHT_END
	INC A
	OUT (M2YCOORDL), A
	JP CLEARSCREEN2RIGHT_VLOOP
CLEARSCREEN2RIGHT_END:
	EI
	RET
	
; FastClear memory
; HL = Start Address
; B = L Byte (255)
; D = H Byte (255) -> max = 64KB clear
; C = Value to use
FASTCLEAR:
	DI
	LD A, 0
	OUT (M2YCOORDH), A
	OUT (M2YCOORDL), A
	LD E, B
FCLOOP:
	LD (HL), C
	INC HL
	DJNZ FCLOOP
	LD B, E
	DEC D
	JP NZ,FCLOOP
	EI
	RET

ENDIF
