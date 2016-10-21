#!/usr/bin/perl -w

$out_dir=$ARGV[0];

open LOG, ">>$out_dir/log.txt";

open OUTPUT, ">$out_dir/clusters.txt";

mkdir "$out_dir/cluster_intergenic_files";

open INPUT, "$out_dir/output_fasta_clustered.fasta.clstr";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /^>(.+)/){
		$cluster=$1;
		$cluster=~s/ /_/g;
		
		print OUTPUT "$cluster\n";
		
		open OUTPUT_CLU, ">$out_dir/cluster_intergenic_files/$cluster.fasta";
		
	}elsif($line =~ /^\d+\s+\d+nt,\s+\>(\S+)\.\.\./){
		$cluster_id=$1;
		@cluster_id_array=split(/_\+_\+_/, $cluster_id);
		$isolate=$cluster_id_array[0];
		
		open INPUT_CLU, "$out_dir/isolate_intergenic_files/$isolate/$cluster_id.fasta";
		while(<INPUT_CLU>){
			$line=$_;
			chomp $line;
			
			if($line =~ /^>(.+)/){
			
			}else{
				print OUTPUT_CLU ">$cluster_id\n$line\n";
			}
		}
	}
}

close LOG;

