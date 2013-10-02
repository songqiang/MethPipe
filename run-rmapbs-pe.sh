#PBS -S /bin/bash
#PBS -q cmb
#PBS -l mem=2500M
#PBS -l pmem=2500M
#PBS -l vmem=2500M
#PBS -l nodes=1:ppn=1
#PBS -l walltime=108:00:00

# input readTrichFile readArichFile
# start
# number

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
export rmapbspe=~qiangson/app/rmap/bin/rmapbs-pe
export adapter=AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
export AdapterTrich=AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
export AdapterArich=CAAGCAGAAGACGGCATACGAGCTCTTCCGATCT
export LC_ALL=C

mrFile=${readTrichFile/_1.fastq/}-$start-$number.mr
logDir=$(readlink -f $readTrichFile|xargs dirname)/log
mkdir -p $logDir
logFile=$(basename $readTrichFile _1.fastq)-$start-$number.log
logFile=$logDir/$logFile

date > $logFile

logrun $logFile ${rmapbspe}  -mismatch 8  -start $start -number $number \
    -chrom ${Genome_Dir} -clip $AdapterTrich:$AdapterArich \
    -o $mrFile -verbose $readTrichFile $readArichFile

sort -T $PWD -k1,1 -k2,2n -k3,3n -k6,6 $mrFile -o $mrFile.tmp && mv $mrFile.tmp $mrFile

date >> $logFile





  
