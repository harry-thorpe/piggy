#!/usr/bin/env perl
use warnings;
use strict;

my $in_blast_file=$ARGV[0];
my $in_file=$ARGV[1];
my $out_file=$ARGV[2];

open OUTPUT, ">$out_file" or die "Cannot open output file: $out_file\n";

my %seq_header_hash=();

open INPUT, $in_blast_file or die "Input file doesn't exist: $in_blast_file\n";
while(my $line=<INPUT>){
	chomp $line;
	my @line_array=split(/\t/, $line);
	
	if($line_array[0] eq $line_array[1]){
		$seq_header_hash{$line_array[0]}=$line_array[3];
	}
}

my @seq_header_array=keys(%seq_header_hash);
@seq_header_array=sort(@seq_header_array);
my $seq_header_count=scalar(@seq_header_array);

my $hits=0;
if($seq_header_count > 1){
	open INPUT, $in_blast_file or die "Input file doesn't exist: $in_blast_file\n";
	while(my $line=<INPUT>){
		chomp $line;
		my @line_array=split(/\t/, $line);
	
		if($line_array[0] eq $seq_header_array[0] && $line_array[1] eq $seq_header_array[1]){
			$hits++;
		}
	}
}

my $id="";
my @seq_array=();

if($hits > 0){
	print STDOUT "hit";
}else{
	print STDOUT "no_hit";
	
	open FASTA, "$in_file" or die "Input file doesn't exist: $in_file\n";
	while(my $line=<FASTA>){
		chomp $line;

		if($line =~ /^>(.+)/){
			$id=$1;
		}elsif($line =~ /^([ATGCN]+)/){
			my $seq=$1;
			my $len=length($seq);
	
			my @tmp_array=("$id", "$seq", "$len");
	
			push @seq_array, [@tmp_array];
		}
	}

	print OUTPUT ">$seq_array[0][0]\n";
	print OUTPUT "$seq_array[0][1]";
	for(my $i=0; $i<$seq_array[1][2]; $i++){
		print OUTPUT "-";
	}
	print OUTPUT "\n";

	print OUTPUT ">$seq_array[1][0]\n";
	for(my $i=0; $i<$seq_array[0][2]; $i++){
		print OUTPUT "-";
	}
	print OUTPUT "$seq_array[1][1]";
	print OUTPUT "\n";
}

