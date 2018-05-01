# Python sript to read p6bmp files and generate a BASIC program
# that views the file in the respective mode.
# Supports both Mode 5 and 6.
# For mode 5 you need two files, one for Hi bytes and one for Lo bytes
# BASIC program will use screen 3 on Mode 5 and 2 on Mode 6
# Search for NotImplemented for TODO :)

import sys
import binascii

gen_pages = 3 # pages mode to use (changes address)

BASM5_TEMPLATE_NORMAL = """10 SCREEN 3,2,2:CLS
20 X={posx}:Y={posy}:REM X is / 4
30 BW={bmpwidth}:BH={bmpheight}:REM BW is / 4
40 AD={loaddress}:AT={hiaddress}
50 SW=40:REM Size of horiz line
60 OF=(Y*SW)+X
70 REM Hi bytes
80 FOR J=0 TO BH-1
90 FOR I=0 TO BW-1
100 READ A$
110 POKE AT+OF+(J*SW)+I,VAL("&H"+A$)
120 NEXT I
130 NEXT J
140 REM Lo bytes
150 FOR J=0 TO BH-1
160 FOR I=0 TO BW-1
170 READ A$
180 POKE AD+OF+(J*SW)+I,VAL("&H"+A$)
190 NEXT I
200 NEXT J
210 I$=INKEY$:IF I$="" THEN 210
"""

BASM6_TEMPLATE_NORMAL = """10 SCREEN 2,2,2:CLS
40 X={posx}:Y={posy}:REM X,Y
50 BW={bmpwidth}:BH={bmpheight}:REM BW is / 2
60 AD={address}
070 SW=128
080 OF=(Y*SW)+X
090 FOR J=0 TO INT(BH-1) STEP 2
100 L0=AD+OF+(J*SW)
110 L1=L0+2
120 REM LINE 0
130 FOR I=0 TO (BW*2)-1 STEP 4
140 READ A1$,A2$
150 POKE L0+I,VAL("&H"+A1$)
160 POKE L0+I+1,VAL("&H"+A2$)
170 NEXT I
180 REM LINE 1
190 FOR I=0 TO (BW*2)-1 STEP 4
200 READ A1$,A2$
210 POKE L1+I,VAL("&H"+A1$)
220 POKE L1+I+1,VAL("&H"+A2$)
230 NEXT I
250 NEXT J
270 I$=INKEY$:IF I$="" THEN 270
"""

BASM5_TEMPLATE_DOUBLER = """10 SCREEN 3,2,2:CLS
20 X={posx}:Y={posy}:REM X is / 4
30 BW={bmpwidth}:BH={bmpheight}:REM BW is / 4
40 AD={loaddress}:AT={hiaddress}
50 SW=40:REM Size of horiz line
60 OF=(Y*SW)+X
70 REM Hi bytes
80 FOR J=0 TO BH-1
90 FOR I=0 TO BW-1
100 READ A$
105 A=AT+OF+(J*SW*2)+I
110 POKE A,VAL("&H"+A$)
115 POKE A+SW,VAL("&H"+A$)
120 NEXT I
130 NEXT J
140 REM Lo bytes
150 FOR J=0 TO BH-1
160 FOR I=0 TO BW-1
170 READ A$
175 A=AD+OF+(J*SW*2)+I
180 POKE A,VAL("&H"+A$)
185 POKE A+SW,VAL("&H"+A$)
190 NEXT I
200 NEXT J
210 I$=INKEY$:IF I$="" THEN 210
"""

