z88dk ZCC PC-6002 Compiler Front-end
=====================================

This is a Tkinter Python-based UI front-end for z88dk ZCC compiler for PC-60 platform.

COMPILE60 requires the following to work:

1. Python 2.7 installed and configured
2. Create environment variable "ZCCCFG" and set its value to this config path in z88dk: "z88dk/lib/config"
3. Add path to z88dk binary folder in your PATH environment variable: "z88dk/bin"

If everything is there, just double click `compile60.py` to start the front-end.

![compile60 window](http://zenithsal.com/assets/photos/pc6002/compile60_scrnshot_window.png)

COMPILE60 will also generate a `.vscode` folder and tasks.json configuration file to build C code from within vscode. Use shortcut `Ctrl+Shift+B` and select the BASIC mode you would like to use to build the current open C file (this method cannot build multiple C files together, use the front-end for that).

COMPILE60 will try to provide useful information in case of failure.

The output of COMPILE60 build process:

1. A .bin file with the compiled z80 hexadecimal code
2. A .cas file ready to be loaded in the PC-6001 emulator tape drive

To load and run a compiled program using a PC-6001 emulator:

- Insert Tape file (.cas) in emulator
- Go to correct BASIC mode and page (by default: Mode 5, Page 3)
- Type: `cload`
- Once initial code is loaded, type: `run` to start loading the actual program then executing it

Support for outputing binaries directly to a virtual floppy disk is planned. 
