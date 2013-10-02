#PBS -S /bin/sh
#PBS -q cmb
#PBS -l mem=20000M
#PBS -l pmem=20000M
#PBS -l vmem=20000M
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00

## required argument passed from commandline
# resultsDir

set -o errexit
set -o nounset
set -o pipefail

function logrun # logfile command
{
    if [ "$#" -ge 2 ];
    then
        echo ">>> " "${@:2}"|tee -a "$1";      
        (${@:2}) 2>&1|tee -a "$1";      
    else
        echo "logrun: logfile command [options]" 1>&2 && false;
    fi
}

export Genome_Dir=~qiangson/panfs/data/human/hg19/sequences
export rmapbs=~qiangson/app/rmap/bin/rmapbs
export methcounts=~qiangson/app/methpipe/trunk/bin/methcounts
export duplicateremover=~qiangson/app/methpipe/trunk/bin/duplicate-remover
export hypermr=~qiangson/app/methpipe/trunk/bin/hmr_plant
export bsrate=~qiangson/app/methpipe/trunk/bin/bsrate
export LC_ALL=C

cd $resultsDir
id=$(basename $(dirname $PWD))

methFile=$id.meth
allmethFile=$id.all.meth
methstatsFile=$id.methstats
allmethstatsFile=$id.all.methstats
bsrateFile=$id.bsrate
dupstatsFile=$id.dupstats
hypermrFile=$id.hypermr
allhypermrFile=$id.all.hypermr

mkdir -p log
logfile=log/$id.log

date > $logfile
echo ------------------------------- >> $logfile

mrFile=$id.mr
mrUniqFile=$id.uniq.mr

sort -k1,1 -k2,2n -k3,3n -k6,6 *000000.mr -o $mrFile && rm -f *000000.mr

# remove duplicate
logrun $logfile $duplicateremover -stats  $dupstatsFile -verbose -o $mrUniqFile $mrFile
bzip2 -f $mrFile

# methcounts 
logrun $logfile $methcounts -o $methFile -S $methstatsFile -chrom $Genome_Dir -v $mrUniqFile

# bsrate 
logrun $logfile $bsrate -o $bsrateFile -v -c $Genome_Dir $mrUniqFile 
rm -f $mrUniqFile

echo ------------------------------- >> $logfile
date >> $logfile