BASM5_TEMPLATE_DOUBLER_COMPRESSED = """10 SCREEN 3,2,2:CLS
20 X={posx}:Y={posy}:REM X is /4
30 BW={bmpwidth}:BH={bmpheight}:REM BW is / 4
40 AD={loaddress}:AT={hiaddress}
50 SW=40:REM Size line in screen mode
60 RO=0:REM Output uncompressed byte
70 OF=(Y*SW)+X
80 REM Hi bytes
90 GOSUB 300:REM Start new decompression
100 FOR J=0 TO BH-1
110 FOR I=0 TO BW-1
120 GOSUB 500:REM Read next value
130 A=AT+OF+(J*SW*2)+I
140 POKE A,RO
150 POKE A+SW,RO
160 NEXT I
170 NEXT J
180 REM Lo bytes
190 GOSUB 300:REM Start new decompression
200 FOR J=0 TO BH-1
210 FOR I=0 TO BW-1
220 GOSUB 500:REM Read next value
230 A=AD+OF+(J*SW*2)+I
240 POKE A,RO
250 POKE A+SW,RO
260 NEXT I
270 NEXT J
280 I$=INKEY$:IF I$="" THEN 280
290 END
300 REM NEWRLE: Start new RLE decompression
310 R1 = 0:REM STATUS: 0=nothing 1=read 2=rle
320 R2 = 0:REM COUNT count of things
330 R3 = 0:REM BYTE  last byte read
340 R4$ = "":REM READ BUFFER
350 RETURN
360 REMNEXTRLE: new RLE data
370 R1=0:R2=0:READ R4$:R3=VAL("&H"+R4$)
380 IF R3=0 THEN R1=1:READ R4$:R2=VAL("&H"+R4$)
390 IF R3>0 THEN R1=2:READ R4$:RO=VAL("&H"+R4$):R2=R3
500 REMNEXTVALUE: Read next uncompressed value 
510 IF R1 = 1 THEN GOTO 530
520 IF R1 = 2 THEN GOTO 590
530 REMSTATUS1: Direct Read
540 IF R2 = 0 THEN GOTO 360
550 R2 = R2 - 1
560 READ R4$
570 RO=VAL("&H"+R4$)
580 RETURN
590 REMSTATUS2: RLE Read 
600 IF R2 = 0 THEN GOTO 360
610 R2 = R2 - 1
620 RETURN
"""

BASM6_TEMPLATE_COMPRESSED = """10 SCREEN 2,2,2:CLS
40 X={posx}:Y={posy}:REM X,Y
50 BW={bmpwidth}:BH={bmpheight}:REM BW is / 2
60 AD={address}
70 SW=128
80 OF=(Y*SW)+X
85 GOSUB 300:REM Start uncompressing
90 FOR J=0 TO INT(BH-1) STEP 2
100 L0=AD+OF+(J*SW)
110 L1=L0+2
120 REM LINE 0
130 FOR I=0 TO (BW*2)-1 STEP 4
140 GOSUB 500:A1=RO
145 GOSUB 500:A2=RO
150 POKE L0+I,A1
160 POKE L0+I+1,A2
170 NEXT I
180 REM LINE 1
190 FOR I=0 TO (BW*2)-1 STEP 4
200 GOSUB 500:A1=RO
205 GOSUB 500:A2=RO
210 POKE L1+I,A1
220 POKE L1+I+1,A2
230 NEXT I
250 NEXT J
270 I$=INKEY$:IF I$="" THEN 270
280 END
300 REM NEWRLE: Start new RLE decompression
305 RO = 0:REM OUTPUT byte
310 R1 = 0:REM STATUS: 0=nothing 1=read 2=rle
320 R2 = 0:REM COUNT count of things
330 R3 = 0:REM BYTE  last byte read
340 R4$ = "":REM READ BUFFER
350 RETURN
360 REM NEXTRLE: new RLE data
370 R1=0:R2=0:READ R4$:R3=VAL("&H"+R4$)
380 IF R3=0 THEN R1=1:READ R4$:R2=VAL("&H"+R4$)
390 IF R3>0 THEN R1=2:READ R4$:RO=VAL("&H"+R4$):R2=R3
500 REM NEXTVALUE: Read next uncompressed value 
510 IF R1 = 1 THEN GOTO 530
520 IF R1 = 2 THEN GOTO 590
530 REM STATUS1: Direct Read
540 IF R2 = 0 THEN GOTO 360
550 R2 = R2 - 1
560 READ R4$
570 RO=VAL("&H"+R4$)
580 RETURN
590 REM STATUS2: RLE Read 
600 IF R2 = 0 THEN GOTO 360
610 R2 = R2 - 1
620 RETURN
"""


