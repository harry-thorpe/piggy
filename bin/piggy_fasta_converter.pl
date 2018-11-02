#!/usr/bin/env perl
use warnings;
use strict;

# this script processes the output from mafft

# aligned mafft file
my $in_file=$ARGV[0];
# desired output file
my $out_file=$ARGV[1];
# initial fasta file which mafft aligned
my $initial_in_file=$ARGV[2];

my @initial_ids=();
open ISO, "$initial_in_file" or die "Cannot open isolate file: $initial_in_file\n";
while(my $line=<ISO>){
    chomp $line;
    
    if($line =~ />(\S+)/){
        my $id=$1;
        push @initial_ids, $id;
    }
}
close ISO;

open OUTPUT, ">$out_file" or die "Cannot open output file: $out_file\n";

my $seq_count=0;
open INPUT, "$in_file" or die "Input file doesn't exist: $in_file\n";
while(my $line=<INPUT>){
	chomp $line;
	
    if($line =~ /^>(\S+)/){
        my $id=$1;
        my $initial_id=$initial_ids[$seq_count];
        my $id_p="";

        if($id eq $initial_id){
            $id_p=$id;
        }else{
            my $id_m="_R_$initial_id";
            if($id eq $id_m){
                $id_p="${initial_id}_+_+_R";
            }else{
                die "ERROR: IDs from initial mafft file and aligned file don't match: $initial_id\t$id\n";
            }
        }

        if($seq_count == 0){
            print OUTPUT ">$id_p\n";
        }else{
			print OUTPUT "\n>$id_p\n";
        }

        $seq_count++;
	}else{
		$line=~tr/a-z/A-Z/;
		print OUTPUT "$line";
	}
}
print OUTPUT "\n";

close INPUT;
close OUTPUT;
