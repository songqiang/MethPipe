# collection of functions related to submit jobs to hpc
# Song Qiang <keeyang@ustc.edu>

function submit_single_end_read_jobs # workdir
{
    workdir=$1;
    cd $workdir;
    lc=~qiangson/app/methpipe/trunk/bin/lc_approx;
    logdir=$PWD/work/log;
    number=4000000;
    maxJobs=250;
    username=$(whoami);
    numJobs=$(qstat|grep $username|wc -l);
    for f in $(find -L $PWD  -name "*.fastq");
    do
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc)   
        for start in $(seq 0 $number $total);  
        do
            logfile=$(echo $f |sed 's|reads|reads/log/|; s/.fastq//;')-$start-$number.log;
            [ ! -f $logfile ] && echo qsub -o $logdir -e $logdir -v readfile="$f",start=$start,number=$number  $PWD/work/script/run-rmapbs.qsub && qsub -o $logdir -e $logdir -v readfile="$f",start=$start,number=$number  $PWD/work/script/run-rmapbs.qsub &&    sleep  5 && numJobs=$(echo $numJobs + 1 | bc);   
            
            if [ $numJobs -ge $maxJobs ];
            then       
                while [ "$(qstat|grep $username|wc -l)" -ge $maxJobs ]; 
                do
                    date && sleep 1h; 
                done
                numJobs=$(qstat|grep $username|wc -l);
            fi
        done
    done
} 


function submit_paired_end_read_jobs # workdir
{
    workdir=$1;
    cd $workdir;
    lc=~qiangson/app/methpipe/trunk/bin/lc_approx;
    logdir=$PWD/work/log;
    number=1000000;
    maxJobs=222;
    numJobs=$(qstat|grep qiangson|wc -l);
    for f in $(find -L $PWD  -name "*_1.fastq");
    do
        readTrichFile=$f
        readArichFile=${f/_1.fastq/_2.fastq}
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc)   
        for start in $(seq 0 $number $total)  
        do
            logfile=$(echo $readTrichFile |sed 's|reads|reads/log/|; s/_1.fastq//;')-$start-$number.log;
            [ ! -f $logfile ] && echo qsub -o $logdir -e $logdir -v readTrichFile="$readTrichFile",readArichFile="$readArichFile",start=$start,number=$number $PWD/work/script/run-rmapbs-pe.qsub && qsub -o $logdir -e $logdir -v readTrichFile="$readTrichFile",readArichFile="$readArichFile",start=$start,number=$number $PWD/work/script/run-rmapbs-pe.qsub && sleep 5 && numJobs=$(echo $numJobs + 1 | bc);   
            
            if [ $numJobs -ge $maxJobs ];
            then       
                while [ "$(qstat|grep qiangson|wc -l)" -ge $maxJobs ]; 
                do
                    date && sleep 1h; 
                done
                numJobs=$(qstat|grep qiangson|wc -l);
            fi
        done
    done
}
