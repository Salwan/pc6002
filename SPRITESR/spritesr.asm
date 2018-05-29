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
	LD HL, SPRITESR_MASK
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
	LD HL, (SPRITESR_DATA0)
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
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 1
	AND (HL)			; State & Mask 1
	JP Z, SPRITESR_RUNONVSYNC_SPR2
		; Clear
	LD HL, (SPRITESR_PAST1)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR1_DRAW
	LD IY, SPRITESR_PAST1
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST1 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR1_DRAW:
	LD HL, (SPRITESR_DATA1)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR1_COPY
	LD IY, SPRITESR_DATA1
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR1_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST1
	LD HL, SPRITESR_DATA1
	LDIR
SPRITESR_RUNONVSYNC_SPR2:
	; Sprite 2
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 2
	AND (HL)			; State & Mask 2
	JP Z, SPRITESR_RUNONVSYNC_SPR3
		; Clear
	LD HL, (SPRITESR_PAST2)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR2_DRAW
	LD IY, SPRITESR_PAST2
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST2 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR2_DRAW:
	LD HL, (SPRITESR_DATA2)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR2_COPY
	LD IY, SPRITESR_DATA2
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR2_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST2
	LD HL, SPRITESR_DATA2
	LDIR
SPRITESR_RUNONVSYNC_SPR3:
	; Sprite 3
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 3
	AND (HL)			; State & Mask 3
	JP Z, SPRITESR_RUNONVSYNC_SPR4
		; Clear
	LD HL, (SPRITESR_PAST3)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR3_DRAW
	LD IY, SPRITESR_PAST3
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST3 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR3_DRAW:
	LD HL, (SPRITESR_DATA3)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR3_COPY
	LD IY, SPRITESR_DATA3
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR3_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST3
	LD HL, SPRITESR_DATA3
	LDIR
SPRITESR_RUNONVSYNC_SPR4:
	; Sprite 4
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 4
	AND (HL)			; State & Mask 4
	JP Z, SPRITESR_RUNONVSYNC_SPR5
		; Clear
	LD HL, (SPRITESR_PAST4)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR4_DRAW
	LD IY, SPRITESR_PAST4
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST4 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR4_DRAW:
	LD HL, (SPRITESR_DATA4)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR4_COPY
	LD IY, SPRITESR_DATA4
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR4_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST4
	LD HL, SPRITESR_DATA4
	LDIR
SPRITESR_RUNONVSYNC_SPR5:
	; Sprite 5
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 5
	AND (HL)			; State & Mask 5
	JP Z, SPRITESR_RUNONVSYNC_SPR6
		; Clear
	LD HL, (SPRITESR_PAST5)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR5_DRAW
	LD IY, SPRITESR_PAST5
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST5 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR5_DRAW:
	LD HL, (SPRITESR_DATA5)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR5_COPY
	LD IY, SPRITESR_DATA5
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR5_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST5
	LD HL, SPRITESR_DATA5
	LDIR
SPRITESR_RUNONVSYNC_SPR6:
	; Sprite 6
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 6
	AND (HL)			; State & Mask 6
	JP Z, SPRITESR_RUNONVSYNC_SPR7
		; Clear
	LD HL, (SPRITESR_PAST6)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR6_DRAW
	LD IY, SPRITESR_PAST6
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST6 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR6_DRAW:
	LD HL, (SPRITESR_DATA6)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR6_COPY
	LD IY, SPRITESR_DATA6
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR6_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST6
	LD HL, SPRITESR_DATA6
	LDIR
SPRITESR_RUNONVSYNC_SPR7:
	; Sprite 7
	LD A, (SPRITESR_STATE)
	LD HL, SPRITESR_MASK + 7
	AND (HL)			; State & Mask 7
	JP Z, SPRITESR_RUNONVSYNC_ENDDRAW
		; Clear
	LD HL, (SPRITESR_PAST7)
	LD A, L
	ADD H	; If pastH == 0 then no previous draw
	JP Z, SPRITESR_RUNONVSYNC_SPR7_DRAW
	LD IY, SPRITESR_PAST7
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	LD A, (IY + SprBG)
	LD HL, (SPRITESR_PAST7 + SprData)
	CALL FASTCLEARSPRITE	; Clear past
		; Draw
  SPRITESR_RUNONVSYNC_SPR7_DRAW:
	LD HL, (SPRITESR_DATA7)
	LD A, 0
	ADD A, H; If dataH == 0 then no redraw
	JP Z, SPRITESR_RUNONVSYNC_SPR7_COPY
	LD IY, SPRITESR_DATA7
	LD C, (IY + SprX)
	LD B, (IY + SprY)
	CALL FASTDRAWSPRITE		; Draw sprite
  SPRITESR_RUNONVSYNC_SPR7_COPY:
	; Past = Data, specifically spr, x, y, bg
	LD BC, 7
	LD DE, SPRITESR_PAST7
	LD HL, SPRITESR_DATA7
	LDIR
	
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
