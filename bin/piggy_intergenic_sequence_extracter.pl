#!/usr/bin/perl -w

$isolate=$ARGV[0];
$in_file=$ARGV[1];
$in_coor_file=$ARGV[2];
$out_dir=$ARGV[3];
$out_iso_dir=$ARGV[4];
$in_coor_g_file=$ARGV[5];
$out_iso_g_dir=$ARGV[6];

$min_len=30;
$max_len=1000;
$max_n_prop=0.1;

open OUTPUT, ">>$out_dir/IGR_sequences.fasta";

$include=0;
open INPUT, "$in_file";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /^##FASTA/){
		$include=1;
	}
	
	if($include == 1){
		if($line =~ /^>(\S+)/){
			$contig_id=$1;
			
			push @contig_array, $contig_id;
		}elsif($line =~ /^([ATGCN]+)/){
			$seq=$1;
			
			if(!$contig_hash{$contig_id}){
				$contig_hash{$contig_id}=$seq;
			}else{
				$contig_hash{$contig_id}=$contig_hash{$contig_id}.$seq;
			}
		}
	}
}

foreach $contig(@contig_array){
	$contig_seq=$contig_hash{$contig};
	
	open INCOOR, "$in_coor_file";
	while(<INCOOR>){
		$line=$_;
		chomp $line;
		@line_array=split(/\t/, $line);
		
		$int_seq="";
		$int_id=$line_array[1];
		$int_id="${isolate}_+_+_$int_id";
		$sta=$line_array[2];
		$end=$line_array[3];
		$len=$line_array[4];
		$contig_id=$line_array[6];
		
		if($line !~ /^Name\tGene_name\tStart\tEnd\tLength\tType/){
			if($contig eq $contig_id){
				
				if($len >= $min_len && $len <= $max_len){
					$ind_sta=($sta-1);
					$ind_end=($end-1);
					
					for $x($ind_sta..$ind_end){
						
						$base=substr($contig_seq, $x, 1);
						$int_seq=$int_seq.$base;
					}
					
					$n_count=$int_seq=~tr/N/N/;
					$n_prop=($n_count/$len);
					
					if($n_prop < $max_n_prop){
						print OUTPUT ">$int_id\n$int_seq\n";
					
						open OUTPUT_ISOLATE, ">$out_iso_dir/$int_id.fasta";
						print OUTPUT_ISOLATE ">$int_id\n$int_seq\n";
						close OUTPUT_ISOLATE;
					}
				}
			}
		}
	}
}

foreach $contig(@contig_array){
	$contig_seq=$contig_hash{$contig};
	
	open INCOOR, "$in_coor_g_file";
	while(<INCOOR>){
		$line=$_;
		chomp $line;
		@line_array=split(/\t/, $line);
		
		$gene_s_seq="";
		$gene_e_seq="";
		$gene_id=$line_array[0];
		$sta=$line_array[2];
		$end=$line_array[3];
		$len=$line_array[4];
		$contig_id=$line_array[7];
		
		if($line !~ /^Name\tGene\tStart\tEnd\tLength\tType/){
			if($contig eq $contig_id){
				
				if($len >= 30){
					$ind_sta=($sta-1);
					$ind_end=($end-1);
					
					for $x($ind_sta..($ind_sta+29)){
						
						$base=substr($contig_seq, $x, 1);
						$gene_s_seq=$gene_s_seq.$base;
					}
					
					for $x(($ind_end-29)..$ind_end){
						
						$base=substr($contig_seq, $x, 1);
						$gene_e_seq=$gene_e_seq.$base;
					}
				
					open OUTPUT_ISOLATE, ">$out_iso_g_dir/$gene_id.fasta";
					print OUTPUT_ISOLATE ">${gene_id}_s\n$gene_s_seq\n>${gene_id}_e\n$gene_e_seq\n";
					close OUTPUT_ISOLATE;
				}
			}
		}
	}
}

print STDOUT "$isolate intergenic sequences extracted.\n";
print STDERR "$isolate intergenic sequences extracted.\n";

