fromFile=Mouse_ESC.meth
indexFile=CpGs-mm9Tohg19.bed
toFile=Mouse_ESC-hg19.meth
 
$fastLiftOver -f $fromFile -i $indexFile -t $toFile -v
 
# sort output and merge sites mapped to the same location
export LC_ALL=C;
tmpfile=$(mktemp);
wc -l $toFile
sort -k1,1 -k2,2n $toFile \
|awk '
NR == 1 {chr = $1; pos = $2; strand = $3; seq = $4; t = $6; m = $5 * $6;}
NR > 1 {
if ($1 == chr && $2 == pos && $3 == strand && $4 == seq)
{
t += $6; m += $5 * $6;
}
else
{
if (t == 0) meth = 0.0; else meth = m / t;
print chr,pos,strand,seq,meth,t;
chr = $1; pos = $2; strand = $3; seq = $4; t = $6; m = $5 * $6;
}
}
END {
if (t == 0) meth = 0.0; else meth = m / t;
print chr,pos,strand,seq,meth,t;
}' > $tmpfile;
mv $tmpfile $toFile;
wc -l $toFile;

