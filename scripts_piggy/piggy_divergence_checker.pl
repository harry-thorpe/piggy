#!/usr/bin/env perl
use warnings;
use strict;

my $in_dir=$ARGV[0];
my $out_dir=$ARGV[1];
my $out_file=$ARGV[2];

open OUTPUT, ">$out_dir/$out_file" or die "Cannot open output file: $out_dir/$out_file\n";
print OUTPUT "Gene,Id_1,Id_2,SNPs,Sites,Length,Nuc_identity,Length_identity\n";

opendir(my $dh, $in_dir) or die "Input folder doesn't exist: $in_dir\n";
while(my $file=readdir $dh){
	
	my $gene="";
	
	if($file=~/([^\.]+)\..+/){
		$gene=$1;
	}
	
	my $nuc_identity_sum=0;
	my $len_identity_sum=0;
	my $comp=0;
	
	my $id="";
	my $snps=0;
	my $sites=0;
	
	my $ref_seq="";
	my @ref_seq_array=();
	my $ref_seq_len=0;
	my $ref_id="";
	
	my $count=0;
	open INPUT, "$in_dir/$file" or die "Input file doesn't exist: $in_dir/$file\n";
	while(my $line=<INPUT>){
		chomp $line;
		
		if($line =~ /^>(.+)/){
			$id=$1;
		}else{
			$count++;
			
			my $seq=$line;
			my @seq_array=split(//, $seq);
			my $seq_len=scalar(@seq_array);
			
			$sites=0;
			$snps=0;
			my $nuc_identity=0;
			my $len_identity=0;
			my $ref_seq_sites=0;
			my $seq_sites=0;
			
			if($count == 1){
				$ref_seq=$seq;
				@ref_seq_array=split(//, $ref_seq);
				$ref_seq_len=scalar(@ref_seq_array);
				$ref_id=$id;
			}else{
				if($ref_seq_len == $seq_len){
					
					$comp=1;
					for(my $pos=0; $pos<$ref_seq_len; $pos++){
						if($ref_seq_array[$pos] !~ /n|N|-/){
							$ref_seq_sites++;
						}
						if($seq_array[$pos] !~ /n|N|-/){
							$seq_sites++;
						}
					
						if($ref_seq_array[$pos] !~ /n|N|-/ && $seq_array[$pos] !~ /n|N|-/){
							$sites++;
							if($ref_seq_array[$pos] ne $seq_array[$pos]){
								$snps++;
							}
						}
					}
					
					if($sites > 0){
						$nuc_identity=($snps/$sites);
						$nuc_identity=(1-$nuc_identity);
						
						$len_identity=($sites/$ref_seq_len);
						
						$nuc_identity_sum+=$nuc_identity;
						$len_identity_sum+=$len_identity;
					}
				}else{
					print "bad sequences\n";
				}
			}
		}
	}
	
	if($comp == 1){
		my $comp_count=$count-1;
		my $nuc_identity=$nuc_identity_sum/$comp_count;
		my $len_identity=$len_identity_sum/$comp_count;
	
		print OUTPUT "$gene,$ref_id,$id,$snps,$sites,$ref_seq_len,$nuc_identity,$len_identity\n";
	}
}

