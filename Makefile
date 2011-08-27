WORK_DIR=.

INPUT=data0
INPUT_DIR=../../data/$(INPUT)

RAWFITS=$(INPUT_DIR)/2mass-atlas-*.fits
REGION=$(INPUT_DIR)/region.hdr

TILE_PIXEL=1000
SHRINK_FACTOR=10

target=shrunk.jpg

all: $(target)

pimages.tbl: $(RAWFITS) $(REGION)
	-mkdir -p p
	$(MAKE) -k -f mk_proj INPUT_DIR=$(INPUT_DIR) all

diffs.tbl: pimages.tbl
	mOverlaps $< $@

mk_diff: diffs.tbl
	awk -f mk_diff.awk -v INPUT_DIR=$(INPUT_DIR) $< > $@

fits.tbl: mk_diff
	-mkdir -p d
	$(MAKE) -f $< INPUT_DIR=$(INPUT_DIR) all

corrections.tbl : fits.tbl pimages.tbl
	mBgModel pimages.tbl $< $@

cimages.tbl: corrections.tbl pimages.tbl
	-mkdir -p c
	$(MAKE) -f mk_corr INPUT_DIR=$(INPUT_DIR) all

mosaic.fits: cimages.tbl $(REGION)
	mAdd -p c $< $(REGION) $@

mosaic.jpg: mosaic.fits
	mJPEG  -ct 0 -gray $< -1.5s 60s gaussian -out $@

t/tile_0_0.hdr: cimages.tbl $(REGION)
	-mkdir -p t
	sh tile_region.sh $(REGION) $(TILE_PIXEL)

simages.tbl: t/tile_0_0.hdr cimages.tbl $(REGION)
	$(MAKE) -f mk_tile INPUT_DIR=$(INPUT_DIR) SHRINK_FACTOR=$(SHRINK_FACTOR) all

shrunk.fits: simages.tbl $(INPUT_DIR)/shrunken.hdr
	mAdd -n -e -p s simages.tbl $(INPUT_DIR)/shrunken.hdr shrunk.fits

shrunk.jpg: shrunk.fits
	mJPEG  -ct 0 -gray $< -1.5s 60s gaussian -out $@

clean:
	rm -rf s
	rm -rf t
	rm -rf c
	rm -rf d
	rm -rf p
	rm -f  simages.tbl cimages.tbl pimages.tbl diffs.tbl
	rm -f mk_diff
	rm -f corrections.tbl fits.tbl fittxt.tbl

cleanall: clean
	rm -f mosaic.fits mosaic_area.fits mosaic.jpg
	rm -f shrunk.fits shrunk_area.fits shrunk.jpg
