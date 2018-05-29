; PC-6002 (PC-6001 Mk2 SR)
; N66-SR (Mode 6) BIOS Helper

IFNDEF __N66SR_BIOS__
DEFINE __N66SR_BIOS__

CURSORON	EQU		000AFH
CURSOROFF	EQU		000B1H
CLS			EQU		0009CH	; Clears current screen
CLSR 		EQU 	0003BH	; clear and reset all
SCREENMODE	EQU		00041H  ; SCREEN MODE=A,WORK=A,VIEW=A
SCREENWORK	EQU		00044H
SCREENPAGE	EQU		00047H
SETPAGE 	EQU		00047H	; PAGE A (0 or 1)
CHAROUT		EQU		00078H	; PRINT CHR$(A)
CHARCOLOR	EQU		0E6D2H  ; COLORED Printed char
CHARADDR 	EQU		00081H  ; Char coords (H, L) -> addr (HL)
PALET		EQU		000F6H	; PALET A, B
WAIT4KEY	EQU		0011DH	; A = Key code
CONSOLE		EQU		0009FH	; CONSOLE D, E -> (EC95-EC99)
SCROLLUP	EQU		000A2H	; H, L
SCROLLDOWN	EQU		000A5H	; H, L
GETCHAR		EQU		0006CH	; GetChar(H=X+1,L=Y+1) -> A
OUTKANJI	EQU		00090H	; ..
OUTGRP		EQU		00093H	; A=Chr, C=ED81 X=ED82,83 Y=ED84,85
INITPALET	EQU		000F0H	
SETCOLOR	EQU		000F6H	; COLOR A (01-04), B (01-10) -> EC7F,82
DRAWLINE	EQU		000BDH	; LINE(BC,DE)-([ED82,83],[ED84,85]),ED81
DRAWBOX		EQU		000C0H	; Same as LINE
DRAWFILL	EQU		000C3H	; Same as LINE
PAINT		EQU		000C9H	; PAINT(BC,DE),ED81,ED9F
ISKEYDOWN	EQU		0011AH	; Z==0? Yes A=Code : No keydown
READKEY		EQU		00120H	; from buffer, set A to 00H -> A
KEYSCLEAR	EQU		00123H	; Clear key buffer
MODKEYDOWN	EQU		00126H	; Status -> A b7 to b0 = Space, notused, left, right, down, up, stop, shift
STOPESCKEY	EQU		00132H	; STOP->Break, ESC->pause
STOPKEYDOWN EQU		00135H	; CY=1 when stop is pressed
STICKSTATE	EQU		00189H	; STICK(A=0-2) where 0 is keyboard, -> A=State
TRIGSTATE	EQU		0018CH	; TRIG(A=0-2) where 0 is space -> Z=1 when pressed, 0 otherwise
BEEP		EQU		00177H	; Make Beep sound
M2YCOORDL	EQU		0CEH	; port low byte Y coord (0-255)
M2YCOORDH	EQU		0CFH	; port high byte Y coord (256-319)

SCRBUF 			EQU 01000H	; Correct though never works
FASTSTARTADR 	EQU 0x2000
FASTBYTEWIDTH 	EQU 0xff; 256 bytes = 256x2 pixels

ENDIF