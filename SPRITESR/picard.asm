; PC-6001 MkII (64K) Mode 6
; Optimized clear function

ORG 0x9000		; 0x9000 to 0xdfff = 20 KB !!

include "n66sr_bios.asm"

; Simple-Motion
; Goal:
; 1. Draw box in 2,2,2
; 2. Picard starts in the beginning
; 3. Picard forward then backwards motion
; 4. Ricochet motion
; Requires:
; - convert picard data from p6bmp to z80asm format
; - quick draw function (using Y port for now)
; - quicker draw function (direct vram write)
; - quick clear function (Y ports)
; - quicker clear function (direct vram)
; - Motion function:
;	* clears sprite using custom background color (old pos)
;   * draws sprite in new position
; - Simple delay procedure to perhaps lessen flicker

START:
	LD A, 01H
	CALL SCREENPAGE
	CALL SCREENWORK
	CALL SCREENMODE		; SCREEN 2,2,2
	LD C, 9
	CALL CLEARSCREEN2
	LD C, 0xff			; clear color 2 pixels
	CALL FASTCLEARSCREEN2
	LD C, 0
	CALL CLEARSCREEN2TOP
	LD C, 0
	CALL CLEARSCREEN2RIGHT
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
PICARD_UPDATE:
	;LD A, (APP_VAR_PICARD_X)
	;					; Clear sprite
	;LD HL, SprCaptainPicard
	;LD B, 188/2
	;LD C, A
	;LD A, 0x55
	;CALL FASTCLEARSPRITE
	;LD A, (APP_VAR_PICARD_X)
	;					; Draw sprite
	;LD HL, SprCaptainPicard
	;LD B, 188/2
	;LD C, A
	;CALL FASTDRAWSPRITE
	
						; Read Input
	CALL MODKEYDOWN
	JP Z, PICARD_UPDATE
	LD B, A
	LD HL, APP_VAR_PICARD_TX
	LD DE, APP_VAR_PICARD_TY
	AND 0b00010000		; Right
	JP NZ, PICARD_RIGHT
	LD A, B
	AND 0b00100000		; Left
	JP NZ, PICARD_LEFT
	LD A, B
	AND 0b00000100
	JP NZ, PICARD_UP
	LD A, B
	AND 0b00001000
	JP NZ, PICARD_DOWN
	LD A, B
	AND 0b10000000		; Space
	JP NZ, PICARD_END
	JP PICARD_UPDATE
PICARD_RIGHT:
	INC (HL)
	JP PICARD_UPDATE
PICARD_LEFT:
	DEC (HL)
	JP PICARD_UPDATE
PICARD_UP:
	EX DE, HL
	DEC (HL)
	JP PICARD_UPDATE
PICARD_DOWN:
	EX DE, HL
	INC (HL)
	JP PICARD_UPDATE
PICARD_END:
	CALL ENDVSYNCEVENT
						; Done
	LD A, 000H
	CALL SCREENPAGE		; Switch to Page 1
	RET					;------------------- END
APP_VAR_COUNT:
	DEFB 0xff
APP_VAR_PICARD_X:
	DEFB 0
APP_VAR_PICARD_Y:
	DEFB 0
APP_VAR_PICARD_TX:		; Change these for motion
	DEFB 50;128
APP_VAR_PICARD_TY:
	DEFB 50;188/2
	
VSYNCEVENT:
	; Runs 60 frames a second
	PUSH AF
	PUSH HL
	LD A, (APP_VAR_PICARD_TX)
	LD HL, APP_VAR_PICARD_X
	CP (HL)
	JP NZ, VSYNCEVENT_REDRAW
	LD A, (APP_VAR_PICARD_TY)
	LD HL, APP_VAR_PICARD_Y
	CP (HL)
	JP NZ, VSYNCEVENT_REDRAW
	JP VSYNCEVENT_NOCHANGE
VSYNCEVENT_REDRAW:
						; Something changed! redraw
	PUSH BC
						; Clear sprite
	LD HL, APP_VAR_PICARD_X
	LD C, (HL)			; VAR_X
	LD HL, APP_VAR_PICARD_Y
	LD B, (HL)		
	LD A, 0xff			; Clear color (2 pixels)
	LD HL, SprSubzero
	CALL FASTCLEARSPRITE
						; Draw new sprite
	LD HL, APP_VAR_PICARD_TX
	LD C, (HL)
	LD HL, APP_VAR_PICARD_TY
	LD B, (HL)
	LD HL, SprSubzero
	CALL FASTDRAWSPRITE
	LD HL, APP_VAR_PICARD_X
	LD A, (APP_VAR_PICARD_TX)
	LD (HL), A
	LD HL, APP_VAR_PICARD_Y
	LD A, (APP_VAR_PICARD_TY)
	LD (HL), A
	POP BC
VSYNCEVENT_NOCHANGE:
	POP HL
	POP AF
	RET
	
include "vsync.asm"
include "fastclear.asm"
include "fastsprite.asm"
include "sprites.asm"
