#!/usr/bin/env perl
use warnings;
use strict;

my $out_dir=$ARGV[0];
my $piggy_bin_path=$ARGV[1];

print STDOUT "Creating IGR cluster files.\n";
print STDERR "Creating IGR cluster files.\n";

open OUTPUT, ">$out_dir/clusters.txt" or die "Cannot open output file: $out_dir/clusters.txt\n";

open OUTPUT_REP, ">$out_dir/representative_clusters.fasta" or die "Cannot open output file: $out_dir/representative_clusters.fasta\n";

my $cluster="";
my $cluster_id="";

# hashes for med approach
my %rep_hash=();
my %clu_hash=();

my $count=0;
open INPUT, "$out_dir/IGR_sequences_clustered.fasta.clstr" or die "Input file doesn't exist: $out_dir/IGR_sequences_clustered.fasta.clstr\n";
while(my $line=<INPUT>){
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
		my $cluster_id=$1;
		my @cluster_id_array=split(/_\+_\+_/, $cluster_id);
		my $isolate=$cluster_id_array[0];
		
		if($line =~ /\*$/){
			
			# Make hash (med tmp and speed)
			$rep_hash{$cluster_id}=$cluster;
			
			# Print representative sequences. (slow and fast)
#			open OUTPUT_CLU, ">$out_dir/cluster_intergenic_files/$cluster.fasta" or die "Cannot open output file: $out_dir/cluster_intergenic_files/$cluster.fasta\n";
			
#			open OUTPUT_CLU_REP, ">$out_dir/cluster_representative_files/$cluster.fasta" or die "Cannot open output file: $out_dir/cluster_representative_files/$cluster.fasta\n";
			
			
#			slow but few tmp files
#			my $seq=`"$piggy_bin_path/piggy_fasta_finder.pl" "$cluster_id" "$out_dir/isolate_intergenic_files/$isolate/${isolate}_IGR_sequences.fasta"`;
			
#			print OUTPUT_REP ">${cluster}_+_+_$cluster_id\n$seq\n";
#			print OUTPUT_CLU_REP ">${cluster}_+_+_$cluster_id\n$seq\n";
#			print OUTPUT_CLU ">$cluster_id\n$seq\n";
			
#			fast but many tmp files			
#			open INPUT_CLU, "$out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta" or die "Input file doesn't exist: $out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta\n";
#			while(my $line=<INPUT_CLU>){
#				chomp $line;
#	
#				if($line =~ /^>(.+)/){
#	
#				}else{
#					print OUTPUT_REP ">${cluster}_+_+_$cluster_id\n$line\n";
#					
#					print OUTPUT_CLU_REP ">${cluster}_+_+_$cluster_id\n$line\n";
#				
#					print OUTPUT_CLU ">$cluster_id\n$line\n";
#				}
#			}
			
#			close OUTPUT_CLU;
#			close OUTPUT_CLU_REP;
		}
	}
}

open INPUT, "$out_dir/IGR_sequences.fasta" or die "Input file doesn't exist: $out_dir/IGR_sequences.fasta\n";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^>(\S+)/){
		$cluster_id=$1;
	}elsif($line =~ /^([ATGCN-]+)/){
		
		$cluster=$rep_hash{$cluster_id};
		
		if($rep_hash{$cluster_id}){
			open OUTPUT_CLU, ">$out_dir/cluster_intergenic_files/$cluster.fasta" or die "Cannot open output file: $out_dir/cluster_intergenic_files/$cluster.fasta\n";
			open OUTPUT_CLU_REP, ">$out_dir/cluster_representative_files/$cluster.fasta" or die "Cannot open output file: $out_dir/cluster_representative_files/$cluster.fasta\n";
			
			print OUTPUT_REP ">${cluster}_+_+_$cluster_id\n$line\n";
			print OUTPUT_CLU_REP ">${cluster}_+_+_$cluster_id\n$line\n";
			print OUTPUT_CLU ">$cluster_id\n$line\n";
		}
	}
}
close OUTPUT_CLU;
close OUTPUT_CLU_REP;
close OUTPUT;
close OUTPUT_REP;

$count=0;
open INPUT, "$out_dir/IGR_sequences_clustered.fasta.clstr" or die "Input file doesn't exist: $out_dir/IGR_sequences_clustered.fasta.clstr\n";
while(my $line=<INPUT>){
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
		my $cluster_id=$1;
		my @cluster_id_array=split(/_\+_\+_/, $cluster_id);
		my $isolate=$cluster_id_array[0];
		
		if($line !~ /\*$/){
			
			# Make hash (med tmp and speed)
			$clu_hash{$cluster_id}=$cluster;
			
			# print to cluster file.
#			open OUTPUT_CLU, ">>$out_dir/cluster_intergenic_files/$cluster.fasta" or die "Cannot open output file: $out_dir/cluster_intergenic_files/$cluster.fasta\n";

#			slow but few tmp files		
#			my $seq=`"$piggy_bin_path/piggy_fasta_finder.pl" "$cluster_id" "$out_dir/isolate_intergenic_files/$isolate/${isolate}_IGR_sequences.fasta"`;
			
#			print OUTPUT_CLU ">$cluster_id\n$seq\n";
			
#			fast but many tmp files	
#			open INPUT_CLU, "$out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta" or die "Input file doesn't exist: $out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta\n";
#			while(my $line=<INPUT_CLU>){
#				
#				print OUTPUT_CLU "$line";
#				
#				chomp $line;
#			
#				if($line =~ /^>(.+)/){
#			
#				}else{
#					print OUTPUT_CLU ">$cluster_id\n$line\n";
#				}
#			}
			
#			close OUTPUT_CLU;
		}
	}
}

open INPUT, "$out_dir/IGR_sequences.fasta" or die "Input file doesn't exist: $out_dir/IGR_sequences.fasta\n";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^>(\S+)/){
		$cluster_id=$1;
	}elsif($line =~ /^([ATGCN-]+)/){
		
		$cluster=$clu_hash{$cluster_id};
		
		if($clu_hash{$cluster_id}){
			open OUTPUT_CLU, ">>$out_dir/cluster_intergenic_files/$cluster.fasta" or die "Cannot open output file: $out_dir/cluster_intergenic_files/$cluster.fasta\n";

			print OUTPUT_CLU ">$cluster_id\n$line\n";
		}
	}
}
close OUTPUT_CLU;

print STDOUT "IGR cluster files created.\n";
print STDERR "IGR cluster files created.\n";

