#!/usr/bin/perl -w

$in_file=$ARGV[0];
$out_file=$ARGV[1];
$out_dir=$ARGV[2];
$cluster_file=$ARGV[3];

if($in_file =~ /^(\S+)\.tab/){
	$in_base=$1;
}

open OUTPUT, ">$out_file";

open INPUT, "$cluster_file";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /(\S+)/){
		push @total_cluster_array, $line;
	}
}
close INPUT;

$cluster_1_pre="NA";
open OUTPUT_MOD, ">${in_base}_modified.tab";
open INPUT, "$in_file";
while(<INPUT>){
	$line=$_;
	chomp $line;
	@line_array=split(/\t/, $line);
	
	$cluster_1=$line_array[0];
	if($cluster_1_pre ne $cluster_1){
		print OUTPUT_MOD "CLUSTER_DELIMITER\n";
	}
	
	print OUTPUT_MOD "$line\n";
	
	$cluster_1_pre=$cluster_1;
}
print OUTPUT_MOD "CLUSTER_DELIMITER\n";
close INPUT;
close OUTPUT_MOD;

%merged_hash=();
%remove_cluster_hash=();

open INPUT, "${in_base}_modified.tab";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /^CLUSTER_DELIMITER/){
		if(%match_hash){
			@match_cluster_array=keys(%match_hash);
			
			@merge_cluster_array=();
			
			if(!$merged_hash{$cluster_1}){
				push @merge_cluster_array, $cluster_1;
				
				$merged_hash{$cluster_1}=1;
			}
			
			foreach $cluster(@match_cluster_array){
				@match_array=keys(%{$match_hash{$cluster}});
				$match_len_total=scalar(@match_array);
				$match_pcn_total=($match_len_total/$cluster_1_len);
		
				if($match_pcn_total >= 0.9){
					if(!$merged_hash{$cluster}){
						push @merge_cluster_array, $cluster;
						
						$merged_hash{$cluster}=1;
					}
				}
			}
			
			$merge_cluster_count=scalar(@merge_cluster_array);
			
			if($merge_cluster_count > 1){
				print OUTPUT "$merge_cluster_array[0]";
				
				for($i=1; $i<$merge_cluster_count; $i++){
					print OUTPUT "\t$merge_cluster_array[$i]";
				}
				print OUTPUT "\n";
				
				open OUTPUT_MERGE, ">>$out_dir/$merge_cluster_array[0].fasta";
				
				for($i=1; $i<$merge_cluster_count; $i++){
					open INPUT_MERGE, "$out_dir/$merge_cluster_array[$i].fasta";
					while(<INPUT_MERGE>){
						$line=$_;
						chomp $line;
						
						print OUTPUT_MERGE "$line\n";
					}
					
					unlink "$out_dir/$merge_cluster_array[$i].fasta";
					
					$remove_cluster_hash{$merge_cluster_array[$i]}=1;
				}
				
				close OUTPUT_MERGE;
			}
			
			%match_hash=();
		}
	}else{
		@line_array=split(/\t/, $line);
	
		$cluster_1=$line_array[0];
		$cluster_2=$line_array[1];
		$cluster_1_len=$line_array[2];
		#$cluster_2_len=$line_array[3];
		$match_pcn=$line_array[4];
		#$match_len=$line_array[5];
		$match_sta=$line_array[10];
		$match_end=$line_array[11];
	
		if($cluster_1 =~ /^(Cluster_)(\d+)/){
			$cluster_header=$1;$cluster_1_no=$2;
			
			$cluster_1="$cluster_header$cluster_1_no";
		}
		if($cluster_2 =~ /^(Cluster_)(\d+)/){
			$cluster_header=$1;$cluster_2_no=$2;
			
			$cluster_2="$cluster_header$cluster_2_no";
		}
	
		if($cluster_1 ne $cluster_2 && $match_pcn >= 90 && $cluster_1_no < $cluster_2_no){
			for($i=$match_sta; $i<=$match_end; $i++){
				$match_hash{$cluster_2}{$i}=1;
			}
		}
	}
}
close INPUT;

open OUTPUT_CLU, ">$cluster_file";

foreach $cluster(@total_cluster_array){
	if(!$remove_cluster_hash{$cluster}){
		print OUTPUT_CLU "$cluster\n";
	}
}

