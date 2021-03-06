; Sprites Data
IFNDEF __SPRITES__
DEFINE __SPRITES__

DEFM "SDCaptainPicard:"

SDCaptainPicard: 		; 16x28
DEFB 0x10, 0x1C, 0xe0, 0x00
DEFB 0x55, 0x55, 0x55, 0x55, 0x25, 0x22, 0x22, 0x22, 0x22, 0x55
DEFB 0xF2, 0x52, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x22, 0x22
DEFB 0x27, 0x22, 0x22, 0x52, 0x22, 0x57, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55
DEFB 0x55, 0x25, 0x27, 0x20, 0x22, 0x22, 0x07, 0x57, 0x27, 0x22, 0x55, 0x55
DEFB 0x55, 0x55, 0x55, 0x25, 0x55, 0x55, 0x22, 0x72, 0x22, 0x22, 0x22, 0x22
DEFB 0x22, 0x52, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x22, 0x72
DEFB 0x25, 0x22, 0x27, 0x52, 0x22, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55
DEFB 0x55, 0x55, 0x55, 0x22, 0x00, 0x00, 0x52, 0x55, 0x00, 0x50, 0x55, 0x55
DEFB 0x55, 0x55, 0x55, 0xA5, 0x55, 0xA5, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA
DEFB 0xAE, 0xAA, 0x55, 0x55, 0x55, 0x55, 0x55, 0xA5, 0x55, 0xA5, 0x0A, 0xAA
DEFB 0x0A, 0xAA, 0x0A, 0xAA, 0x00, 0xAA, 0x55, 0x55, 0x55, 0x55, 0x55, 0xA5
DEFB 0x55, 0xA5, 0x0A, 0x0A, 0x0A, 0x00, 0x00, 0xAA, 0x00, 0xAA, 0x55, 0x55
DEFB 0x55, 0x55, 0x55, 0xA5, 0x55, 0x25, 0x0A, 0x00, 0x02, 0x00, 0x00, 0xAA
DEFB 0x00, 0x22, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x05, 0x50
DEFB 0x05, 0x50, 0x00, 0x55, 0x00, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55
DEFB 0x55, 0x55, 0x05, 0x50, 0x05, 0x50, 0x00, 0x55, 0x00, 0x55, 0x55, 0x55
DEFB 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x05, 0x50, 0x05, 0x50, 0x00, 0x55
DEFB 0x00, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x05, 0x50
DEFB 0x00, 0x50, 0x00, 0x55, 0x00, 0x50, 0x55, 0x55, 0x55, 0x55

DEFM "SDTest:"
SDTest:			; 8x8
DEFB 0x08, 0x08, 0x20, 0x00
DEFB 0x33, 0x33, 0xF3, 0xFF, 0x33, 0x33, 0xFF, 0x3F, 0xF3, 0xF0, 0xF3, 0xF0
DEFB 0x0F, 0x3F, 0x0F, 0x3F, 0xF3, 0xFF, 0xF3, 0xDD, 0xFF, 0x3F, 0xDD, 0x3F
DEFB 0xF3, 0xFF, 0x33, 0x33, 0xFF, 0x3F, 0x33, 0x33

DEFM "SDMario:"
SDMario:			; 16x32
DEFB 	0x10, 0x20, 0x00, 0x01
DEFB 	0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F
DEFB 	0xFF, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x00, 0xF0, 0xFF, 0xFF
DEFB 	0xFF, 0xFF, 0x2F, 0x02, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xA0
DEFB 	0x00, 0x2A, 0xAA, 0x22, 0xA2, 0x22, 0x2A, 0x22, 0xAA, 0x22, 0x00, 0x00
DEFB 	0x22, 0x00, 0x00, 0x2A, 0xA0, 0x2A, 0xA2, 0x2A, 0xA2, 0x2A, 0x22, 0x22
DEFB 	0x22, 0x2A, 0x22, 0x02, 0x22, 0x02, 0xA0, 0x2A, 0xA0, 0xAA, 0x22, 0x22
DEFB 	0x22, 0x22, 0xAA, 0xAA, 0xA2, 0xAA, 0xAA, 0x00, 0xAA, 0x00, 0x00, 0xA0
DEFB 	0x00, 0x00, 0x2A, 0x22, 0x2F, 0x22, 0x22, 0x22, 0x22, 0x0A, 0x02, 0x00
DEFB 	0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0xFA, 0xAA, 0xFA, 0xAA, 0xAA, 0xAF
DEFB 	0xAA, 0xAF, 0x00, 0x00, 0x0A, 0x00, 0x00, 0xAA, 0xA0, 0xAA, 0xFA, 0xAA
DEFB 	0xFA, 0xAA, 0xAA, 0xAF, 0xAA, 0xAF, 0xAA, 0x00, 0xAA, 0x0A, 0xA0, 0xAA
DEFB 	0xAA, 0xAA, 0xFF, 0xAA, 0xFF, 0xAA, 0xAA, 0xFF, 0xAA, 0xFF, 0xAA, 0x0A
DEFB 	0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xFF, 0xFF, 0x2F, 0xFF, 0xFF, 0xFF
DEFB 	0xFF, 0xF2, 0xAA, 0xAA, 0xAA, 0xAA, 0x22, 0x22, 0x22, 0x22, 0xFF, 0xFF
DEFB 	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x22, 0x22, 0x22, 0x22, 0x20, 0x22
DEFB 	0x20, 0xF2, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x22, 0x02
DEFB 	0x2F, 0x02, 0x00, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0xFF
DEFB 	0xF0, 0xFF, 0xFF, 0x00, 0xFF, 0x0F, 0xF0, 0xFF, 0xF0, 0xFF, 0xFF, 0x00
DEFB 	0xFF, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0x0F, 0xFF, 0x0F, 0x00, 0xAA
DEFB 	0x00, 0xAA, 0xAA, 0x00, 0xAA, 0x00, 0x00, 0xAA, 0x00, 0xAA, 0xAA, 0x00
DEFB 	0xAA, 0x00, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0x00, 0xAA, 0x00, 0x00, 0xAA
DEFB 	0x00, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA

