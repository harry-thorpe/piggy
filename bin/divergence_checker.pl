#!/usr/bin/perl -w

$in_dir=$ARGV[0];
$out_dir=$ARGV[1];
$out_file=$ARGV[2];

open OUTPUT, ">$out_dir/$out_file";
print OUTPUT "Gene,Id_1,Id_2,SNPs,Sites,Length,Nuc_identity,Length_identity\n";

opendir($dh, $in_dir);
while(readdir $dh){
	$file=$_;
	
	if($file=~/([^\.]+)\..+/){
		$gene=$1;
	}
	
	$nuc_identity_sum=0;
	$len_identity_sum=0;
	$comp=0;
	
	$count=0;
	open INPUT, "$in_dir/$file";
	while(<INPUT>){
		$line=$_;
		chomp $line;
		
		if($line =~ /^>(.+)/){
			$id=$1;
		}else{
			$count++;
			
			$seq=$line;
			@seq_array=split(//, $seq);
			$seq_len=scalar(@seq_array);
			
			$sites=0;
			$snps=0;
			$nuc_identity=0;
			$len_identity=0;
			$ref_seq_sites=0;
			$seq_sites=0;
			
			if($count == 1){
				$ref_seq=$seq;
				@ref_seq_array=split(//, $ref_seq);
				$ref_seq_len=scalar(@ref_seq_array);
				$ref_id=$id;
			}else{
				if($ref_seq_len == $seq_len){
					
					$comp=1;
					for($pos=0; $pos<$ref_seq_len; $pos++){
						if($ref_seq_array[$pos] ne "-"){
							$ref_seq_sites++;
						}
						if($seq_array[$pos] ne "-"){
							$seq_sites++;
						}
					
						if($ref_seq_array[$pos] ne "-" && $seq_array[$pos] ne "-"){
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
		$comp_count=$count-1;
		$nuc_identity=$nuc_identity_sum/$comp_count;
		$len_identity=$len_identity_sum/$comp_count;
	
		print OUTPUT "$gene,$ref_id,$id,$snps,$sites,$ref_seq_len,$nuc_identity,$len_identity\n";
	}
}

