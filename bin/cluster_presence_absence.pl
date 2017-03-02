#!/usr/bin/perl -w

$out_dir=$ARGV[0];

print STDOUT "Producing IGR presence absence matrix...\n";
print STDERR "Producing IGR presence absence matrix...\n";

open OUTPUT, ">$out_dir/IGR_presence_absence.csv";
open OUTPUT_RTAB, ">$out_dir/IGR_presence_absence.Rtab";

open INPUT, "$out_dir/isolates.txt";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	push @isolate_array, $line;
}
close INPUT;

open INPUT, "$out_dir/clusters.txt";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	push @cluster_array, $line;
}
close INPUT;

foreach $cluster(@cluster_array){
	open INPUT, "$out_dir/cluster_intergenic_files/$cluster.fasta";
	while(<INPUT>){
		$line=$_;
		chomp $line;
	
		if($line =~ /^>(.+)/){
			
			$cluster_id=$1;
			@cluster_id_array=split(/_\+_\+_/, $cluster_id);
			$isolate=$cluster_id_array[0];
		
			if(!$cluster_hash{$cluster}{$isolate}){
				$cluster_isolate_count_hash{$cluster}++;
			
				$cluster_hash{$cluster}{$isolate}=$cluster_id;
			}else{
				$cluster_hash{$cluster}{$isolate}="$cluster_hash{$cluster}{$isolate}\t$cluster_id";
			}
		
			$cluster_seq_count_hash{$cluster}++;
		}
	}
}

@cluster_sorted_array=sort { $cluster_isolate_count_hash{$b} <=> $cluster_isolate_count_hash{$a} } keys %cluster_isolate_count_hash;

print OUTPUT "\"Gene\",\"Non-unique Gene name\",\"Annotation\",\"No. isolates\",\"No. sequences\",\"Avg sequences per isolate\",\"Genome Fragment\",\"Order within Fragment\",\"Accessory Fragment\",\"Accessory Order with Fragment\",\"QC\",\"Min group size nuc\",\"Max group size nuc\",\"Avg group size nuc\"";
print OUTPUT_RTAB "Gene";

foreach $isolate(@isolate_array){
	print OUTPUT ",\"$isolate\"";
	print OUTPUT_RTAB "\t$isolate";
}
print OUTPUT "\n";
print OUTPUT_RTAB "\n";

foreach $cluster(@cluster_sorted_array){
	$ave_seqs=($cluster_seq_count_hash{$cluster}/$cluster_isolate_count_hash{$cluster});
	
	print OUTPUT "\"$cluster\",\"\",\"\",\"$cluster_isolate_count_hash{$cluster}\",\"$cluster_seq_count_hash{$cluster}\",\"$ave_seqs\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\"";
	foreach $isolate(@isolate_array){
		if($cluster_hash{$cluster}{$isolate}){
			print OUTPUT ",\"$cluster_hash{$cluster}{$isolate}\"";
			print OUTPUT_RTAB "\t1";
		}else{
			print OUTPUT ",\"\"";
			print OUTPUT_RTAB "\t0";
		}
	}
	print OUTPUT "\n";
	print OUTPUT_RTAB "\n";
}

print STDOUT "IGR presence absence matrix produced.\n";
print STDERR "IGR presence absence matrix produced.\n";

