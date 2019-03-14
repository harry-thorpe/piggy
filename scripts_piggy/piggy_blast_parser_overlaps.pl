#!/usr/bin/env perl
use warnings;
use strict;

my $in_blast_file=$ARGV[0];

my $hits=0;
open INPUT, $in_blast_file or die "Input file doesn't exist: $in_blast_file\n";
while(my $line=<INPUT>){
	chomp $line;
	my @line_array=split(/\t/, $line);
	
	if($line_array[0] =~ /\S+/){
		$hits++;
	}
}

if($hits > 0){
	print STDOUT "hit";
}else{
	print STDOUT "no_hit";
}

