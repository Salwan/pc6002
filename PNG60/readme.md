PNG to N66-BASIC Importer
===============================

Usage: each internal command has a set of options

PNG60 requires Python 2.7 (or 3 though I haven't tested it) and the Pillow library installed. For instructions, check the readme file in: requirements

To convert PNG to an N66 BASIC program on a cassette, simple drag the PNG and drop it over the batch file with the settings you want:

|                  | MODE | Pixels Doubled Vertically | RLE Compression |
|------------------|------|---------------------------|-----------------|
| png2bas5         | 5    | No                        | No              |
| png2bas5_doubler | 5    | Yes                       | No              |
| png2bas5_rle     | 5    | Yes                       | Yes             |
| png2bas6         | 6    | No                        | No              |
| png2bas6_rle     | 6    | No                        | Yes             |

If using Mode 5 format, PAGE number must be set to 3 in the PC-6001.

The doubler creates 2 horizontal lines per bitmap horizontal line, it's meant for mode 5 screen 3 to un-squish bitmaps due to screen 3's horizontal pixel doubling thing (Pretends to be 320x200 but actually running at 160x200).

Limitations:

- Size of PNG is the biggest problem, anything above 200 pixels wide and/or 140 pixels high won't work as the memory is not enough for the BASIC program to be loaded.
- 24-bit and 32-bit PNGs are supported, indexed PNGs are not.
