#!/usr/bin/env perl
use warnings;
use strict;

my $isolate=$ARGV[0];
my $in_file=$ARGV[1];
my $in_coor_file=$ARGV[2];
my $out_dir=$ARGV[3];
my $out_iso_dir=$ARGV[4];
my $in_coor_g_file=$ARGV[5];
my $out_iso_g_dir=$ARGV[6];

my $min_len=30;
my $max_len=1000;
my $max_n_prop=0.1;

#open OUTPUT, ">>$out_dir/IGR_sequences.fasta" or die "Cannot open output file: $out_dir/IGR_sequences.fasta\n";

if(! -e "$out_iso_dir" && ! -d "$out_iso_dir"){
	mkdir "$out_iso_dir" or die "Cannot create output folder: $out_iso_dir\n";
}

if(! -e "$out_iso_g_dir" && ! -d "$out_iso_g_dir"){
	mkdir "$out_iso_g_dir" or die "Cannot create output folder: $out_iso_g_dir\n";
}

open OUTPUT, ">$out_iso_dir/${isolate}_IGR_sequences.fasta" or die "Cannot open output file: $out_iso_dir/${isolate}_IGR_sequences.fasta\n";
open OUTPUT_GF, ">$out_iso_g_dir/${isolate}_GF_sequences.fasta" or die "Cannot open output file: $out_iso_g_dir/${isolate}_GF_sequences.fasta\n";

my @contig_array=();
my %contig_hash=();
my $contig_id="";
my $contig="";
my $contig_seq="";

my $include=0;
open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^##FASTA/){
		$include=1;
	}
	
	if($include == 1){
		if($line =~ /^>(\S+)/){
			$contig_id=$1;
			
			push @contig_array, $contig_id;
		}elsif($line !~ /^>/ && $line =~ /^(\S+)/){
			my $seq=$1;
			$seq=~tr/atgcn/ATGCN/;
			$seq=~tr/bdefhijklmopqrsuvwxyz/NNNNNNNNNNNNNNNNNNNNN/;
			$seq=~tr/BDEFHIJKLMOPQRSUVWXYZ/NNNNNNNNNNNNNNNNNNNNN/;
			$seq=~tr/-/N/;
			
			if(!$contig_hash{$contig_id}){
				$contig_hash{$contig_id}=$seq;
			}else{
				$contig_hash{$contig_id}=$contig_hash{$contig_id}.$seq;
			}
		}
	}
}

foreach $contig(@contig_array){
	$contig_seq=$contig_hash{$contig};
	
	open INCOOR, "$in_coor_file" or die "Input file doesn't exist: $in_coor_file\n";
	while(my $line=<INCOOR>){
		chomp $line;
		my @line_array=split(/\t/, $line);
		
		my $int_seq="";
		my $int_id=$line_array[1];
		$int_id="${isolate}_+_+_$int_id";
		my $sta=$line_array[2];
		my $end=$line_array[3];
		my $len=$line_array[4];
		my $contig_id=$line_array[6];
		
		if($line !~ /^Name\tGene_name\tStart\tEnd\tLength\tType/){
			if($contig eq $contig_id){
				
				if($len >= $min_len && $len <= $max_len){
					my $ind_sta=($sta-1);
					my $ind_end=($end-1);
					
					for my $x($ind_sta..$ind_end){
						
						my $base=substr($contig_seq, $x, 1);
						$int_seq=$int_seq.$base;
					}
					
					my $n_count=$int_seq=~tr/N/N/;
					my $n_prop=($n_count/$len);
					
					if($n_prop < $max_n_prop){
						print OUTPUT ">$int_id\n$int_seq\n";
					
						#open OUTPUT_ISOLATE, ">$out_iso_dir/$int_id.fasta" or die "Cannot open output file: $out_iso_dir/$int_id.fasta\n";
						#print OUTPUT_ISOLATE ">$int_id\n$int_seq\n";
						#close OUTPUT_ISOLATE;
					}
				}
			}
		}
	}
}

foreach $contig(@contig_array){
	$contig_seq=$contig_hash{$contig};
	
	open INCOOR, "$in_coor_g_file" or die "Input file doesn't exist: $in_coor_g_file\n";
	while(my $line=<INCOOR>){
		chomp $line;
		my @line_array=split(/\t/, $line);
		
		my $gene_s_seq="";
		my $gene_e_seq="";
		my $gene_id=$line_array[0];
		my $sta=$line_array[2];
		my $end=$line_array[3];
		my $len=$line_array[4];
		my $contig_id=$line_array[7];
		
		if($line !~ /^Name\tGene\tStart\tEnd\tLength\tType/){
			if($contig eq $contig_id){
				
				if($len >= 30){
					my $ind_sta=($sta-1);
					my $ind_end=($end-1);
					
					for my $x($ind_sta..($ind_sta+29)){
						
						my $base=substr($contig_seq, $x, 1);
						$gene_s_seq=$gene_s_seq.$base;
					}
					
					for my $x(($ind_end-29)..$ind_end){
						
						my $base=substr($contig_seq, $x, 1);
						$gene_e_seq=$gene_e_seq.$base;
					}
					print OUTPUT_GF ">${gene_id}_s\n$gene_s_seq\n>${gene_id}_e\n$gene_e_seq\n";
				
					#open OUTPUT_ISOLATE, ">$out_iso_g_dir/$gene_id.fasta" or die "Cannot open output file: $out_iso_g_dir/$gene_id.fasta\n";
					#print OUTPUT_ISOLATE ">${gene_id}_s\n$gene_s_seq\n>${gene_id}_e\n$gene_e_seq\n";
					#close OUTPUT_ISOLATE;
				}
			}
		}
	}
}

#print STDOUT "$isolate intergenic sequences extracted.\n";
#print STDERR "$isolate intergenic sequences extracted.\n";

