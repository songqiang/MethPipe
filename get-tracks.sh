# get bigwig and bigbed track files
# Song Qiang <keeyang@ustc.edu>

function get_track_file # source target tracksDir 
{
    source=$1
    target=$2
    tracksDir=$3
    assembly=$(basename $tracksDir|cut -f2 -d_)
    
    if [ -s $source ] && [ ! -e $tracksDir/$target ];
    then
        make -f ~qiangson/app/GenomeBrowserTool/Makefile.inc \
            -e assembly=$assembly $target
        mv $target $tracksDir/         
    fi
}


OWD=$PWD
for resDir in $(find -L $PWD -name "results_*[0-9]"|grep -v "_R[0-9]");
do
    echo $resDir
    cd $resDir   
    assembly=$(basename $PWD|cut -f2 -d_);
    tracksDir=../tracks_${assembly}
    mkdir -p $tracksDir

    for f in *.meth;
    do
        if grep -q ":" $f; # old format
        then
            tmpfile=$(mktemp)         
            cat $f |tr ":" "\t" \
                |awk '{print $1,$2,$7,$4,$6,$5}'|tr " " "\t" \
                >  $tmpfile
            mv $tmpfile $f
        fi

        target=${f/.meth/.meth.bw}
        get_track_file $f $target $tracksDir      
        
        target=${f/.meth/.read.bw}
        get_track_file $f $target $tracksDir      
    done
	
    for f in *.hmr;
    do
        target=${f/.hmr/.hmr.bb}
        get_track_file $f $target $tracksDir      
    done

    for f in *.allelic;
    do
        target=${f/.allelic/.allelic.bw}
        get_track_file $f $target $tracksDir      
    done

    for f in *.amr;
    do
        target=${f/.amr/.amr.bb}
        get_track_file $f $target $tracksDir      
    done

    for f in *.pmd;
    do
        target=${f/.pmd/.pmd.bb}
        get_track_file $f $target $tracksDir      
    done

    for f in *.hypermr;
    do
        target=${f/.hypermr/.hypermr.bb}
        get_track_file $f $target $tracksDir      
    done
done  
cd $OWD