DEFM "Sprite8x64:"
SDSprite8x64:		; 8x64
DEFB 0x08, 0x40, 0x00, 0x10
DEFB 0xF0, 0xF0, 0x22, 0x22, 0xF0, 0xF0, 0x22, 0x22, 0x66, 0x66
DEFB 0xF6, 0xFF, 0x66, 0x66, 0x66, 0x22, 0x44, 0xFF, 0x66, 0x6F, 0xE6, 0xF2
DEFB 0xEE, 0xF2, 0x66, 0x66, 0xEE, 0xEE, 0xEE, 0x22, 0xEE, 0x22, 0xEE, 0xEE
DEFB 0x22, 0x22, 0x2E, 0x12, 0xFF, 0x1F, 0x11, 0xFF, 0x11, 0x3F, 0xFF, 0x1F
DEFB 0x3F, 0x1F, 0x17, 0x0F, 0x17, 0x33, 0x00, 0x1F, 0x3F, 0x13, 0x17, 0xFF
DEFB 0x17, 0x11, 0xF3, 0x1F, 0x11, 0x11, 0x97, 0x1F, 0x97, 0x1F, 0xF1, 0x9F
DEFB 0xFF, 0x99, 0x97, 0x1F, 0x97, 0xFF, 0xF1, 0x99, 0xF1, 0x99, 0x97, 0x1F
DEFB 0x99, 0xFF, 0xF1, 0x99, 0xFF, 0x99, 0xF9, 0x11, 0xF9, 0xF1, 0xF1, 0x99
DEFB 0xF1, 0x99, 0xF9, 0x11, 0xF9, 0xF1, 0xF1, 0x99, 0xF1, 0x99, 0xF9, 0xFF
DEFB 0xF9, 0xF1, 0xFF, 0x99, 0xFF, 0x99, 0xF9, 0xF1, 0xF9, 0x11, 0xFF, 0x99
DEFB 0xF1, 0x99, 0xF9, 0x11, 0xF9, 0xFF, 0xF1, 0x99, 0xFF, 0x99, 0xF9, 0xFF
DEFB 0xF7, 0x1F, 0xFF, 0x99, 0xF1, 0x99, 0x97, 0xFF, 0x97, 0xFF, 0xFF, 0x99
DEFB 0xF1, 0x99, 0x90, 0xF9, 0x07, 0x99, 0x9F, 0x99, 0x00, 0x99, 0x07, 0x0F
DEFB 0x07, 0x0F, 0xF0, 0x00, 0xFF, 0xF0, 0x07, 0xF0, 0xF0, 0xFF, 0x0F, 0xFF
DEFB 0xF0, 0x0F, 0x00, 0x0F, 0x07, 0xF0, 0xFF, 0x00, 0x0F, 0xF0, 0x07, 0xFF
DEFB 0x07, 0x0F, 0x00, 0x0F, 0xF0, 0x0F, 0x07, 0x0F, 0x07, 0xF0, 0xFF, 0x00
DEFB 0x0F, 0xF0, 0x07, 0xFF, 0x07, 0xFF, 0x00, 0xAF, 0xF0, 0xAF, 0x07, 0x0F
DEFB 0x77, 0x00, 0xFF, 0x4A, 0xAF, 0x44, 0x00, 0xF0, 0x07, 0xFF, 0xAF, 0x44
DEFB 0xAA, 0x44, 0xF0, 0xAF, 0xF7, 0xAF, 0x4A, 0x44, 0x44, 0x44, 0xF7, 0x4A
DEFB 0xA7, 0x44, 0x44, 0x44, 0xF4, 0x44, 0xA7, 0x44, 0xA7, 0xF4, 0xFF, 0x44
DEFB 0xFF, 0x44, 0xAA, 0xAA, 0xA7, 0xAF, 0xAF, 0xAA, 0xAF, 0xAF, 0xA7, 0xAF
DEFB 0xAA, 0xAF, 0xAF, 0xAF, 0xAA, 0xAF

