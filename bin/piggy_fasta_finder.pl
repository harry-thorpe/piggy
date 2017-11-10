#!/usr/bin/env perl
use warnings;
use strict;

my $search=$ARGV[0];
my $in_file=$ARGV[1];

my $name="";
my $seq="";

open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	
	if($line =~ /^>(\S+)/){
		$name=$1;
	}elsif($line =~ /^([ATGCN-]+)/){
		$seq=$1;
		
		if($name eq $search){
			print $seq;
			last;
		}
	}
}

