#!/usr/bin/env perl
use warnings;

$out_dir=$ARGV[0];

print STDOUT "Creating IGR cluster files.\n";
print STDERR "Creating IGR cluster files.\n";

open OUTPUT, ">$out_dir/clusters.txt";

open OUTPUT_REP, ">$out_dir/representative_clusters.fasta";

$count=0;
open INPUT, "$out_dir/IGR_sequences_clustered.fasta.clstr";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /^>(.+)/){
		$cluster=$1;
		$cluster=~s/ /_/g;
		
		print OUTPUT "$cluster\n";
		
		$count++;
		if($count % 1000 == 0){
			print STDOUT "$count representative IGR cluster files created.\n";
			print STDERR "$count representative IGR cluster files created.\n";
		}
		
	}elsif($line =~ /^\d+\s+\d+nt,\s+\>(\S+)\.\.\./){
		$cluster_id=$1;
		@cluster_id_array=split(/_\+_\+_/, $cluster_id);
		$isolate=$cluster_id_array[0];
		
		if($line =~ /\*$/){
			# Print representative sequences.
			open OUTPUT_CLU, ">$out_dir/cluster_intergenic_files/$cluster.fasta";
			
			open OUTPUT_CLU_REP, ">$out_dir/cluster_representative_files/$cluster.fasta";
		
			open INPUT_CLU, "$out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta";
			while(<INPUT_CLU>){
				$line=$_;
				chomp $line;
	
				if($line =~ /^>(.+)/){
	
				}else{
					print OUTPUT_REP ">${cluster}_+_+_$cluster_id\n$line\n";
					
					print OUTPUT_CLU_REP ">${cluster}_+_+_$cluster_id\n$line\n";
				
					print OUTPUT_CLU ">$cluster_id\n$line\n";
				}
			}
			
			close OUTPUT_CLU;
			close OUTPUT_CLU_REP;
		}
	}
}

close OUTPUT;
close OUTPUT_REP;

$count=0;
open INPUT, "$out_dir/IGR_sequences_clustered.fasta.clstr";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /^>(.+)/){
		$cluster=$1;
		$cluster=~s/ /_/g;
		
		$count++;
		if($count % 1000 == 0){
			print STDOUT "$count IGR cluster files created.\n";
			print STDERR "$count IGR cluster files created.\n";
		}
		
	}elsif($line =~ /^\d+\s+\d+nt,\s+\>(\S+)\.\.\./){
		$cluster_id=$1;
		@cluster_id_array=split(/_\+_\+_/, $cluster_id);
		$isolate=$cluster_id_array[0];
		
		if($line !~ /\*$/){
			# print to cluster file.
			open OUTPUT_CLU, ">>$out_dir/cluster_intergenic_files/$cluster.fasta";
		
			open INPUT_CLU, "$out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta";
			while(<INPUT_CLU>){
				$line=$_;
				
				print OUTPUT_CLU "$line";
				
#				chomp $line;
#			
#				if($line =~ /^>(.+)/){
#			
#				}else{
#					print OUTPUT_CLU ">$cluster_id\n$line\n";
#				}
			}
			
			close OUTPUT_CLU;
		}
	}
}

print STDOUT "IGR cluster files created.\n";
print STDERR "IGR cluster files created.\n";

