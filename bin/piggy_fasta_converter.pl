#!/usr/bin/env perl
use warnings;
use strict;

my $in_file=$ARGV[0];
my $out_file=$ARGV[1];

open OUTPUT, ">$out_file" or die "Cannot open output file: $out_file\n";

my $beg_seq=0;
open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^>/){
		if($beg_seq == 0){
			print OUTPUT "$line\n";
			$beg_seq=1;
		}else{
			print OUTPUT "\n$line\n";
		}
	}else{
		$line=~tr/a-z/A-Z/;
		print OUTPUT "$line";
	}
}

print OUTPUT "\n";

