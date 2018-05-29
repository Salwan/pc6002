; Setup and use VSYNC
IFNDEF __VSYNC__
DEFINE __BSYNC

;========================
; User VRTC Set
; Will call the procedure with the address: VSYNCEVENT
;========================
SETVSYNCEVENT: 
	DI
	LD A, 0E6H
	LD I, A				; Interrupt Vec = 0E600H (default)
	LD A, 022H			; VRTC Addr Offset
	OUT (0BCH), A		; VRTC Vec = 0E622H (default)
	LD HL, (0E622H)		; BIOS VRTC Routine
	LD (BIVRTC), HL		; Push
	LD HL, USVRTC		; User VRTC Routine
	LD (0E622H), HL		; Replace VRTC Vec
	IN A, (0FAH)
	AND 0EFH			; bit4 off(VRTC interrupt on)(default)
	OUT (0FAH), A
	EI
	RET

; Call at the end of the program to disable user vsync
ENDVSYNCEVENT:
	DI
	PUSH HL
	LD HL, (BIVRTC)
	LD (0E662H), HL
	POP HL
	EI
	RET
	
; Uset VRTC Routine
USVRTC:
	PUSH AF
	LD A, (VRCCNT)
	INC A
	LD (VRCCNT), A
	CALL VSYNCEVENT
	POP AF
	DEFB 0C3H			; JP -> system interrupt handler
BIVRTC:
	DEFW 0000H
VRCCNT:
	DEFB 0

ENDIF
