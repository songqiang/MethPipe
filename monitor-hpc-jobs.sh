# collection of functions related to monitor mapping jobs on hpc
# Song Qiang <keeyang@ustc.edu>

### validate if a particular job is successfully finished
# usage:
# validate_job read_file 0 1000000 # for single end
# validate_job read_file1 read_file1 0 1000000 # for pair end
function validate_job # readfile, start, number
{
    if [ "$#" == "3" ];
    then
        readfile=$(readlink -f $1);
        start=$2;
        number=$3;
        d=$(dirname $readfile);
        id=$(basename $readfile .fastq);
        mrFile=$d/$id-$start-$number.mr;
        logFile=$d/log/$id-$start-$number.log;
        [ -f "$mrFile" ] \
            && test `find $mrFile -mmin +10` \
            && [ -f "$logFile" ] \
            && grep -q "TOTAL READS MAPPED" $logFile;
    else
        readfile1=$(readlink -f $1);
        readfile2=$(readlink -f $2);
        start=$3;
        number=$4;
        d=$(dirname $readfile1);
        id=$(basename $readfile1 _1.fastq);
        mrFile=$d/$id-$start-$number.mr;
        logFile=$d/log/$id-$start-$number.log;
        [ -f "$mrFile" ] \
            && test `find $mrFile -mmin +10` \
            && [ -f "$logFile" ] \
            && [ $(grep "MAPPED:" $logFile|wc -l) -eq 2 ];
    fi
}  

function clean_finished_single_end_jobs # workdir number
{
    workdir=$1;
    cd $workdir;
    lc=~qiangson/app/methpipe/bin/lc_approx;
    number=1000000;
	if [ "$#" -eq 2 ];
	then
		number=$2;
	fi
    finished=0;
    todo=0;
    for f in $(find -L $PWD -name "*.fastq");
    do
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc);
        failedjobs=0;
        for start in $(seq 0 $number $total);
        do
            validate_job $f $start $number;
            if [ "$?" -ne 0 ];
            then
                failedjobs=$(echo $failedjobs + 1|bc);
                break;
            fi
        done
        
        if [ $failedjobs -eq 0 ];
        then
            rm -f $f;
            finished=$(echo $finished + 1|bc);
        else
            todo=$(echo $todo + 1|bc);
        fi
    done
    
    date;
    echo Finished=$finished, TODO=$todo; 
}

function report_unfinished_single_end_jobs # workdir number
{
    workdir=$1;
    cd $workdir;
    lc=~qiangson/app/methpipe/bin/lc_approx;
	number=1000000;
	if [ "$#" -eq 2 ];
	then
		number=$2;
	fi
    finished=0;
    todo=0;
    for f in $(find -L $PWD -name "*.fastq");
    do
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc);
        failedjobs=0;
        for start in $(seq 0 $number $total);
        do
            validate_job $f $start $number;
            if [ "$?" -ne 0 ];
            then
				echo $f $start $number;
            fi
        done
    done
}

function clean_finished_paired_end_jobs # workdir
{
    workdir=$1;
    cd $workdir;
    lc=~qiangson/app/methpipe/bin/lc_approx;
    number=1000000;
	if [ "$#" -eq 2 ];
	then
		number=$2;
	fi
    finished=0;
    todo=0;
    for f in $(find $PWD -name "*_1.fastq");
    do
        readTrichFile=$f;
        readArichFile=${f/_1.fastq/_2.fastq};
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc);
        failedjobs=0;
        for start in $(seq 0 $number $total);
        do
            validate_job $readTrichFile $readArichFile $start $number;
            if [ "$?" -ne 0 ];
            then
                failedjobs=$(echo $failedjobs + 1|bc);
                break;
            fi
        done
        
        if [ $failedjobs -eq 0 ];
        then
            rm -f $readTrichFile $readArichFile;
            finished=$(echo $finished + 1|bc);
        else
            todo=$(echo $todo + 1|bc);
        fi
    done
    
    date;
    echo Finished=$finished, TODO=$todo; 
}


function report_unfinished_paired_end_jobs # workdir number
{
    workdir=$1;
    cd $workdir;
    lc=~qiangson/app/methpipe/bin/lc_approx;
    number=1000000;
	if [ "$#" -eq 2 ];
	then
		number=$2;
	fi
    finished=0;
    todo=0;
    for f in $(find $PWD -name "*_1.fastq");
    do
        readTrichFile=$f;
        readArichFile=${f/_1.fastq/_2.fastq};
        total=$(echo $($lc -n 10 -z 1000000 $f|cut -f2)/4|bc);
        failedjobs=0;
        for start in $(seq 0 $number $total);
        do
            validate_job $readTrichFile $readArichFile $start $number;
            if [ "$?" -ne 0 ];
            then
				echo $readTrichFile $readArichFile $start $number;
            fi
        done
    done
}