DEFM "SDSubzero:"
SDSubzero:			; 32x56
DEFB 0x20, 0x38, 0x80, 0x03
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xAF, 0x00, 0x0A, 0x00, 0xF0, 0xFF, 0x00, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x0A, 0x00, 0x0A, 0x00, 0x00, 0xFF, 0x00, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0x0A, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
DEFB 0x00, 0xF0, 0xAA, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A, 0x00, 0xF2, 0xA0, 0x22
DEFB 0xFF, 0x0F, 0xFF, 0x0F, 0x00, 0x20, 0x00, 0xA0, 0x2A, 0xF0, 0xFF, 0xF5
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x0A, 0x00, 0x00, 0x7A, 0x00, 0xA0, 0xFF, 0x55, 0x0F, 0xA0, 0x00, 0x00
DEFB 0x0A, 0x50, 0x00, 0x55, 0x55, 0xFF, 0x55, 0xF5, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xAF, 0x00, 0x00, 0x00, 0x0A
DEFB 0x54, 0x55, 0x55, 0x55, 0x55, 0x04, 0x55, 0x05, 0x00, 0x50, 0x00, 0x00
DEFB 0x55, 0x55, 0x55, 0x55, 0xF5, 0xFF, 0x55, 0xF5, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0x07, 0xAF, 0x00, 0xAA, 0xAA, 0xAA, 0x00, 0x55, 0x54, 0x55, 0x54
DEFB 0x55, 0x05, 0x55, 0x55, 0x00, 0x00, 0x00, 0x00, 0x52, 0x5F, 0xF2, 0x5F
DEFB 0xD5, 0xFF, 0x5D, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A, 0xFF, 0xFF
DEFB 0x00, 0x00, 0xFF, 0xFF, 0x55, 0x45, 0x45, 0x55, 0x54, 0x55, 0x45, 0x55
DEFB 0x00, 0x00, 0x00, 0x00, 0xF2, 0xDF, 0xFF, 0xDF, 0xFD, 0xFF, 0xF5, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x5F, 0xF5, 0x5F, 0x55, 0x5F, 0x54, 0xFF, 0x55, 0x00, 0x00, 0x00, 0x00
DEFB 0x52, 0x55, 0x52, 0x55, 0xF7, 0xFF, 0x2F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x55, 0xFF, 0x5F
DEFB 0xF5, 0xFF, 0xF5, 0xFF, 0x00, 0x20, 0x00, 0x20, 0x52, 0x54, 0x55, 0x05
DEFB 0x72, 0xFF, 0xA2, 0xF7, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x0F, 0xF0, 0xFF, 0x50, 0xFF
DEFB 0x04, 0x50, 0x04, 0x20, 0x5F, 0x05, 0x55, 0xF4, 0x2A, 0xA7, 0xA0, 0x22
DEFB 0xFF, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0x0F, 0xFF, 0xFF, 0x00, 0x0F, 0x00, 0x00, 0x05, 0x55, 0x05, 0x55
DEFB 0x55, 0xF0, 0x45, 0xF0, 0x00, 0x00, 0x0F, 0x00, 0xF0, 0xFF, 0x00, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x00, 0x44, 0x00, 0x00, 0x55, 0x55, 0x44, 0x44, 0x55, 0xF0, 0x00, 0x00
DEFB 0xFF, 0x2A, 0xFF, 0x2F, 0x00, 0xF0, 0x00, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x0F, 0x00, 0x00, 0x00, 0x00
DEFB 0x55, 0x55, 0x55, 0x55, 0x05, 0x00, 0x05, 0x00, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x00, 0x00, 0x0A, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x55, 0x55
DEFB 0x05, 0x00, 0x05, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x02, 0xAA, 0x02, 0xA2
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00
DEFB 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x55, 0x55, 0x05, 0x00, 0x05, 0x00
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xAF, 0xFA, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00
DEFB 0x55, 0x55, 0x55, 0x55, 0x05, 0x00, 0x05, 0x00, 0xF0, 0xFF, 0xF0, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x0F, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x45, 0x55
DEFB 0x05, 0x00, 0x55, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x00, 0x0F, 0x00
DEFB 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x44, 0x55, 0x55, 0x00, 0x45, 0x00
DEFB 0x00, 0xFF, 0x00, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x0F, 0x00, 0x00, 0xF0, 0x00, 0x00
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF, 0xF0, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
DEFB 0x00, 0xF0, 0x00, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x0F
DEFB 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xF0, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x40
DEFB 0xF0, 0xFF, 0xF5, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x00, 0x00, 0x00, 0x04, 0xF0, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x40, 0x00, 0x00, 0xF5, 0xFF, 0xF5, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x44, 0x00, 0x54
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x0F, 0x40, 0x0F, 0x00, 0xF4, 0xFF, 0xF4, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x54, 0x00, 0x54, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x40, 0x0F, 0x45
DEFB 0xF0, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x00, 0x0F, 0x00, 0xF0, 0xFF, 0x00, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x00, 0x00, 0xF0, 0x00, 0xFF
DEFB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
DEFB 0x0F, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00

ENDIF