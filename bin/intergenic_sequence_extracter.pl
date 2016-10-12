#!/usr/bin/perl -w

$isolate=$ARGV[0];
$in_dir=$ARGV[1];
$out_dir=$ARGV[2];

$min_len=30;

open LOG, ">>$out_dir/log.txt";

mkdir "$out_dir/isolate_intergenic_files/$isolate";

#open OUTPUT, ">$out_dir/isolate_intergenic_files/$isolate/$isolate.fasta";
open OUTPUT, ">>$out_dir/output_fasta.fasta";

$include=0;
open INPUT, "$in_dir/$isolate.gff.modified";
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
	#@contig_seq_array=split(//, $contig_seq);
	
	open INCOOR, "$out_dir/coordinate_files/${isolate}_intergenic_coordinates.tab";
	while(<INCOOR>){
		$line=$_;
		chomp $line;
		@line_array=split(/\t/, $line);
		
		$int_seq="";
		$int_id=$line_array[1];
		$int_id="${isolate}_+_+_$int_id";
		$sta=$line_array[2];
		$end=$line_array[3];
		$contig_id=$line_array[6];
		if($line !~ /^Name\tGene_name\tStart\tEnd\tLength\tType/){
			if($contig eq $contig_id){
				$len=(($end - $sta) + 1);
				if($len >= $min_len){
					$ind_sta=($sta-1);
					$ind_end=($end-1);
					
					for $x($ind_sta..$ind_end){
						#print OUTPUT "$contig_seq_array[$x]";
						$base=substr($contig_seq, $x, 1);
						$int_seq=$int_seq.$base;
					}
					print OUTPUT ">$int_id\n$int_seq\n";
					
					open OUTPUT_ISOLATE, ">$out_dir/isolate_intergenic_files/$isolate/$int_id.fasta";
					print OUTPUT_ISOLATE ">$int_id\n$int_seq\n";
				}
			}
		}
	}
}

print "$isolate intergenic fasta file produced.\n";

print LOG "$isolate intergenic alignment split.\n";

