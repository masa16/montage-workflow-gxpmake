hdrfile=$1
npix=$2

eval `sed '/NAXIS[12]/ s/ //g p; d' $hdrfile`

nx=$(($NAXIS1/$npix))
ny=$(($NAXIS2/$npix))

echo NX=$nx, NY=$ny

if (($nx*$ny>1)); then
    for (( iy=0; iy<$ny; iy++ )) ; do
	for (( ix=0; ix<$nx; ix++ )) ; do
	    mTileHdr ${hdrfile} t/tile_${ix}_${iy}.hdr ${nx} ${ny} ${ix} ${iy} 50 50
	done
    done
    exit 0
else
    exit 1
fi
