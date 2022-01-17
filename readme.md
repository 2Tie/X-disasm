# X/Lunar Chase/Eclipse Disassembly
To assemble: invoke `make` in the base directory. Needs rgbds.  
`make bare` will build the rom without anything unused.
getslack prints the amount of bytes not assembled in each bank (taken from build/map.sym).  
tools/XGFXRLE is a tool to compress 2bpp graphics planally via RLE, to the specifications used by the game. `-i [input filename]` and `-o [output filename]` are required, there is also an optional `-t [run threshold]` switch (defaults to 2, which is the hardcoded value used by the game). Its source is also supplied and is part of the build process.  

Models are in banks 1 and B  
The majority of japanese text is in bank 5  


## TODO:
Finish disassembling the unreferenced stuff in the banks (home bank done so far)  
Finish turning the pointers used in the tutorial scripting into labels, and other raw pointers (rgbds has an option to shuffle banks that should help with this?)  
Another pass over the whole thing, tidying WRAM addresses and such (farcall macro?)  
Figure out the math to generate the last tables in Bank 1  
Incorporating the Lunar Chase english differences  
Possibly use this as a starting point for disassembling the proto?  