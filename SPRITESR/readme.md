# Planning

Sprites: support for 8 sprites of custom width, height, and background color.

Sprites run every other frame (30 fps) and if I had performance issues: every 3rd frame (20 fps).

An alternative to this is redrawing half or third of the sprites every frame then incrementing that to next batch.

If performance allows it:

Tiles: support for up to 32 16x16 different tiles (4KB) and any size. Tilemaps should include scroll helper to only redraw changed tiles?

# Pseudo Code

// Sprite system

uint8 spritesRedraw;// 1 bit per sprite for redraw

const uint8 [8] sprite_stateMasks = {
	0x1, 0x10, 0x100, 0x1000,
0x10000, 0x100000, 0x1000000, 0x10000000
};

struct sprite8x8 {
	ptr* data;		// 32 bytes 8x8 pixels data
	uint8 x;
	uint8 y;
	uint8 width;	
	uint8 height;
	uint8 bgColor;	// color for clearing
	// size to this point: 7 Bytes
	sprite8x8 redraw;	// Sprite info for redraw
	// size to this point = 14 Bytes
};

sprite8x8* sprites = { 8 sprites };

void onVSYNC() {
	if(spritesRedraw != 0) {
		redrawSprite(sprites[0x1]);
		redrawSprite(sprites[0x10]);
		redrawSprite(sprites[0x100]);
		redrawSprite(sprites[0x1000]);
		redrawSprite(sprites[0x10000]);
		redrawSprite(sprites[0x100000]);
		redrawSprite(sprites[0x1000000]);
		redrawSprite(sprites[0x10000000]);
	}
}

void redrawSprite(spirte8x8* spr) {
	clearSprite(spr);
	// Copy redraw to sprite 
	spr.data = spr.redraw.data;
	spr.x = spr.redraw.x;
	spr.y = spr.redraw.y;
	spr.width = spr.redraw.width;
	spr.height = spr.redraw.height;
	spr.bgColor = spr.redraw.bgColor;
	// Draw new sprite 
	drawSprite(spr)'
}

// Tile system



void fastDrawSprite(uint8 x, uint8 y, ptr* sprite) {
	ptr* vram_addr = FASTSTARTADR + CoordsToAddr(x, y);
	uint8 width = sprite[0];
	uint8 wstep = FASTBYTEWIDTH - width
	uint8 height = sprite[1] >> 1;
	sprite += 4;
	for(int j = 0; j < height; ++j) {
		for(int i = 0; i < width; ++i) {
			*vram_addr = *sprite;
			vram_addr++;
			sprite++;
		}
		vram_addr += wstep;
	}
}

void fastClearSprite(uint8 x, uint8 y, ptr* sprite, uint8 color) {
	ptr* vram_addr = FASTSTARTADR + CoordsToAddr(x, y);
	uint8 width = sprite[0];
	uint8 wstep = FASTBYTEWIDTH - width
	uint8 height = sprite[1] >> 1;
	for(int j = 0; j < height; ++j) {
		for(int i = 0; i < width; ++i) {
			*vram_addr = color;
			vram_addr++;
		}
		vram_addr += wstep
	}
}

# Old Code Buffer

OLDPICARD_UPDATE:
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
OLDPICARD_RIGHT:
	INC (HL)
	JP PICARD_UPDATE
OLDPICARD_LEFT:
	DEC (HL)
	JP PICARD_UPDATE
OLDPICARD_UP:
	EX DE, HL
	DEC (HL)
	JP PICARD_UPDATE
OLDPICARD_DOWN:
	EX DE, HL
	INC (HL)
	JP PICARD_UPDATE
OLDPICARD_END:
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

