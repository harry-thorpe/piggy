#!/usr/bin/perl -w

$in_file=$ARGV[0];

open OUTPUT, ">$in_file.modified";

$include=0;
$fir=0;
open INPUT, "$in_file";
while(<INPUT>){
	$line=$_;
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

print "$in_file modified.\n";
