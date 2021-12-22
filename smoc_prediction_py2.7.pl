
#please select the correct python file.

#the python version is 2.7
$run_command="python smoc_prediction_py2.7.py";

#the python version is 3.x
#$run_command="python smoc_prediction_py3.5.py";

$#ARGV;
$infile="";
$outfile="";
$tarclass="";
for ($i=0;$i<=$#ARGV;$i=$i+2) {
	$ARGV[$i]=uc($ARGV[$i]);
	if ($ARGV[$i] eq "-I") {
		$infile=$ARGV[$i+1];
		chomp($infile);
	}
	if ($ARGV[$i] eq "-O") {
		$outfile=$ARGV[$i+1];
		chomp($outfile);
	}
	if ($ARGV[$i] eq "-T") {
		$tarclass=$ARGV[$i+1];
		chomp($tarclass);
	}
}

if ($infile eq "") {
	print "Please input the sequence file in fasta format!\n\n\n";
	exit;
}
if ($tarclass  ne "NIPCK" and $tarclass ne "NIPHS" and $tarclass ne "9311CK" and $tarclass ne "9311HS") {
	print "Please input the correct modification type (5mC, 6mA, m6A, H3K27me3, H3K4me3 or H3K9ac)!\n\n\n";
	exit;
}

$outfile_coding=$infile.".coding.onehot";
$outfile_temp=$infile.".temp.remove_check";

if(-e $infile){
	$flag=1;
	open(out,">$outfile_temp");
	open(ins,"$infile");
	while(defined($seq=<ins>)){
		chomp($seq);
		if($seq =~/^>/){
			if($flag ==1){
				print out $seq,"\n";
			}else{
				print out "\n",$seq,"\n";
			}
			$flag=0;		
		}else{
			print out $seq;
		}
	}
	close(ins);
	close(out);
}else{
	print "The input file ".$infile." does not existed. Please input the correct file name.\n";
}

my @all_frg_name=();
my @all_frg_seqs=();
$all_frg_num=0;

open(out,">$outfile_coding");
open(in,$outfile_temp);
while(defined($line=<in>)){
	chomp($line);
	$line =~ s/\r//g;
	if($line=~/^>/){
		chomp($line);
		$line=~/^>(\S+)/;
		$seq_id=$1;

		#print out $seq_flag,",";
		$tar_seq=<in>;
		$seq_len=length($tar_seq);
		
		for($i=0;$i<($seq_len-41);$i=$i+1){

			$test_seq_flag=0;

			if($tarclass eq "NIPCK" or $tarclass eq "NIPHS" or $tarclass eq "9311CK" or $tarclass eq "9311HS"){
				$tar_in_seq=substr($tar_seq,$i,147);
				$tar_in_seq_len=length($tar_in_seq);
				if($tar_in_seq_len >100){
					$test_seq_flag=1;
				}
			}
			if($test_seq_flag==0){
				next;
			}

			$all_frg_name[$all_frg_num]=$seq_id." ".($i+1);
			$all_frg_seqs[$all_frg_num]=$tar_in_seq;

			$all_frg_num=$all_frg_num+1;

			$tar_in_seq_len=length($tar_in_seq);

			print out "0,";
			for($j=0;$j<$tar_in_seq_len;$j=$j+1){

				$tar_nuc=substr($tar_in_seq,$j,1);
				if($tar_nuc eq "A"){
					print out "1 ";
					next;
				}
				if($tar_nuc eq "T"){
					print out "2 ";
					next;
				}
				if($tar_nuc eq "C"){
					print out "3 ";
					next;
				}
				if($tar_nuc eq "G"){
					print out "4 ";
					next;
				}
				print out "4 ";
			}
			print out ",\n";
		}
		
	}
}
close(in);
close(out);

if($all_frg_num==0){
	print "Pleae input the correct sequences.";
	exit;
}
#system("rm $outfile_temp");

if ($tarclass eq "m6A" ) {
	$tar_model_name="Best_model_NIPCK.h5";
	$run_command=$run_command." ".$outfile_coding." Best_model_NIPCK.h5 147";
}

if ($tarclass eq "H3K27me3") {
	$tar_model_name="Best_model_NIPHS.h5";
	$run_command=$run_command." ".$outfile_coding." Best_model_NIPHS.h5 147";
}

if ($tarclass eq "H3K4me3") {
	$tar_model_name="Best_model_9311CK.h5";
	$run_command=$run_command." ".$outfile_coding." Best_model_9311CK.h5 147";
}

if ($tarclass eq "H3K9ac") {
	$tar_model_name="Best_model_9311HS.h5";
	$run_command=$run_command." ".$outfile_coding." Best_model_9311HS.h5 147";
}

system($run_command);

$pres_file="./pres/Pres.".$outfile_coding ."_model_".$tar_model_name;
print $pres_file,"*\n";

open(out,">$outfile");
open(in,$pres_file);
$tar_line_id=0;
print out "NO\tSeq_id\tSite_location\tModification\Probability\tSequence\n";
while (defined($line=<in>)) {
	chomp($line);
	
	@nr=split(/\s+/,$line);

	print out $tar_line_id+1,"\t",$all_frg_name[$tar_line_id],"\t",$nr[2],"\t";

	if($nr[2] >=1){
		printf out " %.4f\t", $nr[1] ;
	}else{
		printf out " %.4f\t", 1-$nr[1] ;
	}
	print out $all_frg_seqs[$tar_line_id],"\n";
	$tar_line_id=$tar_line_id+1;
}
close(in);
close(out);

