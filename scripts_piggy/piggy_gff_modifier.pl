#!/usr/bin/env perl
use warnings;
use strict;

my $in_file=$ARGV[0];

my $in_base=$in_file;

if($in_file =~ /\/([^\/]+)\.gff/){
	$in_base=$1;
}

open OUTPUT, ">$in_file.modified" or die "Cannot open output file: $in_file.modified\n";

my $include=0;
my $fir=0;

open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	
	if($include == 0 && $line !~ /^##FASTA/){
		
		print OUTPUT "$line\n";
	}elsif($include == 0 && $line =~ /^##FASTA/){
		$include=1;
		$fir=1;
		
		print OUTPUT "$line\n";
	}elsif($line =~ /^>/){
		if($fir == 1){
			print OUTPUT "$line\n";
			$fir=0;
		}elsif($fir == 0){
			print OUTPUT "\n$line\n";
		}
	}else{
		print OUTPUT "$line";
	}
}
print OUTPUT "\n";

#print STDOUT "$in_base modified.\n";
#print STDERR "$in_base modified.\n";

