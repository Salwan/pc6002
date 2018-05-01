# Python script to read, map and export
# a PNG file to hex PC-6001 format.
# Supports both Mode 5 and 6
# Search for NotImplemented for TODO :)

import sys
import binascii
from PIL import Image

p6pal_rgba = [
0xFF101410, # 1
0xFFAD00FF,	# 2
0xFFFFAE00,	# 3
0xFFFF00AD, # 4
0xFF00FFAD,	# 5
0xFF00AEFF, # 6
0xFFADFF00, # 7
0xFFADAEAD, # 8
0xFF101410, # 9
0xFF0000FF, # 10
0xFFFF0000, # 11
0xFFFF00FF, # 12
0xFF00FF00, # 13
0xFF00FFFF, # 14
0xFFFFFF00, # 15
0xFFFFFFFF  # 16
]

if len(sys.argv) < 2:
	print("Converts a given PNG to PC-60 binary bytes ready to be used in Mode 5 or 6.")
	print("Usage: python png60.py pngfile [-M]")
	print("Example: python png60.py image.png -5")
	print("Only mode 5 and 6 are supported. Script will default to mode 5")
	print("Size limit applied: 256x200.")
	print("First 2 bytes in files is the width/height of the bitmap.")
	print(" Optional parameters: ")
	print("  -d: doubles horizontal lines to produce a correct ratio image in mode 5 half resolution 3,2,2")
	exit();
	
image_file = ""
mode_number = 5
doubler = False

c = 0
for a in sys.argv:
	c += 1
	if c <= 1: 
		continue
	s = str(a)
	print("Argument " + str(c) + ": " + s)
	if s[0] == '-' and (s[1] == '5' or s[1] == '6'):
		mode_number = int(s[1])
		print("    Mode select: MODE " + str(mode_number))
		if mode_number != 5 and mode_number != 6:
			raise NotImplementedError("Unsupported mode specified: " + s)
	elif s.endswith(".png"):
		print("    PNG file = " + s)
		image_file = s;
	elif s[0] == '-':
		if s[1] == 'd':
			doubler = True
	else:
		print("    Unknown " + s)

assert(len(image_file) > 0 and (mode_number == 5 or mode_number == 6))

# Convert palette to tuplelist
p6rgb = []
p6rgb_p6color = {}
p6_bmp = [] # list of colors in p6 palette
p6_hex_atr = [] # ATR list of color high bytes in p6 palette
p6_hex_adr = [] # ADR list of color low bytes in p6 palette
				# or mode 6 colors
col = 1
for h in p6pal_rgba:
	r = int((h >> 16) & 0xff);
	g = int((h >> 8) & 0xff);
	b = int((h & 0xff))
	p6rgb.append((r,g,b))
	p6rgb_p6color[(r,g,b)] = col if col != 9 else 1 # 9 overwrites 1!
	col += 1
	
def calc_rgb_diff(c1, c2):
	return abs(c1[0] - c2[0]) + abs(c1[1] - c2[1]) + abs(c1[2] - c2[2])
	
def find_nearest_p6_color(c):
	curr_color = 0
	least_diff = 256
	for (rgb,p6c) in p6rgb_p6color.iteritems():
		a = calc_rgb_diff(c, rgb)
		if a < least_diff:
			least_diff = a
			curr_color = p6c
	return curr_color

def test_print_p6_bmp(w):
	h = 0
	ostr = ""
	for b in p6_bmp:
		if b < 10: 
			ostr += " "
		ostr += str(b)
		h += 1
		if h >= w:
			ostr += "\n"
			h = 0
	print(ostr)
	
def test_print_p6_hex(hx, pixel_width):
	c = 0
	ostr = ""
	w = pixel_width / 4
	for b in hx:
		sb=str(hex(b)[2:])
		while len(sb)<3:
			sb = " " + sb
		ostr += sb
		c += 1
		if c >= w:
			ostr += '\n'
			c = 0
	print(ostr)
	
# c is the p6 color, place is the pixel index in block: 0 1 2 3
# returns byte values for: (ATR, ADR)
def convert_color_to_byte_5(c, place):
	byte_offsets = []
	maskH = 0b1100
	maskL = 0b0011
	assert(place >= 0 and place < 4)
	c = c if c != 9 else 1
	hc = c - 1 # 0b0000 to 0b1111 value
	pn = 3 - place # place is 0 1 2 3, flip it to match X shift
	atr = ((hc & maskH) >> 2) << (pn * 2)
	adr = (hc & maskL) << (pn * 2)
	return (atr, adr)
	
# c is the p6 color, place is the pixel index in block: 0 1
# returns byte value
def convert_color_to_byte_6(c, place):
	c = c if c != 9 else 1
	return ((c - 1) << (place * 4))

# takes a block of 1 to 4 pixels (pads with zeros if < 4)
# then generates the Mode 5 screen 3,2,2 byte for that block
def process_color_byte_block_5(block):
	while len(block) < 4:
		block.append(0)
	p = [convert_color_to_byte_5(block[i], i) for i in range(0, 4)]
	atr = p[0][0] + p[1][0] + p[2][0] + p[3][0]
	adr = p[0][1] + p[1][1] + p[2][1] + p[3][1]
	p6_hex_atr.append(atr)
	p6_hex_adr.append(adr)
	
