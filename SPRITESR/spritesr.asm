; Sprite drawing system
IFNDEF __SPRITESR__
DEFINE __SPRITESR__

include "n66sr_bios.asm"

DEFM "SpriteSR_Data"
DEFVARS 0 				; SpriteSR 
{
	SprData ds.b 	2	; sprite data 2 bytes
	SprX 	ds.b 	1
	SprY 	ds.b 	1
	SprW 	ds.b 	1
	SprH 	ds.b 	1
	SprBG  	ds.b 	1
	SprPad  ds.b	1	; Just padding
} ; Size = 8 Bytes
DEFC SprDataSize = 8

DEFM "DATA"
; Sprites 0 to 7: layout that matches DEFVARS
; CURRENT SPRITE DATA: change this for next redraw
SPRITESR_DATA0:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_DATA1:
	DEFW 0, 0, 0x0808, 0x0000
SPRITESR_DATA2:
	DEFW 0, 0, 0x0808, 0x0000
SPRITESR_DATA3:
	DEFW 0, 0, 0x0808, 0x0000
SPRITESR_DATA4:
	DEFW 0, 0, 0x0808, 0x0000
SPRITESR_DATA5:
	DEFW 0, 0, 0x0808, 0x0000
SPRITESR_DATA6:
	DEFW 0, 0, 0x0808, 0x0000
SPRITESR_DATA7:
	DEFW 0, 0, 0x0808, 0x0000

DEFM "PAST"
; PAST SPRITE DATA: you don't need to touch this
SPRITESR_PAST0:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST1:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST2:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST3:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST4:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST5:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST6:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
SPRITESR_PAST7:
	DEFW 0x0000, 0x0000, 0x0808, 0x0000
	
SPRITESR_MASK:
	DEFB 0x01, 0x02, 0x04, 0x08
	DEFB 0x10, 0x20, 0x40, 0x80
SPRITESR_STATE:
	DEFB 0x00
DEFM "SpriteSR_Data_END"

; A for sprite number (0 to 7)
SPRITESR_SETREDRAW:
	PUSH HL
	LD HL, (SPRITESR_MASK)
	ADD A, L		; Add A to HL without using BC
	LD L, A
	ADC A, H
	SUB L
	LD H, A
	LD A, (HL)		; A = mask value
	LD HL, SPRITESR_STATE
	OR (HL)
	LD (HL), A
	POP HL
	RET
	
; Sprite System main callback for VSYNC
; Will not push/pop HL or AF (assumed pushed already)
SPRITESR_RUNONVSYNC:
	PUSH BC
	PUSH DE
	LD HL, SPRITESR_STATE
	LD A, (HL)
	OR 0
	JP Z, SPRITESR_RUNONVSYNC_END
SPRITESR_RUNONVSYNC_SPR0:
	; Sprite 0
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK
	AND (HL)			; State & Mask 0
	JP Z, SPRITESR_RUNONVSYNC_SPR1
		; Clear
	LD HL, (SPRITESR_PAST0)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR0_DRAW
	LD IY, SPRITESR_PAST0
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST0 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR0_DRAW:
	LD HL, SPRITESR_DATA0
	LD HL, SDTest
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR0_COPY
	LD IY, SPRITESR_DATA0
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR0_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST0
	LD HL, SPRITESR_DATA0
	LDIR
SPRITESR_RUNONVSYNC_SPR1:
	; Sprite 1
	NOP
	; Sprite 2
SPRITESR_RUNONVSYNC_SPR2:
	NOP
	; Sprite 3
SPRITESR_RUNONVSYNC_SPR3:
	NOP
	; Sprite 4
SPRITESR_RUNONVSYNC_SPR4:
	NOP
	; Sprite 5
SPRITESR_RUNONVSYNC_SPR5:
	NOP
	; Sprite 6
SPRITESR_RUNONVSYNC_SPR6:
	NOP
	; Sprite 7
SPRITESR_RUNONVSYNC_SPR7:
	NOP
SPRITESR_RUNONVSYNC_ENDDRAW:
	; Clear status value
	LD HL, SPRITESR_STATE
	LD (HL), 0x00
SPRITESR_RUNONVSYNC_END:
	POP DE
	POP BC
	RET
	
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
