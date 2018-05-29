; PC-6001 MkII (64K) Mode 6
; Picard Demo

ORG 0x9000		; 0x9000 to 0xdfff = 20 KB !!

include "n66sr_bios.asm"

START:
	LD A, 01H
	CALL SCREENPAGE
	CALL SCREENWORK
	CALL SCREENMODE		; SCREEN 2,2,2
	LD C, 9				; Clear color 10 (blue)
	CALL CLEARSCREEN2	; Clears all of screen 2 (slow)
	LD HL, BG_COLOR
	LD C, (HL)			; clear color 2 pixels
	CALL FASTCLEARSCREEN2 ; Clears 256x188 fast work area
	LD C, 0
	CALL CLEARSCREEN2TOP; Clears 256x12 top area (slow)
	LD C, 0
	CALL CLEARSCREEN2RIGHT; Clears 64x265 right area (slow)
						; Draw Frames
	LD BC, 0
	LD DE, 0
	LD A, 3
	LD (0ED81H), A
	LD IX, 319
	LD IY, 199
	LD (0ED82H), IX
	LD (0ED84H), IY
	CALL DRAWBOX		; Draw Box
	LD A, 15
	LD (0ED81H), A
	LD BC, 0
	LD DE, 12
	LD IX, 256
	LD IY, 199
	LD (0ED82H), IX
	LD (0ED84H), IY
	CALL DRAWBOX		; Draw Box 2
PICARD_VSYNC:
						; Set VSYNC event procedure
	CALL SETVSYNCEVENT
PICARD_INIT:
						; Load up test sprite 1
	LD HL, SDTest
	LD (SPRITESR_DATA0), HL
	LD A, 0
	LD (SPRITESR_DATA0+SprX), A
	LD (SPRITESR_DATA0+SprY), A
	LD A, 8
	LD (SPRITESR_DATA0+SprW), A
	LD (SPRITESR_DATA0+SprH), A
	LD A, (BG_COLOR)
	LD (SPRITESR_DATA0+SprBG), A
	LD A, 0
	CALL SPRITESR_SETREDRAW
PICARD_UPDATE:
						; Read Input
	CALL MODKEYDOWN
	JP Z, PICARD_UPDATE
	LD B, A
	AND 0b10000000		; Space
	JP NZ, PICARD_END
	LD A, B
	AND 0b00010000		; Right
	JP NZ, PICARD_RIGHT
  PICARD_AFTER_RIGHT:
	LD A, B
	AND 0b00100000		; Left
	JP NZ, PICARD_LEFT
  PICARD_AFTER_LEFT:
	LD A, B
	AND 0b00000100		; Up
	JP NZ, PICARD_UP
  PICARD_AFTER_UP:
	LD A, B
	AND 0b00001000		; Down
	JP NZ, PICARD_DOWN
	JP PICARD_UPDATE
PICARD_RIGHT:
	LD HL, SPRITESR_DATA0+SprX
	INC (HL)
	LD A, 0
	CALL SPRITESR_SETREDRAW
	JP PICARD_AFTER_RIGHT
PICARD_LEFT:
	LD HL, SPRITESR_DATA0+SprX
	DEC (HL)
	LD A, 0
	CALL SPRITESR_SETREDRAW
	JP PICARD_AFTER_LEFT
PICARD_UP:
	LD HL, SPRITESR_DATA0+SprY
	LD A, (HL)
	OR 0
	JP Z, PICARD_AFTER_UP ; dont decrement 0
	DEC (HL)
	LD A, 0
	CALL SPRITESR_SETREDRAW
	JP PICARD_AFTER_UP
PICARD_DOWN:
	LD HL, SPRITESR_DATA0+SprY
	LD A, (HL)
	ADD 76
	JP C, PICARD_REDRAW
	INC (HL)
	JP PICARD_REDRAW
PICARD_REDRAW:
	LD A, 0
	CALL SPRITESR_SETREDRAW
	JP PICARD_UPDATE
PICARD_END:
	CALL ENDVSYNCEVENT
						; Done
	LD A, 000H
	CALL SCREENPAGE		; Switch to Page 1
	RET					;------------------- END
BG_COLOR:
	DEFB 0x55

; VRCCNT is counting 0-255 round-robin
VSYNCEVENT:
	; Runs 60 frames a second
	PUSH AF
	PUSH HL
	LD A, (VRCCNT)		; Run on even frames only
	AND 0x1
	JP NZ, VSYNCEVENT_END
						; We are in even frame
	; SPRITESR runs at 30 fps
	CALL SPRITESR_RUNONVSYNC
VSYNCEVENT_END:
	POP HL
	POP AF
	RET
	
include "vsync.asm"
include "fastclear.asm"
include "spritesr.asm"
include "sprites.asm"
