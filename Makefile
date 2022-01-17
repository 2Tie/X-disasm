.PHONY: slack
.PHONY: bare

gfx2bpp := $(wildcard gfx/2bpp/*.png)
gfx1bpp := $(wildcard gfx/1bpp/*.png)
gfxVert2bpp := $(wildcard gfx/2bpp/*VERT.png)
gfxVert1bpp := $(wildcard gfx/1bpp/*VERT.png)
#remove the vert gfx from the non-vert collections
gfx2bpp := $(filter-out $(gfxVert2bpp), $(gfx2bpp)) 
gfx1bpp := $(filter-out $(gfxVert1bpp), $(gfx1bpp))
#the RLE graphics
gfxRLE := $(wildcard gfx/rle/*.png)

#the graphics recipes
build/gfx/%.2bpp: gfx/2bpp/%VERT.png
	rgbgfx -h -o $@ $<
	
build/gfx/%.2bpp: gfx/2bpp/%.png
	rgbgfx -o $@ $<
	
build/gfx/%.1bpp: gfx/1bpp/%VERT.png
	rgbgfx -h -d 1 -o $@ $<
	
build/gfx/%.1bpp: gfx/1bpp/%.png
	rgbgfx -d 1 -o $@ $<
	
build/gfx/%.rle: gfx/rle/%.png tools/XGFXRLE
	rgbgfx -o build/gfx/$*.2bpp $<
	./tools/XGFXRLE -i build/gfx/$*.2bpp -o $@

#main recipe
main: X.gb
	rgbasm -E -h -o build/X.o -D UNUSED src/X.asm
	rgblink -d -m build/map.sym -O baserom.gb -o build/X.gb build/X.o
	rgbfix -v -m 0x6 -t "X" -l 1 build/X.gb
	md5sum -c hash.md5
	
X.gb: $(gfxVert2bpp:gfx/2bpp/%VERT.png=build/gfx/%.2bpp) $(gfx2bpp:gfx/2bpp/%.png=build/gfx/%.2bpp) $(gfxVert1bpp:gfx/1bpp/%VERT.png=build/gfx/%.1bpp) $(gfx1bpp:gfx/1bpp/%.png=build/gfx/%.1bpp) $(gfxRLE:gfx/rle/%.png=build/gfx/%.rle)


#graphics tools
tools/XGFXRLE: tools/xGfxRLE.cpp
	g++ tools/xGfxRLE.cpp -o tools/XGFXRLE

#builds + prints slack
slack: X.gb
	bash getslack.sh
	
#builds without the overlay
bare: X.gb
	rgbasm -E -h -o build/X.o -D UNUSED=0 src/X.asm
	rgblink -d -m build/map.sym -o build/X_bare.gb build/X.o
	rgbfix -v -m 0x6 -t "X" -l 1 -p 0 build/X_bare.gb