# Takes a block of 1 to 2 pixels (pads with zero if 1)
# then generates the Mode 6 screen 2,2,2 byte for that block
def process_color_byte_block_6(block):
	while len(block) < 2:
		block.append(0)
	p = [convert_color_to_byte_6(block[i], i) for i in range(0, 2)]
	adr = p[0] + p[1]
	p6_hex_adr.append(adr)
		
# Do the magic!
png = Image.open(image_file)

if png:
	print("PNG opened: ")
	print("    Format = " + str(png.format));
	print("    Size   = " + str(png.size));
	print("    Mode   = " + (png.mode));
	if png.size[0] > 256 or png.size[1] > 200:
		raise NotImplementedError("Size of given png exceeds P6 supported size 256x200, auto-scaling not implemented yet.")
	if mode_number == 5 and png.size[0] % 4 != 0:
		raise NotImplementedError("Width of given png doesn't match pixel blocks of 4 in mode 5. Auto padding will be implemented in the future.")
	if mode_number == 6 and png.size[0] % 2 != 0:
		raise NotImplementedError("Width of given png doesn't match pixel blocks of 2 in mode 6. Auto padding will be implemented in the future.")
	png_data = list(png.getdata())
	print("Palette:")
	print(str(p6rgb_p6color))
	for c in png_data:
		# c in the format (r, g, b)
		p6_bmp.append(find_nearest_p6_color(c))
	print("P6 BMP:")
	#test_print(png.size[0])
	# Generate hexadecimal
	gc = [] # group colors
	for p6c in p6_bmp:
		gc.append(p6c)
		if mode_number == 5:
			if len(gc) >= 4:
				process_color_byte_block_5(gc)
				gc=[]
		elif mode_number == 6:
			if len(gc) >= 2:
				process_color_byte_block_6(gc)
				gc=[]
		else:
			raise NotImplementedError("Conversion: Invalid mode = " + str(mode_number))
	if mode_number == 5:
		print("P6 Hex: " + str(len(p6_hex_atr)) + " byte pairs")
		#print("ATR: ")
		#test_print_p6_hex(p6_hex_atr,png.size[0])
		#print("ADR: ")
		#test_print_p6_hex(p6_hex_adr,png.size[0])
		out_name = image_file[:-4]
		adr_out_file = out_name + ".lo.p6bmp" 
		atr_out_file = out_name + ".hi.p6bmp"
	else:
		print("P6 Hex: " + str(len(p6_hex_adr)) + " byte pairs")
		out_name = image_file[:-4]
		adr_out_file = out_name + ".p6bmp"
	print("Out Name = " + out_name)
	print("Prepending size of bitmap..")
	if mode_number == 5:
		# Adding size to data, first 2 bytes:
		mul=1 if doubler == False else 2
		p6_hex_adr.insert(0, min(png.size[1] * mul, 0xff))
		p6_hex_adr.insert(0, min(png.size[0], 0xff))
		p6_hex_atr.insert(0, min(png.size[1] * mul, 0xff))
		p6_hex_atr.insert(0, min(png.size[0], 0xff))
		if doubler == True:
			print("Doubler will double the vertical resolution..")
			p6b1 = [p6_hex_adr[0], p6_hex_adr[1]]
			p6b2 = [p6_hex_atr[0], p6_hex_atr[1]]
			rv = 0
			szw = png.size[0]/4
			dline1 = []
			dline2 = []
			for i in range(2, len(p6_hex_adr)):
				dline1.append(p6_hex_adr[i])
				dline2.append(p6_hex_atr[i])
				rv += 1
				if rv >= szw:
					p6b1 += dline1 + dline1
					p6b2 += dline2 + dline2
					dline1 = []
					dline2 = []
					rv = 0
			p6_hex_adr = p6b1
			p6_hex_atr = p6b2
			#print("Doubler check..")
		#print("ADR")
		#test_print_p6_hex(p6_hex_adr,png.size[0])
		#print("ATR")
		#test_print_p6_hex(p6_hex_atr,png.size[0])
		#exit()
		print("Writing " + str(len(p6_hex_adr)) + " Low bytes to: " + adr_out_file)
		with open(adr_out_file, "wb+") as f:
			towrite = bytearray(p6_hex_adr)
			f.write(towrite)
		print("Writing " + str(len(p6_hex_atr)) + " High bytes to: " + atr_out_file)
		with open(atr_out_file, "wb+") as f:
			towrite = bytearray(p6_hex_atr)
			f.write(towrite)
	elif mode_number == 6:
		# width and height
		p6_hex_adr.insert(0, min(png.size[1], 0xff))
		p6_hex_adr.insert(0, min(png.size[0], 0xff))
		print("Writing " + str(len(p6_hex_adr)) + " bytes to: " + adr_out_file)
		with open(adr_out_file, "wb+") as f:
			towrite = bytearray(p6_hex_adr)
			f.write(towrite)
	else:
		raise NotImplementedError("Invalid mode: " + str(mode_number))
else:
	print("Failed to open png file: " + image_file)
	
	
	
	
	
	
	