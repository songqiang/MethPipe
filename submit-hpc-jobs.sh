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
            [ ! -f $logfile ] \
                && echo qsub -o $logdir -e $logdir \
                -v readfile="$f",start=$start,number=$number \
                $PWD/work/script/run-rmapbs.qsub \
                && qsub -o $logdir -e $logdir \
                -v readfile="$f",start=$start,number=$number \
                $PWD/work/script/run-rmapbs.qsub \
                && numJobs=$(echo $numJobs + 1 | bc) \
                && sleep  5;   
            
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
    username=$(whoami);
    maxJobs=222;
    numJobs=$(qstat|grep $username|wc -l);
    for f in $(find -L $PWD  -name "*_1.fastq");
    do
        readTrichFile=$f
        readArichFile=${f/_1.fastq/_2.fastq}
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc)   
        for start in $(seq 0 $number $total)  
        do
            logfile=$(echo $readTrichFile |sed 's|reads|reads/log/|; s/_1.fastq//;')-$start-$number.log;
            [ ! -f $logfile ] \
                && echo qsub -o $logdir -e $logdir \
                -v readTrichFile="$readTrichFile",readArichFile="$readArichFile",start=$start,number=$number \
                $PWD/work/script/run-rmapbs-pe.qsub \
                && qsub -o $logdir -e $logdir \
                -v readTrichFile="$readTrichFile",readArichFile="$readArichFile",start=$start,number=$number \
                $PWD/work/script/run-rmapbs-pe.qsub \
                && numJobs=$(echo $numJobs + 1 | bc) \
                && sleep 5 ;   
            
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

function submit_methpipe_jobs # workdir
{
    workdir=$1;
    cd $workdir;
    logdir=$PWD/work/log;
    maxJobs=25;
    username=$(whoami);
    numJobs=$(qstat|grep $username|wc -l);
    for sample_dir in $(find -L $PWD  -name "results_*[0-9]" -a -type d);
    do
		sample_id=$(basename $(dirname $sample_dir));
		logfile=$sample_dir/log/${sample_id}.log;
		[ ! -f $logfile ] \
			&& echo qsub -o $logdir -e $logdir \
            -v resultsDir="$sample_dir" \
			$PWD/work/script/run-methpipe.sh \
            && qsub -o $logdir -e $logdir \
            -v resultsDir="$sample_dir" \
			$PWD/work/script/run-methpipe.sh \
            && numJobs=$(echo $numJobs + 1 | bc) \
            && sleep  5;   
            
        if [ $numJobs -ge $maxJobs ];
        then       
            while [ "$(qstat|grep $username|wc -l)" -ge $maxJobs ]; 
            do
                date && sleep 2h; 
            done
            numJobs=$(qstat|grep $username|wc -l);
        fi
    done
} 



