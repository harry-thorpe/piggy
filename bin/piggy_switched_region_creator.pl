#!/usr/bin/perl -w

$in_file=$ARGV[0];
$in_dir=$ARGV[1];
$out_dir=$ARGV[2];

print STDOUT "Detecting candidate switched IGRs...\n";
print STDERR "Detecting candidate switched IGRs...\n";

open OUTPUT_SR, ">$out_dir/switched_regions.txt";

open INPUT, $in_file;
while(<INPUT>){
	$line=$_;
	chomp $line;
	@line_array=split(/\s+/, $line);
	
	$cluster_hash{$line_array[1]}{$line_array[0]}=1;
}

@gene_pair_array=keys(%cluster_hash);

foreach $gene_pair(@gene_pair_array){
	@cluster_array=keys(%{$cluster_hash{$gene_pair}});
	@cluster_array=sort(@cluster_array);
	
	$cluster_count=scalar(@cluster_array);
	
	#print "$cluster_count";
	
	if($cluster_count > 1){
		for($i=0; $i<$cluster_count; $i++){
			
			$rep_1_len=0;
			$rep_1_seq="";
			open FASTA_1, "$in_dir/$cluster_array[$i].fasta";
			while(<FASTA_1>){
				$line=$_;
				chomp $line;
				
				if($line =~ /^>(.+)/){
					$id_1=$1;
				}else{
					$seq_1_len=length($line);
					
					if($seq_1_len > $rep_1_len){
						$rep_1_seq=$line;
						$rep_1_len=$seq_1_len;
					}
				}
			}
			
			for($j=($i+1); $j<$cluster_count; $j++){
				
				$rep_2_len=0;
				$rep_2_seq="";
				open FASTA_2, "$in_dir/$cluster_array[$j].fasta";
				while(<FASTA_2>){
					$line=$_;
					chomp $line;
				
					if($line =~ /^>(.+)/){
						$id_2=$1;
					}else{
						$seq_2_len=length($line);
					
						if($seq_2_len > $rep_2_len){
							$rep_2_seq=$line;
							$rep_2_len=$seq_2_len;
						}
					}
				}
				
				open OUTPUT, ">$out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j].fasta";
				
				print OUTPUT ">$id_1\n$rep_1_seq\n>$id_2\n$rep_2_seq\n";
				
				print OUTPUT_SR "${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j]\n";
			}
		}
	}
}

print STDOUT "Candidate switched IGRs detected.\n";
print STDERR "Candidate switched IGRs detected.\n";

