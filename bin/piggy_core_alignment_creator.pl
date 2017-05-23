#!/usr/bin/env perl
use warnings;

$out_dir=$ARGV[0];

open OUTPUT, ">$out_dir/core_IGR_alignment.fasta";

mkdir "$out_dir/isolate_core_IGR_tmp";

open INPUT, "$out_dir/isolates.txt";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	push @isolate_array, $line;
	
	open OUTPUT_TMP, ">$out_dir/isolate_core_IGR_tmp/$line.fasta";
	print OUTPUT_TMP ">$line\n";
}
close INPUT;
close OUTPUT_TMP;

$isolate_count=scalar(@isolate_array);
$isolate_core_count=int($isolate_count * 0.99);

open INPUT_I, "$out_dir/IGR_presence_absence.csv";
while(<INPUT_I>){
	$line=$_;
	$line=~s/\R//g;
	$line=~s/^"//;
	$line=~s/"$//;
	@line_array=split(/","/, $line);
	
	if($line !~ /^Gene","/){
		if($line_array[3] >= $isolate_core_count && $line_array[5] == 1){
			push @cluster_array, $line_array[0];
		}
	}
}
close INPUT_I;

foreach $cluster(@cluster_array){
	
	%cluster_seq_hash=();
	$len=0;
	open INPUT, "$out_dir/cluster_intergenic_alignment_files/${cluster}_aligned.fasta";
	while(<INPUT>){
		$line=$_;
		chomp $line;

		if($line =~ /^>(.+)/){
			$cluster_id=$1;
			@cluster_id_array=split(/_\+_\+_/, $cluster_id);
			$isolate=$cluster_id_array[0];
		}else{
			$cluster_seq_hash{$isolate}=$line;
			
			$len=length($line);
		}
	}
	close INPUT;
	
	foreach $isolate(@isolate_array){
		open OUTPUT_TMP, ">>$out_dir/isolate_core_IGR_tmp/$isolate.fasta";
		if(!$cluster_seq_hash{$isolate}){
			for($i=0; $i<$len; $i++){
				print OUTPUT_TMP "-";
			}
		}else{
			print OUTPUT_TMP "$cluster_seq_hash{$isolate}";
		}
	}
}
close OUTPUT_TMP;

foreach $isolate(@isolate_array){
	open OUTPUT_TMP, ">>$out_dir/isolate_core_IGR_tmp/$isolate.fasta";
	print OUTPUT_TMP "\n";
}
close OUTPUT_TMP;

foreach $isolate(@isolate_array){
	open INPUT, "$out_dir/isolate_core_IGR_tmp/$isolate.fasta";
	while(<INPUT>){
		$line=$_;
		chomp $line;
		
		print OUTPUT "$line\n";
	}
}
close INPUT;
close OUTPUT;

