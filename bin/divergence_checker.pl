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
	
	@id_array=();
	%id_hash=();
	
	open INPUT, "$in_dir/$file";
	while(<INPUT>){
		$line=$_;
		chomp $line;
		
		if($line =~ /^>(.+)/){
			$id=$1;
			
			push @id_array, $id;
		}else{
			$seq=$line;
			$seq=~tr/a-z/A-Z/;
			
			if(!$id_hash{$id}){
				$id_hash{$id}=$seq;
			}else{
				$id_hash{$id}=$id_hash{$id}.$seq;
			}
		}
	}
	
	$id_count=scalar(@id_array);
	
	for($i=0; $i<$id_count; $i++){
		$id_1=$id_array[$i];
		
		$seq_1=$id_hash{$id_1};
		@seq_1_array=split(//, $seq_1);
		
		$seq_1_len=scalar(@seq_1_array);
		
		for($j=($i+1); $j<$id_count; $j++){
			$id_2=$id_array[$j];
		
			$seq_2=$id_hash{$id_2};
			@seq_2_array=split(//, $seq_2);
			
			$seq_2_len=scalar(@seq_2_array);
			
			$sites=0;
			$snps=0;
			$nuc_identity=0;
			$len_identity=0;
			$seq_1_sites=0;
			$seq_2_sites=0;
			
			if($seq_1_len == $seq_2_len){
				for($pos=0; $pos<$seq_1_len; $pos++){
					if($seq_1_array[$pos] ne "-"){
						$seq_1_sites++;
					}
					if($seq_2_array[$pos] ne "-"){
						$seq_2_sites++;
					}
					
					if($seq_1_array[$pos] ne "-" && $seq_2_array[$pos] ne "-"){
						$sites++;
						if($seq_1_array[$pos] ne $seq_2_array[$pos]){
							$snps++;
						}
					}
				}
			}else{
				print "bad sequences\n";
			}
			
			if($sites > 0){
				$nuc_identity=($snps/$sites);
				$nuc_identity=(1-$nuc_identity);
				
				if($seq_1_sites > $seq_2_sites){
					$len_identity=($sites/$seq_1_len);
				}else{
					$len_identity=($sites/$seq_2_len);
				}
				
				print OUTPUT "$gene,$id_1,$id_2,$snps,$sites,$seq_1_len,$nuc_identity,$len_identity\n";
			}else{
				print OUTPUT "$gene,$id_1,$id_2,$snps,$sites,$seq_1_len,0,0\n";
			}
		}
	}
}