if len(sys.argv) < 2:
	print("Generates a BASIC file that writes and tests a p6bmp file in Mode 5 or Mode 6.")
	print("Usage for Mode 5: python p6bmp2bas.py file.hi.p6bmp file.lo.p6bmp")
	print("Usage for Mode 6: python p6bmp2bas.py file.p6bmp")
	print(" Optional: ")
	print("  -x 120: will set X to 120/4 in program")
	print("  -y 50: will set Y to 50 in program")
	print("\nIf x and y aren't specified, the image is centered to 320x200.")
	print("  -D double horizontal lines for mode 5 screen 3 in BASIC (no memory cost!)")
	print("  -R enable simple RLE compression")
	exit()
	
image_file = [None, None]
stripped_filename = ""
mode = 0
bwidth = 0
bheight = 0
target_x = -1
target_y = -1
bas_doubler = False
enable_rle = False

c = 0
for a in sys.argv:
	c += 1
	if c <= 1:
		continue
	s = str(a)
	if s.endswith(".lo.p6bmp"):
		mode = 5
		image_file[1] = s
	elif s.endswith(".hi.p6bmp"):
		mode = 5
		image_file[0] = s
	elif s.endswith(".p6bmp"):
		mode = 6
		image_file[0] = s
	elif s[0] == '-':
		if s[1] == 'x':
			target_x = int(sys.argv[c])
		elif s[1] == 'y':
			target_y = int(sys.argv[c])
		elif s[1] == 'D':
			bas_doubler = True
		elif s[1] == 'R':
			enable_rle = True
		elif s[1] == '5':
			mode = 5
		elif s[1] == '6':
			mode = 6
		else:
			print("Unknown flag: " + s[1])
	elif s[0].isalpha():
		print("Assuming given keyword `" + s + "` is stripped filename..")
		stripped_filename = s
	else:
		print("Unknown argument: " + s)

# Mode 5 require both .lo.p6bmp and .hi.p6bmp
# Mode 6 requires one .p6bmp
if image_file[0] == None and image_file[1] == None and len(stripped_filename) > 0:
	if mode == 5:
		print("Converting stripped file to Mode 5..")
		image_file[0] = stripped_filename + ".hi.p6bmp"
		image_file[1] = stripped_filename + ".lo.p6bmp"
	elif mode == 6:
		print("Converting stripped file to Mode 6..")
		image_file[0] = stripped_filename + ".p6bmp"
	
assert((mode == 5 and image_file[0].endswith(".hi.p6bmp") and image_file[1].endswith(".lo.p6bmp")) or (mode == 6 and image_file[0].endswith(".p6bmp") and image_file[1] == None))

out_file = "unset"
if mode == 5:
	out_file = image_file[0][:-9]
else:
	out_file = image_file[0][:-6]
out_file += ".bmp.bas"

print("Output file: " + out_file)

def test_print_p6m5_hex(hx, pixel_width):
	c = 0
	ostr = ""
	w = pixel_width / 4
	for b in hx:
		sb=str(b)#str(hex(b)[2:])
		while len(sb)<3:
			sb = " " + sb
		ostr += sb
		c += 1
		if c >= w:
			ostr += '\n'
			c = 0
	print(ostr)

def test_print_p6m6_hex(hx, pixel_width):
	c = 0
	ostr = ""
	w = pixel_width / 2
	for b in hx:
		sb=str(b)#str(hex(b)[2:])
		while len(sb)<3:
			sb = " " + sb
		ostr += sb
		c += 1
		if c >= w:
			ostr += '\n'
			c = 0
	print(ostr)
	
def parse_file(file):
	data = []
	with open(file, "rb") as f:
		byte = f.read(1)
		while byte:
			data.append(str(binascii.hexlify(byte)))
			byte = f.read(1)
	return data
		
