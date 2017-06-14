#!/usr/bin/env perl
use warnings;
use strict;

my $in_file=$ARGV[0];
my $out_file=$ARGV[1];
my $out_dir=$ARGV[2];
my $cluster_file=$ARGV[3];
my $cluster_file_rep=$ARGV[4];
my $nuc_identity=$ARGV[5];
my $len_identity=$ARGV[6];

my $in_base="";

if($in_file =~ /^(\S+)\.tab/){
	$in_base=$1;
}

my $cluster_file_rep_base="";

if($cluster_file_rep =~ /^(\S+)\.fasta/){
	$cluster_file_rep_base=$1;
}

open OUTPUT, ">$out_file";

my @total_cluster_array=();

open INPUT, "$cluster_file";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /(\S+)/){
		push @total_cluster_array, $line;
	}
}
close INPUT;

my $cluster_1_pre="NA";
open OUTPUT_MOD, ">${in_base}_modified.tab";
open INPUT, "$in_file";
while(my $line=<INPUT>){
	chomp $line;
	my @line_array=split(/\t/, $line);
	
	my $cluster_1=$line_array[0];
	if($cluster_1_pre ne $cluster_1){
		print OUTPUT_MOD "CLUSTER_DELIMITER\n";
	}
	
	print OUTPUT_MOD "$line\n";
	
	$cluster_1_pre=$cluster_1;
}
print OUTPUT_MOD "CLUSTER_DELIMITER\n";
close INPUT;
close OUTPUT_MOD;

my %merged_hash=();
my %remove_cluster_hash=();

my $cluster_1="";
my $cluster_2="";
my $cluster_1_len=0;
my $cluster_2_len=0;
my $match_pcn=0;
my $match_sta=0;
my $match_end=0;

my %match_hash=();

open INPUT, "${in_base}_modified.tab";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^CLUSTER_DELIMITER/){
		if(%match_hash){
			my @match_cluster_array=keys(%match_hash);
			
			my @merge_cluster_array=();
			
			if(!$merged_hash{$cluster_1}){
				push @merge_cluster_array, $cluster_1;
				
				$merged_hash{$cluster_1}=1;
			}
			
			foreach my $cluster(@match_cluster_array){
				my @match_array=keys(%{$match_hash{$cluster}});
				my $match_len_total=scalar(@match_array);
				my $match_cluster_1_total=($match_len_total/$cluster_1_len);
				my $match_cluster_2_total=($match_len_total/$cluster_2_len);
		
				if($match_cluster_1_total >= $len_identity && $match_cluster_2_total >= 0.9){
					if(!$merged_hash{$cluster}){
						push @merge_cluster_array, $cluster;
						
						$merged_hash{$cluster}=1;
					}
				}
			}
			
			my $merge_cluster_count=scalar(@merge_cluster_array);
			
			if($merge_cluster_count > 1){
				print OUTPUT "$merge_cluster_array[0]";
				
				for(my $i=1; $i<$merge_cluster_count; $i++){
					print OUTPUT "\t$merge_cluster_array[$i]";
				}
				print OUTPUT "\n";
				
				open OUTPUT_MERGE, ">>$out_dir/$merge_cluster_array[0].fasta";
				
				for(my $i=1; $i<$merge_cluster_count; $i++){
					open INPUT_MERGE, "$out_dir/$merge_cluster_array[$i].fasta";
					while(my $line=<INPUT_MERGE>){
						chomp $line;
						
						print OUTPUT_MERGE "$line\n";
					}
					
					unlink "$out_dir/$merge_cluster_array[$i].fasta";
					
					$remove_cluster_hash{$merge_cluster_array[$i]}=1;
				}
				
				close OUTPUT_MERGE;
			}
			
			%match_hash=();
		}
	}else{
		my @line_array=split(/\t/, $line);
	
		$cluster_1=$line_array[0];
		$cluster_2=$line_array[1];
		$cluster_1_len=$line_array[2];
		$cluster_2_len=$line_array[3];
		$match_pcn=$line_array[4];
		$match_pcn=($match_pcn/100);
		#$match_len=$line_array[5];
		$match_sta=$line_array[10];
		$match_end=$line_array[11];
		
		if($cluster_1 =~ /^(Cluster_)(\d+)/){
			my $cluster_header=$1;my $cluster_1_no=$2;
			
			my $cluster_1="$cluster_header$cluster_1_no";
			
			if($cluster_2 =~ /^(Cluster_)(\d+)/){
				$cluster_header=$1;my $cluster_2_no=$2;
			
				my $cluster_2="$cluster_header$cluster_2_no";
				
				if($cluster_1 ne $cluster_2 && $match_pcn >= $nuc_identity && $cluster_1_no < $cluster_2_no){
					for(my $i=$match_sta; $i<=$match_end; $i++){
						$match_hash{$cluster_2}{$i}=1;
					}
				}
			}
		}
	}
}
close INPUT;

open OUTPUT_CLU, ">$cluster_file";

foreach my $cluster(@total_cluster_array){
	if(!$remove_cluster_hash{$cluster}){
		print OUTPUT_CLU "$cluster\n";
	}
}
close OUTPUT_CLU;

open OUTPUT_CLU_REP, ">${cluster_file_rep_base}_merged.fasta";

my $id="";
my @id_array=();
my $seq="";
my $cluster="";

open INPUT, $cluster_file_rep;
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^>(\S+)/){
		$id=$1;
		@id_array=split(/_\+_\+_/, $id);
		
		$cluster=$id_array[0];
	}elsif($line =~ /^([ATGCN]+)/){
		$seq=$1;
		
		if(!$remove_cluster_hash{$cluster}){
			print OUTPUT_CLU_REP ">$id\n$seq\n";
		}
	}
}
close INPUT;

