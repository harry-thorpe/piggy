#!/usr/bin/env perl
use warnings;
use strict;

# this script processes the output from mafft

my $in_file=$ARGV[0];
my $out_file=$ARGV[1];
my $iso_file=$ARGV[2];

my %iso_hash=();
open ISO, "$iso_file" or die "Cannot open isolate file: $iso_file\n";
while(my $line=<ISO>){
    chomp $line;

    $iso_hash{$line}=1;
}

open OUTPUT, ">$out_file" or die "Cannot open output file: $out_file\n";

my $beg_seq=0;
open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	
    if($line =~ /^>(\S+)/){
        my $id=$1;

        my @id_array=split(/_\+_\+_/, $id);
        
        my $iso=$id_array[0];
        my $id_p="";

        if($iso_hash{$iso}){
            $id_p=$id;
        }elsif($iso =~ /^_R_(\S+)/){
            my $iso_rev=$1;
            if($iso_hash{$iso_rev}){
                $id_p="${iso_rev}_+_+_$id_array[1]_+_+_$id_array[2]_+_+_$id_array[3]_+_+_R";
            }else{
                die "ERROR: ID $iso_rev not recognised.\n";
            }
        }else{
            die "ERROR: ID $iso not recognised.\n";
        }

		if($beg_seq == 0){
			print OUTPUT ">$id_p\n";
			$beg_seq=1;
		}else{
			print OUTPUT "\n>$id_p\n";
		}
	}else{
		$line=~tr/a-z/A-Z/;
		print OUTPUT "$line";
	}
}
print OUTPUT "\n";

close INPUT;
close OUTPUT;
