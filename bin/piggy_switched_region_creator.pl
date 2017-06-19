#!/usr/bin/env perl
use warnings;
use strict;

my $in_file=$ARGV[0];
my $in_dir=$ARGV[1];
my $out_dir=$ARGV[2];
my $in_g_dir=$ARGV[3];

print STDOUT "Detecting candidate switched IGRs...\n";
print STDERR "Detecting candidate switched IGRs...\n";

open OUTPUT_SR, ">$out_dir/switched_regions.txt" or die "Cannot open output file: $out_dir/switched_regions.txt\n";

my %cluster_hash=();

open INPUT, $in_file or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	my @line_array=split(/\s+/, $line);
	
	$cluster_hash{$line_array[1]}{$line_array[0]}=1;
}

my @gene_pair_array=keys(%cluster_hash);

foreach my $gene_pair(@gene_pair_array){
	my @cluster_array=keys(%{$cluster_hash{$gene_pair}});
	@cluster_array=sort(@cluster_array);
	
	my $cluster_count=scalar(@cluster_array);
	
	#print "$cluster_count";
	
	if($cluster_count > 1){
		for(my $i=0; $i<$cluster_count; $i++){
			
			my $rep_1_len=0;
			my $rep_1_seq="";
			my $rep_1_id="";
			
			my $id_1="";
			
			open FASTA_1, "$in_dir/$cluster_array[$i].fasta" or die "Input file doesn't exist: $in_dir/$cluster_array[$i].fasta\n";
			while(my $line=<FASTA_1>){
				chomp $line;
				
				if($line =~ /^>(.+)/){
					$id_1=$1;
				}else{
					my $seq_1_len=length($line);
					
					if($seq_1_len > $rep_1_len && $id_1 !~ /_\+_\+_NA_\+_\+_/){
						$rep_1_seq=$line;
						$rep_1_len=$seq_1_len;
						$rep_1_id=$id_1;
					}
				}
			}
			
			for(my $j=($i+1); $j<$cluster_count; $j++){
				
				my $rep_2_len=0;
				my $rep_2_seq="";
				my $rep_2_id="";
				
				my $id_2="";
				
				open FASTA_2, "$in_dir/$cluster_array[$j].fasta" or die "Input file doesn't exist: $in_dir/$cluster_array[$j].fasta\n";
				while(my $line=<FASTA_2>){
					chomp $line;
				
					if($line =~ /^>(.+)/){
						$id_2=$1;
					}else{
						my $seq_2_len=length($line);
					
						if($seq_2_len > $rep_2_len && $id_2 !~ /_\+_\+_NA_\+_\+_/){
							$rep_2_seq=$line;
							$rep_2_len=$seq_2_len;
							$rep_2_id=$id_2;
						}
					}
				}
				
				open OUTPUT, ">$out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j].fasta" or die "Cannot open output file: $out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j].fasta\n";
				
				print OUTPUT ">$rep_1_id\n$rep_1_seq\n>$rep_2_id\n$rep_2_seq\n";
				
				close OUTPUT;
				
				my $isolate_1="";
				my $gene_1_1="";
				my $gene_1_2="";
				
				my $isolate_2="";
				my $gene_2_1="";
				my $gene_2_2="";
				
				if($rep_1_id =~ /^(\S+)_\+_\+_(\S+)_\+_\+_(\S+)_\+_\+_\S+$/){
					$isolate_1=$1;
					$gene_1_1=$2;
					$gene_1_2=$3;
				}
				
				if($rep_2_id =~ /^(\S+)_\+_\+_(\S+)_\+_\+_(\S+)_\+_\+_\S+$/){
					$isolate_2=$1;
					$gene_2_1=$2;
					$gene_2_2=$3;
				}
				
				open OUTPUT, ">$out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j]_gene_fragments.fasta" or die "Cannot open output file: $out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j]_gene_fragments.fasta\n";
				
				open GENE_FRAG, "$in_g_dir/$isolate_1/$gene_1_1.fasta" or die "Input file doesn't exist: $in_g_dir/$isolate_1/$gene_1_1.fasta\n";
				while(my $line=<GENE_FRAG>){
					
					print OUTPUT "$line";
				}
				open GENE_FRAG, "$in_g_dir/$isolate_1/$gene_1_2.fasta" or die "Input file doesn't exist: $in_g_dir/$isolate_1/$gene_1_2.fasta\n";
				while(my $line=<GENE_FRAG>){
					
					print OUTPUT "$line";
				}
				open GENE_FRAG, "$in_g_dir/$isolate_2/$gene_2_1.fasta" or die "Input file doesn't exist: $in_g_dir/$isolate_2/$gene_2_1.fasta\n";
				while(my $line=<GENE_FRAG>){
					
					print OUTPUT "$line";
				}
				open GENE_FRAG, "$in_g_dir/$isolate_2/$gene_2_2.fasta" or die "Input file doesn't exist: $in_g_dir/$isolate_2/$gene_2_2.fasta\n";
				while(my $line=<GENE_FRAG>){
					
					print OUTPUT "$line";
				}
				
				close OUTPUT;
				
				print OUTPUT_SR "${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j]\n";
			}
		}
	}
}

print STDOUT "Candidate switched IGRs detected.\n";
print STDERR "Candidate switched IGRs detected.\n";

