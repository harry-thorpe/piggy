#!/usr/bin/env perl
use warnings;

$in_file=$ARGV[0];
$out_file=$ARGV[1];

open OUTPUT, ">$out_file";

$beg_seq=0;
open INPUT, "$in_file";
while(<INPUT>){
	$line=$_;
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

