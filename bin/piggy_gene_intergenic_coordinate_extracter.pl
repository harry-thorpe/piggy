#!/usr/bin/env perl
use warnings;
use strict;

my $isolate=$ARGV[0];
my $in_file=$ARGV[1];
my $out_dir=$ARGV[2];

open OUTPUT_G, ">$out_dir/${isolate}_gene_coordinates.tab" or die "Cannot open output file: $out_dir/${isolate}_gene_coordinates.tab\n";
print OUTPUT_G "Name\tGene\tStart\tEnd\tLength\tType\tStrand\tContig\n";
open OUTPUT_I, ">$out_dir/${isolate}_intergenic_coordinates.tab" or die "Cannot open output file: $out_dir/${isolate}_intergenic_coordinates.tab\n";
print OUTPUT_I "Name\tGene_name\tStart\tEnd\tLength\tType\tContig\n";

my @gene_array=();
my %contig_hash_end=();

open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	my @line_array=split(/\t/, $line);
	
	my $contig="";
	my $sta=0;
	my $end=0;
	my $len=0;
	my $type="";
	my $strand="";
	my $id="";
	my $gene="";
	my $seq_end=0;
	
	if($line !~ /^##/){
		if($line_array[2] eq "CDS" || $line_array[2] eq "rRNA" || $line_array[2] eq "tRNA"){
			$contig=$line_array[0];
			$sta=$line_array[3];
			$end=$line_array[4];
			$type=$line_array[2];
		
			if($line_array[6] eq "+"){
				$strand="Forward";
			}elsif($line_array[6] eq "-"){
				$strand="Reverse";
			}
		
			$len=(($end - $sta) + 1);
		
			if($line_array[8] =~ /ID=([^;]+);/){
				$id=$1;
			}
			if($line_array[8] =~ /gene=([^;]+);/){
				$gene=$1;
			}
		
			my @tmp_array=();
			@tmp_array=("$id", "$gene", "$sta", "$end", "$len", "$type", "$strand", "$contig");
		
			push @gene_array, [@tmp_array];
		
			print OUTPUT_G "$id\t$gene\t$sta\t$end\t$len\t$type\t$strand\t$contig\n";
		
		}
	}elsif($line =~ /^##sequence-region\s+(\S+)\s+(\d+)\s+(\d+)/){
		$contig=$1;
		#$seq_sta=$2;
		$seq_end=$3;
		
		#$contig_hash_sta{$contig}=$seq_sta;
		$contig_hash_end{$contig}=$seq_end;
		
	}elsif($line =~ /^##FASTA/){
		last;
	}
}

my $gene_count=scalar(@gene_array);

my $contig="";
my $int_sta=0;
my $int_end=0;
my $int_len=0;
my $gene_pre="";
my $gene_pos="";
my $int_type="";
my $int_name="";
my $int_id="";
my $int_count=0;

for(my $i=0; $i<$gene_count; $i++){
	# First gene.
	if($i == 0){
		$contig=$gene_array[$i][7];
		$int_sta=1;
		$int_end=($gene_array[$i][2] - 1);
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre="NA";
		$gene_pos=$gene_array[$i][0];
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
	# Last gene.
	elsif($i == ($gene_count - 1)){
		$contig=$gene_array[$i][7];
		$int_sta=($gene_array[$i][3] + 1);
		$int_end=$contig_hash_end{$contig};
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre=$gene_array[$i][0];
		$gene_pos="NA";
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
	# Gene on different contig.
	elsif($gene_array[($i-1)][7] ne $gene_array[$i][7]){
		# Edge of previous contig.
		$contig=$gene_array[($i-1)][7];
		$int_sta=($gene_array[($i-1)][3] + 1);
		$int_end=$contig_hash_end{$contig};
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre=$gene_array[($i-1)][0];
		$gene_pos="NA";
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
		
		# Edge of next contig.
		$contig=$gene_array[$i][7];
		$int_sta=1;
		$int_end=($gene_array[$i][2] - 1);
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre="NA";
		$gene_pos=$gene_array[$i][0];
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
	# Gene on same contig.
	elsif($gene_array[($i-1)][7] eq $gene_array[$i][7]){
		$contig=$gene_array[$i][7];
		$int_sta=($gene_array[($i-1)][3] + 1);
		$int_end=($gene_array[$i][2] - 1);
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre=$gene_array[($i-1)][0];
		$gene_pos=$gene_array[$i][0];
	
		if($gene_array[($i-1)][6] eq "Forward" && $gene_array[$i][6] eq "Forward"){
			
			$int_type="CO_F";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}elsif($gene_array[($i-1)][6] eq "Forward" && $gene_array[$i][6] eq "Reverse"){
			
			$int_type="DT";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}elsif($gene_array[($i-1)][6] eq "Reverse" && $gene_array[$i][6] eq "Forward"){
			
			$int_type="DP";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}elsif($gene_array[($i-1)][6] eq "Reverse" && $gene_array[$i][6] eq "Reverse"){
			
			$int_type="CO_R";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
}

print STDOUT "$isolate gene intergenic coordinates extracted.\n";
print STDERR "$isolate gene intergenic coordinates extracted.\n";