def run():
	global bwidth,bheight,target_x,target_y
	if mode == 5:
		hi_data = parse_file(image_file[0])
		lo_data = parse_file(image_file[1])
		if len(hi_data) == 0 or len(lo_data) == 0:
			raise RuntimeError("Parsing failed for one or both files.")
		print("hi_data size = " + str(len(hi_data)))
		print("lo_data size = " + str(len(lo_data)))
		assert(int(hi_data[0],16) == int(lo_data[0],16))
		bwidth = int(hi_data[0], 16)
		bheight = int(hi_data[1], 16)
		print("width = " + str(bwidth))
		print("height = " + str(bheight))
		if target_x == -1:
			target_x = (320/8/2)-(bwidth/4/2)
		if target_y == -1:
			target_y = 100 - (bheight / 2)
		hi_data = hi_data[2:]
		lo_data = lo_data[2:]
		print("hi_data size = " + str(len(hi_data)))
		print("lo_data size = " + str(len(lo_data)))
		bas_program = generate_basic_5(hi_data, lo_data, bwidth, bheight)
		with open(out_file, "w+") as f:
			f.write(bas_program)
			print("File '" + out_file + "' written.")
	else:
		data = parse_file(image_file[0])
		if len(data) == 0:
			raise RuntimeError("Parsing failed for p6bmp file")
		print("data size = " + str(len(data)))
		bwidth = int(data[0], 16)
		bheight = int(data[1], 16)
		print("width = " + str(bwidth))
		print("height = " + str(bheight))
		assert(bwidth % 2 == 0)#, "width must be a power of 2 for mode 6 bmp")
		assert(bheight % 2 == 0)#, "height must be a power of 2 for mode 6 bmp")
		if target_x == -1:
			target_x = (256 - bwidth)/2
			print("target x centered = " + str(target_x))
		if target_y == -1:
			target_y = 100 - (bheight / 2)
			print("target y centered = " + str(target_y))
		data = data[2:]
		print("pixel data size = " + str(len(data)))
		bas_program = generate_basic_6(data, bwidth, bheight)
		with open(out_file, "w+") as f:
			f.write(bas_program)
			print("File '" + out_file + "' written.")
		
def rle_compress_data(data, width, test_decompress=False):
	# build byte count array
	print("Compression running in Test mode")
	count_array = []
	# Build count array
	next_byte = ""
	curr_byte = ""
	skip_count = 0
	for i in range(0, len(data)):
		if skip_count > 0:
			count_array.append(0) # means don't care (reptition)
			skip_count -= 1
			continue
		byte_count = 0
		curr_byte = data[i]
		for j in range(i, len(data)):
			next_byte = data[j] # this will be true at least once
			if next_byte == curr_byte:
				byte_count += 1
			else:
				break
		count_array.append(byte_count)
		skip_count = byte_count - 1
	print("Count array prepared.")
	if test_decompress:
		test_print_p6m5_hex(count_array, 32)
	compressed = []
	# Perform compression based on count array
	i = 0
	skip_flag = False
	disable_rle_count = 0
	while i < len(data):
		curr_byte = data[i]
		if disable_rle_count > 0:
			compressed.append(curr_byte)
			disable_rle_count -= 1
		elif count_array[i] == 0: # repetition
			if skip_flag:
				pass
			else:
				compressed.append(curr_byte)
		elif count_array[i] < 3: # no point in compression
			compressed.append("00")
			disable_rle_count = count_array[i] # 1 or 2
			if i < len(data) - 1 - count_array[i]:
				for j in range(i + count_array[i], len(data)):
					if count_array[j] < 3: # 0-2 repetitions? disable rle
						disable_rle_count += 1
					else: # >=3 repetitions? compress that segment
						break
					if disable_rle_count == 255:
						# TODO find out what should go on hre
						break
			drc = str(hex(disable_rle_count)[2:])
			if len(drc) == 1: 
				drc = "0" + drc
			assert(len(drc) == 2)
			compressed.append(drc)
			if disable_rle_count > 0:
				disable_rle_count -= 1
			compressed.append(curr_byte)
		else: # >= 3 compress!
			ca = str(hex(count_array[i])[2:])
			if len(ca) == 1:
				ca = "0" + ca
			compressed.append(ca) # count of repetition
			compressed.append(curr_byte)
			skip_flag = True
		i += 1
	print("Compressed data:")
	test_print_p6m5_hex(compressed, 32)
	print(" Report:")
	print("   Original data = " + str(len(data)) + " bytes")
	print("   Compressed data = " + str(len(compressed)) + " bytes")
	if test_decompress:
		print("Testing against decompression.")
		print("Decompressing...")
		uncompressed = decompress_data(compressed)
		print("Uncompressed data = " + str(len(uncompressed)) + " bytes")
		print("Test dump after uncompression:")
		test_print_p6m5_hex(uncompressed, width)
		check_correctness = len(data) == len(uncompressed)
		if check_correctness:
			for i in range(0, len(data)):
				if data[i] != uncompressed[i]:
					check_correctness = False
					break
		if check_correctness:
			print("COMPRESSION IS CORRECT!")
			difference = len(data) - len(compressed)
			print("\nSAVED = " + (str(difference)) + " bytes")
		else:
			print("COMPRESSION IS INCORRECT!")
		#exit()
	return compressed

