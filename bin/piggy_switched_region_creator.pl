#!/usr/bin/perl -w

$in_file=$ARGV[0];
$in_dir=$ARGV[1];
$out_dir=$ARGV[2];
$in_g_dir=$ARGV[3];

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
			$rep_1_id="";
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
						$rep_1_id=$id_1;
					}
				}
			}
			
			for($j=($i+1); $j<$cluster_count; $j++){
				
				$rep_2_len=0;
				$rep_2_seq="";
				$rep_2_id="";
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
							$rep_2_id=$id_2;
						}
					}
				}
				
				open OUTPUT, ">$out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j].fasta";
				
				print OUTPUT ">$rep_1_id\n$rep_1_seq\n>$rep_2_id\n$rep_2_seq\n";
				
				close OUTPUT;
				
				if($rep_1_id =~ /^(\S+)_\+_\+_(\S+)_\+_\+_(\S+)_\+_\+_\S+$/){
					$isolate_1=$1;
					$gene_1_1=$2;
					$gene_1_2=$3;
				}
				
				if($rep_2_id =~ /^(\S+)_\+_\+_(\S+)_\+_\+_(\S+)_\+_\+_\S+$/){
					$isolate_2=$1;
					$gene_2_1=$2;
					$gene_2_2=$3;
				}
				
				open OUTPUT, ">$out_dir/switched_region_files/${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j]_gene_fragments.fasta";
				
				open GENE_FRAG, "$in_g_dir/$isolate_1/$gene_1_1.fasta";
				while(<GENE_FRAG>){
					$line=$_;
					
					print OUTPUT "$line";
				}
				open GENE_FRAG, "$in_g_dir/$isolate_1/$gene_1_2.fasta";
				while(<GENE_FRAG>){
					$line=$_;
					
					print OUTPUT "$line";
				}
				open GENE_FRAG, "$in_g_dir/$isolate_2/$gene_2_1.fasta";
				while(<GENE_FRAG>){
					$line=$_;
					
					print OUTPUT "$line";
				}
				open GENE_FRAG, "$in_g_dir/$isolate_2/$gene_2_2.fasta";
				while(<GENE_FRAG>){
					$line=$_;
					
					print OUTPUT "$line";
				}
				
				close OUTPUT;
				
				print OUTPUT_SR "${gene_pair}_+_+_$cluster_array[$i]_+_+_$cluster_array[$j]\n";
			}
		}
	}
}

print STDOUT "Candidate switched IGRs detected.\n";
print STDERR "Candidate switched IGRs detected.\n";

