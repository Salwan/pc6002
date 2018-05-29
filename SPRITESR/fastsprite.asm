; Sprite drawing procedures.
IFNDEF __FASTSPRITE__
DEFINE __FASTSPRITE__

include "n66sr_bios.asm"

; Fast draw sprite (blocks of 8 pixels, 4 bytes aligned)
; B, C: Y, X coords
; HL: sprite address
FASTDRAWSPRITE:
	PUSH HL
	CALL FASTDRAWSPRITE_COORDSTOADDR
	DI
	LD HL, FASTSTARTADR
	ADD HL, BC			; vram_addr
	EX DE, HL			; DE=vram_addr
	POP HL				; HL=sprite
	LD B, (HL)			; width
	LD A, FASTBYTEWIDTH ; FASTBYTEWIDTH
	DEC B
	SUB B				; FASTBYTEWIDTH-width=wstep
	LD C, A				; C=wstep
	LD (FASTDRAWSPRITE_VAR_W), BC ;	VAR_W = [width, wstep]
	INC HL				; HL=sprite+1
	LD A, (HL)			; A=height
	SRL A				; A=height//2
	INC HL
	INC HL
	INC HL				; HL=sprite+4
FASTDRAWSPRITE_VLOOP:
	LD BC, (FASTDRAWSPRITE_VAR_W); BC=width wstep
	LD C, B				; 
	LD B, 0				; BC = width
	INC C
FASTDRAWSPRITE_HLOOP:
	LDIR				; horizontal i loop
	LD BC, (FASTDRAWSPRITE_VAR_W); BC=width wstep
	LD B, 0				; BC = wstep
	EX DE, HL			; 
	ADD HL, BC			; vram_addr += wstep
	EX DE, HL			; DE=dest, HL=src
	DEC A				; height -= 1
	JP NZ, FASTDRAWSPRITE_VLOOP	;
	EI
	RET
FASTDRAWSPRITE_VAR_W:
	DEFW 0x0000
	
; Fast clear sprite (blocks of 8 pixels, 4 bytes aligned)
; B, C: Y, X coords
; HL: sprite address (to get width/height)
; A: Clear Color (BYTE of two colors)
FASTCLEARSPRITE:
	PUSH HL
	LD (FASTCLEARSPRITE_VAR_C), A ; VAR_C = color
	CALL FASTDRAWSPRITE_COORDSTOADDR
	DI
	LD HL, FASTSTARTADR
	ADD HL, BC			; vram_addr
	EX DE, HL			; DE=vram_addr
	POP HL				; HL=sprite
	PUSH DE				; STACK.push vram_addr
	LD B, (HL)			; width
	LD A, FASTBYTEWIDTH ; FASTBYTEWIDTH
	DEC B
	SUB B				; FASTBYTEWIDTH-width-1=wstep
	LD C, A				; C=wstep
	LD (FASTCLEARSPRITE_VAR_W), BC ; VAR_W = [width, wstep]
	INC HL				; HL=sprite+1
	LD D, (HL)			; D=height
	SRL D				; D=height//2
	POP HL				; HL=vram addr
	LD A, (FASTCLEARSPRITE_VAR_C) ; A = Color
	LD BC, (FASTCLEARSPRITE_VAR_W) ; B = width, C = wstep
	LD E, B				; E = width
	INC E				; E = width + 1
FASTCLEARSPRITE_VLOOP:
	LD B, E				; B = width + 1
FASTCLEARSPRITE_HLOOP:
	LD (HL), A
	INC HL
	DJNZ FASTCLEARSPRITE_HLOOP ; loop B times till B=0
	ADD HL, BC			; vram_addr += wstep
	DEC D				; height -= 1
	JP NZ, FASTCLEARSPRITE_VLOOP
	EI
	RET
FASTCLEARSPRITE_VAR_W:	; (width, wstep)
	DEFW 0x0000
FASTCLEARSPRITE_VAR_C:
	DEFB 0x00			; color 0xCC value
	
; Converts X,Y to memory offset of 8 pix blocks
; You need to add this to your start address.
; B, C: X, Y coords
; Returns BC -> offset to start address
FASTDRAWSPRITE_COORDSTOADDR:
	; x = x & 0b11111100 -> x = x - (x % 4) 
	LD A, C
	AND 0b11111100
	LD C, A
	; y = y // 2
	SRL B
	; hl = y * 256 -> B is like y << 8 :)
	RET
	
ENDIF
