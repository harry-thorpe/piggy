#!/usr/bin/perl -w

$isolate=$ARGV[0];
$in_dir=$ARGV[1];
$out_dir=$ARGV[2];

open LOG, ">>$out_dir/log.txt";

open OUTPUT, ">$in_dir/${isolate}.gff.modified";

$include=0;
$fir=0;
open INPUT, "$in_dir/$isolate.gff";
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

print "$isolate gff modified.\n";

print LOG "$isolate gff modified.\n";

