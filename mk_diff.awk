BEGIN {
    print "| cntr1 | cntr2 |       stat          |" > "fittxt.tbl"
    print "|  int  |  int  |       char          |" > "fittxt.tbl"
    print "WORK_DIR=.\n"
    print "all : fits.tbl\n"
}
NR>2 {
    fit = $5
    sub(/diff/, "fit", fit)
    sub(/.fits$/, ".txt", fit)
    print "d/"fit" : p/"$3" p/"$4" "INPUT_DIR"/region.hdr"
    print "\t(cd $(WORK_DIR); mDiff p/"$3" p/"$4" d/"$5" "INPUT_DIR"/region.hdr && mFitplane -s d/"fit" d/"$5" || echo err )\n"
    list = list" d/"fit
    printf " %7d %7d %21s \n",$1,$2,fit > "fittxt.tbl"
}
END {
    print "fits.tbl : ",list
    print "\tmConcatFit  fittxt.tbl fits.tbl d"
}
