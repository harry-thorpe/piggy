#!/usr/bin/env perl
use warnings;

$in_blast_file=$ARGV[0];

$hits=0;
open INPUT, $in_blast_file;
while(<INPUT>){
	$line=$_;
	chomp $line;
	@line_array=split(/\t/, $line);
	
	if($line_array[0] =~ /\S+/){
		$hits++;
	}
}

if($hits > 0){
	print STDOUT "hit";
}else{
	print STDOUT "no_hit";
}

