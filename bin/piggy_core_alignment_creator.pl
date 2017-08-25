#!/usr/bin/env perl
use warnings;
use strict;

my $out_dir=$ARGV[0];

print STDOUT "Creating core IGR alignment.\n";
print STDERR "Creating core IGR alignment.\n";

open OUTPUT, ">$out_dir/core_IGR_alignment.fasta" or die "Cannot open output file: $out_dir/core_IGR_alignment.fasta\n";

mkdir "$out_dir/isolate_core_IGR_tmp";

my @isolate_array=();

open INPUT, "$out_dir/isolates.txt" or die "Input file doesn't exist: $out_dir/isolates.txt\n";
while(my $line=<INPUT>){
	chomp $line;
	
	push @isolate_array, $line;
	
	open OUTPUT_TMP, ">$out_dir/isolate_core_IGR_tmp/$line.fasta" or die "Cannot open output file: $out_dir/isolate_core_IGR_tmp/$line.fasta\n";
	print OUTPUT_TMP ">$line\n";
}
close INPUT;
close OUTPUT_TMP;

my $isolate_count=scalar(@isolate_array);
my $isolate_core_count=int($isolate_count * 0.95);
my @cluster_array=();

open INPUT_I, "$out_dir/IGR_presence_absence.csv" or die "Input file doesn't exist: $out_dir/IGR_presence_absence.csv\n";
while(my $line=<INPUT_I>){
	$line=~s/\r$//;
	$line=~s/\n$//;
	$line=~s/\r\n$//;
	$line=~s/^"//;
	$line=~s/"$//;
	my @line_array=split(/","/, $line);
	
	if($line !~ /^Gene","/){
		if($line_array[3] >= $isolate_core_count && $line_array[5] == 1){
			push @cluster_array, $line_array[0];
		}
	}
}
close INPUT_I;

foreach my $cluster(@cluster_array){
	
	my %cluster_seq_hash=();
	my $len=0;
	
	my $cluster_id="";
	my @cluster_id_array=();
	my $isolate="";
	
	open INPUT, "$out_dir/cluster_intergenic_alignment_files/${cluster}_aligned.fasta" or die "Input file doesn't exist: $out_dir/cluster_intergenic_alignment_files/${cluster}_aligned.fasta\n";
	while(my $line=<INPUT>){
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
		open OUTPUT_TMP, ">>$out_dir/isolate_core_IGR_tmp/$isolate.fasta" or die "Cannot open output file: $out_dir/isolate_core_IGR_tmp/$isolate.fasta\n";
		if(!$cluster_seq_hash{$isolate}){
			for(my $i=0; $i<$len; $i++){
				print OUTPUT_TMP "-";
			}
		}else{
			print OUTPUT_TMP "$cluster_seq_hash{$isolate}";
		}
	}
}
close OUTPUT_TMP;

foreach my $isolate(@isolate_array){
	open OUTPUT_TMP, ">>$out_dir/isolate_core_IGR_tmp/$isolate.fasta" or die "Cannot open output file: $out_dir/isolate_core_IGR_tmp/$isolate.fasta\n";
	print OUTPUT_TMP "\n";
}
close OUTPUT_TMP;

foreach my $isolate(@isolate_array){
	open INPUT, "$out_dir/isolate_core_IGR_tmp/$isolate.fasta" or die "Input file doesn't exist: $out_dir/isolate_core_IGR_tmp/$isolate.fasta\n";
	while(my $line=<INPUT>){
		chomp $line;
		
		print OUTPUT "$line\n";
	}
}
close INPUT;
close OUTPUT;

print STDOUT "core IGR alignment created.\n";
print STDERR "core IGR alignment created.\n";

