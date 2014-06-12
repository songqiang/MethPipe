# run-fastLiftOver.sh: example code to map mouse mehtcount file to human 
# reference genome with the fastLiftOver tool.
#
# Copyright (C) 2014 University of Southern California and
# Song Qiang <keeyang@ustc.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


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

