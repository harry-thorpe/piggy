#!/usr/bin/perl -w

$isolate=$ARGV[0];
$in_file=$ARGV[1];
$out_dir=$ARGV[2];

open OUTPUT_G, ">$out_dir/${isolate}_gene_coordinates.tab";
print OUTPUT_G "Name\tGene\tStart\tEnd\tLength\tType\tStrand\tContig\n";
open OUTPUT_I, ">$out_dir/${isolate}_intergenic_coordinates.tab";
print OUTPUT_I "Name\tGene_name\tStart\tEnd\tLength\tType\tContig\n";

open INPUT, "$in_file";
while(<INPUT>){
	$line=$_;
	chomp $line;
	@line_array=split(/\t/, $line);
	
	$contig="";
	$sta="";
	$end="";
	$strand="";
	$id="";
	$gene="";
	if($line !~ /^##/){
		if($line_array[2] ne "sig_peptide" && $line_array[2] ne "misc_RNA" && $line_array[2] ne "repeat_region"){
			$contig=$line_array[0];
			$sta=$line_array[3];
			$end=$line_array[4];
			$type=$line_array[2];
		
			if($line_array[6] eq "+"){
				$strand="Forward";
			}elsif($line_array[6] eq "-"){
				$strand="Reverse";
			}
		
			$len=(($end - $sta) + 1);
		
			if($line_array[8] =~ /ID=(${isolate}_[^;]+);/){
				$id=$1;
			}
			if($line_array[8] =~ /gene=([^;]+);/){
				$gene=$1;
			}
		
			@tmp_array=();
			@tmp_array=("$id", "$gene", "$sta", "$end", "$len", "$type", "$strand", "$contig");
		
			push @gene_array, [@tmp_array];
		
			print OUTPUT_G "$id\t$gene\t$sta\t$end\t$len\t$type\t$strand\t$contig\n";
		
		}
	}elsif($line =~ /^##sequence-region\s+(\S+)\s+(\d+)\s+(\d+)/){
		$contig=$1;
		#$seq_sta=$2;
		$seq_end=$3;
		
		#$contig_hash_sta{$contig}=$seq_sta;
		$contig_hash_end{$contig}=$seq_end;
		
	}elsif($line =~ /^##FASTA/){
		last;
	}
}

$gene_count=scalar(@gene_array);

$int_count=0;
for($i=0; $i<$gene_count; $i++){
	# First gene.
	if($i == 0){
		$contig=$gene_array[$i][7];
		$int_sta=1;
		$int_end=($gene_array[$i][2] - 1);
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre="NA";
		$gene_pos=$gene_array[$i][0];
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
	# Last gene.
	elsif($i == ($gene_count - 1)){
		$contig=$gene_array[$i][7];
		$int_sta=($gene_array[$i][3] + 1);
		$int_end=$contig_hash_end{$contig};
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre=$gene_array[$i][0];
		$gene_pos="NA";
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
	# Gene on different contig.
	elsif($gene_array[($i-1)][7] ne $gene_array[$i][7]){
		# Edge of previous contig.
		$contig=$gene_array[($i-1)][7];
		$int_sta=($gene_array[($i-1)][3] + 1);
		$int_end=$contig_hash_end{$contig};
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre=$gene_array[($i-1)][0];
		$gene_pos="NA";
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
		
		# Edge of next contig.
		$contig=$gene_array[$i][7];
		$int_sta=1;
		$int_end=($gene_array[$i][2] - 1);
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre="NA";
		$gene_pos=$gene_array[$i][0];
		$int_type="NA";
		$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
	# Gene on same contig.
	elsif($gene_array[($i-1)][7] eq $gene_array[$i][7]){
		$contig=$gene_array[$i][7];
		$int_sta=($gene_array[($i-1)][3] + 1);
		$int_end=($gene_array[$i][2] - 1);
		$int_len=(($int_end - $int_sta) + 1);
		
		$gene_pre=$gene_array[($i-1)][0];
		$gene_pos=$gene_array[$i][0];
	
		if($gene_array[($i-1)][6] eq "Forward" && $gene_array[$i][6] eq "Forward"){
			
			$int_type="CO_F";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}elsif($gene_array[($i-1)][6] eq "Forward" && $gene_array[$i][6] eq "Reverse"){
			
			$int_type="DT";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}elsif($gene_array[($i-1)][6] eq "Reverse" && $gene_array[$i][6] eq "Forward"){
			
			$int_type="DP";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}elsif($gene_array[($i-1)][6] eq "Reverse" && $gene_array[$i][6] eq "Reverse"){
			
			$int_type="CO_R";
			$int_name="${gene_pre}_+_+_${gene_pos}_+_+_$int_type";
		}
		
		$int_count++;
		$int_id="${isolate}_intergenic_$int_count";
		
		if($int_len > 0){
			print OUTPUT_I "$int_id\t$int_name\t$int_sta\t$int_end\t$int_len\t$int_type\t$contig\n";
		}
	}
}

print "$isolate gene intergenic coordinates extracted.\n";