def decompress_data(rle_data):
	uncomp = []
	rle_byte = -1
	rle_disable = 0
	i = 0
	while i < len(rle_data):
		if rle_disable > 0:
			rle_disable -= 1
			uncomp.append(rle_data[i])
			rle_byte = -1
		else:
			if rle_byte == -1:
				rle_byte=int(rle_data[i],16)
			if i < len(rle_data) - 1:
				i+=1
				if rle_byte > 0:
					b = rle_data[i]
					for j in range(0, rle_byte):
						uncomp.append(b)
					rle_byte = -1
				else: # == 0 
					rle_disable = int(rle_data[i],16)
		i+=1
	return uncomp
			
def generate_basic_5(atr_data, adr_data, w, h):
	assert(len(atr_data) > 0 and len(adr_data) > 0)
	global target_x, target_y
	if gen_pages == 3:
		atr = "&h6000"
		adr = "&h4000"
	elif gen_pages == 4:
		atr = "&h8000"
		adr = "&ha000"
	else:
		raise AttributeError("gen_pages is incorrectly set.")
	print("ATR:")
	test_print_p6m5_hex(atr_data, w)
	print("ADR:")
	test_print_p6m5_hex(adr_data, w)
	if enable_rle:
		print("Compressing data...")
		atr_data = rle_compress_data(atr_data, w)
		adr_data = rle_compress_data(adr_data, h)
	template=""
	line=-1
	if not enable_rle:
		if not bas_doubler:
			template = BASM5_TEMPLATE_NORMAL
			line = 220
		else:
			if target_y == 100 - (h / 2):
				target_y = 100 - h
			template = BASM5_TEMPLATE_DOUBLER
			line = 220
	else: # RLE compression
		# no point in caring about doubler, always double.
		if target_y == 100 - (h / 2):
			target_y = 100 - h
		template = BASM5_TEMPLATE_DOUBLER_COMPRESSED
		line = 630
	bas=""
	bas+=str.format(template, posx=target_x, posy=target_y, bmpwidth=w/4, bmpheight=h, loaddress=adr, hiaddress=atr)
	c = 0
	all_data = atr_data + adr_data
	for d in all_data:
		if c == 0:
			bas += str(line) + " DATA"
			line += 10
		else:
			bas += ","
		bas += str(d)
		c += 1
		if c >= 18: # Mode 5 allows up to 19 datums
			c = 0
			bas += '\n'
	print("BASIC program generated:\n\n")
	print(bas)
	return bas

def generate_basic_6(data, w, h):
	assert(len(data) > 0)
	global target_x, target_y
	adr = "&h1a00"
	print("ADR:")
	test_print_p6m6_hex(data, w)
	if enable_rle:
		print("Compressing data...")
		data = rle_compress_data(data, w, True)
	template=""
	line=-1
	if not enable_rle:
		template = BASM6_TEMPLATE_NORMAL
		line = 300
	else: # RLE compression
		template = BASM6_TEMPLATE_COMPRESSED
		line = 650
	bas=""
	bas+=str.format(template, posx=target_x, posy=target_y, bmpwidth=w/2, bmpheight=h, address=adr)
	c = 0
	for d in data:
		if c == 0:
			bas += str(line) + " DATA"
			line += 10
		else:
			bas += ","
		bas += str(d)
		c += 1
		if c >= 80: # data can have up to 80 2 digit hexa
			c = 0
			bas += '\n'
	print("BASIC program generated:\n\n")
	print("LINE COUNT = " + str(line))
	#print(bas)
	return bas	

run()
	

	
	
	