# merge technical/biological replicates
# Song Qiang <keeyang@ustc.edu>

function merge_technical_rep #dir assembly
{
    OWD=$PWD
    dir=$1
    assembly=$2
    id=$(basename $dir)   

    cd  $dir
    mkdir -p results_${assembly}   
    cd results_${assembly}  

    nrep=$(ls .. -1|grep "${id}_L[0-9]"|wc -l)
    if [ $nrep -eq 1 ];
    then 
        repid=${id}_L1;
        repdir=../$repid/results_${assembly};
        [ ! -f $id.meth ] && [ -f  $repdir/$repid.meth ] && ln -s $repdir/$repid.meth $id.meth;
        [ ! -f $id.methstats ] && [ -f  $repdir/$repid.methstats ] && ln -s $repdir/$repid.methstats $id.methstats;
        [ ! -f $id.all.meth ] && [ -f  $repdir/$repid.all.meth ] && ln -s $repdir/$repid.all.meth $id.all.meth;
        [ ! -f $id.all.methstats ] && [ -f  $repdir/$repid.all.methstats ] && ln -s $repdir/$repid.all.methstats $id.all.methstats;
        [ ! -f $id.bsrate ] && [ -f  $repdir/$repid.bsrate ] && ln -s $repdir/$repid.bsrate $id.bsrate;
        [ ! -f $id.hmr ] && [ -f  $repdir/$repid.hmr ] && ln -s $repdir/$repid.hmr $id.hmr;
        [ ! -f $id.hypermr ] && [ -f  $repdir/$repid.hypermr ] && ln -s $repdir/$repid.hypermr $id.hypermr;
        [ ! -f $id.amr ] && [ -f  $repdir/$repid.amr ] && ln -s $repdir/$repid.amr $id.amr;
        [ ! -f $id.pmd ] && [ -f  $repdir/$repid.pmd ] && ln -s $repdir/$repid.pmd $id.pmd;
        [ ! -f $id.pmr ] && [ -f  $repdir/$repid.pmr ] && ln -s $repdir/$repid.pmr $id.pmr;
        [ ! -f $id.allelic ] && [ -f  $repdir/$repid.allelic ] && ln -s $repdir/$repid.allelic $id.allelic;
    fi

    if [ $nrep -gt 1 ];
    then 
        mergemeth=~qiangson/app/methpipe/bin/merge-methcounts
        mergebsrate=~qiangson/app/methpipe/bin/merge-bsrate
		
        methfs=$(find ../${id}_L[0-9]* -maxdepth 2 -name "*.meth" -a ! -name "*all.meth")
        [ ! -f $id.meth ] && [ ! -z "$methfs" ] && $mergemeth $methfs -o $id.meth  -S $id.methstats -v

        allmethfs=$(find ../${id}_L[0-9]* -maxdepth 2 -name "*.all.meth")
        [ ! -f $id.all.meth ] && [ ! -z "$allmethfs" ] && $mergemeth $allmethfs -o $id.all.meth  -S $id.all.methstats -v

        bsratefs=$(find ../${id}_L[0-9]* -maxdepth 2 -name "*.bsrate")
        [ ! -f $id.bsrate ] && [ ! -z "$bsratefs" ] && $mergebsrate $bsratefs -o $id.bsrate -v
    fi
    
    cd $OWD
}


function merge_biological_rep #dir assembly
{
    OWD=$PWD
    dir=$1
    assembly=$2
    id=$(basename $dir)   

    cd  $dir
    mkdir -p results_${assembly}   
    cd results_${assembly}  

    nrep=$(ls .. -1|grep "${id}_R[0-9]"|wc -l)
    if [ $nrep -eq 1 ];
    then 
        repid=${id}_R1      
        repdir=../$repid/results_${assembly};
        [ ! -f $id.meth ] && [ -f  $repdir/$repid.meth ] && ln -s $repdir/$repid.meth $id.meth;
        [ ! -f $id.methstats ] && [ -f  $repdir/$repid.methstats ] && ln -s $repdir/$repid.methstats $id.methstats;
        [ ! -f $id.all.meth ] && [ -f  $repdir/$repid.all.meth ] && ln -s $repdir/$repid.all.meth $id.all.meth;
        [ ! -f $id.all.methstats ] && [ -f  $repdir/$repid.all.methstats ] && ln -s $repdir/$repid.all.methstats $id.all.methstats;
        [ ! -f $id.bsrate ] && [ -f  $repdir/$repid.bsrate ] && ln -s $repdir/$repid.bsrate $id.bsrate;
        [ ! -f $id.hmr ] && [ -f  $repdir/$repid.hmr ] && ln -s $repdir/$repid.hmr $id.hmr;
        [ ! -f $id.hypermr ] && [ -f  $repdir/$repid.hypermr ] && ln -s $repdir/$repid.hypermr $id.hypermr;
        [ ! -f $id.amr ] && [ -f  $repdir/$repid.amr ] && ln -s $repdir/$repid.amr $id.amr;
        [ ! -f $id.pmd ] && [ -f  $repdir/$repid.pmd ] && ln -s $repdir/$repid.pmd $id.pmd;
        [ ! -f $id.pmr ] && [ -f  $repdir/$repid.pmr ] && ln -s $repdir/$repid.pmr $id.pmr;
        [ ! -f $id.allelic ] && [ -f  $repdir/$repid.allelic ] && ln -s $repdir/$repid.allelic $id.allelic;
    fi

    if [ $nrep -gt 1 ];
    then 
        mergemeth=~qiangson/app/methpipe/bin/merge-methcounts
        mergebsrate=~qiangson/app/methpipe/bin/merge-bsrate
		
        methfs=$(find ../${id}_R[0-9]* -maxdepth 2 -name "*.meth" -a ! -name "*all.meth")
        [ ! -f $id.meth ] && [ ! -z "$methfs" ] && $mergemeth $methfs -o $id.meth  -S $id.methstats -v

        allmethfs=$(find ../${id}_R[0-9]* -maxdepth 2 -name "*.all.meth")
        [ ! -f $id.all.meth ] && [ ! -z "$allmethfs" ] && $mergemeth $allmethfs -o $id.all.meth  -S $id.all.methstats -v

        bsratefs=$(find ../${id}_R[0-9]* -maxdepth 2 -name "*.bsrate")
        [ ! -f $id.bsrate ] && [ ! -z "$bsratefs" ] && $mergebsrate $bsratefs -o $id.bsrate -v
    fi
    cd $OWD
}

